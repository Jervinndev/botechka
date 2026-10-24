# Vue 3 + Vite

## Inventory Supabase setup

Run this SQL in the Supabase SQL Editor before using the new batch and image features:

```sql
create table if not exists public.medicine_batches (
	id uuid primary key default gen_random_uuid(),
	medicine_id uuid not null references public.medicines(id) on delete cascade,
	batch_number text not null,
	quantity integer not null check (quantity >= 0),
	supplier text,
	manufacturing_date date not null,
	expiration_date date not null,
	image_url text,
	status text not null default 'Available',
	created_at timestamptz not null default now()
);

create index if not exists medicine_batches_medicine_id_idx
	on public.medicine_batches(medicine_id);

insert into storage.buckets (id, name, public)
values ('medicine-images', 'medicine-images', true)
on conflict (id) do update set public = true;

drop policy if exists "Public medicine images are readable" on storage.objects;
create policy "Public medicine images are readable"
on storage.objects for select
using (bucket_id = 'medicine-images');

drop policy if exists "Authenticated users can upload medicine images" on storage.objects;
create policy "Authenticated users can upload medicine images"
on storage.objects for insert to authenticated
with check (bucket_id = 'medicine-images');
```

This template should help get you started developing with Vue 3 in Vite. The template uses Vue 3 `<script setup>` SFCs, check out the [script setup docs](https://v3.vuejs.org/api/sfc-script-setup.html#sfc-script-setup) to learn more.

Learn more about IDE Support for Vue in the [Vue Docs Scaling up Guide](https://vuejs.org/guide/scaling-up/tooling.html#ide-support).
