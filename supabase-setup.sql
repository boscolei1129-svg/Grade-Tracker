-- Run once in Supabase: SQL Editor > New query > paste > Run.
-- One row per person per app. "app" lets other apps (gym, sleep, ledger) share this table later.
create table if not exists public.app_data (
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  app        text not null,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, app)
);

-- Row Level Security: each signed-in person can only see and change their own rows.
alter table public.app_data enable row level security;

create policy "Read own data" on public.app_data
  for select to authenticated using ((select auth.uid()) = user_id);

create policy "Add own data" on public.app_data
  for insert to authenticated with check ((select auth.uid()) = user_id);

create policy "Update own data" on public.app_data
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

grant select, insert, update on public.app_data to authenticated;
