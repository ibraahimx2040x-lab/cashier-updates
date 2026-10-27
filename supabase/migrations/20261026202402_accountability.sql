-- Accountability (design doc v2, section 3-f): consequences the user agrees
-- to in advance for a late task, and what happened each time.
--
-- Safety is enforced here too: a custom consequence may not touch sleep,
-- food, prayer or health care, or add punishment.

create table public.accountability_rules (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  task_id uuid not null,
  grace_days smallint not null default 7 check (grace_days between 1 and 30),
  consequence text not null check (consequence in ('extraReview', 'planningSession', 'firstStepFirst', 'custom')),
  custom_text text not null default '' check (char_length(custom_text) <= 200),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (id, user_id),
  -- One rule per task.
  unique (task_id),
  foreign key (task_id, user_id) references public.tasks (id, user_id) on delete cascade,
  check (consequence <> 'custom' or char_length(btrim(custom_text)) > 0),
  -- Arabic stems match from the start of a word, after optional prefixes.
  check (custom_text !~ '(^|[^ء-ي])(و|ف|ب|ل)?(ال|لل)?(نوم|انام|أنام|سهر|اسهر|أسهر|طعام|اكل|أكل|وجب|جوع|صيام|اصوم|أصوم|صلا|دواء|علاج|طبيب|مستشف|اضرب|أضرب|جلد|عقاب|تمرين إضافي|تمارين إضافية)'),
  check (custom_text !~* '\m(sleep\w*|food|eat|eating|meals?|starv\w*|fasting|pray\w*|medic\w*|doctors?|hospital|hurt|punish\w*|extra (workout|exercise)s?)\M')
);

create table public.accountability_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  rule_id uuid,
  task_id uuid,
  due_date date not null,
  triggered_on date not null,
  reason text check (reason in ('postponed', 'emergency', 'illness', 'notImportant')),
  outcome text not null default 'pending'
    check (outcome in ('pending', 'consequenceAccepted', 'rescheduled', 'dropped')),
  new_due_date date,
  note text not null default '' check (char_length(note) <= 2000),
  resolved_at timestamptz,
  -- Triggered once per missed deadline.
  unique (rule_id, due_date),
  foreign key (rule_id, user_id) references public.accountability_rules (id, user_id) on delete set null (rule_id),
  foreign key (task_id, user_id) references public.tasks (id, user_id) on delete set null (task_id),
  -- An answer always says why; only a deliberate postponement brings the consequence.
  check ((outcome = 'pending') = (reason is null)),
  check (outcome <> 'consequenceAccepted' or reason = 'postponed'),
  check (outcome <> 'rescheduled' or reason in ('emergency', 'illness')),
  check (outcome <> 'dropped' or reason = 'notImportant')
);
create index accountability_events_user on public.accountability_events (user_id, triggered_on);
create index accountability_events_task on public.accountability_events (task_id);

do $$
declare t text;
begin
  foreach t in array array['accountability_rules', 'accountability_events'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('alter table public.%I force row level security', t);
    execute format(
      'create policy owner_all on public.%I for all to authenticated
         using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
  end loop;
end $$;
