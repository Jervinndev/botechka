import { supabase } from '../supabase/supabase.js'

export async function getMedicines() {
    const { data, error } = await supabase
        .from('medicines')
        .select('*')
        .order('created_at', { ascending: false })

    if (error) throw new Error(error.message)

    return data
}

export async function getCategories() {
    const { data, error } = await supabase
        .from('medicine_categories')
        .select('*')
        .order('created_at', { ascending: false })

    if (error) throw new Error(error.message)

    return data
}

export async function getMedicinesByCategory(categoryName) {
    const { data, error } = await supabase
        .from('medicines')
        .select('*')
        .eq('category', categoryName)
        .order('medicine_name', { ascending: true })

    if (error) throw new Error(error.message)

    return data
}