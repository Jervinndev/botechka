<script setup>
import { computed, onMounted, ref } from 'vue'
import {
    Bell, CheckCheck, Search, SlidersHorizontal, X, PackagePlus,
    ClipboardList, CalendarClock, ShieldCheck, EllipsisVertical, Check
} from '@lucide/vue'
import { supabase } from '../../supabase/supabase'

const notifications = ref([])
const searchQuery = ref('')
const selectedFilter = ref('All')
const isPreferencesOpen = ref(false)
const isLoading = ref(false)
const errorMessage = ref('')
const notificationPreferences = ref({
    inventory: true,
    requests: true,
    distributions: true
})
const alertThresholds = ref({ lowStock: 10, expiryDays: 30 })
const storageKey = 'botechka_notifications_read'
const readIds = ref([])

const unreadCount = computed(() => notifications.value.filter((item) => !readIds.value.includes(item.id)).length)
const visibleNotifications = computed(() => {
    const query = searchQuery.value.trim().toLowerCase()
    return notifications.value.filter((item) => {
        const matchesFilter = selectedFilter.value === 'All' || item.category === selectedFilter.value
        const matchesSearch = !query || `${item.title} ${item.description}`.toLowerCase().includes(query)
        return matchesFilter && matchesSearch
    })
})

function isRead(id) {
    return readIds.value.includes(id)
}

function markRead(id) {
    if (!isRead(id)) {
        readIds.value = [...readIds.value, id]
        localStorage.setItem(storageKey, JSON.stringify(readIds.value))
    }
}

function markAllRead() {
    readIds.value = [...new Set([...readIds.value, ...notifications.value.map((item) => item.id)])]
    localStorage.setItem(storageKey, JSON.stringify(readIds.value))
}

function makeNotification(category, id, title, description, date, href, icon) {
    return {
        id: `${category}-${id}`,
        category,
        title,
        description,
        date,
        href,
        icon
    }
}

async function loadNotifications() {
    isLoading.value = true
    errorMessage.value = ''
    try {
        const [medicinesResult, requestsResult, distributionsResult] = await Promise.all([
            notificationPreferences.value.inventory
                ? supabase.from('medicines').select('id, medicine_name, quantity, expiration_date, created_at')
                    .is('archived_at', null)
                : Promise.resolve({ data: [], error: null }),
            notificationPreferences.value.requests
                ? supabase.from('medicine_requests').select('request_id, medicine_name, status, created_at')
                    .in('status', ['pending', 'approved', 'rejected']).order('created_at', { ascending: false }).limit(50)
                : Promise.resolve({ data: [], error: null }),
            notificationPreferences.value.distributions
                ? supabase.from('distribution_transactions').select('distribution_transaction_id, distribution_date, purpose')
                    .order('distribution_date', { ascending: false }).limit(25)
                : Promise.resolve({ data: [], error: null })
        ])
        const failed = [medicinesResult, requestsResult, distributionsResult].find((result) => result.error)
        if (failed?.error) throw failed.error

        const alerts = []
        const now = new Date()
        const expiryLimit = new Date(now)
        expiryLimit.setDate(now.getDate() + alertThresholds.value.expiryDays)

        for (const medicine of medicinesResult.data || []) {
            const quantity = Number(medicine.quantity) || 0
            const expiry = medicine.expiration_date ? new Date(`${medicine.expiration_date}T00:00:00`) : null
            if (quantity <= alertThresholds.value.lowStock) {
                alerts.push(makeNotification(
                    'Inventory',
                    `low-${medicine.id}`,
                    quantity === 0 ? 'Medicine out of stock' : 'Low medicine stock',
                    `${medicine.medicine_name}: ${quantity} unit(s) currently available.`,
                    medicine.created_at,
                    '/inventory',
                    'inventory'
                ))
            }
            if (expiry && !Number.isNaN(expiry.getTime()) && expiry <= expiryLimit) {
                const expired = expiry < now
                alerts.push(makeNotification(
                    'Inventory',
                    `expiry-${medicine.id}`,
                    expired ? 'Medicine expired' : 'Medicine expiring soon',
                    `${medicine.medicine_name} ${expired ? 'expired' : 'expires'} on ${expiry.toLocaleDateString()}.`,
                    medicine.created_at,
                    '/inventory',
                    'expiry'
                ))
            }
        }

        for (const request of requestsResult.data || []) {
            alerts.push(makeNotification(
                'Requests',
                request.request_id,
                request.status === 'pending' ? 'Medicine request needs review' : 'Medicine request updated',
                `${request.medicine_name} request is ${request.status}.`,
                request.created_at,
                '/beneficiaryrequest',
                'request'
            ))
        }

        for (const transaction of distributionsResult.data || []) {
            alerts.push(makeNotification(
                'Distributions',
                transaction.distribution_transaction_id,
                'Distribution recorded',
                `A medicine distribution was recorded for ${transaction.purpose}.`,
                transaction.distribution_date,
                '/distribution',
                'distribution'
            ))
        }

        notifications.value = alerts.sort((a, b) => new Date(b.date || 0) - new Date(a.date || 0))
    } catch (error) {
        console.error('Unable to load notifications:', error)
        errorMessage.value = error.message || 'Unable to load notifications.'
    } finally {
        isLoading.value = false
    }
}

function notificationIcon(item) {
    if (item.icon === 'request') return ClipboardList
    if (item.icon === 'distribution') return ShieldCheck
    if (item.icon === 'expiry') return CalendarClock
    return PackagePlus
}

function formatRelativeDate(date) {
    if (!date) return '—'
    const timestamp = new Date(date).getTime()
    if (Number.isNaN(timestamp)) return '—'
    const minutes = Math.max(0, Math.floor((Date.now() - timestamp) / 60000))
    if (minutes < 60) return `${minutes} min ago`
    if (minutes < 1440) return `${Math.floor(minutes / 60)} hr ago`
    return new Date(date).toLocaleDateString()
}

function savePreferences() {
    localStorage.setItem('botechka_notification_preferences', JSON.stringify(notificationPreferences.value))
    isPreferencesOpen.value = false
    loadNotifications()
}

onMounted(() => {
    try {
        const savedReads = JSON.parse(localStorage.getItem(storageKey) || '[]')
        readIds.value = Array.isArray(savedReads) ? savedReads : []
        const savedPreferences = JSON.parse(localStorage.getItem('botechka_notification_preferences') || '{}')
        notificationPreferences.value = { ...notificationPreferences.value, ...savedPreferences }
        const savedConfiguration = JSON.parse(localStorage.getItem('botechka_configuration') || '{}')
        alertThresholds.value = {
            lowStock: Number.isFinite(Number(savedConfiguration.lowStockThreshold))
                ? Math.max(0, Number(savedConfiguration.lowStockThreshold)) : 10,
            expiryDays: Number.isFinite(Number(savedConfiguration.expiryAlertDays))
                ? Math.max(0, Number(savedConfiguration.expiryAlertDays)) : 30
        }
    } catch (error) {
        console.error('Unable to read saved notification preferences:', error)
    }
    loadNotifications()
})
</script>

<template>
    <section class="w-full min-w-0 font-inter">
        <div class="border-b border-gray-100 pb-4">
            <h1 class="text-lg font-bold text-gray-800">Notifications</h1>
            <p class="mt-1 text-sm text-gray-500">Stay up to date with activity across your workspace.</p>
        </div>

        <div class="flex flex-col gap-3 border-b border-gray-100 bg-gray-50/50 py-4 sm:flex-row sm:items-center sm:justify-between">
            <div class="relative w-full sm:max-w-md">
                <Search :size="17" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                <input v-model="searchQuery" type="search" placeholder="Search Notifications"
                    class="w-full rounded-md border border-gray-200 bg-white py-2.5 pl-10 pr-3 text-sm text-gray-700 outline-none placeholder:text-gray-400 focus:border-blue-400">
            </div>
            <div class="flex flex-wrap items-center gap-2">
                <button type="button" @click="isPreferencesOpen = true"
                    class="flex items-center gap-2 rounded-md border border-gray-200 bg-white px-4 py-2 text-sm text-gray-700 transition hover:bg-gray-50">
                    <SlidersHorizontal :size="16" /> Preferences
                </button>
                <button type="button" @click="markAllRead"
                    class="flex items-center gap-2 rounded-md bg-blue-700 px-4 py-2 text-sm font-medium text-white transition hover:bg-blue-800">
                    <CheckCheck :size="16" /> Mark all as read
                </button>
                <button type="button" @click="loadNotifications" :disabled="isLoading"
                    class="flex items-center gap-2 rounded-md border border-gray-200 bg-white px-4 py-2 text-sm text-gray-700 transition hover:bg-gray-50 disabled:opacity-50">
                    <Bell :size="16" :class="{ 'animate-pulse': isLoading }" /> Refresh
                </button>
            </div>
        </div>

        <p v-if="errorMessage" role="alert" class="my-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">{{ errorMessage }}</p>

        <div class="overflow-hidden rounded-xl border border-gray-200 bg-white">
            <div class="flex items-center gap-5 overflow-x-auto border-b border-gray-100 px-4 sm:px-6">
                <button v-for="filter in ['All', 'Inventory', 'Requests', 'Distributions']" :key="filter"
                    type="button" @click="selectedFilter = filter"
                    :class="selectedFilter === filter
                        ? 'border-[#2638ff] text-gray-800'
                        : 'border-transparent text-gray-500 hover:text-blue-600'"
                    class="shrink-0 border-b-2 py-4 text-sm font-medium transition">
                    {{ filter }}
                    <span v-if="filter === 'All'" class="ml-1 rounded-full bg-indigo-50 px-2 py-0.5 text-xs text-indigo-500">
                        {{ notifications.length }}
                    </span>
                </button>
            </div>

            <div class="flex items-center justify-between px-4 pb-2 pt-4 sm:px-6">
                <p class="text-xs font-medium uppercase tracking-wider text-slate-400">Current alerts</p>
                <p class="text-xs text-[#2638ff]">{{ unreadCount }} unread</p>
            </div>

            <p v-if="isLoading && !notifications.length" class="px-6 py-10 text-center text-sm text-slate-500">
                Loading notifications...
            </p>
            <p v-else-if="!visibleNotifications.length" class="px-6 py-10 text-center text-sm text-slate-500">
                No notifications found.
            </p>
            <div v-for="item in visibleNotifications" :key="item.id"
                :class="isRead(item.id) ? 'bg-white' : 'bg-slate-50/70'"
                class="group flex items-start gap-4 border-b border-gray-100 px-4 py-5 transition hover:bg-gray-50 sm:px-6">
                <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
                    <component :is="notificationIcon(item)" :size="19" />
                </div>
                <div class="min-w-0 flex-1">
                    <p class="text-sm font-semibold text-gray-800">{{ item.title }}</p>
                    <p class="mt-1 text-sm leading-5 text-slate-500">{{ item.description }}</p>
                    <router-link :to="item.href" @click="markRead(item.id)"
                        class="mt-3 inline-flex rounded-md border border-gray-200 bg-white px-3 py-1.5 text-xs text-gray-700 transition hover:border-blue-300 hover:text-blue-600">
                        View details
                    </router-link>
                </div>
                <div class="flex shrink-0 items-center gap-2 pt-1">
                    <span class="text-xs text-slate-400">{{ formatRelativeDate(item.date) }}</span>
                    <span v-if="!isRead(item.id)" class="h-2 w-2 rounded-full bg-indigo-500"></span>
                    <button v-if="!isRead(item.id)" type="button" @click="markRead(item.id)"
                        :aria-label="`Mark ${item.title} as read`"
                        class="ml-1 flex h-8 w-8 items-center justify-center rounded-md text-slate-400 transition hover:bg-gray-100 hover:text-gray-700">
                        <Check :size="16" />
                    </button>
                    <EllipsisVertical v-else :size="16" class="text-slate-300" />
                </div>
            </div>
        </div>

        <div v-if="isPreferencesOpen" class="fixed inset-0 z-[70] flex items-center justify-center bg-black/40 p-4">
            <section role="dialog" aria-modal="true" aria-labelledby="notification-preferences-title"
                class="w-full max-w-md rounded-xl bg-white p-6 shadow-xl">
                <div class="flex items-start justify-between">
                    <div>
                        <h2 id="notification-preferences-title" class="text-lg font-bold text-gray-800">Notification Preferences</h2>
                        <p class="mt-1 text-sm text-gray-500">Choose which alerts to show.</p>
                    </div>
                    <button type="button" @click="isPreferencesOpen = false" aria-label="Close preferences"
                        class="rounded-md p-1 text-gray-500 hover:bg-gray-100"><X :size="20" /></button>
                </div>
                <div class="mt-5 space-y-3">
                    <label v-for="preference in [
                        { key: 'inventory', label: 'Inventory and expiry alerts' },
                        { key: 'requests', label: 'Beneficiary medicine requests' },
                        { key: 'distributions', label: 'Distribution activity' }
                    ]" :key="preference.key" class="flex items-center justify-between rounded-lg border border-gray-100 p-3 text-sm text-gray-700">
                        {{ preference.label }}
                        <input v-model="notificationPreferences[preference.key]" type="checkbox" class="h-4 w-4 accent-blue-700">
                    </label>
                </div>
                <div class="mt-6 flex justify-end gap-3">
                    <button type="button" @click="isPreferencesOpen = false"
                        class="rounded-lg border border-gray-200 px-4 py-2 text-sm text-gray-600 hover:bg-gray-50">Cancel</button>
                    <button type="button" @click="savePreferences"
                        class="rounded-lg bg-blue-700 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-800">Save Preferences</button>
                </div>
            </section>
        </div>
    </section>
</template>
