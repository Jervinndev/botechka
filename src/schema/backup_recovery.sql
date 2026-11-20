INSERT INTO storage.buckets (id, name, public)
VALUES ('database-backups', 'database-backups', FALSE)
ON CONFLICT (id) DO UPDATE SET public = FALSE;

DROP POLICY IF EXISTS "Staff can list their backups" ON storage.objects;
CREATE POLICY "Staff can list their backups"
ON storage.objects
FOR SELECT TO authenticated
USING (
    bucket_id = 'database-backups'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::TEXT
    AND public.is_current_user_staff()
);

DROP POLICY IF EXISTS "Staff can upload their backups" ON storage.objects;
CREATE POLICY "Staff can upload their backups"
ON storage.objects
FOR INSERT TO authenticated
WITH CHECK (
    bucket_id = 'database-backups'
    AND (storage.foldername(name))[1] = (SELECT auth.uid())::TEXT
    AND public.is_current_user_staff()
);

CREATE OR REPLACE FUNCTION public.sync_data_backup_sequences()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_table RECORD;
    v_sequence TEXT;
    v_max_id BIGINT;
BEGIN
    IF NOT public.is_current_user_staff() THEN
        RAISE EXCEPTION 'Only staff accounts can synchronize backup sequences.';
    END IF;

    FOR v_table IN
        SELECT * FROM (VALUES
            ('medicine_categories', 'category_id'),
            ('beneficiaries', 'beneficiary_id'),
            ('distribution_purposes', 'purpose_id'),
            ('distribution_transactions', 'distribution_transaction_id'),
            ('distribution_items', 'distribution_item_id'),
            ('medicine_requests', 'request_id')
        ) AS tables(table_name, column_name)
    LOOP
        v_sequence := pg_get_serial_sequence(
            format('public.%I', v_table.table_name),
            v_table.column_name
        );
        IF v_sequence IS NOT NULL THEN
            EXECUTE format('SELECT COALESCE(MAX(%I), 0) FROM public.%I',
                v_table.column_name, v_table.table_name)
                INTO v_max_id;
            IF v_max_id > 0 THEN
                PERFORM setval(v_sequence::REGCLASS, v_max_id, TRUE);
            END IF;
        END IF;
    END LOOP;
END;
$$;

REVOKE ALL ON FUNCTION public.sync_data_backup_sequences() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sync_data_backup_sequences() TO authenticated;
