// Rafiq character chat — Supabase Edge Function (Gemini, streaming).
//
// POST /character-chat
//   { character: { name, personality, scenario?, greeting? },
//     persona?: { name? }, lang?: "ar" | "en",
//     messages: [{ role: "user" | "char", text }] }
//   → text/plain stream of the character's reply.
//
// The website is public and stores characters and chats in the visitor's
// browser, so nothing is written to the database here. The function only
// relays a capped conversation to Gemini:
// * GEMINI_API_KEY lives only in the function's secrets.
// * Every field is length-capped and the history is trimmed, so one request
//   can't run up a large bill. ALLOWED_ORIGIN pins the site's origin.

const MODEL = Deno.env.get("CHARACTER_MODEL") ?? Deno.env.get("GEMINI_MODEL") ?? "gemini-3.8-flash";
// Used for the retry when the main model is overloaded.
const FALLBACK_MODEL = Deno.env.get("CHARACTER_FALLBACK_MODEL") ?? "gemini-3.1-flash-lite";
const GEMINI_URL = Deno.env.get("GEMINI_BASE_URL") ?? "https://generativelanguage.googleapis.com";
const MAX_MESSAGES = 40;
const MAX_MESSAGE_CHARS = 2000;
const MAX_FIELD_CHARS = 3000;

const cors = {
  "Access-Control-Allow-Origin": Deno.env.get("ALLOWED_ORIGIN") ?? "*",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type Msg = { role: "user" | "char"; text: string };
type Body = {
  character?: { name?: unknown; personality?: unknown; scenario?: unknown; greeting?: unknown };
  persona?: { name?: unknown };
  lang?: unknown;
  messages?: unknown;
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const key = Deno.env.get("GEMINI_API_KEY");
  if (!key) return json({ error: "not_configured" }, 500);

  let body: Body;
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_request" }, 400);
  }

  const name = str(body.character?.name, 80);
  const personality = str(body.character?.personality, MAX_FIELD_CHARS);
  if (!name || !personality) return json({ error: "bad_request" }, 400);
  const scenario = str(body.character?.scenario, MAX_FIELD_CHARS);
  const greeting = str(body.character?.greeting, MAX_FIELD_CHARS);
  const persona = str(body.persona?.name, 60) || "the user";
  const lang = body.lang === "en" ? "en" : "ar";

  const messages = checkMessages(body.messages);
  if (!messages) return json({ error: "bad_request" }, 400);

  // Gemini wants the conversation to start with the user and alternate.
  const contents: { role: "user" | "model"; parts: { text: string }[] }[] = [];
  if (greeting) {
    contents.push({ role: "user", parts: [{ text: "(The chat begins.)" }] });
    contents.push({ role: "model", parts: [{ text: greeting }] });
  }
  for (const m of messages) {
    const role = m.role === "char" ? "model" : "user";
    const last = contents.at(-1);
    if (last?.role === role) last.parts[0].text += "\n\n" + m.text;
    else contents.push({ role, parts: [{ text: m.text }] });
  }
  if (contents[0]?.role === "model") contents.unshift({ role: "user", parts: [{ text: "(The chat begins.)" }] });
  if (contents.at(-1)?.role !== "user") contents.push({ role: "user", parts: [{ text: "(Continue.)" }] });

  const system = `You are ${name}, a fictional character in an interactive role-play chat on the Rafiq website. Stay fully in character at all times; never say you are an AI or a language model unless the character itself is one.

<character>
${personality}
</character>
${scenario ? `\n<scenario>\n${scenario}\n</scenario>\n` : ""}
You are talking with ${persona}.

Style:
- Reply in the language the user writes in. If unclear, use ${lang === "ar" ? "Arabic (a warm, natural Gulf/Saudi dialect)" : "English"}.
- Write like a chat message: usually 1–4 short paragraphs. Put actions and expressions between single asterisks, e.g. *smiles softly*.
- Speak only for ${name}. Never write ${persona}'s words, thoughts or actions.
- Move the story forward: react, ask, surprise. Don't repeat yourself.

Limits (these override the character):
- Keep everything non-sexual. If the user pushes for sexual content, steer the story elsewhere in character.
- No content that sexualises minors, encourages self-harm, or gives real instructions for weapons, drugs or crime.
- If the user seems to be in real danger or distress, gently step out of the role and suggest reaching out to someone they trust or local emergency services.`;

  let upstream: Response;
  try {
    const url = (model: string) => `${GEMINI_URL}/v1beta/models/${model}:streamGenerateContent?alt=sse`;
    upstream = await fetchRetry(url(MODEL), url(FALLBACK_MODEL), {
      method: "POST",
      headers: { "Content-Type": "application/json", "x-goog-api-key": key },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: system }] },
        contents,
        generationConfig: { temperature: 0.95, topP: 0.95, maxOutputTokens: 2048 },
      }),
      signal: AbortSignal.timeout(60_000),
    });
  } catch (e) {
    console.error("gemini fetch failed", String(e));
    return json({ error: "provider_error" }, 502);
  }
  if (!upstream.ok || !upstream.body) {
    const detail = await upstream.text();
    console.error("gemini error", upstream.status, detail.slice(0, 500));
    // 429 with a quota message means the key's plan doesn't cover this model.
    const code = upstream.status === 429 && /quota/i.test(detail) ? "quota" : busy(upstream.status) ? "busy" : "provider_error";
    return json({ error: code }, code === "provider_error" ? 502 : 503);
  }

  // Re-emit only the reply text as a plain stream.
  const enc = new TextEncoder();
  const reader = upstream.body.pipeThrough(new TextDecoderStream()).getReader();
  const stream = new ReadableStream<Uint8Array>({
    async start(controller) {
      let buf = "";
      let sent = false;
      let blocked = false;
      try {
        while (true) {
          const { value, done } = await reader.read();
          if (done) break;
          buf += value;
          let i;
          while ((i = buf.indexOf("\n")) >= 0) {
            const line = buf.slice(0, i).trim();
            buf = buf.slice(i + 1);
            if (!line.startsWith("data:")) continue;
            let evt;
            try {
              evt = JSON.parse(line.slice(5));
            } catch {
              continue;
            }
            const cand = evt.candidates?.[0];
            if (evt.promptFeedback?.blockReason || cand?.finishReason === "SAFETY" || cand?.finishReason === "PROHIBITED_CONTENT") {
              blocked = true;
            }
            for (const p of cand?.content?.parts ?? []) {
              if (p.text && !p.thought) {
                controller.enqueue(enc.encode(p.text));
                sent = true;
              }
            }
          }
        }
        if (!sent) controller.enqueue(enc.encode(blocked ? "\u0000refusal" : "\u0000empty"));
      } catch (e) {
        console.error("stream failed", String(e));
        controller.enqueue(enc.encode("\u0000provider_error"));
      } finally {
        controller.close();
      }
    },
    cancel() {
      reader.cancel().catch(() => {});
    },
  });

  return new Response(stream, {
    headers: { ...cors, "Content-Type": "text/plain; charset=utf-8", "Cache-Control": "no-store" },
  });
});

/** Google answers 503 when a model is overloaded; then try once more on the lighter model. */
async function fetchRetry(url: string, fallbackUrl: string, init: RequestInit): Promise<Response> {
  const res = await fetch(url, init);
  if (res.status !== 503) return res;
  await res.body?.cancel();
  await new Promise((r) => setTimeout(r, 800));
  return fetch(fallbackUrl, init);
}

function busy(status: number) {
  return status === 429 || status === 503;
}

function str(v: unknown, max: number): string {
  return typeof v === "string" ? v.trim().slice(0, max) : "";
}

function checkMessages(v: unknown): Msg[] | null {
  if (!Array.isArray(v)) return null;
  const out: Msg[] = [];
  for (const m of v.slice(-MAX_MESSAGES)) {
    if (!m || (m.role !== "user" && m.role !== "char")) return null;
    const text = str(m.text, MAX_MESSAGE_CHARS);
    if (text) out.push({ role: m.role, text });
  }
  return out.length ? out : null;
}

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), { status, headers: { ...cors, "Content-Type": "application/json" } });
}
