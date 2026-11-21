<script setup>
import { computed, onMounted, ref } from 'vue'
import { History, UserRound } from '@lucide/vue'
import { getMyProfile } from '../services/Authservices'
import { getMyActivityLog } from '../services/AuditTrail'

const profile = ref(null)
const activities = ref([])
const isLoading = ref(true)
const errorMessage = ref('')
const activityError = ref('')

const fullName = computed(() => profile.value
    ? [profile.value.fname, profile.value.mname, profile.value.lname].filter(Boolean).join(' ')
    : '')

function formatDate(value) {
    if (!value) return '—'
    const date = new Date(value)
    return Number.isNaN(date.getTime()) ? '—' : date.toLocaleString()
}

onMounted(async () => {
    const [profileResult, activityResult] = await Promise.allSettled([
        getMyProfile(),
        getMyActivityLog()
    ])
    if (profileResult.status === 'fulfilled' && profileResult.value.success) {
        profile.value = profileResult.value.data
    } else {
        errorMessage.value = profileResult.status === 'rejected'
            ? profileResult.reason?.message || 'Unable to load your profile.'
            : profileResult.value.error || 'Unable to load your profile.'
    }

    if (activityResult.status === 'fulfilled') {
        activities.value = activityResult.value
    } else {
        console.error('Unable to load profile activity:', activityResult.reason)
        activityError.value = activityResult.reason?.message || 'Unable to load your activity log.'
    }
    isLoading.value = false
})
</script>

<template>
    <main class="mx-auto max-w-5xl p-4 font-inter text-slate-900 sm:p-8">
        <header class="mb-6 flex items-center gap-3">
            <span class="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-50 text-blue-700">
                <UserRound :size="24" />
            </span>
            <div>
                <h1 class="text-xl font-bold">My Profile</h1>
                <p class="text-sm text-slate-500">Account information and your activity history.</p>
            </div>
        </header>

        <p v-if="errorMessage" role="alert" class="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">
            {{ errorMessage }}
        </p>
        <p v-else-if="isLoading" class="rounded-xl bg-white p-8 text-center text-sm text-slate-500">
            Loading profile...
        </p>

        <section v-else-if="profile" class="rounded-xl border border-slate-200 bg-white p-5 sm:p-6">
            <h2 class="text-base font-semibold">Account information</h2>
            <dl class="mt-4 grid gap-4 sm:grid-cols-2">
                <div>
                    <dt class="text-xs text-slate-500">Full name</dt>
                    <dd class="mt-1 text-sm font-medium">{{ fullName || '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs text-slate-500">Email</dt>
                    <dd class="mt-1 text-sm font-medium">{{ profile.email || '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs text-slate-500">Role</dt>
                    <dd class="mt-1 text-sm font-medium capitalize">{{ profile.role?.replaceAll('_', ' ') || '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs text-slate-500">Contact number</dt>
                    <dd class="mt-1 text-sm font-medium">{{ profile.contactnumber || '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs text-slate-500">Barangay</dt>
                    <dd class="mt-1 text-sm font-medium">{{ profile.barangay || '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs text-slate-500">Account created</dt>
                    <dd class="mt-1 text-sm font-medium">{{ formatDate(profile.created_at) }}</dd>
                </div>
            </dl>
        </section>

        <section class="mt-5 overflow-hidden rounded-xl border border-slate-200 bg-white">
            <header class="flex items-center gap-2 border-b border-slate-100 p-5">
                <History :size="18" class="text-blue-700" />
                <div>
                    <h2 class="text-base font-semibold">My activity</h2>
                    <p class="text-xs text-slate-500">Recent sign-ins, sign-outs, and account actions.</p>
                </div>
            </header>
            <p v-if="activityError" role="alert" class="p-5 text-sm text-red-700">{{ activityError }}</p>
            <p v-else-if="!activities.length" class="p-8 text-center text-sm text-slate-500">No activity recorded yet.</p>
            <ul v-else class="divide-y divide-slate-100">
                <li v-for="activity in activities" :key="activity.audit_log_id" class="flex flex-wrap justify-between gap-2 p-4">
                    <div>
                        <p class="text-sm font-semibold capitalize">{{ activity.action }}</p>
                        <p class="mt-0.5 text-xs text-slate-500">
                            {{ activity.entity_type || 'Account' }}
                            <span v-if="activity.entity_id"> · {{ activity.entity_id }}</span>
                            <span v-if="activity.details?.name"> · {{ activity.details.name }}</span>
                        </p>
                    </div>
                    <time class="text-xs text-slate-500">{{ formatDate(activity.created_at) }}</time>
                </li>
            </ul>
        </section>
    </main>
</template>
