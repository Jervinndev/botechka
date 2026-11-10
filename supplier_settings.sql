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
