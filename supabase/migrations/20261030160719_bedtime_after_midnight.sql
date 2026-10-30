-- v4, phase 15: a bedtime after midnight is stored past 24:00 (e.g. 1500 =
-- 1 am), so the waking day can run into the next one. Still at most 24 hours.
alter table public.profiles drop constraint profiles_day_end_check;
alter table public.profiles add constraint profiles_day_end_check check (day_end between 1 and 2879);
alter table public.profiles drop constraint profiles_check;
alter table public.profiles add constraint profiles_check check (day_end > day_start and day_end - day_start <= 1440);
