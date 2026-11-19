import { supabase } from '../supabase/supabase.js'

export async function getMyBeneficiaryDashboardData() {
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError) throw new Error(authError.message)
    if (!user) throw new Error('You must be signed in to view your dashboard.')

    const { data: beneficiary, error: beneficiaryError } = await supabase
        .from('beneficiaries')
        .select('beneficiary_id, eligibility, next_dispensing_date')
        .eq('profile_id', user.id)
        .maybeSingle()

    if (beneficiaryError) throw new Error(beneficiaryError.message)
    if (!beneficiary) return { beneficiary: null, history: [] }

    const { data: history, error: historyError } = await supabase
        .from('distribution_transactions')
        .select(`
            distribution_transaction_id,
            distribution_date,
            purpose,
            distribution_items(quantity, medicine_name, unit)
        `)
        .eq('beneficiary_id', beneficiary.beneficiary_id)
        .is('returned_at', null)
        .is('voided_at', null)
        .order('distribution_date', { ascending: false })

    if (historyError) throw new Error(historyError.message)

    return { beneficiary, history: history || [] }
}
