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
    <section class="flex flex-col md:flex-row bg-gray-100 min-h-screen md:h-screen">
        <Sidebar :is-beneficiary-layout="true" />
        <main ref="pageContainer" class="flex-1 min-w-0 p-4 pt-12 md:pt-4 md:overflow-auto">
            <router-view />
        </main>
    </section>
</template>