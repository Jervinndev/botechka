<script setup>
import { computed, onMounted, ref } from 'vue'
import { Bell, Check, LogOut, Settings, X } from '@lucide/vue'
import { useRouter } from 'vue-router'
import { getMyProfile, signOutUser } from '../../services/Authservices'
import { getMyMedicineRequests } from '../../services/MedicineRequests'

const router = useRouter()
const profile = ref(null)
const requests = ref([])
const readIds = ref([])
const activePanel = ref('')
const errorMessage = ref('')
const isLoading = ref(false)
const isSigningOut = ref(false)

const displayName = computed(() => {
    if (!profile.value) return 'My account'
    return [profile.value.fname, profile.value.mname, profile.value.lname]
        .filter((name) => name?.trim())
        .join(' ') || profile.value.email || 'My account'
})
const initials = computed(() => displayName.value
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0].toUpperCase())
    .join(''))
const unreadCount = computed(() => notifications.value.filter((item) => !readIds.value.includes(item.id)).length)
const notifications = computed(() => requests.value.slice(0, 8).map((request) => ({
    id: `beneficiary-request-${request.request_id}`,
    title: request.status === 'pending' ? 'Request pending' : `Request ${request.status}`,
    description: `${request.medicine_name} · ${request.quantity} ${request.medicine_unit || 'unit(s)'}`,
    date: request.reviewed_at || request.created_at,
    status: request.status
})))
const storageKey = computed(() => `botechka_beneficiary_notifications_read_${profile.value?.id || 'user'}`)

function isRead(id) {
    return readIds.value.includes(id)
}

function markRead(id) {
    if (isRead(id)) return
    readIds.value = [...readIds.value, id]
    localStorage.setItem(storageKey.value, JSON.stringify(readIds.value))
}

async function loadRequests() {
    isLoading.value = true
    errorMessage.value = ''
    try {
        requests.value = await getMyMedicineRequests()
    } catch (error) {
        console.error('Unable to load beneficiary notifications:', error)
        errorMessage.value = error.message || 'Unable to load notifications.'
    } finally {
        isLoading.value = false
    }
}

async function toggleNotifications() {
    activePanel.value = activePanel.value === 'notifications' ? '' : 'notifications'
    if (activePanel.value === 'notifications') {
        await loadRequests()
        try {
            const saved = JSON.parse(localStorage.getItem(storageKey.value) || '[]')
            readIds.value = Array.isArray(saved) ? saved : []
        } catch (error) {
            console.error('Unable to read notification state:', error)
            errorMessage.value = 'Unable to load notification read status.'
        }
    }
}

async function logout() {
    isSigningOut.value = true
    try {
        const result = await signOutUser()
        if (!result.success) throw new Error(result.error)
        await router.replace('/login')
    } catch (error) {
        console.error('Unable to sign out:', error)
        errorMessage.value = error.message || 'Unable to sign out.'
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
    const result = await getMyProfile()
    if (!result.success) {
        console.error('Unable to load beneficiary profile:', result.error)
        errorMessage.value = 'Unable to load your profile.'
        return
    }
    profile.value = result.data
    try {
        const saved = JSON.parse(localStorage.getItem(storageKey.value) || '[]')
        readIds.value = Array.isArray(saved) ? saved : []
    } catch (error) {
        console.error('Unable to read beneficiary notification state:', error)
        errorMessage.value = 'Unable to load notification read status.'
    }
    await loadRequests()
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
        <button type="button" @click="activePanel = activePanel === 'profile' ? '' : 'profile'"
            aria-label="Open profile menu" :aria-expanded="activePanel === 'profile'"
            class="flex h-10 w-10 items-center justify-center rounded-full bg-blue-700 text-sm font-bold text-white ring-2 ring-blue-100 transition hover:ring-blue-300">
            {{ initials }}
        </button>

        <div v-if="activePanel === 'notifications'"
            class="absolute right-0 top-12 z-[80] w-[min(24rem,calc(100vw-2rem))] overflow-hidden rounded-xl border border-slate-200 bg-white text-left shadow-xl"
            role="dialog" aria-label="Your notifications">
            <div class="flex items-center justify-between border-b border-slate-100 px-4 py-3">
                <div>
                    <h2 class="text-sm font-bold text-slate-800">My Notifications</h2>
                    <p class="text-xs text-slate-500">{{ unreadCount }} unread</p>
                </div>
                <button type="button" @click="activePanel = ''" aria-label="Close notifications"
                    class="rounded-md p-1.5 text-slate-500 hover:bg-slate-100"><X :size="17" /></button>
            </div>
            <p v-if="errorMessage" role="alert" class="m-3 rounded-lg bg-red-50 p-3 text-xs text-red-700">{{ errorMessage }}</p>
            <p v-else-if="isLoading && !notifications.length" class="px-4 py-8 text-center text-sm text-slate-500">
                Loading notifications...
            </p>
            <p v-else-if="!notifications.length" class="px-4 py-8 text-center text-sm text-slate-500">
                No medicine request updates yet.
            </p>
            <ul v-else class="max-h-96 divide-y divide-slate-100 overflow-y-auto">
                <li v-for="item in notifications" :key="item.id" :class="isRead(item.id) ? 'bg-white' : 'bg-blue-50/60'">
                    <RouterLink :to="{ name: 'notificationbene' }" @click="markRead(item.id); activePanel = ''"
                        class="block px-4 py-3 transition hover:bg-slate-50">
                        <span class="flex items-start justify-between gap-3">
                            <span>
                                <span class="block text-sm font-semibold capitalize text-slate-800">{{ item.title }}</span>
                                <span class="mt-1 block text-xs text-slate-600">{{ item.description }}</span>
                                <span class="mt-1 block text-[11px] text-slate-400">{{ formatDate(item.date) }}</span>
                            </span>
                            <Check v-if="isRead(item.id)" :size="15" class="mt-1 shrink-0 text-emerald-600" />
                            <span v-else class="mt-1 h-2 w-2 shrink-0 rounded-full bg-blue-600"></span>
                        </span>
                    </RouterLink>
                </li>
            </ul>
            <RouterLink :to="{ name: 'notificationbene' }" @click="activePanel = ''"
                class="block border-t border-slate-100 px-4 py-3 text-center text-sm font-semibold text-blue-700 hover:bg-blue-50">
                View all updates
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
                    <span class="mt-1 block text-xs text-blue-700">Beneficiary</span>
                </span>
            </div>
            <RouterLink :to="{ name: 'beneficiary-settings' }" @click="activePanel = ''"
                class="mt-3 flex items-center gap-2 rounded-lg px-3 py-2 text-sm text-slate-700 hover:bg-slate-100">
                <Settings :size="16" /> Settings
            </RouterLink>
            <button type="button" @click="logout" :disabled="isSigningOut"
                class="mt-1 flex w-full items-center gap-2 rounded-lg px-3 py-2 text-left text-sm text-red-600 hover:bg-red-50 disabled:opacity-50">
                <LogOut :size="16" /> {{ isSigningOut ? 'Signing out...' : 'Sign out' }}
            </button>
        </div>
    </div>
</template>
