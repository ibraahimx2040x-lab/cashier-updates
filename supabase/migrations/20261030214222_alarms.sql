-- v4, phase 17: sounding alarms, separate from quiet notifications. A
-- repeating alarm has weekdays (1 = Monday … 7 = Sunday); a one-time alarm
-- has on_date instead.
create table public.alarms (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  label text not null default '' check (char_length(label) <= 80),
  minutes smallint not null check (minutes between 0 and 1439),
  weekdays smallint[] not null default '{}' check (weekdays <@ array[1,2,3,4,5,6,7]::smallint[]),
  on_date date,
  tone text not null default 'dawn' check (tone in ('dawn', 'chime', 'bells', 'pulse')),
  vibrate boolean not null default true,
  snooze_minutes smallint not null default 10 check (snooze_minutes between 1 and 60),
  enabled boolean not null default true,
  task_id uuid,
  event_id uuid,
  snoozed_until timestamptz,
  updated_at timestamptz not null default now(),
  check (cardinality(weekdays) > 0 or on_date is not null),
  foreign key (task_id, user_id) references public.tasks (id, user_id) on delete set null (task_id),
  foreign key (event_id, user_id) references public.events (id, user_id) on delete set null (event_id)
);
create index alarms_user on public.alarms (user_id);

alter table public.alarms enable row level security;
alter table public.alarms force row level security;
create policy owner_all on public.alarms for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
grant select, insert, update, delete on public.alarms to authenticated;
