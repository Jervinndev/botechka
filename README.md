# BOTECHKA

## Supabase database setup

Run [`src/schema/botechka_complete.sql`](./src/schema/botechka_complete.sql) in the Supabase SQL Editor. It combines the required schema, access policies, database functions, storage buckets, audit trail, annual beneficiary benefits, and backup/recovery setup in dependency order. It expects Supabase's standard `auth` and `storage` schemas.

The script is safe to rerun for its supported schema changes. Take a database backup before applying it to an existing deployment and review any SQL Editor errors before using the updated application.

The public homepage calls `get_beneficiary_count()` without requiring a session. That function exposes only the count of non-archived beneficiaries—not their personal data—and is executable by the `anon` and `authenticated` roles. Run the updated schema script in Supabase to apply this permission change to an existing project.

## Account management function

Deploy the included account-management Edge Function so Admin and Super Admin account creation and role updates can use the server-side Auth Admin API:

```powershell
supabase link --project-ref YOUR_PROJECT_REF
supabase functions deploy manage-accounts
```

The function uses the Supabase URL, anon key, and service-role key from the Edge Function environment. Keep the service-role key server-side; never add it to the Vue app.

## Inventory workbook upload

Batch Upload accepts `.xlsx` workbooks. Use the first worksheet with these required columns:

`medicine_name`, `category`, `quantity`, `dosage`, `unit`, `batch_number`, `supplier`, `manufacturing_date`, `expiration_date`

Optional columns are `medicine_id`, `price` (or `price_per_unit`), and `restock_level`. Enter dates as Excel date cells or `YYYY-MM-DD`. Each valid row is saved as a medicine and stock batch; if a later row fails, the error reports how many earlier rows were saved.

## Annual beneficiary medicine limit

Each linked beneficiary account has a ₱20,000 limit per calendar year in the Asia/Manila timezone. Submitted requests reserve their medicine cost; rejected or cancelled requests and verified returns release the corresponding amount.

## Backups

Backup restore merges records and does not delete records absent from a backup. Backups do not include Supabase Auth credentials or uploaded images and prescriptions.
