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
