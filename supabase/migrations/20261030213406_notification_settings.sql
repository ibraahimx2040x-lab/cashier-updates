-- v4, phase 17: which sections may notify and at what time.
alter table public.profiles add column notification_settings jsonb not null default '{}'::jsonb;
