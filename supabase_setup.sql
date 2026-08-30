-- NoahX Japan / Supabase setup
-- Run this entire file in Supabase Dashboard > SQL Editor.
-- The browser uses only the public Publishable/anon key. NEVER put service_role here.

create extension if not exists pgcrypto;

create table if not exists public.noahx_posts (
  id text primary key,
  talent_index integer not null default 0,
  data jsonb not null default '{}'::jsonb,
  image_path text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists noahx_posts_talent_index_idx
  on public.noahx_posts (talent_index);
create index if not exists noahx_posts_updated_at_idx
  on public.noahx_posts (updated_at desc);

create table if not exists public.noahx_talents (
  id uuid primary key default gen_random_uuid(),
  base_index integer unique,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists noahx_talents_base_index_idx
  on public.noahx_talents (base_index);

create table if not exists public.noahx_site_state (
  key text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.noahx_posts enable row level security;
alter table public.noahx_talents enable row level security;
alter table public.noahx_site_state enable row level security;

-- Remove/recreate policies so this script can be safely rerun.
drop policy if exists "noahx_posts_public_read" on public.noahx_posts;
drop policy if exists "noahx_posts_authenticated_insert" on public.noahx_posts;
drop policy if exists "noahx_posts_authenticated_update" on public.noahx_posts;
drop policy if exists "noahx_posts_authenticated_delete" on public.noahx_posts;

drop policy if exists "noahx_talents_public_read" on public.noahx_talents;
drop policy if exists "noahx_talents_authenticated_insert" on public.noahx_talents;
drop policy if exists "noahx_talents_authenticated_update" on public.noahx_talents;
drop policy if exists "noahx_talents_authenticated_delete" on public.noahx_talents;

drop policy if exists "noahx_site_state_public_read" on public.noahx_site_state;
drop policy if exists "noahx_site_state_authenticated_insert" on public.noahx_site_state;
drop policy if exists "noahx_site_state_authenticated_update" on public.noahx_site_state;
drop policy if exists "noahx_site_state_authenticated_delete" on public.noahx_site_state;

create policy "noahx_posts_public_read"
on public.noahx_posts for select
to anon, authenticated
using (true);

create policy "noahx_posts_authenticated_insert"
on public.noahx_posts for insert
to authenticated
with check (true);

create policy "noahx_posts_authenticated_update"
on public.noahx_posts for update
to authenticated
using (true)
with check (true);

create policy "noahx_posts_authenticated_delete"
on public.noahx_posts for delete
to authenticated
using (true);

create policy "noahx_talents_public_read"
on public.noahx_talents for select
to anon, authenticated
using (true);

create policy "noahx_talents_authenticated_insert"
on public.noahx_talents for insert
to authenticated
with check (true);

create policy "noahx_talents_authenticated_update"
on public.noahx_talents for update
to authenticated
using (true)
with check (true);

create policy "noahx_talents_authenticated_delete"
on public.noahx_talents for delete
to authenticated
using (true);

create policy "noahx_site_state_public_read"
on public.noahx_site_state for select
to anon, authenticated
using (true);

create policy "noahx_site_state_authenticated_insert"
on public.noahx_site_state for insert
to authenticated
with check (true);

create policy "noahx_site_state_authenticated_update"
on public.noahx_site_state for update
to authenticated
using (true)
with check (true);

create policy "noahx_site_state_authenticated_delete"
on public.noahx_site_state for delete
to authenticated
using (true);

-- Storage bucket for post images.
insert into storage.buckets (id, name, public)
values ('noahx-images', 'noahx-images', true)
on conflict (id) do update set public = true;

-- Storage policies. Public visitors can read images; only signed-in admins can write/delete.
drop policy if exists "noahx_images_public_read" on storage.objects;
drop policy if exists "noahx_images_authenticated_insert" on storage.objects;
drop policy if exists "noahx_images_authenticated_update" on storage.objects;
drop policy if exists "noahx_images_authenticated_delete" on storage.objects;

create policy "noahx_images_public_read"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'noahx-images');

create policy "noahx_images_authenticated_insert"
on storage.objects for insert
to authenticated
with check (bucket_id = 'noahx-images');

create policy "noahx_images_authenticated_update"
on storage.objects for update
to authenticated
using (bucket_id = 'noahx-images')
with check (bucket_id = 'noahx-images');

create policy "noahx_images_authenticated_delete"
on storage.objects for delete
to authenticated
using (bucket_id = 'noahx-images');

-- Optional: useful realtime publication for future live-update features.
-- Safe to run only if your project has the standard supabase_realtime publication.
alter publication supabase_realtime add table public.noahx_posts;
