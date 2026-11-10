import { supabase } from '../supabase/supabase'

export async function getSuppliers({ includeArchived = false } = {}) {
    let query = supabase.from('suppliers').select('*').order('created_at', { ascending: false })
    query = includeArchived ? query.not('archived_at', 'is', null) : query.is('archived_at', null)
    const { data, error } = await query
    if (error) throw new Error(error.message)
    return data
}

export async function saveSupplier(supplier) {
    const payload = {
        supplier_code: supplier.supplier_code.trim(),
        company_name: supplier.company_name.trim(),
        contact_person: supplier.contact_person.trim() || null,
        contact_number: supplier.contact_number.trim() || null,
        email: supplier.email.trim() || null,
        location: supplier.location.trim() || null,
        supplier_type: supplier.supplier_type,
        updated_at: new Date().toISOString()
    }

    let query = supabase.from('suppliers')
    if (supplier.id) query = query.update(payload).eq('id', supplier.id)
    else query = query.insert(payload)

    const { data, error } = await query.select().single()
    if (error) throw new Error(error.message)
    return data
}

export async function archiveSupplier(supplierId) {
    const { error } = await supabase.from('suppliers')
        .update({ archived_at: new Date().toISOString(), updated_at: new Date().toISOString() })
        .eq('id', supplierId)
    if (error) throw new Error(error.message)
}

export async function restoreSupplier(supplierId) {
    const { error } = await supabase.from('suppliers')
        .update({ archived_at: null, updated_at: new Date().toISOString() })
        .eq('id', supplierId)
    if (error) throw new Error(error.message)
}

export async function deleteSupplier(supplierId) {
    const { error } = await supabase.from('suppliers').delete().eq('id', supplierId)
    if (error) throw new Error(error.message)
}
