import { supabase } from '../supabase/supabase.js'

const requestFields = `
    request_id,
    requester_id,
    beneficiary_name,
    beneficiary_type,
    medicine_id,
    medicine_name,
    medicine_dosage,
    medicine_unit,
    quantity,
    purpose,
    prescription_path,
    status,
    created_at,
    reviewed_at,
    rejection_reason
`

export async function getAvailableRequestMedicines() {
    const { data, error } = await supabase
        .from('medicines')
        .select('id, medicine_name, dosage, unit, quantity')
        .is('archived_at', null)
        .gt('quantity', 0)
        .order('medicine_name', { ascending: true })

    if (error) throw new Error(error.message)

    return data
}

export async function getMyMedicineRequests() {
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError) throw new Error(authError.message)
    if (!user) throw new Error('You must be signed in to view your requests.')

    const { data, error } = await supabase
        .from('medicine_requests')
        .select(requestFields)
        .eq('requester_id', user.id)
        .order('created_at', { ascending: false })

    if (error) throw new Error(error.message)

    return data
}

export async function getAllMedicineRequests() {
    const { data, error } = await supabase
        .from('medicine_requests')
        .select(requestFields)
        .order('created_at', { ascending: false })

    if (error) throw new Error(error.message)

    return data
}

export async function submitMedicineRequest({ medicineId, quantity, purpose, beneficiaryType, prescriptionFile }) {
    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError) throw new Error(authError.message)
    if (!user) throw new Error('You must be signed in to submit a request.')

    const extensionByType = {
        'application/pdf': 'pdf',
        'image/jpeg': 'jpg',
        'image/png': 'png',
        'image/webp': 'webp'
    }
    const extension = extensionByType[prescriptionFile?.type]

    if (!prescriptionFile || !extension) {
        throw new Error('Upload your prescription as a PDF, JPG, PNG, or WebP file.')
    }
    if (prescriptionFile.size > 5 * 1024 * 1024) {
        throw new Error('The prescription file must be 5 MB or smaller.')
    }

    const prescriptionPath = `${user.id}/${crypto.randomUUID()}.${extension}`
    const { error: uploadError } = await supabase.storage
        .from('medicine-prescriptions')
        .upload(prescriptionPath, prescriptionFile, { contentType: prescriptionFile.type, upsert: false })

    if (uploadError) throw new Error(uploadError.message)

    const { data, error } = await supabase.rpc('submit_medicine_request', {
        p_medicine_id: medicineId,
        p_quantity: Number(quantity),
        p_purpose: purpose.trim() || null,
        p_beneficiary_type: beneficiaryType,
        p_prescription_path: prescriptionPath
    })

    if (error) {
        const { error: cleanupError } = await supabase.storage
            .from('medicine-prescriptions')
            .remove([prescriptionPath])
        if (cleanupError) console.error('Failed to remove an unlinked prescription upload:', cleanupError.message)
        throw new Error(error.message)
    }

    return data
}

export async function cancelMedicineRequest(requestId) {
    const { error } = await supabase.rpc('cancel_medicine_request', {
        p_request_id: requestId
    })

    if (error) throw new Error(error.message)
}

export async function updateMedicineRequestStatus(requestId, status) {
    if (!['approved', 'rejected'].includes(status)) {
        throw new Error('Choose a valid request status.')
    }

    const { data: { user }, error: authError } = await supabase.auth.getUser()

    if (authError) throw new Error(authError.message)
    if (!user) throw new Error('You must be signed in to review requests.')

    const { data, error } = await supabase
        .from('medicine_requests')
        .update({
            status,
            reviewed_at: new Date().toISOString(),
            reviewed_by: user.id,
            rejection_reason: null
        })
        .eq('request_id', requestId)
        .eq('status', 'pending')
        .select('request_id')
        .maybeSingle()

    if (error) throw new Error(error.message)
    if (!data) throw new Error('This request has already been reviewed or is no longer available.')
}

export async function getPrescriptionUrl(path) {
    const { data, error } = await supabase.storage
        .from('medicine-prescriptions')
        .createSignedUrl(path, 60)

    if (error) throw new Error(error.message)

    return data.signedUrl
}
