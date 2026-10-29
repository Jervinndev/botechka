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
            .select(`id, fname, mname, lname, contactnumber, barangay, email, role`)
            .eq('id', user.id)
            .single()

        if (error) throw error

        cachedMyProfile = data
        return { success: true, data }
    } catch (error) {
        return { success: false, error: error instanceof Error ? error.message : 'Unable to fetch profile.' }
    }
}