ALTER TABLE public.medicines
    ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;

ALTER TABLE public.beneficiaries
    ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;

GRANT UPDATE (archived_at) ON public.medicines TO authenticated;
GRANT UPDATE (archived_at) ON public.beneficiaries TO authenticated;

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
