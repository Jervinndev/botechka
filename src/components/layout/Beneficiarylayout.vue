<script setup>
import Sidebar from '../admin/sidebar.vue'
</script>

<template>
    <section class="flex bg-gray-100 h-screen">
        <Sidebar />
        <main class="p-4 w-full overflow-auto">
            <router-view />
        </main>
    </section>
</template>