<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { Pencil, Eye, Archive, RotateCcw, X, ChevronDown, FileSpreadsheet } from '@lucide/vue'
import { getMedicines } from '../../services/Fetches'
import AddMedicineModal from '../../components/modals/Addmedicine.vue'
import Addnewstocks from '../../components/modals/Addnewstocks.vue'
import InventorySkeleton from '../../Skelitonloader/inventoryskeliton.vue'
import { setRecordArchived } from '../../services/Archive'
import AdminTopActions from '../../components/admin/AdminTopActions.vue'
import { isWithinDateRange } from '../../utils/dateRange.js'
import readXlsxFile from 'read-excel-file/browser'

const medicines = ref([])
const dateRange = ref(null)
const route = useRoute()
const isLoading = ref(false)
const isAddModalOpen = ref(false)
const IsAddstockOpen = ref(false)
const isEditModalOpen = ref(false)
const selectedMedicine = ref(null)
const searchQuery = ref('')
const currentPage = ref(1)
const pageSize = 10
const actionError = ref('')
const fetchError = ref('')
const isImporting = ref(false)
const importInput = ref(null)

function normalizeHeader(value) {
    return String(value || '').trim().toLowerCase().replace(/[^a-z0-9]/g, '')
}

function formatImportDate(value, label) {
    if (value instanceof Date && !Number.isNaN(value.getTime())) {
        const year = value.getFullYear()
        const month = String(value.getMonth() + 1).padStart(2, '0')
        const day = String(value.getDate()).padStart(2, '0')
        return `${year}-${month}-${day}`
    }

    const date = String(value || '').trim()
    if (/^\d{4}-\d{2}-\d{2}$/.test(date) && !Number.isNaN(Date.parse(`${date}T00:00:00`))) {
        return date
    }

    throw new Error(`${label} must be an Excel date cell or use YYYY-MM-DD format.`)
}

async function importMedicines(event) {
    const file = event.target.files?.[0]
    event.target.value = ''
    if (!file) return

    actionError.value = ''
    isImporting.value = true
    try {
        if (file.size > 10 * 1024 * 1024) throw new Error('Choose a workbook smaller than 10 MB.')
        const [headerRow, ...dataRows] = await readXlsxFile(file)
        if (!headerRow?.length) throw new Error('The workbook does not contain a header row.')

        const headerAliases = {
            medicinename: 'medicine_name',
            medicineid: 'medicine_id',
            category: 'category',
            quantity: 'quantity',
            price: 'price',
            priceperunit: 'price',
            restocklevel: 'restock_level',
            dosage: 'dosage',
            unit: 'unit',
            batchnumber: 'batch_number',
            supplier: 'supplier',
            manufacturingdate: 'manufacturing_date',
            expirationdate: 'expiration_date'
        }
        const headers = headerRow.map((header) => headerAliases[normalizeHeader(header)])
        const rows = dataRows
            .filter((row) => row.some((value) => value !== null && value !== ''))
            .map((row) => Object.fromEntries(row
                .map((value, index) => [headers[index], value])
                .filter(([key]) => key)))
        if (!rows.length) throw new Error('The first worksheet has no medicine rows.')

        let savedCount = 0
        for (const [index, row] of rows.entries()) {
            const required = ['medicine_name', 'category', 'quantity', 'dosage', 'unit', 'batch_number',
                'supplier', 'manufacturing_date', 'expiration_date']
            const missing = required.filter((key) => row[key] === '' || row[key] === null || row[key] === undefined)
            if (missing.length) {
                throw new Error(`Row ${index + 2} is missing: ${missing.join(', ')}. ${savedCount} earlier row(s) were saved.`)
            }

            const payload = {
                medicine_name: String(row.medicine_name).trim(),
                medicine_id: String(row.medicine_id || `MED-${crypto.randomUUID().slice(0, 8).toUpperCase()}`).trim(),
                category: String(row.category).trim(),
                quantity: Number(row.quantity),
                price: Number(row.price || 0),
                restock_level: Number(row.restock_level || 10),
                dosage: String(row.dosage).trim(),
                unit: String(row.unit).trim(),
                batch_number: String(row.batch_number).trim(),
                supplier: String(row.supplier).trim(),
                manufacturing_date: formatImportDate(row.manufacturing_date, 'Manufacturing date'),
                expiration_date: formatImportDate(row.expiration_date, 'Expiration date')
            }
            if (!Number.isInteger(payload.quantity) || payload.quantity < 0
                || !Number.isFinite(payload.price) || payload.price < 0
                || !Number.isInteger(payload.restock_level) || payload.restock_level < 0) {
                throw new Error(`Row ${index + 2} has an invalid quantity, price, or restock level. ${savedCount} earlier row(s) were saved.`)
            }

            const result = await AddMedicine(payload)
            if (result.error) {
                throw new Error(`Row ${index + 2} (${payload.medicine_name}) failed: ${result.error.message}. ${savedCount} earlier row(s) were saved.`)
            }
            savedCount += 1
        }

        actionError.value = ''
        window.alert(`${savedCount} medicine(s) imported successfully.`)
        await fetchInventory()
    } catch (error) {
        console.error('Unable to import medicine workbook:', error)
        actionError.value = error.message || 'Unable to import this workbook.'
        await fetchInventory()
    } finally {
        isImporting.value = false
    }
}

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
        const matchesDate = isWithinDateRange(med.created_at, dateRange.value)
        return matchesCategory && matchesSearch && matchesDate
    })
})

const totalPages = computed(() => Math.ceil(searchfilter.value.length / pageSize))
const paginatedMedicines = computed(() => {
    const start = (currentPage.value - 1) * pageSize
    return searchfilter.value.slice(start, start + pageSize)
})
const pageNumbers = computed(() => {
    const visiblePageCount = 5
    let start = Math.max(1, currentPage.value - 2)
    let end = Math.min(totalPages.value, start + visiblePageCount - 1)
    start = Math.max(1, end - visiblePageCount + 1)

    return Array.from({ length: end - start + 1 }, (_, index) => start + index)
})

watch([searchQuery, dateRange, () => route.query.category], () => {
    currentPage.value = 1
})
watch(totalPages, pages => {
    if (currentPage.value > pages) currentPage.value = pages || 1
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
            <div class="bg-white p-2 rounded-md flex-row 2xl:flex w-full gap-2 items-center justify-between">
                <input type="text" placeholder="Search medicines...." class="p-2 bg-gray-100 w-full rounded-md"
                    v-model="searchQuery">
                <div class="flex items-end justify-end gap-2 2xl:mt-0 mt-2 font-inter w-full">
                    <button @click="isAddModalOpen = true"
                        class="flex items-center justify-center 2xl:w-auto w-full bg-blue-700 text-white p-2 px-4 gap-2 rounded-md hover:bg-blue-800 transition">
                        <span class="2xl:text-md text-sm">Add Medicines</span>
                    </button>
                    <button type="button" @click="importInput?.click()" :disabled="isImporting"
                        class="flex items-center justify-center 2xl:w-auto w-full bg-emerald-700 text-white p-2 px-4 gap-2 rounded-md hover:bg-emerald-800 transition disabled:opacity-50">
                        <FileSpreadsheet :size="16" />
                        <span class="2xl:text-md text-sm">{{ isImporting ? 'Importing...' : 'Batch Upload' }}</span>
                    </button>
                    <input ref="importInput" type="file" accept=".xlsx" class="hidden" @change="importMedicines">
                    <button @click="IsAddstockOpen = true"
                        class="flex items-center justify-center 2xl:w-auto w-full bg-green-700 text-white p-2 px-4 gap-2 rounded-md">
                        <span class="2xl:text-md text-sm">Add stock</span>
                    </button>
                </div>
            </div>
        </div>

        <div class="flex-row 2xl:flex items-center justify-between">
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
                <VueDatePicker v-model="dateRange" range :partial-range="false" :enable-time-picker="true"
                    placeholder="From - To" auto-apply class="min-w-[260px]" />
            </div>
            <div
                class="flex items-center justify-between gap-4 mt-4 p-2 rounded-md bg-white 2xl:w-fit w-full font-inter text-sm">
                <span>{{ searchfilter.length }} Medicines found</span>
                <button type="button" @click="fetchInventory" :disabled="isLoading" aria-label="Reload medicines"
                    title="Reload medicines"
                    class="flex h-9 w-9 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-500 transition hover:bg-gray-100 disabled:opacity-50">
                    <RotateCcw :size="16" :class="{ 'animate-spin': isLoading }" />
                </button>
            </div>
        </div>

        <p v-if="actionError" role="alert" class="mt-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">{{ actionError
            }}</p>
        <div
            class="hidden 2xl:block w-full h-162 rounded-xl overflow-x-scroll overflow-y-scroll [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none] mt-4">
            <!-- Table para sa Dynamic Data galing Supabase -->
            <table class="w-full bg-white border border-gray-100 rounded-xl border-collapse overflow-x-auto">
                <thead class="bg-blue-700 text-white">
                    <tr class="grid grid-cols-9 text-left">
                        <th class="p-3 font-semibold text-gray-50">Medicine Name</th>
                        <th class="p-3 font-semibold text-gray-50">Medicine ID</th>
                        <th class="p-3 font-semibold text-gray-50">Category</th>
                        <th class="p-3 font-semibold text-gray-50">Quantity</th>
                        <th class="p-3 font-semibold text-gray-50">Price</th>
                        <th class="p-3 font-semibold text-gray-50">Status</th>
                        <th class="p-3 font-semibold text-gray-50">Dosage</th>
                        <th class="p-3 font-semibold text-gray-50">Unit</th>
                        <th class="p-3 font-semibold text-gray-50">Action</th>
                    </tr>
                </thead>

                <InventorySkeleton v-if="isLoading" />
                <tbody v-else-if="fetchError">
                    <tr>
                        <td colspan="9" class="text-center p-6 text-red-600 text-sm">{{ fetchError }}</td>
                    </tr>
                </tbody>
                <tbody v-else-if="searchfilter.length === 0">
                    <tr>
                        <td colspan="9" class="text-center p-6 text-gray-500 text-sm">
                            Walang nakitang gamot na tumutugma sa iyong hinahanap.
                        </td>
                    </tr>
                </tbody>
                <tbody v-else class="divide-y divide-gray-100 w-full">
                    <tr v-for="med in paginatedMedicines" :key="med.id"
                        class="grid grid-cols-9 items-center hover:bg-gray-50 w-full">
                        <td class="flex item-center justify-start text-center gap-3 p-3 text-gray-700">
                            <img v-if="med.image_url" :src="med.image_url" :alt="`${med.medicine_name} image`"
                                class="h-10 w-10 rounded-lg object-cover">
                            <span v-else class="text-xs text-gray-400">No image</span>
                            <div class="flex items-center">{{ med.medicine_name }}</div>
                        </td>
                        <td class="p-3 text-gray-500">{{ med.medicine_id || 'N/A' }}</td>
                        <td class="p-3 text-gray-600">{{ med.category }}</td>
                        <td class="p-3 text-gray-700 font-medium">{{ med.quantity }}</td>
                        <td class="p-3 text-gray-700">₱{{ Number(med.price || 0).toFixed(2) }}</td>
                        <td class="p-3">
                            <span :class="{
                                'bg-green-100 text-green-700': med.quantity > med.restock_level,
                                'bg-yellow-100 text-yellow-700': med.quantity > 0 && med.quantity <= med.restock_level,
                                'bg-red-100 text-red-700': med.quantity === 0
                            }" class="px-2 py-1 text-xs rounded-full font-medium">
                                {{ med.quantity > med.restock_level ? 'Available' : (med.quantity > 0 ? 'Low Stock'
                                    : 'Out of Stock') }} </span>
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

        <div class="mt-4 max-h-162 space-y-3 overflow-y-auto 2xl:hidden">
            <template v-if="isLoading">
                <div v-for="row in 4" :key="row"
                    class="animate-pulse rounded-xl border border-gray-100 bg-white p-4">
                    <div class="h-4 w-2/3 rounded bg-gray-200"></div>
                    <div class="mt-4 grid grid-cols-2 gap-3">
                        <div v-for="column in 4" :key="column" class="h-10 rounded bg-gray-100"></div>
                    </div>
                </div>
            </template>
            <div v-else-if="fetchError" role="alert"
                class="rounded-xl border border-red-100 bg-white p-5 text-center text-sm text-red-600">
                {{ fetchError }}
            </div>
            <div v-else-if="searchfilter.length === 0"
                class="rounded-xl border border-gray-100 bg-white p-6 text-center text-sm text-gray-500">
                Walang nakitang gamot na tumutugma sa iyong hinahanap.
            </div>
            <template v-else>
                <article v-for="med in paginatedMedicines" :key="med.id"
                    class="rounded-xl border border-gray-100 bg-white p-4">
                    <div class="flex items-start gap-3">
                        <img v-if="med.image_url" :src="med.image_url" :alt="`${med.medicine_name} image`"
                            class="h-12 w-12 shrink-0 rounded-lg object-cover">
                        <div v-else
                            class="flex h-12 w-12 shrink-0 items-center justify-center rounded-lg bg-blue-50 text-lg font-semibold text-blue-700">
                            {{ med.medicine_name?.charAt(0) || '?' }}
                        </div>
                        <div class="min-w-0 flex-1">
                            <h2 class="break-words font-semibold text-gray-800">{{ med.medicine_name }}</h2>
                            <p class="mt-0.5 break-all text-xs text-gray-500">{{ med.medicine_id || 'N/A' }}</p>
                        </div>
                        <span :class="{
                            'bg-green-100 text-green-700': med.quantity > med.restock_level,
                            'bg-yellow-100 text-yellow-700': med.quantity > 0 && med.quantity <= med.restock_level,
                            'bg-red-100 text-red-700': med.quantity === 0
                        }" class="shrink-0 rounded-full px-2 py-1 text-[11px] font-medium">
                            {{ med.quantity > med.restock_level ? 'Available' : (med.quantity > 0 ? 'Low Stock' : 'Out of Stock') }}
                        </span>
                    </div>

                    <dl class="mt-4 grid grid-cols-2 gap-x-4 gap-y-3 border-t border-gray-100 pt-4 text-sm">
                        <div class="min-w-0">
                            <dt class="text-xs text-gray-500">Category</dt>
                            <dd class="mt-0.5 break-words font-medium text-gray-700">{{ med.category || '—' }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs text-gray-500">Quantity</dt>
                            <dd class="mt-0.5 font-medium text-gray-700">{{ med.quantity }} {{ med.unit }}</dd>
                        </div>
                        <div>
                            <dt class="text-xs text-gray-500">Price</dt>
                            <dd class="mt-0.5 font-medium text-gray-700">₱{{ Number(med.price || 0).toFixed(2) }}</dd>
                        </div>
                        <div class="min-w-0">
                            <dt class="text-xs text-gray-500">Dosage</dt>
                            <dd class="mt-0.5 break-words font-medium text-gray-700">{{ med.dosage || '—' }}</dd>
                        </div>
                    </dl>

                    <div class="mt-4 grid grid-cols-3 gap-2 border-t border-gray-100 pt-3">
                        <button type="button" title="View" @click="selectedMedicine = med"
                            class="flex min-h-11 items-center justify-center gap-1.5 rounded-lg border border-gray-200 text-sm text-gray-600 transition hover:bg-blue-50">
                            <Eye :size="16" />
                            <span>View</span>
                        </button>
                        <button type="button" title="Edit" @click="openEditMedicine(med)"
                            class="flex min-h-11 items-center justify-center gap-1.5 rounded-lg border border-gray-200 text-sm text-gray-600 transition hover:bg-amber-50">
                            <Pencil :size="16" />
                            <span>Edit</span>
                        </button>
                        <button type="button" title="Archive" @click="archiveMedicine(med)"
                            class="flex min-h-11 items-center justify-center gap-1.5 rounded-lg border border-gray-200 text-sm text-gray-600 transition hover:bg-gray-100">
                            <Archive :size="16" />
                            <span>Archive</span>
                        </button>
                    </div>
                </article>
            </template>
        </div>

        <div v-if="searchfilter.length > pageSize"
            class="mt-4 flex flex-col gap-3 text-sm text-gray-600 sm:flex-row sm:items-center sm:justify-between">
            <p>
                Showing {{ (currentPage - 1) * pageSize + 1 }}–{{ Math.min(currentPage * pageSize, searchfilter.length)
                }}
                of {{ searchfilter.length }} medicines
            </p>
            <nav class="flex flex-wrap items-center gap-1" aria-label="Inventory pagination">
                <button type="button" @click="currentPage--" :disabled="currentPage === 1"
                    class="rounded-md border border-gray-200 bg-white px-3 py-2 transition hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50">
                    Previous
                </button>
                <button v-for="page in pageNumbers" :key="page" type="button" @click="currentPage = page"
                    :aria-current="page === currentPage ? 'page' : undefined" :class="page === currentPage
                        ? 'border-blue-700 bg-blue-700 text-white'
                        : 'border-gray-200 bg-white text-gray-700 hover:bg-gray-50'"
                    class="min-w-10 rounded-md border px-3 py-2 transition">
                    {{ page }}
                </button>
                <button type="button" @click="currentPage++" :disabled="currentPage === totalPages"
                    class="rounded-md border border-gray-200 bg-white px-3 py-2 transition hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50">
                    Next
                </button>
            </nav>
        </div>

        <!-- Modal Component Integration -->
        <AddMedicineModal :IsOpen="isAddModalOpen" @close="isAddModalOpen = false" @saved="handleMedicineSaved" />
        <AddMedicineModal :IsOpen="isEditModalOpen" :medicine="selectedMedicine" @close="closeEditMedicine"
            @saved="handleMedicineSaved" />
        <Addnewstocks :IsOpen="IsAddstockOpen" @close="IsAddstockOpen = false" @saved="handleStockSaved" />
        <div v-if="selectedMedicine && !isEditModalOpen"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
            @click.self="selectedMedicine = null">
            <section role="dialog" aria-modal="true" aria-labelledby="medicine-details-title"
                class="w-full max-w-xl rounded-xl bg-white p-6 shadow-xl">
                <div class="flex items-start justify-between">
                    <div>
                        <h2 id="medicine-details-title" class="text-xl font-bold text-gray-800">{{
                            selectedMedicine.medicine_name }}</h2>
                        <p class="mt-1 text-sm text-gray-500">{{ selectedMedicine.medicine_id }}</p>
                    </div>
                    <button type="button" aria-label="Close" @click="selectedMedicine = null"
                        class="rounded-lg p-2 text-gray-500 hover:bg-gray-100">
                        <X :size="18" />
                    </button>
                </div>
                <dl class="mt-5 grid gap-4 sm:grid-cols-2">
                    <div>
                        <dt class="text-xs text-gray-500">Category</dt>
                        <dd class="mt-1 text-sm font-medium">{{ selectedMedicine.category }}</dd>
                    </div>
                    <div>
                        <dt class="text-xs text-gray-500">Available stock</dt>
                        <dd class="mt-1 text-sm font-medium">{{ selectedMedicine.quantity }} {{ selectedMedicine.unit }}
                        </dd>
                    </div>
                    <div>
                        <dt class="text-xs text-gray-500">Price per unit</dt>
                        <dd class="mt-1 text-sm font-medium">₱{{ Number(selectedMedicine.price || 0).toFixed(2) }}</dd>
                    </div>
                    <div>
                        <dt class="text-xs text-gray-500">Restock level</dt>
                        <dd class="mt-1 text-sm font-medium">{{ selectedMedicine.restock_level ?? 10 }} {{
                            selectedMedicine.unit }}</dd>
                    </div>
                    <div>
                        <dt class="text-xs text-gray-500">Dosage</dt>
                        <dd class="mt-1 text-sm font-medium">{{ selectedMedicine.dosage }}</dd>
                    </div>
                    <div>
                        <dt class="text-xs text-gray-500">Batch number</dt>
                        <dd class="mt-1 text-sm font-medium">{{ selectedMedicine.batch_number }}</dd>
                    </div>
                    <div>
                        <dt class="text-xs text-gray-500">Supplier</dt>
                        <dd class="mt-1 text-sm font-medium">{{ selectedMedicine.supplier }}</dd>
                    </div>
                    <div>
                        <dt class="text-xs text-gray-500">Expiration date</dt>
                        <dd class="mt-1 text-sm font-medium">{{ selectedMedicine.expiration_date || '—' }}</dd>
                    </div>
                </dl>
            </section>
        </div>
    </section>
</template>