create table medicine_categories (
  category_id bigserial primary key,
  category_name varchar(100) not null,
  description text,
  status varchar(30) not null default 'Active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table medicine_categories enable row level security;

drop policy if exists "Allow read access for authenticated users on medicine_categories"
  on medicine_categories;
create policy "Allow read access for authenticated users on medicine_categories"
  on medicine_categories for select to authenticated using (public.is_current_user_not_super_admin());

drop policy if exists "Allow insert for authenticated users on medicine_categories"
  on medicine_categories;
create policy "Allow insert for authenticated users on medicine_categories"
  on medicine_categories for insert to authenticated with check (public.is_current_user_staff());

drop policy if exists "Allow update for authenticated users on medicine_categories"
  on medicine_categories;
create policy "Allow update for authenticated users on medicine_categories"
  on medicine_categories for update to authenticated
  using (public.is_current_user_staff())
  with check (public.is_current_user_staff());

drop policy if exists "Allow delete for authenticated users on medicine_categories"
  on medicine_categories;
create policy "Allow delete for authenticated users on medicine_categories"
  on medicine_categories for delete to authenticated using (public.is_current_user_staff());