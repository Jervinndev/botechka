<script setup>
import { computed, onMounted, ref } from 'vue'
import { ChartColumn, Printer, Download, Search } from '@lucide/vue'
import { supabase } from '../../supabase/supabase'
import AdminTopActions from '../../components/admin/AdminTopActions.vue'

const reportTypes = ['Category', 'Inventory', 'Dispensing', 'Beneficiary', 'Supplier', 'Audit Trail', 'Return']
const selectedReport = ref('Category')
const searchQuery = ref('')
const startDate = ref('')
const endDate = ref('')
const reportData = ref({
    medicines: [],
    transactions: [],
    beneficiaries: [],
    requests: []
})
const isLoading = ref(false)
const errorMessage = ref('')
const lowStockThreshold = ref(10)

function printReport() {
    window.print()
}

async function fetchReportData() {
    isLoading.value = true
    errorMessage.value = ''
    try {
        const [medicinesResult, transactionsResult, beneficiariesResult, requestsResult] = await Promise.all([
            supabase.from('medicines').select('*').is('archived_at', null).order('created_at', { ascending: false }),
            supabase.from('distribution_transactions').select(`
                distribution_transaction_id, distribution_date, purpose, returned_at,
                beneficiaries(first_name, middle_name, last_name, suffix),
                distribution_items(quantity, medicine_name, unit)
            `).order('distribution_date', { ascending: false }),
            supabase.from('beneficiaries').select('*').is('archived_at', null).order('created_at', { ascending: false }),
            supabase.from('medicine_requests').select('request_id, status, created_at, beneficiary_name, medicine_name, quantity')
                .order('created_at', { ascending: false })
        ])
        const failed = [medicinesResult, transactionsResult, beneficiariesResult, requestsResult].find((result) => result.error)
        if (failed?.error) throw failed.error

        reportData.value = {
            medicines: medicinesResult.data || [],
            transactions: transactionsResult.data || [],
            beneficiaries: beneficiariesResult.data || [],
            requests: requestsResult.data || []
        }
    } catch (error) {
        console.error('Unable to load report data:', error)
        errorMessage.value = error.message || 'Unable to load report data.'
    } finally {
        isLoading.value = false
    }
}

function inDateRange(dateValue) {
    if (!startDate.value && !endDate.value) return true
    const date = new Date(dateValue)
    if (Number.isNaN(date.getTime())) return false
    if (startDate.value && date < new Date(`${startDate.value}T00:00:00`)) return false
    if (endDate.value && date > new Date(`${endDate.value}T23:59:59.999`)) return false
    return true
}

const reportRows = computed(() => {
    const medicines = reportData.value.medicines
    let rows = []

    if (selectedReport.value === 'Category') {
        const grouped = new Map()
        for (const medicine of medicines.filter((item) => inDateRange(item.created_at))) {
            const category = medicine.category || 'Uncategorized'
            const row = grouped.get(category) || {
                id: category,
                category,
                medicineCount: 0,
                stock: 0,
                lowStock: 0,
                outOfStock: 0,
                expired: 0
            }
            const stock = Number(medicine.quantity) || 0
            row.medicineCount += 1
            row.stock += stock
            if (stock > 0 && stock <= lowStockThreshold.value) row.lowStock += 1
            if (stock === 0) row.outOfStock += 1
            if (medicine.expiration_date && new Date(medicine.expiration_date) < new Date()) row.expired += 1
            grouped.set(category, row)
        }
        rows = [...grouped.values()].map((row) => ({
            ...row,
            status: row.outOfStock || row.lowStock ? 'Low' : 'Healthy'
        }))
    } else if (selectedReport.value === 'Inventory') {
        rows = medicines.filter((medicine) => inDateRange(medicine.created_at)).map((medicine) => ({
            id: medicine.id,
            name: medicine.medicine_name,
            category: medicine.category,
            stock: medicine.quantity,
            unit: medicine.unit,
            expiry: medicine.expiration_date,
            status: Number(medicine.quantity) === 0 ? 'Out of stock' : Number(medicine.quantity) <= lowStockThreshold.value ? 'Low stock' : 'Available'
        }))
    } else if (selectedReport.value === 'Dispensing' || selectedReport.value === 'Return') {
        rows = reportData.value.transactions
            .filter((transaction) => inDateRange(transaction.distribution_date))
            .filter((transaction) => selectedReport.value !== 'Return' || transaction.returned_at)
            .map((transaction) => ({
                id: `DIST-${String(transaction.distribution_transaction_id).padStart(4, '0')}`,
                date: transaction.distribution_date,
                beneficiary: [
                    transaction.beneficiaries?.first_name,
                    transaction.beneficiaries?.middle_name,
                    transaction.beneficiaries?.last_name,
                    transaction.beneficiaries?.suffix
                ].filter(Boolean).join(' '),
                items: transaction.distribution_items?.map((item) => `${item.medicine_name} (${item.quantity} ${item.unit || 'units'})`).join(', '),
                quantity: transaction.distribution_items?.reduce((total, item) => total + Number(item.quantity || 0), 0),
                purpose: transaction.purpose,
                status: transaction.returned_at ? 'Returned' : 'Dispensed'
            }))
    } else if (selectedReport.value === 'Beneficiary') {
        rows = reportData.value.beneficiaries.filter((beneficiary) => inDateRange(beneficiary.registration_date || beneficiary.created_at))
            .map((beneficiary) => ({
                id: beneficiary.beneficiary_code,
                name: [beneficiary.first_name, beneficiary.middle_name, beneficiary.last_name, beneficiary.suffix].filter(Boolean).join(' '),
                type: beneficiary.beneficiary_type,
                barangay: beneficiary.barangay,
                eligibility: beneficiary.eligibility,
                status: beneficiary.status,
                registered: beneficiary.registration_date
            }))
    } else if (selectedReport.value === 'Supplier') {
        const grouped = new Map()
        for (const medicine of medicines) {
            const supplier = medicine.supplier || 'Unspecified'
            const row = grouped.get(supplier) || { id: supplier, supplier, medicineCount: 0, stock: 0 }
            row.medicineCount += 1
            row.stock += Number(medicine.quantity) || 0
            grouped.set(supplier, row)
        }
        rows = [...grouped.values()]
    } else if (selectedReport.value === 'Audit Trail') {
        rows = reportData.value.requests.filter((request) => inDateRange(request.created_at)).map((request) => ({
            id: `REQ-${request.request_id}`,
            date: request.created_at,
            activity: `Medicine request ${request.status}`,
            user: request.beneficiary_name,
            details: `${request.medicine_name} × ${request.quantity}`
        }))
    }

    const query = searchQuery.value.trim().toLowerCase()
    return rows.filter((row) => !query || Object.values(row)
        .some((value) => String(value ?? '').toLowerCase().includes(query)))
})

const reportColumns = computed(() => {
    const columns = {
        Category: [['id', 'ID'], ['category', 'Category Name'], ['medicineCount', 'No. of Medicines'], ['stock', 'Total Stock'], ['lowStock', 'Low Stock'], ['outOfStock', 'Out of Stock'], ['status', 'Status'], ['expired', 'Expired']],
        Inventory: [['id', 'Medicine ID'], ['name', 'Medicine'], ['category', 'Category'], ['stock', 'Stock'], ['unit', 'Unit'], ['expiry', 'Expiration'], ['status', 'Status']],
        Dispensing: [['id', 'Transaction'], ['date', 'Date & Time'], ['beneficiary', 'Beneficiary'], ['items', 'Medicines'], ['quantity', 'Quantity'], ['purpose', 'Purpose'], ['status', 'Status']],
        Beneficiary: [['id', 'Beneficiary ID'], ['name', 'Name'], ['type', 'Type'], ['barangay', 'Barangay'], ['eligibility', 'Eligibility'], ['status', 'Status'], ['registered', 'Registered']],
        Supplier: [['supplier', 'Supplier'], ['medicineCount', 'No. of Medicines'], ['stock', 'Total Stock']],
        'Audit Trail': [['id', 'Reference'], ['date', 'Date & Time'], ['activity', 'Activity'], ['user', 'Requested by'], ['details', 'Details']],
        Return: [['id', 'Transaction'], ['date', 'Date & Time'], ['beneficiary', 'Beneficiary'], ['items', 'Medicines'], ['quantity', 'Quantity'], ['purpose', 'Purpose'], ['status', 'Status']]
    }
    return columns[selectedReport.value]
})

function formatValue(value) {
    if (!value) return '—'
    if (typeof value === 'string' && /^\d{4}-\d{2}-\d{2}T/.test(value)) {
        const date = new Date(value)
        return Number.isNaN(date.getTime()) ? value : date.toLocaleString()
    }
    return value
}

function exportCsv() {
    const header = reportColumns.value.map(([, label]) => label)
    const rows = reportRows.value.map((row) => reportColumns.value.map(([key]) => row[key] ?? ''))
    const escapeCell = (value) => `"${String(value).replaceAll('"', '""')}"`
    const csv = [header, ...rows].map((row) => row.map(escapeCell).join(',')).join('\r\n')
    const url = URL.createObjectURL(new Blob([`\uFEFF${csv}`], { type: 'text/csv;charset=utf-8' }))
    const link = document.createElement('a')
    link.href = url
    link.download = `${selectedReport.value.toLowerCase().replaceAll(' ', '-')}-report.csv`
    link.click()
    URL.revokeObjectURL(url)
}

onMounted(() => {
    try {
        const configuration = JSON.parse(localStorage.getItem('botechka_configuration') || '{}')
        const configuredThreshold = Number(configuration.lowStockThreshold)
        lowStockThreshold.value = Number.isFinite(configuredThreshold)
            ? Math.max(0, configuredThreshold) : 10
    } catch (error) {
        console.error('Unable to load report configuration:', error)
    }
    fetchReportData()
})
</script>

<template>
    <div class="font-inter text-slate-900">
        <header class="mb-4 flex items-center justify-between">
            <div>
                <h1 class="font-inter text-lg font-bold text-[#404040]">Reports</h1>
                <p class="text-sm text-[#808080]">Overview of inventory, distribution, and beneficiary records</p>
            </div>
            <AdminTopActions />
        </header>

        <nav class="mb-4 inline-flex flex-wrap items-center gap-1 rounded-md bg-white p-2" aria-label="Report type">
            <button v-for="report in reportTypes" :key="report" type="button" @click="selectedReport = report"
                :class="selectedReport === report ? 'bg-blue-700 text-white' : 'text-slate-700 hover:bg-slate-100'"
                class="rounded-md px-5 py-2.5 text-sm font-medium transition">
                {{ report }}
            </button>
        </nav>

        <section class="rounded-xl border border-gray-100 bg-white p-5">
            <div class="mb-4 flex flex-wrap items-start justify-between gap-4">
                <div class="flex items-center gap-3">
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-100 text-blue-700">
                        <ChartColumn :size="18" />
                    </span>
                    <div>
                        <h2 class="font-bold text-slate-900">{{ selectedReport }} Report</h2>
                        <p class="text-xs text-slate-500">{{ reportRows.length }} matching records</p>
                    </div>
                </div>
                <div class="flex gap-2">
                    <button type="button" @click="printReport"
                        class="flex items-center gap-2 rounded-md bg-blue-700 px-4 py-2 text-sm font-medium text-white transition hover:bg-blue-800">
                        <Printer :size="15" /> Print Report
                    </button>
                    <button type="button" @click="exportCsv"
                        class="flex items-center gap-2 rounded-md bg-blue-700 px-4 py-2 text-sm font-medium text-white transition hover:bg-blue-800">
                        <Download :size="15" /> Export Excel
                    </button>
                </div>
            </div>

            <div class="mb-4 flex flex-wrap items-center gap-3 text-sm text-slate-600">
                <label class="flex items-center gap-2 rounded-md border border-gray-200 bg-gray-50 px-3 py-2">
                    From <input v-model="startDate" type="date" class="bg-transparent outline-none">
                </label>
                <label class="flex items-center gap-2 rounded-md border border-gray-200 bg-gray-50 px-3 py-2">
                    To <input v-model="endDate" type="date" class="bg-transparent outline-none">
                </label>
                <div class="relative ml-auto w-64">
                    <Search :size="14" class="absolute left-3 top-1/2 -translate-y-1/2" />
                    <input v-model="searchQuery" type="search" placeholder="Search report..."
                        class="w-full rounded-md bg-gray-100 py-2 pl-9 pr-3 text-sm outline-none placeholder:text-gray-500 focus:ring-2 focus:ring-blue-200">
                </div>
            </div>

            <p v-if="errorMessage" role="alert" class="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">{{ errorMessage }}</p>
            <p v-if="selectedReport === 'Audit Trail'" class="mb-4 text-xs text-slate-500">
                Audit activity shows medicine requests. Other actions are not recorded because this project does not yet have a general audit log.
            </p>

            <div class="overflow-x-auto rounded-xl border border-slate-200">
                <table class="w-full min-w-[800px] text-left text-xs">
                    <thead>
                        <tr class="bg-blue-700 font-semibold text-white">
                            <th v-for="([key, label]) in reportColumns" :key="key" class="px-4 py-3.5">{{ label }}</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <tr v-if="isLoading || errorMessage || !reportRows.length">
                            <td :colspan="reportColumns.length" class="px-4 py-8 text-center text-slate-500">
                                {{ errorMessage || (isLoading ? 'Loading report...' : 'No records found.') }}
                            </td>
                        </tr>
                        <tr v-for="(row, index) in reportRows" :key="row.id || index"
                            class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
                            <td v-for="([key]) in reportColumns" :key="key" class="px-4 py-3.5 text-slate-700">
                                {{ formatValue(row[key]) }}
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="mt-4 flex items-center justify-between text-sm text-slate-500">
                <p>Showing {{ reportRows.length }} of {{ reportRows.length }} entries</p>
                <button type="button" @click="fetchReportData" :disabled="isLoading"
                    class="rounded-md border border-gray-200 px-3 py-1.5 transition hover:bg-gray-50 disabled:opacity-50">
                    {{ isLoading ? 'Refreshing...' : 'Refresh' }}
                </button>
            </div>
        </section>
    </div>
</template>
