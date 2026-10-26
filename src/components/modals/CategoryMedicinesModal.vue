<script setup>
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { Pill, Search, X } from '@lucide/vue'
import { getMedicinesByCategory } from '../../services/Fetches'
import { updateCategoryStatus } from '../../services/Medicines'
import { getLocalDateString } from '../../utils/dates'

const props = defineProps({
    IsOpen: Boolean,
    category: {
        type: Object,
        default: null
    }
})

const emit = defineEmits(['close', 'status-changed'])
const router = useRouter()
const medicines = ref([])
const searchQuery = ref('')
const isLoading = ref(false)
const isSaving = ref(false)
const errorMessage = ref('')
let requestId = 0

const stockedCount = computed(() =>
    medicines.value.filter(medicine => Number(medicine.quantity) > 0).length
)
const stockPercentage = computed(() =>
    medicines.value.length ? Math.round((stockedCount.value / medicines.value.length) * 100) : 0
)
const filteredMedicines = computed(() => {
    const query = searchQuery.value.trim().toLowerCase()
    if (!query) return medicines.value

    return medicines.value.filter(medicine =>
        medicine.medicine_name?.toLowerCase().includes(query) ||
        medicine.dosage?.toLowerCase().includes(query) ||
        medicine.unit?.toLowerCase().includes(query)
    )
})

function medicineStatus(medicine) {
    if (medicine.expiration_date && medicine.expiration_date < getLocalDateString()) {
        return 'Expired'
    }
    if (Number(medicine.quantity) <= 0) return 'Out of stock'
    if (Number(medicine.quantity) <= 50) return 'Low stock'
    return 'Stock in'
}

async function fetchCategoryMedicines(categoryName) {
    const currentRequest = ++requestId
    isLoading.value = true
    errorMessage.value = ''
    medicines.value = []
    searchQuery.value = ''

    try {
        const data = await getMedicinesByCategory(categoryName)
        if (currentRequest === requestId) medicines.value = data || []
    } catch (error) {
        if (currentRequest === requestId) {
            console.error('Failed to fetch medicines for category:', error)
            errorMessage.value = 'Failed to load medicines for this category.'
        }
    } finally {
        if (currentRequest === requestId) isLoading.value = false
    }
}

watch(
    () => [props.IsOpen, props.category?.category_name],
    ([isOpen, categoryName]) => {
        if (isOpen && categoryName) {
            fetchCategoryMedicines(categoryName)
        } else {
            requestId += 1
            medicines.value = []
            errorMessage.value = ''
        }
    },
    { immediate: true }
)

async function changeCategoryStatus(status) {
    if (!props.category || isSaving.value) return

    isSaving.value = true
    errorMessage.value = ''

    try {
        await updateCategoryStatus(props.category.id, status)
        emit('status-changed')
    } catch (error) {
        console.error('Failed to update category status:', error)
        errorMessage.value = 'Failed to update this category. Please try again.'
    } finally {
        isSaving.value = false
    }
}

function viewInInventory() {
    if (!props.category) return

    router.push({
        name: 'inventory',
        query: { category: props.category.category_name }
    })
    emit('close')
}
</script>

<template>
    <Transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0"
        enter-to-class="opacity-100" leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100" leave-to-class="opacity-0">
        <div v-if="IsOpen && category" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4"
            @click.self="emit('close')" @keydown.esc="emit('close')">
            <section class="flex max-h-[90vh] w-full max-w-md flex-col rounded-2xl bg-white p-4 shadow-xl font-inter"
                role="dialog" aria-modal="true" :aria-label="`${category.category_name} category medicines`">
                <header class="flex items-start justify-between border-b border-gray-200 pb-3">
                    <div>
                        <h2 class="text-lg font-bold text-gray-900">{{ category.category_name }}</h2>
                        <p class="text-sm text-gray-500">
                            {{ medicines.length }} items · {{ stockPercentage }}% stocked
                        </p>
                    </div>
                    <button type="button" class="rounded-lg p-1 text-gray-500 hover:bg-gray-100"
                        aria-label="Close category medicines" @click="emit('close')">
                        <X :size="20" />
                    </button>
                </header>

                <label class="mt-3 flex items-center gap-2 rounded-lg border border-gray-200 bg-gray-50 px-3">
                    <Search :size="18" class="shrink-0 text-gray-400" />
                    <input v-model="searchQuery" type="search" placeholder="Search in this category..."
                        class="w-full bg-transparent py-2 text-sm outline-none">
                </label>

                <p v-if="errorMessage" class="mt-3 rounded-lg bg-red-50 p-3 text-sm text-red-700">
                    {{ errorMessage }}
                </p>
                <div v-else-if="isLoading" class="flex min-h-40 items-center justify-center text-sm text-gray-500">
                    Loading category medicines...
                </div>
                <div v-else-if="filteredMedicines.length === 0"
                    class="flex min-h-40 items-center justify-center text-sm text-gray-500">
                    {{ medicines.length ? 'No medicines match your search.' : 'No medicines in this category.' }}
                </div>
                <ul v-else class="mt-2 min-h-0 flex-1 divide-y divide-gray-100 overflow-y-auto">
                    <li v-for="medicine in filteredMedicines" :key="medicine.id"
                        class="flex items-center gap-3 py-2.5">
                        <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg bg-blue-50 text-blue-700">
                            <Pill :size="20" />
                        </div>
                        <div class="min-w-0 flex-1">
                            <p class="truncate text-sm font-semibold text-gray-900">{{ medicine.medicine_name }}</p>
                            <p class="text-xs text-gray-500">{{ medicine.dosage }} {{ medicine.unit }}</p>
                        </div>
                        <span :class="{
                            'bg-green-100 text-green-700': medicineStatus(medicine) === 'Stock in',
                            'bg-yellow-100 text-yellow-800': medicineStatus(medicine) === 'Low stock',
                            'bg-red-100 text-red-700': medicineStatus(medicine) === 'Expired' || medicineStatus(medicine) === 'Out of stock'
                        }" class="shrink-0 rounded-lg px-2.5 py-1 text-xs font-medium">
                            {{ medicineStatus(medicine) }}
                        </span>
                    </li>
                </ul>

                <footer class="mt-3 grid grid-cols-2 gap-3 border-t border-gray-100 pt-3">
                    <button type="button" @click="viewInInventory"
                        class="rounded-lg bg-blue-700 px-3 py-2.5 text-sm font-semibold text-white hover:bg-blue-800">
                        View in Inventory
                    </button>
                    <button type="button" :disabled="isSaving" @click="changeCategoryStatus(
                        category.status === 'archived' ? 'active' : 'archived'
                    )" :class="category.status === 'archived'
                        ? 'border border-green-200 bg-green-50 text-green-700 hover:bg-green-100'
                        : 'border border-red-200 bg-red-50 text-red-700 hover:bg-red-100'"
                        class="rounded-lg px-3 py-2.5 text-sm font-semibold disabled:cursor-not-allowed disabled:opacity-60">
                        {{ isSaving ? 'Saving...' : category.status === 'archived' ? 'Restore' : 'Archive' }}
                    </button>
                </footer>
            </section>
        </div>
    </Transition>
</template>
