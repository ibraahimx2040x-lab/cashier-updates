-- Spec v3, phase 09: a workout can come from a fixed program (stretching,
-- balance, pelvic floor, pregnancy, after birth, back care). The program id
-- is a code key kept with the session; the programs themselves live in the
-- app, and which ones show depends on the user's sex and health modules.
alter table public.workout_sessions
  add column program_id text check (program_id ~ '^[a-z0-9_]{1,40}$');
