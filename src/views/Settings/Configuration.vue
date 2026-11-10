<script setup>
import { onMounted, reactive, ref } from 'vue'
import { Settings2, Save } from '@lucide/vue'

const storageKey = 'botechka_configuration'
const settings = reactive({
    organizationName: 'RHU-BoTechKa',
    lowStockThreshold: 10,
    expiryAlertDays: 30
})
const successMessage = ref('')
const errorMessage = ref('')

function saveSettings() {
    if (settings.lowStockThreshold < 0 || settings.expiryAlertDays < 0) {
        errorMessage.value = 'Thresholds cannot be negative.'
        successMessage.value = ''
        return
    }

    localStorage.setItem(storageKey, JSON.stringify(settings))
    window.dispatchEvent(new CustomEvent('botechka:configuration-updated'))
    errorMessage.value = ''
    successMessage.value = 'Configuration saved in this browser.'
}

onMounted(() => {
    try {
        const saved = JSON.parse(localStorage.getItem(storageKey) || '{}')
        Object.assign(settings, saved)
    } catch (error) {
        console.error('Unable to load saved configuration:', error)
        errorMessage.value = 'Saved configuration could not be read.'
    }
})
</script>

<template>
    <section class="font-inter">
        <h2 class="flex items-center gap-2 text-lg font-semibold text-[#404040]">
            <Settings2 :size="20" /> Configuration
        </h2>
        <p class="mt-1 text-sm text-[#808080]">Configure inventory alerts for this browser.</p>

        <p v-if="successMessage" role="status" class="mt-4 rounded-lg bg-emerald-50 p-3 text-sm text-emerald-700">
            {{ successMessage }}
        </p>
        <p v-if="errorMessage" role="alert" class="mt-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">
            {{ errorMessage }}
        </p>

        <form @submit.prevent="saveSettings" class="mt-5 grid max-w-2xl gap-5">
            <label class="text-sm font-medium text-slate-700">
                Organization name
                <input v-model.trim="settings.organizationName" type="text" required
                    class="mt-1 w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 outline-none focus:border-blue-500">
            </label>
            <label class="text-sm font-medium text-slate-700">
                Low stock alert threshold
                <input v-model.number="settings.lowStockThreshold" type="number" min="0" step="1" required
                    class="mt-1 w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 outline-none focus:border-blue-500">
                <span class="mt-1 block text-xs font-normal text-slate-500">Notify when on-hand stock is at or below this quantity.</span>
            </label>
            <label class="text-sm font-medium text-slate-700">
                Expiry alert window (days)
                <input v-model.number="settings.expiryAlertDays" type="number" min="0" step="1" required
                    class="mt-1 w-full rounded-lg border border-slate-200 bg-white px-3 py-2.5 outline-none focus:border-blue-500">
                <span class="mt-1 block text-xs font-normal text-slate-500">Notify when medicine expires within this many days.</span>
            </label>
            <button type="submit"
                class="flex w-fit items-center gap-2 rounded-lg bg-blue-700 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-blue-800">
                <Save :size="16" /> Save configuration
            </button>
        </form>
    </section>
</template>
