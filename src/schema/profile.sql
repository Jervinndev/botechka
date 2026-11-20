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

DROP POLICY IF EXISTS "Super admins can view all profiles" ON public.profiles;
CREATE POLICY "Super admins can view all profiles"
ON public.profiles
FOR SELECT
TO authenticated
USING (public.is_current_user_super_admin());

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
    IF NEW.role IS DISTINCT FROM OLD.role
       AND auth.uid() IS NOT NULL
       AND NOT public.is_current_user_super_admin() THEN
        RAISE EXCEPTION 'Only a super admin can change account roles.';
    END IF;
    RETURN NEW;
END;
$$;

REVOKE ALL ON FUNCTION public.prevent_unauthorized_profile_role_change() FROM PUBLIC, anon, authenticated;

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
