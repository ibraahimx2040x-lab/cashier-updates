// Sanad assistant — Supabase Edge Function (Gemini).
//
// POST /assistant   { conversationId?, message, now, timeZone, locale, context, tools }
//   → { conversationId, reply, kind, calls, executor: "device" }
//
// Security model:
// * The user's JWT is forwarded to Postgres, so every read and write runs
//   under row-level security. The service-role key is never used here.
// * The model only *proposes* tool calls. The app validates each one against
//   the user's own records and shows it for approval (unless the user lets
//   that kind of change run by itself) before applying it on the device;
//   the change then syncs under RLS like any edit the user makes.
// * The app sends only the sections the user shares with the assistant
//   (assistant permissions), and the daily allowance is enforced in the
//   database.
// * GEMINI_API_KEY lives only in the function's secrets.

import { createClient, type SupabaseClient } from "@supabase/supabase-js";

const MODEL = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash";
// Overridable only for local tests against a fake server.
const GEMINI_URL = Deno.env.get("GEMINI_BASE_URL") ?? "https://generativelanguage.googleapis.com";
const DAILY_LIMIT = { free: 30, pro: 300 } as const;
const MAX_CONTEXT_BYTES = 150_000;
const MAX_TOOLS_BYTES = 60_000;

const cors = {
  "Access-Control-Allow-Origin": Deno.env.get("ALLOWED_ORIGIN") ?? "*",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey, x-client-info",
};

const SYSTEM = `You are the assistant inside Sanad («سَنَد»), a personal life app: tasks, calendar, alarms, goals, habits, notes, money, health, water, sleep, workouts, English lessons and settings.

Reply in the user's language. In Arabic, use a warm, simple Gulf dialect. Keep replies short.

You can do anything in the app through the provided tools. When the user asks for something a tool can do, call the tool(s) — never say you can't when a tool fits. Use several calls in one turn for a request with several parts. The app shows your calls to the user to approve before anything changes (except small ones they allowed), so describe what you are proposing; never claim it is already done.

Rules:
- Use only ids from <user_data>. Never invent ids. Exercises must come from exercise_catalog.
- Ask a short question only when a request is truly ambiguous (e.g. "at 8" with no morning/evening). Otherwise make sensible assumptions and say them.
- Dates are in the user's time zone; times are minutes after midnight where the tool says so.
- Workout plans repeat weekly. "Every day / no rest day" means all 7 weekdays. For a plan with a length (e.g. 90 days) also create a goal whose targetDate is that many days from today. Pick exercises that match the request, the user's level and their place (home: body weight or their equipment). Vary days a little and keep sessions reasonable.
- Planning a day: keep events fixed, put tasks only in free time inside the day hours, respect priorities and deadlines, leave breaks, and never squeeze in more than fits.
- Goals: 3–6 concrete milestones; at most the first week of tasks.
- Progress reviews: describe what the numbers show; don't invent causes.
- Money: amounts are in the user's currency, major units. No investment, banking or tax advice.
- Health: no diagnosis. For pain, pregnancy or medical conditions suggest a doctor.
- If a section is missing from <user_data>, the user hasn't shared it; say so if it matters.`;

type Body = {
  conversationId?: string;
  message?: string;
  now?: string;
  timeZone?: string;
  locale?: string;
  context?: unknown;
  tools?: unknown;
};

type Part = { text?: string; functionCall?: { name: string; args?: Record<string, unknown> }; thought?: boolean };

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const auth = req.headers.get("Authorization");
  if (!auth?.startsWith("Bearer ")) return json({ error: "unauthorized" }, 401);
  const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: auth } },
    auth: { persistSession: false },
  });
  const { data: userData, error: userErr } = await db.auth.getUser(auth.slice(7));
  if (userErr || !userData.user) return json({ error: "unauthorized" }, 401);

  let body: Body;
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_json" }, 400);
  }
  const path = new URL(req.url).pathname;
  // Proposals are now applied on the device; older app versions may still
  // ask the server to reject one.
  if (path.endsWith("/execute") || path.endsWith("/reject")) return json({ outcome: "not_found" });
  return chat(db, body);
});

async function chat(db: SupabaseClient, body: Body) {
  const key = Deno.env.get("GEMINI_API_KEY");
  if (!key) return json({ error: "not_configured" }, 503);

  const message = body.message?.trim();
  if (!message || message.length > 4000) return json({ error: "message" }, 400);
  const tools = checkTools(body.tools);
  if (!tools) return json({ error: "tools" }, 400);
  const context = JSON.stringify(body.context ?? {});
  if (context.length > MAX_CONTEXT_BYTES) return json({ error: "context_too_large" }, 413);

  const { data: profile } = await db.from("profiles").select("assistant_permissions,time_zone").single();
  if (!profile) return json({ error: "no_profile" }, 400);
  if (!(profile.assistant_permissions as { enabled?: boolean })?.enabled) return json({ error: "assistant_disabled" }, 403);

  const { data: sub } = await db.from("subscriptions").select("plan,status").single();
  const plan = sub?.plan === "pro" && sub.status !== "expired" ? "pro" : "free";
  const { data: allowed } = await db.rpc("consume_assistant_request", { p_daily_limit: DAILY_LIMIT[plan] });
  if (!allowed) return json({ error: "limit_reached" }, 429);

  // Conversation + user message are stored before calling the model, so a
  // provider failure never loses what the user wrote.
  let conversationId = body.conversationId;
  if (conversationId) {
    if (!/^[0-9a-f-]{36}$/i.test(conversationId)) return json({ error: "conversationId" }, 400);
    const { error } = await db
      .from("assistant_conversations")
      .upsert({ id: conversationId, title: message.slice(0, 40) }, { onConflict: "id", ignoreDuplicates: true });
    if (error) return json({ error: "conversation" }, 500);
  } else {
    const { data, error } = await db.from("assistant_conversations").insert({ title: message.slice(0, 40) }).select("id").single();
    if (error) return json({ error: "conversation" }, 500);
    conversationId = data.id;
  }
  const { data: history } = await db
    .from("assistant_messages")
    .select("role,kind,content")
    .eq("conversation_id", conversationId)
    .neq("kind", "error")
    .order("created_at", { ascending: false })
    .limit(20);
  await db.from("assistant_messages").insert({ conversation_id: conversationId, role: "user", content: message });

  // Earlier turns as plain text, merged so roles alternate.
  const contents: { role: "user" | "model"; parts: { text: string }[] }[] = [];
  for (const m of (history ?? []).reverse()) {
    const text = (m.content as string).trim();
    if (!text) continue;
    const role = m.role === "assistant" ? "model" : "user";
    const last = contents.at(-1);
    if (last && last.role === role) last.parts[0].text += `\n${text}`;
    else contents.push({ role, parts: [{ text }] });
  }
  if (contents.at(-1)?.role === "user") contents.push({ role: "model", parts: [{ text: "…" }] });
  const now = body.now && !Number.isNaN(Date.parse(body.now)) ? body.now : new Date().toISOString();
  contents.push({
    role: "user",
    parts: [
      { text: `<now>${now} (${body.timeZone ?? profile.time_zone})</now>\n<user_data>\n${context}\n</user_data>` },
      { text: message },
    ],
  });

  let res: Response;
  try {
    res = await fetch(`${GEMINI_URL}/v1beta/models/${MODEL}:generateContent`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "x-goog-api-key": key },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: SYSTEM }] },
        contents,
        tools: [{ functionDeclarations: tools }],
        toolConfig: { functionCallingConfig: { mode: "AUTO" } },
        generationConfig: { temperature: 0.3, maxOutputTokens: 8192 },
      }),
      signal: AbortSignal.timeout(80_000),
    });
  } catch (e) {
    console.error("gemini fetch failed", String(e));
    await saveReply(db, conversationId!, "error", "provider_error");
    return json({ conversationId, error: "provider_error" }, 502);
  }
  if (!res.ok) {
    console.error("gemini error", res.status, (await res.text()).slice(0, 500));
    await saveReply(db, conversationId!, "error", "provider_error");
    return json({ conversationId, error: "provider_error" }, res.status === 429 ? 503 : 502);
  }
  const out = await res.json();

  const usage = out.usageMetadata ?? {};
  await db.rpc("record_assistant_tokens", {
    p_input: usage.promptTokenCount ?? 0,
    p_output: (usage.candidatesTokenCount ?? 0) + (usage.thoughtsTokenCount ?? 0),
  }).then(() => {}, () => {});

  const cand = out.candidates?.[0];
  if (!cand || cand.finishReason === "SAFETY" || cand.finishReason === "PROHIBITED_CONTENT" || out.promptFeedback?.blockReason) {
    await saveReply(db, conversationId!, "error", "refusal");
    return json({ conversationId, kind: "error", error: "refusal" });
  }

  const parts: Part[] = cand.content?.parts ?? [];
  const reply = parts.filter((p) => p.text && !p.thought).map((p) => p.text!).join("\n").trim();
  const allowedNames = new Set(tools.map((t) => t.name));
  const calls = parts
    .filter((p) => p.functionCall && allowedNames.has(p.functionCall.name))
    .slice(0, 40)
    .map((p) => ({ tool: p.functionCall!.name, args: p.functionCall!.args ?? {} }));

  await saveReply(db, conversationId!, calls.length ? "proposal" : "text", reply || (calls.length ? "…" : ""));
  return json({ conversationId, kind: "text", reply, calls, executor: "device" });
}

/** The app's tool list: names and JSON shapes only, size-capped. */
function checkTools(v: unknown): { name: string }[] | null {
  if (!Array.isArray(v) || v.length === 0 || v.length > 40) return null;
  if (JSON.stringify(v).length > MAX_TOOLS_BYTES) return null;
  for (const t of v) {
    if (!t || typeof t !== "object" || typeof t.name !== "string" || !/^[a-z_]{1,40}$/.test(t.name)) return null;
    if (typeof t.description !== "string" || typeof t.parameters !== "object") return null;
  }
  return v as { name: string }[];
}

async function saveReply(db: SupabaseClient, conversationId: string, kind: string, content: string) {
  await db.from("assistant_messages").insert({ conversation_id: conversationId, role: "assistant", kind, content });
}

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), { status, headers: { ...cors, "Content-Type": "application/json" } });
}
