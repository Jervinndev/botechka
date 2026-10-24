import { supabase } from '../supabase/supabase.js'

export async function addCategory(categoryData) {
    try {
        const { data, error } = await supabase
            .from('medicine_categories')
            .insert([
                {
                    category_name: categoryData.name,
                    description: categoryData.description,
                    status: 'active'
                }
            ])
            .select()

        if (error) throw error
        return { data, error: null }
    } catch (error) {
        console.error('Error in addCategory service:', error.message)
        return { data: null, error }
    }
}

export async function updateCategoryStatus(categoryId, status) {
    const { data, error } = await supabase
        .from('medicine_categories')
        .update({ status })
        .eq('id', categoryId)
        .select()
        .single()

    if (error) throw new Error(error.message)

    return data
}

export async function Addmedicines(MedicineData) {
    try {
        const { data, error } = await supabase
            .from('medicines')
            .insert(MedicineData)
            .select()

        if (error) throw error
        return { data, error: null }
    } catch (error) {
        console.error('Error in Addmedicines service:', error.message)
        return { data: null, error }
    }
}

export async function addMedicineStock(medicineId, quantity, stockDetails) {
    try {
        const updates = { quantity }

        if (stockDetails) {
            Object.assign(updates, stockDetails)
        }

        const { data, error } = await supabase
            .from('medicines')
            .update(updates)
            .eq('id', medicineId)
            .select()

        if (error) throw error
        return { data, error: null }
    } catch (error) {
        console.error('Error in addMedicineStock service:', error.message)
        return { data: null, error }
    }
}