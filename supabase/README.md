# Hayati backend (Supabase)

- `migrations/` — PostgreSQL schema, constraints, indexes, Row Level Security, and the assistant functions (`apply_assistant_action`, `consume_assistant_request`, …).
- `functions/assistant/` — Edge Function that sends the user's message, the *shared* data the app passes in, and the app's tool list to Gemini (`gemini-2.5-flash`, override with `GEMINI_MODEL`), and returns the reply and the proposed tool calls. It applies nothing: the app validates each call against the user's own records, asks for approval (unless the user allowed that kind of change), applies it on the device and syncs it under RLS.
- `tests/` — runs the migration on a throwaway PostgreSQL with a stub `auth` schema and checks RLS isolation between two users, ownership-safe links, atomic rollback, run-once execution, stale-proposal refusal and the daily limit.

```bash
# Local tests (PostgreSQL 15+, as a non-root user)
supabase/tests/run.sh

# Deploy
supabase db push
supabase secrets set GEMINI_API_KEY=...           # from aistudio.google.com; never shipped in the app
supabase functions deploy assistant
```

The function uses the caller's JWT for every query, so RLS applies; the service-role key is not used. The Flutter app connects with `--dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=…` (auth + data sync; see `hayati_app/README.md`). Verified against a local `supabase start` stack by `hayati_app/test/supabase_integration_test.dart`, which CI also runs.

When connected and signed in, the app's assistant calls this function; if it can't be reached (not deployed, no key, offline, provider error) the on-device assistant answers the simple requests it knows and says the smart assistant is offline. The tools (27: tasks, calendar, alarms, goals, habits, notes, money, health, workouts, learning, notifications, opening screens) are declared in `hayati_app/lib/domain/assistant/catalog.dart` and validated in `tools.dart`.

To exercise the function locally without a real key, serve it against a fake Gemini API (`GEMINI_API_KEY=test-key` and `GEMINI_BASE_URL=http://host.docker.internal:<port>` in the env file) and run the integration test with `ASSISTANT_TEST=1`.

```bash
supabase start          # local stack on :54321, applies migrations/
supabase migration up   # apply new migrations to it
```
