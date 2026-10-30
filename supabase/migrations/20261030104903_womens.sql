-- Spec v3, phase 11: women's health and health appointments. Cycle data is
-- the most sensitive the app holds: owner-only like every table, never
-- shared with the assistant, and the user can keep it on the device only
-- (then the app sends none of it here and removes what was here).

-- One row per recorded period. end_date is null while it is going on.
create table public.cycle_periods (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  start_date date not null,
  end_date date,
  updated_at timestamptz not null default now(),
  check (end_date is null or (end_date >= start_date and end_date - start_date < 15))
);
create index cycle_periods_user_start on public.cycle_periods (user_id, start_date);

-- No future start, and no two periods of one user overlapping (an open one
-- counts as its first 15 days).
create or replace function public.check_cycle_period() returns trigger
language plpgsql set search_path = '' as $$
declare tz text;
begin
  select p.time_zone into tz from public.profiles p where p.user_id = new.user_id;
  if greatest(new.start_date, coalesce(new.end_date, new.start_date)) > (now() at time zone coalesce(tz, 'UTC'))::date then
    raise exception 'period is in the future' using errcode = 'check_violation';
  end if;
  if exists (
    select 1 from public.cycle_periods c
    where c.user_id = new.user_id and c.id <> new.id
      and daterange(c.start_date, coalesce(c.end_date, c.start_date + 14), '[]')
          && daterange(new.start_date, coalesce(new.end_date, new.start_date + 14), '[]')
  ) then
    raise exception 'periods overlap' using errcode = 'exclusion_violation';
  end if;
  return new;
end $$;
create trigger cycle_periods_check before insert or update on public.cycle_periods
  for each row execute function public.check_cycle_period();

-- How a day went: one row per day.
create table public.cycle_day_logs (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  day date not null,
  flow text check (flow in ('none', 'light', 'medium', 'heavy')),
  pain smallint check (pain between 0 and 10),
  symptoms text[] not null default '{}' check (symptoms <@ array[
    'cramps', 'headache', 'back_pain', 'bloating', 'breast_tenderness', 'acne',
    'fatigue', 'nausea', 'cravings', 'insomnia', 'mood_swings', 'spotting']::text[]),
  other_symptoms text not null default '' check (char_length(other_symptoms) <= 200),
  mood text check (mood in ('calm', 'happy', 'low', 'irritable', 'anxious')),
  energy smallint check (energy between 1 and 5),
  note text not null default '' check (char_length(note) <= 1000),
  updated_at timestamptz not null default now(),
  unique (user_id, day)
);
create trigger cycle_day_logs_not_future before insert or update on public.cycle_day_logs
  for each row execute function public.reject_future_day();

-- Health appointments and tests (screen 46), for women and men.
create table public.health_appointments (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null check (char_length(btrim(title)) between 1 and 120),
  kind text not null default 'checkup' check (kind in ('checkup', 'test', 'followup', 'other')),
  at timestamptz not null,
  place text not null default '' check (char_length(place) <= 120),
  notes text not null default '' check (char_length(notes) <= 2000),
  questions text[] not null default '{}' check (cardinality(questions) <= 30),
  reminder_minutes integer check (reminder_minutes between 0 and 10080),
  updated_at timestamptz not null default now()
);
create index health_appointments_user_at on public.health_appointments (user_id, at);

do $$
declare t text;
begin
  foreach t in array array['cycle_periods', 'cycle_day_logs', 'health_appointments'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('alter table public.%I force row level security', t);
    execute format('create policy owner_all on public.%I for all to authenticated
      using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
  end loop;
end $$;
