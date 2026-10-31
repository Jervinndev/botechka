<script setup>
import { computed, ref, watch } from 'vue'
import { Image as ImageIcon, X } from '@lucide/vue'
import { getCategories } from '../../services/Fetches'
import { addDaysToDate, getEarlierDate, getLaterDate, getLocalDateString } from '../../utils/dates'

const props = defineProps({
    IsOpen: Boolean
})
const emit = defineEmits(['close', 'saved'])

const Isloading = ref(false)
const errorMessage = ref('')
const categories = ref([])
const selectedImage = ref(null)
const imagePreviewUrl = ref('')

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
    selectedImage.value = null
    if (imagePreviewUrl.value) URL.revokeObjectURL(imagePreviewUrl.value)
    imagePreviewUrl.value = ''
    errorMessage.value = ''
}

function handleImageSelected(event) {
    const file = event.target.files?.[0]
    if (!file) return

    const supportedTypes = ['image/jpeg', 'image/png', 'image/webp']
    if (!supportedTypes.includes(file.type)) {
        errorMessage.value = 'Choose a JPG, PNG, or WebP image.'
        event.target.value = ''
        return
    }
    if (file.size > 2 * 1024 * 1024) {
        errorMessage.value = 'Image must be 2 MB or smaller.'
        event.target.value = ''
        return
    }

    if (imagePreviewUrl.value) URL.revokeObjectURL(imagePreviewUrl.value)
    selectedImage.value = file
    imagePreviewUrl.value = URL.createObjectURL(file)
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

        const response = await AddMedicineWithImage(payload, selectedImage.value)

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
            class="fixed inset-0 z-50 flex h-full w-full items-center justify-center overflow-y-auto bg-black/40 p-4">
            <div
                class="max-h-[calc(100vh-2rem)] w-full max-w-2xl overflow-y-auto rounded-xl bg-white p-6 font-inter shadow-xl">
                <form @submit.prevent="saveMedicine">
                    <div class="flex justify-between items-start">
                        <div>
                            <h1 class="mt-2 font-inter text-2xl font-bold text-[#404040]">Add New Medicine</h1>
                            <p class="font-inter text-sm font-medium text-[#808080]">Add a new medicine to your
                                inventory.</p>
                        </div>
                        <X class="cursor-pointer text-gray-400 hover:text-[#404040]" @click="closeModal" />
                    </div>

                    <div v-if="errorMessage" class="mt-4 rounded-lg bg-red-50 p-2 text-sm text-red-600">
                        {{ errorMessage }}
                    </div>

                    <div class="mt-6 grid grid-cols-1 gap-6">
                        <div class="flex items-center gap-3">
                            <img v-if="imagePreviewUrl" :src="imagePreviewUrl" alt="Medicine image preview"
                                class="h-20 w-20 rounded-lg object-cover">
                            <div v-else
                                class="flex h-20 w-20 items-center justify-center rounded-lg bg-gray-100 text-gray-400">
                                <ImageIcon :size="28" />
                            </div>
                            <div>
                                <label for="imageInput"
                                    class="cursor-pointer rounded-xl bg-blue-700 px-4 py-2 text-white hover:bg-blue-800">
                                    {{ selectedImage ? 'Change Image' : 'Upload Image' }}
                                </label>
                                <input type="file" class="hidden" id="imageInput"
                                    accept="image/jpeg,image/png,image/webp" @change="handleImageSelected">
                                <p class="mt-2 text-xs text-gray-500">JPG, PNG, or WebP · max 2 MB</p>
                            </div>
                        </div>
                        <div class="grid gap-2">
                            <div>
                                <h1 class="font-inter text-lg font-semibold text-[#404040]">Identity</h1>
                            </div>
                            <div class="mt-2 grid grid-cols-1 gap-3 sm:grid-cols-2">
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Medicine name <span
                                            class="text-red-500">*</span></label>
                                    <input type="text" v-model="formData.medicine_name"
                                        class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 placeholder:opacity-50 focus:outline-none focus:ring-2 focus:ring-blue-700"
                                        placeholder="e.g. Biogesic" required>
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Medicine ID (Auto)
                                    </label>
                                    <input type="text" v-model="formData.medicine_id" readonly
                                        class="w-full cursor-not-allowed rounded-lg border border-gray-200 bg-gray-100 p-2 text-slate-600">
                                </div>
                                <div class="grid gap-1 sm:col-span-2">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Category <span
                                            class="text-red-500">*</span></label>
                                    <select v-model="formData.category"
                                        class="w-full cursor-pointer rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
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
                                <h1 class="font-inter text-lg font-semibold text-[#404040]">Stock</h1>
                            </div>
                            <div class="mt-2 grid grid-cols-1 gap-3 sm:grid-cols-3">
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Quantity <span
                                            class="text-red-500">*</span></label>
                                    <input type="number" v-model="formData.quantity"
                                        class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 placeholder:opacity-50 focus:outline-none focus:ring-2 focus:ring-blue-700"
                                        placeholder="e.g. 100" min="0" required>
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Dosage <span
                                            class="text-red-500">*</span></label>
                                    <select v-model="formData.dosage"
                                        class="w-full cursor-pointer rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                                        required>
                                        <option v-for="dosage in dosages" :key="dosage.id" :value="dosage.dosage_name">
                                            {{ dosage.dosage_name }}
                                        </option>
                                    </select>
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Unit <span
                                            class="text-red-500">*</span></label>
                                    <select v-model="formData.unit"
                                        class="w-full cursor-pointer rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
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
                                <h1 class="font-inter text-lg font-semibold text-[#404040]">Batch and Supplier</h1>
                            </div>
                            <div class="mt-2 grid grid-cols-1 gap-3 sm:grid-cols-2">
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Batch number <span
                                            class="text-red-500">*</span></label>
                                    <input type="text" v-model="formData.batch_number"
                                        class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 uppercase placeholder:opacity-50 focus:outline-none focus:ring-2 focus:ring-blue-700"
                                        placeholder="e.g. BATCH-A1" required>
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Supplier name <span
                                            class="text-red-500">*</span></label>
                                    <input type="text" v-model="formData.supplier"
                                        class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 placeholder:opacity-50 focus:outline-none focus:ring-2 focus:ring-blue-700"
                                        placeholder="e.g. Metro Drug" required>
                                </div>
                            </div>
                        </div>
                        <div class="grid gap-2">
                            <div>
                                <h1 class="font-inter text-lg font-semibold text-[#404040]">Dates</h1>
                            </div>
                            <div class="mt-2 grid grid-cols-1 gap-3 sm:grid-cols-2">
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Manufacturing Date
                                        <span class="text-red-500">*</span></label>
                                    <input type="date" v-model="formData.manufacturing_date" :max="manufacturingDateMax"
                                        class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                                        required>
                                </div>
                                <div class="grid gap-1">
                                    <label class="font-inter text-sm font-medium text-[#404040]">Expiration date <span
                                            class="text-red-500">*</span></label>
                                    <input type="date" v-model="formData.expiration_date" :min="expirationDateMin"
                                        class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                                        required>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="mt-6 flex items-center justify-end gap-2">
                        <button type="button" @click="closeModal"
                            class="cursor-pointer rounded-xl bg-gray-100 p-2 px-4 text-[#404040] transition hover:bg-gray-200">Cancel</button>
                        <button type="submit"
                            class="cursor-pointer rounded-xl bg-blue-700 p-2 px-5 text-white transition hover:bg-blue-800 disabled:cursor-not-allowed disabled:opacity-60"
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