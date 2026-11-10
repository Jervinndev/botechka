<script setup>
import { computed, onMounted, ref } from 'vue'
import { Bell, Check, CheckCheck, RotateCcw } from '@lucide/vue'
import { getMyProfile } from '../../services/Authservices'
import { getMyMedicineRequests } from '../../services/MedicineRequests'

const requests = ref([])
const readIds = ref([])
const isLoading = ref(false)
const errorMessage = ref('')
const storageKey = ref('botechka_beneficiary_notifications_read')

const notifications = computed(() => requests.value.map((request) => ({
    id: `beneficiary-request-${request.request_id}`,
    title: request.status === 'pending' ? 'Request pending' : `Request ${request.status}`,
    description: `${request.medicine_name} · ${request.quantity} ${request.medicine_unit || 'unit(s)'}`,
    date: request.reviewed_at || request.created_at,
    status: request.status,
    reason: request.rejection_reason
})))
const unreadCount = computed(() => notifications.value.filter((item) => !readIds.value.includes(item.id)).length)

function isRead(id) {
    return readIds.value.includes(id)
}

function markRead(id) {
    if (isRead(id)) return
    readIds.value = [...readIds.value, id]
    localStorage.setItem(storageKey.value, JSON.stringify(readIds.value))
}

function markAllRead() {
    readIds.value = [...new Set([...readIds.value, ...notifications.value.map((item) => item.id)])]
    localStorage.setItem(storageKey.value, JSON.stringify(readIds.value))
}

function formatDate(value) {
    if (!value) return '—'
    const date = new Date(value)
    return Number.isNaN(date.getTime()) ? '—' : date.toLocaleString()
}

async function loadNotifications() {
    isLoading.value = true
    errorMessage.value = ''
    try {
        requests.value = await getMyMedicineRequests()
    } catch (error) {
        console.error('Unable to load beneficiary notifications:', error)
        errorMessage.value = error.message || 'Unable to load your notifications.'
    } finally {
        isLoading.value = false
    }
}

onMounted(async () => {
    const result = await getMyProfile()
    if (!result.success) {
        console.error('Unable to load beneficiary notification profile:', result.error)
        errorMessage.value = 'Unable to load your notification settings.'
        return
    }
    storageKey.value = `botechka_beneficiary_notifications_read_${result.data.id}`
    try {
        const saved = JSON.parse(localStorage.getItem(storageKey.value) || '[]')
        readIds.value = Array.isArray(saved) ? saved : []
    } catch (error) {
        console.error('Unable to load notification read status:', error)
        errorMessage.value = 'Unable to load notification read status.'
    }
    await loadNotifications()
})
</script>

<template>
    <section class="font-inter text-slate-800">
        <header class="mb-4 flex flex-wrap items-start justify-between gap-3 border-b border-gray-100 pb-4">
            <div>
                <h1 class="flex items-center gap-2 text-lg font-bold text-[#404040]"><Bell :size="19" /> My Notifications</h1>
                <p class="mt-1 text-sm text-[#808080]">Updates about your medicine requests.</p>
            </div>
            <div class="flex gap-2">
                <button type="button" @click="markAllRead"
                    class="flex items-center gap-2 rounded-lg bg-blue-700 px-3 py-2 text-sm font-medium text-white hover:bg-blue-800">
                    <CheckCheck :size="16" /> Mark all read
                </button>
                <button type="button" @click="loadNotifications" :disabled="isLoading"
                    class="flex items-center gap-2 rounded-lg border border-gray-200 bg-white px-3 py-2 text-sm text-gray-700 hover:bg-gray-50 disabled:opacity-50">
                    <RotateCcw :size="16" :class="{ 'animate-spin': isLoading }" /> Refresh
                </button>
            </div>
        </header>

        <p class="mb-3 text-xs text-gray-500">{{ unreadCount }} unread</p>
        <p v-if="errorMessage" role="alert" class="rounded-lg bg-red-50 p-3 text-sm text-red-700">{{ errorMessage }}</p>
        <p v-else-if="isLoading && !notifications.length" class="rounded-xl bg-white p-10 text-center text-sm text-gray-500">
            Loading your notifications...
        </p>
        <p v-else-if="!notifications.length" class="rounded-xl bg-white p-10 text-center text-sm text-gray-500">
            No request updates yet.
        </p>
        <ul v-else class="overflow-hidden rounded-xl border border-gray-200 bg-white">
            <li v-for="item in notifications" :key="item.id"
                :class="isRead(item.id) ? 'bg-white' : 'bg-blue-50/60'"
                class="flex items-start gap-4 border-b border-gray-100 p-4 last:border-b-0 sm:p-5">
                <span class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-blue-100 text-blue-700">
                    <Bell :size="18" />
                </span>
                <div class="min-w-0 flex-1">
                    <div class="flex flex-wrap items-center gap-2">
                        <h2 class="text-sm font-semibold capitalize text-gray-800">{{ item.title }}</h2>
                        <span class="rounded-full bg-gray-100 px-2 py-0.5 text-[11px] capitalize text-gray-600">{{ item.status }}</span>
                    </div>
                    <p class="mt-1 text-sm text-gray-600">{{ item.description }}</p>
                    <p v-if="item.reason" class="mt-1 text-xs text-red-600">Reason: {{ item.reason }}</p>
                    <p class="mt-2 text-xs text-gray-400">{{ formatDate(item.date) }}</p>
                </div>
                <button v-if="!isRead(item.id)" type="button" @click="markRead(item.id)"
                    :aria-label="`Mark ${item.title} as read`"
                    class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg text-gray-400 hover:bg-gray-100 hover:text-blue-700">
                    <Check :size="17" />
                </button>
            </li>
        </ul>
    </section>
</template>
