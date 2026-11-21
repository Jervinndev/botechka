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
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError) throw new Error(authError.message)
    if (!user) throw new Error('You must sign in to update account roles.')

    const { data: currentProfile, error: profileError } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single()
    if (profileError) throw new Error(profileError.message)

    if (currentProfile.role?.toLowerCase() === 'admin') {
        const { error } = await supabase.rpc('admin_update_personnel_role', {
            p_user_id: userId,
            p_role: role
        })
        if (error) throw new Error(error.message)
        return
    }

    const { data, error } = await supabase.functions.invoke('manage-accounts', {
        body: { action: 'update_role', userId, role }
    })

    if (error) throw new Error(error.message)
    if (data?.error) throw new Error(data.error)

    return data
}
