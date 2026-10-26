// The assistant's tool contract. Mirrors hayati_app/lib/domain/assistant/tools.dart
// — the client and server enforce the same names, arguments and tiers.
//
// The model never executes anything: a tool_use block is a *proposal* that is
// validated here, stored in assistant_actions, and applied by the database
// function apply_assistant_action under the caller's row-level security.

import type Anthropic from "@anthropic-ai/sdk";

const nullable = (type: string, extra: Record<string, unknown> = {}) => ({ type: [type, "null"], ...extra });
const day = { type: ["string", "null"], description: "Calendar day YYYY-MM-DD in the user's time zone, or null." };

// Strict schemas: every property is listed in `required`; optional values
// are expressed as nullable and stripped before storage.
export const TOOLS: Anthropic.Tool[] = [
  {
    name: "create_task",
    description:
      "Create one task. Use only when the user clearly asked to add a task. dueTime is minutes after midnight " +
      "(e.g. 20:00 = 1200). If the hour is ambiguous (AM/PM unclear), ask instead of calling this tool.",
    strict: true,
    input_schema: {
      type: "object",
      properties: {
        title: { type: "string" },
        dueDate: day,
        dueTime: nullable("integer"),
        estimatedMinutes: nullable("integer"),
        priority: { type: ["string", "null"], enum: ["low", "medium", "high", null] },
        goalId: nullable("string", { description: "Id of one of the user's goals from the context, or null." }),
      },
      required: ["title", "dueDate", "dueTime", "estimatedMinutes", "priority", "goalId"],
      additionalProperties: false,
    },
  },
  {
    name: "add_note",
    description: "Save a note the user dictated.",
    strict: true,
    input_schema: {
      type: "object",
      properties: { title: nullable("string"), body: { type: "string" } },
      required: ["title", "body"],
      additionalProperties: false,
    },
  },
  {
    name: "log_habit",
    description: "Record that the user completed one of their habits on a day (not in the future).",
    strict: true,
    input_schema: {
      type: "object",
      properties: { habitId: { type: "string" }, day: { type: "string", description: "YYYY-MM-DD" } },
      required: ["habitId", "day"],
      additionalProperties: false,
    },
  },
  {
    name: "plan_task",
    description:
      "Set when the user intends to work on an existing task (not its deadline). Call once per task when " +
      "proposing a day plan; place tasks only in free time around events and leave slack for breaks.",
    strict: true,
    input_schema: {
      type: "object",
      properties: {
        taskId: { type: "string" },
        plannedStart: { type: "string", description: "ISO-8601 timestamp with offset." },
      },
      required: ["taskId", "plannedStart"],
      additionalProperties: false,
    },
  },
  {
    name: "move_task",
    description: "Change an existing task's deadline day.",
    strict: true,
    input_schema: {
      type: "object",
      properties: { taskId: { type: "string" }, dueDate: { type: "string", description: "YYYY-MM-DD" } },
      required: ["taskId", "dueDate"],
      additionalProperties: false,
    },
  },
  {
    name: "create_goal",
    description:
      "Create a goal with ordered milestones and, optionally, a first set of tasks (at most the first week). " +
      "Each task's `milestone` is the 0-based index of the milestone it belongs to.",
    strict: true,
    input_schema: {
      type: "object",
      properties: {
        title: { type: "string" },
        category: { type: "string", enum: ["learning", "health", "work", "money", "personal"] },
        targetDate: day,
        why: nullable("string"),
        milestones: { type: "array", items: { type: "string" } },
        tasks: {
          type: "array",
          items: {
            type: "object",
            properties: {
              title: { type: "string" },
              dueDate: day,
              estimatedMinutes: nullable("integer"),
              milestone: nullable("integer"),
            },
            required: ["title", "dueDate", "estimatedMinutes", "milestone"],
            additionalProperties: false,
          },
        },
      },
      required: ["title", "category", "targetDate", "why", "milestones", "tasks"],
      additionalProperties: false,
    },
  },
  {
    name: "add_milestones",
    description: "Append milestones to one of the user's existing goals.",
    strict: true,
    input_schema: {
      type: "object",
      properties: { goalId: { type: "string" }, titles: { type: "array", items: { type: "string" } } },
      required: ["goalId", "titles"],
      additionalProperties: false,
    },
  },
  {
    name: "delete_task",
    description: "Delete one of the user's tasks. Always shown to the user for approval first.",
    strict: true,
    input_schema: {
      type: "object",
      properties: { taskId: { type: "string" } },
      required: ["taskId"],
      additionalProperties: false,
    },
  },
];

export type ToolCall = { tool: string; args: Record<string, unknown> };

export type Permissions = {
  enabled: boolean;
  autoCreateTasks: boolean;
  autoAddNotes: boolean;
  autoLogHabits: boolean;
  autoDraftPlans: boolean;
  approveReschedule: boolean;
  shareTasks: boolean;
  shareEvents: boolean;
  shareGoals: boolean;
  shareHabits: boolean;
  shareNotes: boolean;
  shareExpenses: boolean;
};

/** The ids the user owns, from the context sent to the model. */
export type Owned = { tasks: Set<string>; goals: Set<string>; habits: Set<string> };

const isDay = (v: unknown) => typeof v === "string" && /^\d{4}-\d{2}-\d{2}$/.test(v);
const isUuid = (v: unknown) =>
  typeof v === "string" && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v);
const isText = (v: unknown, max = 200) => typeof v === "string" && v.trim().length > 0 && v.length <= max;
const intIn = (v: unknown, lo: number, hi: number) => Number.isInteger(v) && (v as number) >= lo && (v as number) <= hi;

/** Drops null optionals (strict schemas send them as null). */
function compact(o: Record<string, unknown>): Record<string, unknown> {
  return Object.fromEntries(
    Object.entries(o)
      .filter(([, v]) => v !== null && v !== undefined)
      .map(([k, v]) => [k, Array.isArray(v) ? v.map((x) => (x && typeof x === "object" ? compact(x as Record<string, unknown>) : x)) : v]),
  );
}

/**
 * Validates one proposed call. Returns the cleaned call, or an error code.
 * Ownership is also enforced again by RLS when the call is applied.
 */
export function validate(name: string, input: unknown, owned: Owned): ToolCall | string {
  if (!TOOLS.some((t) => t.name === name)) return "unknown_tool";
  if (!input || typeof input !== "object") return "bad_input";
  const a = compact(input as Record<string, unknown>);
  switch (name) {
    case "create_task":
      if (!isText(a.title)) return "title";
      if (a.dueDate !== undefined && !isDay(a.dueDate)) return "dueDate";
      if (a.dueTime !== undefined && (!intIn(a.dueTime, 0, 1439) || a.dueDate === undefined)) return "dueTime";
      if (a.estimatedMinutes !== undefined && !intIn(a.estimatedMinutes, 1, 1440)) return "estimatedMinutes";
      if (a.goalId !== undefined && !owned.goals.has(a.goalId as string)) return "goalId";
      break;
    case "add_note":
      if (!isText(a.body, 20000)) return "body";
      break;
    case "log_habit":
      if (!owned.habits.has(a.habitId as string)) return "habitId";
      if (!isDay(a.day)) return "day";
      break;
    case "plan_task":
      if (!owned.tasks.has(a.taskId as string)) return "taskId";
      if (typeof a.plannedStart !== "string" || Number.isNaN(Date.parse(a.plannedStart))) return "plannedStart";
      break;
    case "move_task":
      if (!owned.tasks.has(a.taskId as string)) return "taskId";
      if (!isDay(a.dueDate)) return "dueDate";
      break;
    case "delete_task":
      if (!owned.tasks.has(a.taskId as string)) return "taskId";
      break;
    case "add_milestones":
      if (!owned.goals.has(a.goalId as string)) return "goalId";
      if (!Array.isArray(a.titles) || a.titles.length === 0 || a.titles.length > 20 || !a.titles.every((t) => isText(t))) {
        return "titles";
      }
      break;
    case "create_goal": {
      if (!isText(a.title)) return "title";
      if (a.targetDate !== undefined && !isDay(a.targetDate)) return "targetDate";
      const ms = a.milestones as unknown[];
      if (!Array.isArray(ms) || ms.length > 20 || !ms.every((t) => isText(t))) return "milestones";
      const ts = a.tasks as Record<string, unknown>[];
      if (!Array.isArray(ts) || ts.length > 50) return "tasks";
      for (const t of ts) {
        if (!isText(t.title)) return "tasks.title";
        if (t.dueDate !== undefined && !isDay(t.dueDate)) return "tasks.dueDate";
        if (t.milestone !== undefined && !intIn(t.milestone, 0, ms.length - 1)) return "tasks.milestone";
      }
      break;
    }
  }
  for (const k of ["taskId", "goalId", "habitId"]) {
    if (a[k] !== undefined && !isUuid(a[k])) return k;
  }
  return { tool: name, args: a };
}

/** Section 16: more than one call is a bulk change and always needs approval. */
export function needsApproval(calls: ToolCall[], p: Permissions): boolean {
  if (calls.length !== 1) return true;
  switch (calls[0].tool) {
    case "create_task":
      return !p.autoCreateTasks;
    case "add_note":
      return !p.autoAddNotes;
    case "log_habit":
      return !p.autoLogHabits;
    case "plan_task":
    case "move_task":
      return p.approveReschedule;
    default:
      return true;
  }
}
