# Hayati backend (Supabase)

- `migrations/` — PostgreSQL schema, constraints, indexes, Row Level Security, and the assistant functions (`apply_assistant_action`, `consume_assistant_request`, …).
- `functions/assistant/` — Edge Function that sends the user's *shared* data to Claude (`claude-opus-5-5`), validates the proposed tool calls, stores them in `assistant_actions`, and applies them through `apply_assistant_action` when the user's grants allow it or the user approves.
- `tests/` — runs the migration on a throwaway PostgreSQL with a stub `auth` schema and checks RLS isolation between two users, ownership-safe links, atomic rollback, run-once execution, stale-proposal refusal and the daily limit.

```bash
# Local tests (PostgreSQL 15+, as a non-root user)
supabase/tests/run.sh

# Deploy
supabase db push
supabase secrets set ANTHROPIC_API_KEY=...        # never shipped in the app
supabase functions deploy assistant
```

The function uses the caller's JWT for every query, so RLS applies; the service-role key is not used. Status: type-checked and its validator unit-checked; not yet exercised against the live Claude API or a deployed Supabase project, and the Flutter app does not call it yet (see `docs/ROADMAP.md`).
