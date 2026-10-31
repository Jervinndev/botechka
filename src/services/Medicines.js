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

export async function AddMedicine(MedicineData, imageFile = null) {
    let uploadedPath = null;

    try {
        let imageUrl = null;

        if (imageFile) {
            const ext = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/webp': 'webp' }[imageFile.type];
            if (!ext) throw new Error('Choose a JPG, PNG, or WebP image.');
            if (imageFile.size > 2 * 1024 * 1024) throw new Error('Image must be 2 MB or smaller.');

            uploadedPath = `${crypto.randomUUID()}.${ext}`;
            
            const { error: uploadError } = await supabase.storage
                .from('medicine-images')
                .upload(uploadedPath, imageFile);

            if (uploadError) throw uploadError;

            imageUrl = supabase.storage.from('medicine-images').getPublicUrl(uploadedPath).data.publicUrl;
        }

        const finalData = { ...MedicineData, ...(imageUrl && { image_url: imageUrl }) };

        const { data, error } = await supabase
            .from('medicines')
            .insert([finalData])
            .select();

        if (error) throw error;
        return { data, error: null };

    } catch (error) {
        if (uploadedPath) {
            await supabase.storage.from('medicine-images').remove([uploadedPath]);
        }
        console.error('Error in AddMedicine service:', error.message);
        return { data: null, error };
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