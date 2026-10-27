-- Spec v3, phase 08: food and water, entered by the user (built-in list,
-- their own foods, product barcodes, or an on-device photo suggestion they
-- confirm). Every number is an estimate the user can change.

-- No future days, in the user's own time zone (shared by the tables below).
create or replace function public.reject_future_day() returns trigger
language plpgsql set search_path = '' as $$
declare tz text;
begin
  select p.time_zone into tz from public.profiles p where p.user_id = new.user_id;
  if new.day > (now() at time zone coalesce(tz, 'UTC'))::date then
    raise exception 'day is in the future' using errcode = 'check_violation';
  end if;
  return new;
end $$;

-- Foods the user saved; a barcode is kept once per account.
create table public.custom_foods (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 120),
  portion text not null default '' check (char_length(portion) <= 60),
  grams numeric(7, 1) check (grams > 0 and grams <= 5000),
  kcal numeric(7, 1) not null check (kcal between 0 and 5000),
  protein numeric(6, 1) not null check (protein between 0 and 500),
  carbs numeric(6, 1) not null check (carbs between 0 and 500),
  fat numeric(6, 1) not null check (fat between 0 and 500),
  barcode text check (barcode ~ '^[0-9]{6,14}$'),
  created_at timestamptz not null default now(),
  unique (user_id, barcode)
);

-- Each thing eaten, with its name and numbers copied in when logged.
create table public.food_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  day date not null,
  meal text not null check (meal in ('breakfast', 'lunch', 'dinner', 'snack')),
  name text not null check (char_length(btrim(name)) between 1 and 120),
  food_ref text check (char_length(food_ref) <= 64),
  portions numeric(5, 2) not null check (portions > 0 and portions <= 20),
  kcal numeric(8, 1) not null check (kcal between 0 and 100000),
  protein numeric(7, 1) not null check (protein between 0 and 10000),
  carbs numeric(7, 1) not null check (carbs between 0 and 10000),
  fat numeric(7, 1) not null check (fat between 0 and 10000),
  logged_at timestamptz not null default now()
);
create index food_logs_user_day on public.food_logs (user_id, day);

create table public.water_intake (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  day date not null,
  ml integer not null check (ml between 0 and 10000),
  unique (user_id, day)
);

create trigger food_logs_not_future before insert or update on public.food_logs
  for each row execute function public.reject_future_day();
create trigger water_intake_not_future before insert or update on public.water_intake
  for each row execute function public.reject_future_day();

do $$
declare t text;
begin
  foreach t in array array['custom_foods', 'food_logs', 'water_intake'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('alter table public.%I force row level security', t);
    execute format(
      'create policy owner_all on public.%I for all to authenticated
         using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
  end loop;
end $$;
