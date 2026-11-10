import { supabase } from '../supabase/supabase.js'

export async function getDistributionPurposes() {
    const { data, error } = await supabase
        .from('distribution_purposes')
        .select('purpose_id, purpose_name, description')
        .order('purpose_name', { ascending: true })

    if (error) throw new Error(error.message)

    return data
}

export async function addDistributionPurpose({ purposeName, description }) {
    const { data, error } = await supabase
        .from('distribution_purposes')
        .insert({
            purpose_name: purposeName.trim(),
            description: description.trim() || null
        })
        .select('purpose_id, purpose_name, description')
        .single()

    if (error) throw new Error(error.message)

    return data
}

export async function getDistributionTransactions() {
    const { data, error } = await supabase
        .from('distribution_transactions')
        .select(`
            distribution_transaction_id,
            distribution_date,
            purpose,
            beneficiaries(first_name, middle_name, last_name, suffix, beneficiary_type),
            returned_at,
            distribution_items(quantity, medicine_name, medicine_image_url, unit, medicine:medicines(category))
        `)
        .order('distribution_date', { ascending: false })

    if (error) throw new Error(error.message)

    return data
}

export async function returnDistributionTransaction(transactionId) {
    const { data, error } = await supabase.rpc('return_distribution_transaction', {
        p_distribution_transaction_id: transactionId
    })

    if (error) throw new Error(error.message)

    return data
}

export async function dispenseDistribution({ beneficiaryId, distributionDate, purpose, items }) {
    const { data, error } = await supabase.rpc('dispense_distribution', {
        p_beneficiary_id: beneficiaryId,
        p_distribution_date: distributionDate,
        p_purpose: purpose,
        p_items: items.map(({ id, quantity }) => ({
            medicine_id: id,
            quantity
        }))
    })

    if (error) throw new Error(error.message)

    return data
}
