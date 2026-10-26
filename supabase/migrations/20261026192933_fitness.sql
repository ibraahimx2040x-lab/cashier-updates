-- Fitness (design doc v2, section 3-d): the user's training profile,
-- versioned home/gym plans, and the sessions they logged.
--
-- The exercise library is fixed and ships with the app, so plans store
-- exercise ids with their sets/reps; a plan is never edited in place:
-- regenerating inserts a new version, and sessions keep pointing at the
-- version that was followed.

alter table public.profiles
  add column fitness_profile jsonb not null default '{}'::jsonb
    check (jsonb_typeof(fitness_profile) = 'object');

create table public.workout_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  place text not null check (place in ('home', 'gym')),
  version integer not null check (version > 0),
  active boolean not null default true,
  goal text not null check (goal in ('strength', 'muscle', 'fatLoss', 'general', 'mobility')),
  days jsonb not null check (jsonb_typeof(days) = 'array' and jsonb_array_length(days) between 1 and 7),
  created_at timestamptz not null default now(),
  unique (id, user_id),
  unique (user_id, place, version)
);
-- At most one active plan per place.
create unique index workout_plans_one_active on public.workout_plans (user_id, place) where active;

create table public.workout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  plan_id uuid,
  day date not null,
  place text not null check (place in ('home', 'gym')),
  focus text not null check (focus in ('fullBody', 'upper', 'lower', 'conditioning', 'mobility')),
  status text not null check (status in ('completed', 'partial')),
  difficulty smallint check (difficulty between 1 and 5),
  note text not null default '' check (char_length(note) <= 2000),
  -- Only the sets the user entered: [{exerciseId, setIndex, reps?, seconds?, weightKg?}].
  sets jsonb not null default '[]'::jsonb check (jsonb_typeof(sets) = 'array' and jsonb_array_length(sets) <= 200),
  substituted boolean not null default false,
  created_at timestamptz not null default now(),
  foreign key (plan_id, user_id) references public.workout_plans (id, user_id) on delete set null (plan_id)
);
create index workout_sessions_user_day on public.workout_sessions (user_id, day);

-- Sessions are logged after the fact: never for a future day.
create or replace function public.reject_future_workout() returns trigger
language plpgsql set search_path = '' as $$
declare tz text;
begin
  select time_zone into tz from public.profiles where user_id = new.user_id;
  if new.day > (now() at time zone coalesce(tz, 'UTC'))::date then
    raise exception 'workout logged for a future day' using errcode = '23514';
  end if;
  return new;
end $$;

create trigger workout_sessions_no_future before insert or update on public.workout_sessions
  for each row execute function public.reject_future_workout();

do $$
declare t text;
begin
  foreach t in array array['workout_plans', 'workout_sessions'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('alter table public.%I force row level security', t);
    execute format(
      'create policy owner_all on public.%I for all to authenticated
         using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
  end loop;
end $$;
