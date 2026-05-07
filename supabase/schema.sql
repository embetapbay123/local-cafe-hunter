-- Local Cafe Hunter - Supabase schema
-- Run this in Supabase SQL Editor before testing the app.

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null,
  tagline text not null default 'Chua co mo ta ca nhan',
  level integer not null default 1,
  points integer not null default 0,
  email text not null default '',
  phone text not null default '',
  avatar_key text not null default 'cat-dev',
  updated_at timestamptz not null default now()
);

create table if not exists public.favorite_cafes (
  user_id uuid not null references auth.users (id) on delete cascade,
  cafe_id text not null,
  saved_at timestamptz not null default now(),
  primary key (user_id, cafe_id)
);

create table if not exists public.collections (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.collection_cafes (
  collection_id text not null references public.collections (id) on delete cascade,
  cafe_id text not null,
  primary key (collection_id, cafe_id)
);

create table if not exists public.reviews (
  id text primary key,
  cafe_id text not null,
  author_uid uuid not null references auth.users (id) on delete cascade,
  author_name text not null,
  rating numeric(2, 1) not null check (rating >= 0 and rating <= 5),
  comment text not null,
  created_at timestamptz not null default now(),
  image_key text,
  image_url text
);

alter table public.profiles enable row level security;
alter table public.favorite_cafes enable row level security;
alter table public.collections enable row level security;
alter table public.collection_cafes enable row level security;
alter table public.reviews enable row level security;

create policy "profiles_select_own"
on public.profiles
for select
to authenticated
using (auth.uid() = id);

create policy "profiles_insert_own"
on public.profiles
for insert
to authenticated
with check (auth.uid() = id);

create policy "profiles_update_own"
on public.profiles
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

create policy "favorites_select_own"
on public.favorite_cafes
for select
to authenticated
using (auth.uid() = user_id);

create policy "favorites_insert_own"
on public.favorite_cafes
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "favorites_delete_own"
on public.favorite_cafes
for delete
to authenticated
using (auth.uid() = user_id);

create policy "collections_select_own"
on public.collections
for select
to authenticated
using (auth.uid() = user_id);

create policy "collections_insert_own"
on public.collections
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "collections_update_own"
on public.collections
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "collections_delete_own"
on public.collections
for delete
to authenticated
using (auth.uid() = user_id);

create policy "collection_cafes_select_owned_collection"
on public.collection_cafes
for select
to authenticated
using (
  exists (
    select 1
    from public.collections c
    where c.id = collection_id
      and c.user_id = auth.uid()
  )
);

create policy "collection_cafes_insert_owned_collection"
on public.collection_cafes
for insert
to authenticated
with check (
  exists (
    select 1
    from public.collections c
    where c.id = collection_id
      and c.user_id = auth.uid()
  )
);

create policy "collection_cafes_delete_owned_collection"
on public.collection_cafes
for delete
to authenticated
using (
  exists (
    select 1
    from public.collections c
    where c.id = collection_id
      and c.user_id = auth.uid()
  )
);

create policy "reviews_select_all"
on public.reviews
for select
to authenticated
using (true);

create policy "reviews_insert_own"
on public.reviews
for insert
to authenticated
with check (auth.uid() = author_uid);

create policy "reviews_update_own"
on public.reviews
for update
to authenticated
using (auth.uid() = author_uid)
with check (auth.uid() = author_uid);

create policy "reviews_delete_own"
on public.reviews
for delete
to authenticated
using (auth.uid() = author_uid);

insert into storage.buckets (id, name, public)
values ('review-images', 'review-images', true)
on conflict (id) do nothing;

create policy "review_images_public_read"
on storage.objects
for select
to public
using (bucket_id = 'review-images');

create policy "review_images_insert_own_folder"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'review-images'
  and (storage.foldername(name))[1] = auth.uid()::text
);
