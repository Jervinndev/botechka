<script setup>
import { computed, onMounted, ref } from 'vue'
import {
  Search, Clock, CircleCheck, CircleX, ClipboardList, Eye, Check, X,
  Calendar, Package, Pill,
} from '@lucide/vue'
import {
  getAllMedicineRequests,
  getPrescriptionUrl,
  updateMedicineRequestStatus
} from '../../services/MedicineRequests'
import AdminTopActions from '../../components/admin/AdminTopActions.vue'

const requests = ref([])
const loading = ref(true)
const errorMessage = ref('')
const searchQuery = ref('')
const activeStatus = ref('all')
const updatingRequestId = ref(null)
const statusMessage = ref('')

const pendingCount = computed(() => requests.value.filter(request => request.status === 'pending').length)
const approvedCount = computed(() => requests.value.filter(request => request.status === 'approved').length)
const rejectedCount = computed(() => requests.value.filter(request => request.status === 'rejected').length)
const filteredRequests = computed(() => {
  const query = searchQuery.value.trim().toLowerCase()

  return requests.value.filter(request => {
    const matchesStatus = activeStatus.value === 'all' || request.status === activeStatus.value
    const matchesQuery = !query || [
      request.beneficiary_name,
      request.beneficiary_type,
      request.medicine_name,
      request.purpose,
      request.status,
      request.request_id
    ].some(value => String(value ?? '').toLowerCase().includes(query))

    return matchesStatus && matchesQuery
  })
})

async function loadRequests() {
  loading.value = true
  errorMessage.value = ''

  try {
    requests.value = await getAllMedicineRequests()
  } catch (error) {
    console.error('Failed to load beneficiary medicine requests:', error)
    errorMessage.value = error.message || 'Unable to load beneficiary requests.'
  } finally {
    loading.value = false
  }
}

async function setRequestStatus(request, status) {
  updatingRequestId.value = request.request_id
  errorMessage.value = ''
  statusMessage.value = ''

  try {
    await updateMedicineRequestStatus(request.request_id, status)
    statusMessage.value = `Request REQ-${String(request.request_id).padStart(4, '0')} was ${status}.`
    await loadRequests()
  } catch (error) {
    console.error(`Failed to ${status} beneficiary request:`, error)
    errorMessage.value = error.message || `Unable to ${status} this request.`
  } finally {
    updatingRequestId.value = null
  }
}

async function openPrescription(request) {
  errorMessage.value = ''

  try {
    const url = await getPrescriptionUrl(request.prescription_path)
    window.open(url, '_blank', 'noopener,noreferrer')
  } catch (error) {
    console.error('Failed to open beneficiary prescription:', error)
    errorMessage.value = error.message || 'Unable to open the prescription.'
  }
}

function requestCode(requestId) {
  return `REQ-${String(requestId).padStart(4, '0')}`
}

function formatDate(date) {
  return new Intl.DateTimeFormat('en', { dateStyle: 'medium' }).format(new Date(date))
}

function statusClass(status) {
  return {
    pending: 'bg-amber-50 text-amber-600',
    approved: 'bg-green-50 text-green-700',
    rejected: 'bg-red-50 text-red-500',
    cancelled: 'bg-gray-100 text-gray-600'
  }[status] || 'bg-gray-100 text-gray-600'
}

onMounted(loadRequests)
</script>

<template>
  <div class="font-inter text-slate-900">
    <!-- Page header -->
    <header class="mb-5 flex items-center justify-between">
      <div>
        <h1 class="font-inter text-lg font-bold text-[#404040]">Beneficiary Request</h1>
        <p class="text-sm text-[#808080]">Review and manage medicine requests from beneficiaries</p>
      </div>
      <AdminTopActions />
    </header>

    <!-- Summary cards (repeat per status) -->
    <section class="mb-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
      <div class="flex items-center gap-4 rounded-xl border border-gray-100 bg-white p-5">
        <div class="flex flex-col item-start justify-center gap-2">
          <span class="flex G h-12 w-12 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
            <ClipboardList :size="22" />
          </span>
          <p class="text-sm text-slate-500">Total Requests</p>
          <p class="text-2xl font-semibold">{{ requests.length }}</p>
        </div>
      </div>
      <div class="flex items-center gap-4 rounded-xl border border-gray-100 bg-white p-5">
        <div class="flex flex-col item-start justify-center gap-2">
          <span class="flex h-12 w-12 items-center justify-center rounded-xl bg-amber-50 text-amber-500">
            <Clock :size="22" />
          </span>
          <p class="text-sm text-slate-500">Pending</p>
          <p class="text-2xl font-semibold">{{ pendingCount }}</p>
        </div>
      </div>
      <div class="flex items-center gap-4 rounded-xl border border-gray-100 bg-white p-5">
        <div class="flex flex-col item-start justify-center gap-2">
          <span class="flex h-12 w-12 items-center justify-center rounded-xl bg-green-50 text-green-600">
            <CircleCheck :size="22" />
          </span>
          <p class="text-sm text-slate-500">Approved</p>
          <p class="text-2xl font-semibold">{{ approvedCount }}</p>
        </div>
      </div>
      <div class="flex items-center gap-4 rounded-xl border border-gray-100 bg-white p-5">
        <div class="flex flex-col item-start justify-center gap-2">
          <span class="flex h-12 w-12 items-center justify-center rounded-xl bg-red-50 text-red-500">
            <CircleX :size="22" />
          </span>
          <p class="text-sm text-slate-500">Rejected</p>
          <p class="text-2xl font-semibold">{{ rejectedCount }}</p>
        </div>
      </div>
    </section>

    <!-- Tabs + filters -->
    <section class="rounded-xl border border-gray-100 bg-white p-4">
      <!-- Status tabs (active tab = blue) -->
      <div class="mb-4 flex flex-wrap gap-2">
        <button @click="activeStatus = 'all'"
          :class="activeStatus === 'all' ? 'bg-blue-700 text-white hover:bg-blue-800' : 'border border-gray-200 text-gray-600 hover:bg-gray-50'"
          class="rounded-md px-4 py-2 text-sm font-medium transition">All</button>
        <button @click="activeStatus = 'pending'"
          :class="activeStatus === 'pending' ? 'bg-blue-700 text-white hover:bg-blue-800' : 'border border-gray-200 text-gray-600 hover:bg-gray-50'"
          class="rounded-md px-4 py-2 text-sm font-medium transition">Pending</button>
        <button @click="activeStatus = 'approved'"
          :class="activeStatus === 'approved' ? 'bg-blue-700 text-white hover:bg-blue-800' : 'border border-gray-200 text-gray-600 hover:bg-gray-50'"
          class="rounded-md px-4 py-2 text-sm font-medium transition">Approved</button>
        <button @click="activeStatus = 'rejected'"
          :class="activeStatus === 'rejected' ? 'bg-blue-700 text-white hover:bg-blue-800' : 'border border-gray-200 text-gray-600 hover:bg-gray-50'"
          class="rounded-md px-4 py-2 text-sm font-medium transition">Rejected</button>
      </div>

      <div class="relative">
        <input v-model="searchQuery" type="text" placeholder="Search for Beneficiary Request.."
          class="w-full rounded-md bg-gray-100 px-4 py-2.5 pr-12 text-sm outline-none placeholder:text-gray-400 focus:ring-2 focus:ring-blue-200" />
        <Search :size="18" class="absolute right-4 top-1/2 -translate-y-1/2" />
      </div>
    </section>

    <!-- Requests table -->
    <p v-if="errorMessage" class="mt-4 rounded-lg bg-red-50 p-3 text-sm text-red-700" role="alert">
      {{ errorMessage }}
    </p>
    <p v-if="statusMessage" class="mt-4 rounded-lg bg-green-50 p-3 text-sm text-green-700" role="status">
      {{ statusMessage }}
    </p>
    <section class="mt-4 overflow-x-auto rounded-xl border border-gray-100 bg-white">
      <table class="w-full min-w-[900px] border-collapse text-left text-sm">
        <thead class="bg-blue-700 text-white">
          <tr class="text-xs font-semibold uppercase tracking-wide">
            <th class="px-6 py-4">Request #</th>
            <th class="px-6 py-4">Beneficiary</th>
            <th class="px-6 py-4">Medicine Requested</th>
            <th class="px-6 py-4">Quantity</th>
            <th class="px-6 py-4">Date Requested</th>
            <th class="px-6 py-4">Status</th>
            <th class="px-6 py-4 text-right">Action</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100">
          <tr v-for="request in filteredRequests" :key="request.request_id"
            class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
            <td class="px-6 py-4 font-semibold text-slate-600">{{ requestCode(request.request_id) }}</td>
            <td class="px-6 py-4">
              <p class="font-semibold text-slate-600">{{ request.beneficiary_name }}</p>
              <p class="text-xs text-slate-400">{{ request.beneficiary_type }}</p>
            </td>
            <td class="px-6 py-4">
              <div class="flex items-center gap-3">
                <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-pink-50 text-pink-500">
                  <Pill :size="18" />
                </span>
                <span class="font-semibold leading-tight text-slate-600">
                  {{ request.medicine_name }} {{ request.medicine_dosage || '' }}
                </span>
              </div>
              <p v-if="request.purpose" class="mt-1 text-xs text-slate-400">{{ request.purpose }}</p>
            </td>
            <td class="px-6 py-4 text-slate-500">{{ request.quantity }} {{ request.medicine_unit }}</td>
            <td class="px-6 py-4 text-slate-500">{{ formatDate(request.created_at) }}</td>
            <td class="px-6 py-4">
              <span :class="statusClass(request.status)"
                class="rounded-full px-3 py-1 text-xs font-semibold capitalize">{{ request.status }}</span>
            </td>
            <td class="px-6 py-4">
              <div class="flex justify-end gap-2">
                <button @click="openPrescription(request)"
                  class="flex h-9 w-9 items-center justify-center rounded-md border border-gray-300 text-gray-500 transition hover:bg-blue-50 hover:text-blue-700"
                  aria-label="View prescription">
                  <Eye :size="18" />
                </button>
                <template v-if="request.status === 'pending'">
                  <button @click="setRequestStatus(request, 'approved')"
                    :disabled="updatingRequestId === request.request_id"
                    class="flex h-9 w-9 items-center justify-center rounded-md border border-gray-300 text-gray-500 transition hover:bg-green-50 hover:text-green-700 disabled:opacity-50"
                    aria-label="Approve">
                    <Check :size="18" />
                  </button>
                  <button @click="setRequestStatus(request, 'rejected')"
                    :disabled="updatingRequestId === request.request_id"
                    class="flex h-9 w-9 items-center justify-center rounded-md border border-gray-300 text-gray-500 transition hover:bg-red-50 hover:text-red-500 disabled:opacity-50"
                    aria-label="Reject">
                    <X :size="18" />
                  </button>
                </template>
              </div>
            </td>
          </tr>
          <tr v-if="loading">
            <td colspan="7" class="px-6 py-10 text-center text-sm text-slate-500">Loading beneficiary requests...</td>
          </tr>
          <tr v-else-if="filteredRequests.length === 0">
            <td colspan="7" class="px-6 py-10 text-center text-sm text-slate-500">No beneficiary requests found.</td>
          </tr>
        </tbody>
      </table>

      <div
        class="flex flex-col items-center justify-between gap-3 border-t border-gray-100 px-4 py-3 text-sm text-gray-500 sm:flex-row">
        <p>Showing {{ filteredRequests.length }} of {{ requests.length }} requests</p>
      </div>
    </section>
  </div>
</template>