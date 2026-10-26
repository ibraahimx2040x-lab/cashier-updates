// Hayati assistant — Supabase Edge Function.
//
// POST /assistant            { conversationId?, message, now, timeZone, locale }
//   → { conversationId, reply, kind, actionId?, actionStatus? }
// POST /assistant/execute    { actionId }   → apply an approved proposal
// POST /assistant/reject     { actionId }
//
// Security model (design doc §17, §23):
// * The user's JWT is forwarded to Postgres, so every read and write runs
//   under row-level security. The service-role key is never used here.
// * The model only *proposes* tool calls. Each is validated (tools.ts),
//   checked against the user's grants, stored, and applied by the database
//   function apply_assistant_action — atomically and at most once.
// * Only the sections the user shares (assistant_permissions) are sent to
//   the model, and the daily allowance is enforced in the database.

import Anthropic from "@anthropic-ai/sdk";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";

import { needsApproval, type Owned, type Permissions, TOOLS, type ToolCall, validate } from "./tools.ts";

const MODEL = "claude-opus-5-5";
const DAILY_LIMIT = { free: 30, pro: 300 } as const;

const anthropic = new Anthropic({ apiKey: Deno.env.get("ANTHROPIC_API_KEY") });

const cors = {
  "Access-Control-Allow-Origin": Deno.env.get("ALLOWED_ORIGIN") ?? "*",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey, x-client-info",
};

// Frozen system prompt: stable bytes so it stays cached across requests.
// Anything that varies per request (date, data) goes in the user turn.
const SYSTEM = `You are the assistant inside Hayati («حياتي»), a personal planner for tasks, events, goals, habits, notes and expenses.

Reply in the user's language (Arabic or English), briefly and warmly.

You can only change the user's data by calling the provided tools. Tool calls are proposals: the app shows them to the user, who approves or rejects them, unless the user has allowed that kind of change to happen automatically. Never claim something was created, moved or deleted — say what you are proposing.

Rules:
- Use only ids that appear in the user's data block. Never invent ids.
- If a request is ambiguous (e.g. "at 8" without morning/evening, or which task is meant), ask a short question instead of calling a tool.
- Planning a day: keep fixed events in place, put tasks only in free time inside the user's day hours, respect priorities and deadlines, leave breathing room, and never squeeze in more than fits. If tasks don't fit, say which ones and suggest moving them. If a duration is unknown, say you assumed one.
- Breaking down a goal: 3–6 concrete milestones; create at most the first week of tasks.
- Progress reviews: describe what the numbers show. Do not claim causes (sleep, phone use, motivation) that the data doesn't contain.
- Money: you see only manually entered expenses. Give no investment, banking or tax advice.
- If a section of data is missing, the user hasn't shared it with you; say so if it matters.`;

type Body = { conversationId?: string; message?: string; now?: string; timeZone?: string; locale?: string; actionId?: string };

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
  if (path.endsWith("/execute")) return execute(db, body.actionId);
  if (path.endsWith("/reject")) return reject(db, body.actionId);
  return chat(db, body);
});

async function execute(db: SupabaseClient, actionId?: string) {
  if (!actionId) return json({ error: "actionId" }, 400);
  const { data, error } = await db.rpc("apply_assistant_action", { p_action_id: actionId });
  if (error) return json({ error: "apply_failed" }, 500);
  return json(data);
}

async function reject(db: SupabaseClient, actionId?: string) {
  if (!actionId) return json({ error: "actionId" }, 400);
  const { error } = await db.rpc("reject_assistant_action", { p_action_id: actionId });
  return error ? json({ error: "reject_failed" }, 500) : json({ outcome: "rejected" });
}

async function chat(db: SupabaseClient, body: Body) {
  const message = body.message?.trim();
  if (!message || message.length > 4000) return json({ error: "message" }, 400);

  const { data: profile } = await db.from("profiles").select("*").single();
  if (!profile) return json({ error: "no_profile" }, 400);
  const perms = profile.assistant_permissions as Permissions;
  if (!perms.enabled) return json({ error: "assistant_disabled" }, 403);

  const { data: sub } = await db.from("subscriptions").select("plan,status").single();
  const plan = sub?.plan === "pro" && sub.status !== "expired" ? "pro" : "free";
  const { data: allowed } = await db.rpc("consume_assistant_request", { p_daily_limit: DAILY_LIMIT[plan] });
  if (!allowed) return json({ error: "limit_reached" }, 429);

  // Conversation + user message are stored before calling the model, so a
  // provider failure never loses what the user wrote.
  let conversationId = body.conversationId;
  if (conversationId) {
    // The app names conversations itself (it keeps a device copy); create
    // the server row on first use. RLS stops reuse of another user's id.
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

  const { context, owned, versions } = await loadContext(db, perms, profile);
  const now = body.now && !Number.isNaN(Date.parse(body.now)) ? body.now : new Date().toISOString();

  // Earlier turns as plain text, merged so roles alternate.
  const past: Anthropic.Beta.Messages.BetaMessageParam[] = [];
  for (const m of (history ?? []).reverse()) {
    const content = (m.content as string).trim();
    if (!content) continue;
    const last = past.at(-1);
    if (last && last.role === m.role) last.content = `${last.content}\n${content}`;
    else past.push({ role: m.role as "user" | "assistant", content });
  }
  if (past.at(-1)?.role === "user") past.push({ role: "assistant", content: "…" });
  const messages: Anthropic.Beta.Messages.BetaMessageParam[] = [
    ...past,
    {
      role: "user",
      content: [
        {
          type: "text",
          text: `<now>${now} (${body.timeZone ?? profile.time_zone})</now>\n<user_data>\n${JSON.stringify(context)}\n</user_data>`,
        },
        { type: "text", text: message },
      ],
    },
  ];

  let response: Anthropic.Beta.Messages.BetaMessage;
  try {
    response = await anthropic.beta.messages.create({
      model: MODEL,
      max_tokens: 8000,
      betas: ["server-side-fallback-2026-07-01"],
      // On a safety-classifier decline, the API retries on Anthropic's
      // recommended fallback model inside the same call.
      fallbacks: "default",
      // Chat turns should feel quick; effort is the only depth control on
      // this model (thinking is always on).
      output_config: { effort: "medium" },
      system: [{ type: "text", text: SYSTEM, cache_control: { type: "ephemeral" } }],
      tools: TOOLS,
      tool_choice: { type: "auto" },
      messages,
    });
  } catch (e) {
    const status = e instanceof Anthropic.RateLimitError ? 503 : 502;
    await saveReply(db, conversationId!, "error", "provider_error");
    return json({ conversationId, error: "provider_error" }, status);
  }

  await db.rpc("record_assistant_tokens", {
    p_input: response.usage.input_tokens + (response.usage.cache_read_input_tokens ?? 0),
    p_output: response.usage.output_tokens,
  }).then(() => {}, () => {});

  if (response.stop_reason === "refusal") {
    await saveReply(db, conversationId!, "error", "refusal");
    return json({ conversationId, kind: "error", error: "refusal" });
  }

  const text = response.content
    .filter((b): b is Anthropic.Beta.Messages.BetaTextBlock => b.type === "text")
    .map((b) => b.text)
    .join("\n")
    .trim();

  // Validate every proposed call; drop the whole batch if any is invalid.
  const calls: ToolCall[] = [];
  const invalid: string[] = [];
  for (const block of response.content) {
    if (block.type !== "tool_use") continue;
    const r = validate(block.name, block.input, owned);
    if (typeof r === "string") invalid.push(`${block.name}:${r}`);
    else calls.push(r);
  }
  if (invalid.length > 0 || calls.length === 0) {
    const reply = text || (invalid.length ? "invalid_proposal" : "");
    await saveReply(db, conversationId!, invalid.length ? "error" : "text", reply);
    return json({ conversationId, kind: invalid.length ? "error" : "text", reply, invalid });
  }

  if (calls.every((c) => c.tool === "plan_task") && !perms.autoDraftPlans) {
    await saveReply(db, conversationId!, "info", text);
    return json({ conversationId, kind: "info", reply: text, note: "drafts_disabled" });
  }

  const snapshot = Object.fromEntries(
    calls.flatMap((c) => ["taskId", "goalId"].map((k) => c.args[k] as string | undefined))
      .filter((id): id is string => !!id && versions.has(id))
      .map((id) => [id, versions.get(id)!]),
  );
  const auto = !needsApproval(calls, perms);
  const { data: action, error: actionErr } = await db
    .from("assistant_actions")
    .insert({ conversation_id: conversationId, reason: text.slice(0, 500), calls, snapshot, auto })
    .select("id")
    .single();
  if (actionErr) return json({ error: "action" }, 500);

  let actionStatus = "pending";
  if (auto) {
    const { data: applied } = await db.rpc("apply_assistant_action", { p_action_id: action.id });
    actionStatus = (applied as { outcome: string } | null)?.outcome ?? "failed";
  }
  const kind = calls.every((c) => c.tool === "plan_task" || c.tool === "move_task") && calls.length > 1 ? "plan" : "proposal";
  await db.from("assistant_messages").insert({
    conversation_id: conversationId,
    role: "assistant",
    kind,
    content: text,
    action_id: action.id,
  });
  return json({ conversationId, kind, reply: text, actionId: action.id, actionStatus, calls });
}

/** Only the sections the user shares, capped in size. */
async function loadContext(db: SupabaseClient, p: Permissions, profile: Record<string, unknown>) {
  const owned: Owned = { tasks: new Set(), goals: new Set(), habits: new Set() };
  const versions = new Map<string, string>();
  const context: Record<string, unknown> = {
    day_hours: { start: profile.day_start, end: profile.day_end },
    work: profile.work_start == null ? null : { start: profile.work_start, end: profile.work_end, days: profile.work_days },
    breaks: profile.breaks,
    week_start: profile.week_start,
  };
  const horizon = new Date(Date.now() + 14 * 864e5).toISOString().slice(0, 10);

  if (p.shareTasks) {
    const { data } = await db
      .from("tasks")
      .select("id,title,due_date,due_time,estimated_minutes,priority,status,goal_id,milestone_id,planned_start,updated_at")
      .eq("archived", false)
      .in("status", ["todo", "in_progress"])
      .or(`due_date.is.null,due_date.lte.${horizon}`)
      .order("due_date", { ascending: true, nullsFirst: false })
      .limit(100);
    context.tasks = (data ?? []).map(({ updated_at, ...t }) => {
      owned.tasks.add(t.id);
      versions.set(t.id, updated_at);
      return t;
    });
  }
  if (p.shareEvents) {
    const { data } = await db
      .from("events")
      .select("id,title,starts_at,ends_at")
      .gte("ends_at", new Date().toISOString())
      .lte("starts_at", new Date(Date.now() + 7 * 864e5).toISOString())
      .order("starts_at")
      .limit(100);
    context.events = data ?? [];
  }
  if (p.shareGoals) {
    const { data } = await db
      .from("goals")
      .select("id,title,category,target_date,progress_mode,manual_progress,status,updated_at,goal_milestones(id,title,done,position)")
      .in("status", ["active", "paused"])
      .limit(30);
    context.goals = (data ?? []).map(({ updated_at, ...g }) => {
      owned.goals.add(g.id);
      versions.set(g.id, updated_at);
      return g;
    });
  }
  if (p.shareHabits) {
    const since = new Date(Date.now() - 14 * 864e5).toISOString().slice(0, 10);
    const { data } = await db.from("habits").select("id,name,weekdays,active,habit_logs(day)").eq("active", true).gte("habit_logs.day", since);
    context.habits = (data ?? []).map((h) => {
      owned.habits.add(h.id);
      return h;
    });
  }
  if (p.shareExpenses) {
    const since = new Date(Date.now() - 31 * 864e5).toISOString();
    const { data } = await db.from("expenses").select("amount_minor,currency,category,spent_at").gte("spent_at", since).limit(300);
    context.expenses_last_31_days = data ?? [];
  }
  // Notes are never sent unless shared, and then only titles.
  if (p.shareNotes) {
    const { data } = await db.from("notes").select("title").eq("archived", false).limit(50);
    context.note_titles = (data ?? []).map((n) => n.title);
  }
  return { context, owned, versions };
}

async function saveReply(db: SupabaseClient, conversationId: string, kind: string, content: string) {
  await db.from("assistant_messages").insert({ conversation_id: conversationId, role: "assistant", kind, content });
}

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), { status, headers: { ...cors, "Content-Type": "application/json" } });
}
