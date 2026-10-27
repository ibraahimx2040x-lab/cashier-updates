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

-- Fitness: one active plan per place, versions kept, sessions validated.
insert into workout_plans (id, place, version, goal, days) values
  ('aaaaaaaa-0000-0000-0000-0000000000d1', 'home', 1, 'general', '[{"weekday":1,"focus":"fullBody","minutes":30,"exercises":[]}]');
do $$ begin
  insert into workout_plans (place, version, goal, days) values ('home', 2, 'general', '[{"weekday":1}]');
  raise exception 'FAILED: two active plans for one place';
exception when unique_violation then raise notice 'ok: one active plan per place';
end $$;
update workout_plans set active = false where id = 'aaaaaaaa-0000-0000-0000-0000000000d1';
insert into workout_plans (place, version, goal, days) values ('home', 2, 'general', '[{"weekday":1}]');
select pg_temp.check((select count(*) = 2 from workout_plans), 'earlier plan version kept');
insert into workout_sessions (plan_id, day, place, focus, status, difficulty, sets)
  values ('aaaaaaaa-0000-0000-0000-0000000000d1', current_date, 'home', 'fullBody', 'partial', 3,
          '[{"exerciseId":"bw_squat","setIndex":0,"reps":10}]');
select pg_temp.check((select plan_id = 'aaaaaaaa-0000-0000-0000-0000000000d1' from workout_sessions), 'session keeps the plan version');
do $$ begin
  insert into workout_sessions (day, place, focus, status) values (current_date + 2, 'home', 'upper', 'completed');
  raise exception 'FAILED: future workout';
exception when check_violation then raise notice 'ok: no workout logged for a future day';
end $$;
do $$ begin
  insert into workout_sessions (day, place, focus, status, difficulty) values (current_date, 'home', 'upper', 'completed', 6);
  raise exception 'FAILED: difficulty out of range';
exception when check_violation then raise notice 'ok: difficulty 1-5';
end $$;
insert into workout_sessions (day, place, focus, status, program_id) values (current_date, 'home', 'fullBody', 'completed', 'pelvic_floor_women');
select pg_temp.check((select count(*) = 1 from workout_sessions where program_id = 'pelvic_floor_women'), 'session keeps its program');
do $$ begin
  insert into workout_sessions (day, place, focus, status, program_id) values (current_date, 'home', 'upper', 'completed', 'Bad Id!');
  raise exception 'FAILED: odd program id';
exception when check_violation then raise notice 'ok: program id is a code key';
end $$;
select pg_temp.as_user('22222222-2222-2222-2222-222222222222');
select pg_temp.check((select count(*) = 0 from workout_plans) and (select count(*) = 0 from workout_sessions),
  'B cannot read A''s plans or workouts');
do $$ begin
  insert into workout_sessions (plan_id, day, place, focus, status)
    values ('aaaaaaaa-0000-0000-0000-0000000000d1', current_date, 'home', 'upper', 'completed');
  raise exception 'FAILED: linked a workout to another user''s plan';
exception when foreign_key_violation then raise notice 'ok: cannot link to another user''s plan';
end $$;
select pg_temp.as_user('11111111-1111-1111-1111-111111111111');

-- Learning: one path per subject, one progress row per lesson and word.
insert into learning_paths (level, weekly_goal) values ('a2', 3);
do $$ begin
  insert into learning_paths (level, weekly_goal) values ('b1', 3);
  raise exception 'FAILED: two English paths';
exception when unique_violation then raise notice 'ok: one path per subject';
end $$;
do $$ begin
  insert into learning_paths (subject, level, weekly_goal) values ('french', 'a1', 3);
  raise exception 'FAILED: unknown subject';
exception when check_violation then raise notice 'ok: only known subjects';
end $$;
insert into lesson_progress (lesson_id, best_score, attempts) values ('a2_past', 60, 1);
do $$ begin
  insert into lesson_progress (lesson_id, best_score, attempts) values ('a2_past', 90, 1);
  raise exception 'FAILED: duplicate lesson progress';
exception when unique_violation then raise notice 'ok: one progress row per lesson';
end $$;
do $$ begin
  insert into lesson_progress (lesson_id, best_score, attempts) values ('a2_compare', 120, 1);
  raise exception 'FAILED: score over 100';
exception when check_violation then raise notice 'ok: score 0-100';
end $$;
insert into vocab_reviews (word_id, box, due) values ('w_yesterday', 1, current_date + 1);
do $$ begin
  insert into vocab_reviews (word_id, box, due) values ('w_trip', 6, current_date);
  raise exception 'FAILED: box out of range';
exception when check_violation then raise notice 'ok: review box 1-5';
end $$;
insert into assessments (kind, level, scores, passed) values ('placement', 'a2', '{"grammar": {"correct": 3, "total": 4}}', true);
select pg_temp.as_user('22222222-2222-2222-2222-222222222222');
select pg_temp.check(
  (select count(*) from learning_paths) + (select count(*) from lesson_progress)
    + (select count(*) from vocab_reviews) + (select count(*) from assessments) = 0,
  'B cannot read A''s learning data');
select pg_temp.as_user('11111111-1111-1111-1111-111111111111');

-- Accountability: one rule per task, safe custom wording, reasons that match outcomes.
insert into tasks (id, title, due_date) values ('acacacac-0000-0000-0000-000000000001', 'Essay', current_date - 10);
insert into accountability_rules (id, task_id, grace_days, consequence)
  values ('acacacac-0000-0000-0000-0000000000a1', 'acacacac-0000-0000-0000-000000000001', 7, 'planningSession');
do $$ begin
  insert into accountability_rules (task_id, consequence) values ('acacacac-0000-0000-0000-000000000001', 'extraReview');
  raise exception 'FAILED: two rules for one task';
exception when unique_violation then raise notice 'ok: one rule per task';
end $$;
insert into tasks (id, title, due_date) values ('acacacac-0000-0000-0000-000000000002', 'Report', current_date);
do $$ declare bad text; begin
  foreach bad in array array['No sleep until done', 'skip meals', 'بدون أكل', 'أأخر الصلاة', 'أروح للطبيب بعدين', 'punishment', ''] loop
    begin
      insert into accountability_rules (task_id, consequence, custom_text) values ('acacacac-0000-0000-0000-000000000002', 'custom', bad);
      raise exception 'FAILED: unsafe consequence accepted: %', bad;
    exception when check_violation then null;
    end;
  end loop;
  raise notice 'ok: unsafe custom consequences rejected';
end $$;
insert into accountability_rules (task_id, consequence, custom_text)
  values ('acacacac-0000-0000-0000-000000000002', 'custom', 'أحل المشاكل وأرتب المجلد');
do $$ begin
  insert into accountability_rules (task_id, grace_days, consequence) values ('acacacac-0000-0000-0000-000000000002', 0, 'extraReview');
  raise exception 'FAILED: grace 0';
exception when check_violation then raise notice 'ok: grace 1-30';
end $$;
insert into accountability_events (id, rule_id, task_id, due_date, triggered_on)
  values ('acacacac-0000-0000-0000-0000000000e1', 'acacacac-0000-0000-0000-0000000000a1', 'acacacac-0000-0000-0000-000000000001', current_date - 10, current_date - 3);
do $$ begin
  insert into accountability_events (rule_id, due_date, triggered_on)
    values ('acacacac-0000-0000-0000-0000000000a1', current_date - 10, current_date);
  raise exception 'FAILED: triggered twice for one deadline';
exception when unique_violation then raise notice 'ok: once per deadline';
end $$;
do $$ begin
  update accountability_events set reason = 'illness', outcome = 'consequenceAccepted' where id = 'acacacac-0000-0000-0000-0000000000e1';
  raise exception 'FAILED: consequence after illness';
exception when check_violation then raise notice 'ok: illness never brings a consequence';
end $$;
do $$ begin
  update accountability_events set outcome = 'rescheduled' where id = 'acacacac-0000-0000-0000-0000000000e1';
  raise exception 'FAILED: answered without a reason';
exception when check_violation then raise notice 'ok: an answer says why';
end $$;
update accountability_events set reason = 'postponed', outcome = 'consequenceAccepted', new_due_date = current_date + 3, resolved_at = now()
  where id = 'acacacac-0000-0000-0000-0000000000e1';
delete from accountability_rules where id = 'acacacac-0000-0000-0000-0000000000a1';
select pg_temp.check(
  (select rule_id is null and outcome = 'consequenceAccepted' from accountability_events where id = 'acacacac-0000-0000-0000-0000000000e1'),
  'deleting a rule keeps its history');
select pg_temp.as_user('22222222-2222-2222-2222-222222222222');
select pg_temp.check(
  (select count(*) from accountability_rules) + (select count(*) from accountability_events) = 0,
  'B cannot read A''s commitments');
do $$ begin
  insert into accountability_rules (task_id, consequence) values ('acacacac-0000-0000-0000-000000000001', 'extraReview');
  raise exception 'FAILED: rule on another user''s task';
exception when foreign_key_violation or unique_violation or insufficient_privilege then raise notice 'ok: no rule on another user''s task';
end $$;
select pg_temp.as_user('11111111-1111-1111-1111-111111111111');

-- Activity: sex from sign-up metadata, one row per day and source, no future days.
reset role;
insert into auth.users values
  ('33333333-3333-3333-3333-333333333333', 'c@example.com', '{"sex": "female"}'),
  ('44444444-4444-4444-4444-444444444444', 'd@example.com', '{"sex": "robot"}');
select pg_temp.check((select sex = 'female' and health_settings -> 'modules' ? 'womens' and not health_settings -> 'modules' ? 'mens'
  from profiles where user_id = '33333333-3333-3333-3333-333333333333'), 'sign-up sex copied to profile with its health section');
select pg_temp.check((select sex is null from profiles where user_id = '44444444-4444-4444-4444-444444444444'), 'unknown sex ignored');
set role authenticated;
select pg_temp.as_user('11111111-1111-1111-1111-111111111111');
do $$ begin
  update profiles set sex = 'other';
  raise exception 'FAILED: unknown sex stored';
exception when check_violation then raise notice 'ok: sex is male or female';
end $$;
update profiles set sex = 'male', health_settings = '{"stepGoal": 9000}';
insert into daily_activity (id, day, source, steps) values ('adadadad-0000-0000-0000-000000000001', current_date - 1, 'phone', 6400);
insert into daily_activity (id, day, source, steps, distance_m, active_minutes)
  values ('adadadad-0000-0000-0000-000000000002', current_date - 1, 'healthConnect', 7100, 5200, 48);
do $$ begin
  insert into daily_activity (id, day, source, steps) values ('adadadad-0000-0000-0000-000000000003', current_date - 1, 'phone', 10);
  raise exception 'FAILED: two rows for one day and source';
exception when unique_violation then raise notice 'ok: one row per day and source';
end $$;
do $$ begin
  insert into daily_activity (id, day, source, steps) values ('adadadad-0000-0000-0000-000000000004', current_date + 2, 'manual', 10);
  raise exception 'FAILED: future activity';
exception when check_violation then raise notice 'ok: no future activity';
end $$;
do $$ begin
  insert into daily_activity (id, day, source, steps) values ('adadadad-0000-0000-0000-000000000005', current_date, 'manual', 200000);
  raise exception 'FAILED: impossible step count';
exception when check_violation then raise notice 'ok: step count in range';
end $$;
do $$ begin
  insert into daily_activity (id, day, source, steps) values ('adadadad-0000-0000-0000-000000000006', current_date, 'fitbit', 10);
  raise exception 'FAILED: unknown source';
exception when check_violation then raise notice 'ok: only known sources';
end $$;
select pg_temp.as_user('22222222-2222-2222-2222-222222222222');
select pg_temp.check((select count(*) = 0 from daily_activity), 'B cannot read A''s activity');
do $$ begin
  insert into daily_activity (id, user_id, day, source, steps)
    values ('adadadad-0000-0000-0000-000000000007', '11111111-1111-1111-1111-111111111111', current_date, 'manual', 10);
  raise exception 'FAILED: wrote activity for another user';
exception when insufficient_privilege then raise notice 'ok: no activity for another user';
end $$;
select pg_temp.as_user('11111111-1111-1111-1111-111111111111');

-- Nutrition: saved foods, food log, water; no future days; owner only.
insert into custom_foods (name, portion, kcal, protein, carbs, fat, barcode) values ('Laban', 'bottle', 120, 8, 12, 4, '6281007012345');
do $$ begin
  insert into custom_foods (name, kcal, protein, carbs, fat, barcode) values ('Laban again', 1, 0, 0, 0, '6281007012345');
  raise exception 'FAILED: barcode saved twice';
exception when unique_violation then raise notice 'ok: one food per barcode';
end $$;
do $$ begin
  insert into custom_foods (name, kcal, protein, carbs, fat, barcode) values ('Bad', 1, 0, 0, 0, '12ab');
  raise exception 'FAILED: bad barcode';
exception when check_violation then raise notice 'ok: barcode digits only';
end $$;
do $$ begin
  insert into custom_foods (name, kcal, protein, carbs, fat) values ('Huge', 9000, 0, 0, 0);
  raise exception 'FAILED: impossible calories';
exception when check_violation then raise notice 'ok: calories in range';
end $$;
insert into food_logs (day, meal, name, food_ref, portions, kcal, protein, carbs, fat)
  values (current_date, 'lunch', 'Chicken mandi', 'chicken_mandi', 1.5, 930, 52.5, 102, 33);
do $$ begin
  insert into food_logs (day, meal, name, portions, kcal, protein, carbs, fat) values (current_date + 2, 'lunch', 'x', 1, 1, 0, 0, 0);
  raise exception 'FAILED: future food log';
exception when check_violation then raise notice 'ok: no future food log';
end $$;
do $$ begin
  insert into food_logs (day, meal, name, portions, kcal, protein, carbs, fat) values (current_date, 'brunch', 'x', 1, 1, 0, 0, 0);
  raise exception 'FAILED: unknown meal';
exception when check_violation then raise notice 'ok: known meals only';
end $$;
do $$ begin
  insert into food_logs (day, meal, name, portions, kcal, protein, carbs, fat) values (current_date, 'lunch', 'x', 0, 1, 0, 0, 0);
  raise exception 'FAILED: zero portions';
exception when check_violation then raise notice 'ok: portions above zero';
end $$;
insert into water_intake (id, day, ml) values ('aeaeaeae-0000-0000-0000-000000000001', current_date, 750);
do $$ begin
  insert into water_intake (id, day, ml) values ('aeaeaeae-0000-0000-0000-000000000002', current_date, 250);
  raise exception 'FAILED: two water rows for one day';
exception when unique_violation then raise notice 'ok: one water row per day';
end $$;
select pg_temp.as_user('22222222-2222-2222-2222-222222222222');
select pg_temp.check(
  (select count(*) from custom_foods) + (select count(*) from food_logs) + (select count(*) from water_intake) = 0,
  'B cannot read A''s food');
do $$ begin
  insert into food_logs (user_id, day, meal, name, portions, kcal, protein, carbs, fat)
    values ('11111111-1111-1111-1111-111111111111', current_date, 'lunch', 'x', 1, 1, 0, 0, 0);
  raise exception 'FAILED: logged food for another user';
exception when insufficient_privilege then raise notice 'ok: no food for another user';
end $$;
select pg_temp.as_user('11111111-1111-1111-1111-111111111111');

reset role;
\echo ALL RLS TESTS PASSED
