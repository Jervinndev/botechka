<script setup>
import { ShieldCheck, ChevronsRight, AlignVerticalSpaceAround, Bell, TriangleAlert, BookPlus } from '@lucide/vue'
import { ref, onMounted } from 'vue'
import {
    Chart as ChartJS,
    Title,
    Tooltip,
    Legend,
    BarElement,
    LineElement,
    PointElement,
    CategoryScale,
    LinearScale,
    ArcElement
} from 'chart.js'
import { Bar, Line } from 'vue-chartjs'
import Dashboardskeliton from '../../Skelitonloader/Dashboardskeliton.vue'
import { getMedicines } from '../../services/Fetches'
import { getLocalDateString } from '../../utils/dates'

ChartJS.register(Title, Tooltip, Legend, BarElement, LineElement, PointElement, CategoryScale, LinearScale, ArcElement)

const loading = ref(true)
const medicines = ref([])

const barChartData = ref({
    labels: [],
    datasets: []
})

const barChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
        legend: { display: false }
    }
}

const lineChartData = ref({
    labels: [],
    datasets: []
})

const lineChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
        legend: { display: false }
    }
}

async function fetchDashboardData() {
    try {
        await new Promise(resolve => setTimeout(resolve, 1500))

        barChartData.value = {
            labels: ['Maintenance', 'Cough & Colds', 'Pain Reliever', 'Cancer Treatment', 'Diabetes'],
            datasets: [
                {
                    label: 'Purpose Count',
                    backgroundColor: '#2563eb',
                    borderColor: '#2563eb',
                    borderWidth: 1,
                    borderRadius: 6,
                    data: [48.8, 39.3, 30.3, 42.6, 36.9]
                }
            ]
        }

        lineChartData.value = {
            labels: ['1 Dec', '8 Dec', '16 Dec', '31 Dec', '1 Jan'],
            datasets: [
                {
                    label: 'Total Distribution',
                    backgroundColor: '#2563eb',
                    borderColor: '#2563eb',
                    borderWidth: 2,
                    tension: 0.3,
                    data: [50, 165, 140, 146, 200]
                }
            ]
        }
    } catch (error) {
        console.error('Error fetching dashboard data:', error)
    }
}

const stockAlerts = ref([])
const expiringItems = ref([])
const totalMedicineStock = ref(0)
const medicineShortageCount = ref(0)
const expiringMedicineCount = ref(0)

async function fetchAlertsAndExpirations() {
    try {
        const data = await getMedicines()
        medicines.value = data

        totalMedicineStock.value = data.reduce(
            (total, medicine) => total + Math.max(Number(medicine.quantity) || 0, 0),
            0
        )

        const lowStockMedicines = data
            .filter(medicine => Number(medicine.quantity) <= 50)
            .sort((first, second) => Number(first.quantity) - Number(second.quantity))

        medicineShortageCount.value = lowStockMedicines.length
        stockAlerts.value = lowStockMedicines.slice(0, 5).map(medicine => ({
            id: medicine.id,
            name: medicine.medicine_name,
            stock: `${Number(medicine.quantity) || 0} ${medicine.unit || 'units'}`,
            daysLeft: 'N/A',
            status: Number(medicine.quantity) <= 0 ? 'Out of Stock' : 'Low Stock',
            action: 'Restock',
            actionColor: Number(medicine.quantity) <= 0 ? 'text-red-500' : 'text-amber-500'
        }))

        const today = getLocalDateString()
        const endOfWindow = new Date()
        endOfWindow.setDate(endOfWindow.getDate() + 30)
        const lastDate = getLocalDateString(endOfWindow)
        const dateFormatter = new Intl.DateTimeFormat('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric'
        })

        const expiringMedicines = data
            .filter(medicine =>
                medicine.expiration_date &&
                medicine.expiration_date >= today &&
                medicine.expiration_date <= lastDate
            )
            .sort((first, second) => first.expiration_date.localeCompare(second.expiration_date))

        expiringMedicineCount.value = expiringMedicines.length
        expiringItems.value = expiringMedicines
            .slice(0, 5)
            .map(medicine => {
                const daysLeft = Math.ceil(
                    (Date.parse(`${medicine.expiration_date}T00:00:00`) - Date.parse(`${today}T00:00:00`)) /
                    (1000 * 60 * 60 * 24)
                )

                return {
                    id: medicine.id,
                    name: medicine.medicine_name,
                    expiryText: `${dateFormatter.format(new Date(`${medicine.expiration_date}T00:00:00`))} (${daysLeft} days left)`,
                    units: `${Number(medicine.quantity) || 0} ${medicine.unit || 'units'}`,
                    badgeBg: daysLeft <= 7 ? 'bg-red-100 text-red-600' : 'bg-amber-100 text-amber-600'
                }
            })
    } catch (error) {
        console.error('Error fetching dashboard medicines:', error)
        medicines.value = []
        stockAlerts.value = []
        expiringItems.value = []
        totalMedicineStock.value = 0
        medicineShortageCount.value = 0
        expiringMedicineCount.value = 0
    }
}

onMounted(async () => {
    loading.value = true
    await Promise.all([
        fetchAlertsAndExpirations(),
        fetchDashboardData()
    ])
    loading.value = false
})
</script>

<template>
    <Dashboardskeliton v-if="loading" />
    <section v-else class="w-full">
        <div class="flex justify-between items-center ">
            <div>
                <h1 class="font-inter font-bold text-[#404040] text-lg">Dashboard</h1>
                <p class="text-sm text-[#808080]">Manage your medicine resources</p>
            </div>
            <div class="flex items-center gap-4">
                <Bell class="text-blue-700" />
                <div class="flex items-center justify-center gap-1 border border-gray-500/40 rounded-full p-1">
                    <img src="/src/assets/download (12).jpg" alt="" class="w-10 rounded-full">
                    <!-- <p class="text-sm">Mark Hello po</p> -->
                </div>
            </div>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mt-4">
            <div class="bg-blue-700 p-4 text-white rounded-xl">
                <div class="flex items-center gap-2">
                    <ShieldCheck size="35" />
                    <p class="text-sm font-medium">Inventory Status</p>
                </div>
                <h1 class="text-2xl font-black mt-2">
                    {{ medicines.length === 0 ? 'No Medicines' : medicineShortageCount > 0 ? 'Needs Restock' : 'Goods'
                    }}
                </h1>
                <div class="flex items-center justify-between gap-2 mt-6">
                    <p class="text-sm">View detailed report</p>
                    <router-link to="/inventory" class="p-2 bg-white text-blue-700 rounded-full">
                        <ChevronsRight />
                    </router-link>
                </div>
            </div>
            <div class="bg-white p-4 text-black rounded-xl">
                <div class="flex items-center gap-2">
                    <div class="p-2 bg-blue-100/70 rounded-lg">
                        <BookPlus size="22" class="text-blue-700" />
                    </div>
                    <p class="text-sm font-medium">Medicines Available</p>
                </div>
                <h1 class="text-2xl font-black text-gray-700 mt-2">{{ totalMedicineStock.toLocaleString() }}</h1>
                <div class="flex items-center justify-between gap-2 mt-6">
                    <p class="text-sm">View detailed report</p>
                    <router-link to="/categories" class="p-2 bg-blue-700 text-white rounded-full">
                        <ChevronsRight />
                    </router-link>
                </div>
            </div>
            <div class="bg-white p-4 text-black rounded-xl">
                <div class="flex items-center gap-2">
                    <div class="p-2 bg-blue-100/70 rounded-lg">
                        <AlignVerticalSpaceAround size="22" class="text-blue-700" />
                    </div>
                    <p class="text-sm font-medium">Dispense</p>
                </div>
                <h1 class="text-2xl font-black text-gray-700 mt-2">2,000</h1>
                <div class="flex items-center justify-between gap-2 mt-6">
                    <p class="text-sm">View detailed report</p>
                    <router-link to="/admin/reports" class="p-2 bg-blue-700 text-white rounded-full">
                        <ChevronsRight />
                    </router-link>
                </div>
            </div>
            <div class="bg-white p-4 text-black rounded-xl">
                <div class="flex items-center gap-2">
                    <div class="p-2 bg-blue-100/70 rounded-lg">
                        <TriangleAlert size="22" class="text-blue-700" />
                    </div>
                    <p class="text-sm font-medium">Medincine Shortage</p>
                </div>
                <h1 class="text-2xl font-black text-gray-700 mt-2">{{ medicineShortageCount }}</h1>
                <div class="flex items-center justify-between gap-2 mt-6">
                    <p class="text-sm">View detailed report</p>
                    <router-link to="/admin/reports" class="p-2 bg-blue-700 text-white rounded-full">
                        <ChevronsRight />
                    </router-link>
                </div>
            </div>
        </div>

        <!-- CHARTS BABY -->
        <div class="font-poppins mt-4">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                <!-- Total Distribution (Line Chart) -->

                <!-- Most Purpose of Dispensing (Bar Chart) -->
                <div class="bg-white p-6 rounded-2xl border border-gray-100 flex flex-col justify-between">
                    <div>
                        <h2 class="text-base font-bold font-inter text-gray-800 mb-4 tracking-wider">
                            Most purpose of dispensing
                        </h2>
                    </div>
                    <div class="h-64 relative flex items-center justify-center">
                        <Bar :data="barChartData" :options="barChartOptions" />
                    </div>
                </div>

                <div class="bg-white p-6 rounded-2xl border border-gray-100 flex flex-col justify-between">
                    <div class="flex items-center justify-between">
                        <h2 class="text-base font-inter font-bold text-gray-800 mb-4">Total Distribution</h2>
                        <select
                            class="text-xs font-inter bg-gray-50 border border-gray-200 text-gray-700 rounded-lg px-3 py-1.5 focus:outline-none focus:ring-2 focus:ring-blue-500 cursor-pointer">
                            <option value="daily">Daily</option>
                            <option value="weekly">Weekly</option>
                            <option value="monthly">Monthly</option>
                        </select>
                    </div>
                    <div class="h-64 relative flex items-center justify-center">
                        <Line :data="lineChartData" :options="lineChartOptions" />
                    </div>
                </div>
            </div>
        </div>

        <!-- TABLE -->
        <div class="mt-4 font-poppins">

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                <div class="bg-white p-6 rounded-2xl border border-gray-100 flex flex-col justify-between">
                    <div>
                        <div class="flex justify-between items-center mb-6">
                            <div class="flex items-center gap-2.5">
                                <div class="p-2 bg-blue-50 text-blue-600 rounded-lg">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                                    </svg>
                                </div>
                                <h2 class="font-bold font-inter text-gray-800 text-base">Stock Alert</h2>
                            </div>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full text-left text-sm">
                                <thead>
                                    <tr class="text-gray-800 font-medium border-b border-gray-100">
                                        <th class="pb-3 font-medium">Medicine name</th>
                                        <th class="pb-3 font-medium">Current Stock</th>
                                        <th class="pb-3 font-medium">Days Left</th>
                                        <th class="pb-3 font-medium">Status</th>
                                        <th class="pb-3 font-medium text-right">Action</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-50">
                                    <tr v-for="item in stockAlerts" :key="item.id" class="text-gray-700">
                                        <td class="py-3.5 font-medium text-gray-800">{{ item.name }}</td>
                                        <td class="py-3.5 text-gray-500">{{ item.stock }}</td>
                                        <td class="py-3.5 text-gray-500">{{ item.daysLeft }}</td>
                                        <td class="py-3.5 text-gray-500">{{ item.status }}</td>
                                        <td class="py-3.5 text-right" :class="item.actionColor">
                                            {{ item.action }}
                                        </td>
                                    </tr>
                                    <tr v-if="stockAlerts.length === 0">
                                        <td colspan="5" class="py-4 text-center text-gray-500">
                                            No low-stock medicines.
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="bg-white p-6 rounded-2xl border border-gray-100 flex flex-col justify-between">
                    <div>
                        <div class="flex items-center gap-2.5 mb-1">
                            <div class="p-2 bg-blue-50 text-blue-600 rounded-lg">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                </svg>
                            </div>
                            <div>
                                <h2 class="font-bold font-inter text-gray-800 text-base">Upcoming Expiration</h2>
                                <p class="text-xs text-gray-400">
                                    {{ expiringMedicineCount }} medicines expiring within 30 days
                                </p>
                            </div>
                        </div>
                        <div class="space-y-4 mb-6">
                            <div v-for="exp in expiringItems" :key="exp.id"
                                class="flex items-center justify-between py-2 border-b border-gray-50 last:border-none">
                                <div>
                                    <h4 class="font-semibold text-gray-800 text-sm">{{ exp.name }}</h4>
                                    <p class="text-xs text-amber-600 mt-0.5">{{ exp.expiryText }}</p>
                                </div>
                                <span :class="['px-3 py-1 rounded-lg text-xs font-semibold', exp.badgeBg]">
                                    {{ exp.units }}
                                </span>
                            </div>
                            <p v-if="expiringItems.length === 0" class="py-3 text-center text-sm text-gray-500">
                                No medicines expiring within 30 days.
                            </p>
                        </div>
                    </div>
                    <button
                        class="w-full bg-blue-700 hover:bg-blue-800 text-white font-semibold py-2.5 rounded-xl transition text-sm shadow-sm">
                        View Expiring Items
                    </button>
                </div>

            </div>

        </div>
    </section>
</template>