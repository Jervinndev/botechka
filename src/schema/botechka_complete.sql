-- BOTECHKA complete Supabase schema. Run in Supabase SQL Editor.

-- ===== profile.sql =====

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    fname TEXT NOT NULL DEFAULT '',
    mname TEXT DEFAULT '',
    lname TEXT NOT NULL DEFAULT '',
    contactnumber TEXT DEFAULT '',
    barangay TEXT DEFAULT '',
    email TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'beneficiary'
        CHECK (role IN ('super_admin', 'admin', 'personnel', 'beneficiary')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
CREATE POLICY "Users can view their own profile"
ON public.profiles
FOR SELECT
TO authenticated
USING (auth.uid() = id);

CREATE OR REPLACE FUNCTION public.is_current_user_super_admin()
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
SET row_security = off
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE id = (SELECT auth.uid())
          AND LOWER(role) = 'super_admin'
    );
$$;

REVOKE ALL ON FUNCTION public.is_current_user_super_admin() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_current_user_super_admin() TO authenticated;

CREATE OR REPLACE FUNCTION public.is_current_user_not_super_admin()
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
SET row_security = off
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE id = (SELECT auth.uid())
          AND LOWER(role) <> 'super_admin'
    );
$$;

REVOKE ALL ON FUNCTION public.is_current_user_not_super_admin() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_current_user_not_super_admin() TO authenticated;

CREATE OR REPLACE FUNCTION public.is_current_user_staff()
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
SET row_security = off
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE id = (SELECT auth.uid())
          AND LOWER(role) IN ('admin', 'personnel')
    );
$$;

REVOKE ALL ON FUNCTION public.is_current_user_staff() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_current_user_staff() TO authenticated;

CREATE OR REPLACE FUNCTION public.is_current_user_admin()
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public, pg_temp
SET row_security = off
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.profiles
        WHERE id = (SELECT auth.uid())
          AND LOWER(role) = 'admin'
    );
$$;

REVOKE ALL ON FUNCTION public.is_current_user_admin() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.is_current_user_admin() TO authenticated;

DROP POLICY IF EXISTS "Super admins can view all profiles" ON public.profiles;
CREATE POLICY "Super admins can view all profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (public.is_current_user_super_admin());

DROP POLICY IF EXISTS "Admins can view staff profiles" ON public.profiles;
CREATE POLICY "Admins can view staff profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (
    role IN ('admin', 'personnel')
    AND public.is_current_user_admin()
);

DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
CREATE POLICY "Users can update their own profile"
ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

REVOKE UPDATE (role) ON public.profiles FROM authenticated;

CREATE OR REPLACE FUNCTION public.prevent_unauthorized_profile_role_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    IF NEW.role IS DISTINCT FROM OLD.role AND auth.uid() IS NOT NULL THEN
        IF public.is_current_user_super_admin() THEN
            RETURN NEW;
        END IF;
        IF OLD.role = 'personnel'
           AND NEW.role IN ('personnel', 'beneficiary')
           AND public.is_current_user_admin() THEN
            RETURN NEW;
        END IF;
        RAISE EXCEPTION 'Only a super admin can assign administrator roles.';
    END IF;
    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.prevent_unauthorized_profile_role_change() FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.admin_update_personnel_role(p_user_id UUID, p_role TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    IF auth.uid() IS NULL OR NOT public.is_current_user_admin() THEN
        RAISE EXCEPTION 'Only an admin can manage personnel accounts.';
    END IF;
    IF p_user_id = auth.uid() OR p_role NOT IN ('personnel', 'beneficiary') THEN
        RAISE EXCEPTION 'Admins can only deactivate or retain personnel accounts.';
    END IF;

    UPDATE public.profiles
       SET role = p_role
     WHERE id = p_user_id
       AND role = 'personnel';
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Personnel account was not found or is no longer manageable.';
    END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_update_personnel_role(UUID, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.admin_update_personnel_role(UUID, TEXT) TO authenticated;

DROP TRIGGER IF EXISTS prevent_unauthorized_profile_role_change ON public.profiles;
CREATE TRIGGER prevent_unauthorized_profile_role_change
BEFORE UPDATE OF role ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.prevent_unauthorized_profile_role_change();

CREATE OR REPLACE FUNCTION public.create_profile_for_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        fname,
        mname,
        lname,
        contactnumber,
        barangay,
        email,
        role
    )
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data ->> 'fname', ''),
        COALESCE(NEW.raw_user_meta_data ->> 'mname', ''),
        COALESCE(NEW.raw_user_meta_data ->> 'lname', ''),
        COALESCE(NEW.raw_user_meta_data ->> 'contactnumber', ''),
        COALESCE(NEW.raw_user_meta_data ->> 'barangay', ''),
        COALESCE(NEW.email, ''),
        'beneficiary'
    )
    ON CONFLICT (id) DO NOTHING;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.create_profile_for_new_user();

INSERT INTO public.profiles (id, fname, mname, lname, contactnumber, barangay, email, role)
SELECT
    users.id,
    COALESCE(users.raw_user_meta_data ->> 'fname', ''),
    COALESCE(users.raw_user_meta_data ->> 'mname', ''),
    COALESCE(users.raw_user_meta_data ->> 'lname', ''),
    COALESCE(users.raw_user_meta_data ->> 'contactnumber', ''),
    COALESCE(users.raw_user_meta_data ->> 'barangay', ''),
    COALESCE(users.email, ''),
    'beneficiary'
FROM auth.users AS users
ON CONFLICT (id) DO NOTHING;


-- ===== categorymedicines.sql =====

create table if not exists public.medicine_categories (
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

-- ===== supplier_settings.sql =====

CREATE TABLE IF NOT EXISTS public.suppliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_code TEXT NOT NULL UNIQUE,
    company_name TEXT NOT NULL,
    contact_person TEXT,
    contact_number TEXT,
    email TEXT,
    location TEXT,
    supplier_type TEXT NOT NULL DEFAULT 'Private',
    archived_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Staff can manage suppliers" ON public.suppliers;
CREATE POLICY "Staff can manage suppliers"
ON public.suppliers
FOR ALL TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = (SELECT auth.uid())
          AND LOWER(role) IN ('admin', 'personnel')
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = (SELECT auth.uid())
          AND LOWER(role) IN ('admin', 'personnel')
    )
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.suppliers TO authenticated;


-- ===== medicines.sql =====

-- UUID generator
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Medicines table
CREATE TABLE IF NOT EXISTS public.medicines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    medicine_id TEXT UNIQUE NOT NULL,
    medicine_name TEXT NOT NULL,
    category TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    price NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (price >= 0),
    restock_level INTEGER NOT NULL DEFAULT 10 CHECK (restock_level >= 0),
    dosage TEXT NOT NULL,
    unit TEXT NOT NULL,
    batch_number TEXT NOT NULL,
    supplier TEXT NOT NULL,
    manufacturing_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.medicines
    ADD COLUMN IF NOT EXISTS price NUMERIC(10,2) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS restock_level INTEGER NOT NULL DEFAULT 10;

ALTER TABLE public.medicines
    DROP CONSTRAINT IF EXISTS medicines_price_check,
    ADD CONSTRAINT medicines_price_check CHECK (price >= 0),
    DROP CONSTRAINT IF EXISTS medicines_restock_level_check,
    ADD CONSTRAINT medicines_restock_level_check CHECK (restock_level >= 0);

-- Kung mayroon nang medicines table na wala pang image_url
ALTER TABLE public.medicines
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Enable Row Level Security
ALTER TABLE public.medicines ENABLE ROW LEVEL SECURITY;

-- Medicine table policies
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.medicines;
CREATE POLICY "Enable insert for authenticated users"
ON public.medicines
FOR INSERT TO authenticated
WITH CHECK (public.is_current_user_staff());

DROP POLICY IF EXISTS "Enable read for authenticated users" ON public.medicines;
CREATE POLICY "Enable read for authenticated users"
ON public.medicines
FOR SELECT TO authenticated
USING (public.is_current_user_not_super_admin());

DROP POLICY IF EXISTS "Enable update for authenticated users" ON public.medicines;
CREATE POLICY "Enable update for authenticated users"
ON public.medicines
FOR UPDATE TO authenticated
USING (public.is_current_user_staff())
WITH CHECK (public.is_current_user_staff());

-- Storage bucket for medicine images (max 2 MB; JPG, PNG, WebP)
INSERT INTO storage.buckets (
    id,
    name,
    public,
    file_size_limit,
    allowed_mime_types
)
VALUES (
    'medicine-images',
    'medicine-images',
    true,
    2097152,
    ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Allow signed-in users to upload images
DROP POLICY IF EXISTS "Authenticated users can upload medicine images" ON storage.objects;
CREATE POLICY "Authenticated users can upload medicine images"
ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
    bucket_id = 'medicine-images'
    AND public.is_current_user_staff()
);

-- Allow signed-in users to delete images if medicine saving fails
DROP POLICY IF EXISTS "Authenticated users can delete medicine images" ON storage.objects;
CREATE POLICY "Authenticated users can delete medicine images"
ON storage.objects
FOR DELETE TO authenticated
USING (
    bucket_id = 'medicine-images'
    AND public.is_current_user_staff()
);

-- ===== beneficiaries.sql =====

CREATE TABLE IF NOT EXISTS public.beneficiaries (
    beneficiary_id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    beneficiary_code TEXT NOT NULL UNIQUE,
    beneficiary_type TEXT NOT NULL DEFAULT 'Regular',
    first_name TEXT NOT NULL,
    middle_name TEXT,
    last_name TEXT NOT NULL,
    suffix TEXT,
    birth_date DATE,
    sex TEXT,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    eligibility TEXT NOT NULL DEFAULT 'Pending',
    next_dispensing_date DATE,
    contact_number TEXT,
    address TEXT,
    barangay TEXT,
    status TEXT NOT NULL DEFAULT 'Active',
    profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    archived_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.beneficiaries
    ADD COLUMN IF NOT EXISTS profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS next_dispensing_date DATE,
    ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;

CREATE UNIQUE INDEX IF NOT EXISTS beneficiaries_profile_id_unique
    ON public.beneficiaries (profile_id)
    WHERE profile_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS beneficiaries_name_idx
    ON public.beneficiaries (LOWER(last_name), LOWER(first_name));

ALTER TABLE public.beneficiaries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Staff can view beneficiaries" ON public.beneficiaries;
CREATE POLICY "Staff can view beneficiaries"
    ON public.beneficiaries
    FOR SELECT TO authenticated
    USING (public.is_current_user_staff());

DROP POLICY IF EXISTS "Staff can create beneficiaries" ON public.beneficiaries;
CREATE POLICY "Staff can create beneficiaries"
    ON public.beneficiaries
    FOR INSERT TO authenticated
    WITH CHECK (public.is_current_user_staff());

DROP POLICY IF EXISTS "Staff can update beneficiaries" ON public.beneficiaries;
CREATE POLICY "Staff can update beneficiaries"
    ON public.beneficiaries
    FOR UPDATE TO authenticated
    USING (public.is_current_user_staff())
    WITH CHECK (public.is_current_user_staff());

DROP POLICY IF EXISTS "Beneficiaries can view own linked record" ON public.beneficiaries;
CREATE POLICY "Beneficiaries can view own linked record"
    ON public.beneficiaries
    FOR SELECT TO authenticated
    USING (
        profile_id = (SELECT auth.uid())
        AND EXISTS (
            SELECT 1 FROM public.profiles AS profile
             WHERE profile.id = (SELECT auth.uid())
               AND LOWER(profile.role) = 'beneficiary'
        )
    );

GRANT SELECT, INSERT, UPDATE ON public.beneficiaries TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.beneficiaries_beneficiary_id_seq TO authenticated;

DROP FUNCTION IF EXISTS public.get_beneficiary_count();
CREATE OR REPLACE FUNCTION public.get_beneficiary_count()
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
          FROM public.beneficiaries
         WHERE archived_at IS NULL
    );
END;
$$;

REVOKE ALL ON FUNCTION public.get_beneficiary_count() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_beneficiary_count() TO anon, authenticated;


-- ===== beneficiary_dashboard.sql =====

ALTER TABLE public.beneficiaries
    ADD COLUMN IF NOT EXISTS profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS next_dispensing_date DATE;

CREATE UNIQUE INDEX IF NOT EXISTS beneficiaries_profile_id_unique
    ON public.beneficiaries (profile_id)
    WHERE profile_id IS NOT NULL;

WITH matches AS (
    SELECT
        beneficiary.beneficiary_id,
        profile.id AS profile_id,
        COUNT(*) OVER (PARTITION BY beneficiary.beneficiary_id) AS beneficiary_match_count,
        COUNT(*) OVER (PARTITION BY profile.id) AS profile_match_count
    FROM public.beneficiaries AS beneficiary
    JOIN public.profiles AS profile
      ON LOWER(BTRIM(beneficiary.first_name)) = LOWER(BTRIM(profile.fname))
     AND LOWER(BTRIM(beneficiary.last_name)) = LOWER(BTRIM(profile.lname))
     AND NULLIF(REGEXP_REPLACE(COALESCE(beneficiary.contact_number, ''), '[^0-9]', '', 'g'), '') IS NOT NULL
     AND REGEXP_REPLACE(beneficiary.contact_number, '[^0-9]', '', 'g') =
         REGEXP_REPLACE(COALESCE(profile.contactnumber, ''), '[^0-9]', '', 'g')
    WHERE beneficiary.profile_id IS NULL
      AND LOWER(profile.role) = 'beneficiary'
      AND NOT EXISTS (
          SELECT 1
            FROM public.beneficiaries AS linked
           WHERE linked.profile_id = profile.id
      )
)
UPDATE public.beneficiaries AS beneficiary
   SET profile_id = matches.profile_id
  FROM matches
 WHERE beneficiary.beneficiary_id = matches.beneficiary_id
   AND matches.beneficiary_match_count = 1
   AND matches.profile_match_count = 1;

CREATE OR REPLACE FUNCTION public.link_beneficiary_profile_from_record()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_profile_id UUID;
    v_match_count INTEGER;
BEGIN
    IF NEW.profile_id IS NOT NULL OR NULLIF(REGEXP_REPLACE(COALESCE(NEW.contact_number, ''), '[^0-9]', '', 'g'), '') IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT COUNT(*), (ARRAY_AGG(profile.id))[1]
      INTO v_match_count, v_profile_id
      FROM public.profiles AS profile
     WHERE LOWER(profile.role) = 'beneficiary'
       AND LOWER(BTRIM(profile.fname)) = LOWER(BTRIM(NEW.first_name))
       AND LOWER(BTRIM(profile.lname)) = LOWER(BTRIM(NEW.last_name))
       AND REGEXP_REPLACE(COALESCE(profile.contactnumber, ''), '[^0-9]', '', 'g') =
           REGEXP_REPLACE(NEW.contact_number, '[^0-9]', '', 'g')
       AND NOT EXISTS (
           SELECT 1
             FROM public.beneficiaries AS linked
            WHERE linked.profile_id = profile.id
              AND linked.beneficiary_id IS DISTINCT FROM NEW.beneficiary_id
       );

    IF v_match_count = 1 THEN
        NEW.profile_id := v_profile_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.link_beneficiary_profile_from_account()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_beneficiary_id BIGINT;
    v_match_count INTEGER;
BEGIN
    IF LOWER(NEW.role) <> 'beneficiary'
       OR NULLIF(REGEXP_REPLACE(COALESCE(NEW.contactnumber, ''), '[^0-9]', '', 'g'), '') IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT COUNT(*), (ARRAY_AGG(beneficiary.beneficiary_id))[1]
      INTO v_match_count, v_beneficiary_id
      FROM public.beneficiaries AS beneficiary
     WHERE beneficiary.profile_id IS NULL
       AND LOWER(BTRIM(beneficiary.first_name)) = LOWER(BTRIM(NEW.fname))
       AND LOWER(BTRIM(beneficiary.last_name)) = LOWER(BTRIM(NEW.lname))
       AND REGEXP_REPLACE(COALESCE(beneficiary.contact_number, ''), '[^0-9]', '', 'g') =
           REGEXP_REPLACE(NEW.contactnumber, '[^0-9]', '', 'g')
       AND (
           SELECT COUNT(*)
             FROM public.profiles AS matching_profile
            WHERE LOWER(matching_profile.role) = 'beneficiary'
              AND LOWER(BTRIM(matching_profile.fname)) = LOWER(BTRIM(NEW.fname))
              AND LOWER(BTRIM(matching_profile.lname)) = LOWER(BTRIM(NEW.lname))
              AND REGEXP_REPLACE(COALESCE(matching_profile.contactnumber, ''), '[^0-9]', '', 'g') =
                  REGEXP_REPLACE(NEW.contactnumber, '[^0-9]', '', 'g')
       ) = 1;

    IF v_match_count = 1 THEN
        UPDATE public.beneficiaries
           SET profile_id = NEW.id
         WHERE beneficiary_id = v_beneficiary_id
           AND profile_id IS NULL;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS link_beneficiary_profile_from_record ON public.beneficiaries;
CREATE TRIGGER link_beneficiary_profile_from_record
BEFORE INSERT OR UPDATE OF first_name, last_name, contact_number ON public.beneficiaries
FOR EACH ROW
EXECUTE FUNCTION public.link_beneficiary_profile_from_record();

DROP TRIGGER IF EXISTS link_beneficiary_profile_from_account ON public.profiles;
CREATE TRIGGER link_beneficiary_profile_from_account
AFTER INSERT ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.link_beneficiary_profile_from_account();

REVOKE ALL ON FUNCTION public.link_beneficiary_profile_from_record() FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.link_beneficiary_profile_from_account() FROM PUBLIC, anon, authenticated;

DROP POLICY IF EXISTS "Beneficiaries can view own linked record" ON public.beneficiaries;
CREATE POLICY "Beneficiaries can view own linked record"
    ON public.beneficiaries
    FOR SELECT TO authenticated
    USING (
        profile_id = (SELECT auth.uid())
        AND EXISTS (
            SELECT 1
              FROM public.profiles AS profile
             WHERE profile.id = (SELECT auth.uid())
               AND LOWER(profile.role) = 'beneficiary'
        )
    );


-- ===== distribution.sql =====

CREATE TABLE IF NOT EXISTS public.distribution_purposes (
    purpose_id BIGSERIAL PRIMARY KEY,
    purpose_name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS distribution_purposes_name_ci_unique
    ON public.distribution_purposes (LOWER(purpose_name));

INSERT INTO public.distribution_purposes (purpose_name, description)
VALUES
    ('Fever', 'Medicine for fever symptoms'),
    ('Cough and colds', 'Medicine for cough or cold symptoms'),
    ('Pain relief', 'Medicine for pain or discomfort'),
    ('Hypertension', 'Medicine for blood pressure management'),
    ('Diabetes', 'Medicine for blood sugar management'),
    ('Vitamin supplementation', 'Vitamins and nutritional supplements'),
    ('Other', 'Other medical purpose')
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS public.distribution_transactions (
    distribution_transaction_id BIGSERIAL PRIMARY KEY,
    beneficiary_id BIGINT NOT NULL
        REFERENCES public.beneficiaries(beneficiary_id) ON DELETE RESTRICT,
    user_id UUID NOT NULL
        REFERENCES public.profiles(id) ON DELETE RESTRICT,
    distribution_date TIMESTAMPTZ NOT NULL,
    purpose TEXT NOT NULL,
    remarks TEXT,
    created_by UUID NOT NULL
        REFERENCES public.profiles(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by UUID
        REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.distribution_transactions
    ADD COLUMN IF NOT EXISTS returned_at TIMESTAMPTZ;

ALTER TABLE public.distribution_transactions
    ADD COLUMN IF NOT EXISTS voided_at TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS public.distribution_items (
    distribution_item_id BIGSERIAL PRIMARY KEY,
    distribution_transaction_id BIGINT NOT NULL
        REFERENCES public.distribution_transactions(distribution_transaction_id) ON DELETE CASCADE,
    medicine_id UUID NOT NULL
        REFERENCES public.medicines(id) ON DELETE RESTRICT,
    medicine_name TEXT NOT NULL,
    medicine_image_url TEXT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (distribution_transaction_id, medicine_id)
);

CREATE INDEX IF NOT EXISTS distribution_transactions_beneficiary_idx
    ON public.distribution_transactions (beneficiary_id);

CREATE INDEX IF NOT EXISTS distribution_transactions_date_idx
    ON public.distribution_transactions (distribution_date DESC);

CREATE INDEX IF NOT EXISTS distribution_items_transaction_idx
    ON public.distribution_items (distribution_transaction_id);

ALTER TABLE public.distribution_purposes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.distribution_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.distribution_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Staff can view distribution purposes"
    ON public.distribution_purposes;
DROP POLICY IF EXISTS "Authenticated users can view distribution purposes"
    ON public.distribution_purposes;
CREATE POLICY "Authenticated users can view distribution purposes"
    ON public.distribution_purposes
    FOR SELECT TO authenticated
    USING (public.is_current_user_not_super_admin());

DROP POLICY IF EXISTS "Staff can add distribution purposes"
    ON public.distribution_purposes;
CREATE POLICY "Staff can add distribution purposes"
    ON public.distribution_purposes
    FOR INSERT TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.profiles AS profile
            WHERE profile.id = (SELECT auth.uid())
              AND LOWER(profile.role) IN ('personnel', 'admin')
        )
    );

DROP POLICY IF EXISTS "Staff can view distribution transactions"
    ON public.distribution_transactions;
CREATE POLICY "Staff can view distribution transactions"
    ON public.distribution_transactions
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM public.profiles AS profile
            WHERE profile.id = (SELECT auth.uid())
              AND LOWER(profile.role) IN ('personnel', 'admin')
        )
        OR EXISTS (
            SELECT 1
              FROM public.beneficiaries AS beneficiary
              JOIN public.profiles AS profile
                ON profile.id = (SELECT auth.uid())
             WHERE beneficiary.beneficiary_id = distribution_transactions.beneficiary_id
               AND beneficiary.profile_id = profile.id
               AND LOWER(profile.role) = 'beneficiary'
        )
    );

DROP POLICY IF EXISTS "Staff can view distribution items"
    ON public.distribution_items;
CREATE POLICY "Staff can view distribution items"
    ON public.distribution_items
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM public.distribution_transactions AS dist
            JOIN public.profiles AS profile
              ON profile.id = (SELECT auth.uid())
            WHERE dist.distribution_transaction_id =
                    distribution_items.distribution_transaction_id
              AND LOWER(profile.role) IN ('personnel', 'admin')
        )
        OR EXISTS (
            SELECT 1
              FROM public.distribution_transactions AS dist
              JOIN public.beneficiaries AS beneficiary
                ON beneficiary.beneficiary_id = dist.beneficiary_id
              JOIN public.profiles AS profile
                ON profile.id = (SELECT auth.uid())
             WHERE dist.distribution_transaction_id =
                    distribution_items.distribution_transaction_id
               AND beneficiary.profile_id = profile.id
               AND LOWER(profile.role) = 'beneficiary'
        )
    );

GRANT SELECT, INSERT ON public.distribution_purposes TO authenticated;
GRANT SELECT ON public.distribution_transactions TO authenticated;
GRANT SELECT ON public.distribution_items TO authenticated;
GRANT INSERT, UPDATE ON public.distribution_transactions TO authenticated;
GRANT INSERT, UPDATE ON public.distribution_items TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.distribution_transactions_distribution_transaction_id_seq TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.distribution_items_distribution_item_id_seq TO authenticated;

DROP POLICY IF EXISTS "Staff can restore distribution transactions" ON public.distribution_transactions;
CREATE POLICY "Staff can restore distribution transactions"
    ON public.distribution_transactions
    FOR ALL TO authenticated
    USING (public.is_current_user_staff())
    WITH CHECK (public.is_current_user_staff());

DROP POLICY IF EXISTS "Staff can restore distribution items" ON public.distribution_items;
CREATE POLICY "Staff can restore distribution items"
    ON public.distribution_items
    FOR ALL TO authenticated
    USING (public.is_current_user_staff())
    WITH CHECK (public.is_current_user_staff());
GRANT USAGE, SELECT ON SEQUENCE public.distribution_purposes_purpose_id_seq TO authenticated;

CREATE OR REPLACE FUNCTION public.dispense_distribution(
    p_beneficiary_id BIGINT,
    p_distribution_date TIMESTAMPTZ,
    p_purpose TEXT,
    p_items JSONB,
    p_remarks TEXT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_role TEXT;
    v_transaction_id BIGINT;
    v_item_count INTEGER;
    v_locked_count INTEGER := 0;
    v_item RECORD;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication is required to dispense medicines.';
    END IF;

    SELECT LOWER(profile.role)
      INTO v_role
      FROM public.profiles AS profile
     WHERE profile.id = v_user_id;

    IF v_role IS NULL OR v_role NOT IN ('personnel', 'admin') THEN
        RAISE EXCEPTION 'You are not authorized to dispense medicines.';
    END IF;

    IF p_beneficiary_id IS NULL OR p_distribution_date IS NULL
       OR NULLIF(BTRIM(p_purpose), '') IS NULL THEN
        RAISE EXCEPTION 'Beneficiary, distribution date, and purpose are required.';
    END IF;

    IF p_items IS NULL OR jsonb_typeof(p_items) <> 'array' THEN
        RAISE EXCEPTION 'At least one medicine is required.';
    END IF;

    IF jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'At least one medicine is required.';
    END IF;

    SELECT COUNT(*)
      INTO v_item_count
      FROM jsonb_to_recordset(p_items) AS item(medicine_id UUID, quantity INTEGER);

    IF EXISTS (
        SELECT 1
          FROM jsonb_to_recordset(p_items) AS item(medicine_id UUID, quantity INTEGER)
         WHERE item.medicine_id IS NULL OR item.quantity IS NULL OR item.quantity < 1
    ) THEN
        RAISE EXCEPTION 'Medicine IDs and positive integer quantities are required.';
    END IF;

    IF v_item_count <> (
        SELECT COUNT(DISTINCT item.medicine_id)
          FROM jsonb_to_recordset(p_items) AS item(medicine_id UUID, quantity INTEGER)
    ) THEN
        RAISE EXCEPTION 'A medicine may only appear once in a distribution.';
    END IF;

    INSERT INTO public.distribution_transactions (
        beneficiary_id,
        user_id,
        distribution_date,
        purpose,
        remarks,
        created_by
    )
    VALUES (
        p_beneficiary_id,
        v_user_id,
        p_distribution_date,
        BTRIM(p_purpose),
        p_remarks,
        v_user_id
    )
    RETURNING distribution_transaction_id INTO v_transaction_id;

    FOR v_item IN
        SELECT medicine.id,
               medicine.medicine_name,
               medicine.image_url,
               medicine.unit,
               medicine.quantity AS current_stock,
               requested.quantity AS requested_quantity
          FROM jsonb_to_recordset(p_items) AS requested(medicine_id UUID, quantity INTEGER)
          JOIN public.medicines AS medicine ON medicine.id = requested.medicine_id
         ORDER BY medicine.id
         FOR UPDATE OF medicine
    LOOP
        v_locked_count := v_locked_count + 1;

        IF v_item.current_stock IS NULL OR v_item.current_stock < v_item.requested_quantity THEN
            RAISE EXCEPTION
                'Insufficient Quantity: The quantity entered (%) exceeds the available stock for this medicine (%). Current stock: %.',
                v_item.requested_quantity,
                v_item.medicine_name,
                COALESCE(v_item.current_stock, 0);
        END IF;

        UPDATE public.medicines
           SET quantity = quantity - v_item.requested_quantity
         WHERE id = v_item.id;

        INSERT INTO public.distribution_items (
            distribution_transaction_id,
            medicine_id,
            medicine_name,
            medicine_image_url,
            quantity,
            unit
        )
        VALUES (
            v_transaction_id,
            v_item.id,
            v_item.medicine_name,
            v_item.image_url,
            v_item.requested_quantity,
            v_item.unit
        );
    END LOOP;

    IF v_locked_count <> v_item_count THEN
        RAISE EXCEPTION 'One or more selected medicines no longer exist in inventory.';
    END IF;

    RETURN v_transaction_id;
END;
$$;

REVOKE ALL ON FUNCTION public.dispense_distribution(BIGINT, TIMESTAMPTZ, TEXT, JSONB, TEXT)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.dispense_distribution(BIGINT, TIMESTAMPTZ, TEXT, JSONB, TEXT)
    TO authenticated;

CREATE OR REPLACE FUNCTION public.return_distribution_transaction(
    p_distribution_transaction_id BIGINT
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_role TEXT;
    v_returned_at TIMESTAMPTZ;
    v_voided_at TIMESTAMPTZ;
    v_transaction_id BIGINT;
    v_item RECORD;
    v_returned_count INTEGER := 0;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication is required to return medicines.';
    END IF;

    SELECT LOWER(profile.role)
      INTO v_role
      FROM public.profiles AS profile
     WHERE profile.id = v_user_id;

    IF v_role IS NULL OR v_role NOT IN ('personnel', 'admin') THEN
        RAISE EXCEPTION 'You are not authorized to return medicines.';
    END IF;

    SELECT distribution_transaction_id, returned_at, voided_at
      INTO v_transaction_id, v_returned_at, v_voided_at
      FROM public.distribution_transactions
     WHERE distribution_transaction_id = p_distribution_transaction_id
     FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Distribution transaction was not found.';
    END IF;

    IF v_returned_at IS NOT NULL THEN
        RAISE EXCEPTION 'Medicines in this distribution have already been returned.';
    END IF;

    IF v_voided_at IS NOT NULL THEN
        RAISE EXCEPTION 'This distribution has already been voided.';
    END IF;

    FOR v_item IN
        SELECT medicine.id, distribution_item.quantity
          FROM public.distribution_items AS distribution_item
          JOIN public.medicines AS medicine
            ON medicine.id = distribution_item.medicine_id
         WHERE distribution_item.distribution_transaction_id = v_transaction_id
         ORDER BY medicine.id
         FOR UPDATE OF medicine
    LOOP
        UPDATE public.medicines
           SET quantity = quantity + v_item.quantity
         WHERE id = v_item.id;

        v_returned_count := v_returned_count + 1;
    END LOOP;

    IF v_returned_count = 0 THEN
        RAISE EXCEPTION 'This distribution has no medicines to return.';
    END IF;

    UPDATE public.distribution_transactions
       SET returned_at = NOW(),
           updated_by = v_user_id,
           updated_at = NOW()
     WHERE distribution_transaction_id = v_transaction_id;

    RETURN v_transaction_id;
END;
$$;

REVOKE ALL ON FUNCTION public.return_distribution_transaction(BIGINT)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.return_distribution_transaction(BIGINT)
    TO authenticated;

CREATE OR REPLACE FUNCTION public.void_distribution_transaction(
    p_distribution_transaction_id BIGINT
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_role TEXT;
    v_returned_at TIMESTAMPTZ;
    v_voided_at TIMESTAMPTZ;
    v_transaction_id BIGINT;
    v_item RECORD;
    v_restored_count INTEGER := 0;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication is required to void a distribution.';
    END IF;

    SELECT LOWER(profile.role)
      INTO v_role
      FROM public.profiles AS profile
     WHERE profile.id = v_user_id;

    IF v_role IS NULL OR v_role NOT IN ('personnel', 'admin') THEN
        RAISE EXCEPTION 'You are not authorized to void distributions.';
    END IF;

    SELECT distribution_transaction_id, returned_at, voided_at
      INTO v_transaction_id, v_returned_at, v_voided_at
      FROM public.distribution_transactions
     WHERE distribution_transaction_id = p_distribution_transaction_id
     FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Distribution transaction was not found.';
    END IF;

    IF v_returned_at IS NOT NULL THEN
        RAISE EXCEPTION 'A returned distribution cannot be voided.';
    END IF;

    IF v_voided_at IS NOT NULL THEN
        RAISE EXCEPTION 'This distribution has already been voided.';
    END IF;

    FOR v_item IN
        SELECT medicine.id, distribution_item.quantity
          FROM public.distribution_items AS distribution_item
          JOIN public.medicines AS medicine
            ON medicine.id = distribution_item.medicine_id
         WHERE distribution_item.distribution_transaction_id = v_transaction_id
         ORDER BY medicine.id
         FOR UPDATE OF medicine
    LOOP
        UPDATE public.medicines
           SET quantity = quantity + v_item.quantity
         WHERE id = v_item.id;

        v_restored_count := v_restored_count + 1;
    END LOOP;

    IF v_restored_count = 0 THEN
        RAISE EXCEPTION 'This distribution has no medicines to restore.';
    END IF;

    UPDATE public.distribution_transactions
       SET voided_at = NOW(),
           updated_by = v_user_id,
           updated_at = NOW()
     WHERE distribution_transaction_id = v_transaction_id;

    RETURN v_transaction_id;
END;
$$;

REVOKE ALL ON FUNCTION public.void_distribution_transaction(BIGINT)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.void_distribution_transaction(BIGINT)
    TO authenticated;


-- ===== beneficiary_requests.sql =====

CREATE TABLE IF NOT EXISTS public.medicine_requests (
    request_id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    requester_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    beneficiary_name TEXT NOT NULL,
    beneficiary_type TEXT NOT NULL,
    medicine_id UUID NOT NULL REFERENCES public.medicines(id) ON DELETE RESTRICT,
    medicine_name TEXT NOT NULL,
    medicine_dosage TEXT,
    medicine_unit TEXT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    purpose TEXT,
    prescription_path TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
    rejection_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reviewed_at TIMESTAMPTZ,
    reviewed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS medicine_requests_requester_created_idx
    ON public.medicine_requests (requester_id, created_at DESC);
CREATE INDEX IF NOT EXISTS medicine_requests_status_created_idx
    ON public.medicine_requests (status, created_at DESC);

ALTER TABLE public.medicine_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Beneficiaries and staff can view medicine requests"
    ON public.medicine_requests;
CREATE POLICY "Beneficiaries and staff can view medicine requests"
    ON public.medicine_requests
    FOR SELECT TO authenticated
    USING (
        requester_id = (SELECT auth.uid())
        OR EXISTS (
            SELECT 1
            FROM public.profiles AS profile
            WHERE profile.id = (SELECT auth.uid())
              AND LOWER(profile.role) IN ('personnel', 'admin')
        )
    );

DROP POLICY IF EXISTS "Staff can update medicine requests"
    ON public.medicine_requests;
CREATE POLICY "Staff can update medicine requests"
    ON public.medicine_requests
    FOR UPDATE TO authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM public.profiles AS profile
            WHERE profile.id = (SELECT auth.uid())
              AND LOWER(profile.role) IN ('personnel', 'admin')
        )
        AND status = 'pending'
    )
    WITH CHECK (
        status IN ('approved', 'rejected')
        AND reviewed_by = (SELECT auth.uid())
        AND EXISTS (
            SELECT 1
            FROM public.profiles AS profile
            WHERE profile.id = (SELECT auth.uid())
              AND LOWER(profile.role) IN ('personnel', 'admin')
        )
    );

GRANT SELECT, INSERT, UPDATE ON public.medicine_requests TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.medicine_requests_request_id_seq TO authenticated;

DROP POLICY IF EXISTS "Staff can restore medicine requests" ON public.medicine_requests;
CREATE POLICY "Staff can restore medicine requests"
    ON public.medicine_requests
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM public.profiles AS profile
            WHERE profile.id = (SELECT auth.uid())
              AND LOWER(profile.role) IN ('personnel', 'admin')
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.profiles AS profile
            WHERE profile.id = (SELECT auth.uid())
              AND LOWER(profile.role) IN ('personnel', 'admin')
        )
    );

CREATE OR REPLACE FUNCTION public.submit_medicine_request(
    p_medicine_id UUID,
    p_quantity INTEGER,
    p_purpose TEXT,
    p_beneficiary_type TEXT,
    p_prescription_path TEXT
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_profile RECORD;
    v_medicine RECORD;
    v_request_id BIGINT;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'You must be signed in to submit a medicine request.';
    END IF;

    SELECT profile.fname, profile.mname, profile.lname, LOWER(profile.role) AS role
      INTO v_profile
      FROM public.profiles AS profile
     WHERE profile.id = v_user_id;

    IF v_profile.role IS DISTINCT FROM 'beneficiary' THEN
        RAISE EXCEPTION 'Only beneficiary accounts can submit medicine requests.';
    END IF;

    IF p_quantity IS NULL OR p_quantity < 1 THEN
        RAISE EXCEPTION 'Request quantity must be at least one.';
    END IF;

    IF p_beneficiary_type IS NULL
       OR p_beneficiary_type NOT IN ('Senior Citizen', 'PWD', 'General') THEN
        RAISE EXCEPTION 'Choose a valid beneficiary type.';
    END IF;

    IF p_prescription_path IS NULL
       OR split_part(p_prescription_path, '/', 1) <> v_user_id::TEXT
       OR p_prescription_path LIKE '%..%'
       OR NOT EXISTS (
            SELECT 1
            FROM storage.objects AS object
            WHERE object.bucket_id = 'medicine-prescriptions'
              AND object.name = p_prescription_path
       ) THEN
        RAISE EXCEPTION 'Upload a valid prescription before submitting.';
    END IF;

    SELECT medicine.id, medicine.medicine_name, medicine.dosage, medicine.unit
      INTO v_medicine
      FROM public.medicines AS medicine
     WHERE medicine.id = p_medicine_id
       AND COALESCE(medicine.quantity, 0) > 0;

    IF v_medicine.id IS NULL THEN
        RAISE EXCEPTION 'The selected medicine is unavailable.';
    END IF;

    IF NULLIF(BTRIM(CONCAT_WS(' ', v_profile.fname, v_profile.mname, v_profile.lname)), '') IS NULL THEN
        RAISE EXCEPTION 'Your profile must include your name before submitting a request.';
    END IF;

    INSERT INTO public.medicine_requests (
        requester_id,
        beneficiary_name,
        beneficiary_type,
        medicine_id,
        medicine_name,
        medicine_dosage,
        medicine_unit,
        quantity,
        purpose,
        prescription_path
    )
    VALUES (
        v_user_id,
        BTRIM(CONCAT_WS(' ', v_profile.fname, v_profile.mname, v_profile.lname)),
        p_beneficiary_type,
        v_medicine.id,
        v_medicine.medicine_name,
        v_medicine.dosage,
        v_medicine.unit,
        p_quantity,
        NULLIF(BTRIM(p_purpose), ''),
        p_prescription_path
    )
    RETURNING request_id INTO v_request_id;

    RETURN v_request_id;
END;
$$;

REVOKE ALL ON FUNCTION public.submit_medicine_request(UUID, INTEGER, TEXT, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_medicine_request(UUID, INTEGER, TEXT, TEXT, TEXT) TO authenticated;

CREATE OR REPLACE FUNCTION public.cancel_medicine_request(p_request_id BIGINT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID := auth.uid();
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'You must be signed in to cancel a medicine request.';
    END IF;

    UPDATE public.medicine_requests
       SET status = 'cancelled'
     WHERE request_id = p_request_id
       AND requester_id = v_user_id
       AND status = 'pending';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'This request cannot be cancelled.';
    END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.cancel_medicine_request(BIGINT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.cancel_medicine_request(BIGINT) TO authenticated;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'medicine-prescriptions',
    'medicine-prescriptions',
    FALSE,
    5242880,
    ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE
SET public = FALSE,
    file_size_limit = 5242880,
    allowed_mime_types = ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/webp'];

DROP POLICY IF EXISTS "Users can upload their own prescriptions"
    ON storage.objects;
CREATE POLICY "Users can upload their own prescriptions"
    ON storage.objects
    FOR INSERT TO authenticated
    WITH CHECK (
        bucket_id = 'medicine-prescriptions'
        AND public.is_current_user_not_super_admin()
        AND (storage.foldername(name))[1] = (SELECT auth.uid())::TEXT
    );

DROP POLICY IF EXISTS "Owners and staff can view prescriptions"
    ON storage.objects;
CREATE POLICY "Owners and staff can view prescriptions"
    ON storage.objects
    FOR SELECT TO authenticated
    USING (
        bucket_id = 'medicine-prescriptions'
        AND public.is_current_user_not_super_admin()
        AND (
            (storage.foldername(name))[1] = (SELECT auth.uid())::TEXT
            OR EXISTS (
                SELECT 1
                FROM public.profiles AS profile
                WHERE profile.id = (SELECT auth.uid())
                  AND LOWER(profile.role) IN ('personnel', 'admin')
            )
        )
    );

DROP POLICY IF EXISTS "Owners can remove unlinked prescriptions"
    ON storage.objects;
CREATE POLICY "Owners can remove unlinked prescriptions"
    ON storage.objects
    FOR DELETE TO authenticated
    USING (
        bucket_id = 'medicine-prescriptions'
        AND public.is_current_user_not_super_admin()
        AND (storage.foldername(name))[1] = (SELECT auth.uid())::TEXT
        AND NOT EXISTS (
            SELECT 1
            FROM public.medicine_requests AS request
            WHERE request.prescription_path = storage.objects.name
        )
    );


-- ===== medicine_batches.sql =====

CREATE TABLE IF NOT EXISTS public.medicine_batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    medicine_id UUID NOT NULL REFERENCES public.medicines(id) ON DELETE CASCADE,
    batch_number TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    supplier TEXT,
    manufacturing_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    image_url TEXT,
    status TEXT NOT NULL DEFAULT 'Available',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS medicine_batches_medicine_id_idx
    ON public.medicine_batches(medicine_id);

ALTER TABLE public.medicine_batches ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated users can read medicine batches" ON public.medicine_batches;
CREATE POLICY "Authenticated users can read medicine batches"
ON public.medicine_batches
FOR SELECT TO authenticated
USING (public.is_current_user_not_super_admin());

DROP POLICY IF EXISTS "Staff can insert medicine batches" ON public.medicine_batches;
CREATE POLICY "Staff can insert medicine batches"
ON public.medicine_batches
FOR INSERT TO authenticated
WITH CHECK (public.is_current_user_staff());

DROP POLICY IF EXISTS "Staff can restore medicine batches" ON public.medicine_batches;
CREATE POLICY "Staff can restore medicine batches"
ON public.medicine_batches
FOR ALL TO authenticated
USING (public.is_current_user_staff())
WITH CHECK (public.is_current_user_staff());

GRANT SELECT, INSERT ON public.medicine_batches TO authenticated;
GRANT UPDATE ON public.medicine_batches TO authenticated;

INSERT INTO public.medicine_batches (
    medicine_id,
    batch_number,
    quantity,
    supplier,
    manufacturing_date,
    expiration_date,
    image_url
)
SELECT
    medicine.id,
    medicine.batch_number,
    medicine.quantity,
    medicine.supplier,
    medicine.manufacturing_date,
    medicine.expiration_date,
    medicine.image_url
FROM public.medicines AS medicine
WHERE NOT EXISTS (
    SELECT 1
    FROM public.medicine_batches AS batch
    WHERE batch.medicine_id = medicine.id
      AND batch.batch_number = medicine.batch_number
);

CREATE OR REPLACE FUNCTION public.create_medicine_with_batch(p_medicine JSONB)
RETURNS SETOF public.medicines
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
DECLARE
    saved_medicine public.medicines%ROWTYPE;
BEGIN
    INSERT INTO public.medicines (
        medicine_id,
        medicine_name,
        category,
        quantity,
        price,
        restock_level,
        dosage,
        unit,
        batch_number,
        supplier,
        manufacturing_date,
        expiration_date,
        image_url
    )
    VALUES (
        p_medicine ->> 'medicine_id',
        p_medicine ->> 'medicine_name',
        p_medicine ->> 'category',
        (p_medicine ->> 'quantity')::INTEGER,
        COALESCE((p_medicine ->> 'price')::NUMERIC, 0),
        COALESCE((p_medicine ->> 'restock_level')::INTEGER, 10),
        p_medicine ->> 'dosage',
        p_medicine ->> 'unit',
        p_medicine ->> 'batch_number',
        p_medicine ->> 'supplier',
        (p_medicine ->> 'manufacturing_date')::DATE,
        (p_medicine ->> 'expiration_date')::DATE,
        p_medicine ->> 'image_url'
    )
    RETURNING * INTO saved_medicine;

    INSERT INTO public.medicine_batches (
        medicine_id,
        batch_number,
        quantity,
        supplier,
        manufacturing_date,
        expiration_date,
        image_url
    )
    VALUES (
        saved_medicine.id,
        saved_medicine.batch_number,
        saved_medicine.quantity,
        saved_medicine.supplier,
        saved_medicine.manufacturing_date,
        saved_medicine.expiration_date,
        saved_medicine.image_url
    );

    RETURN NEXT saved_medicine;
END;
$$;

CREATE OR REPLACE FUNCTION public.add_medicine_batch(
    p_medicine_id UUID,
    p_quantity INTEGER,
    p_batch_number TEXT,
    p_supplier TEXT,
    p_manufacturing_date DATE,
    p_expiration_date DATE
)
RETURNS SETOF public.medicines
LANGUAGE plpgsql
SET search_path = public, pg_temp
AS $$
DECLARE
    saved_medicine public.medicines%ROWTYPE;
    batch_number_value TEXT;
    supplier_value TEXT;
    manufacturing_date_value DATE;
    expiration_date_value DATE;
BEGIN
    IF p_quantity IS NULL OR p_quantity < 1 THEN
        RAISE EXCEPTION 'Quantity to add must be at least 1.';
    END IF;

    SELECT *
    INTO saved_medicine
    FROM public.medicines
    WHERE id = p_medicine_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Medicine not found.';
    END IF;

    batch_number_value := COALESCE(NULLIF(BTRIM(p_batch_number), ''), saved_medicine.batch_number);
    supplier_value := COALESCE(NULLIF(BTRIM(p_supplier), ''), saved_medicine.supplier);
    manufacturing_date_value := COALESCE(p_manufacturing_date, saved_medicine.manufacturing_date);
    expiration_date_value := COALESCE(p_expiration_date, saved_medicine.expiration_date);

    IF expiration_date_value <= manufacturing_date_value THEN
        RAISE EXCEPTION 'Expiration date must be after the manufacturing date.';
    END IF;

    UPDATE public.medicines
    SET quantity = saved_medicine.quantity + p_quantity,
        batch_number = batch_number_value,
        supplier = supplier_value,
        manufacturing_date = manufacturing_date_value,
        expiration_date = expiration_date_value
    WHERE id = p_medicine_id
    RETURNING * INTO saved_medicine;

    INSERT INTO public.medicine_batches (
        medicine_id,
        batch_number,
        quantity,
        supplier,
        manufacturing_date,
        expiration_date,
        image_url
    )
    VALUES (
        saved_medicine.id,
        batch_number_value,
        p_quantity,
        supplier_value,
        manufacturing_date_value,
        expiration_date_value,
        saved_medicine.image_url
    );

    RETURN NEXT saved_medicine;
END;
$$;

REVOKE ALL ON FUNCTION public.create_medicine_with_batch(JSONB) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.add_medicine_batch(UUID, INTEGER, TEXT, TEXT, DATE, DATE) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.create_medicine_with_batch(JSONB) TO authenticated;
GRANT EXECUTE ON FUNCTION public.add_medicine_batch(UUID, INTEGER, TEXT, TEXT, DATE, DATE) TO authenticated;


-- ===== archive_settings.sql =====

ALTER TABLE public.medicines
    ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;

ALTER TABLE public.beneficiaries
    ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;

ALTER TABLE public.medicine_categories
    ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;

GRANT UPDATE (archived_at) ON public.medicines TO authenticated;
GRANT UPDATE (archived_at) ON public.beneficiaries TO authenticated;
GRANT UPDATE (archived_at) ON public.medicine_categories TO authenticated;

DROP POLICY IF EXISTS "Staff can view beneficiaries for archive" ON public.beneficiaries;
CREATE POLICY "Staff can view beneficiaries for archive"
ON public.beneficiaries
FOR SELECT TO authenticated
USING (public.is_current_user_staff());

DROP POLICY IF EXISTS "Staff can archive beneficiaries" ON public.beneficiaries;
CREATE POLICY "Staff can archive beneficiaries"
ON public.beneficiaries
FOR UPDATE TO authenticated
USING (public.is_current_user_staff())
WITH CHECK (public.is_current_user_staff());

DROP POLICY IF EXISTS "Staff can view categories for archive" ON public.medicine_categories;
CREATE POLICY "Staff can view categories for archive"
ON public.medicine_categories
FOR SELECT TO authenticated
USING (public.is_current_user_staff());

DROP POLICY IF EXISTS "Staff can archive categories" ON public.medicine_categories;
CREATE POLICY "Staff can archive categories"
ON public.medicine_categories
FOR UPDATE TO authenticated
USING (public.is_current_user_staff())
WITH CHECK (public.is_current_user_staff());

CREATE OR REPLACE FUNCTION public.prevent_non_staff_archive_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    IF NEW.archived_at IS DISTINCT FROM OLD.archived_at
       AND auth.uid() IS NOT NULL
       AND NOT public.is_current_user_staff() THEN
        RAISE EXCEPTION 'Only staff accounts can archive or restore records.';
    END IF;
    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.prevent_non_staff_archive_change() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS prevent_non_staff_medicine_archive_change ON public.medicines;
CREATE TRIGGER prevent_non_staff_medicine_archive_change
BEFORE UPDATE OF archived_at ON public.medicines
FOR EACH ROW
EXECUTE FUNCTION public.prevent_non_staff_archive_change();

DROP TRIGGER IF EXISTS prevent_non_staff_beneficiary_archive_change ON public.beneficiaries;
CREATE TRIGGER prevent_non_staff_beneficiary_archive_change
BEFORE UPDATE OF archived_at ON public.beneficiaries
FOR EACH ROW
EXECUTE FUNCTION public.prevent_non_staff_archive_change();

DROP TRIGGER IF EXISTS prevent_non_staff_category_archive_change ON public.medicine_categories;
CREATE TRIGGER prevent_non_staff_category_archive_change
BEFORE UPDATE OF archived_at ON public.medicine_categories
FOR EACH ROW
EXECUTE FUNCTION public.prevent_non_staff_archive_change();


-- ===== beneficiary_workflow.sql =====

ALTER TABLE public.medicine_requests
    ADD COLUMN IF NOT EXISTS pickup_instructions TEXT,
    ADD COLUMN IF NOT EXISTS rejection_reason_code TEXT,
    ADD COLUMN IF NOT EXISTS rejection_reason_other TEXT,
    ADD COLUMN IF NOT EXISTS budget_reserved BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS benefit_year INTEGER,
    ADD COLUMN IF NOT EXISTS fulfilled_at TIMESTAMPTZ;

ALTER TABLE public.medicine_requests
    DROP CONSTRAINT IF EXISTS medicine_requests_status_check,
    ADD CONSTRAINT medicine_requests_status_check
        CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled', 'ready_to_dispense', 'completed'));

CREATE TABLE IF NOT EXISTS public.medicine_request_items (
    request_item_id BIGSERIAL PRIMARY KEY,
    request_id BIGINT NOT NULL
        REFERENCES public.medicine_requests(request_id) ON DELETE CASCADE,
    medicine_id UUID NOT NULL
        REFERENCES public.medicines(id) ON DELETE RESTRICT,
    medicine_name TEXT NOT NULL,
    medicine_dosage TEXT,
    medicine_unit TEXT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (unit_price >= 0),
    UNIQUE (request_id, medicine_id)
);

CREATE INDEX IF NOT EXISTS medicine_request_items_request_idx
    ON public.medicine_request_items (request_id);

INSERT INTO public.medicine_request_items (
    request_id, medicine_id, medicine_name, medicine_dosage, medicine_unit, quantity, unit_price
)
SELECT request.request_id,
       request.medicine_id,
       request.medicine_name,
       request.medicine_dosage,
       request.medicine_unit,
       request.quantity,
       COALESCE(medicine.price, 0)
  FROM public.medicine_requests AS request
  LEFT JOIN public.medicines AS medicine ON medicine.id = request.medicine_id
 WHERE NOT EXISTS (
       SELECT 1
         FROM public.medicine_request_items AS item
        WHERE item.request_id = request.request_id
          AND item.medicine_id = request.medicine_id
 );

CREATE TABLE IF NOT EXISTS public.beneficiary_annual_benefits (
    requester_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    benefit_year INTEGER NOT NULL,
    limit_amount NUMERIC(10,2) NOT NULL DEFAULT 20000 CHECK (limit_amount >= 0),
    used_amount NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (used_amount >= 0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (requester_id, benefit_year)
);

WITH legacy_reservations AS (
    SELECT request.requester_id,
           EXTRACT(YEAR FROM timezone('Asia/Manila', request.created_at))::INTEGER AS benefit_year,
           SUM(item.unit_price * item.quantity) AS reserved_amount
      FROM public.medicine_requests AS request
      JOIN public.medicine_request_items AS item ON item.request_id = request.request_id
     WHERE request.status IN ('pending', 'approved', 'ready_to_dispense')
       AND NOT request.budget_reserved
     GROUP BY request.requester_id,
              EXTRACT(YEAR FROM timezone('Asia/Manila', request.created_at))::INTEGER
)
INSERT INTO public.beneficiary_annual_benefits (requester_id, benefit_year, used_amount)
SELECT requester_id, benefit_year, reserved_amount
  FROM legacy_reservations
ON CONFLICT (requester_id, benefit_year) DO UPDATE
    SET used_amount = beneficiary_annual_benefits.used_amount + EXCLUDED.used_amount,
        updated_at = NOW();

UPDATE public.medicine_requests AS request
   SET budget_reserved = TRUE,
       benefit_year = EXTRACT(YEAR FROM timezone('Asia/Manila', request.created_at))::INTEGER
 WHERE request.status IN ('pending', 'approved', 'ready_to_dispense')
   AND NOT request.budget_reserved;

ALTER TABLE public.medicine_request_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.beneficiary_annual_benefits ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Request owners and staff can view request items"
    ON public.medicine_request_items;
CREATE POLICY "Request owners and staff can view request items"
    ON public.medicine_request_items
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1
              FROM public.medicine_requests AS request
             WHERE request.request_id = medicine_request_items.request_id
               AND (
                    request.requester_id = (SELECT auth.uid())
                    OR public.is_current_user_staff()
               )
        )
    );

DROP POLICY IF EXISTS "Staff can restore medicine request items"
    ON public.medicine_request_items;
CREATE POLICY "Staff can restore medicine request items"
    ON public.medicine_request_items
    FOR ALL TO authenticated
    USING (public.is_current_user_staff())
    WITH CHECK (public.is_current_user_staff());

DROP POLICY IF EXISTS "Beneficiaries and staff can view annual benefits"
    ON public.beneficiary_annual_benefits;
CREATE POLICY "Beneficiaries and staff can view annual benefits"
    ON public.beneficiary_annual_benefits
    FOR SELECT TO authenticated
    USING (requester_id = (SELECT auth.uid()) OR public.is_current_user_staff());

DROP POLICY IF EXISTS "Staff can restore annual benefits"
    ON public.beneficiary_annual_benefits;
CREATE POLICY "Staff can restore annual benefits"
    ON public.beneficiary_annual_benefits
    FOR ALL TO authenticated
    USING (public.is_current_user_staff())
    WITH CHECK (public.is_current_user_staff());

GRANT SELECT, INSERT, UPDATE ON public.medicine_request_items TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.beneficiary_annual_benefits TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.medicine_request_items_request_item_id_seq TO authenticated;

CREATE OR REPLACE FUNCTION public.get_my_annual_benefit()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_year INTEGER := EXTRACT(YEAR FROM timezone('Asia/Manila', NOW()))::INTEGER;
    v_limit NUMERIC(10,2);
    v_used NUMERIC(10,2);
    v_beneficiary_id BIGINT;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'You must be signed in to view your annual benefit.';
    END IF;

    INSERT INTO public.beneficiary_annual_benefits (requester_id, benefit_year)
    VALUES (v_user_id, v_year)
    ON CONFLICT (requester_id, benefit_year) DO NOTHING;

    SELECT benefit.limit_amount, benefit.used_amount
      INTO v_limit, v_used
      FROM public.beneficiary_annual_benefits AS benefit
     WHERE benefit.requester_id = v_user_id
       AND benefit.benefit_year = v_year;

    RETURN jsonb_build_object(
        'year', v_year,
        'limit', v_limit,
        'used', v_used,
        'remaining', GREATEST(v_limit - v_used, 0)
    );
END;
$$;

REVOKE ALL ON FUNCTION public.get_my_annual_benefit() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_my_annual_benefit() TO authenticated;

CREATE OR REPLACE FUNCTION public.submit_medicine_request_multi(
    p_medicines JSONB,
    p_purpose TEXT,
    p_beneficiary_type TEXT,
    p_prescription_path TEXT
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_profile RECORD;
    v_medicine RECORD;
    v_first_medicine RECORD;
    v_items JSONB := '[]'::JSONB;
    v_request_id BIGINT;
    v_beneficiary_id BIGINT;
    v_item_count INTEGER;
    v_seen_count INTEGER := 0;
    v_total NUMERIC(10,2) := 0;
    v_year INTEGER := EXTRACT(YEAR FROM timezone('Asia/Manila', NOW()))::INTEGER;
    v_limit NUMERIC(10,2);
    v_used NUMERIC(10,2);
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'You must be signed in to submit a medicine request.';
    END IF;

    SELECT profile.fname, profile.mname, profile.lname, LOWER(profile.role) AS role
      INTO v_profile
      FROM public.profiles AS profile
     WHERE profile.id = v_user_id;

    IF v_profile.role IS DISTINCT FROM 'beneficiary' THEN
        RAISE EXCEPTION 'Only beneficiary accounts can submit medicine requests.';
    END IF;

    SELECT beneficiary.beneficiary_id
      INTO v_beneficiary_id
      FROM public.beneficiaries AS beneficiary
     WHERE beneficiary.profile_id = v_user_id
       AND beneficiary.archived_at IS NULL;
    IF v_beneficiary_id IS NULL THEN
        RAISE EXCEPTION 'Your beneficiary account must be linked to an active beneficiary record before requesting medicines.';
    END IF;

    IF p_beneficiary_type IS NULL
       OR p_beneficiary_type NOT IN ('Senior Citizen', 'PWD', 'General') THEN
        RAISE EXCEPTION 'Choose a valid beneficiary type.';
    END IF;

    IF p_purpose IS NULL OR NOT EXISTS (
        SELECT 1 FROM public.distribution_purposes
         WHERE LOWER(purpose_name) = LOWER(BTRIM(p_purpose))
    ) THEN
        RAISE EXCEPTION 'Choose a valid medicine request purpose.';
    END IF;

    IF p_medicines IS NULL OR jsonb_typeof(p_medicines) <> 'array'
       OR jsonb_array_length(p_medicines) = 0 THEN
        RAISE EXCEPTION 'Select at least one medicine.';
    END IF;

    SELECT COUNT(*)
      INTO v_item_count
      FROM jsonb_to_recordset(p_medicines) AS item(medicine_id UUID, quantity INTEGER);

    IF EXISTS (
        SELECT 1
          FROM jsonb_to_recordset(p_medicines) AS item(medicine_id UUID, quantity INTEGER)
         WHERE item.medicine_id IS NULL OR item.quantity IS NULL OR item.quantity < 1
    ) OR v_item_count <> (
        SELECT COUNT(DISTINCT item.medicine_id)
          FROM jsonb_to_recordset(p_medicines) AS item(medicine_id UUID, quantity INTEGER)
    ) THEN
        RAISE EXCEPTION 'Each medicine must be selected once with a positive quantity.';
    END IF;

    IF NULLIF(BTRIM(CONCAT_WS(' ', v_profile.fname, v_profile.mname, v_profile.lname)), '') IS NULL THEN
        RAISE EXCEPTION 'Your profile must include your name before submitting a request.';
    END IF;

    IF p_prescription_path IS NULL
       OR split_part(p_prescription_path, '/', 1) <> v_user_id::TEXT
       OR p_prescription_path LIKE '%..%'
       OR NOT EXISTS (
            SELECT 1 FROM storage.objects AS object
             WHERE object.bucket_id = 'medicine-prescriptions'
               AND object.name = p_prescription_path
       ) THEN
        RAISE EXCEPTION 'Upload a valid prescription before submitting.';
    END IF;

       INSERT INTO public.beneficiary_annual_benefits (requester_id, benefit_year)
       VALUES (v_user_id, v_year)
       ON CONFLICT (requester_id, benefit_year) DO NOTHING;

       SELECT benefit.limit_amount, benefit.used_amount
         INTO v_limit, v_used
         FROM public.beneficiary_annual_benefits AS benefit
        WHERE benefit.requester_id = v_user_id
          AND benefit.benefit_year = v_year
        FOR UPDATE;

    FOR v_medicine IN
        SELECT medicine.id,
               medicine.medicine_name,
               medicine.dosage,
               medicine.unit,
               medicine.price,
               medicine.quantity AS current_stock,
               requested.quantity AS requested_quantity
          FROM jsonb_to_recordset(p_medicines) AS requested(medicine_id UUID, quantity INTEGER)
          JOIN public.medicines AS medicine ON medicine.id = requested.medicine_id
         WHERE medicine.archived_at IS NULL
         ORDER BY medicine.id
         FOR UPDATE OF medicine
    LOOP
        v_seen_count := v_seen_count + 1;
        IF v_medicine.current_stock < v_medicine.requested_quantity THEN
            RAISE EXCEPTION 'Requested quantity exceeds available stock for % (available: %).',
                v_medicine.medicine_name, v_medicine.current_stock;
        END IF;

        IF v_seen_count = 1 THEN
            v_first_medicine := v_medicine;
        END IF;

        v_total := v_total + (v_medicine.price * v_medicine.requested_quantity);
        v_items := v_items || jsonb_build_array(jsonb_build_object(
            'medicine_id', v_medicine.id,
            'medicine_name', v_medicine.medicine_name,
            'medicine_dosage', v_medicine.dosage,
            'medicine_unit', v_medicine.unit,
            'quantity', v_medicine.requested_quantity,
            'unit_price', v_medicine.price
        ));
    END LOOP;

    IF v_seen_count <> v_item_count THEN
        RAISE EXCEPTION 'One or more selected medicines are unavailable.';
    END IF;

    IF v_used + v_total > v_limit THEN
        RAISE EXCEPTION 'This request exceeds your remaining annual medicine benefit of ₱%.',
            GREATEST(v_limit - v_used, 0);
    END IF;

    INSERT INTO public.medicine_requests (
        requester_id, beneficiary_name, beneficiary_type, medicine_id, medicine_name,
        medicine_dosage, medicine_unit, quantity, purpose, prescription_path,
        budget_reserved, benefit_year
    )
    VALUES (
        v_user_id,
        BTRIM(CONCAT_WS(' ', v_profile.fname, v_profile.mname, v_profile.lname)),
        p_beneficiary_type,
        v_first_medicine.id,
        v_first_medicine.medicine_name,
        v_first_medicine.dosage,
        v_first_medicine.unit,
        v_first_medicine.requested_quantity,
        BTRIM(p_purpose),
        p_prescription_path,
        TRUE,
        v_year
    )
    RETURNING request_id INTO v_request_id;

    INSERT INTO public.medicine_request_items (
        request_id, medicine_id, medicine_name, medicine_dosage, medicine_unit, quantity, unit_price
    )
    SELECT v_request_id, item.medicine_id, item.medicine_name, item.medicine_dosage,
           item.medicine_unit, item.quantity, item.unit_price
      FROM jsonb_to_recordset(v_items) AS item(
          medicine_id UUID, medicine_name TEXT, medicine_dosage TEXT,
          medicine_unit TEXT, quantity INTEGER, unit_price NUMERIC
      );

    UPDATE public.beneficiary_annual_benefits
       SET used_amount = used_amount + v_total,
           updated_at = NOW()
     WHERE requester_id = v_user_id
       AND benefit_year = v_year;

    RETURN v_request_id;
END;
$$;

REVOKE ALL ON FUNCTION public.submit_medicine_request_multi(JSONB, TEXT, TEXT, TEXT)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.submit_medicine_request_multi(JSONB, TEXT, TEXT, TEXT)
    TO authenticated;
REVOKE ALL ON FUNCTION public.submit_medicine_request(UUID, INTEGER, TEXT, TEXT, TEXT)
    FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.review_medicine_request(
    p_request_id BIGINT,
    p_status TEXT,
    p_rejection_reason_code TEXT DEFAULT NULL,
    p_rejection_reason_other TEXT DEFAULT NULL,
    p_pickup_instructions TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_request public.medicine_requests%ROWTYPE;
    v_refund NUMERIC(10,2);
    v_reason TEXT;
BEGIN
    IF v_user_id IS NULL OR NOT public.is_current_user_staff() THEN
        RAISE EXCEPTION 'Only signed-in staff can review medicine requests.';
    END IF;
    IF p_status IS NULL OR p_status NOT IN ('approved', 'rejected') THEN
        RAISE EXCEPTION 'Choose approve or reject.';
    END IF;

    SELECT * INTO v_request
      FROM public.medicine_requests
     WHERE request_id = p_request_id
     FOR UPDATE;
    IF NOT FOUND OR v_request.status <> 'pending' THEN
        RAISE EXCEPTION 'This request has already been reviewed or is no longer available.';
    END IF;

    IF p_status = 'rejected' THEN
        IF p_rejection_reason_code IS NULL OR p_rejection_reason_code NOT IN (
            'Incomplete or invalid prescription',
            'Request does not meet eligibility criteria',
            'Requested quantity exceeds allowable limit',
            'Medicine unavailable',
            'Duplicate request',
            'Others'
        ) THEN
            RAISE EXCEPTION 'Choose a predefined rejection reason.';
        END IF;
        IF p_rejection_reason_code = 'Others'
           AND NULLIF(BTRIM(p_rejection_reason_other), '') IS NULL THEN
            RAISE EXCEPTION 'Enter an explanation for Other.';
        END IF;

        v_reason := CASE
            WHEN p_rejection_reason_code = 'Others'
                THEN 'Others: ' || BTRIM(p_rejection_reason_other)
            ELSE p_rejection_reason_code
        END;

        IF v_request.budget_reserved AND v_request.benefit_year IS NOT NULL THEN
            SELECT COALESCE(SUM(item.unit_price * item.quantity), 0)
              INTO v_refund
              FROM public.medicine_request_items AS item
             WHERE item.request_id = v_request.request_id;
            UPDATE public.beneficiary_annual_benefits
               SET used_amount = GREATEST(used_amount - v_refund, 0),
                   updated_at = NOW()
             WHERE requester_id = v_request.requester_id
               AND benefit_year = v_request.benefit_year;
        END IF;
    ELSE
        v_reason := NULL;
    END IF;

    UPDATE public.medicine_requests
       SET status = p_status,
           reviewed_at = NOW(),
           reviewed_by = v_user_id,
           rejection_reason_code = CASE WHEN p_status = 'rejected' THEN p_rejection_reason_code ELSE NULL END,
           rejection_reason_other = CASE WHEN p_status = 'rejected' AND p_rejection_reason_code = 'Others'
               THEN BTRIM(p_rejection_reason_other) ELSE NULL END,
           rejection_reason = v_reason,
           pickup_instructions = CASE WHEN p_status = 'approved'
               THEN NULLIF(BTRIM(p_pickup_instructions), '') ELSE NULL END,
           budget_reserved = CASE WHEN p_status = 'rejected' THEN FALSE ELSE budget_reserved END
     WHERE request_id = p_request_id;
END;
$$;

REVOKE ALL ON FUNCTION public.review_medicine_request(BIGINT, TEXT, TEXT, TEXT, TEXT)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.review_medicine_request(BIGINT, TEXT, TEXT, TEXT, TEXT)
    TO authenticated;

CREATE OR REPLACE FUNCTION public.mark_medicine_request_ready(p_request_id BIGINT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
    IF auth.uid() IS NULL OR NOT public.is_current_user_staff() THEN
        RAISE EXCEPTION 'Only staff can prepare approved requests for dispensing.';
    END IF;

    UPDATE public.medicine_requests
       SET status = 'ready_to_dispense'
     WHERE request_id = p_request_id
       AND status = 'approved';

    IF NOT FOUND THEN
        IF NOT EXISTS (
            SELECT 1 FROM public.medicine_requests
             WHERE request_id = p_request_id AND status = 'ready_to_dispense'
        ) THEN
            RAISE EXCEPTION 'Only approved requests can be sent to dispensing.';
        END IF;
    END IF;
END;
$$;

REVOKE ALL ON FUNCTION public.mark_medicine_request_ready(BIGINT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.mark_medicine_request_ready(BIGINT) TO authenticated;

CREATE OR REPLACE FUNCTION public.cancel_medicine_request(p_request_id BIGINT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_request public.medicine_requests%ROWTYPE;
    v_refund NUMERIC(10,2);
BEGIN
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'You must be signed in to cancel a medicine request.';
    END IF;

    SELECT * INTO v_request
      FROM public.medicine_requests
     WHERE request_id = p_request_id
       AND requester_id = auth.uid()
     FOR UPDATE;

    IF NOT FOUND OR v_request.status <> 'pending' THEN
        RAISE EXCEPTION 'This request cannot be cancelled.';
    END IF;

    IF v_request.budget_reserved AND v_request.benefit_year IS NOT NULL THEN
        SELECT COALESCE(SUM(item.unit_price * item.quantity), 0)
          INTO v_refund
          FROM public.medicine_request_items AS item
         WHERE item.request_id = v_request.request_id;
        UPDATE public.beneficiary_annual_benefits
           SET used_amount = GREATEST(used_amount - v_refund, 0),
               updated_at = NOW()
         WHERE requester_id = v_request.requester_id
           AND benefit_year = v_request.benefit_year;
    END IF;

    UPDATE public.medicine_requests
       SET status = 'cancelled',
           budget_reserved = FALSE
     WHERE request_id = p_request_id;
END;
$$;

REVOKE ALL ON FUNCTION public.cancel_medicine_request(BIGINT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.cancel_medicine_request(BIGINT) TO authenticated;


-- ===== distribution_workflow.sql =====

ALTER TABLE public.distribution_items
    ADD COLUMN IF NOT EXISTS unit_price NUMERIC(10,2) NOT NULL DEFAULT 0
        CHECK (unit_price >= 0);

ALTER TABLE public.distribution_transactions
    ADD COLUMN IF NOT EXISTS medicine_request_id BIGINT
        REFERENCES public.medicine_requests(request_id) ON DELETE RESTRICT;

CREATE UNIQUE INDEX IF NOT EXISTS distribution_transactions_request_unique
    ON public.distribution_transactions (medicine_request_id)
    WHERE medicine_request_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS public.distribution_returns (
    return_id BIGSERIAL PRIMARY KEY,
    distribution_transaction_id BIGINT NOT NULL
        REFERENCES public.distribution_transactions(distribution_transaction_id) ON DELETE RESTRICT,
    distribution_item_id BIGINT NOT NULL
        REFERENCES public.distribution_items(distribution_item_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    medicine_condition TEXT NOT NULL CHECK (medicine_condition IN ('Good', 'Damaged')),
    inventory_restored_quantity INTEGER NOT NULL DEFAULT 0 CHECK (inventory_restored_quantity >= 0),
    beneficiary_credit NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (beneficiary_credit >= 0),
    verified_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS distribution_returns_item_idx
    ON public.distribution_returns (distribution_item_id);

ALTER TABLE public.distribution_returns ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Staff can view medicine returns" ON public.distribution_returns;
CREATE POLICY "Staff can view medicine returns"
    ON public.distribution_returns
    FOR SELECT TO authenticated
    USING (public.is_current_user_staff());

DROP POLICY IF EXISTS "Staff can restore medicine returns" ON public.distribution_returns;
CREATE POLICY "Staff can restore medicine returns"
    ON public.distribution_returns
    FOR ALL TO authenticated
    USING (public.is_current_user_staff())
    WITH CHECK (public.is_current_user_staff());

GRANT SELECT ON public.distribution_returns TO authenticated;
GRANT INSERT, UPDATE ON public.distribution_returns TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.distribution_returns_return_id_seq TO authenticated;

CREATE OR REPLACE FUNCTION public.dispense_distribution_workflow(
    p_beneficiary_id BIGINT,
    p_distribution_date TIMESTAMPTZ,
    p_purpose TEXT,
    p_items JSONB,
    p_remarks TEXT DEFAULT NULL,
    p_medicine_request_id BIGINT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_beneficiary RECORD;
    v_request public.medicine_requests%ROWTYPE;
    v_expected_count INTEGER;
    v_actual_count INTEGER;
    v_total NUMERIC(10,2);
    v_year INTEGER;
    v_limit NUMERIC(10,2);
    v_used NUMERIC(10,2);
    v_transaction_id BIGINT;
BEGIN
    IF v_user_id IS NULL OR NOT public.is_current_user_staff() THEN
        RAISE EXCEPTION 'Only signed-in staff can dispense medicines.';
    END IF;

    SELECT beneficiary.beneficiary_id, beneficiary.profile_id
      INTO v_beneficiary
      FROM public.beneficiaries AS beneficiary
     WHERE beneficiary.beneficiary_id = p_beneficiary_id
       AND beneficiary.archived_at IS NULL;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Choose an active beneficiary.';
    END IF;
    IF v_beneficiary.profile_id IS NULL THEN
        RAISE EXCEPTION 'Link this beneficiary record to an account before dispensing so the annual benefit limit can be enforced.';
    END IF;

    IF p_medicine_request_id IS NOT NULL THEN
        SELECT * INTO v_request
          FROM public.medicine_requests
         WHERE request_id = p_medicine_request_id
         FOR UPDATE;
        IF NOT FOUND OR v_request.status NOT IN ('approved', 'ready_to_dispense') THEN
            RAISE EXCEPTION 'Only approved requests can be dispensed.';
        END IF;
        IF v_beneficiary.profile_id IS DISTINCT FROM v_request.requester_id THEN
            RAISE EXCEPTION 'The selected beneficiary does not own this request.';
        END IF;

        SELECT COUNT(*) INTO v_expected_count
          FROM public.medicine_request_items AS item
         WHERE item.request_id = v_request.request_id;
        SELECT COUNT(*) INTO v_actual_count
          FROM jsonb_to_recordset(p_items) AS requested(medicine_id UUID, quantity INTEGER);
        IF v_expected_count <> v_actual_count OR EXISTS (
            SELECT 1
              FROM public.medicine_request_items AS requested
              FULL JOIN jsonb_to_recordset(p_items) AS supplied(medicine_id UUID, quantity INTEGER)
                ON supplied.medicine_id = requested.medicine_id
             WHERE requested.request_id = v_request.request_id
               AND (supplied.medicine_id IS NULL OR supplied.quantity IS DISTINCT FROM requested.quantity)
        ) OR EXISTS (
            SELECT 1
              FROM jsonb_to_recordset(p_items) AS supplied(medicine_id UUID, quantity INTEGER)
             WHERE NOT EXISTS (
                 SELECT 1 FROM public.medicine_request_items AS requested
                  WHERE requested.request_id = v_request.request_id
                    AND requested.medicine_id = supplied.medicine_id
             )
        ) THEN
            RAISE EXCEPTION 'Dispensing quantities must match the approved request.';
        END IF;
    ELSE
        v_year := EXTRACT(YEAR FROM timezone('Asia/Manila', p_distribution_date))::INTEGER;
        SELECT COALESCE(SUM(medicine.price * requested.quantity), 0)
          INTO v_total
          FROM jsonb_to_recordset(p_items) AS requested(medicine_id UUID, quantity INTEGER)
          JOIN public.medicines AS medicine ON medicine.id = requested.medicine_id;

        INSERT INTO public.beneficiary_annual_benefits (requester_id, benefit_year)
        SELECT v_beneficiary.profile_id, v_year
         WHERE v_beneficiary.profile_id IS NOT NULL
        ON CONFLICT (requester_id, benefit_year) DO NOTHING;

        IF v_beneficiary.profile_id IS NOT NULL THEN
            SELECT benefit.limit_amount, benefit.used_amount
              INTO v_limit, v_used
              FROM public.beneficiary_annual_benefits AS benefit
             WHERE benefit.requester_id = v_beneficiary.profile_id
               AND benefit.benefit_year = v_year
             FOR UPDATE;
            IF v_used + v_total > v_limit THEN
                RAISE EXCEPTION 'This dispensing exceeds the beneficiary''s remaining annual limit of ₱%.',
                    GREATEST(v_limit - v_used, 0);
            END IF;
            UPDATE public.beneficiary_annual_benefits
               SET used_amount = used_amount + v_total,
                   updated_at = NOW()
             WHERE requester_id = v_beneficiary.profile_id
               AND benefit_year = v_year;
        END IF;
    END IF;

    v_transaction_id := public.dispense_distribution(
        p_beneficiary_id, p_distribution_date, p_purpose, p_items, p_remarks
    );

    IF p_medicine_request_id IS NOT NULL THEN
        UPDATE public.distribution_items AS distribution_item
           SET unit_price = requested.unit_price
          FROM public.medicine_request_items AS requested
         WHERE distribution_item.distribution_transaction_id = v_transaction_id
           AND requested.request_id = p_medicine_request_id
           AND requested.medicine_id = distribution_item.medicine_id;

        UPDATE public.distribution_transactions
           SET medicine_request_id = p_medicine_request_id
         WHERE distribution_transaction_id = v_transaction_id;

        UPDATE public.medicine_requests
           SET status = 'completed',
               fulfilled_at = NOW()
         WHERE request_id = p_medicine_request_id;
    ELSE
        UPDATE public.distribution_items AS distribution_item
           SET unit_price = medicine.price
          FROM public.medicines AS medicine
         WHERE distribution_item.distribution_transaction_id = v_transaction_id
           AND medicine.id = distribution_item.medicine_id;
    END IF;

    RETURN v_transaction_id;
END;
$$;

REVOKE ALL ON FUNCTION public.dispense_distribution_workflow(BIGINT, TIMESTAMPTZ, TEXT, JSONB, TEXT, BIGINT)
    FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.dispense_distribution_workflow(BIGINT, TIMESTAMPTZ, TEXT, JSONB, TEXT, BIGINT)
    TO authenticated;
REVOKE EXECUTE ON FUNCTION public.dispense_distribution(BIGINT, TIMESTAMPTZ, TEXT, JSONB, TEXT)
    FROM authenticated;

CREATE OR REPLACE FUNCTION public.return_distribution_items(
    p_distribution_transaction_id BIGINT,
    p_items JSONB
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_transaction public.distribution_transactions%ROWTYPE;
    v_beneficiary_profile UUID;
    v_benefit_year INTEGER;
    v_item RECORD;
    v_seen_count INTEGER := 0;
    v_item_count INTEGER;
    v_credit NUMERIC(10,2);
BEGIN
    IF v_user_id IS NULL OR NOT public.is_current_user_staff() THEN
        RAISE EXCEPTION 'Only signed-in staff can verify returned medicines.';
    END IF;
    IF p_items IS NULL OR jsonb_typeof(p_items) <> 'array' OR jsonb_array_length(p_items) = 0 THEN
        RAISE EXCEPTION 'Select at least one medicine and quantity to return.';
    END IF;
    IF EXISTS (
        SELECT 1
          FROM jsonb_to_recordset(p_items) AS item(distribution_item_id BIGINT, quantity INTEGER, medicine_condition TEXT)
         WHERE item.distribution_item_id IS NULL OR item.quantity IS NULL OR item.quantity < 1
            OR item.medicine_condition NOT IN ('Good', 'Damaged')
    ) THEN
        RAISE EXCEPTION 'Return quantities and verified medicine conditions are required.';
    END IF;
    SELECT COUNT(*) INTO v_item_count
      FROM jsonb_to_recordset(p_items) AS item(distribution_item_id BIGINT, quantity INTEGER, medicine_condition TEXT);
    IF v_item_count <> (
        SELECT COUNT(DISTINCT item.distribution_item_id)
          FROM jsonb_to_recordset(p_items) AS item(distribution_item_id BIGINT, quantity INTEGER, medicine_condition TEXT)
    ) THEN
        RAISE EXCEPTION 'A distribution item may only appear once per return.';
    END IF;

    SELECT * INTO v_transaction
      FROM public.distribution_transactions
     WHERE distribution_transaction_id = p_distribution_transaction_id
     FOR UPDATE;
    IF NOT FOUND OR v_transaction.voided_at IS NOT NULL THEN
        RAISE EXCEPTION 'This distribution cannot be returned.';
    END IF;

    SELECT beneficiary.profile_id
      INTO v_beneficiary_profile
      FROM public.beneficiaries AS beneficiary
     WHERE beneficiary.beneficiary_id = v_transaction.beneficiary_id;

    IF v_transaction.medicine_request_id IS NOT NULL THEN
        SELECT request.benefit_year
          INTO v_benefit_year
          FROM public.medicine_requests AS request
         WHERE request.request_id = v_transaction.medicine_request_id;
    ELSE
        v_benefit_year := EXTRACT(YEAR FROM timezone('Asia/Manila', v_transaction.distribution_date))::INTEGER;
    END IF;

    FOR v_item IN
        SELECT distribution_item.distribution_item_id,
               distribution_item.medicine_id,
               distribution_item.quantity AS dispensed_quantity,
               distribution_item.unit_price,
               requested.quantity AS return_quantity,
               requested.medicine_condition,
               COALESCE((
                   SELECT SUM(prior_return.quantity)
                     FROM public.distribution_returns AS prior_return
                    WHERE prior_return.distribution_item_id = distribution_item.distribution_item_id
               ), 0) AS already_returned
          FROM jsonb_to_recordset(p_items) AS requested(
              distribution_item_id BIGINT, quantity INTEGER, medicine_condition TEXT
          )
          JOIN public.distribution_items AS distribution_item
            ON distribution_item.distribution_item_id = requested.distribution_item_id
           AND distribution_item.distribution_transaction_id = p_distribution_transaction_id
         ORDER BY distribution_item.medicine_id
         FOR UPDATE OF distribution_item
    LOOP
        v_seen_count := v_seen_count + 1;
        IF v_item.return_quantity > v_item.dispensed_quantity - v_item.already_returned THEN
            RAISE EXCEPTION 'Return quantity exceeds the remaining dispensed quantity.';
        END IF;

        v_credit := v_item.unit_price * v_item.return_quantity;

        IF v_item.medicine_condition = 'Good' THEN
            UPDATE public.medicines
               SET quantity = quantity + v_item.return_quantity
             WHERE id = v_item.medicine_id;
        END IF;

        INSERT INTO public.distribution_returns (
            distribution_transaction_id, distribution_item_id, quantity,
            medicine_condition, inventory_restored_quantity, beneficiary_credit, verified_by
        )
        VALUES (
            p_distribution_transaction_id,
            v_item.distribution_item_id,
            v_item.return_quantity,
            v_item.medicine_condition,
            CASE WHEN v_item.medicine_condition = 'Good' THEN v_item.return_quantity ELSE 0 END,
            v_credit,
            v_user_id
        );

        IF v_credit > 0 AND v_beneficiary_profile IS NOT NULL AND v_benefit_year IS NOT NULL THEN
            UPDATE public.beneficiary_annual_benefits
               SET used_amount = GREATEST(used_amount - v_credit, 0),
                   updated_at = NOW()
             WHERE requester_id = v_beneficiary_profile
               AND benefit_year = v_benefit_year;
        END IF;
    END LOOP;

    IF v_seen_count <> v_item_count THEN
        RAISE EXCEPTION 'One or more selected items do not belong to this distribution.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
          FROM public.distribution_items AS item
         WHERE item.distribution_transaction_id = p_distribution_transaction_id
           AND item.quantity > COALESCE((
               SELECT SUM(returned.quantity)
                 FROM public.distribution_returns AS returned
                WHERE returned.distribution_item_id = item.distribution_item_id
           ), 0)
    ) THEN
        UPDATE public.distribution_transactions
           SET returned_at = NOW(),
               updated_by = v_user_id,
               updated_at = NOW()
         WHERE distribution_transaction_id = p_distribution_transaction_id;
    END IF;

    RETURN p_distribution_transaction_id;
END;
$$;

REVOKE ALL ON FUNCTION public.return_distribution_items(BIGINT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.return_distribution_items(BIGINT, JSONB) TO authenticated;

CREATE OR REPLACE FUNCTION public.return_distribution_transaction(p_distribution_transaction_id BIGINT)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_items JSONB;
BEGIN
    SELECT jsonb_agg(jsonb_build_object(
        'distribution_item_id', item.distribution_item_id,
        'quantity', item.quantity - COALESCE((
            SELECT SUM(returned.quantity)
              FROM public.distribution_returns AS returned
             WHERE returned.distribution_item_id = item.distribution_item_id
        ), 0),
        'medicine_condition', 'Good'
    ))
      INTO v_items
      FROM public.distribution_items AS item
     WHERE item.distribution_transaction_id = p_distribution_transaction_id
       AND item.quantity > COALESCE((
           SELECT SUM(returned.quantity)
             FROM public.distribution_returns AS returned
            WHERE returned.distribution_item_id = item.distribution_item_id
       ), 0);

    IF v_items IS NULL THEN
        RAISE EXCEPTION 'This distribution has no remaining medicines to return.';
    END IF;
    RETURN public.return_distribution_items(p_distribution_transaction_id, v_items);
END;
$$;

REVOKE ALL ON FUNCTION public.return_distribution_transaction(BIGINT) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.void_distribution_with_benefit_credit(p_distribution_transaction_id BIGINT)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_transaction public.distribution_transactions%ROWTYPE;
    v_profile_id UUID;
    v_benefit_year INTEGER;
    v_credit NUMERIC(10,2);
BEGIN
    SELECT * INTO v_transaction
      FROM public.distribution_transactions
     WHERE distribution_transaction_id = p_distribution_transaction_id
     FOR UPDATE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Distribution transaction was not found.';
    END IF;
    IF EXISTS (
        SELECT 1 FROM public.distribution_returns
         WHERE distribution_transaction_id = p_distribution_transaction_id
    ) THEN
        RAISE EXCEPTION 'A distribution with recorded returns cannot be voided.';
    END IF;

    SELECT beneficiary.profile_id
      INTO v_profile_id
      FROM public.beneficiaries AS beneficiary
     WHERE beneficiary.beneficiary_id = v_transaction.beneficiary_id;
    IF v_transaction.medicine_request_id IS NOT NULL THEN
        SELECT request.benefit_year INTO v_benefit_year
          FROM public.medicine_requests AS request
         WHERE request.request_id = v_transaction.medicine_request_id;
    ELSE
        v_benefit_year := EXTRACT(YEAR FROM timezone('Asia/Manila', v_transaction.distribution_date))::INTEGER;
    END IF;
    SELECT COALESCE(SUM(item.unit_price * item.quantity), 0)
      INTO v_credit
      FROM public.distribution_items AS item
     WHERE item.distribution_transaction_id = p_distribution_transaction_id;

    PERFORM public.void_distribution_transaction(p_distribution_transaction_id);

    IF v_profile_id IS NOT NULL AND v_benefit_year IS NOT NULL THEN
        UPDATE public.beneficiary_annual_benefits
           SET used_amount = GREATEST(used_amount - v_credit, 0),
               updated_at = NOW()
         WHERE requester_id = v_profile_id
           AND benefit_year = v_benefit_year;
    END IF;
    RETURN p_distribution_transaction_id;
END;
$$;

REVOKE ALL ON FUNCTION public.void_distribution_with_benefit_credit(BIGINT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.void_distribution_with_benefit_credit(BIGINT) TO authenticated;
REVOKE EXECUTE ON FUNCTION public.void_distribution_transaction(BIGINT) FROM authenticated;


-- ===== audit_trail.sql =====

CREATE TABLE IF NOT EXISTS public.audit_logs (
    audit_log_id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    user_name TEXT NOT NULL DEFAULT 'Unknown user',
    user_email TEXT,
    user_role TEXT,
    action TEXT NOT NULL,
    entity_type TEXT,
    entity_id TEXT,
    details JSONB NOT NULL DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS audit_logs_created_at_idx
    ON public.audit_logs (created_at DESC);
CREATE INDEX IF NOT EXISTS audit_logs_user_created_idx
    ON public.audit_logs (user_id, created_at DESC);

ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own audit activity" ON public.audit_logs;
CREATE POLICY "Users can view their own audit activity"
    ON public.audit_logs
    FOR SELECT TO authenticated
    USING (
        user_id = (SELECT auth.uid())
        OR public.is_current_user_staff()
    );

GRANT SELECT ON public.audit_logs TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE public.audit_logs_audit_log_id_seq TO authenticated;

CREATE OR REPLACE FUNCTION public.log_audit_activity(
    p_action TEXT,
    p_entity_type TEXT DEFAULT NULL,
    p_entity_id TEXT DEFAULT NULL,
    p_details JSONB DEFAULT '{}'::JSONB
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_profile RECORD;
BEGIN
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication is required to record account activity.';
    END IF;
    IF p_action NOT IN ('login', 'logout', 'profile updated') THEN
        RAISE EXCEPTION 'This activity cannot be recorded through the account activity endpoint.';
    END IF;

    SELECT profile.fname, profile.mname, profile.lname, profile.email, profile.role
      INTO v_profile
      FROM public.profiles AS profile
     WHERE profile.id = v_user_id;

    INSERT INTO public.audit_logs (
        user_id, user_name, user_email, user_role, action, entity_type, entity_id, details
    )
    VALUES (
        v_user_id,
        COALESCE(NULLIF(BTRIM(CONCAT_WS(' ', v_profile.fname, v_profile.mname, v_profile.lname)), ''), v_profile.email, 'Unknown user'),
        v_profile.email,
        v_profile.role,
        p_action,
        p_entity_type,
        p_entity_id,
        COALESCE(p_details, '{}'::JSONB)
    );
END;
$$;

REVOKE ALL ON FUNCTION public.log_audit_activity(TEXT, TEXT, TEXT, JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.log_audit_activity(TEXT, TEXT, TEXT, JSONB) TO authenticated;

CREATE OR REPLACE FUNCTION public.audit_record_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_row JSONB;
    v_old_row JSONB;
    v_record_id TEXT;
    v_record_name TEXT;
    v_action TEXT;
    v_profile RECORD;
BEGIN
    v_row := TO_JSONB(NEW);
    IF TG_OP = 'UPDATE' THEN
        v_old_row := TO_JSONB(OLD);
        IF v_row ? 'archived_at' AND v_row -> 'archived_at' IS DISTINCT FROM v_old_row -> 'archived_at' THEN
            v_action := CASE WHEN v_row -> 'archived_at' = 'null'::JSONB THEN 'restored' ELSE 'archived' END;
        ELSIF TG_ARGV[0] = 'Medicine request'
              AND v_row -> 'status' IS DISTINCT FROM v_old_row -> 'status' THEN
            v_action := v_row ->> 'status';
        ELSIF TG_ARGV[0] = 'Distribution'
              AND v_row -> 'voided_at' IS DISTINCT FROM v_old_row -> 'voided_at' THEN
            v_action := 'voided';
        ELSE
            v_action := 'edited';
        END IF;
    ELSE
        v_action := CASE TG_ARGV[0]
            WHEN 'Distribution' THEN 'dispensed'
            WHEN 'Medicine return' THEN 'returned'
            WHEN 'Medicine request' THEN 'request submitted'
            ELSE 'added'
        END;
    END IF;

    v_record_id := COALESCE(
        v_row ->> 'id',
        v_row ->> 'category_id',
        v_row ->> 'beneficiary_id',
        v_row ->> 'supplier_code',
        v_row ->> 'request_id',
        v_row ->> 'distribution_transaction_id',
        v_row ->> 'return_id'
    );
    v_record_name := COALESCE(
        v_row ->> 'medicine_name',
        v_row ->> 'category_name',
        v_row ->> 'company_name',
        NULLIF(BTRIM(CONCAT_WS(' ', v_row ->> 'first_name', v_row ->> 'middle_name', v_row ->> 'last_name')), ''),
        v_row ->> 'beneficiary_name',
        v_row ->> 'purpose'
    );

    SELECT profile.fname, profile.mname, profile.lname, profile.email, profile.role
      INTO v_profile
      FROM public.profiles AS profile
     WHERE profile.id = v_user_id;

    INSERT INTO public.audit_logs (
        user_id, user_name, user_email, user_role, action, entity_type, entity_id, details
    )
    VALUES (
        v_user_id,
        COALESCE(NULLIF(BTRIM(CONCAT_WS(' ', v_profile.fname, v_profile.mname, v_profile.lname)), ''), v_profile.email, 'Unknown user'),
        v_profile.email,
        v_profile.role,
        v_action,
        TG_ARGV[0],
        v_record_id,
        jsonb_strip_nulls(jsonb_build_object('name', v_record_name))
    );

    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.audit_record_change() FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.restore_audit_logs(p_logs JSONB)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    IF auth.uid() IS NULL OR NOT public.is_current_user_staff() THEN
        RAISE EXCEPTION 'Only staff can restore audit history.';
    END IF;
    IF p_logs IS NULL OR jsonb_typeof(p_logs) <> 'array' THEN
        RAISE EXCEPTION 'Audit history backup must be a JSON array.';
    END IF;

    INSERT INTO public.audit_logs (
        audit_log_id, user_id, user_name, user_email, user_role, action,
        entity_type, entity_id, details, created_at
    )
    SELECT restored.audit_log_id,
           CASE WHEN profile.id IS NULL THEN NULL ELSE restored.user_id END,
           restored.user_name,
           restored.user_email,
           restored.user_role,
           restored.action,
           restored.entity_type,
           restored.entity_id,
           COALESCE(restored.details, '{}'::JSONB),
           restored.created_at
      FROM jsonb_to_recordset(p_logs) AS restored(
          audit_log_id BIGINT, user_id UUID, user_name TEXT, user_email TEXT, user_role TEXT,
          action TEXT, entity_type TEXT, entity_id TEXT, details JSONB, created_at TIMESTAMPTZ
      )
      LEFT JOIN public.profiles AS profile ON profile.id = restored.user_id
    ON CONFLICT (audit_log_id) DO NOTHING;

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$;

REVOKE ALL ON FUNCTION public.restore_audit_logs(JSONB) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.restore_audit_logs(JSONB) TO authenticated;

DROP TRIGGER IF EXISTS audit_medicine_category_changes ON public.medicine_categories;
CREATE TRIGGER audit_medicine_category_changes
AFTER INSERT OR UPDATE ON public.medicine_categories
FOR EACH ROW EXECUTE FUNCTION public.audit_record_change('Category');

DROP TRIGGER IF EXISTS audit_medicine_changes ON public.medicines;
CREATE TRIGGER audit_medicine_changes
AFTER INSERT OR UPDATE ON public.medicines
FOR EACH ROW EXECUTE FUNCTION public.audit_record_change('Medicine');

DROP TRIGGER IF EXISTS audit_supplier_changes ON public.suppliers;
CREATE TRIGGER audit_supplier_changes
AFTER INSERT OR UPDATE ON public.suppliers
FOR EACH ROW EXECUTE FUNCTION public.audit_record_change('Supplier');

DROP TRIGGER IF EXISTS audit_beneficiary_changes ON public.beneficiaries;
CREATE TRIGGER audit_beneficiary_changes
AFTER INSERT OR UPDATE ON public.beneficiaries
FOR EACH ROW EXECUTE FUNCTION public.audit_record_change('Beneficiary');

DROP TRIGGER IF EXISTS audit_medicine_request_changes ON public.medicine_requests;
CREATE TRIGGER audit_medicine_request_changes
AFTER INSERT OR UPDATE ON public.medicine_requests
FOR EACH ROW EXECUTE FUNCTION public.audit_record_change('Medicine request');

DROP TRIGGER IF EXISTS audit_distribution_changes ON public.distribution_transactions;
CREATE TRIGGER audit_distribution_changes
AFTER INSERT OR UPDATE ON public.distribution_transactions
FOR EACH ROW EXECUTE FUNCTION public.audit_record_change('Distribution');

DROP TRIGGER IF EXISTS audit_distribution_return_changes ON public.distribution_returns;
CREATE TRIGGER audit_distribution_return_changes
AFTER INSERT ON public.distribution_returns
FOR EACH ROW EXECUTE FUNCTION public.audit_record_change('Medicine return');

DROP TRIGGER IF EXISTS audit_profile_changes ON public.profiles;
CREATE TRIGGER audit_profile_changes
AFTER UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.audit_record_change('Account profile');


-- ===== backup_recovery.sql =====

INSERT INTO storage.buckets (id, name, public)
VALUES ('database-backups', 'database-backups', FALSE)
ON CONFLICT (id) DO UPDATE SET public = FALSE;

DROP POLICY IF EXISTS "Staff can list their backups" ON storage.objects;
CREATE POLICY "Staff can list their backups"
ON storage.objects
FOR SELECT TO authenticated
USING (
    bucket_id = 'database-backups'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::TEXT
    AND public.is_current_user_staff()
);

DROP POLICY IF EXISTS "Staff can upload their backups" ON storage.objects;
CREATE POLICY "Staff can upload their backups"
ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
    bucket_id = 'database-backups'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::TEXT
    AND public.is_current_user_staff()
);

CREATE OR REPLACE FUNCTION public.sync_data_backup_sequences()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_table RECORD;
    v_sequence TEXT;
    v_max_id BIGINT;
BEGIN
    IF NOT public.is_current_user_staff() THEN
        RAISE EXCEPTION 'Only staff accounts can synchronize backup sequences.';
    END IF;

    FOR v_table IN
        SELECT * FROM (VALUES
            ('medicine_categories', 'category_id'),
            ('beneficiaries', 'beneficiary_id'),
            ('distribution_purposes', 'purpose_id'),
            ('distribution_transactions', 'distribution_transaction_id'),
            ('distribution_items', 'distribution_item_id'),
            ('medicine_requests', 'request_id'),
            ('medicine_request_items', 'request_item_id'),
            ('distribution_returns', 'return_id'),
            ('audit_logs', 'audit_log_id')
        ) AS tables(table_name, column_name)
    LOOP
        v_sequence := pg_get_serial_sequence(
            format('public.%I', v_table.table_name),
            v_table.column_name
        );
        IF v_sequence IS NOT NULL THEN
            EXECUTE format('SELECT COALESCE(MAX(%I), 0) FROM public.%I',
                v_table.column_name, v_table.table_name)
                INTO v_max_id;
            IF v_max_id > 0 THEN
                PERFORM setval(v_sequence::REGCLASS, v_max_id, TRUE);
            END IF;
        END IF;
    END LOOP;
END;
$$;

REVOKE ALL ON FUNCTION public.sync_data_backup_sequences() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sync_data_backup_sequences() TO authenticated;
