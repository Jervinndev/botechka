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
