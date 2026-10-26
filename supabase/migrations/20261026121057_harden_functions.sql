-- Security advisor fixes.
-- Pin search_path on trigger functions so they can't be redirected by a
-- caller's search_path (their table references are schema-qualified).
alter function public.touch_updated_at() set search_path = '';
alter function public.complete_milestone_from_tasks() set search_path = '';
alter function public.reject_future_habit_log() set search_path = '';

-- handle_new_user only runs as the auth.users trigger; nobody calls it.
revoke execute on function public.handle_new_user() from public, anon, authenticated;
