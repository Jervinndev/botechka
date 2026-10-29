import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://gmedqxgciccqaaiikojl.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdtZWRxeGdjaWNjcWFhaWlrb2psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODc2NDU1MTEsImV4cCI6MjEwMzIyMTUxMX0.5TIRarphnSdLoXLiQe2_ZSqDfvX2_ettCjtCSfNp8Gk'

export const supabase = createClient(supabaseUrl, supabaseKey)