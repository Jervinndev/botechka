<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { Moon, Palette, Sun, LaptopMinimal } from '@lucide/vue'
import { getMyProfile } from '../../services/Authservices'

const theme = ref('system')
const profile = ref(null)
let systemPreference

const themeOptions = [
    { value: 'light', label: 'Light', description: 'Use a bright appearance.', Icon: Sun },
    { value: 'dark', label: 'Dark', description: 'Use a dark appearance.', Icon: Moon },
    { value: 'system', label: 'System', description: 'Follow your device preference.', Icon: LaptopMinimal }
]

const fullName = computed(() => {
    if (!profile.value) return '—'
    return [profile.value.fname, profile.value.mname, profile.value.lname]
        .filter((part) => part?.trim())
        .join(' ') || '—'
})

function applyTheme() {
    const dark = theme.value === 'dark'
        || (theme.value === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)
    document.documentElement.classList.toggle('dark', dark)
    localStorage.setItem('theme', theme.value)
}

function handleSystemThemeChange() {
    if (theme.value === 'system') applyTheme()
}

onMounted(async () => {
    const savedTheme = localStorage.getItem('theme')
    theme.value = ['light', 'dark', 'system'].includes(savedTheme) ? savedTheme : 'system'
    applyTheme()
    systemPreference = window.matchMedia('(prefers-color-scheme: dark)')
    systemPreference.addEventListener('change', handleSystemThemeChange)

    const result = await getMyProfile()
    if (!result.success) {
        console.error('Unable to load beneficiary profile settings:', result.error)
        return
    }
    profile.value = result.data
})

onUnmounted(() => systemPreference?.removeEventListener('change', handleSystemThemeChange))
</script>

<template>
    <section class="mx-auto max-w-3xl font-inter text-slate-900">
        <header class="mb-6">
            <h1 class="flex items-center gap-2 text-xl font-bold text-slate-800">
                <Palette :size="22" /> My Settings
            </h1>
            <p class="mt-1 text-sm text-slate-500">Manage your profile details and dashboard appearance.</p>
        </header>

        <section class="rounded-xl border border-slate-200 bg-white p-5 sm:p-6">
            <h2 class="text-base font-semibold text-slate-800">Profile</h2>
            <dl class="mt-4 grid gap-4 sm:grid-cols-2">
                <div>
                    <dt class="text-xs text-slate-500">Full name</dt>
                    <dd class="mt-1 text-sm font-medium text-slate-800">{{ fullName }}</dd>
                </div>
                <div>
                    <dt class="text-xs text-slate-500">Email</dt>
                    <dd class="mt-1 text-sm font-medium text-slate-800">{{ profile?.email || '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs text-slate-500">Contact number</dt>
                    <dd class="mt-1 text-sm font-medium text-slate-800">{{ profile?.contactnumber || '—' }}</dd>
                </div>
                <div>
                    <dt class="text-xs text-slate-500">Barangay</dt>
                    <dd class="mt-1 text-sm font-medium text-slate-800">{{ profile?.barangay || '—' }}</dd>
                </div>
            </dl>
        </section>

        <section class="mt-5 rounded-xl border border-slate-200 bg-white p-5 sm:p-6">
            <h2 class="text-base font-semibold text-slate-800">Appearance</h2>
            <p class="mt-1 text-sm text-slate-500">Choose light mode, dark mode, or follow your device setting.</p>
            <div class="mt-4 grid gap-3 sm:grid-cols-3">
                <label v-for="option in themeOptions" :key="option.value" class="cursor-pointer">
                    <input v-model="theme" @change="applyTheme" type="radio" name="beneficiary-theme"
                        :value="option.value" class="peer sr-only">
                    <span class="flex h-full flex-col rounded-xl border border-slate-200 p-4 transition hover:border-blue-300 peer-checked:border-blue-600 peer-checked:bg-blue-50">
                        <component :is="option.Icon" :size="20" class="text-blue-700" />
                        <span class="mt-3 text-sm font-semibold text-slate-800">{{ option.label }}</span>
                        <span class="mt-1 text-xs text-slate-500">{{ option.description }}</span>
                    </span>
                </label>
            </div>
        </section>
    </section>
</template>
