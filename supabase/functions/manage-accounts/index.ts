import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS'
}

Deno.serve(async (request) => {
    if (request.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    if (request.method !== 'POST') {
        return respond({ error: 'Method not allowed.' }, 405)
    }

    const url = Deno.env.get('SUPABASE_URL')
    const anonKey = Deno.env.get('SUPABASE_ANON_KEY')
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
    const authorization = request.headers.get('Authorization')

    if (!url || !anonKey || !serviceRoleKey) {
        console.error('Required Supabase function environment variables are missing.')
        return respond({ error: 'Account management is not configured.' }, 500)
    }

    if (!authorization?.startsWith('Bearer ')) {
        return respond({ error: 'Authentication is required.' }, 401)
    }

    try {
        const userClient = createClient(url, anonKey, {
            global: { headers: { Authorization: authorization } },
            auth: { persistSession: false }
        })
        const { data: { user }, error: authError } = await userClient.auth.getUser()
        if (authError || !user) return respond({ error: 'Authentication is required.' }, 401)

        const adminClient = createClient(url, serviceRoleKey, {
            auth: { persistSession: false }
        })
        const { data: callerProfile, error: profileError } = await adminClient
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single()

        if (profileError) throw profileError
        if (callerProfile.role?.toLowerCase() !== 'super_admin') {
            return respond({ error: 'Only super admins can manage accounts.' }, 403)
        }

        const body = await request.json()
        const validRoles = ['super_admin', 'admin', 'personnel', 'beneficiary']

        if (body.action === 'create') {
            const email = String(body.email || '').trim().toLowerCase()
            const password = String(body.password || '')
            const firstName = String(body.firstName || '').trim()
            const middleName = String(body.middleName || '').trim()
            const lastName = String(body.lastName || '').trim()
            const contactNumber = String(body.contactNumber || '').trim()
            const barangay = String(body.barangay || '').trim()
            const role = String(body.role || '').toLowerCase()

            if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                return respond({ error: 'Enter a valid email address.' }, 400)
            }
            if (password.length < 8) return respond({ error: 'Password must be at least 8 characters.' }, 400)
            if (!firstName || !lastName || !contactNumber || !barangay || !validRoles.includes(role)) {
                return respond({ error: 'Complete all required fields and choose a valid role.' }, 400)
            }

            const { data: createdUser, error: createError } = await adminClient.auth.admin.createUser({
                email,
                password,
                email_confirm: true,
                user_metadata: {
                    fname: firstName,
                    mname: middleName,
                    lname: lastName,
                    contactnumber: contactNumber,
                    barangay
                }
            })
            if (createError) throw createError

            const { error: roleError } = await adminClient
                .from('profiles')
                .update({ role })
                .eq('id', createdUser.user.id)
            if (roleError) {
                const { error: deleteError } = await adminClient.auth.admin.deleteUser(createdUser.user.id)
                if (deleteError) console.error('Failed to clean up account after role assignment failed:', deleteError)
                throw roleError
            }

            return respond({ userId: createdUser.user.id })
        }

        if (body.action === 'update_role') {
            const userId = String(body.userId || '')
            const role = String(body.role || '').toLowerCase()
            if (!userId || !validRoles.includes(role)) {
                return respond({ error: 'Choose a valid account and role.' }, 400)
            }
            if (userId === user.id) {
                return respond({ error: 'You cannot change your own account role.' }, 400)
            }

            const { data: target, error: targetError } = await adminClient
                .from('profiles')
                .select('role')
                .eq('id', userId)
                .single()
            if (targetError) throw targetError

            if (target.role?.toLowerCase() === 'super_admin' && role !== 'super_admin') {
                const { count, error: countError } = await adminClient
                    .from('profiles')
                    .select('id', { count: 'exact', head: true })
                    .eq('role', 'super_admin')
                if (countError) throw countError
                if (count <= 1) return respond({ error: 'At least one super admin account must remain.' }, 400)
            }

            const { error: updateError } = await adminClient
                .from('profiles')
                .update({ role })
                .eq('id', userId)
            if (updateError) throw updateError

            return respond({ userId })
        }

        return respond({ error: 'Unsupported account management action.' }, 400)
    } catch (error) {
        console.error('Account management request failed:', error)
        return respond({ error: error instanceof Error ? error.message : 'Account management failed.' }, 400)
    }
})

function respond(body: unknown, status = 200) {
    return new Response(JSON.stringify(body), {
        status,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
}
