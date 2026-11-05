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
CREATE POLICY "Staff can view distribution purposes"
    ON public.distribution_purposes
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1
            FROM public.profiles AS profile
            WHERE profile.id = (SELECT auth.uid())
              AND LOWER(profile.role) IN ('personnel', 'admin', 'super_admin')
        )
    );

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
              AND LOWER(profile.role) IN ('personnel', 'admin', 'super_admin')
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
              AND LOWER(profile.role) IN ('personnel', 'admin', 'super_admin')
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
              AND LOWER(profile.role) IN ('personnel', 'admin', 'super_admin')
        )
    );

GRANT SELECT, INSERT ON public.distribution_purposes TO authenticated;
GRANT SELECT ON public.distribution_transactions TO authenticated;
GRANT SELECT ON public.distribution_items TO authenticated;
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

    IF v_role IS NULL OR v_role NOT IN ('personnel', 'admin', 'super_admin') THEN
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
