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
