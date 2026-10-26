-- English learning (design doc v2, section 3-e): the user's path, test
-- history, lesson results and vocabulary reviews. The course content is
-- fixed and ships with the app; rows reference lessons and words by id.

create table public.learning_paths (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  subject text not null default 'english' check (subject in ('english')),
  level text not null check (level in ('a1', 'a2', 'b1', 'b2')),
  weekly_goal smallint not null check (weekly_goal between 1 and 7),
  started_at timestamptz not null default now(),
  unique (user_id, subject)
);

-- Placement tests and end-of-level checks are kept as history.
create table public.assessments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  kind text not null check (kind in ('placement', 'levelCheck')),
  level text not null check (level in ('a1', 'a2', 'b1', 'b2')),
  -- {"vocabulary": {"correct": 3, "total": 4}, ...}
  scores jsonb not null check (jsonb_typeof(scores) = 'object'),
  skill_levels jsonb not null default '{}'::jsonb check (jsonb_typeof(skill_levels) = 'object'),
  passed boolean not null,
  taken_at timestamptz not null default now()
);
create index assessments_user on public.assessments (user_id, taken_at);

-- Best result per lesson, not just an overall percentage.
create table public.lesson_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  lesson_id text not null check (char_length(lesson_id) between 1 and 64),
  best_score smallint not null check (best_score between 0 and 100),
  attempts integer not null check (attempts >= 1),
  last_at timestamptz not null default now(),
  unique (user_id, lesson_id)
);

-- Spaced review (Leitner boxes 1-5) of words from studied lessons.
create table public.vocab_reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  word_id text not null check (char_length(word_id) between 1 and 64),
  box smallint not null check (box between 1 and 5),
  due date not null,
  unique (user_id, word_id)
);
create index vocab_reviews_due on public.vocab_reviews (user_id, due);

do $$
declare t text;
begin
  foreach t in array array['learning_paths', 'assessments', 'lesson_progress', 'vocab_reviews'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('alter table public.%I force row level security', t);
    execute format(
      'create policy owner_all on public.%I for all to authenticated
         using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))', t);
    execute format('grant select, insert, update, delete on public.%I to authenticated', t);
  end loop;
end $$;
