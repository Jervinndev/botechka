-- UUID generator
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Medicines table
CREATE TABLE IF NOT EXISTS public.medicines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    medicine_id TEXT UNIQUE NOT NULL,
    medicine_name TEXT NOT NULL,
    category TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 0,
    dosage TEXT NOT NULL,
    unit TEXT NOT NULL,
    batch_number TEXT NOT NULL,
    supplier TEXT NOT NULL,
    manufacturing_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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