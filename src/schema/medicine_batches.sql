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
