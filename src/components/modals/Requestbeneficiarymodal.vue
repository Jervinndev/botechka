<script setup>
import { ref } from 'vue'

const props = defineProps({
    IsOpen: Boolean
})
const emit = defineEmits(['close', 'saved'])

// Reactive states para sa Prescription File
const prescriptionFile = ref(null)
const prescriptionPreview = ref(null)

function handleFileUpload(event) {
    const file = event.target.files[0]
    if (file) {
        prescriptionFile.value = file
        // Preview if image file
        if (file.type.startsWith('image/')) {
            prescriptionPreview.value = URL.createObjectURL(file)
        } else {
            prescriptionPreview.value = null
        }
    }
}

function removeFile() {
    prescriptionFile.value = null
    prescriptionPreview.value = null
}
</script>

<template>
    <div v-if="IsOpen" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4 font-inter">
        <div
            class="bg-white rounded-2xl max-w-lg w-full p-6 shadow-xl relative overflow-hidden flex flex-col max-h-[90vh]">

            <!-- Modal Header -->
            <div class="flex justify-between items-start pb-3 border-b border-gray-100">
                <div>
                    <h2 class="text-xl font-bold text-gray-900 tracking-tight">Request Medicine</h2>
                    <p class="text-xs text-gray-400 mt-0.5">Fill out the details for your medicine request</p>
                </div>
                <button @click="emit('close')"
                    class="text-gray-400 hover:text-gray-600 p-1.5 rounded-full hover:bg-gray-100 transition-colors">
                    &times;
                </button>
            </div>

            <!-- Form Body -->
            <div class="py-3 px-1 space-y-4 overflow-y-auto flex-1">

                <!-- Beneficiary Name -->
                <div class="space-y-1.5">
                    <label class="text-xs font-semibold text-gray-700">Full Name <span
                            class="text-red-500">*</span></label>
                    <input type="text" placeholder="e.g. Juan Dela Cruz"
                        class="w-full bg-gray-50 text-xs text-gray-800 placeholder-gray-400 px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500" />
                </div>

                <!-- Beneficiary Type & Quantity (2 columns) -->
                <div class="grid grid-cols-2 gap-3">
                    <div class="space-y-1.5">
                        <label class="text-xs font-semibold text-gray-700">Beneficiary Type</label>
                        <select
                            class="w-full bg-gray-50 text-xs text-gray-800 px-3 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500">
                            <option value="Senior Citizen">Senior Citizen</option>
                            <option value="PWD">PWD</option>
                            <option value="General">General</option>
                        </select>
                    </div>
                    <div class="space-y-1.5">
                        <label class="text-xs font-semibold text-gray-700">Quantity (pcs)</label>
                        <input type="number" value="1" min="1"
                            class="w-full bg-gray-50 text-xs text-gray-800 px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500" />
                    </div>
                </div>

                <!-- Medicine Name Selection -->
                <div class="space-y-1.5">
                    <label class="text-xs font-semibold text-gray-700">Select Medicine <span
                            class="text-red-500">*</span></label>
                    <select
                        class="w-full bg-gray-50 text-xs text-gray-800 px-3 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500">
                        <option value="">-- Choose Medicine --</option>
                        <option value="Paracetamol">Paracetamol (500mg tablet)</option>
                        <option value="Amoxicillin">Amoxicillin (500mg capsule)</option>
                        <option value="Cetirizine">Cetirizine (10mg tablet)</option>
                    </select>
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
                                <p class="text-[10px] text-gray-400 mt-0.5">PNG, JPG, or PDF (Max 5MB)</p>
                            </div>
                            <input id="prescriptionInput" type="file" class="hidden" accept="image/*,.pdf"
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
                    <textarea rows="2" placeholder="State your reason or symptoms (e.g., Fever and severe headache)..."
                        class="w-full bg-gray-50 text-xs text-gray-800 placeholder-gray-400 p-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500 resize-none"></textarea>
                </div>

            </div>

            <!-- Modal Footer Actions -->
            <div class="flex items-center gap-3 pt-4 border-t border-gray-100">
                <button @click="emit('close')"
                    class="flex-1 bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-semibold py-3 rounded-xl transition-colors">
                    Cancel
                </button>
                <button
                    class="flex-1 bg-blue-700 hover:bg-blue-800 text-white text-xs font-semibold py-3 rounded-xl transition-colors shadow-sm shadow-blue-200">
                    Submit Request
                </button>
            </div>

        </div>
    </div>
</template>