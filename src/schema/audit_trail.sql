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
