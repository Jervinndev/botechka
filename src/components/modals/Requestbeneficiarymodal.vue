<script setup>
import { onBeforeUnmount, ref, watch } from 'vue'
import { getMyProfile } from '../../services/Authservices'
import { getAvailableRequestMedicines, submitMedicineRequest } from '../../services/MedicineRequests'

const props = defineProps({
    IsOpen: Boolean,
    initialMedicineId: {
        type: String,
        default: ''
    }
})
const emit = defineEmits(['close', 'saved'])

const profile = ref(null)
const medicines = ref([])
const loading = ref(false)
const submitting = ref(false)
const errorMessage = ref('')
const selectedMedicine = ref('')
const quantity = ref(1)
const beneficiaryType = ref('Senior Citizen')
const purpose = ref('')
const prescriptionFile = ref(null)
const prescriptionPreview = ref(null)

watch(() => props.IsOpen, async (isOpen) => {
    if (!isOpen) return

    loading.value = true
    errorMessage.value = ''

    try {
        const [profileResult, medicineData] = await Promise.all([
            getMyProfile(),
            getAvailableRequestMedicines()
        ])
        if (!profileResult.success) throw new Error(profileResult.error)
        profile.value = profileResult.data
        medicines.value = medicineData
        selectedMedicine.value = medicineData.some((medicine) => medicine.id === props.initialMedicineId)
            ? props.initialMedicineId
            : medicineData[0]?.id ?? ''
    } catch (error) {
        console.error('Failed to load medicine request form:', error)
        errorMessage.value = error.message || 'Unable to load the request form.'
    } finally {
        loading.value = false
    }
}, { immediate: true })

function handleFileUpload(event) {
    const file = event.target.files?.[0]
    if (file) {
        if (prescriptionPreview.value) URL.revokeObjectURL(prescriptionPreview.value)
        if (file.size > 5 * 1024 * 1024) {
            prescriptionFile.value = null
            prescriptionPreview.value = null
            errorMessage.value = 'The prescription file must be 5 MB or smaller.'
            event.target.value = ''
            return
        }

        const supportedTypes = ['application/pdf', 'image/jpeg', 'image/png', 'image/webp']
        if (!supportedTypes.includes(file.type)) {
            prescriptionFile.value = null
            prescriptionPreview.value = null
            errorMessage.value = 'Upload your prescription as a PDF, JPG, PNG, or WebP file.'
            event.target.value = ''
            return
        }

        errorMessage.value = ''
        prescriptionFile.value = file
        if (file.type.startsWith('image/')) {
            prescriptionPreview.value = URL.createObjectURL(file)
        } else {
            prescriptionPreview.value = null
        }
    }
}

function removeFile() {
    if (prescriptionPreview.value) URL.revokeObjectURL(prescriptionPreview.value)
    prescriptionFile.value = null
    prescriptionPreview.value = null
}

onBeforeUnmount(() => {
    if (prescriptionPreview.value) URL.revokeObjectURL(prescriptionPreview.value)
})

function closeModal() {
    if (submitting.value) return
    emit('close')
}

async function submitRequest() {
    errorMessage.value = ''

    if (!selectedMedicine.value) {
        errorMessage.value = 'Choose an available medicine.'
        return
    }
    if (!Number.isInteger(Number(quantity.value)) || Number(quantity.value) < 1) {
        errorMessage.value = 'Enter a quantity of at least one.'
        return
    }
    if (!prescriptionFile.value) {
        errorMessage.value = 'Upload your prescription before submitting.'
        return
    }

    submitting.value = true
    try {
        await submitMedicineRequest({
            medicineId: selectedMedicine.value,
            quantity: quantity.value,
            purpose: purpose.value,
            beneficiaryType: beneficiaryType.value,
            prescriptionFile: prescriptionFile.value
        })

        removeFile()
        selectedMedicine.value = ''
        quantity.value = 1
        purpose.value = ''
        emit('saved')
    } catch (error) {
        console.error('Failed to submit medicine request:', error)
        errorMessage.value = error.message || 'Unable to submit your request.'
    } finally {
        submitting.value = false
    }
}
</script>

<template>
    <div v-if="IsOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4 font-inter">
        <form
            @submit.prevent="submitRequest"
            class="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl relative overflow-hidden flex flex-col max-h-[90vh]">

            <!-- Modal Header -->
            <div class="flex justify-between items-start pb-3 border-b border-gray-100">
                <div>
                    <h2 class="text-xl font-bold text-gray-900 tracking-tight">Request Medicine</h2>
                    <p class="text-xs text-gray-400 mt-0.5">Fill out the details for your medicine request</p>
                </div>
                <button type="button" @click="closeModal"
                    class="text-gray-400 hover:text-gray-600 p-1.5 rounded-full hover:bg-gray-100 transition-colors">
                    &times;
                </button>
            </div>

            <!-- Form Body -->
            <div class="py-3 px-1 space-y-4 overflow-y-auto flex-1">
                <p v-if="errorMessage" class="rounded-lg bg-red-50 px-3 py-2 text-xs text-red-700" role="alert">
                    {{ errorMessage }}
                </p>

                <!-- Beneficiary Name -->
                <div class="space-y-1.5">
                    <label class="text-xs font-semibold text-gray-700">Full Name <span
                            class="text-red-500">*</span></label>
                    <input :value="[profile?.fname, profile?.mname, profile?.lname].filter(Boolean).join(' ')"
                        type="text" readonly placeholder="Loading your profile..."
                        class="w-full bg-gray-50 text-xs text-gray-800 placeholder-gray-400 px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500" />
                </div>

                <!-- Beneficiary Type & Quantity (2 columns) -->
                <div class="grid grid-cols-2 gap-3">
                    <div class="space-y-1.5">
                        <label class="text-xs font-semibold text-gray-700">Beneficiary Type</label>
                        <select v-model="beneficiaryType"
                            class="w-full bg-gray-50 text-xs text-gray-800 px-3 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500">
                            <option value="Senior Citizen">Senior Citizen</option>
                            <option value="PWD">PWD</option>
                            <option value="General">General</option>
                        </select>
                    </div>
                    <div class="space-y-1.5">
                        <label class="text-xs font-semibold text-gray-700">Quantity (pcs)</label>
                        <input v-model.number="quantity" type="number" min="1" step="1" required
                            class="w-full bg-gray-50 text-xs text-gray-800 px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500" />
                    </div>
                </div>

                <!-- Medicine Name Selection -->
                <div class="space-y-1.5">
                    <label class="text-xs font-semibold text-gray-700">Select Medicine <span
                            class="text-red-500">*</span></label>
                    <select v-model="selectedMedicine" required :disabled="loading || medicines.length === 0"
                        class="w-full bg-gray-50 text-xs text-gray-800 px-3 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500">
                        <option value="" disabled>-- Choose Medicine --</option>
                        <option v-for="medicine in medicines" :key="medicine.id" :value="medicine.id">
                            {{ medicine.medicine_name }} ({{ medicine.dosage }} {{ medicine.unit }}) — {{ medicine.quantity }} in stock
                        </option>
                    </select>
                    <p v-if="!loading && !medicines.length" class="text-[11px] text-gray-500">No medicines are currently available.</p>
                </div>

                <!-- Prescription Upload Section -->
                <div class="space-y-1.5">
                    <label class="text-xs font-semibold text-gray-700">
                        Upload Prescription (Reseta) <span class="text-red-500">*</span>
                    </label>

                    <!-- Kapag WALANG pang uploaded -->
                    <div v-if="!prescriptionFile">
                        <label for="prescriptionInput"
                            class="flex flex-col items-center justify-center p-4 border-2 border-dashed border-gray-200 rounded-xl cursor-pointer bg-gray-50 hover:bg-gray-100/80 transition-colors">
                            <div class="flex flex-col items-center justify-center pt-1 pb-1">
                                <svg xmlns="http://www.w3.org/2000/svg" class="w-7 h-7 text-blue-600 mb-1" fill="none"
                                    viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" />
                                </svg>
                                <p class="text-xs font-semibold text-gray-700">Click to upload doctor's prescription</p>
                                <p class="text-[10px] text-gray-400 mt-0.5">PNG, JPG, WebP, or PDF (Max 5MB)</p>
                            </div>
                            <input id="prescriptionInput" type="file" class="hidden" accept="image/jpeg,image/png,image/webp,application/pdf"
                                @change="handleFileUpload" />
                        </label>
                    </div>

                    <!-- Kapag MAY uploaded file na -->
                    <div v-else
                        class="flex items-center justify-between p-3 bg-blue-50/60 border border-blue-200 rounded-xl">
                        <div class="flex items-center gap-3">
                            <!-- Image preview (kung picture) -->
                            <div v-if="prescriptionPreview"
                                class="w-10 h-10 rounded-lg bg-gray-200 overflow-hidden border shrink-0">
                                <img :src="prescriptionPreview" alt="Prescription" class="w-full h-full object-cover" />
                            </div>
                            <!-- PDF File Icon (kung document) -->
                            <div v-else
                                class="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center shrink-0 text-blue-700 font-bold text-xs">
                                PDF
                            </div>

                            <div class="overflow-hidden">
                                <p class="text-xs font-bold text-gray-800 truncate max-w-[200px]">{{
                                    prescriptionFile.name }}</p>
                                <p class="text-[10px] text-gray-500">{{ (prescriptionFile.size / 1024 / 1024).toFixed(2)
                                }} MB</p>
                            </div>
                        </div>

                        <button type="button" @click="removeFile"
                            class="text-xs text-red-500 hover:text-red-700 font-semibold px-2 py-1">
                            Remove
                        </button>
                    </div>
                </div>

                <!-- Purpose / Ailment -->
                <div class="space-y-1.5">
                    <label class="text-xs font-semibold text-gray-700">Purpose / Ailment</label>
                    <textarea v-model="purpose" rows="2" placeholder="State your reason or symptoms (e.g., Fever and severe headache)..."
                        class="w-full bg-gray-50 text-xs text-gray-800 placeholder-gray-400 p-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500 resize-none"></textarea>
                </div>

            </div>

            <!-- Modal Footer Actions -->
            <div class="flex items-center gap-3 pt-4 border-t border-gray-100">
                <button type="button" @click="closeModal"
                    class="flex-1 bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold py-3 rounded-xl transition-colors">
                    Cancel
                </button>
                <button type="submit" :disabled="submitting || loading"
                    class="flex-1 bg-blue-700 hover:bg-blue-800 text-white text-xs font-semibold py-3 rounded-xl transition-colors shadow-sm shadow-blue-200">
                    {{ submitting ? 'Submitting...' : 'Submit Request' }}
                </button>
            </div>

        </form>
    </div>
</template>