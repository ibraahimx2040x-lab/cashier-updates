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

-- Devices: sleep, body measurements and imported workouts (phase 10).
insert into sleep_sessions (id, source, start_at, end_at)
  values ('5eeb0000-0000-0000-0000-000000000001', 'healthConnect', now() - interval '9 hours', now() - interval '1 hour');
do $$ begin
  insert into sleep_sessions (id, source, start_at, end_at) values (gen_random_uuid(), 'healthConnect', now() - interval '1 hour', now() - interval '2 hours');
  raise exception 'FAILED: sleep ends before it starts';
exception when check_violation then raise notice 'ok: sleep ends after it starts';
end $$;
do $$ begin
  insert into sleep_sessions (id, source, start_at, end_at) values (gen_random_uuid(), 'healthConnect', now() - interval '30 hours', now() - interval '1 hour');
  raise exception 'FAILED: sleep over 24 hours';
exception when check_violation then raise notice 'ok: sleep at most 24 hours';
end $$;
do $$ begin
  insert into sleep_sessions (id, source, start_at, end_at) values (gen_random_uuid(), 'healthConnect', now(), now() + interval '8 hours');
  raise exception 'FAILED: sleep in the future';
exception when check_violation then raise notice 'ok: no future sleep';
end $$;
do $$ begin
  insert into sleep_sessions (id, source, start_at, end_at) values (gen_random_uuid(), 'fitbit', now() - interval '9 hours', now() - interval '1 hour');
  raise exception 'FAILED: unknown source';
exception when check_violation then raise notice 'ok: known sources only';
end $$;
insert into body_metrics (id, kind, value, source, measured_at)
  values ('b0d10000-0000-0000-0000-000000000001', 'resting_hr', 58, 'healthKit', now() - interval '3 hours');
insert into body_metrics (id, kind, value, value2, source, measured_at)
  values ('b0d10000-0000-0000-0000-000000000002', 'bp', 120, 80, 'manual', now());
do $$ begin
  insert into body_metrics (id, kind, value, source, measured_at) values (gen_random_uuid(), 'resting_hr', 300, 'healthKit', now());
  raise exception 'FAILED: heart rate out of range';
exception when check_violation then raise notice 'ok: resting heart rate 25-220';
end $$;
do $$ begin
  insert into body_metrics (id, kind, value, source, measured_at) values (gen_random_uuid(), 'bp', 120, 'manual', now());
  raise exception 'FAILED: blood pressure without diastolic';
exception when check_violation then raise notice 'ok: blood pressure needs both values';
end $$;
do $$ begin
  insert into body_metrics (id, kind, value, value2, source, measured_at) values (gen_random_uuid(), 'weight', 80, 70, 'manual', now());
  raise exception 'FAILED: second value on weight';
exception when check_violation then raise notice 'ok: only blood pressure has a second value';
end $$;
do $$ begin
  insert into body_metrics (id, kind, value, source, measured_at) values (gen_random_uuid(), 'weight', 80, 'manual', now() + interval '1 day');
  raise exception 'FAILED: measured in the future';
exception when check_violation then raise notice 'ok: no future measurements';
end $$;
insert into device_workouts (id, source, activity, start_at, end_at, kcal, distance_m)
  values ('d0d00000-0000-0000-0000-000000000001', 'healthConnect', 'RUNNING', now() - interval '2 hours', now() - interval '90 minutes', 320, 5200);
do $$ begin
  insert into device_workouts (id, source, activity, start_at, end_at) values (gen_random_uuid(), 'healthConnect', 'run fast!', now() - interval '2 hours', now() - interval '1 hour');
  raise exception 'FAILED: odd activity code';
exception when check_violation then raise notice 'ok: activity is a store code';
end $$;
do $$ begin
  insert into device_workouts (id, source, activity, start_at, end_at, kcal) values (gen_random_uuid(), 'healthConnect', 'WALKING', now() - interval '2 hours', now() - interval '1 hour', -5);
  raise exception 'FAILED: negative calories';
exception when check_violation then raise notice 'ok: workout values not negative';
end $$;
select pg_temp.as_user('22222222-2222-2222-2222-222222222222');
select pg_temp.check(
  (select count(*) from sleep_sessions) + (select count(*) from body_metrics) + (select count(*) from device_workouts) = 0,
  'B cannot read A''s sleep, measurements or workouts');
do $$ begin
  insert into sleep_sessions (id, user_id, source, start_at, end_at)
    values (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'manual', now() - interval '8 hours', now());
  raise exception 'FAILED: wrote sleep for another user';
exception when insufficient_privilege then raise notice 'ok: no sleep for another user';
end $$;
select pg_temp.as_user('11111111-1111-1111-1111-111111111111');

-- Women's health and appointments (phase 11).
insert into cycle_periods (id, start_date, end_date) values ('c1c10000-0000-0000-0000-000000000001', current_date - 40, current_date - 36);
insert into cycle_periods (id, start_date) values ('c1c10000-0000-0000-0000-000000000002', current_date - 10);
do $$ begin
  insert into cycle_periods (id, start_date, end_date) values (gen_random_uuid(), current_date - 38, current_date - 37);
  raise exception 'FAILED: overlapping periods';
exception when exclusion_violation then raise notice 'ok: periods do not overlap';
end $$;
do $$ begin
  insert into cycle_periods (id, start_date) values (gen_random_uuid(), current_date - 3);
  raise exception 'FAILED: second open period inside the first';
exception when exclusion_violation then raise notice 'ok: an open period blocks its first 15 days';
end $$;
do $$ begin
  insert into cycle_periods (id, start_date) values (gen_random_uuid(), current_date + 3);
  raise exception 'FAILED: future period';
exception when check_violation then raise notice 'ok: no future periods';
end $$;
do $$ begin
  insert into cycle_periods (id, start_date, end_date) values (gen_random_uuid(), current_date - 80, current_date - 60);
  raise exception 'FAILED: 21-day period';
exception when check_violation then raise notice 'ok: a period lasts at most 15 days';
end $$;
update cycle_periods set end_date = current_date - 6 where id = 'c1c10000-0000-0000-0000-000000000002';
select pg_temp.check((select end_date = current_date - 6 from cycle_periods where id = 'c1c10000-0000-0000-0000-000000000002'), 'a period can be ended');
insert into cycle_day_logs (id, day, flow, pain, symptoms, mood, energy) values
  ('c1d00000-0000-0000-0000-000000000001', current_date - 9, 'medium', 4, '{cramps,back_pain}', 'low', 2);
do $$ begin
  insert into cycle_day_logs (id, day, symptoms) values (gen_random_uuid(), current_date - 8, '{cramps,unknown}');
  raise exception 'FAILED: unknown symptom';
exception when check_violation then raise notice 'ok: symptoms from the fixed list';
end $$;
do $$ begin
  insert into cycle_day_logs (id, day, pain) values (gen_random_uuid(), current_date - 8, 11);
  raise exception 'FAILED: pain 11';
exception when check_violation then raise notice 'ok: pain 0-10';
end $$;
do $$ begin
  insert into cycle_day_logs (id, day) values (gen_random_uuid(), current_date - 9);
  raise exception 'FAILED: two logs for one day';
exception when unique_violation then raise notice 'ok: one log per day';
end $$;
do $$ begin
  insert into cycle_day_logs (id, day) values (gen_random_uuid(), current_date + 2);
  raise exception 'FAILED: future log';
exception when check_violation then raise notice 'ok: no future logs';
end $$;
insert into health_appointments (id, title, kind, at, questions, reminder_minutes)
  values ('a9900000-0000-0000-0000-0000000000a1', 'Checkup', 'checkup', now() + interval '3 days', '{"Is this normal?"}', 60);
do $$ begin
  insert into health_appointments (id, title, at) values (gen_random_uuid(), '  ', now());
  raise exception 'FAILED: blank appointment title';
exception when check_violation then raise notice 'ok: appointment needs a title';
end $$;
do $$ begin
  insert into health_appointments (id, title, kind, at) values (gen_random_uuid(), 'x', 'surgery', now());
  raise exception 'FAILED: unknown appointment kind';
exception when check_violation then raise notice 'ok: known appointment kinds';
end $$;
select pg_temp.as_user('22222222-2222-2222-2222-222222222222');
select pg_temp.check(
  (select count(*) from cycle_periods) + (select count(*) from cycle_day_logs) + (select count(*) from health_appointments) = 0,
  'B cannot read A''s cycle data or appointments');
-- B's periods don't clash with A's.
insert into cycle_periods (id, start_date) values ('c1c10000-0000-0000-0000-0000000000b1', current_date - 10);
do $$ begin
  insert into cycle_day_logs (id, user_id, day) values (gen_random_uuid(), '11111111-1111-1111-1111-111111111111', current_date);
  raise exception 'FAILED: wrote a cycle log for another user';
exception when insufficient_privilege then raise notice 'ok: no cycle logs for another user';
end $$;
select pg_temp.as_user('11111111-1111-1111-1111-111111111111');

-- Sleep and recovery check-ins (phase 12).
insert into wellbeing_checkins (id, day, energy, fatigue, recovery, mood) values ('3e110000-0000-0000-0000-000000000001', current_date, 4, 2, 3, 5);
do $$ begin
  insert into wellbeing_checkins (id, day, energy) values (gen_random_uuid(), current_date, 3);
  raise exception 'FAILED: two check-ins for one day';
exception when unique_violation then raise notice 'ok: one check-in per day';
end $$;
do $$ begin
  insert into wellbeing_checkins (id, day, mood) values (gen_random_uuid(), current_date - 1, 6);
  raise exception 'FAILED: mood 6';
exception when check_violation then raise notice 'ok: check-ins 1-5';
end $$;
do $$ begin
  insert into wellbeing_checkins (id, day, energy) values (gen_random_uuid(), current_date + 1, 3);
  raise exception 'FAILED: future check-in';
exception when check_violation then raise notice 'ok: no future check-ins';
end $$;
insert into sleep_sessions (id, source, start_at, end_at, quality)
  values ('5eeb0000-0000-0000-0000-0000000000a2', 'manual', now() - interval '33 hours', now() - interval '25 hours', 4);
select pg_temp.as_user('22222222-2222-2222-2222-222222222222');
select pg_temp.check((select count(*) = 0 from wellbeing_checkins), 'B cannot read A''s check-ins');
select pg_temp.as_user('11111111-1111-1111-1111-111111111111');

-- Income and monthly items (v4 phase 14).
insert into salary_rates (id, amount_minor, currency, effective_from, pay_day) values
  ('5a100000-0000-0000-0000-000000000001', 500000, 'SAR', '2026-01-01', 27),
  ('5a100000-0000-0000-0000-000000000002', 600000, 'SAR', '2026-06-01', 27);
do $$ begin
  insert into salary_rates (id, amount_minor, currency, effective_from) values (gen_random_uuid(), 1, 'SAR', '2026-06-01');
  raise exception 'FAILED: two salary rates on one day';
exception when unique_violation then raise notice 'ok: one salary change per day';
end $$;
do $$ begin
  insert into salary_rates (id, amount_minor, currency, effective_from, pay_day) values (gen_random_uuid(), 1, 'SAR', '2026-07-01', 32);
  raise exception 'FAILED: pay day 32';
exception when check_violation then raise notice 'ok: pay day 1-31';
end $$;
insert into recurring_items (id, kind, amount_minor, currency, category, title, day_of_month, starts_on)
  values ('5a100000-0000-0000-0000-0000000000a1', 'expense', 150000, 'SAR', 'bills', 'Rent', 1, '2026-01-01');
insert into expenses (amount_minor, currency, category, recurring_id)
  values (150000, 'SAR', 'bills', '5a100000-0000-0000-0000-0000000000a1');
insert into incomes (id, amount_minor, currency, kind, source, received_at)
  values ('5a100000-0000-0000-0000-0000000000b1', 80000, 'SAR', 'extra', 'Freelance', now());
do $$ begin
  insert into incomes (id, amount_minor, currency, received_at) values (gen_random_uuid(), 100, 'SAR', now() + interval '3 days');
  raise exception 'FAILED: future income';
exception when check_violation then raise notice 'ok: no future income';
end $$;
do $$ begin
  insert into recurring_items (id, kind, amount_minor, currency, starts_on, ends_on) values (gen_random_uuid(), 'income', 1, 'SAR', '2026-05-01', '2026-04-01');
  raise exception 'FAILED: ends before it starts';
exception when check_violation then raise notice 'ok: monthly item ends after it starts';
end $$;
select pg_temp.as_user('22222222-2222-2222-2222-222222222222');
select pg_temp.check(
  (select count(*) from salary_rates) + (select count(*) from incomes) + (select count(*) from recurring_items) = 0,
  'B cannot read A''s income');
do $$ begin
  insert into expenses (amount_minor, currency, category, recurring_id) values (1, 'SAR', 'bills', '5a100000-0000-0000-0000-0000000000a1');
  raise exception 'FAILED: B linked an expense to A''s monthly item';
exception when foreign_key_violation then raise notice 'ok: B cannot use A''s monthly item';
end $$;
select pg_temp.as_user('11111111-1111-1111-1111-111111111111');
delete from recurring_items where id = '5a100000-0000-0000-0000-0000000000a1';
select pg_temp.check((select count(*) = 1 from expenses where category = 'bills' and recurring_id is null),
  'deleting a monthly item keeps the expenses it made');

reset role;
\echo ALL RLS TESTS PASSED
