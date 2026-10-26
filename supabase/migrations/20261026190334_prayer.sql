-- Prayer times (design doc v2, section 3-c): per-user calculation
-- settings and an optional log of prayers the user chose to record.

alter table public.profiles
  add column prayer_settings jsonb not null default '{}'::jsonb
    check (jsonb_typeof(prayer_settings) = 'object');

create table public.prayer_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  day date not null,
  prayer text not null check (prayer in ('fajr', 'dhuhr', 'asr', 'maghrib', 'isha')),
  logged_at timestamptz not null default now(),
  -- Recording the same prayer twice on one day is a no-op, not a duplicate.
  unique (user_id, day, prayer)
);

create index prayer_logs_user_day on public.prayer_logs (user_id, day);

-- Same rule as habit logs: nothing is recorded for a future day.
create or replace function public.reject_future_prayer_log() returns trigger
language plpgsql set search_path = '' as $$
declare tz text;
begin
  select time_zone into tz from public.profiles where user_id = new.user_id;
  if new.day > (now() at time zone coalesce(tz, 'UTC'))::date then
    raise exception 'prayer log for a future day' using errcode = '23514';
  end if;
  return new;
end $$;

create trigger prayer_logs_no_future before insert or update on public.prayer_logs
  for each row execute function public.reject_future_prayer_log();

alter table public.prayer_logs enable row level security;
alter table public.prayer_logs force row level security;
create policy owner_all on public.prayer_logs for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
grant select, insert, update, delete on public.prayer_logs to authenticated;
