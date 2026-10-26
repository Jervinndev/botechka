<script setup>
import {
    Archive,
    Brush,
    DatabaseBackup,
    Settings2,
    Truck,
    UserRoundCog
} from '@lucide/vue'

const settingsLinks = [
    { label: 'Appearance', to: { name: 'settings-appearance' }, Icon: Brush },
    { label: 'Account Management', to: { name: 'settings-account-management' }, Icon: UserRoundCog },
    { label: 'Backup & Recovery', to: { name: 'settings-backup-recovery' }, Icon: DatabaseBackup },
    { label: 'Archive', to: { name: 'settings-archive' }, Icon: Archive },
    { label: 'Configuration', to: { name: 'settings-configuration' }, Icon: Settings2 },
    { label: 'Suppliers', to: { name: 'settings-suppliers' }, Icon: Truck }
]
</script>

<template>
    <nav aria-label="Settings navigation"
        class="w-full h-fit shrink-0 rounded-xl border border-gray-100 bg-white p-3 md:w-56">
        <h2 class="px-3 py-2 text-xs font-semibold uppercase tracking-wide text-gray-400">Settings</h2>
        <div class="flex gap-1 overflow-x-auto md:flex-col md:overflow-visible">
            <router-link v-for="item in settingsLinks" :key="item.label" :to="item.to"
                class="flex shrink-0 items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-50 hover:text-blue-700"
                active-class="!bg-blue-50 !text-blue-700">
                <component :is="item.Icon" :size="18" />
                <span>{{ item.label }}</span>
            </router-link>
        </div>
    </nav>
</template>