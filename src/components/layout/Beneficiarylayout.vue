<script setup>
import Sidebar from '../admin/sidebar.vue'
</script>

<template>
    <section class="flex flex-col md:flex-row bg-gray-100 min-h-screen md:h-screen">
        <Sidebar :is-beneficiary-layout="true" />
        <main class="flex-1 min-w-0 p-4 pt-10 md:pt-4 md:overflow-auto">
            <router-view />
        </main>
    </section>
</template>