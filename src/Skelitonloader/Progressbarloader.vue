<script setup>
import { onMounted, onUnmounted, ref } from 'vue'

const emit = defineEmits(['complete'])

defineProps({
    message: {
        type: String,
        default: 'Loading BOTECHKA...'
    }
})

const progress = ref(1)
let progressTimer

onMounted(() => {
    progressTimer = window.setInterval(() => {
        progress.value += 1

        if (progress.value >= 100) {
            progress.value = 100
            window.clearInterval(progressTimer)
            emit('complete')
        }
    }, 30)
})

onUnmounted(() => {
    window.clearInterval(progressTimer)
})
</script>

<template>
    <div class="flex min-h-screen w-full flex-col items-center justify-center gap-4 bg-gray-100 px-6 text-blue-700">
        <div class="flex items-center gap-3">
            <div>
                <img src="/src/assets/Screenshot 2026-08-04 113304(2).png" alt="" class="w-10">
            </div>
            <div class="flex  flex-col">
                <h1 class="font-outfit font-black text-[#404040]"><span class="text-blue-700">botech</span>ka
                </h1>
                <p class="text-xs text-[#808080]">Botika ng bayan</p>
            </div>
        </div>
        <div class="w-full max-w-xs overflow-hidden rounded-full bg-white" role="progressbar" aria-label="Loading"
            :aria-valuenow="progress" aria-valuemin="1" aria-valuemax="100">
            <div class="h-2 rounded-full bg-blue-700 transition-[width] duration-75" :style="{ width: `${progress}%` }">
            </div>
        </div>
        <div class="flex items-center gap-2 text-sm font-medium">
            <p>{{ message }}</p>
            <span>{{ progress }}%</span>
        </div>
    </div>
</template>
