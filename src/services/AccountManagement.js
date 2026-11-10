import { supabase } from '../supabase/supabase.js'

export async function getManagedAccounts() {
    const { data, error } = await supabase
        .from('profiles')
        .select('id, fname, mname, lname, email, role, created_at')
        .order('created_at', { ascending: false })

    if (error) throw new Error(error.message)

    return data
}

export async function createManagedAccount(account) {
    const { data, error } = await supabase.functions.invoke('manage-accounts', {
        body: { action: 'create', ...account }
    })

    if (error) throw new Error(error.message)
    if (data?.error) throw new Error(data.error)

    return data
}

export async function updateManagedAccountRole(userId, role) {
    const { data, error } = await supabase.functions.invoke('manage-accounts', {
        body: { action: 'update_role', userId, role }
    })

    if (error) throw new Error(error.message)
    if (data?.error) throw new Error(data.error)

    return data
}
