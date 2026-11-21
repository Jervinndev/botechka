import { supabase } from '../supabase/supabase'

const tableNames = [
    'medicine_categories',
    'medicines',
    'medicine_batches',
    'suppliers',
    'beneficiaries',
    'distribution_purposes',
    'beneficiary_annual_benefits',
    'medicine_requests',
    'medicine_request_items',
    'distribution_transactions',
    'distribution_items',
    'distribution_returns',
    'audit_logs'
]

const conflictColumns = {
    medicine_categories: 'category_id',
    medicines: 'id',
    medicine_batches: 'id',
    suppliers: 'id',
    beneficiaries: 'beneficiary_id',
    beneficiary_annual_benefits: 'requester_id,benefit_year',
    distribution_purposes: 'purpose_id',
    distribution_transactions: 'distribution_transaction_id',
    distribution_items: 'distribution_item_id',
    distribution_returns: 'return_id',
    medicine_requests: 'request_id',
    medicine_request_items: 'request_item_id',
    audit_logs: 'audit_log_id'
}
const legacyRequiredTables = [
    'medicine_categories',
    'medicines',
    'suppliers',
    'beneficiaries',
    'distribution_purposes',
    'distribution_transactions',
    'distribution_items',
    'medicine_requests'
]

export async function createDataBackup() {
    const tables = {}
    for (const tableName of tableNames) {
        const rows = []
        const pageSize = 1000
        let start = 0
        while (true) {
            const { data, error } = await supabase
                .from(tableName)
                .select('*')
                .range(start, start + pageSize - 1)
            if (error) throw new Error(`Unable to back up ${tableName}: ${error.message}`)
            rows.push(...(data || []))
            if (!data || data.length < pageSize) break
            start += pageSize
        }
        tables[tableName] = rows
    }

    return {
        application: 'RHUBoTechka',
        formatVersion: 1,
        createdAt: new Date().toISOString(),
        tables
    }
}

export async function uploadDataBackup(backup) {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError) throw new Error(userError.message)
    if (!user) throw new Error('You must sign in to create a cloud backup.')

    const filename = `backup-${new Date(backup.createdAt).toISOString().replaceAll(':', '-')}.json`
    const path = `${user.id}/${filename}`
    const { error } = await supabase.storage
        .from('database-backups')
        .upload(path, JSON.stringify(backup), {
            contentType: 'application/json',
            upsert: false
        })
    if (error) throw new Error(error.message)

    return path
}

export async function listCloudBackups() {
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError) throw new Error(userError.message)
    if (!user) throw new Error('You must sign in to view cloud backups.')

    const { data, error } = await supabase.storage
        .from('database-backups')
        .list(user.id, { limit: 100, sortBy: { column: 'created_at', order: 'desc' } })
    if (error) throw new Error(error.message)

    return (data || []).filter((file) => file.name.endsWith('.json')).map((file) => ({
        name: file.name,
        path: `${user.id}/${file.name}`,
        createdAt: file.created_at,
        size: file.metadata?.size || 0
    }))
}

export async function downloadCloudBackup(path) {
    const { data, error } = await supabase.storage.from('database-backups').download(path)
    if (error) throw new Error(error.message)

    const backup = JSON.parse(await data.text())
    validateBackup(backup)
    return backup
}

export function validateBackup(backup) {
    if (!backup || backup.application !== 'RHUBoTechka' || backup.formatVersion !== 1 || !backup.tables) {
        throw new Error('This is not a supported RHUBoTechka backup file.')
    }

    for (const tableName of legacyRequiredTables) {
        if (!Array.isArray(backup.tables[tableName])) {
            throw new Error(`The backup is missing the ${tableName} records.`)
        }
    }
    for (const tableName of tableNames) {
        if (backup.tables[tableName] !== undefined && !Array.isArray(backup.tables[tableName])) {
            throw new Error(`The backup has invalid ${tableName} records.`)
        }
    }
}

export async function restoreDataBackup(backup) {
    validateBackup(backup)
    const results = []

    for (const tableName of tableNames) {
        const rows = backup.tables[tableName] || []
        if (!rows.length) continue

        for (let start = 0; start < rows.length; start += 500) {
            const batch = rows.slice(start, start + 500)
            const { error } = tableName === 'audit_logs'
                ? await supabase.rpc('restore_audit_logs', { p_logs: batch })
                : await supabase.from(tableName)
                    .upsert(batch, { onConflict: conflictColumns[tableName] })
            if (error) {
                throw new Error(`Restore stopped at ${tableName} after ${results.join(', ') || 'no tables'} were merged: ${error.message}`)
            }
        }
        results.push(tableName)
    }

    const { error: sequenceError } = await supabase.rpc('sync_data_backup_sequences')
    if (sequenceError) {
        throw new Error(`Data was merged, but ID sequences could not be synchronized: ${sequenceError.message}`)
    }

    return results
}

export function downloadBackupFile(backup) {
    const blob = new Blob([JSON.stringify(backup, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `rhobotechka-backup-${backup.createdAt.slice(0, 10)}.json`
    link.click()
    URL.revokeObjectURL(url)
}
