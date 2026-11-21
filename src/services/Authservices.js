import { supabase } from '../supabase/supabase.js'

let cachedMyProfile = null

export function getCachedMyProfile(userId) {
    if (userId && cachedMyProfile?.id !== userId) {
        return null
    }

    return cachedMyProfile
}

// lOGIN USER
export const loginUser = async ({ email, password }) => {
    try {
        cachedMyProfile = null
        const { data, error } = await supabase.auth.signInWithPassword({ email, password })

        if (error) throw error
        const { error: auditError } = await supabase.rpc('log_audit_activity', {
            p_action: 'login',
            p_entity_type: 'Account',
            p_entity_id: data.user.id,
            p_details: {}
        })
        if (auditError) {
            const { error: signOutError } = await supabase.auth.signOut()
            if (signOutError) console.error('Unable to roll back sign-in after the audit log failed:', signOutError.message)
            throw new Error(`Unable to record login activity: ${auditError.message}`)
        }

        return { success: true, data }
    } catch (error) {
        return { success: false, error: error.message }
    }
}

// REGISTER USER
export const registerUser = async ({ email, password, firstName, middleName, lastName, contactNumber, barangay }) => {
    try {
        const { data, error } = await supabase.auth.signUp({
            email,
            password,
            options: {
                emailRedirectTo: `${window.location.origin}/login`,
                data: {
                    fname: firstName.trim(),
                    mname: middleName.trim(),
                    lname: lastName.trim(),
                    contactnumber: contactNumber.trim(),
                    barangay: barangay.trim()
                }
            }
        })

        if (error) throw error

        return { success: true, data }
    } catch (error) {
        return { success: false, error: error instanceof Error ? error.message : 'Registration failed. Please try again.' }
    }
}

// GET CURRENT SESSION
export async function getSessionUser() {
    try {
        const { data, error } = await supabase.auth.getSession()

        if (error) throw error

        return { success: true, data: data.session }
    } catch (error) {
        return { success: false, error: error.message }
    }
}

// LOGOUT USER
export async function signOutUser() {
    try {
        const { data: { user }, error: userError } = await supabase.auth.getUser()
        if (userError) throw userError
        if (user) {
            const { error: auditError } = await supabase.rpc('log_audit_activity', {
                p_action: 'logout',
                p_entity_type: 'Account',
                p_entity_id: user.id,
                p_details: {}
            })
            if (auditError) throw new Error(`Unable to record logout activity: ${auditError.message}`)
        }

        const { error } = await supabase.auth.signOut()

        if (error) throw error

        cachedMyProfile = null
        return { success: true, data: null }
    } catch (error) {
        return { success: false, error: error.message }
    }
}

export const getMyProfile = async () => {
    try {
        const { data: { user }, error: authError } = await supabase.auth.getUser()

        if (authError) throw authError

        if (!user) {
            throw new Error('You are not authenticated.')
        }

        const { data, error } = await supabase
            .from('profiles')
            .select(`id, fname, mname, lname, contactnumber, barangay, email, role, created_at`)
            .eq('id', user.id)
            .single()

        if (error) throw error

        cachedMyProfile = data
        return { success: true, data }
    } catch (error) {
        return { success: false, error: error instanceof Error ? error.message : 'Unable to fetch profile.' }
    }
}