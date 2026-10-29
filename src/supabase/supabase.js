import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabaseConfigError = !supabaseUrl || !supabaseKey
    ? 'Missing Supabase environment variables. Check your .env and Vercel settings.'
    : ''

export const supabase = supabaseConfigError
    ? null
    : createClient(supabaseUrl, supabaseKey)