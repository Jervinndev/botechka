import { supabase } from '../supabase/supabase'

export async function forgotPassword(email) {
    const { error } = await supabase.auth.resetPasswordForEmail(
        email,
        {
            redirectTo: 'https://botechka.vercel.app/reset-password'
        }
    )

    if (error) {
        throw error
    }

    return true
}