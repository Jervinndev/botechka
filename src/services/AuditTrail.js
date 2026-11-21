import { supabase } from '../supabase/supabase.js'

const auditFields = `
    audit_log_id,
    user_id,
    user_name,
    user_email,
    user_role,
    action,
    entity_type,
    entity_id,
    details,
    created_at
`

export async function getMyActivityLog() {
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError) throw new Error(authError.message)
    if (!user) throw new Error('You must be signed in to view your activity.')

    const { data, error } = await supabase
        .from('audit_logs')
        .select(auditFields)
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(100)

    if (error) throw new Error(error.message)
    return data || []
}

export async function getAuditTrail() {
    const { data, error } = await supabase
        .from('audit_logs')
        .select(auditFields)
        .order('created_at', { ascending: false })
        .limit(500)

    if (error) throw new Error(error.message)
    return data || []
}
