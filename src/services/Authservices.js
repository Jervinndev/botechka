import { supabase } from '../supabase/supabase.js'

let userCache = null
let userRequest = null
let profileCache = null
let profileRequest = null

// lOGIN USER
export const loginUser = async ({ email, password }) => {
    try {
        const { data, error } = await supabase.auth.signInWithPassword({
            email: email,
            password: password,
        })

        if (error) throw error

        const profileResult = await syncUserProfile(data.user)
        if (!profileResult.success) throw new Error(profileResult.error)

        return { success: true, data }
    } catch (error) {
        return { success: false, error: error.message }
    }
}

// REGISTER USER
export const registerUser = async ({ email, password, firstname, lastname, middlename, contact, barangays }) => {
    try {

        const { data, error } = await supabase.auth.signUp({
            email: email,
            password: password,
            options: {
                emailRedirectTo: 'https://botechka.vercel.app/login',
                data: { 
                    f_name: firstname,
                    l_name: lastname,
                    m_name: middlename,
                    contact_number: contact,
                    barangay: barangays,
                    role: 'beneficiary'
                }
            }
        })

        if (error) throw error

        if (data?.session && data?.user) {
            const profileResult = await syncUserProfile(data.user)
            if (!profileResult.success) throw new Error(profileResult.error)
        }

        return { success: true, data }
    } catch (error) {
        return { success: false, error: error.message }
    }
}


// SESSION USER
export async function Gesstsessionuser() {
    try {
        const { data, error } = await supabase.auth.getSession()

        if (error) throw error

        return { success: true, data: data.session }
    } catch (error) {
        return { success: false, error: error.message }
    }
}

// LOGOUT USER
export async function Signoutuser() {
    try {
        const { error } = await supabase.auth.signOut()

        if (error) throw error

        userCache = null
        userRequest = null
        profileCache = null
        profileRequest = null

        return { success: true, data: null }
    } catch (error) {
        return { success: false, error: error.message }
    }
}

// GET USER
export async function Getuserinfo() {
    try {
        if (userCache) return { success: true, data: userCache }
        if (userRequest) return userRequest

        userRequest = supabase.auth.getUser()
            .then(({ data: { user }, error }) => {
                if (error) throw error
                userCache = user
                return { success: true, data: user }
            })
            .catch(error => ({ success: false, error: error.message }))
            .finally(() => {
                userRequest = null
            })

        return userRequest
    } catch (error) {
        return { success: false, error: error.message }
    }
}

// FETCH PROFILE
export async function Getuserprofile() {
    try {
        if (profileCache) return { success: true, data: profileCache }
        if (profileRequest) return profileRequest

        profileRequest = Getuserinfo()
            .then(async userResult => {
                if (!userResult.success) throw new Error(userResult.error)
                if (!userResult.data) throw new Error('No authenticated user found')

                const { data, error } = await supabase
                    .from('profiles')
                    .select('f_name, m_name, l_name, role')
                    .eq('id', userResult.data.id)
                    .single()

                if (error) throw erro
                profileCache = data
                return { success: true, data }
            })
            .catch(error => ({ success: false, error: error.message }))
            .finally(() => {
                profileRequest = null
            })

        return profileRequest
    } catch (error) {
        return { success: false, error: error.message }
    }
}

// CREATE OR UPDATE THE PROFILE AFTER SUPABASE AUTHENTICATES THE USER
export async function syncUserProfile(user) {
    try {
        if (!user) throw new Error('No authenticated user found')

        const metadata = user.user_metadata || {}

        let firstName = metadata.f_name
        let lastName = metadata.l_name

        if (!firstName && (metadata.full_name || metadata.name)) {
            const fullName = metadata.full_name || metadata.name
            const nameParts = fullName.split(' ')
            firstName = nameParts[0] || ''
            lastName = nameParts.slice(1).join(' ') || ''
        }

        if (!firstName) {
            return { success: true, data: null }
        }

        const { data, error } = await supabase
            .from('profiles')
            .upsert({
                id: user.id,
                f_name: firstName,
                l_name: lastName || '',
                m_name: metadata.m_name || '',
                contact_number: metadata.contact_number || '',
                barangay: metadata.barangay || '',
                role: metadata.role || 'beneficiary'
            }, { onConflict: 'id' })
            .select()
            .single()

        if (error) throw error

        userCache = user
        profileCache = data

        return { success: true, data }
    } catch (error) {
        return { success: false, error: error.message }
    }
}

// LOGIN / REGISTER GAMIT ANG GOOGLE
// export const signInWithProvider = async (provider) => {
//     try {
//         const { data, error } = await supabase.auth.signInWithOAuth({
//             provider: provider,
//             options: {
//                 redirectTo: `${window.location.origin}/beneficiary-dashboard`
//             }
//         })
//         if (error) throw error
//         return { success: true, data }
//     } catch (error) {
//         return { success: false, error: error.message }
//     }
// }