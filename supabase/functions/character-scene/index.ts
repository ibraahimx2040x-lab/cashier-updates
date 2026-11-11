// Rafiq scene drawing — Supabase Edge Function (Gemini image model).
//
// POST /character-scene
//   { character: { name, appearance?, scenario? },
//     reference?: { mimeType: "image/png" | "image/jpeg" | "image/webp", data: base64 },
//     scene: "the *actions* from the message", message?: "the full message for context" }
//   → { mimeType, data }  (base64 image)
//
// The character's portrait is sent as a reference so the drawing keeps the
// same look. GEMINI_API_KEY lives only in the function's secrets; every field
// is size-capped so a single request stays one small image.

const MODEL = Deno.env.get("SCENE_MODEL") ?? "gemini-3.1-flash-image";
const GEMINI_URL = Deno.env.get("GEMINI_BASE_URL") ?? "https://generativelanguage.googleapis.com";
const MAX_REFERENCE_BASE64 = 600_000; // ~450 KB image
const MIME = new Set(["image/png", "image/jpeg", "image/webp"]);

const cors = {
  "Access-Control-Allow-Origin": Deno.env.get("ALLOWED_ORIGIN") ?? "*",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type Body = {
  character?: { name?: unknown; appearance?: unknown; scenario?: unknown };
  reference?: { mimeType?: unknown; data?: unknown };
  scene?: unknown;
  message?: unknown;
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
  const scene = str(body.scene, 600);
  if (!name || !scene) return json({ error: "bad_request" }, 400);
  const appearance = str(body.character?.appearance, 600);
  const scenario = str(body.character?.scenario, 800);
  const message = str(body.message, 1500);

  const parts: ({ text: string } | { inlineData: { mimeType: string; data: string } })[] = [];
  const ref = body.reference;
  if (ref && typeof ref.data === "string" && typeof ref.mimeType === "string") {
    if (!MIME.has(ref.mimeType) || ref.data.length > MAX_REFERENCE_BASE64 || !/^[A-Za-z0-9+/=]+$/.test(ref.data)) {
      return json({ error: "bad_request" }, 400);
    }
    parts.push({ inlineData: { mimeType: ref.mimeType, data: ref.data } });
  }

  parts.push({
    text: `Draw one anime-style illustration (clean line art, soft cel shading, vivid colours, cinematic framing) of the character ${name} in this moment:

<moment>
${scene}
</moment>
${message ? `\nWhat ${name} said at that moment, for mood and context only (do not write it in the image):\n<message>\n${message}\n</message>\n` : ""}${scenario ? `\nSetting of the story: ${scenario}\n` : ""}${appearance ? `\nAppearance of ${name}: ${appearance}\n` : ""}${ref?.data ? `\nThe attached picture is ${name}'s portrait. Keep the same face, hair style and colour, eye colour, skin tone, outfit and accessories.\n` : ""}
Rules:
- Show the action, pose, facial expression and surroundings described in the moment. Include the setting and objects it mentions.
- The moment is written in first person by ${name} ("I"), possibly in Arabic; "I" means ${name}.
- No text, letters, captions or speech bubbles in the image.
- Keep it non-sexual and free of gore; everyone fully clothed.`,
  });

  let res: Response;
  try {
    res = await fetchRetry(`${GEMINI_URL}/v1beta/models/${MODEL}:generateContent`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "x-goog-api-key": key },
      body: JSON.stringify({
        contents: [{ role: "user", parts }],
        generationConfig: { responseModalities: ["IMAGE"], imageConfig: { aspectRatio: "4:3" } },
      }),
      signal: AbortSignal.timeout(90_000),
    });
  } catch (e) {
    console.error("gemini fetch failed", String(e));
    return json({ error: "provider_error" }, 502);
  }
  if (!res.ok) {
    const detail = await res.text();
    console.error("gemini error", res.status, detail.slice(0, 500));
    // 429 with a quota message means the key's plan doesn't cover this model.
    const code = res.status === 429 && /quota/i.test(detail) ? "quota" : busy(res.status) ? "busy" : "provider_error";
    return json({ error: code }, code === "provider_error" ? 502 : 503);
  }

  const out = await res.json();
  const cand = out.candidates?.[0];
  const img = (cand?.content?.parts ?? []).find((p: { inlineData?: { data?: string } }) => p.inlineData?.data)?.inlineData;
  if (!img) {
    const blocked = out.promptFeedback?.blockReason || ["SAFETY", "PROHIBITED_CONTENT", "IMAGE_SAFETY"].includes(cand?.finishReason);
    console.error("no image", cand?.finishReason, out.promptFeedback?.blockReason);
    return json({ error: blocked ? "refusal" : "empty" }, 200);
  }
  return json({ mimeType: img.mimeType ?? "image/png", data: img.data });
});

/** Google answers 503 when the model is overloaded; try once more after a short pause. */
async function fetchRetry(url: string, init: RequestInit): Promise<Response> {
  const res = await fetch(url, init);
  if (res.status !== 503) return res;
  await res.body?.cancel();
  await new Promise((r) => setTimeout(r, 1500));
  return fetch(url, init);
}

function busy(status: number) {
  return status === 429 || status === 503;
}

function str(v: unknown, max: number): string {
  return typeof v === "string" ? v.trim().slice(0, max) : "";
}

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), { status, headers: { ...cors, "Content-Type": "application/json" } });
}
