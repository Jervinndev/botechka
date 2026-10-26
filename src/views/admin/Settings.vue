<script setup>
import SettingsSidebar from '../../components/admin/SettingsSidebar.vue'
</script>

<template>
    <section class="w-full">
        <div>
            <h1 class="font-inter text-lg font-bold text-[#404040]">Settings</h1>
            <p class="text-sm text-[#808080]">Manage your system preferences and administration tools.</p>
        </div>

        <div class="mt-4 flex min-w-0 flex-col gap-4 md:flex-row">
            <SettingsSidebar />
            <main class="min-w-0 h-fit flex-1 rounded-xl border overflow-auto border-gray-100 bg-white p-4 sm:p-6">
                <router-view />
            </main>
        </div>
    </section>
</template>