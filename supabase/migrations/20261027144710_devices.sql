-- Spec v3, phase 10: what the phone's health store (Health Connect on
-- Android, HealthKit on iPhone) adds besides steps: sleep, resting heart
-- rate and workouts. Each row keeps its source; the app shows one source
-- per day for sleep and heart rate (the user's pick, else Health Connect /
-- HealthKit before manual), never a sum.

-- Nothing timed in the future (a few minutes of clock drift allowed). The
-- column to check is the trigger argument.
create or replace function public.reject_future_at() returns trigger
language plpgsql set search_path = '' as $$
begin
  if (to_jsonb(new) ->> tg_argv[0])::timestamptz > now() + interval '10 minutes' then
    raise exception '% is in the future', tg_argv[0] using errcode = 'check_violation';
  end if;
  return new;
end $$;

create table public.sleep_sessions (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  source text not null check (source in ('healthConnect', 'healthKit', 'phone', 'manual')),
  start_at timestamptz not null,
  end_at timestamptz not null,
  quality smallint check (quality between 1 and 5),
  updated_at timestamptz not null default now(),
  check (end_at > start_at and end_at - start_at <= interval '24 hours')
);
create index sleep_sessions_user_end on public.sleep_sessions (user_id, end_at);
create trigger sleep_sessions_not_future before insert or update on public.sleep_sessions
  for each row execute function public.reject_future_at('end_at');

-- Body measurements (spec 4.5). Resting heart rate is imported now; the
-- other kinds get their screen in phase 12. Bounds per kind; blood pressure
-- alone has a second value (diastolic).
create table public.body_metrics (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  kind text not null check (kind in ('weight', 'waist', 'resting_hr', 'bp', 'body_fat')),
  value numeric(5, 1) not null,
  value2 numeric(5, 1),
  source text not null check (source in ('healthConnect', 'healthKit', 'phone', 'manual')),
  measured_at timestamptz not null,
  note text not null default '' check (char_length(note) <= 500),
  check (case kind
    when 'weight' then value between 20 and 400
    when 'waist' then value between 30 and 250
    when 'resting_hr' then value between 25 and 220
    when 'bp' then value between 60 and 260 and value2 between 30 and 160
    when 'body_fat' then value between 2 and 75
  end),
  check ((kind = 'bp') = (value2 is not null))
);
create index body_metrics_user_kind on public.body_metrics (user_id, kind, measured_at);
create trigger body_metrics_not_future before insert or update on public.body_metrics
  for each row execute function public.reject_future_at('measured_at');

-- Workouts a watch or another app recorded, read from the health store.
-- Kept apart from workout_sessions, which follow the app's plans.
create table public.device_workouts (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  source text not null check (source in ('healthConnect', 'healthKit', 'phone', 'manual')),
  activity text not null check (activity ~ '^[A-Z0-9_]{1,40}$'),
  start_at timestamptz not null,
  end_at timestamptz not null,
  kcal integer check (kcal between 0 and 10000),
  distance_m integer check (distance_m between 0 and 1000000),
  steps integer check (steps between 0 and 200000),
  updated_at timestamptz not null default now(),
  check (end_at > start_at and end_at - start_at <= interval '24 hours')
);
create index device_workouts_user_start on public.device_workouts (user_id, start_at);
create trigger device_workouts_not_future before insert or update on public.device_workouts
  for each row execute function public.reject_future_at('end_at');

do $$
declare t text;
begin
  foreach t in array array['sleep_sessions', 'body_metrics', 'device_workouts'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('alter table public.%I force row level security', t);
    execute format('create policy owner_all on public.%I for all to authenticated
      using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
  end loop;
end $$;
