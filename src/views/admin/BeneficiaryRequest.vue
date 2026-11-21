<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import {
  Search, Clock, CircleCheck, CircleX, ClipboardList, Eye, Check, X,
  Calendar, Package, Pill,
} from '@lucide/vue'
import {
  getAllMedicineRequests,
  getPrescriptionUrl,
  updateMedicineRequestStatus,
  markMedicineRequestReady
} from '../../services/MedicineRequests'
import AdminTopActions from '../../components/admin/AdminTopActions.vue'
import TablePagination from '../../components/TablePagination.vue'
import { usePagination } from '../../composable/usePagination.js'

const requests = ref([])
const loading = ref(true)
const errorMessage = ref('')
const searchQuery = ref('')
const activeStatus = ref('all')
const updatingRequestId = ref(null)
const statusMessage = ref('')
const selectedRequest = ref(null)
const prescriptionUrl = ref('')
const isRequestViewOpen = ref(false)
const isPrescriptionPreviewOpen = ref(false)
const isLoadingPrescription = ref(false)
const prescriptionError = ref('')
const router = useRouter()
const reviewTarget = ref(null)
const reviewStatus = ref('')
const rejectionReasonCode = ref('')
const rejectionReasonOther = ref('')
const pickupInstructions = ref('')
const rejectionReasons = [
  'Incomplete or invalid prescription',
  'Request does not meet eligibility criteria',
  'Requested quantity exceeds allowable limit',
  'Medicine unavailable',
  'Duplicate request',
  'Others'
]

const pendingCount = computed(() => requests.value.filter(request => request.status === 'pending').length)
const approvedCount = computed(() => requests.value.filter(request =>
  ['approved', 'ready_to_dispense'].includes(request.status)).length)
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
const { currentPage: requestPage, paginatedItems: paginatedRequests } = usePagination(filteredRequests)

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
  reviewTarget.value = request
  reviewStatus.value = status
  rejectionReasonCode.value = ''
  rejectionReasonOther.value = ''
  pickupInstructions.value = request.pickup_instructions || ''
}

async function saveRequestReview() {
  const request = reviewTarget.value
  if (!request) return
  if (reviewStatus.value === 'rejected' && !rejectionReasonCode.value) {
    errorMessage.value = 'Select a rejection reason.'
    return
  }
  if (reviewStatus.value === 'rejected' && rejectionReasonCode.value === 'Others'
    && !rejectionReasonOther.value.trim()) {
    errorMessage.value = 'Add a short explanation for Other.'
    return
  }

  updatingRequestId.value = request.request_id
  errorMessage.value = ''
  statusMessage.value = ''

  try {
    await updateMedicineRequestStatus(request.request_id, {
      status: reviewStatus.value,
      rejectionReasonCode: rejectionReasonCode.value || null,
      rejectionReasonOther: rejectionReasonOther.value.trim() || null,
      pickupInstructions: pickupInstructions.value.trim() || null
    })
    statusMessage.value = `Request REQ-${String(request.request_id).padStart(4, '0')} was ${reviewStatus.value}.`
    reviewTarget.value = null
    await loadRequests()
  } catch (error) {
    console.error(`Failed to ${status} beneficiary request:`, error)
    errorMessage.value = error.message || `Unable to ${status} this request.`
  } finally {
    updatingRequestId.value = null
  }
}

async function sendToDispensing(request) {
  updatingRequestId.value = request.request_id
  errorMessage.value = ''
  try {
    await markMedicineRequestReady(request.request_id)
    await router.push({ name: 'distribution', query: { requestId: String(request.request_id) } })
  } catch (error) {
    console.error('Unable to prepare approved request for dispensing:', error)
    errorMessage.value = error.message || 'Unable to send this request to dispensing.'
  } finally {
    updatingRequestId.value = null
  }
}

function requestItems(request) {
  return request.items?.length
    ? request.items
    : [{ medicine_name: request.medicine_name, medicine_dosage: request.medicine_dosage,
      medicine_unit: request.medicine_unit, quantity: request.quantity }]
}

function requestQuantity(request) {
  return requestItems(request).reduce((total, item) => total + Number(item.quantity || 0), 0)
}

async function openRequestDetails(request) {
  selectedRequest.value = request
  prescriptionUrl.value = ''
  prescriptionError.value = ''
  isRequestViewOpen.value = true
  if (!request.prescription_path) return

  isLoadingPrescription.value = true
  try {
    prescriptionUrl.value = await getPrescriptionUrl(request.prescription_path)
  } catch (error) {
    console.error('Failed to load beneficiary prescription:', error)
    prescriptionError.value = error.message || 'Unable to load the prescription.'
  } finally {
    isLoadingPrescription.value = false
  }
}

function closeRequestDetails() {
  isRequestViewOpen.value = false
  isPrescriptionPreviewOpen.value = false
  selectedRequest.value = null
  prescriptionUrl.value = ''
}

function isImagePrescription(path) {
  return /\.(jpe?g|png|webp)$/i.test(path || '')
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
    cancelled: 'bg-gray-100 text-gray-600',
    ready_to_dispense: 'bg-blue-50 text-blue-700',
    completed: 'bg-emerald-50 text-emerald-700'
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
      <div class="2xl:flex flex-row gap-2">
        <div class="mb-4 2xl:flex flex-row gap-2 2xl:mb-0 2xl:items-center">
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
        <div class="relative w-full">
          <input v-model="searchQuery" type="text" placeholder="Search for Beneficiary Request.."
            class="w-full rounded-md bg-gray-100 px-4 py-2.5 pr-12 text-sm outline-none placeholder:text-gray-400 focus:ring-2 focus:ring-blue-200" />
        </div>
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
          <tr v-for="request in paginatedRequests" :key="request.request_id"
            class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
            <td class="px-6 py-4 font-semibold text-slate-600">{{ requestCode(request.request_id) }}</td>
            <td class="px-6 py-4">
              <p class="font-semibold text-slate-600">{{ request.beneficiary_name }}</p>
              <p class="text-xs text-slate-400">{{ request.beneficiary_type }}</p>
            </td>
            <td class="px-6 py-4">
              <div v-for="item in requestItems(request)" :key="`${request.request_id}-${item.medicine_id || item.medicine_name}`"
                class="mb-1 flex items-center gap-3 last:mb-0">
                <span class="font-semibold leading-tight text-slate-600">
                  {{ item.medicine_name }} {{ item.medicine_dosage || '' }}
                </span>
                <span class="text-xs text-slate-500">× {{ item.quantity }} {{ item.medicine_unit || '' }}</span>
              </div>
              <p v-if="request.purpose" class="mt-1 text-xs text-slate-400">{{ request.purpose }}</p>
            </td>
            <td class="px-6 py-4 text-slate-500">{{ requestQuantity(request) }} units</td>
            <td class="px-6 py-4 text-slate-500">{{ formatDate(request.created_at) }}</td>
            <td class="px-6 py-4">
              <span :class="statusClass(request.status)"
                class="rounded-full px-3 py-1 text-xs font-semibold capitalize">{{ request.status }}</span>
            </td>
            <td class="px-6 py-4">
              <div class="flex justify-end gap-2">
                <button @click="openRequestDetails(request)"
                  class="flex h-9 w-9 items-center justify-center rounded-md border border-gray-300 text-gray-500 transition hover:bg-blue-50 hover:text-blue-700"
                  aria-label="View request details">
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
                <button v-else-if="request.status === 'approved' || request.status === 'ready_to_dispense'"
                  type="button" @click="sendToDispensing(request)"
                  :disabled="updatingRequestId === request.request_id"
                  class="rounded-md bg-blue-700 px-3 py-2 text-xs font-semibold text-white hover:bg-blue-800 disabled:opacity-50">
                  {{ request.status === 'approved' ? 'Ready to Dispense' : 'Continue Dispensing' }}
                </button>
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

      <TablePagination v-model="requestPage" :total-items="filteredRequests.length" item-label="requests"
        aria-label="Beneficiary request pagination" class="border-t border-gray-100 px-4 py-3" />
    </section>
  </div>

  <div v-if="isRequestViewOpen && selectedRequest"
    class="fixed inset-0 z-[70] flex items-center justify-center bg-black/40 p-4"
    @click.self="closeRequestDetails">
    <section role="dialog" aria-modal="true" aria-labelledby="request-details-title"
      class="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-xl bg-white p-6 shadow-xl">
      <div class="flex items-start justify-between gap-4">
        <div>
          <h2 id="request-details-title" class="text-lg font-bold text-slate-900">Request Details</h2>
          <p class="mt-1 text-sm text-slate-500">{{ requestCode(selectedRequest.request_id) }}</p>
        </div>
        <button type="button" aria-label="Close request details" @click="closeRequestDetails"
          class="rounded-lg p-2 text-slate-500 hover:bg-slate-100">
          <X :size="18" />
        </button>
      </div>

      <dl class="mt-5 grid gap-4 border-b border-gray-100 pb-5 sm:grid-cols-2">
        <div>
          <dt class="text-xs text-slate-400">Beneficiary</dt>
          <dd class="mt-1 text-sm font-medium text-slate-700">{{ selectedRequest.beneficiary_name }}</dd>
        </div>
        <div>
          <dt class="text-xs text-slate-400">Status</dt>
          <dd class="mt-1 text-sm font-medium capitalize text-slate-700">{{ selectedRequest.status }}</dd>
        </div>
        <div>
          <dt class="text-xs text-slate-400">Beneficiary type</dt>
          <dd class="mt-1 text-sm font-medium text-slate-700">{{ selectedRequest.beneficiary_type }}</dd>
        </div>
        <div>
          <dt class="text-xs text-slate-400">Medicine</dt>
          <dd class="mt-1 text-sm font-medium text-slate-700">
            <span v-for="item in requestItems(selectedRequest)" :key="item.medicine_id || item.medicine_name" class="block">
              {{ item.medicine_name }} {{ item.medicine_dosage || '' }} × {{ item.quantity }} {{ item.medicine_unit || '' }}
            </span>
          </dd>
        </div>
        <div>
          <dt class="text-xs text-slate-400">Quantity</dt>
          <dd class="mt-1 text-sm font-medium text-slate-700">
            {{ requestQuantity(selectedRequest) }} units
          </dd>
        </div>
        <div>
          <dt class="text-xs text-slate-400">Purpose</dt>
          <dd class="mt-1 text-sm font-medium text-slate-700">{{ selectedRequest.purpose || '—' }}</dd>
        </div>
        <div>
          <dt class="text-xs text-slate-400">Requested</dt>
          <dd class="mt-1 text-sm font-medium text-slate-700">{{ formatDate(selectedRequest.created_at) }}</dd>
        </div>
        <div v-if="selectedRequest.rejection_reason" class="sm:col-span-2">
          <dt class="text-xs text-slate-400">Rejection reason</dt>
          <dd class="mt-1 text-sm font-medium text-red-700">{{ selectedRequest.rejection_reason }}</dd>
        </div>
        <div v-if="selectedRequest.pickup_instructions" class="sm:col-span-2">
          <dt class="text-xs text-slate-400">Pickup instructions</dt>
          <dd class="mt-1 text-sm font-medium text-slate-700">{{ selectedRequest.pickup_instructions }}</dd>
        </div>
      </dl>

      <div class="mt-5">
        <h3 class="mb-2 text-sm font-semibold text-slate-800">Prescription</h3>
        <p v-if="isLoadingPrescription" class="rounded-lg bg-slate-50 p-6 text-center text-sm text-slate-500">
          Loading prescription...
        </p>
        <p v-else-if="prescriptionError" role="alert" class="rounded-lg bg-red-50 p-3 text-sm text-red-700">
          {{ prescriptionError }}
        </p>
        <button v-else-if="prescriptionUrl && isImagePrescription(selectedRequest.prescription_path)" type="button"
          @click="isPrescriptionPreviewOpen = true"
          class="block max-h-80 w-full overflow-hidden rounded-lg border border-slate-200 bg-slate-50 p-2">
          <img :src="prescriptionUrl" alt="Beneficiary prescription"
            class="mx-auto max-h-72 max-w-full object-contain">
          <span class="mt-2 block text-xs text-slate-500">Click image to enlarge</span>
        </button>
        <iframe v-else-if="prescriptionUrl" :src="prescriptionUrl" title="Beneficiary prescription PDF"
          class="h-[55vh] w-full rounded-lg border border-slate-200"></iframe>
      </div>
    </section>
  </div>

  <div v-if="isPrescriptionPreviewOpen && prescriptionUrl"
    class="fixed inset-0 z-[80] flex items-center justify-center bg-black/90 p-4"
    @click.self="isPrescriptionPreviewOpen = false">
    <button type="button" aria-label="Close enlarged prescription" @click="isPrescriptionPreviewOpen = false"
      class="absolute right-4 top-4 rounded-full bg-white/10 p-2 text-white hover:bg-white/20">
      <X :size="22" />
    </button>
    <img :src="prescriptionUrl" alt="Enlarged beneficiary prescription"
      class="max-h-full max-w-full object-contain">
  </div>

  <div v-if="reviewTarget" class="fixed inset-0 z-[75] flex items-center justify-center bg-black/40 p-4"
    @click.self="reviewTarget = null">
    <form class="w-full max-w-lg rounded-xl bg-white p-6 shadow-xl" @submit.prevent="saveRequestReview">
      <h2 class="text-lg font-bold text-slate-900">
        {{ reviewStatus === 'approved' ? 'Approve request' : 'Reject request' }}
      </h2>
      <p class="mt-1 text-sm text-slate-500">{{ requestCode(reviewTarget.request_id) }} · {{ reviewTarget.beneficiary_name }}</p>
      <label v-if="reviewStatus === 'rejected'" class="mt-5 block text-sm font-medium text-slate-700">
        Rejection reason
        <select v-model="rejectionReasonCode" required class="mt-1 w-full rounded-lg border border-slate-200 p-2.5">
          <option value="" disabled>Select reason</option>
          <option v-for="reason in rejectionReasons" :key="reason" :value="reason">{{ reason }}</option>
        </select>
      </label>
      <label v-if="reviewStatus === 'rejected' && rejectionReasonCode === 'Others'"
        class="mt-4 block text-sm font-medium text-slate-700">
        Other reason
        <textarea v-model="rejectionReasonOther" required rows="3"
          class="mt-1 w-full rounded-lg border border-slate-200 p-2.5"></textarea>
      </label>
      <label v-if="reviewStatus === 'approved'" class="mt-5 block text-sm font-medium text-slate-700">
        Pickup instructions for beneficiary
        <textarea v-model="pickupInstructions" rows="3" placeholder="Where and when to claim the medicine"
          class="mt-1 w-full rounded-lg border border-slate-200 p-2.5"></textarea>
      </label>
      <p v-if="errorMessage" role="alert" class="mt-3 text-sm text-red-600">{{ errorMessage }}</p>
      <div class="mt-5 flex justify-end gap-2">
        <button type="button" @click="reviewTarget = null"
          class="rounded-lg border border-slate-200 px-4 py-2 text-sm text-slate-600">Cancel</button>
        <button type="submit" :disabled="updatingRequestId === reviewTarget.request_id"
          class="rounded-lg bg-blue-700 px-4 py-2 text-sm font-semibold text-white disabled:opacity-50">
          {{ updatingRequestId === reviewTarget.request_id ? 'Saving...' : 'Save review' }}
        </button>
      </div>
    </form>
  </div>
</template>