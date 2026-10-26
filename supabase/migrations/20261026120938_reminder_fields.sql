-- Reminder fields used by the app's task and event editors.
alter table public.tasks add column reminder_at timestamptz;
alter table public.events add column reminder_minutes_before smallint
  check (reminder_minutes_before between 0 and 10080);
