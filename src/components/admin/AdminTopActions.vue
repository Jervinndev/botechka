<script setup>
import { computed, onMounted, ref } from 'vue'
import { Bell, Check, ChevronDown, LogOut, Settings, X } from '@lucide/vue'
import { useRouter } from 'vue-router'
import { getMyProfile, signOutUser } from '../../services/Authservices'
import { supabase } from '../../supabase/supabase'

const router = useRouter()
const profile = ref(null)
const activePanel = ref('')
const notifications = ref([])
const unreadIds = ref([])
const notificationError = ref('')
const profileError = ref('')
const actionError = ref('')
const isLoadingNotifications = ref(false)
const isSigningOut = ref(false)
const lowStockThreshold = ref(10)
const expiryAlertDays = ref(30)
const notificationPreferences = ref({
    inventory: true,
    requests: true,
    distributions: true
})

const displayName = computed(() => {
    if (!profile.value) return 'Admin'
    return [profile.value.fname, profile.value.mname, profile.value.lname]
        .filter((name) => name?.trim())
        .join(' ') || profile.value.email || 'Admin'
})

const initials = computed(() => displayName.value
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0].toUpperCase())
    .join(''))
const settingsRoute = computed(() => profile.value?.role?.toLowerCase() === 'super_admin'
    ? { name: 'settings-account-management' }
    : { name: 'settings-appearance' })
const settingsLabel = computed(() => profile.value?.role?.toLowerCase() === 'super_admin'
    ? 'Account Management'
    : 'Settings')

const unreadCount = computed(() => notifications.value.filter((item) => !unreadIds.value.includes(item.id)).length)

function isRead(id) {
    return unreadIds.value.includes(id)
}

function markRead(id) {
    if (isRead(id)) return
    unreadIds.value = [...unreadIds.value, id]
    localStorage.setItem('botechka_notifications_read', JSON.stringify(unreadIds.value))
}

function readPreferences() {
    try {
        const reads = JSON.parse(localStorage.getItem('botechka_notifications_read') || '[]')
        unreadIds.value = Array.isArray(reads) ? reads : []
        const config = JSON.parse(localStorage.getItem('botechka_configuration') || '{}')
        const threshold = Number(config.lowStockThreshold)
        const expiryDays = Number(config.expiryAlertDays)
        lowStockThreshold.value = Number.isFinite(threshold) ? Math.max(0, threshold) : 10
        expiryAlertDays.value = Number.isFinite(expiryDays) ? Math.max(0, expiryDays) : 30
        const savedPreferences = JSON.parse(localStorage.getItem('botechka_notification_preferences') || '{}')
        notificationPreferences.value = { ...notificationPreferences.value, ...savedPreferences }
    } catch (error) {
        console.error('Unable to load notification settings:', error)
        notificationError.value = 'Unable to load saved notification settings.'
    }
}

async function loadNotifications() {
    isLoadingNotifications.value = true
    notificationError.value = ''
    try {
        const [medicinesResult, requestsResult, distributionsResult] = await Promise.all([
            notificationPreferences.value.inventory ? supabase.from('medicines')
                .select('id, medicine_name, quantity, expiration_date, created_at')
                .is('archived_at', null) : Promise.resolve({ data: [], error: null }),
            notificationPreferences.value.requests ? supabase.from('medicine_requests')
                .select('request_id, medicine_name, status, created_at')
                .in('status', ['pending', 'approved', 'rejected'])
                .order('created_at', { ascending: false })
                .limit(5) : Promise.resolve({ data: [], error: null }),
            notificationPreferences.value.distributions ? supabase.from('distribution_transactions')
                .select('distribution_transaction_id, distribution_date, purpose')
                .order('distribution_date', { ascending: false })
                .limit(5) : Promise.resolve({ data: [], error: null })
        ])
        const failed = [medicinesResult, requestsResult, distributionsResult].find((result) => result.error)
        if (failed?.error) throw failed.error

        const items = []
        for (const medicine of medicinesResult.data || []) {
            const quantity = Number(medicine.quantity) || 0
            if (quantity <= lowStockThreshold.value) {
                items.push({
                    id: `Inventory-low-${medicine.id}`,
                    title: quantity === 0 ? 'Medicine out of stock' : 'Low medicine stock',
                    description: `${medicine.medicine_name}: ${quantity} unit(s) available.`,
                    date: medicine.created_at,
                    href: '/inventory'
                })
            }
            if (medicine.expiration_date) {
                const expiry = new Date(`${medicine.expiration_date}T00:00:00`)
                const expiryLimit = new Date()
                expiryLimit.setDate(expiryLimit.getDate() + expiryAlertDays.value)
                if (!Number.isNaN(expiry.getTime()) && expiry <= expiryLimit) {
                    const expired = expiry < new Date()
                    items.push({
                        id: `Inventory-expiry-${medicine.id}`,
                        title: expired ? 'Medicine expired' : 'Medicine expiring soon',
                        description: `${medicine.medicine_name} ${expired ? 'expired' : 'expires'} on ${expiry.toLocaleDateString()}.`,
                        date: medicine.created_at,
                        href: '/inventory'
                    })
                }
            }
        }
        for (const request of requestsResult.data || []) {
            items.push({
                id: `Requests-${request.request_id}`,
                title: request.status === 'pending' ? 'Medicine request needs review' : 'Medicine request updated',
                description: `${request.medicine_name} request is ${request.status}.`,
                date: request.created_at,
                href: '/beneficiaryrequest'
            })
        }
        for (const distribution of distributionsResult.data || []) {
            items.push({
                id: `Distributions-${distribution.distribution_transaction_id}`,
                title: 'Distribution recorded',
                description: `A medicine distribution was recorded for ${distribution.purpose}.`,
                date: distribution.distribution_date,
                href: '/distribution'
            })
        }
        notifications.value = items
            .sort((a, b) => new Date(b.date || 0) - new Date(a.date || 0))
            .slice(0, 8)
    } catch (error) {
        console.error('Unable to load quick notifications:', error)
        notificationError.value = error.message || 'Unable to load notifications.'
    } finally {
        isLoadingNotifications.value = false
    }
}

async function toggleNotifications() {
    activePanel.value = activePanel.value === 'notifications' ? '' : 'notifications'
    if (activePanel.value === 'notifications') await loadNotifications()
}

function toggleProfile() {
    activePanel.value = activePanel.value === 'profile' ? '' : 'profile'
}

async function logout() {
    isSigningOut.value = true
    actionError.value = ''
    try {
        const result = await signOutUser()
        if (!result.success) throw new Error(result.error)
        await router.replace('/login')
    } catch (error) {
        console.error('Unable to sign out:', error)
        actionError.value = error.message || 'Unable to sign out.'
    } finally {
        isSigningOut.value = false
    }
}

function formatDate(value) {
    if (!value) return '—'
    const date = new Date(value)
    return Number.isNaN(date.getTime()) ? '—' : date.toLocaleString()
}

onMounted(async () => {
    readPreferences()
    const result = await getMyProfile()
    if (!result.success) {
        console.error('Unable to load admin profile:', result.error)
        profileError.value = 'Unable to load profile details.'
        return
    }
    profile.value = result.data
})
</script>

<template>
    <div class="relative flex items-center gap-3">
        <button type="button" @click="toggleNotifications" aria-label="Open notifications"
            :aria-expanded="activePanel === 'notifications'"
            class="relative flex h-10 w-10 items-center justify-center rounded-full text-blue-700 transition hover:bg-blue-50">
            <Bell :size="20" />
            <span v-if="unreadCount" class="absolute right-0 top-0 flex h-4 min-w-4 items-center justify-center rounded-full bg-red-600 px-1 text-[10px] font-bold text-white">
                {{ unreadCount > 9 ? '9+' : unreadCount }}
            </span>
        </button>
        <button type="button" @click="toggleProfile" aria-label="Open profile menu"
            :aria-expanded="activePanel === 'profile'"
            class="flex h-10 w-10 items-center justify-center rounded-full bg-blue-700 text-sm font-bold text-white ring-2 ring-blue-100 transition hover:ring-blue-300">
            {{ initials }}
        </button>

        <div v-if="activePanel === 'notifications'"
            class="absolute right-0 top-12 z-[80] w-[min(24rem,calc(100vw-2rem))] overflow-hidden rounded-xl border border-slate-200 bg-white text-left shadow-xl"
            role="dialog" aria-modal="false" aria-label="Notifications">
            <div class="flex items-center justify-between border-b border-slate-100 px-4 py-3">
                <div>
                    <h2 class="text-sm font-bold text-slate-800">Notifications</h2>
                    <p class="text-xs text-slate-500">{{ unreadCount }} unread</p>
                </div>
                <button type="button" @click="activePanel = ''" aria-label="Close notifications"
                    class="rounded-md p-1.5 text-slate-500 hover:bg-slate-100"><X :size="17" /></button>
            </div>
            <p v-if="notificationError" role="alert" class="m-3 rounded-lg bg-red-50 p-3 text-xs text-red-700">
                {{ notificationError }}
            </p>
            <p v-else-if="isLoadingNotifications && !notifications.length" class="px-4 py-8 text-center text-sm text-slate-500">
                Loading notifications...
            </p>
            <p v-else-if="!notifications.length" class="px-4 py-8 text-center text-sm text-slate-500">
                You're all caught up.
            </p>
            <ul v-else class="max-h-96 divide-y divide-slate-100 overflow-y-auto">
                <li v-for="item in notifications" :key="item.id"
                    :class="isRead(item.id) ? 'bg-white' : 'bg-blue-50/60'">
                    <RouterLink :to="item.href" @click="markRead(item.id); activePanel = ''"
                        class="block px-4 py-3 transition hover:bg-slate-50">
                        <span class="flex items-start justify-between gap-3">
                            <span>
                                <span class="block text-sm font-semibold text-slate-800">{{ item.title }}</span>
                                <span class="mt-1 block text-xs text-slate-600">{{ item.description }}</span>
                                <span class="mt-1 block text-[11px] text-slate-400">{{ formatDate(item.date) }}</span>
                            </span>
                            <Check v-if="isRead(item.id)" :size="15" class="mt-1 shrink-0 text-emerald-600" />
                            <span v-else class="mt-1 h-2 w-2 shrink-0 rounded-full bg-blue-600"></span>
                        </span>
                    </RouterLink>
                </li>
            </ul>
            <RouterLink to="/notification" @click="activePanel = ''"
                class="block border-t border-slate-100 px-4 py-3 text-center text-sm font-semibold text-blue-700 hover:bg-blue-50">
                View all notifications
            </RouterLink>
        </div>

        <div v-if="activePanel === 'profile'"
            class="absolute right-0 top-12 z-[80] w-64 rounded-xl border border-slate-200 bg-white p-4 text-left shadow-xl"
            role="menu" aria-label="Profile menu">
            <div class="flex items-center gap-3 border-b border-slate-100 pb-3">
                <span class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-blue-700 text-sm font-bold text-white">{{ initials }}</span>
                <span class="min-w-0">
                    <span class="block truncate text-sm font-semibold text-slate-800">{{ displayName }}</span>
                    <span class="block truncate text-xs text-slate-500">{{ profile?.email }}</span>
                    <span class="mt-1 block text-xs capitalize text-blue-700">{{ profile?.role?.replace('_', ' ') }}</span>
                </span>
            </div>
            <p v-if="profileError" role="alert" class="mt-3 text-xs text-red-600">{{ profileError }}</p>
            <p v-if="actionError" role="alert" class="mt-3 text-xs text-red-600">{{ actionError }}</p>
            <RouterLink :to="settingsRoute" @click="activePanel = ''"
                class="mt-3 flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100">
                <Settings :size="16" /> {{ settingsLabel }}
            </RouterLink>
            <button type="button" role="menuitem" @click="logout" :disabled="isSigningOut"
                class="mt-1 flex w-full items-center gap-2 rounded-lg px-3 py-2 text-left text-sm text-red-600 hover:bg-red-50 disabled:opacity-50">
                <LogOut :size="16" /> {{ isSigningOut ? 'Signing out...' : 'Sign out' }}
            </button>
        </div>
    </div>
</template>
