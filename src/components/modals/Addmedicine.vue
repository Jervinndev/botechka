<script setup>
import { computed, ref, watch } from 'vue'
import { X } from '@lucide/vue'
import { Addmedicines } from '../../services/Medicines'
import { getCategories } from '../../services/Fetches'
import { addDaysToDate, getEarlierDate, getLaterDate, getLocalDateString } from '../../utils/dates'

const props = defineProps({
    IsOpen: Boolean
})
const emit = defineEmits(['close', 'saved'])

const Isloading = ref(false)
const errorMessage = ref('')
const categories = ref([])

const dosages = ref([
    { id: 1, dosage_name: 'Tablet' },
    { id: 2, dosage_name: 'Capsule' },
    { id: 3, dosage_name: 'Syrup' },
    { id: 4, dosage_name: 'Injection' },
    { id: 5, dosage_name: 'Cream' },
    { id: 6, dosage_name: 'Ointment' },
    { id: 7, dosage_name: 'Drops' },
    { id: 8, dosage_name: 'Inhaler' }
])

const units = ref([
    { id: 1, unit_name: 'mg' },
    { id: 2, unit_name: 'ml' },
    { id: 3, unit_name: 'g' },
    { id: 4, unit_name: 'IU' },
    { id: 5, unit_name: 'mcg' }
])

const createDefaultForm = () => ({
    medicine_name: '',
    medicine_id: `MED-${crypto.randomUUID().slice(0, 8).toUpperCase()}`,
    category: '',
    quantity: 0,
    dosage: '',
    unit: '',
    batch_number: '',
    supplier: '',
    manufacturing_date: '',
    expiration_date: ''
})

const formData = ref(createDefaultForm())
const today = getLocalDateString()
const manufacturingDateMax = computed(() =>
    getEarlierDate(today, addDaysToDate(formData.value.expiration_date, -1))
)
const expirationDateMin = computed(() =>
    getLaterDate(addDaysToDate(today, 1), addDaysToDate(formData.value.manufacturing_date, 1))
)

async function fetchCategories() {
    try {
        categories.value = await getCategories()
    } catch (error) {
        console.error('Failed to load med   icine categories:', error)
        categories.value = []
        errorMessage.value = 'Failed to load medicine categories.'
    }
}

function resetForm() {
    formData.value = createDefaultForm()
    errorMessage.value = ''
}

watch(() => props.IsOpen, isOpen => {
    if (isOpen) fetchCategories()
})

function closeModal() {
    resetForm()
    emit('close')
}

async function saveMedicine() {
    Isloading.value = true
    errorMessage.value = ''

    try {
        const payload = {
            ...formData.value,
            medicine_name: formData.value.medicine_name.trim(),
            batch_number: formData.value.batch_number.trim(),
            supplier: formData.value.supplier.trim(),
            quantity: Number(formData.value.quantity)
        }

        if (!payload.medicine_name || !payload.category || !payload.dosage || !payload.unit || !payload.batch_number || !payload.supplier || !payload.manufacturing_date || !payload.expiration_date) {
            throw new Error('Please fill in all required fields.')
        }

        if (Number(payload.quantity) < 0) {
            throw new Error('Quantity cannot be negative.')
        }

        if (payload.manufacturing_date > today) {
            throw new Error('Manufacturing date cannot be in the future.')
        }

        if (payload.expiration_date <= today) {
            throw new Error('Expiration date must be in the future.')
        }

        if (payload.expiration_date <= payload.manufacturing_date) {
            throw new Error('Expiration date must be after the manufacturing date.')
        }

        const response = await Addmedicines(payload)

        if (response.error) {
            throw response.error
        }

        const savedMedicine = response.data?.[0] ?? payload
        console.log('Medicine successfully saved:', savedMedicine)

        emit('saved', savedMedicine)
        resetForm()
        emit('close')
    } catch (error) {
        console.error('Failed to save medicine:', error)
        errorMessage.value = error instanceof Error ? error.message : 'Failed to save medicine.'
    } finally {
        Isloading.value = false
    }
}
</script>

<template>
    <!-- Success Alert -->
    <!-- <div
        class="fixed top-4 right-4 z-50 bg-blue-700 text-white px-6 py-3 rounded-lg shadow-lg flex items-center gap-2 animate-in fade-in slide-in-from-top-2 duration-300">
        <Check size="20" />
        <span class="font-medium">Medicine saved successfully!</span>
    </div> -->

    <!-- <div class="fixed top-4 right-4 z-50 max-w-md rounded-lg bg-red-600 px-6 py-3 text-white shadow-lg">
        <span class="font-medium">{{ errorMessage }}</span>
    </div> -->

    <!-- Modal Background / Backdrop -->
    <Transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0 -translate-y-2"
        enter-to-class="opacity-100 translate-y-0" leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100 translate-y-0" leave-to-class="opacity-0 -translate-y-2">
        <section v-if="IsOpen"
            class="fixed inset-0 z-30 bg-black/40 w-full h-full flex items-center justify-center p-4 overflow-y-auto">
            <div class="p-6 bg-white max-w-2xl w-full rounded-xl shadow-xl my-8 font-inter">
                <form @submit.prevent="saveMedicine">
                    <div class="flex justify-between items-start">
                        <div>
                            <h1 class="font-black text-[#404040] font-inter text-lg">ADD NEW MEDICINE</h1>
                            <p class="text-sm text-[#808080] font-inter">insert ka muna pare</p>
                        </div>
                        <X class="cursor-pointer text-gray-500 hover:text-black" @click="closeModal" />
                    </div>

                    <div v-if="errorMessage"
                        class="mt-4 rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">
                        {{ errorMessage }}
                    </div>

                    <div class="grid grid-cols-1 gap-4 mt-8">
                        <div class="flex items-center gap-2">
                            <img src="/src/assets/download (12).jpg" alt="" class="w-20 rounded-lg object-cover">
                            <div class="flex flex-col items-start gap-2">
                                <div>
                                    <label for="imageInput"
                                        class="cursor-pointer bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700">
                                        Upload Image
                                    </label>
                                    <input type="file" class="hidden" id="imageInput">
                                </div>
                                <div>
                                    <button type="button" @click="closeModal"
                                        class="bg-gray-100 text-gray-800 py-2 px-4 rounded-lg hover:bg-gray-400">
                                        Cancel
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div class="grid gap-2">
                            <div>
                                <h1 class="text-lg text-blue-700 font-bold">Identity</h1>
                            </div>
                            <div class="grid grid-cols-2 gap-2 mt-1">
                                <div class="grid gap-1">
                                    <label class="font-medium text-sm text-slate-600">Medicine name <span
                                            class="text-red-700">*</span></label>
                                    <input type="text" v-model="formData.medicine_name"
                                        class="p-2 w-full border border-gray-300 rounded-lg placeholder:opacity-50 focus:outline-blue-600"
                                        placeholder="e.g. Biogesic" required>
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-medium text-sm text-slate-600">Medicine ID (Auto) </label>
                                    <input type="text" v-model="formData.medicine_id" readonly
                                        class="p-2 border w-full border-gray-300 rounded-lg bg-gray-100 text-slate-600 cursor-not-allowed">
                                </div>
                                <div class="grid gap-1 col-span-2">
                                    <label class="font-medium text-sm text-slate-600">Category <span
                                            class="text-red-700">*</span></label>
                                    <select v-model="formData.category"
                                        class="p-2 border border-gray-300 rounded-lg bg-white cursor-pointer focus:outline-blue-600"
                                        required>
                                        <option value="">-- Select Category --</option>
                                        <option v-for="category in categories" :key="category.id"
                                            :value="category.category_name">
                                            {{ category.category_name }}
                                        </option>
                                    </select>
                                    <p v-if="categories.length === 0" class="text-xs text-gray-500">
                                        No categories found. Add a category first.
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="grid gap-2">
                            <div>
                                <h1 class="text-lg text-blue-700 font-bold">Stock</h1>
                            </div>
                            <div class="grid grid-cols-3 gap-2 mt-1">
                                <div class="grid gap-1">
                                    <label class="font-medium text-sm text-slate-600">Quantity <span
                                            class="text-red-700">*</span></label>
                                    <input type="number" v-model="formData.quantity"
                                        class="p-2 w-full border border-gray-300 rounded-lg placeholder:opacity-50 focus:outline-blue-600"
                                        placeholder="e.g. 100" min="0" required>
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-medium text-sm text-slate-600">Dosage <span
                                            class="text-red-700">*</span></label>
                                    <select v-model="formData.dosage"
                                        class="p-2 w-full border border-gray-300 rounded-lg bg-white cursor-pointer focus:outline-blue-600"
                                        required>
                                        <option v-for="dosage in dosages" :key="dosage.id" :value="dosage.dosage_name">
                                            {{ dosage.dosage_name }}
                                        </option>
                                    </select>
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-medium text-sm text-slate-600">Unit <span
                                            class="text-red-700">*</span></label>
                                    <select v-model="formData.unit"
                                        class="p-2 w-full border border-gray-300 rounded-lg bg-white cursor-pointer focus:outline-blue-600"
                                        required>
                                        <option value="">-- Select Unit --</option>
                                        <option v-for="unit in units" :key="unit.id" :value="unit.unit_name">
                                            {{ unit.unit_name }}
                                        </option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="grid gap-2">
                            <div>
                                <h1 class="text-lg text-blue-700 font-bold">Batch and Supplier</h1>
                            </div>
                            <div class="grid grid-cols-2 gap-2 mt-1">
                                <div class="grid gap-1">
                                    <label class="font-medium text-sm text-slate-600">Batch number <span
                                            class="text-red-700">*</span></label>
                                    <input type="text" v-model="formData.batch_number"
                                        class="p-2 w-full uppercase border border-gray-300 rounded-lg placeholder:opacity-50 focus:outline-blue-600"
                                        placeholder="e.g. BATCH-A1" required>
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-medium text-sm text-slate-600">Supplier name <span
                                            class="text-red-700">*</span></label>
                                    <input type="text" v-model="formData.supplier"
                                        class="p-2 w-full border border-gray-300 rounded-lg placeholder:opacity-50 focus:outline-blue-600"
                                        placeholder="e.g. Metro Drug" required>
                                </div>
                            </div>
                        </div>
                        <div class="grid gap-2">
                            <div>
                                <h1 class="text-lg text-blue-700 font-bold">Batch and Supplier</h1>
                            </div>
                            <div class="grid grid-cols-2 gap-2 mt-1">
                                <div class="grid gap-1">
                                    <label class="font-medium text-sm text-slate-600">Manufacturing Date
                                        <span class="text-red-700">*</span></label>
                                    <input type="date" v-model="formData.manufacturing_date"
                                        :max="manufacturingDateMax"
                                        class="p-2 w-full border border-gray-300 rounded-lg focus:outline-blue-600"
                                        required>
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-medium text-sm text-slate-600">Expiration date <span
                                            class="text-red-700">*</span></label>
                                    <input type="date" v-model="formData.expiration_date"
                                        :min="expirationDateMin"
                                        class="p-2 w-full border border-gray-300 rounded-lg focus:outline-blue-600"
                                        required>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="mt-6 flex gap-2 items-center justify-end">
                        <button type="button" @click="closeModal"
                            class="px-4 py-2.5 bg-white rounded-lg border border-gray-300 text-gray-700 hover:bg-gray-50">Cancel</button>
                        <button type="submit"
                            class="px-5 py-2.5  text-white rounded-lg border bg-blue-700 hover:bg-blue-800 transition"
                            :disabled="Isloading">
                            <span v-if="Isloading">Saving...</span>
                            <span v-else>Save Medicine</span>
                        </button>
                    </div>
                </form>
            </div>
        </section>
    </Transition>
</template>