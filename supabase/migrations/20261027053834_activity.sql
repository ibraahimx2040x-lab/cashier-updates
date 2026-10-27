-- Spec v3, phase 07: sex chosen at sign-up, health settings, and daily
-- activity (steps) per source.

-- Sex is chosen at sign-up (stored as account metadata, copied here by the
-- trigger). Null only for accounts made before it was asked.
alter table public.profiles
  add column sex text check (sex in ('male', 'female')),
  add column health_settings jsonb not null default '{}'::jsonb
    check (jsonb_typeof(health_settings) = 'object');

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
declare s text := new.raw_user_meta_data ->> 'sex';
begin
  if s in ('male', 'female') then
    -- The matching health section is on from the start (as the app's setSex).
    insert into public.profiles (user_id, sex, health_settings)
      values (new.id, s, jsonb_build_object('modules', jsonb_build_array(
        'activity', 'nutrition', 'sleep', case s when 'female' then 'womens' else 'mens' end)));
  else
    insert into public.profiles (user_id) values (new.id);
  end if;
  insert into public.subscriptions (user_id) values (new.id);
  return new;
end $$;
revoke execute on function public.handle_new_user() from public, anon, authenticated;

-- One row per day and source. The app shows one source per day (never a
-- sum), so a phone and a watch counting the same walk don't double it.
create table public.daily_activity (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  day date not null,
  source text not null check (source in ('healthConnect', 'healthKit', 'phone', 'manual')),
  steps integer not null check (steps between 0 and 150000),
  distance_m integer check (distance_m between 0 and 500000),
  active_minutes smallint check (active_minutes between 0 and 1440),
  updated_at timestamptz not null default now(),
  unique (user_id, day, source)
);

-- No future days, in the user's own time zone.
create or replace function public.reject_future_activity() returns trigger
language plpgsql set search_path = '' as $$
declare tz text;
begin
  select coalesce(p.time_zone, 'UTC') into tz from public.profiles p where p.user_id = new.user_id;
  if new.day > (now() at time zone coalesce(tz, 'UTC'))::date then
    raise exception 'activity day is in the future' using errcode = 'check_violation';
  end if;
  return new;
end $$;
create trigger daily_activity_not_future before insert or update on public.daily_activity
  for each row execute function public.reject_future_activity();

alter table public.daily_activity enable row level security;
alter table public.daily_activity force row level security;
create policy owner_all on public.daily_activity for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
grant select, insert, update, delete on public.daily_activity to authenticated;
