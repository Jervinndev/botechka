<script setup>
import { BookPlus, AlignVerticalSpaceAround, TriangleAlert, Plus } from '@lucide/vue'
import { computed, onMounted, ref } from 'vue'
import BeneficiaryTopActions from '../../components/beneficiary/BeneficiaryTopActions.vue'
import Requestbeneficiarymodal from '../../components/modals/Requestbeneficiarymodal.vue'
import { getMyBeneficiaryDashboardData } from '../../services/BeneficiaryDashboard.js'
import { getMyMedicineRequests } from '../../services/MedicineRequests.js'
import { getMedicines } from '../../services/Fetches.js'

const med = ref([])
const requests = ref([])
const beneficiary = ref(null)
const history = ref([])
const isLoading = ref(false)
const fetchError = ref('')
const requestSuccess = ref('')
const isRequestModalOpen = ref(false)
const searchQuery = ref('')

const filteredHistory = computed(() => {
    const query = searchQuery.value.trim().toLowerCase()
    if (!query) return history.value

    return history.value.filter((transaction) => [
        transaction.distribution_transaction_id,
        transaction.purpose,
        ...transaction.distribution_items.map((item) => item.medicine_name)
    ].some((value) => String(value ?? '').toLowerCase().includes(query)))
})

const requestCount = computed(() => requests.value.length)
const availableMedicineCount = computed(() => med.value.filter((medicine) => Number(medicine.quantity) > 0).length)
const statusLabel = computed(() => beneficiary.value?.eligibility || 'Not linked')
const nextDispensingLabel = computed(() => {
    const date = beneficiary.value?.next_dispensing_date
    if (!date) return 'Not scheduled'

    const scheduledDate = new Date(`${String(date).slice(0, 10)}T00:00:00`)
    if (Number.isNaN(scheduledDate.getTime())) return 'Not scheduled'

    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const daysLeft = Math.ceil((scheduledDate.getTime() - today.getTime()) / 86400000)
    if (daysLeft < 0) return 'Overdue'
    if (daysLeft === 0) return 'Today'
    return `${daysLeft} days left`
})

function formatDispensingDate(date) {
    if (!date) return 'No date set'
    const parsedDate = new Date(`${String(date).slice(0, 10)}T00:00:00`)
    return Number.isNaN(parsedDate.getTime()) ? 'No date set' : parsedDate.toLocaleDateString()
}

function formatDistributionDate(date) {
    if (!date) return '—'
    const parsedDate = new Date(date)
    return Number.isNaN(parsedDate.getTime()) ? '—' : parsedDate.toLocaleString()
}

function getTransactionQuantity(transaction) {
    return transaction.distribution_items.reduce((total, item) => total + Number(item.quantity || 0), 0)
}

async function loadDashboard() {
    isLoading.value = true
    fetchError.value = ''
    try {
        const [medicines, myRequests, dashboardData] = await Promise.all([
            getMedicines(),
            getMyMedicineRequests(),
            getMyBeneficiaryDashboardData()
        ])
        med.value = medicines || []
        requests.value = myRequests || []
        beneficiary.value = dashboardData.beneficiary
        history.value = dashboardData.history
    } catch (error) {
        console.error('Error fetching beneficiary dashboard data:', error)
        fetchError.value = error.message || 'Unable to load your dashboard data.'
        med.value = []
        requests.value = []
        beneficiary.value = null
        history.value = []
    } finally {
        isLoading.value = false
    }
}

async function handleRequestSaved() {
    isRequestModalOpen.value = false
    requestSuccess.value = 'Medicine request submitted.'
    await loadDashboard()
}

function openRequestModal() {
    requestSuccess.value = ''
    isRequestModalOpen.value = true
}

onMounted(loadDashboard)
</script>


<template>
    <div>
        <div class="flex items-center justify-between gap-3">
            <div>
                <h1 class="font-inter font-bold text-[#404040] text-lg">My Dashboard</h1>
                <p class="text-sm text-[#808080]">Hello po! Jervin Kamusta!</p>
            </div>
            <div>
                <BeneficiaryTopActions />
            </div>
        </div>
    </div>
    <div class="mt-4 grid grid-cols-2 gap-4 lg:grid-cols-4">
        <div
            class="relative flex flex-col items-start gap-3 overflow-hidden rounded-xl border border-gray-100 bg-white p-4 ">
            <span
                class="pointer-events-none absolute -right-5 -top-5 h-20 w-20 rounded-full border-[14px] border-blue-100"></span>
            <div class="relative flex h-11 w-11 shrink-0 items-center justify-center rounded-lg bg-blue-100/70">
                <TriangleAlert size="22" class="text-blue-700" />
            </div>
            <div class="relative flex min-w-0 flex-col">
                <p class="text-xs font-medium text-gray-500 sm:text-sm">My Requests</p>
                <h1 class="text-lg font-bold text-gray-900 sm:text-2xl">{{ isLoading ? '...' : requestCount }}</h1>
            </div>
        </div>

        <div
            class="relative flex flex-col items-start gap-3 overflow-hidden rounded-xl border border-gray-100 bg-white p-4 ">
            <span
                class="pointer-events-none absolute -right-5 -top-5 h-20 w-20 rounded-full border-[14px] border-blue-100"></span>
            <div class="relative flex h-11 w-11 shrink-0 items-center justify-center rounded-lg bg-blue-100/70">
                <BookPlus size="22" class="text-blue-700" />
            </div>
            <div class="relative flex min-w-0 flex-col">
                <p class="text-xs font-medium text-gray-500 sm:text-sm">Available Medicines</p>
                <h1 class="text-lg font-bold text-gray-900 sm:text-2xl">
                    {{ isLoading ? 'Loading...' : availableMedicineCount.toLocaleString() }}
                </h1>
            </div>
        </div>

        <div
            class="relative flex flex-col items-start gap-3 overflow-hidden rounded-xl border border-gray-100 bg-white p-4 ">
            <span
                class="pointer-events-none absolute -right-5 -top-5 h-20 w-20 rounded-full border-[14px] border-blue-100"></span>
            <div class="relative flex h-11 w-11 shrink-0 items-center justify-center rounded-lg bg-blue-100/70">
                <AlignVerticalSpaceAround size="22" class="text-blue-700" />
            </div>
            <div class="relative flex min-w-0 flex-col">
                <p class="text-xs font-medium text-gray-500 sm:text-sm">Next Dispensing Date</p>
                <h1 class="text-lg font-bold text-gray-900 sm:text-2xl">{{ nextDispensingLabel }}</h1>
                <p class="text-xs text-gray-500">{{ formatDispensingDate(beneficiary?.next_dispensing_date) }}</p>
            </div>
        </div>

        <div
            class="relative flex flex-col items-start gap-3 overflow-hidden rounded-xl border border-gray-100 bg-white p-4 ">
            <span
                class="pointer-events-none absolute -right-5 -top-5 h-20 w-20 rounded-full border-[14px] border-blue-100"></span>
            <div class="relative flex h-11 w-11 shrink-0 items-center justify-center rounded-lg bg-blue-100/70">
                <TriangleAlert size="22" class="text-blue-700" />
            </div>
            <div class="relative flex min-w-0 flex-col">
                <p class="text-xs font-medium text-gray-500 sm:text-sm">Your Status</p>
                <h1 class="text-lg font-bold text-gray-900 sm:text-2xl">{{ statusLabel }}</h1>
            </div>
        </div>

    </div>


    <p v-if="fetchError" role="alert" class="mt-3 rounded-lg bg-red-50 p-3 text-sm text-red-700">
        {{ fetchError }}
    </p>
    <p v-else-if="!isLoading && !beneficiary" class="mt-3 rounded-lg bg-amber-50 p-3 text-sm text-amber-800">
        Walang beneficiary record na naka-link sa account na ito. Ipa-link ito sa admin para makita ang iyong status at history.
    </p>
    <p v-if="requestSuccess" role="status" class="mt-3 rounded-lg bg-green-50 p-3 text-sm text-green-700">
        {{ requestSuccess }}
    </p>

    <!-- Table -->
    <div class="mt-6 font-inter text-gray-800 bg-white p-4 rounded-lg">
        <div class="flex items-center gap-3 mb-4">
            <div>
                <h1 class="2xl:text-xl text-md font-bold text-black/80 tracking-tight">Medicine Release History</h1>
                <p class="text-xs text-gray-400 mt-0.5">Your completed distributions</p>
            </div>
        </div>

        <!-- Filters & Search Bar Row -->
        <div class="flex justify-between items-stretch md:items-center gap-4 mb-4">

            <!-- Search Input -->
            <div class="flex items-center gap-2 w-full md:w-auto">
                <div class="relative w-full md:w-96">
                    <svg xmlns="http://www.w3.org/2000/svg"
                        class="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" fill="none"
                        viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                    <input v-model="searchQuery" type="search" placeholder="Search medicines..."
                        class="w-full bg-white text-xs text-gray-700 placeholder-gray-400 pl-10 pr-4 py-3 rounded-lg border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500" />

                </div>
            </div>
            <button type="button" @click="openRequestModal"
                aria-label="Request medicine"
                class="flex shrink-0 items-center justify-center gap-2 rounded-lg bg-blue-700 px-3 py-2 text-sm text-white hover:bg-blue-800">
                <Plus />
                <span class="hidden sm:inline">Request Medicine</span>
            </button>
        </div>

        <!-- Table Container -->
        <!-- MOBILE: cards -->
        <div class="space-y-3 md:hidden">
            <p v-if="isLoading" class="rounded-xl bg-white p-6 text-center text-sm text-gray-500">Loading release history...</p>
            <p v-else-if="!filteredHistory.length" class="rounded-xl bg-white p-6 text-center text-sm text-gray-500">
                No release history found.
            </p>
            <div v-for="transaction in filteredHistory" :key="transaction.distribution_transaction_id"
                class="rounded-xl border border-gray-100 bg-white p-4 shadow-sm">
                <div class="flex items-start justify-between gap-3">
                    <div>
                        <p class="text-sm font-semibold text-gray-900">
                            {{ `DIST-${String(transaction.distribution_transaction_id).padStart(4, '0')}` }}
                        </p>
                        <p class="mt-0.5 text-xs text-gray-500">{{ formatDistributionDate(transaction.distribution_date) }}</p>
                    </div>
                    <span class="shrink-0 rounded-full bg-blue-50 px-2.5 py-1 text-xs font-semibold text-blue-700">
                        {{ getTransactionQuantity(transaction) }} total
                    </span>
                </div>

                <div class="mt-3 border-t border-gray-100 pt-3">
                    <p v-for="(item, index) in transaction.distribution_items" :key="`${item.medicine_name}-${index}`"
                        class="text-sm font-bold text-gray-900">
                        {{ item.medicine_name }} <span class="text-xs font-normal text-gray-500">
                            — {{ item.quantity }} {{ item.unit || 'units' }}
                        </span>
                    </p>
                </div>

                <div class="mt-3 grid grid-cols-2 gap-3">
                    <div>
                        <p class="text-[10px] font-semibold uppercase tracking-wider text-gray-400">Purpose</p>
                        <p class="mt-0.5 text-sm text-gray-700">{{ transaction.purpose || '—' }}</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- TABLET / DESKTOP: table -->
        <div class="hidden overflow-hidden rounded-lg border border-black/5 bg-white md:block">
            <div class="overflow-x-auto">
                <table class="w-full border-collapse text-left">
                    <thead>
                        <tr class="bg-blue-700 text-xs font-semibold uppercase tracking-wider text-white">
                            <th class="whitespace-nowrap px-4 py-3.5">Transaction #</th>
                            <th class="whitespace-nowrap px-4 py-3.5">Date &amp; Time</th>
                            <th class="whitespace-nowrap px-4 py-3.5">Medicines</th>
                            <th class="whitespace-nowrap px-4 py-3.5">Quantity</th>
                            <th class="whitespace-nowrap px-4 py-3.5">Purpose</th>
                            <th class="whitespace-nowrap px-4 py-3.5">Status</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <tr v-if="isLoading">
                            <td colspan="6" class="px-4 py-8 text-center text-sm text-gray-500">Loading release history...</td>
                        </tr>
                        <tr v-else-if="fetchError">
                            <td colspan="6" class="px-4 py-8 text-center text-sm text-red-600">{{ fetchError }}</td>
                        </tr>
                        <tr v-else-if="!filteredHistory.length">
                            <td colspan="6" class="px-4 py-8 text-center text-sm text-gray-500">No release history found.</td>
                        </tr>
                        <tr v-for="transaction in filteredHistory" :key="transaction.distribution_transaction_id"
                            class="transition hover:bg-gray-50/50">
                            <td class="whitespace-nowrap px-4 py-4 text-sm font-semibold text-gray-900">
                                {{ `DIST-${String(transaction.distribution_transaction_id).padStart(4, '0')}` }}
                            </td>
                            <td class="whitespace-nowrap px-4 py-4">
                                <p class="text-sm text-gray-700">{{ formatDistributionDate(transaction.distribution_date) }}</p>
                            </td>
                            <td class="px-4 py-4">
                                <p v-for="(item, index) in transaction.distribution_items"
                                    :key="`${item.medicine_name}-${index}`" class="text-sm font-bold text-gray-900">
                                    {{ item.medicine_name }}
                                </p>
                            </td>
                            <td class="whitespace-nowrap px-4 py-4 text-sm font-medium text-gray-800">
                                {{ transaction.distribution_items.map(item => `${item.quantity} ${item.unit || 'units'}`).join(', ') }}
                            </td>
                            <td class="px-4 py-4 text-sm text-gray-700">{{ transaction.purpose || '—' }}</td>
                            <td class="px-4 py-4 text-sm text-gray-700">Dispensed</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <Requestbeneficiarymodal :IsOpen="isRequestModalOpen" @close="isRequestModalOpen = false"
        @saved="handleRequestSaved" />
</template>