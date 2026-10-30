-- v4, phase 14: income and monthly items. The fixed salary is a history of
-- rates (each from a date on), so a raise never changes the months before
-- it; an amount of 0 stops the salary (variable income from then on).
create table public.salary_rates (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  amount_minor bigint not null check (amount_minor >= 0),
  currency char(3) not null check (currency ~ '^[A-Z]{3}$'),
  effective_from date not null,
  pay_day smallint not null default 1 check (pay_day between 1 and 31),
  note text not null default '' check (char_length(note) <= 200),
  updated_at timestamptz not null default now(),
  unique (user_id, effective_from)
);

-- Monthly expenses and income. Each month that falls due becomes an ordinary
-- expense or income row; generated_through ('yyyy-MM') is the last month made.
create table public.recurring_items (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  kind text not null check (kind in ('expense', 'income')),
  amount_minor bigint not null check (amount_minor > 0),
  currency char(3) not null check (currency ~ '^[A-Z]{3}$'),
  category text not null default 'other',
  title text not null default '' check (char_length(title) <= 120),
  day_of_month smallint not null default 1 check (day_of_month between 1 and 31),
  starts_on date not null,
  ends_on date check (ends_on is null or ends_on >= starts_on),
  generated_through text check (generated_through ~ '^\d{4}-\d{2}$'),
  active boolean not null default true,
  updated_at timestamptz not null default now(),
  unique (id, user_id)
);

create table public.incomes (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  amount_minor bigint not null check (amount_minor > 0),
  currency char(3) not null check (currency ~ '^[A-Z]{3}$'),
  kind text not null default 'extra' check (kind in ('pay', 'extra')),
  source text not null default '' check (char_length(source) <= 120),
  received_at timestamptz not null,
  recurring_id uuid,
  note text not null default '' check (char_length(note) <= 500),
  foreign key (recurring_id, user_id) references public.recurring_items (id, user_id) on delete set null (recurring_id)
);
create index incomes_user_time on public.incomes (user_id, received_at);

-- Received money can't be dated in the future (a day of slack for time zones).
create function public.reject_future_income() returns trigger
  language plpgsql set search_path = '' as $$
begin
  if new.received_at > now() + interval '1 day' then
    raise exception 'income in the future' using errcode = 'check_violation';
  end if;
  return new;
end $$;
create trigger incomes_not_future before insert or update on public.incomes
  for each row execute function public.reject_future_income();

alter table public.expenses add column recurring_id uuid,
  add foreign key (recurring_id, user_id) references public.recurring_items (id, user_id) on delete set null (recurring_id);
create index expenses_recurring on public.expenses (recurring_id, user_id) where recurring_id is not null;
create index incomes_recurring on public.incomes (recurring_id, user_id) where recurring_id is not null;

do $$
declare t text;
begin
  foreach t in array array['salary_rates', 'recurring_items', 'incomes'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('alter table public.%I force row level security', t);
    execute format('create policy owner_all on public.%I for all to authenticated
      using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
  end loop;
end $$;
