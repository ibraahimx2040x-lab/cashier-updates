-- RLS and assistant-executor tests. Fails loudly (ON_ERROR_STOP) on any
-- broken expectation.
\set ON_ERROR_STOP on
\set QUIET on
\pset tuples_only on
\o /dev/null

insert into auth.users values
  ('11111111-1111-1111-1111-111111111111', 'a@example.com'),
  ('22222222-2222-2222-2222-222222222222', 'b@example.com');

create function pg_temp.as_user(u uuid) returns void language sql as
  $$ select set_config('request.jwt.claim.sub', u::text, false) $$;
create function pg_temp.check(ok boolean, what text) returns void language plpgsql as
  $$ begin if not ok then raise exception 'FAILED: %', what; end if; raise notice 'ok: %', what; end $$;

set role authenticated;

-- ---------------------------------------------------------------- user A
select pg_temp.as_user('11111111-1111-1111-1111-111111111111');
select pg_temp.check((select count(*) = 1 from profiles), 'profile created by signup trigger');
insert into goals (id, title) values ('aaaaaaaa-0000-0000-0000-000000000001', 'Learn Flutter');
insert into goal_milestones (id, goal_id, title) values ('aaaaaaaa-0000-0000-0000-0000000000a1', 'aaaaaaaa-0000-0000-0000-000000000001', 'Dart');
insert into tasks (id, title, goal_id, milestone_id) values
  ('aaaaaaaa-0000-0000-0000-0000000000b1', 'A task', 'aaaaaaaa-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-0000000000a1');
insert into habits (id, name, weekdays) values ('aaaaaaaa-0000-0000-0000-0000000000c1', 'Walk', '{1,2,3,4,5,6,7}');

-- ---------------------------------------------------------------- user B
select pg_temp.as_user('22222222-2222-2222-2222-222222222222');
select pg_temp.check((select count(*) = 0 from tasks), 'B cannot read A''s tasks');
select pg_temp.check((select count(*) = 0 from goals), 'B cannot read A''s goals');
update tasks set title = 'hacked' where id = 'aaaaaaaa-0000-0000-0000-0000000000b1';
delete from tasks where id = 'aaaaaaaa-0000-0000-0000-0000000000b1';

do $$ begin
  insert into tasks (user_id, title) values ('11111111-1111-1111-1111-111111111111', 'spoof');
  raise exception 'FAILED: B inserted a row owned by A';
exception when insufficient_privilege then raise notice 'ok: B cannot insert rows for A (RLS)';
end $$;

do $$ begin
  insert into tasks (title, goal_id) values ('link', 'aaaaaaaa-0000-0000-0000-000000000001');
  raise exception 'FAILED: B linked a task to A''s goal';
exception when foreign_key_violation then raise notice 'ok: B cannot link a task to A''s goal';
end $$;

do $$ begin
  insert into subscriptions (user_id, plan) values ('22222222-2222-2222-2222-222222222222', 'pro')
    on conflict (user_id) do update set plan = 'pro';
  raise exception 'FAILED: client upgraded its own subscription';
exception when insufficient_privilege then raise notice 'ok: client cannot write its subscription';
end $$;

-- B's proposal targeting A's task fails as a whole and changes nothing.
insert into tasks (id, title) values ('bbbbbbbb-0000-0000-0000-0000000000b1', 'B task');
insert into assistant_actions (id, calls) values ('bbbbbbbb-0000-0000-0000-0000000000f1',
  '[{"tool":"create_task","args":{"title":"should roll back"}},
    {"tool":"delete_task","args":{"taskId":"aaaaaaaa-0000-0000-0000-0000000000b1"}}]');
select pg_temp.check(apply_assistant_action('bbbbbbbb-0000-0000-0000-0000000000f1') ->> 'outcome' = 'failed',
  'proposal touching another user''s task fails');
select pg_temp.check((select count(*) = 1 from tasks), 'failed proposal rolled back its other calls');

do $$ begin
  update assistant_actions set status = 'executed' where id = 'bbbbbbbb-0000-0000-0000-0000000000f1';
  raise exception 'FAILED: client edited action status directly';
exception when insufficient_privilege then raise notice 'ok: client cannot edit action status directly';
end $$;

-- ---------------------------------------------------------------- user A
select pg_temp.as_user('11111111-1111-1111-1111-111111111111');
select pg_temp.check((select title from tasks where id = 'aaaaaaaa-0000-0000-0000-0000000000b1') = 'A task',
  'B''s update/delete on A''s task had no effect');

-- Milestone completes when its last task is done.
update tasks set status = 'done', completed_at = now() where id = 'aaaaaaaa-0000-0000-0000-0000000000b1';
select pg_temp.check((select done from goal_milestones where id = 'aaaaaaaa-0000-0000-0000-0000000000a1'),
  'milestone auto-completes with its tasks');

-- Habit logs: unique per day, no future days.
insert into habit_logs (habit_id, day) values ('aaaaaaaa-0000-0000-0000-0000000000c1', current_date);
do $$ begin
  insert into habit_logs (habit_id, day) values ('aaaaaaaa-0000-0000-0000-0000000000c1', current_date);
  raise exception 'FAILED: duplicate habit log';
exception when unique_violation then raise notice 'ok: one habit log per day';
end $$;
do $$ begin
  insert into habit_logs (habit_id, day) values ('aaaaaaaa-0000-0000-0000-0000000000c1', current_date + 2);
  raise exception 'FAILED: future habit log';
exception when check_violation then raise notice 'ok: no future habit logs';
end $$;

do $$ begin
  insert into expenses (amount_minor, currency, category) values (0, 'SAR', 'food');
  raise exception 'FAILED: zero expense';
exception when check_violation then raise notice 'ok: expense must be positive';
end $$;

-- Executor: create_goal with milestones and linked tasks, exactly once.
insert into assistant_actions (id, calls) values ('aaaaaaaa-0000-0000-0000-0000000000f1',
  '[{"tool":"create_goal","args":{"title":"Learn English","milestones":["Level","Basics"],
     "tasks":[{"title":"Session 1","estimatedMinutes":30,"milestone":0},{"title":"Session 2","estimatedMinutes":30,"milestone":1}]}},
    {"tool":"create_task","args":{"title":"Review","dueDate":"2026-03-11","dueTime":1200,"priority":"high"}}]');
select pg_temp.check(apply_assistant_action('aaaaaaaa-0000-0000-0000-0000000000f1') ->> 'outcome' = 'executed', 'proposal executes');
select pg_temp.check(apply_assistant_action('aaaaaaaa-0000-0000-0000-0000000000f1') ->> 'outcome' = 'already_executed', 'second approval is a no-op');
select pg_temp.check((select count(*) = 1 from goals where title = 'Learn English'), 'goal created once');
select pg_temp.check((select count(*) = 2 from tasks t join goal_milestones m on m.id = t.milestone_id where m.title in ('Level', 'Basics')),
  'session tasks linked to the new milestones');
select pg_temp.check((select due_time = '20:00' from tasks where title = 'Review'), 'due time stored');

-- Staleness: a proposal built on an old version of a task is refused.
insert into assistant_actions (id, calls, snapshot) values ('aaaaaaaa-0000-0000-0000-0000000000f2',
  '[{"tool":"move_task","args":{"taskId":"aaaaaaaa-0000-0000-0000-0000000000b1","dueDate":"2026-03-12"}}]',
  '{"aaaaaaaa-0000-0000-0000-0000000000b1":"2000-01-01T00:00:00Z"}');
select pg_temp.check(apply_assistant_action('aaaaaaaa-0000-0000-0000-0000000000f2') ->> 'outcome' = 'stale', 'stale proposal refused');
select pg_temp.check((select due_date is null from tasks where id = 'aaaaaaaa-0000-0000-0000-0000000000b1'), 'stale proposal changed nothing');

-- Usage allowance is enforced server-side.
select pg_temp.check(consume_assistant_request(2) and consume_assistant_request(2) and not consume_assistant_request(2),
  'daily assistant limit enforced');

-- Prayer log: owner-only, one row per prayer per day, nothing in the future.
insert into prayer_logs (day, prayer) values (current_date, 'fajr');
do $$ begin
  insert into prayer_logs (day, prayer) values (current_date, 'fajr');
  raise exception 'FAILED: duplicate prayer log';
exception when unique_violation then raise notice 'ok: prayer logged once per day';
end $$;
do $$ begin
  insert into prayer_logs (day, prayer) values (current_date + 2, 'asr');
  raise exception 'FAILED: future prayer log';
exception when check_violation then raise notice 'ok: no prayer log for a future day';
end $$;
do $$ begin
  insert into prayer_logs (day, prayer) values (current_date, 'witr');
  raise exception 'FAILED: unknown prayer';
exception when check_violation then raise notice 'ok: only the five prayers';
end $$;
update profiles set prayer_settings = '{"enabled": true, "method": "ummAlQura"}';
select pg_temp.check((select prayer_settings ->> 'method' = 'ummAlQura' from profiles), 'prayer settings saved');
select pg_temp.as_user('22222222-2222-2222-2222-222222222222');
select pg_temp.check((select count(*) = 0 from prayer_logs), 'B cannot read A''s prayer log');
do $$ begin
  insert into prayer_logs (user_id, day, prayer) values ('11111111-1111-1111-1111-111111111111', current_date, 'dhuhr');
  raise exception 'FAILED: wrote a prayer log for another user';
exception when insufficient_privilege then raise notice 'ok: cannot log for another user';
end $$;
select pg_temp.as_user('11111111-1111-1111-1111-111111111111');

reset role;
\echo ALL RLS TESTS PASSED
