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
            medicine_request_id,
            distribution_date,
            purpose,
            beneficiaries(first_name, middle_name, last_name, suffix, beneficiary_type),
            returned_at,
            voided_at,
            distribution_items(
                distribution_item_id, quantity, unit_price, medicine_name, medicine_image_url, unit,
                medicine:medicines(category),
                distribution_returns(quantity, medicine_condition, beneficiary_credit)
            )
        `)
        .order('distribution_date', { ascending: false })

    if (error) throw new Error(error.message)

    return data
}

export async function returnDistributionItems({ transactionId, items }) {
    const { data, error } = await supabase.rpc('return_distribution_items', {
        p_distribution_transaction_id: transactionId,
        p_items: items.map(({ distributionItemId, quantity, condition }) => ({
            distribution_item_id: distributionItemId,
            quantity: Number(quantity),
            medicine_condition: condition
        }))
    })

    if (error) throw new Error(error.message)

    return data
}

export async function voidDistributionTransaction(transactionId) {
    const { data, error } = await supabase.rpc('void_distribution_with_benefit_credit', {
        p_distribution_transaction_id: transactionId
    })

    if (error) throw new Error(error.message)

    return data
}

export async function dispenseDistribution({ beneficiaryId, distributionDate, purpose, items, medicineRequestId = null }) {
    const { data, error } = await supabase.rpc('dispense_distribution_workflow', {
        p_beneficiary_id: beneficiaryId,
        p_distribution_date: distributionDate,
        p_purpose: purpose,
        p_medicine_request_id: medicineRequestId,
        p_items: items.map(({ id, quantity }) => ({
            medicine_id: id,
            quantity
        }))
    })

    if (error) throw new Error(error.message)

    return data
}
