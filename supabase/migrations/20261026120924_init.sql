-- Hayati — initial schema (design doc §13–15).
--
-- Every table holding personal data has a user_id defaulting to auth.uid()
-- and Row Level Security restricting all four operations to the owner.
-- Cross-table links use composite foreign keys on (id, user_id) so a row can
-- never reference another user's goal, milestone, habit, task or event.

create extension if not exists pgcrypto;

-- ------------------------------------------------------------------ helpers

create or replace function public.touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- ----------------------------------------------------------------- profiles

create table public.profiles (
  user_id uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  display_name text not null default '' check (char_length(display_name) <= 40),
  show_name_in_greeting boolean not null default true,
  locale text not null default 'ar' check (locale in ('ar', 'en')),
  time_zone text not null default 'Asia/Riyadh',
  theme_mode text not null default 'system' check (theme_mode in ('system', 'light', 'dark')),
  currency char(3) not null default 'SAR',
  week_start smallint not null default 7 check (week_start between 1 and 7),
  use_24h boolean not null default false,
  day_start smallint not null default 420 check (day_start between 0 and 1439),
  day_end smallint not null default 1380 check (day_end between 1 and 1440),
  work_start smallint check (work_start between 0 and 1439),
  work_end smallint check (work_end between 1 and 1440),
  work_days smallint[] not null default '{7,1,2,3,4}',
  breaks jsonb not null default '[]',
  modules text[] not null default '{time,learning,habits,expenses,notes}',
  onboarding_done boolean not null default false,
  home_sections jsonb not null default '{"events": true, "habits": true, "goals": true}',
  -- Each grant is separate and revocable (screen 20). Deletes and bulk
  -- changes always require approval and are not stored as grants.
  assistant_permissions jsonb not null default '{
    "enabled": true, "autoCreateTasks": false, "autoAddNotes": false,
    "autoLogHabits": false, "autoDraftPlans": true, "approveReschedule": true,
    "shareTasks": true, "shareEvents": true, "shareGoals": true,
    "shareHabits": true, "shareNotes": false, "shareExpenses": false
  }',
  chat_retention_days integer not null default 90 check (chat_retention_days >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (day_end > day_start),
  check ((work_start is null) = (work_end is null) and (work_end is null or work_end > work_start))
);

-- --------------------------------------------------------------- categories

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  domain text not null check (domain in ('goal', 'expense', 'note')),
  name text not null check (char_length(name) between 1 and 40),
  unique (user_id, domain, name)
);

-- -------------------------------------------------------------------- goals

create table public.goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null check (char_length(btrim(title)) between 1 and 200),
  description text not null default '',
  category text not null default 'personal'
    check (category in ('learning', 'health', 'work', 'money', 'personal')),
  start_date date,
  target_date date,
  why text not null default '',
  -- One measurement method per goal; never mixed (design doc §11).
  progress_mode text not null default 'milestones' check (progress_mode in ('milestones', 'manual')),
  manual_progress smallint not null default 0 check (manual_progress between 0 and 100),
  status text not null default 'active' check (status in ('active', 'paused', 'completed', 'archived')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, user_id),
  check (target_date is null or start_date is null or target_date >= start_date)
);
create index goals_user_status on public.goals (user_id, status);

create table public.goal_milestones (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid(),
  goal_id uuid not null,
  title text not null check (char_length(btrim(title)) between 1 and 200),
  done boolean not null default false,
  position smallint not null default 0,
  unique (id, user_id),
  unique (id, goal_id),
  foreign key (goal_id, user_id) references public.goals (id, user_id) on delete cascade
);
create index goal_milestones_goal on public.goal_milestones (goal_id, position);

-- -------------------------------------------------------------------- tasks

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null check (char_length(btrim(title)) between 1 and 200),
  description text not null default '',
  due_date date,
  due_time time,
  estimated_minutes smallint check (estimated_minutes between 1 and 1440),
  priority text not null default 'medium' check (priority in ('low', 'medium', 'high')),
  status text not null default 'todo' check (status in ('todo', 'in_progress', 'done', 'cancelled')),
  -- At most one goal per task (design doc §14).
  goal_id uuid,
  milestone_id uuid,
  planned_start timestamptz,
  completed_at timestamptz,
  archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, user_id),
  check (due_time is null or due_date is not null),
  check (milestone_id is null or goal_id is not null),
  check ((status = 'done') = (completed_at is not null)),
  foreign key (goal_id, user_id) references public.goals (id, user_id) on delete set null (goal_id),
  foreign key (milestone_id, goal_id) references public.goal_milestones (id, goal_id) on delete set null (milestone_id)
);
create index tasks_user_due on public.tasks (user_id, due_date) where not archived;
create index tasks_user_planned on public.tasks (user_id, planned_start) where planned_start is not null;
create index tasks_goal on public.tasks (goal_id) where goal_id is not null;

-- Completing the last open task of a milestone completes the milestone.
create or replace function public.complete_milestone_from_tasks() returns trigger
language plpgsql as $$
begin
  if new.status = 'done' and new.milestone_id is not null
     and not exists (
       select 1 from public.tasks t
       where t.milestone_id = new.milestone_id and t.status not in ('done', 'cancelled')
     ) then
    update public.goal_milestones set done = true where id = new.milestone_id;
  end if;
  return new;
end $$;

-- ------------------------------------------------------------------- events

create table public.events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null check (char_length(btrim(title)) between 1 and 200),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  location text not null default '',
  notes text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, user_id),
  -- Overlaps are allowed (and flagged in the UI); inverted ranges are not.
  check (ends_at > starts_at)
);
create index events_user_range on public.events (user_id, starts_at, ends_at);

-- ------------------------------------------------------------------- habits

create table public.habits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name text not null check (char_length(btrim(name)) between 1 and 100),
  description text not null default '',
  weekdays smallint[] not null check (cardinality(weekdays) between 1 and 7 and weekdays <@ '{1,2,3,4,5,6,7}'),
  start_date date not null default current_date,
  reminder_time time,
  active boolean not null default true,
  unique (id, user_id)
);

-- One completion per habit per day. Days a habit isn't due are simply
-- absent and never count as failures.
create table public.habit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid(),
  habit_id uuid not null,
  day date not null,
  unique (habit_id, day),
  foreign key (habit_id, user_id) references public.habits (id, user_id) on delete cascade
);

create or replace function public.reject_future_habit_log() returns trigger
language plpgsql as $$
declare tz text;
begin
  select time_zone into tz from public.profiles where user_id = new.user_id;
  if new.day > (now() at time zone coalesce(tz, 'UTC'))::date then
    raise exception 'habit log in the future' using errcode = 'check_violation';
  end if;
  return new;
end $$;

-- -------------------------------------------------------------------- notes

create table public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null default '',
  body text not null default '',
  category text not null default '',
  pinned boolean not null default false,
  archived boolean not null default false,
  goal_id uuid,
  task_id uuid,
  updated_at timestamptz not null default now(),
  check (char_length(btrim(title)) > 0 or char_length(btrim(body)) > 0),
  foreign key (goal_id, user_id) references public.goals (id, user_id) on delete set null (goal_id),
  foreign key (task_id, user_id) references public.tasks (id, user_id) on delete set null (task_id)
);
create index notes_search on public.notes using gin (to_tsvector('simple', title || ' ' || body));

-- ------------------------------------------------------- expenses & budgets

-- Minor units (halalas/cents) avoid float error. Each record keeps its own
-- currency; totals are always grouped by currency.
create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  amount_minor bigint not null check (amount_minor > 0),
  currency char(3) not null check (currency ~ '^[A-Z]{3}$'),
  category text not null,
  spent_at timestamptz not null default now(),
  description text not null default ''
);
create index expenses_user_time on public.expenses (user_id, spent_at);

create table public.budgets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  period text not null default 'monthly' check (period in ('monthly')),
  currency char(3) not null check (currency ~ '^[A-Z]{3}$'),
  category text,
  limit_minor bigint not null check (limit_minor > 0)
);
-- One budget per currency+category (null category = all categories).
create unique index budgets_unique on public.budgets (user_id, currency, coalesce(category, ''));

-- ---------------------------------------------- reminders & notifications

create table public.reminders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid(),
  task_id uuid,
  event_id uuid,
  remind_at timestamptz not null,
  delivered_at timestamptz,
  cancelled boolean not null default false,
  check (num_nonnulls(task_id, event_id) = 1),
  foreign key (task_id, user_id) references public.tasks (id, user_id) on delete cascade,
  foreign key (event_id, user_id) references public.events (id, user_id) on delete cascade,
  -- The same reminder is never delivered twice.
  unique nulls not distinct (task_id, event_id, remind_at)
);
create index reminders_due on public.reminders (remind_at) where delivered_at is null and not cancelled;

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  type text not null check (type in ('task', 'event', 'habit', 'plan', 'assistant', 'billing')),
  title text not null,
  body text not null default '',
  ref_id uuid,
  read_at timestamptz,
  dedupe_key text not null,
  created_at timestamptz not null default now(),
  unique (user_id, dedupe_key)
);

-- ---------------------------------------------------------------- assistant

create table public.assistant_conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null default '',
  updated_at timestamptz not null default now(),
  unique (id, user_id)
);

create table public.assistant_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid(),
  conversation_id uuid not null,
  role text not null check (role in ('user', 'assistant')),
  kind text not null default 'text' check (kind in ('text', 'plan', 'proposal', 'error', 'info')),
  content text not null,
  action_id uuid,
  created_at timestamptz not null default now(),
  foreign key (conversation_id, user_id) references public.assistant_conversations (id, user_id) on delete cascade
);
create index assistant_messages_conv on public.assistant_messages (conversation_id, created_at);

-- A proposed batch of tool calls and its outcome (screen 14). Doubles as the
-- audit log: who approved what, when, and the result. Holds no chat text.
create table public.assistant_actions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  conversation_id uuid,
  reason text not null default '',
  calls jsonb not null check (jsonb_typeof(calls) = 'array' and jsonb_array_length(calls) between 1 and 60),
  -- record id -> updated_at when the preview was built
  snapshot jsonb not null default '{}',
  warnings jsonb not null default '[]',
  status text not null default 'pending'
    check (status in ('pending', 'executed', 'rejected', 'failed', 'stale')),
  auto boolean not null default false,
  idempotency_key uuid not null default gen_random_uuid(),
  result jsonb,
  created_at timestamptz not null default now(),
  decided_at timestamptz,
  unique (user_id, idempotency_key),
  foreign key (conversation_id, user_id) references public.assistant_conversations (id, user_id) on delete set null (conversation_id)
);

-- Server-side daily allowance; the client never decides its own limit.
create table public.assistant_usage (
  user_id uuid not null references auth.users (id) on delete cascade,
  day date not null,
  requests integer not null default 0,
  input_tokens bigint not null default 0,
  output_tokens bigint not null default 0,
  primary key (user_id, day)
);

-- ------------------------------------------------------------- subscriptions

-- Written only by the billing webhook (service role) after the store has
-- verified the purchase. Clients can read their row, never write it.
create table public.subscriptions (
  user_id uuid primary key references auth.users (id) on delete cascade,
  plan text not null default 'free' check (plan in ('free', 'pro')),
  status text not null default 'active' check (status in ('active', 'grace', 'expired', 'cancelled')),
  store text check (store in ('app_store', 'play_store', 'web')),
  current_period_end timestamptz,
  updated_at timestamptz not null default now()
);

create table public.support_reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  kind text not null check (kind in ('bug', 'notifications', 'assistant', 'other')),
  description text not null check (char_length(btrim(description)) > 0),
  steps text not null default '',
  tech_info text,
  created_at timestamptz not null default now()
);

-- Account deletion requests (screen 21). Processed by a server job that
-- removes auth.users (cascading to all tables above) per the retention policy.
create table public.account_deletion_requests (
  user_id uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  requested_at timestamptz not null default now()
);

-- ----------------------------------------------------------------- triggers

create trigger profiles_touch before update on public.profiles for each row execute function public.touch_updated_at();
create trigger goals_touch before update on public.goals for each row execute function public.touch_updated_at();
create trigger tasks_touch before update on public.tasks for each row execute function public.touch_updated_at();
create trigger events_touch before update on public.events for each row execute function public.touch_updated_at();
create trigger notes_touch before update on public.notes for each row execute function public.touch_updated_at();
create trigger tasks_milestone after insert or update of status on public.tasks
  for each row execute function public.complete_milestone_from_tasks();
create trigger habit_logs_no_future before insert or update on public.habit_logs
  for each row execute function public.reject_future_habit_log();

-- New users get a profile and a free subscription row.
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (user_id) values (new.id);
  insert into public.subscriptions (user_id) values (new.id);
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- --------------------------------------------------------------------- RLS

do $$
declare t text;
begin
  -- Owner-only CRUD.
  foreach t in array array[
    'profiles', 'categories', 'goals', 'goal_milestones', 'tasks', 'events', 'habits',
    'habit_logs', 'notes', 'expenses', 'budgets', 'reminders', 'notifications',
    'assistant_conversations', 'assistant_messages', 'assistant_actions'
  ] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('alter table public.%I force row level security', t);
    execute format(
      'create policy owner_all on public.%I for all to authenticated
         using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
  end loop;

  -- Read-only to the owner; written by the server.
  foreach t in array array['assistant_usage', 'subscriptions'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('alter table public.%I force row level security', t);
    execute format(
      'create policy owner_read on public.%I for select to authenticated using (user_id = (select auth.uid()))', t);
    execute format('grant select on public.%I to authenticated', t);
  end loop;

  -- Insert-only to the owner.
  foreach t in array array['support_reports', 'account_deletion_requests'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('alter table public.%I force row level security', t);
    execute format(
      'create policy owner_insert on public.%I for insert to authenticated with check (user_id = (select auth.uid()))', t);
    execute format(
      'create policy owner_read on public.%I for select to authenticated using (user_id = (select auth.uid()))', t);
    execute format('grant select, insert on public.%I to authenticated', t);
  end loop;
end $$;

-- A user may not edit an action's outcome directly; only the executor
-- function below changes status. (Column privileges, on top of RLS.)
revoke update on public.assistant_actions from authenticated;
grant update (conversation_id) on public.assistant_actions to authenticated;

-- ---------------------------------------------------- assistant functions

-- Counts one assistant request against today's allowance. Returns false when
-- the allowance is used up. Runs as definer because clients can't write
-- assistant_usage; it only ever touches the caller's own row.
create or replace function public.consume_assistant_request(p_daily_limit integer)
returns boolean
language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  n integer;
begin
  if uid is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  insert into public.assistant_usage as u (user_id, day, requests)
  values (uid, current_date, 1)
  on conflict (user_id, day) do update set requests = u.requests + 1
    where u.requests < p_daily_limit
  returning requests into n;
  return n is not null;
end $$;
revoke all on function public.consume_assistant_request(integer) from public;
grant execute on function public.consume_assistant_request(integer) to authenticated;

-- Token accounting for cost monitoring (design doc §22). Own row only.
create or replace function public.record_assistant_tokens(p_input bigint, p_output bigint)
returns void
language sql security definer set search_path = '' as $$
  update public.assistant_usage
     set input_tokens = input_tokens + greatest(p_input, 0), output_tokens = output_tokens + greatest(p_output, 0)
   where user_id = auth.uid() and day = current_date;
$$;
revoke all on function public.record_assistant_tokens(bigint, bigint) from public;
grant execute on function public.record_assistant_tokens(bigint, bigint) to authenticated;

-- The only way an action's status changes. Definer, because clients have no
-- UPDATE privilege on status; it only moves the caller's own *pending* row to
-- a final state, so an executed action can never be reopened and replayed.
create or replace function public.finish_assistant_action(p_action_id uuid, p_status text, p_result jsonb)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  if p_status not in ('executed', 'rejected', 'failed', 'stale') then
    raise exception 'invalid status %', p_status;
  end if;
  update public.assistant_actions
     set status = p_status, decided_at = now(), result = p_result
   where id = p_action_id and user_id = auth.uid() and status = 'pending';
end $$;
revoke all on function public.finish_assistant_action(uuid, text, jsonb) from public;
grant execute on function public.finish_assistant_action(uuid, text, jsonb) to authenticated;

-- Applies an approved proposal atomically and at most once.
--
-- SECURITY INVOKER: every data change below runs under the caller's RLS, so
-- a call naming another user's record matches zero rows and the whole
-- proposal fails. The function runs in one transaction: any error rolls
-- back every call.
create or replace function public.apply_assistant_action(p_action_id uuid)
returns jsonb
language plpgsql security invoker set search_path = '' as $$
declare
  a public.assistant_actions;
  c jsonb;
  args jsonb;
  k text;
  v text;
  n integer;
  goal_id uuid;
  ms_ids uuid[];
  t jsonb;
  applied integer := 0;
begin
  -- Serialise concurrent approvals of the same action (double taps).
  perform pg_advisory_xact_lock(hashtext(p_action_id::text));
  select * into a from public.assistant_actions
   where id = p_action_id and user_id = auth.uid();
  if not found then
    return jsonb_build_object('outcome', 'not_found');
  end if;
  if a.status = 'executed' then
    return jsonb_build_object('outcome', 'already_executed', 'result', a.result);
  end if;
  if a.status <> 'pending' then
    return jsonb_build_object('outcome', 'not_pending', 'status', a.status);
  end if;

  -- Staleness: the records the preview was built from must be unchanged.
  for k, v in select * from jsonb_each_text(a.snapshot) loop
    if not exists (select 1 from public.tasks where id = k::uuid and updated_at = v::timestamptz)
       and not exists (select 1 from public.goals where id = k::uuid and updated_at = v::timestamptz) then
      perform public.finish_assistant_action(a.id, 'stale', null);
      return jsonb_build_object('outcome', 'stale');
    end if;
  end loop;

  begin
    for c in select * from jsonb_array_elements(a.calls) loop
      args := c -> 'args';
      case c ->> 'tool'
        when 'create_task' then
          insert into public.tasks (title, due_date, due_time, estimated_minutes, priority, goal_id)
          values (args ->> 'title', (args ->> 'dueDate')::date,
                  make_time(((args ->> 'dueTime')::int) / 60, ((args ->> 'dueTime')::int) % 60, 0),
                  (args ->> 'estimatedMinutes')::smallint, coalesce(args ->> 'priority', 'medium'),
                  (args ->> 'goalId')::uuid);
        when 'add_note' then
          insert into public.notes (title, body)
          values (coalesce(args ->> 'title', left(args ->> 'body', 40)), args ->> 'body');
        when 'log_habit' then
          insert into public.habit_logs (habit_id, day)
          select h.id, (args ->> 'day')::date from public.habits h where h.id = (args ->> 'habitId')::uuid
          on conflict (habit_id, day) do nothing;
          if not exists (select 1 from public.habits where id = (args ->> 'habitId')::uuid) then
            raise exception 'habit not found';
          end if;
        when 'plan_task' then
          update public.tasks set planned_start = (args ->> 'plannedStart')::timestamptz
           where id = (args ->> 'taskId')::uuid;
          get diagnostics n = row_count;
          if n <> 1 then raise exception 'task not found'; end if;
        when 'move_task' then
          update public.tasks set due_date = (args ->> 'dueDate')::date
           where id = (args ->> 'taskId')::uuid;
          get diagnostics n = row_count;
          if n <> 1 then raise exception 'task not found'; end if;
        when 'delete_task' then
          delete from public.tasks where id = (args ->> 'taskId')::uuid;
          get diagnostics n = row_count;
          if n <> 1 then raise exception 'task not found'; end if;
        when 'add_milestones' then
          if not exists (select 1 from public.goals where id = (args ->> 'goalId')::uuid) then
            raise exception 'goal not found';
          end if;
          insert into public.goal_milestones (goal_id, title, position)
          select (args ->> 'goalId')::uuid, m.value,
                 (select coalesce(max(position), -1) from public.goal_milestones where goal_id = (args ->> 'goalId')::uuid) + m.ord
            from jsonb_array_elements_text(args -> 'titles') with ordinality as m(value, ord);
        when 'create_goal' then
          insert into public.goals (title, category, start_date, target_date, why)
          values (args ->> 'title', coalesce(args ->> 'category', 'learning'), current_date,
                  (args ->> 'targetDate')::date, coalesce(args ->> 'why', ''))
          returning id into goal_id;
          with ins as (
            insert into public.goal_milestones (goal_id, title, position)
            select goal_id, m.value, m.ord - 1
              from jsonb_array_elements_text(args -> 'milestones') with ordinality as m(value, ord)
            returning id, position
          )
          select array_agg(id order by position) into ms_ids from ins;
          for t in select * from jsonb_array_elements(coalesce(args -> 'tasks', '[]')) loop
            insert into public.tasks (title, due_date, estimated_minutes, goal_id, milestone_id)
            values (t ->> 'title', (t ->> 'dueDate')::date, (t ->> 'estimatedMinutes')::smallint, goal_id,
                    ms_ids[(t ->> 'milestone')::int + 1]);
          end loop;
        else
          raise exception 'unknown tool %', c ->> 'tool';
      end case;
      applied := applied + 1;
    end loop;
  exception when others then
    -- The inner block's changes are rolled back; record the failure.
    perform public.finish_assistant_action(a.id, 'failed', jsonb_build_object('error', sqlerrm));
    return jsonb_build_object('outcome', 'failed', 'error', sqlerrm);
  end;

  perform public.finish_assistant_action(a.id, 'executed', jsonb_build_object('applied', applied));
  return jsonb_build_object('outcome', 'executed', 'applied', applied);
end $$;
revoke all on function public.apply_assistant_action(uuid) from public;
grant execute on function public.apply_assistant_action(uuid) to authenticated;

create or replace function public.reject_assistant_action(p_action_id uuid)
returns void
language sql security invoker set search_path = '' as $$
  select public.finish_assistant_action(p_action_id, 'rejected', null);
$$;
revoke all on function public.reject_assistant_action(uuid) from public;
grant execute on function public.reject_assistant_action(uuid) to authenticated;
