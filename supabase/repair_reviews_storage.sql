-- Run this in Supabase SQL Editor if reviews, collections, or storage fail with RLS errors.

grant select, insert, update, delete on table public.reviews to authenticated;
grant select, insert, update, delete on table public.favorite_cafes to authenticated;
grant select, insert, update, delete on table public.collections to authenticated;
grant select, insert, update, delete on table public.collection_cafes to authenticated;

drop policy if exists "reviews_select_all" on public.reviews;
drop policy if exists "reviews_insert_own" on public.reviews;
drop policy if exists "reviews_update_own" on public.reviews;
drop policy if exists "reviews_delete_own" on public.reviews;
drop policy if exists "collections_select_own" on public.collections;
drop policy if exists "collections_insert_own" on public.collections;
drop policy if exists "collections_update_own" on public.collections;
drop policy if exists "collections_delete_own" on public.collections;
drop policy if exists "collection_cafes_select_owned_collection" on public.collection_cafes;
drop policy if exists "collection_cafes_insert_owned_collection" on public.collection_cafes;
drop policy if exists "collection_cafes_delete_owned_collection" on public.collection_cafes;

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

insert into storage.buckets (id, name, public)
values ('review-images', 'review-images', true)
on conflict (id) do nothing;

drop policy if exists "review_images_public_read" on storage.objects;
drop policy if exists "review_images_insert_own_folder" on storage.objects;

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
