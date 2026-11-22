<script setup>
defineProps({
    variant: {
        type: String,
        default: 'table'
    }
})
</script>

<template>
    <section
        class="w-full animate-pulse font-inter"
        :aria-label="variant === 'cards' ? 'Loading cards and content' : 'Loading page content'"
    >
        <div class="flex items-center justify-between">
            <div>
                <div class="mb-2 h-5 w-36 rounded-md bg-gray-200"></div>
                <div class="h-3 w-56 max-w-full rounded-md bg-gray-100"></div>
            </div>
            <div class="h-9 w-9 rounded-full bg-gray-200"></div>
        </div>

        <div v-if="variant === 'cards'" class="mt-5 grid grid-cols-2 gap-4 lg:grid-cols-4">
            <div v-for="card in 4" :key="card"
                class="h-28 rounded-xl border border-gray-100 bg-white p-4">
                <div class="h-10 w-10 rounded-lg bg-gray-200"></div>
                <div class="mt-4 h-4 w-20 rounded-md bg-gray-200"></div>
                <div class="mt-2 h-6 w-14 rounded-md bg-gray-100"></div>
            </div>
        </div>

        <div v-else-if="variant === 'grid'" class="mt-5 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <div v-for="card in 6" :key="card"
                class="h-44 rounded-xl border border-gray-100 bg-white p-4">
                <div class="h-12 w-12 rounded-lg bg-gray-200"></div>
                <div class="mt-4 h-4 w-3/4 rounded-md bg-gray-200"></div>
                <div class="mt-2 h-3 w-1/2 rounded-md bg-gray-100"></div>
                <div class="mt-6 h-9 w-full rounded-lg bg-gray-100"></div>
            </div>
        </div>

        <div v-else-if="variant === 'list'" class="mt-5 overflow-hidden rounded-xl border border-gray-100 bg-white">
            <div v-for="row in 6" :key="row"
                class="flex items-center gap-4 border-b border-gray-100 p-4 last:border-b-0">
                <div class="h-10 w-10 shrink-0 rounded-xl bg-gray-200"></div>
                <div class="flex-1">
                    <div class="h-4 w-2/5 rounded-md bg-gray-200"></div>
                    <div class="mt-2 h-3 w-3/4 rounded-md bg-gray-100"></div>
                </div>
                <div class="h-3 w-20 rounded-md bg-gray-100"></div>
            </div>
        </div>

        <div v-else class="mt-5 overflow-hidden rounded-xl border border-gray-100 bg-white">
            <div class="flex gap-4 bg-blue-700 p-4">
                <div v-for="column in 6" :key="column" class="h-3 flex-1 rounded-md bg-blue-500/60"></div>
            </div>
            <div v-for="row in 7" :key="row"
                class="flex gap-4 border-b border-gray-100 p-4 last:border-b-0">
                <div v-for="column in 6" :key="column"
                    :class="column === 1 ? 'w-1/5' : 'flex-1'"
                    class="h-4 rounded-md bg-gray-100"></div>
            </div>
        </div>
    </section>
</template>
