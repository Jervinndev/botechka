import { supabase } from '../supabase/supabase.js'

export async function getBeneficiaries() {
    try {
        const { data, error } = await supabase
            .from('beneficiaries')
            .select('*')
            .order('created_at', { ascending: false })

        if (error) throw error
        return { data, error: null }
    } catch (error) {
        console.error('Error in getBeneficiaries service:', error.message)
        return { data: null, error }
    }
}

export async function addBeneficiary(beneficiaryData) {
    try {
        const { data, error } = await supabase
            .from('beneficiaries')
            .insert([beneficiaryData])
            .select()
            .single()

        if (error) throw error
        return { data, error: null }
    } catch (error) {
        console.error('Error in addBeneficiary service:', error.message)
        return { data: null, error }
    }
}
