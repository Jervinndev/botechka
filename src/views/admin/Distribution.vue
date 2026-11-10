<script setup>
import { computed, onMounted, ref } from 'vue';
import {
    Search,
    RotateCcw,
    Plus,
    Minus,
    ClipboardList,
    X,
    ChevronDown,
    CalendarDays,
    Clock,
    Eye,
} from '@lucide/vue'
import Selectmedicines from '../../components/modals/Selectmedicines.vue'
import Addnewpurpose from '../../components/modals/Addnewpurpose.vue'
import AddNewBeneficiary from '../../components/modals/AddNewBeneficiary.vue';
import { getBeneficiaries } from '../../services/Beneficiaries'
import {
    dispenseDistribution,
    getDistributionPurposes,
    getDistributionTransactions,
    returnDistributionTransaction
} from '../../services/Distribution'
import { getMedicines } from '../../services/Fetches'
import AdminTopActions from '../../components/admin/AdminTopActions.vue'

const IsmodalOpen = ref(false)
const Isaddpurposeopen = ref(false)
const IsbeneficiaryOpen = ref(false)
const selectedMedicines = ref([])
const beneficiaries = ref([])
const purposes = ref([])
const selectedBeneficiaryId = ref('')
const selectedPurposeId = ref('')
const isConfirmDispenseOpen = ref(false)
const isDispensing = ref(false)
const alertMessage = ref('')
const isLoadingOptions = ref(false)
const optionsError = ref('')
const transactions = ref([])
const isLoadingTransactions = ref(false)
const transactionsError = ref('')
const successMessage = ref('')
const transactionSearchQuery = ref('')
const expandedTransactionId = ref(null)
const viewedTransaction = ref(null)
const isTransactionViewOpen = ref(false)
const transactionToReturn = ref(null)
const isReturnConfirmOpen = ref(false)
const isReturning = ref(false)
const returnError = ref('')
const totalMedicineQuantity = computed(() => selectedMedicines.value.reduce((total, medicine) => total + medicine.quantity, 0))
const selectedBeneficiary = computed(() => beneficiaries.value.find(
    (beneficiary) => beneficiary.beneficiary_id === selectedBeneficiaryId.value
))
const selectedPurpose = computed(() => purposes.value.find(
    (purpose) => purpose.purpose_id === selectedPurposeId.value
))
const filteredTransactions = computed(() => {
    const query = transactionSearchQuery.value.trim().toLowerCase()
    if (!query) return transactions.value

    return transactions.value.filter((transaction) => {
        const searchValues = [
            `dist-${String(transaction.distribution_transaction_id).padStart(4, '0')}`,
            transaction.distribution_date,
            transaction.purpose,
            transaction.beneficiaries?.beneficiary_type,
            getBeneficiaryName(transaction.beneficiaries),
            ...transaction.distribution_items.flatMap((item) => [
                item.medicine_name,
                item.medicine?.category
            ])
        ]
        return searchValues.some((value) => String(value || '').toLowerCase().includes(query))
    })
})

function getBeneficiaryName(beneficiary) {
    if (!beneficiary) return 'Unknown beneficiary'

    return [
        beneficiary.first_name,
        beneficiary.middle_name,
        beneficiary.last_name,
        beneficiary.suffix
    ].filter(Boolean).join(' ')
}

function formatDistributionDate(date) {
    if (!date) return '—'
    const parsedDate = new Date(date)
    return Number.isNaN(parsedDate.getTime()) ? '—' : parsedDate.toLocaleString()
}

function getTransactionCategories(transaction) {
    return [...new Set(transaction.distribution_items
        .map((item) => item.medicine?.category)
        .filter(Boolean))]
}

function getTransactionQuantity(transaction) {
    return transaction.distribution_items.reduce((total, item) => total + Number(item.quantity || 0), 0)
}

function toggleTransaction(transactionId) {
    expandedTransactionId.value = expandedTransactionId.value === transactionId ? null : transactionId
}

function showTransaction(transaction) {
    viewedTransaction.value = transaction
    isTransactionViewOpen.value = true
}

function askReturnTransaction(transaction) {
    if (transaction.returned_at) return
    transactionToReturn.value = transaction
    returnError.value = ''
    isReturnConfirmOpen.value = true
}

async function confirmReturnTransaction() {
    if (!transactionToReturn.value || isReturning.value) return

    isReturning.value = true
    returnError.value = ''
    try {
        await returnDistributionTransaction(transactionToReturn.value.distribution_transaction_id)
        await fetchTransactions()
        isReturnConfirmOpen.value = false
        transactionToReturn.value = null
        successMessage.value = 'Medicines from the selected distribution were returned to inventory.'
    } catch (error) {
        console.error('Error returning distribution medicines:', error)
        returnError.value = error.message || 'Unable to return these medicines. Please try again.'
    } finally {
        isReturning.value = false
    }
}

async function fetchBeneficiaries(preselect = null) {
    const result = await getBeneficiaries()
    if (result.error) throw result.error

    beneficiaries.value = result.data || []
    optionsError.value = ''
    if (preselect) selectedBeneficiaryId.value = preselect.beneficiary_id
}

async function fetchPurposes(preselect = null) {
    purposes.value = await getDistributionPurposes()
    optionsError.value = ''
    if (preselect) selectedPurposeId.value = preselect.purpose_id
}

async function fetchFormOptions() {
    isLoadingOptions.value = true
    optionsError.value = ''

    const results = await Promise.allSettled([fetchBeneficiaries(), fetchPurposes()])
    const failedResult = results.find((result) => result.status === 'rejected')
    if (failedResult) {
        console.error('Error fetching distribution form options:', failedResult.reason)
        optionsError.value = failedResult.reason?.message || 'Unable to load beneficiary or purpose options.'
    }

    isLoadingOptions.value = false
}

async function fetchTransactions() {
    isLoadingTransactions.value = true
    transactionsError.value = ''

    try {
        transactions.value = await getDistributionTransactions()
    } catch (error) {
        console.error('Error fetching distribution transactions:', error)
        transactionsError.value = error.message || 'Unable to load distribution history.'
    } finally {
        isLoadingTransactions.value = false
    }
}

function addMedicines(medicines) {
    for (const medicine of medicines) {
        const existingMedicine = selectedMedicines.value.find((item) => item.id === medicine.id)
        if (!existingMedicine && medicine.stock > 0) selectedMedicines.value.push({ ...medicine, quantity: 1 })
    }
}

function changeMedicineQuantity(medicine, amount) {
    medicine.quantity = Math.min(medicine.stock, Math.max(1, medicine.quantity + amount))
}

function setMedicineQuantity(medicine, event) {
    const enteredQuantity = Number(event.target.value)
    if (!Number.isInteger(enteredQuantity) || enteredQuantity < 1) {
        event.target.value = medicine.quantity
        return
    }
    if (enteredQuantity > medicine.stock) {
        alertMessage.value = `Insufficient Quantity: The quantity entered (${enteredQuantity}) exceeds the available stock for this medicine. Current stock: ${medicine.stock}.`
        event.target.value = medicine.quantity
        return
    }

    medicine.quantity = enteredQuantity
}

function removeMedicine(medicineId) {
    selectedMedicines.value = selectedMedicines.value.filter((medicine) => medicine.id !== medicineId)
}

async function prepareDispense() {
    alertMessage.value = ''
    successMessage.value = ''

    if (!selectedBeneficiaryId.value || !selectedPurposeId.value || !selectedMedicines.value.length) {
        alertMessage.value = 'Select a beneficiary, purpose, and at least one medicine before dispensing.'
        return
    }

    try {
        const currentMedicines = await getMedicines()
        for (const medicine of selectedMedicines.value) {
            const currentMedicine = currentMedicines.find((item) => item.id === medicine.id)
            const currentStock = Math.max(0, Number(currentMedicine?.quantity) || 0)
            medicine.stock = currentStock

            if (!currentMedicine || medicine.quantity > currentStock) {
                alertMessage.value = `Insufficient Quantity: The quantity entered (${medicine.quantity}) exceeds the available stock for this medicine. Current stock: ${currentStock}.`
                return
            }
        }

        isConfirmDispenseOpen.value = true
    } catch (error) {
        console.error('Error validating medicine stock:', error)
        alertMessage.value = 'Unable to verify current stock. Please try again.'
    }
}

async function confirmDispense() {
    if (isDispensing.value) return

    isDispensing.value = true
    alertMessage.value = ''
    try {
        await dispenseDistribution({
            beneficiaryId: selectedBeneficiaryId.value,
            distributionDate: new Date().toISOString(),
            purpose: selectedPurpose.value.purpose_name,
            items: selectedMedicines.value
        })

        isConfirmDispenseOpen.value = false
        selectedMedicines.value = []
        successMessage.value = 'Medicines dispensed and inventory updated.'
        await fetchTransactions()
    } catch (error) {
        console.error('Error dispensing medicines:', error)
        const message = error.message || ''
        alertMessage.value = message.includes('Insufficient Quantity:')
            ? message
            : 'Unable to dispense these medicines. Please try again.'
        isConfirmDispenseOpen.value = false
    } finally {
        isDispensing.value = false
    }
}

function handleBeneficiarySaved(beneficiary) {
    fetchBeneficiaries(beneficiary).catch((error) => {
        console.error('Error refreshing beneficiaries:', error)
        optionsError.value = error.message || 'Unable to refresh beneficiaries.'
    })
}

function handlePurposeSaved(purpose) {
    fetchPurposes(purpose).catch((error) => {
        console.error('Error refreshing purposes:', error)
        optionsError.value = error.message || 'Unable to refresh purposes.'
    })
}

onMounted(() => {
    fetchFormOptions()
    fetchTransactions()
})
</script>

<template>
    <section class="w-full">
        <!-- HEADER -->
        <div class="flex justify-between items-center gap-4">
            <div>
                <h1 class="font-inter font-bold text-[#404040] text-lg">Distribution</h1>
                <p class="text-sm text-[#808080]">Manage your distribution channels and logistics</p>
            </div>

            <AdminTopActions />
        </div>
        <div class="grid grid-cols-1 mt-4 gap-4 items-start">
            <div class="w-full grid 2xl:grid-cols-2 grid-cols-1 gap-4 min-w-0">
                <div class="bg-white p-4 w-full rounded-lg border border-gray-100">
                    <div>
                        <h1 class="font-bold text-xl text-gray-800">New Distribution</h1>
                        <p class="text-sm text-gray-400 mt-1">Record medicine given to a beneficiary</p>
                    </div>
                    <div class="mt-4 p-4 border border-black/10 rounded-xl">
                        <div class="flex justify-between items-center gap-2">
                            <h2 class="text-sm font-medium text-gray-700">Beneficiary </h2>
                            <button type="button" @click="IsbeneficiaryOpen = true"
                                class="flex items-center justify-center gap-2 rounded-md bg-blue-700 p-2 px-4 text-sm text-white transition hover:bg-blue-800 whitespace-nowrap">
                                Add New Beneficiaries
                            </button>
                        </div>
                        <div class="relative mt-3">
                            <select v-model="selectedBeneficiaryId" :disabled="isLoadingOptions"
                                class="appearance-none w-full border border-black/10 rounded-xl p-2.5 pr-9 text-sm text-gray-600 outline-none focus:border-blue-500 bg-white">
                                <option value="">Select Beneficiary</option>
                                <option v-for="beneficiary in beneficiaries" :key="beneficiary.beneficiary_id"
                                    :value="beneficiary.beneficiary_id">
                                    {{ getBeneficiaryName(beneficiary) }}
                                </option>
                            </select>
                            <ChevronDown :size="16"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" />
                        </div>
                    </div>
                    <div class="mt-4 p-4 border border-black/10 rounded-xl">
                        <div class="flex justify-between items-center gap-2">
                            <h2 class="text-sm font-medium text-gray-700">Purpose (Ailment)</h2>
                            <button type="button" @click="Isaddpurposeopen = true"
                                class="flex items-center justify-center gap-2 rounded-md bg-blue-700 p-2 px-4 text-sm text-white transition hover:bg-blue-800 whitespace-nowrap">
                                Add New Purpose
                            </button>
                        </div>
                        <div class="relative mt-3">
                            <select v-model="selectedPurposeId" :disabled="isLoadingOptions"
                                class="appearance-none w-full border border-black/10 rounded-xl p-2.5 pr-9 text-sm text-gray-600 outline-none focus:border-blue-500 bg-white">
                                <option value="">Select Purpose</option>
                                <option v-for="purpose in purposes" :key="purpose.purpose_id"
                                    :value="purpose.purpose_id">
                                    {{ purpose.purpose_name }}
                                </option>
                            </select>
                            <ChevronDown :size="16"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" />
                        </div>
                    </div>

                    <p v-if="optionsError" role="alert" class="mt-3 text-sm text-red-600">{{ optionsError }}</p>

                    <div class="mt-4 p-4 border border-black/10 rounded-xl">
                        <div class="flex justify-between items-center gap-2">
                            <h2 class="text-sm font-medium text-gray-700">Medicines</h2>
                            <button type="button" @click="IsmodalOpen = true"
                                class="flex items-center justify-center gap-2 rounded-md bg-blue-700 p-2 px-4 text-sm text-white transition hover:bg-blue-800 whitespace-nowrap">
                                Add Item
                            </button>
                        </div>
                        <button type="button" @click="IsmodalOpen = true"
                            class="mt-3 flex w-full items-center justify-between rounded-xl border border-black/10 bg-white p-2.5 text-left text-sm text-gray-600 transition hover:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-100">
                            <span>{{ selectedMedicines.length ? `${selectedMedicines.length} medicine(s) selected` :
                                'Select Medicine' }}</span>
                            <ChevronDown :size="15" class="text-gray-400" />
                        </button>
                        <div v-if="selectedMedicines.length"
                            class="mt-3 w-full overflow-x-auto rounded-lg border border-gray-100">
                            <table class="w-full min-w-[640px] border-collapse text-left">
                                <thead class="bg-gray-50 text-xs font-semibold uppercase text-gray-500">
                                    <tr>
                                        <th class="px-3 py-2">Image</th>
                                        <th class="px-3 py-2">Medicine</th>
                                        <th class="px-3 py-2">Stock</th>
                                        <th class="px-3 py-2">Quantity</th>
                                        <th class="px-3 py-2 text-center">Action</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-100">
                                    <tr v-for="medicine in selectedMedicines" :key="medicine.id"
                                        class="text-sm text-gray-700">
                                        <td class="px-3 py-2">
                                            <img v-if="medicine.image_url" :src="medicine.image_url"
                                                :alt="`${medicine.name} image`"
                                                class="h-10 w-10 rounded-lg object-cover">
                                            <span v-else class="text-xs text-gray-400">No image</span>
                                        </td>
                                        <td class="px-3 py-2">
                                            <p class="font-medium">{{ medicine.name }}</p>
                                            <p class="text-xs text-gray-400">{{ medicine.strength }}</p>
                                        </td>
                                        <td class="px-3 py-2">{{ medicine.stock }} {{ medicine.unit }}</td>
                                        <td class="px-3 py-2">
                                            <div class="flex items-center gap-2">
                                                <button type="button" :aria-label="`Decrease ${medicine.name} quantity`"
                                                    :disabled="medicine.quantity <= 1"
                                                    @click="changeMedicineQuantity(medicine, -1)"
                                                    class="flex h-7 w-7 items-center justify-center rounded-md border border-gray-200 text-gray-600 transition hover:bg-blue-50 hover:text-blue-700 disabled:opacity-40">
                                                    <Minus :size="14" />
                                                </button>
                                                <input type="number" min="1" :max="medicine.stock"
                                                    :value="medicine.quantity"
                                                    :aria-label="`${medicine.name} quantity`"
                                                    @change="setMedicineQuantity(medicine, $event)"
                                                    class="w-16 rounded border border-gray-200 px-2 py-1 text-center font-medium outline-none focus:border-blue-500">
                                                <button type="button" :aria-label="`Increase ${medicine.name} quantity`"
                                                    :disabled="medicine.quantity >= medicine.stock"
                                                    @click="changeMedicineQuantity(medicine, 1)"
                                                    class="flex h-7 w-7 items-center justify-center rounded-md border border-gray-200 text-gray-600 transition hover:bg-blue-50 hover:text-blue-700 disabled:opacity-40">
                                                    <Plus :size="14" />
                                                </button>
                                            </div>
                                        </td>
                                        <td class="px-3 py-2 text-center">
                                            <button type="button" :aria-label="`Remove ${medicine.name}`"
                                                @click="removeMedicine(medicine.id)"
                                                class="inline-flex h-8 w-8 items-center justify-center rounded-md border border-red-200 text-red-500 transition hover:bg-red-50">
                                                <X :size="15" />
                                            </button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="flex items-center justify-end gap-2 mt-5">
                        <p v-if="successMessage" role="status" class="mr-auto text-sm text-green-700">
                            {{ successMessage }}
                        </p>
                        <button type="button" @click="selectedMedicines = []"
                            class="rounded-md border border-gray-200 px-4 py-2 text-sm text-gray-600 transition hover:bg-gray-50">
                            Clear
                        </button>

                        <button type="button" @click="prepareDispense"
                            class="flex items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-2 text-sm text-white transition hover:bg-blue-800">Dispense
                        </button>
                    </div>
                </div>

                <div class="bg-white p-4 w-full rounded-lg border border-gray-100">
                    <div class="flex items-center gap-2">
                        <div class="flex items-center justify-center h-9 w-9 rounded-lg bg-blue-50 text-blue-700">
                            <ClipboardList :size="18" />
                        </div>
                        <div>
                            <h1 class="font-bold text-lg text-gray-800">Dispense Summary</h1>
                            <p class="text-xs text-gray-400 mt-0.5">Distribution details</p>
                        </div>
                    </div>
                    <div class="mt-4 border border-black/10 rounded-xl p-4">
                        <div class="flex justify-between items-center py-2">
                            <span class="text-sm text-gray-500">Beneficiary</span>
                            <span class="text-sm font-medium text-gray-700">{{ selectedBeneficiary ? getBeneficiaryName(selectedBeneficiary) : 'Not selected' }}</span>
                        </div>
                        <div class="flex justify-between items-center py-2 border-t border-gray-100">
                            <span class="text-sm text-gray-500">Purpose</span>
                            <span class="text-sm font-medium text-gray-700">{{ selectedPurpose?.purpose_name || 'Not selected' }}</span>
                        </div>
                        <div class="flex justify-between items-center py-2 border-t border-gray-100">
                            <span class="text-sm text-gray-500">Medicine Items</span>
                            <span class="text-sm font-medium text-gray-700">{{ selectedMedicines.length }}</span>
                        </div>
                        <div class="flex justify-between items-center py-2 border-t border-gray-100">
                            <span class="text-sm text-gray-500">Total Quantity</span>
                            <span class="text-sm font-semibold text-blue-700">{{ totalMedicineQuantity }}</span>
                        </div>
                        <div v-if="selectedMedicines.length" class="mt-2 border-t border-gray-100 pt-3">
                            <h2 class="mb-2 text-sm font-medium text-gray-700">Selected Medicines</h2>
                            <div v-for="medicine in selectedMedicines" :key="medicine.id"
                                class="flex items-center gap-3 border-b border-gray-100 py-2 last:border-b-0">
                                <img v-if="medicine.image_url" :src="medicine.image_url"
                                    :alt="`${medicine.name} image`"
                                    class="h-10 w-10 rounded-lg object-cover">
                                <div v-else
                                    class="flex h-10 w-10 items-center justify-center rounded-lg bg-gray-100 text-xs text-gray-400">
                                    No image
                                </div>
                                <div class="min-w-0 flex-1">
                                    <p class="truncate text-sm font-medium text-gray-700">{{ medicine.name }}</p>
                                    <p class="text-xs text-gray-500">{{ medicine.quantity }} {{ medicine.unit }}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="bg-white flex flex-col gap-4 min-w-0 rounded-lg p-4">
                <div class="grid gap-3">
                    <div class="w-full flex flex-col sm:flex-row sm:justify-between gap-3">
                        <div class="relative w-full sm:max-w-[300px]">
                            <Search :size="17" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                            <input v-model="transactionSearchQuery" type="search" placeholder="Search distributions..."
                                class="border border-black/10 rounded-xl py-2 pl-9 pr-3 w-full outline-none focus:border-blue-500 text-sm" />
                        </div>
                    </div>
                    <div class="flex flex-wrap items-center gap-2">
                        <select class="filter-input">
                            <option value="">All Categories</option>
                            <option value="General Medicine">General Medicine</option>
                            <option value="Cold Chain">Cold Chain</option>
                            <option value="High-Alert">High-Alert</option>
                        </select>
                        <div class="flex items-center gap-2 border border-gray-200 rounded-lg px-2 py-1.5">
                            <CalendarDays :size="14" class="text-gray-500 shrink-0" />
                            <input type="date" aria-label="Start date"
                                class="text-xs text-gray-600 bg-transparent outline-none w-[120px]" />
                        </div>
                        <div class="flex items-center gap-2 border border-gray-200 rounded-lg px-2 py-1.5">
                            <CalendarDays :size="14" class="text-gray-500 shrink-0" />
                            <input type="date" aria-label="End date"
                                class="text-xs text-gray-600 bg-transparent outline-none w-[120px]" />
                        </div>
                        <div class="flex items-center gap-2 border border-gray-200 rounded-lg px-2 py-1.5">
                            <Clock :size="14" class="text-gray-500 shrink-0" />
                            <input type="time" aria-label="Start time"
                                class="text-xs text-gray-600 bg-transparent outline-none w-[95px]" />
                        </div>
                        <div class="flex items-center gap-2 border border-gray-200 rounded-lg px-2 py-1.5">
                            <Clock :size="14" class="text-gray-500 shrink-0" />
                            <input type="time" aria-label="End time"
                                class="text-xs text-gray-600 bg-transparent outline-none w-[95px]" />
                        </div>
                        <select class="filter-input">
                            <option value="">All Expiry</option>
                            <option value="valid">Not Expired</option>
                            <option value="expiring">Expiring Soon</option>
                            <option value="expired">Expired</option>
                        </select>
                        <select class="filter-input">
                            <option value="">All Stock Status</option>
                            <option value="available">Available</option>
                            <option value="low">Low Stock</option>
                            <option value="out">Out of Stock</option>
                        </select>
                    </div>
                </div>
                <div class="w-full overflow-x-auto border border-gray-100 rounded-lg">
                    <table class="w-full min-w-[820px] border-collapse text-left">
                        <thead>
                            <tr class="bg-[#2638FF] text-white">
                                <th class="px-4 py-3 text-[12px] font-semibold uppercase tracking-wide">Transaction</th>
                                <th class="px-4 py-3 text-[12px] font-semibold uppercase tracking-wide">Date &amp; Time</th>
                                <th class="px-4 py-3 text-[12px] font-semibold uppercase tracking-wide">Beneficiary</th>
                                <th class="px-4 py-3 text-[12px] font-semibold uppercase tracking-wide">Category</th>
                                <th class="px-4 py-3 text-[12px] font-semibold uppercase tracking-wide">Quantity</th>
                                <th class="px-4 py-3 text-[12px] font-semibold uppercase tracking-wide">Purpose</th>
                                <th class="px-4 py-3 text-[12px] font-semibold uppercase tracking-wide text-center">
                                    Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                            <tr v-if="isLoadingTransactions || transactionsError">
                                <td colspan="7" class="px-4 py-8 text-center text-sm text-gray-500">
                                    {{ transactionsError || 'Loading distributions...' }}
                                </td>
                            </tr>
                            <tr v-else-if="filteredTransactions.length === 0">
                                <td colspan="7" class="px-4 py-8 text-center text-sm text-gray-500">
                                    {{ transactionSearchQuery ? 'No matching distributions found.' : 'No distributions recorded yet.' }}
                                </td>
                            </tr>
                            <template v-for="transaction in filteredTransactions"
                                :key="transaction.distribution_transaction_id">
                            <tr @click="toggleTransaction(transaction.distribution_transaction_id)"
                                @keydown.enter="toggleTransaction(transaction.distribution_transaction_id)"
                                tabindex="0" role="button"
                                :aria-expanded="expandedTransactionId === transaction.distribution_transaction_id"
                                class="cursor-pointer hover:bg-gray-50 transition-colors focus:outline-none focus-visible:bg-blue-50">
                                <td class="px-4 py-3 text-sm text-gray-500 whitespace-nowrap">
                                    DIST-{{ String(transaction.distribution_transaction_id).padStart(4, '0') }}
                                </td>
                                <td class="px-4 py-3 text-sm text-gray-500 whitespace-nowrap">
                                    {{ formatDistributionDate(transaction.distribution_date) }}
                                </td>
                                <td class="px-4 py-3">
                                    <p class="text-sm font-medium text-gray-700">{{ getBeneficiaryName(transaction.beneficiaries) }}</p>
                                    <p class="text-[12px] text-gray-400 mt-1">{{ transaction.beneficiaries?.beneficiary_type || 'Beneficiary' }}</p>
                                </td>
                                <td class="px-4 py-3 text-sm text-gray-600">
                                    {{ getTransactionCategories(transaction).join(', ') || 'Uncategorized' }}
                                </td>
                                <td class="px-4 py-3 text-sm text-gray-500 whitespace-nowrap">
                                    {{ getTransactionQuantity(transaction) }}
                                    <span class="text-xs text-gray-400">({{ transaction.distribution_items.length }} items)</span>
                                </td>
                                <td class="px-4 py-3 text-sm text-gray-500">{{ transaction.purpose }}</td>
                                <td class="px-4 py-3">
                                    <div class="flex items-center justify-center gap-2" @click.stop>
                                        <button type="button" title="View transaction" @click="showTransaction(transaction)"
                                            class="flex h-9 w-9 items-center justify-center rounded-md border border-gray-300 text-gray-500 transition hover:bg-blue-50 hover:text-blue-700">
                                            <Eye :size="16" />
                                        </button>
                                        <button type="button"
                                            :title="transaction.returned_at ? 'Already returned' : 'Return this distribution'"
                                            :disabled="Boolean(transaction.returned_at)"
                                            @click="askReturnTransaction(transaction)"
                                            class="flex h-9 w-9 items-center justify-center rounded-md border border-gray-300 text-gray-500 transition hover:bg-red-50 hover:text-red-500 disabled:cursor-not-allowed disabled:opacity-40">
                                            <RotateCcw :size="15" />
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="7" class="bg-blue-50/50 px-6 py-0">
                                    <Transition enter-active-class="transition duration-200 ease-out"
                                        enter-from-class="opacity-0 -translate-y-2"
                                        enter-to-class="opacity-100 translate-y-0"
                                        leave-active-class="transition duration-150 ease-in"
                                        leave-from-class="opacity-100 translate-y-0"
                                        leave-to-class="opacity-0 -translate-y-2">
                                        <div v-if="expandedTransactionId === transaction.distribution_transaction_id"
                                            class="py-4">
                                            <h3 class="mb-2 text-sm font-semibold text-gray-700">Medicines dispensed</h3>
                                            <ul class="grid gap-2 sm:grid-cols-2 lg:grid-cols-3">
                                                <li v-for="(item, index) in transaction.distribution_items"
                                                    :key="`${item.medicine_name}-${index}`"
                                                    class="flex items-center gap-3 rounded-lg border border-gray-100 bg-white p-3">
                                                    <img v-if="item.medicine_image_url" :src="item.medicine_image_url"
                                                        :alt="`${item.medicine_name} image`"
                                                        class="h-10 w-10 rounded-md object-cover">
                                                    <div v-else class="h-10 w-10 rounded-md bg-gray-100"></div>
                                                    <div class="min-w-0 flex-1">
                                                        <p class="truncate text-sm font-medium text-gray-700">{{ item.medicine_name }}</p>
                                                        <p class="text-xs text-gray-500">{{ item.quantity }} {{ item.unit || 'units' }}</p>
                                                    </div>
                                                </li>
                                            </ul>
                                        </div>
                                    </Transition>
                                </td>
                            </tr>
                            </template>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </section>


    <Selectmedicines :IsOpen="IsmodalOpen" @close="IsmodalOpen = false" @select="addMedicines" />
    <Addnewpurpose :IsOpen="Isaddpurposeopen" @close="Isaddpurposeopen = false" @saved="handlePurposeSaved" />
    <AddNewBeneficiary :IsOpen="IsbeneficiaryOpen" @close="IsbeneficiaryOpen = false"
        @saved="handleBeneficiarySaved" />

    <Transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0"
        enter-to-class="opacity-100" leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100" leave-to-class="opacity-0">
        <section v-if="isTransactionViewOpen && viewedTransaction"
            class="fixed inset-0 z-[60] flex items-center justify-center bg-black/40 p-4">
            <div role="dialog" aria-modal="true" aria-labelledby="distribution-view-title"
                class="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-xl bg-white p-6 shadow-xl">
                <div class="flex items-start justify-between gap-4">
                    <div>
                        <h2 id="distribution-view-title" class="text-lg font-bold text-gray-800">Distribution Details</h2>
                        <p class="mt-1 text-sm text-gray-500">
                            DIST-{{ String(viewedTransaction.distribution_transaction_id).padStart(4, '0') }}
                        </p>
                    </div>
                    <button type="button" aria-label="Close details" @click="isTransactionViewOpen = false"
                        class="rounded-md p-1 text-gray-500 hover:bg-gray-100">
                        <X :size="20" />
                    </button>
                </div>
                <dl class="mt-5 grid gap-3 border-b border-gray-100 pb-4 sm:grid-cols-2">
                    <div>
                        <dt class="text-xs text-gray-400">Beneficiary</dt>
                        <dd class="mt-1 text-sm font-medium text-gray-700">
                            {{ getBeneficiaryName(viewedTransaction.beneficiaries) }}
                        </dd>
                    </div>
                    <div>
                        <dt class="text-xs text-gray-400">Date &amp; Time</dt>
                        <dd class="mt-1 text-sm font-medium text-gray-700">
                            {{ formatDistributionDate(viewedTransaction.distribution_date) }}
                        </dd>
                    </div>
                    <div>
                        <dt class="text-xs text-gray-400">Purpose</dt>
                        <dd class="mt-1 text-sm font-medium text-gray-700">{{ viewedTransaction.purpose }}</dd>
                    </div>
                    <div>
                        <dt class="text-xs text-gray-400">Status</dt>
                        <dd class="mt-1 text-sm font-medium text-gray-700">
                            {{ viewedTransaction.returned_at ? 'Returned to inventory' : 'Dispensed' }}
                        </dd>
                    </div>
                </dl>
                <h3 class="mb-2 mt-4 text-sm font-semibold text-gray-700">Medicines</h3>
                <ul class="divide-y divide-gray-100 rounded-lg border border-gray-100">
                    <li v-for="(item, index) in viewedTransaction.distribution_items"
                        :key="`${item.medicine_name}-${index}`" class="flex items-center gap-3 p-3">
                        <img v-if="item.medicine_image_url" :src="item.medicine_image_url"
                            :alt="`${item.medicine_name} image`" class="h-10 w-10 rounded-md object-cover">
                        <div v-else class="h-10 w-10 rounded-md bg-gray-100"></div>
                        <p class="min-w-0 flex-1 truncate text-sm font-medium text-gray-700">{{ item.medicine_name }}</p>
                        <p class="whitespace-nowrap text-sm text-gray-500">{{ item.quantity }} {{ item.unit || 'units' }}</p>
                    </li>
                </ul>
            </div>
        </section>
    </Transition>

    <Transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0"
        enter-to-class="opacity-100" leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100" leave-to-class="opacity-0">
        <section v-if="isReturnConfirmOpen && transactionToReturn"
            class="fixed inset-0 z-[60] flex items-center justify-center bg-black/40 p-4">
            <div role="alertdialog" aria-modal="true" aria-labelledby="return-distribution-title"
                class="w-full max-w-md rounded-xl bg-white p-6 shadow-xl">
                <h2 id="return-distribution-title" class="text-lg font-bold text-gray-800">Return Medicines</h2>
                <p class="mt-2 text-sm text-gray-600">
                    Ibalik ang lahat ng gamot mula sa napiling distribution sa inventory?
                </p>
                <div class="mt-4 rounded-lg bg-gray-50 p-3 text-sm text-gray-600">
                    <p class="font-medium text-gray-800">
                        DIST-{{ String(transactionToReturn.distribution_transaction_id).padStart(4, '0') }}
                    </p>
                    <p class="mt-1">{{ getBeneficiaryName(transactionToReturn.beneficiaries) }}</p>
                    <p class="mt-1">
                        {{ transactionToReturn.distribution_items.length }} medicine(s),
                        {{ getTransactionQuantity(transactionToReturn) }} total units
                    </p>
                </div>
                <p v-if="returnError" role="alert" class="mt-3 text-sm text-red-600">{{ returnError }}</p>
                <div class="mt-6 flex justify-end gap-3">
                    <button type="button" :disabled="isReturning"
                        @click="isReturnConfirmOpen = false; transactionToReturn = null"
                        class="rounded-lg border border-gray-200 px-4 py-2 text-sm text-gray-600 hover:bg-gray-50 disabled:opacity-50">
                        Cancel
                    </button>
                    <button type="button" :disabled="isReturning" @click="confirmReturnTransaction"
                        class="flex items-center gap-2 rounded-lg bg-blue-700 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-800 disabled:cursor-not-allowed disabled:opacity-50">
                        <RotateCcw :size="15" />
                        {{ isReturning ? 'Returning...' : 'Confirm Return' }}
                    </button>
                </div>
            </div>
        </section>
    </Transition>

    <Transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0"
        enter-to-class="opacity-100" leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100" leave-to-class="opacity-0">
        <section v-if="alertMessage" class="fixed inset-0 z-[60] flex items-center justify-center bg-black/40 p-4">
            <div role="alertdialog" aria-modal="true" class="w-full max-w-md rounded-xl bg-white p-6 shadow-xl">
                <h2 class="text-lg font-bold text-red-700">Unable to Dispense</h2>
                <p class="mt-3 text-sm text-gray-600">{{ alertMessage }}</p>
                <button type="button" @click="alertMessage = ''"
                    class="mt-5 w-full rounded-lg bg-blue-700 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-800">
                    Close
                </button>
            </div>
        </section>
    </Transition>

    <Transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0"
        enter-to-class="opacity-100" leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100" leave-to-class="opacity-0">
        <section v-if="isConfirmDispenseOpen"
            class="fixed inset-0 z-[60] flex items-center justify-center bg-black/40 p-4">
            <div role="alertdialog" aria-modal="true" class="w-full max-w-md rounded-xl bg-white p-6 shadow-xl">
                <h2 class="text-lg font-bold text-gray-800">Confirm Dispense</h2>
                <p class="mt-3 text-sm text-gray-600">Are you sure you want to dispense these medicines?</p>
                <div class="mt-5 flex justify-end gap-3">
                    <button type="button" :disabled="isDispensing" @click="isConfirmDispenseOpen = false"
                        class="rounded-lg border border-gray-200 px-4 py-2 text-sm text-gray-600 hover:bg-gray-50">
                        Cancel
                    </button>
                    <button type="button" :disabled="isDispensing" @click="confirmDispense"
                        class="rounded-lg bg-blue-700 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-800 disabled:cursor-not-allowed disabled:opacity-60">
                        {{ isDispensing ? 'Dispensing...' : 'Confirm Dispense' }}
                    </button>
                </div>
            </div>
        </section>
    </Transition>
</template>
