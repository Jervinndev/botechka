import { supabase } from '../supabase/supabase'

const archiveTables = {
    Medicines: { table: 'medicines', idColumn: 'id' },
    Beneficiaries: { table: 'beneficiaries', idColumn: 'beneficiary_id' },
    Suppliers: { table: 'suppliers', idColumn: 'id' }
}

export async function getArchivedRecords() {
    const records = []
    for (const [type, config] of Object.entries(archiveTables)) {
        const { data, error } = await supabase.from(config.table)
            .select('*')
            .not('archived_at', 'is', null)
            .order('archived_at', { ascending: false })
        if (error) throw new Error(`Unable to load archived ${type.toLowerCase()}: ${error.message}`)

        for (const row of data || []) {
            const name = type === 'Medicines'
                ? row.medicine_name
                : type === 'Beneficiaries'
                    ? [row.first_name, row.middle_name, row.last_name, row.suffix].filter(Boolean).join(' ')
                    : row.company_name
            records.push({
                id: row[config.idColumn],
                type,
                name: name || row.email || 'Unnamed record',
                code: row.medicine_id || row.beneficiary_code || row.supplier_code || row[config.idColumn],
                archivedAt: row.archived_at,
                row
            })
        }
    }

    return records.sort((a, b) => new Date(b.archivedAt) - new Date(a.archivedAt))
}

export async function setRecordArchived(type, id, archived) {
    const config = archiveTables[type]
    if (!config) throw new Error('Unsupported archive record type.')

    const { error } = await supabase.from(config.table)
        .update({
            archived_at: archived ? new Date().toISOString() : null,
            ...(type === 'Suppliers' ? { updated_at: new Date().toISOString() } : {})
        })
        .eq(config.idColumn, id)
    if (error) throw new Error(error.message)
}

export async function permanentlyDeleteSupplier(id) {
    const { error } = await supabase.from('suppliers').delete().eq('id', id)
    if (error) throw new Error(error.message)
}
