<script setup>
import { computed, ref, watch } from 'vue'
import { X } from '@lucide/vue'
import { getMedicines } from '../../services/Fetches'

const props = defineProps({
    IsOpen: Boolean
})

const emit = defineEmits(['close', 'select'])

const medicines = ref([])
const searchQuery = ref('')
const selectedCategory = ref('All')
const selectedIds = ref([])
const isLoading = ref(false)
const errorMessage = ref('')

const categories = computed(() => [...new Set(medicines.value.map((medicine) => medicine.category).filter(Boolean))])

const filteredMedicines = computed(() => {
    const query = searchQuery.value.trim().toLowerCase()

    return medicines.value.filter((medicine) => {
        const matchesQuery = !query || [medicine.name, medicine.medicineId, medicine.category, medicine.strength]
            .some((value) => value?.toLowerCase().includes(query))
        const matchesCategory = selectedCategory.value === 'All' || medicine.category === selectedCategory.value

        return matchesQuery && matchesCategory
    })
})

const selectableMedicines = computed(() => filteredMedicines.value.filter((medicine) => medicine.stock > 0))
const selectedCount = computed(() => selectedIds.value.length)
const allVisibleSelected = computed(() => selectableMedicines.value.length > 0
    && selectableMedicines.value.every((medicine) => selectedIds.value.includes(medicine.id)))

async function fetchMedicines() {
    isLoading.value = true
    errorMessage.value = ''

    try {
        const data = await getMedicines()
        medicines.value = data.map((medicine) => ({
            id: medicine.id,
            medicineId: medicine.medicine_id,
            name: medicine.medicine_name,
            image_url: medicine.image_url,
            category: medicine.category || '',
            strength: [medicine.dosage, medicine.unit].filter(Boolean).join(' '),
            unit: medicine.unit || 'units',
            stock: Math.max(0, Number(medicine.quantity) || 0)
        }))
    } catch (error) {
        console.error('Error fetching medicines for selection:', error)
        medicines.value = []
        errorMessage.value = 'Hindi ma-load ang medicines. Subukan ulit.'
    } finally {
        isLoading.value = false
    }
}

watch(() => props.IsOpen, async (isOpen) => {
    if (isOpen) {
        searchQuery.value = ''
        selectedCategory.value = 'All'
        selectedIds.value = []
             fetchMedicines()
    }
})

function toggleMedicine(medicineId) {
    selectedIds.value = selectedIds.value.includes(medicineId)
        ? selectedIds.value.filter((id) => id !== medicineId)
        : [...selectedIds.value, medicineId]
}

function toggleVisibleMedicines(event) {
    const visibleIds = selectableMedicines.value.map((medicine) => medicine.id)
    selectedIds.value = event.target.checked
        ? [...new Set([...selectedIds.value, ...visibleIds])]
        : selectedIds.value.filter((id) => !visibleIds.includes(id))
}

function clearFilters() {
    searchQuery.value = ''
    selectedCategory.value = 'All'
}

function addSelectedMedicines() {
    const selectedMedicines = medicines.value.filter((medicine) => selectedIds.value.includes(medicine.id))
    if (selectedMedicines.length === 0) return

    emit('select', selectedMedicines)
    emit('close')
}
</script>


<template>
    <Transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0 -translate-y-2"
        enter-to-class="opacity-100 translate-y-0" leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100 translate-y-0" leave-to-class="opacity-0 -translate-y-2">
        <section v-if="IsOpen"
            class="fixed inset-0 z-50 flex h-full w-full items-center justify-center overflow-y-auto bg-black/40     p-4">
            <div
                class="flex max-h-[calc(100vh-2rem)] w-full max-w-6xl flex-col overflow-hidden rounded-xl border border-gray-100 bg-white font-inter shadow-xl">

                <!-- Header -->
                <div class="flex items-center justify-between border-b border-gray-100 px-5 py-5 sm:px-8">
                    <div class="flex items-center gap-4">
                        <div class="flex h-11 w-11 items-center justify-center rounded-xl bg-blue-50 text-blue-700">
                            <X :size="24" :stroke-width="2.5" />
                        </div>

                        <div>
                            <h2 class="text-xl font-bold text-[#404040]">Select Medicines</h2>
                            <p class="mt-0.5 text-sm text-slate-500">
                                Browse or search for medicines to dispense.
                            </p>
                        </div>
                    </div>

                    <button type="button" @click="emit('close')"
                        class="flex h-8 w-8 items-center justify-center rounded-md text-slate-500 transition hover:bg-gray-100 hover:text-slate-800"
                        aria-label="Close">
                        <svg xmlns="http://www.w3.org/2000/svg" width="17" height="17" viewBox="0 0 24 24" fill="none"
                            stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                            <circle cx="12" cy="12" r="9" />
                            <path d="m9 9 6 6m0-6-6 6" />
                        </svg>
                    </button>
                </div>

                <!-- Search and Filters -->
                <div class="flex flex-col gap-4 px-5 pt-5 sm:px-8 md:flex-row md:items-center">
                    <div class="relative flex-1">
                        <svg class="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500"
                            xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none"
                            stroke="currentColor" stroke-width="2" stroke-linecap="round">
                            <circle cx="11" cy="11" r="7" />
                            <path d="m20 20-4-4" />
                        </svg>

                        <input v-model="searchQuery" type="search"
                            placeholder="Search medicine (name, ID, or strength)..."
                            class="h-10 w-full rounded-lg border border-gray-200 bg-gray-50 pl-10 pr-4 text-sm text-slate-700 outline-none placeholder:text-slate-400 focus:border-blue-700" />
                    </div>

                    <div class="flex flex-wrap items-center gap-3">
                        <button type="button"
                            class="flex h-10 shrink-0 items-center gap-2 rounded-md border border-gray-200 px-4 text-sm font-medium text-gray-700 transition hover:bg-gray-50">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                                <path d="M4 4h16l-6.5 8v6l-3 2v-8L4 4Z" />
                            </svg>
                            Category
                        </button>

                        <select v-model="selectedCategory"
                            class="h-10 min-w-0 flex-1 rounded-lg border border-blue-700 bg-white px-3 text-sm text-slate-700 outline-none focus:ring-2 focus:ring-blue-100 sm:w-40">
                            <option>All</option>
                            <option v-for="category in categories" :key="category" :value="category">
                                {{ category }}
                            </option>
                        </select>

                        <button type="button" @click="clearFilters"
                            class="flex h-10 shrink-0 items-center gap-2 rounded-md border border-gray-200 px-4 text-sm font-medium text-gray-600 transition hover:bg-gray-50 hover:text-gray-800">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                                fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                stroke-linejoin="round">
                                <path d="M20 7v5h-5" />
                                <path d="M4 17v-5h5" />
                                <path d="M5.6 9a7 7 0 0 1 11.5-2L20 12M4 12l2.9 5a7 7 0 0 0 11.5-2" />
                            </svg>
                            Clear Filters
                        </button>
                    </div>
                </div>

                <!-- Medicine Table -->
                <div class="min-h-0 flex-1 overflow-auto px-5 pb-5 pt-5 sm:px-8">
                    <table class="w-full min-w-[760px] border-collapse bg-white text-left">
                        <thead class="sticky top-0 z-10 bg-blue-700 text-white">
                            <tr class="text-left text-sm font-semibold">
                                <th class="w-10 rounded-tl-lg px-3 py-3">
                                    <input type="checkbox" :checked="allVisibleSelected"
                                        :disabled="selectableMedicines.length === 0" @change="toggleVisibleMedicines"
                                        class="h-[17px] w-[17px] rounded border-slate-300 accent-blue-700" />
                                </th>
                                <th class="px-3 py-3">Image</th>
                                <th class="px-3 py-3">Medicine</th>
                                <th class="px-3 py-3">Category</th>
                                <th class="px-3 py-3">Strength / Form</th>
                                <th class="rounded-tr-lg px-3 py-3">Stock Level</th>
                            </tr>
                        </thead>

                        <tbody class="divide-y divide-gray-100 text-sm">
                            <tr v-for="medicine in filteredMedicines" :key="medicine.id"
                                class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50"
                                :class="{ 'opacity-50': medicine.stock === 0 }">
                                <td class="px-3 py-3">
                                    <input type="checkbox" :checked="selectedIds.includes(medicine.id)"
                                        :disabled="medicine.stock === 0" @change="toggleMedicine(medicine.id)"
                                        class="h-[17px] w-[17px] rounded border-slate-300 accent-blue-700" />
                                </td>
                                <td class="px-3 py-3">
                                    <img v-if="medicine.image_url" :src="medicine.image_url"
                                        :alt="`${medicine.name} image`" class="h-10 w-10 rounded-lg object-cover">
                                    <span v-else class="text-xs text-slate-400">No image</span>
                                </td>
                                <td class="px-3 py-3">
                                    <p class="text-sm font-semibold text-slate-800">{{ medicine.name }}</p>
                                    <p class="mt-0.5 text-xs text-slate-500">{{ medicine.medicineId || 'N/A' }}</p>
                                </td>
                                <td class="px-3 py-3">
                                    <span
                                        class="inline-flex rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700">
                                        {{ medicine.category }}
                                    </span>
                                </td>
                                <td class="px-3 py-3 text-sm text-slate-700">{{ medicine.strength }}</td>
                                <td class="px-3 py-3 text-sm font-semibold"
                                    :class="medicine.stock === 0 ? 'text-red-500' : 'text-slate-800'">
                                    {{ medicine.stock }} {{ medicine.unit }}
                                </td>
                            </tr>
                            <tr v-if="isLoading || errorMessage || filteredMedicines.length === 0">
                                <td colspan="6" class="px-3 py-10 text-center text-sm text-slate-500">
                                    {{ errorMessage || (isLoading ? 'Loading medicines...' : 'No medicines found.') }}
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- Footer -->
                <div
                    class="flex flex-col gap-4 border-t border-gray-100 bg-white px-5 py-5 sm:flex-row sm:items-center sm:justify-between sm:px-8">
                    <p class="text-sm text-slate-500">{{ selectedCount }} medicine(s) selected</p>

                    <div class="flex items-center justify-end gap-3">
                        <button type="button" @click="emit('close')"
                            class="rounded-md border border-gray-200 px-4 py-2 text-sm font-medium text-gray-600 transition hover:bg-gray-50">
                            Cancel
                        </button>

                        <button type="button" @click="addSelectedMedicines"
                            :disabled="selectedCount === 0 || isLoading || Boolean(errorMessage)"
                            class="rounded-md bg-blue-700 px-4 py-2 text-sm font-semibold text-white transition hover:bg-blue-800 disabled:cursor-not-allowed disabled:opacity-50">
                            Add to Dispense
                        </button>
                    </div>
                </div>

            </div>
        </section>
    </Transition>
</template>