<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute } from 'vue-router'
import { Pencil, Eye, Archive, RotateCcw, X } from '@lucide/vue'
import { getMedicines } from '../../services/Fetches'
import AddMedicineModal from '../../components/modals/Addmedicine.vue'
import Addnewstocks from '../../components/modals/Addnewstocks.vue'
import InventorySkeleton from '../../Skelitonloader/inventoryskeliton.vue'
import { setRecordArchived } from '../../services/Archive'
import AdminTopActions from '../../components/admin/AdminTopActions.vue'

const medicines = ref([])
const date = ref(null)
const route = useRoute()
const isLoading = ref(false)
const isAddModalOpen = ref(false)
const IsAddstockOpen = ref(false)
const isEditModalOpen = ref(false)
const selectedMedicine = ref(null)
const searchQuery = ref('')
const actionError = ref('')
const fetchError = ref('')

async function fetchInventory() {
    isLoading.value = true
    fetchError.value = ''
    try {
        const data = await getMedicines()
        medicines.value = data
    } catch (error) {
        console.error('Error fetching inventory:', error)
        fetchError.value = error.message || 'Unable to load medicines. Please try again.'
        medicines.value = []
    } finally {
        isLoading.value = false
    }
}

function openEditMedicine(medicine) {
    selectedMedicine.value = medicine
    isEditModalOpen.value = true
}

function closeEditMedicine() {
    isEditModalOpen.value = false
    selectedMedicine.value = null
}

async function archiveMedicine(medicine) {
    if (!window.confirm(`Archive ${medicine.medicine_name}?`)) return
    actionError.value = ''
    try {
        await setRecordArchived('Medicines', medicine.id, true)
        await fetchInventory()
    } catch (error) {
        console.error('Unable to archive medicine:', error)
        actionError.value = error.message || 'Unable to archive this medicine.'
    }
}

function handleMedicineSaved() {
    isAddModalOpen.value = false
    fetchInventory()
}

function handleStockSaved() {
    IsAddstockOpen.value = false
    fetchInventory()
}

const searchfilter = computed(() => {
    const categoryQuery = String(route.query.category || '').trim().toLowerCase()
    const query = searchQuery.value.trim().toLowerCase()

    return medicines.value.filter(med => {
        const matchesCategory = !categoryQuery ||
            med.category?.trim().toLowerCase() === categoryQuery
        const matchesSearch = !query ||
            med.category?.toLowerCase().includes(query) ||
            med.medicine_name?.toLowerCase().includes(query)
        return matchesCategory && matchesSearch
    })
})

onMounted(() => {
    fetchInventory()
})
</script>

<template>
    <section>
        <div class="flex items-center justify-between">
            <div>
                <h1 class="font-inter font-bold text-[#404040] text-lg">Inventory</h1>
                <p class="text-sm text-[#808080]">Manage your medicine resources</p>
            </div>
            <AdminTopActions />
        </div>

        <div class="mt-4">
            <div class="bg-white p-2 rounded-md 2xl:flex grid w-full gap-2 items-center justify-between">
                <input type="text" placeholder="Search medicines...."
                    class="p-2 bg-gray-100 2xl:max-w-5xl max-w-full w-full rounded-md" v-model="searchQuery">
                <div class="flex gap-2 font-inter">
                    <!-- Button para buksan ang Add Medicine Modal -->
                    <button @click="isAddModalOpen = true"
                        class="flex items-center justify-center bg-blue-700 text-white p-2 px-4 gap-2 rounded-md hover:bg-blue-800 transition">
                        <span class="2xl:text-md text-sm">Add Medicines</span>
                    </button>
                    <button @click="IsAddstockOpen = true"
                        class="flex items-center justify-center bg-green-700 text-white p-2 px-4 gap-2 rounded-md">
                        <span class="2xl:text-md text-sm">Add stock</span>
                    </button>
                </div>
            </div>
        </div>

        <div class="flex items-center justify-between mt-4">
            <div class="flex items-center gap-4 mt-4 p-2 rounded-md bg-white w-fit font-inter">
                <div>
                    <h1 class="text-sm">Filter by category</h1>
                </div>
                <div class="flex">
                    <button class="flex gap-2 p-1.5 px-3 bg-blue-700 text-white rounded-md">
                        All
                        <ChevronDown />
                    </button>
                </div>
                <VueDatePicker v-model="date" placeholder="Select date"></VueDatePicker>
            </div>
            <div class="flex items-center gap-4 mt-4 p-2 rounded-md bg-white w-fit font-inter text-sm">
                <span>{{ searchfilter.length }} Medicines found</span>
                <button type="button" @click="fetchInventory" :disabled="isLoading" aria-label="Reload medicines"
                    title="Reload medicines"
                    class="flex h-9 w-9 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-500 transition hover:bg-gray-100 disabled:opacity-50">
                    <RotateCcw :size="16" :class="{ 'animate-spin': isLoading }" />
                </button>
            </div>
        </div>

        <div
            class="w-full h-150 overflow-x-scroll overflow-y-scroll [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none] mt-4">
            <p v-if="actionError" role="alert" class="mb-3 rounded-lg bg-red-50 p-3 text-sm text-red-700">{{ actionError }}</p>
            <!-- Table para sa Dynamic Data galing Supabase -->
            <table class="2xl:w-full w-200 bg-white border border-gray-100 rounded-xl border-collapse overflow-hidden">
                <thead class="bg-blue-700 text-white">
                    <tr class="grid grid-cols-8 text-left">
                        <th class="p-3 font-semibold text-gray-50">Medicine Name</th>
                        <th class="p-3 font-semibold text-gray-50">Medicine ID</th>
                        <th class="p-3 font-semibold text-gray-50">Category</th>
                        <th class="p-3 font-semibold text-gray-50">Quantity</th>
                        <th class="p-3 font-semibold text-gray-50">Status</th>
                        <th class="p-3 font-semibold text-gray-50">Dosage</th>
                        <th class="p-3 font-semibold text-gray-50">Unit</th>
                        <th class="p-3 font-semibold text-gray-50">Action</th>
                    </tr>
                </thead>

                <InventorySkeleton v-if="isLoading" />
                <tbody v-else-if="fetchError">
                    <tr>
                        <td colspan="8" class="text-center p-6 text-red-600 text-sm">{{ fetchError }}</td>
                    </tr>
                </tbody>
                <tbody v-else-if="searchfilter.length === 0">
                    <tr>
                        <td colspan="9" class="text-center p-6 text-gray-500 text-sm">
                            Walang nakitang gamot na tumutugma sa iyong hinahanap.
                        </td>
                    </tr>
                </tbody>
                <tbody v-else class="divide-y divide-gray-100">
                    <tr v-for="med in searchfilter" :key="med.id"
                        class="grid grid-cols-8 items-center hover:bg-gray-50">
                        <td class="flex item-center justify-start text-center gap-3 p-3 text-gray-700">
                            <img v-if="med.image_url" :src="med.image_url" :alt="`${med.medicine_name} image`"
                                class="h-10 w-10 rounded-lg object-cover">
                            <span v-else class="text-xs text-gray-400">No image</span>
                            <div class="flex items-center">{{ med.medicine_name }}</div>
                        </td>
                        <td class="p-3 text-gray-500">{{ med.medicine_id || 'N/A' }}</td>
                        <td class="p-3 text-gray-600">{{ med.category }}</td>
                        <td class="p-3 text-gray-700 font-medium">{{ med.quantity }}</td>
                        <td class="p-3">
                            <span :class="{
                                'bg-green-100 text-green-700': med.quantity > 50,
                                'bg-yellow-100 text-yellow-700': med.quantity > 0 && med.quantity <= 50,
                                'bg-red-100 text-red-700': med.quantity === 0
                            }" class="px-2 py-1 text-xs rounded-full font-medium">
                                {{ med.quantity > 50 ? 'Available' : (med.quantity > 0 ? 'Low Stock' : 'Out of Stock')
                                }}
                            </span>
                        </td>
                        <td class="p-3 text-gray-700">{{ med.dosage }}</td>
                        <td class="p-3 text-gray-700">{{ med.unit }}</td>
                        <td class="p-3 flex items-center gap-2">
                            <button title="View" @click="selectedMedicine = med"
                                class="p-1.5 text-gray-500 border border-gray-300 hover:bg-blue-50 rounded-lg transition">
                                <Eye size="22" />
                            </button>
                            <button title="Edit" @click="openEditMedicine(med)"
                                class="p-1.5 text-gray-500 border border-gray-300 hover:bg-amber-50 rounded-lg transition">
                                <Pencil size="22" />
                            </button>
                            <button title="Archive" @click="archiveMedicine(med)"
                                class="p-1.5 text-gray-500 border border-gray-300 hover:bg-gray-100 rounded-lg transition">
                                <Archive size="22" />
                            </button>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>


        <!-- Modal Component Integration -->
        <AddMedicineModal :IsOpen="isAddModalOpen" @close="isAddModalOpen = false" @saved="handleMedicineSaved" />
        <AddMedicineModal :IsOpen="isEditModalOpen" :medicine="selectedMedicine"
            @close="closeEditMedicine" @saved="handleMedicineSaved" />
        <Addnewstocks :IsOpen="IsAddstockOpen" @close="IsAddstockOpen = false" @saved="handleStockSaved" />
        <div v-if="selectedMedicine && !isEditModalOpen"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
            @click.self="selectedMedicine = null">
            <section role="dialog" aria-modal="true" aria-labelledby="medicine-details-title"
                class="w-full max-w-xl rounded-xl bg-white p-6 shadow-xl">
                <div class="flex items-start justify-between">
                    <div>
                        <h2 id="medicine-details-title" class="text-xl font-bold text-gray-800">{{ selectedMedicine.medicine_name }}</h2>
                        <p class="mt-1 text-sm text-gray-500">{{ selectedMedicine.medicine_id }}</p>
                    </div>
                    <button type="button" aria-label="Close" @click="selectedMedicine = null"
                        class="rounded-lg p-2 text-gray-500 hover:bg-gray-100"><X :size="18" /></button>
                </div>
                <dl class="mt-5 grid gap-4 sm:grid-cols-2">
                    <div><dt class="text-xs text-gray-500">Category</dt><dd class="mt-1 text-sm font-medium">{{ selectedMedicine.category }}</dd></div>
                    <div><dt class="text-xs text-gray-500">Available stock</dt><dd class="mt-1 text-sm font-medium">{{ selectedMedicine.quantity }} {{ selectedMedicine.unit }}</dd></div>
                    <div><dt class="text-xs text-gray-500">Dosage</dt><dd class="mt-1 text-sm font-medium">{{ selectedMedicine.dosage }}</dd></div>
                    <div><dt class="text-xs text-gray-500">Batch number</dt><dd class="mt-1 text-sm font-medium">{{ selectedMedicine.batch_number }}</dd></div>
                    <div><dt class="text-xs text-gray-500">Supplier</dt><dd class="mt-1 text-sm font-medium">{{ selectedMedicine.supplier }}</dd></div>
                    <div><dt class="text-xs text-gray-500">Expiration date</dt><dd class="mt-1 text-sm font-medium">{{ selectedMedicine.expiration_date || '—' }}</dd></div>
                </dl>
            </section>
        </div>
    </section>
</template>