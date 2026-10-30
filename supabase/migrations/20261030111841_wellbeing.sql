-- Spec v3, phase 12: sleep and recovery. Sleep sessions and body
-- measurements already exist (phase 10); this adds the daily check-in of
-- energy, fatigue, recovery and mood (1–5 each, all optional).
create table public.wellbeing_checkins (
  id uuid primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  day date not null,
  energy smallint check (energy between 1 and 5),
  fatigue smallint check (fatigue between 1 and 5),
  recovery smallint check (recovery between 1 and 5),
  mood smallint check (mood between 1 and 5),
  updated_at timestamptz not null default now(),
  unique (user_id, day)
);
create trigger wellbeing_checkins_not_future before insert or update on public.wellbeing_checkins
  for each row execute function public.reject_future_day();

alter table public.wellbeing_checkins enable row level security;
alter table public.wellbeing_checkins force row level security;
create policy owner_all on public.wellbeing_checkins for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
grant select, insert, update, delete on public.wellbeing_checkins to authenticated;
