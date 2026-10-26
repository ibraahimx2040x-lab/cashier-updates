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

The function uses the caller's JWT for every query, so RLS applies; the service-role key is not used. The Flutter app connects with `--dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=…` (auth + data sync; see `hayati_app/README.md`). Verified against a local `supabase start` stack by `hayati_app/test/supabase_integration_test.dart`, which CI also runs.

When connected and signed in, the app's assistant calls this function; if it can't be reached (not deployed, offline, provider error) the on-device assistant answers instead. Cloud proposals are executed and rejected on the server (`/assistant/execute`, `/assistant/reject`) and can't be edited on the device.

To exercise the function locally without a real key, serve it against a fake Messages API (`ANTHROPIC_BASE_URL=http://host.docker.internal:<port>` in the env file) and run the integration test with `ASSISTANT_TEST=1`. It has not yet been run against the live Claude API.

```bash
supabase start          # local stack on :54321, applies migrations/
supabase migration up   # apply new migrations to it
```
