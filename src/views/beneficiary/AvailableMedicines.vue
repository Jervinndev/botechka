<script setup>
import { computed, onMounted, ref } from 'vue'
import { Pill, Search, RotateCcw, ArrowRight } from '@lucide/vue'
import { useRouter } from 'vue-router'
import { getMedicines } from '../../services/Fetches'

const router = useRouter()
const medicines = ref([])
const searchQuery = ref('')
const selectedCategory = ref('All')
const isLoading = ref(false)
const errorMessage = ref('')

const categories = computed(() => [
    'All',
    ...new Set(medicines.value.map((medicine) => medicine.category).filter(Boolean))
])

const filteredMedicines = computed(() => {
    const query = searchQuery.value.trim().toLowerCase()
    return medicines.value.filter((medicine) => {
        const categoryMatches = selectedCategory.value === 'All' || medicine.category === selectedCategory.value
        const searchMatches = !query || [
            medicine.medicine_name,
            medicine.medicine_id,
            medicine.category,
            medicine.dosage,
            medicine.unit
        ].some((value) => String(value ?? '').toLowerCase().includes(query))
        return categoryMatches && searchMatches && Number(medicine.quantity) > 0
    })
})

async function loadMedicines() {
    isLoading.value = true
    errorMessage.value = ''
    try {
        const data = await getMedicines()
        medicines.value = data || []
    } catch (error) {
        console.error('Unable to load beneficiary medicines:', error)
        errorMessage.value = error.message || 'Unable to load available medicines.'
        medicines.value = []
    } finally {
        isLoading.value = false
    }
}

function requestMedicine(medicine) {
    router.push({ name: 'requestmedicines', query: { medicineId: medicine.id } })
}

onMounted(loadMedicines)
</script>

<template>
    <section class="font-inter text-slate-800">
        <header class="mb-5">
            <h1 class="text-lg font-bold text-[#404040]">Available Medicines</h1>
            <p class="text-sm text-[#808080]">Browse medicines currently available for request.</p>
        </header>

        <div class="mb-5 flex flex-col gap-3 sm:flex-row">
            <div class="relative min-w-0 flex-1">
                <Search :size="16" class="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400" />
                <input v-model="searchQuery" type="search" placeholder="Search medicines..."
                    class="w-full rounded-xl border border-gray-200 bg-white py-3 pl-10 pr-4 text-sm outline-none focus:border-blue-500">
            </div>
            <select v-model="selectedCategory"
                class="rounded-xl border border-gray-200 bg-white px-4 py-3 text-sm text-gray-700 outline-none focus:border-blue-500">
                <option v-for="category in categories" :key="category" :value="category">
                    {{ category === 'All' ? 'All Categories' : category }}
                </option>
            </select>
            <button type="button" @click="loadMedicines" :disabled="isLoading"
                class="flex items-center justify-center gap-2 rounded-xl border border-gray-200 bg-white px-4 py-3 text-sm text-gray-700 hover:bg-gray-50 disabled:opacity-50">
                <RotateCcw :size="16" :class="{ 'animate-spin': isLoading }" /> Refresh
            </button>
        </div>

        <div class="mb-3 flex items-center justify-between">
            <h2 class="text-base font-bold text-gray-900">In Stock</h2>
            <span class="text-sm text-gray-500">{{ filteredMedicines.length }} medicine(s)</span>
        </div>

        <p v-if="errorMessage" role="alert" class="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">
            {{ errorMessage }}
        </p>
        <p v-else-if="isLoading && !medicines.length" class="rounded-xl bg-white p-10 text-center text-sm text-gray-500">
            Loading available medicines...
        </p>
        <p v-else-if="!filteredMedicines.length" class="rounded-xl bg-white p-10 text-center text-sm text-gray-500">
            No available medicines match your search.
        </p>

        <div v-else class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 2xl:grid-cols-4">
            <article v-for="medicine in filteredMedicines" :key="medicine.id"
                class="flex flex-col justify-between gap-4 rounded-2xl border border-gray-200 bg-white p-4">
                <div class="flex items-start gap-3">
                    <div class="flex h-12 w-16 shrink-0 items-center justify-center overflow-hidden rounded-lg border border-gray-100 bg-gray-50 p-1">
                        <img v-if="medicine.image_url" :src="medicine.image_url" :alt="medicine.medicine_name"
                            class="h-full w-full object-contain">
                        <Pill v-else :size="23" class="text-blue-600" />
                    </div>
                    <div class="min-w-0">
                        <h3 class="text-sm font-bold leading-snug text-gray-900">{{ medicine.medicine_name }}</h3>
                        <p class="mt-1 text-xs text-gray-500">{{ medicine.category || 'Uncategorized' }}</p>
                        <p class="mt-0.5 text-[11px] text-gray-400">{{ medicine.dosage }} · {{ medicine.unit }}</p>
                    </div>
                </div>
                <div class="flex items-center justify-between gap-2 border-t border-gray-100 pt-3">
                    <span class="text-xs font-bold text-gray-800">{{ medicine.quantity }} {{ medicine.unit }} available</span>
                    <button type="button" @click="requestMedicine(medicine)"
                        class="inline-flex shrink-0 items-center gap-1 rounded-lg bg-blue-700 px-3 py-2 text-xs font-semibold text-white transition hover:bg-blue-800">
                        Request <ArrowRight :size="14" />
                    </button>
                </div>
            </article>
        </div>
    </section>
</template>
