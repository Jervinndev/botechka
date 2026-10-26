<script setup>
import { computed, ref, watch } from 'vue'
import { Plus, X } from '@lucide/vue'
import { supabase } from '../../supabase/supabase.js'
import { addMedicineStock } from '../../services/Medicines'
import { addDaysToDate, getEarlierDate, getLaterDate, getLocalDateString } from '../../utils/dates'

const props = defineProps({
    IsOpen: Boolean
})

const emit = defineEmits(['close', 'saved'])

const Isloading = ref(false)
const errorMessage = ref('')
const medicines = ref([])
const isNewBatch = ref(false)
const today = getLocalDateString()

const formData = ref({
    selectedMedicine: '',
    quantity: 1,
    batch_number: '',
    supplier: '',
    manufacturing_date: '',
    expiration_date: ''
})

const selectedMedicine = ref(null)
const manufacturingDateMax = computed(() =>
    getEarlierDate(today, addDaysToDate(formData.value.expiration_date, -1))
)
const expirationDateMin = computed(() =>
    getLaterDate(addDaysToDate(today, 1), addDaysToDate(formData.value.manufacturing_date, 1))
)

async function fetchMedicines() {
    errorMessage.value = ''
    const { data, error } = await supabase
        .from('medicines')
        .select('id, medicine_id, medicine_name, category, dosage, unit, quantity, batch_number, supplier, manufacturing_date, expiration_date')
        .order('medicine_name')

    if (error) {
        errorMessage.value = 'Failed to load medicines.'
        console.error(error)
        medicines.value = []
        return
    }

    medicines.value = data || []
}

function selectMedicine() {
    selectedMedicine.value = medicines.value.find(
        medicine => medicine.id === formData.value.selectedMedicine
    ) || null

    formData.value.quantity = 1
    formData.value.batch_number = selectedMedicine.value?.batch_number || ''
    formData.value.supplier = selectedMedicine.value?.supplier || ''
    formData.value.manufacturing_date = selectedMedicine.value?.manufacturing_date || ''
    formData.value.expiration_date = selectedMedicine.value?.expiration_date || ''
    isNewBatch.value = false
}

function toggleNewBatch() {
    if (isNewBatch.value && selectedMedicine.value) {
        formData.value.batch_number = selectedMedicine.value.batch_number || ''
        formData.value.supplier = selectedMedicine.value.supplier || ''
        formData.value.manufacturing_date = selectedMedicine.value.manufacturing_date || ''
        formData.value.expiration_date = selectedMedicine.value.expiration_date || ''
    }

    isNewBatch.value = !isNewBatch.value
    errorMessage.value = ''
}

function resetForm() {
    formData.value = {
        selectedMedicine: '',
        quantity: 1,
        batch_number: '',
        supplier: '',
        manufacturing_date: '',
        expiration_date: ''
    }

    selectedMedicine.value = null
    isNewBatch.value = false
    errorMessage.value = ''
}

function closeModal() {
    resetForm()
    emit('close')
}

async function saveStock() {
    errorMessage.value = ''

    if (!selectedMedicine.value) {
        errorMessage.value = 'Please select a medicine.'
        return
    }

    if (!formData.value.quantity || Number(formData.value.quantity) < 1) {
        errorMessage.value = 'Quantity to add must be at least 1.'
        return
    }

    if (isNewBatch.value) {
        if (
            !formData.value.batch_number.trim() ||
            !formData.value.supplier.trim() ||
            !formData.value.manufacturing_date ||
            !formData.value.expiration_date
        ) {
            errorMessage.value = 'Please complete all required new batch fields.'
            return
        }

        if (formData.value.expiration_date <= formData.value.manufacturing_date) {
            errorMessage.value = 'Expiration date must be after the manufacturing date.'
            return
        }

        if (formData.value.manufacturing_date > today) {
            errorMessage.value = 'Manufacturing date cannot be in the future.'
            return
        }

        if (formData.value.expiration_date <= today) {
            errorMessage.value = 'Expiration date must be in the future.'
            return
        }
    }

    Isloading.value = true

    try {
        const medicine = selectedMedicine.value
        const quantity = Number(medicine.quantity || 0) + Number(formData.value.quantity)
        const stockDetails = isNewBatch.value ? {
            batch_number: formData.value.batch_number.trim(),
            supplier: formData.value.supplier.trim(),
            manufacturing_date: formData.value.manufacturing_date,
            expiration_date: formData.value.expiration_date
        } : null
        const response = await addMedicineStock(medicine.id, quantity, stockDetails)

        if (response.error) {
            throw response.error
        }

        emit('saved', response.data?.[0])
        closeModal()
    } catch (error) {
        console.error('Failed to add stock:', error)
        errorMessage.value = error.message || 'Failed to add stock.'
    } finally {
        Isloading.value = false
    }
}

watch(() => props.IsOpen, isOpen => {
    if (isOpen) fetchMedicines()
})
</script>

<template>
    <Transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0 -translate-y-2"
        enter-to-class="opacity-100 translate-y-0" leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100 translate-y-0" leave-to-class="opacity-0 -translate-y-2">
        <section v-if="IsOpen"
            class="fixed inset-0 z-50 flex h-full w-full items-center justify-center overflow-y-auto bg-black/40 backdrop-blur-xs p-4">
            <div class="max-h-[calc(100vh-2rem)] w-full max-w-2xl overflow-y-auto rounded-xl bg-white p-6 font-inter shadow-xl">
                <form @submit.prevent="saveStock">
                    <div class="flex items-start justify-between">
                        <div>
                            <h1 class="mt-2 font-inter text-2xl font-bold text-[#404040]">Add New Stock</h1>
                            <p class="font-inter text-sm font-medium text-[#808080]">Select an existing medicine and add to its quantity.</p>
                        </div>
                        <div class="flex items-center gap-2">
                            <button type="button" @click="toggleNewBatch" :disabled="!selectedMedicine"
                                class="flex items-center gap-1 rounded-xl bg-blue-700 p-2 px-3 text-sm text-white transition hover:bg-blue-800 disabled:cursor-not-allowed disabled:opacity-50">
                                <Plus :size="16" />
                                {{ isNewBatch ? 'Cancel New Batch' : 'New Batch' }}
                            </button>
                            <button type="button" @click="closeModal"
                                class="cursor-pointer rounded-xl p-1 text-gray-400 transition hover:bg-gray-100 hover:text-[#404040]">
                                <X :size="22" />
                            </button>
                        </div>
                    </div>

                    <div v-if="errorMessage"
                        class="mt-4 rounded-lg bg-red-50 p-2 text-sm text-red-600">
                        {{ errorMessage }}
                    </div>

                    <div class="mt-6 grid grid-cols-1 gap-6">
                        <div class="grid gap-1">
                            <label class="font-inter text-sm font-medium text-[#404040]">Medicine <span
                                    class="text-red-500">*</span></label>
                            <select v-model="formData.selectedMedicine" @change="selectMedicine"
                                class="w-full cursor-pointer rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                                required>
                                <option value="">-- Select Medicine --</option>
                                <option v-for="medicine in medicines" :key="medicine.id" :value="medicine.id">
                                    {{ medicine.medicine_name }} ({{ medicine.medicine_id }})
                                </option>
                            </select>
                            <p v-if="medicines.length === 0" class="text-xs text-gray-500">No medicines found. Add a
                                medicine first.</p>
                        </div>

                        <div class="grid gap-2">
                            <h2 class="font-inter text-lg font-semibold text-[#404040]">Identity</h2>
                            <div class="mt-2 grid grid-cols-1 gap-3 sm:grid-cols-2">
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Medicine name</label>
                                    <input :value="selectedMedicine?.medicine_name || ''" type="text" disabled
                                        class="w-full cursor-not-allowed rounded-lg border border-gray-200 bg-gray-100 p-2 text-slate-600">
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Medicine ID</label>
                                    <input :value="selectedMedicine?.medicine_id || ''" type="text" disabled
                                        class="w-full cursor-not-allowed rounded-lg border border-gray-200 bg-gray-100 p-2 text-slate-600">
                                </div>
                                <div class="grid gap-1 sm:col-span-2">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Category</label>
                                    <input :value="selectedMedicine?.category || ''" type="text" disabled
                                        class="w-full cursor-not-allowed rounded-lg border border-gray-200 bg-gray-100 p-2 text-slate-600">
                                </div>
                            </div>
                        </div>

                        <div class="grid gap-2">
                            <h2 class="font-inter text-lg font-semibold text-[#404040]">Stock</h2>
                            <div class="mt-2 grid grid-cols-1 gap-3 sm:grid-cols-3">
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Quantity to Add <span
                                            class="text-red-500">*</span></label>
                                    <input v-model.number="formData.quantity" type="number" min="1"
                                        placeholder="e.g. 100"
                                        class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                                        required>
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Dosage</label>
                                    <input :value="selectedMedicine?.dosage || ''" type="text" disabled
                                        class="w-full cursor-not-allowed rounded-lg border border-gray-200 bg-gray-100 p-2 text-slate-600">
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Unit</label>
                                    <input :value="selectedMedicine?.unit || ''" type="text" disabled
                                        class="w-full cursor-not-allowed rounded-lg border border-gray-200 bg-gray-100 p-2 text-slate-600">
                                </div>
                            </div>
                            <p v-if="selectedMedicine" class="font-inter text-sm font-medium text-[#808080]">
                                Current stock: {{ selectedMedicine.quantity ?? 0 }} {{ selectedMedicine.unit }}
                            </p>
                        </div>

                        <div class="grid gap-2">
                            <h2 class="font-inter text-lg font-semibold text-[#404040]">Batch and Supplier</h2>
                            <div class="mt-2 grid grid-cols-1 gap-3 sm:grid-cols-2">
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Batch number</label>
                                    <input v-model="formData.batch_number" type="text" placeholder="e.g. BATCH-A1"
                                        :disabled="!isNewBatch"
                                        class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 uppercase focus:outline-none focus:ring-2 focus:ring-blue-700 disabled:cursor-not-allowed disabled:bg-gray-100 disabled:text-slate-600"
                                        :required="isNewBatch">
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Supplier name</label>
                                    <input v-model="formData.supplier" type="text" placeholder="e.g. Metro Drug"
                                        :disabled="!isNewBatch"
                                        class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700 disabled:cursor-not-allowed disabled:bg-gray-100 disabled:text-slate-600"
                                        :required="isNewBatch">
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Manufacturing Date</label>
                                    <input v-model="formData.manufacturing_date" type="date"
                                        :max="manufacturingDateMax" :disabled="!isNewBatch"
                                        class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700 disabled:cursor-not-allowed disabled:bg-gray-100 disabled:text-slate-600"
                                        :required="isNewBatch">
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Expiration date</label>
                                    <input v-model="formData.expiration_date" type="date"
                                        :min="expirationDateMin" :disabled="!isNewBatch"
                                        class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700 disabled:cursor-not-allowed disabled:bg-gray-100 disabled:text-slate-600"
                                        :required="isNewBatch">
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="mt-6 flex items-center justify-end gap-2">
                        <button type="button" @click="closeModal"
                            class="cursor-pointer rounded-xl bg-gray-100 p-2 px-4 text-[#404040] transition hover:bg-gray-200">Cancel</button>
                        <button type="submit" :disabled="Isloading || medicines.length === 0"
                            class="cursor-pointer rounded-xl bg-blue-700 p-2 px-5 text-white transition hover:bg-blue-800 disabled:cursor-not-allowed disabled:opacity-60">
                            <span v-if="Isloading">Adding Stock...</span>
                            <span v-else>Add Stock</span>
                        </button>
                    </div>
                </form>
            </div>
        </section>
    </Transition>
</template>
