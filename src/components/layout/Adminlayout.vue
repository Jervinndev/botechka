<script setup>
import { nextTick, onBeforeUnmount, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import gsap from 'gsap'
import Sidebar from '../admin/sidebar.vue'

const route = useRoute()
const pageContainer = ref(null)
let routeAnimation

watch(
    () => route.fullPath,
    async () => {
        await nextTick()
        routeAnimation?.kill()
        routeAnimation = gsap.fromTo(
            pageContainer.value,
            { opacity: 0, y: 14 },
            {
                opacity: 1,
                y: 0,
                duration: 0.45,
                ease: 'power2.out',
                clearProps: 'transform,opacity'
            }
        )
    },
    { immediate: true }
)

onBeforeUnmount(() => routeAnimation?.kill())
</script>

<template>
    <section class="flex min-h-screen flex-col bg-gray-100 md:h-screen md:flex-row overflow-hidden">
        <Sidebar />
        <main ref="pageContainer" class="min-w-0 flex-1 p-4 pt-12 md:overflow-auto md:pt-4">
            <router-view />
        </main>
    </section>
</template>