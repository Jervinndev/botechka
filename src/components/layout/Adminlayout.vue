<script setup>
import Sidebar from '../admin/sidebar.vue'
</script>

<template>
    <section class="flex min-h-screen flex-col bg-gray-100 md:h-screen md:flex-row overflow-hidden">
        <Sidebar />
        <main class="min-w-0 flex-1 p-4 pt-12 md:overflow-auto md:pt-4">
            <router-view />
        </main>
    </section>
</template>