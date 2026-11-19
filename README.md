# Vue 3 + Vite

## Inventory Supabase setup

After creating the medicines and suppliers tables, run [medicine_batches.sql](./medicine_batches.sql) in the Supabase SQL Editor. It creates the batch table, adds staff access policies and atomic stock functions, and backfills the existing medicine batch details.

For beneficiary dashboard links and dispensing dates, run [beneficiary_dashboard.sql](./beneficiary_dashboard.sql) after the `profiles` and `beneficiaries` tables exist. It adds a profile link (backfilled only for unique name-and-contact matches), a next dispensing date, and own-record access. Then rerun [distribution.sql](./distribution.sql) to add beneficiary history access and the atomic distribution-void function.

Run this SQL in the Supabase SQL Editor to configure medicine image storage:

```sql
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
