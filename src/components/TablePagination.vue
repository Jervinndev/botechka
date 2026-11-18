<script setup>
import { computed } from 'vue'

const props = defineProps({
    modelValue: {
        type: Number,
        required: true
    },
    totalItems: {
        type: Number,
        required: true
    },
    pageSize: {
        type: Number,
        default: 10
    },
    itemLabel: {
        type: String,
        default: 'entries'
    },
    ariaLabel: {
        type: String,
        default: 'Table pagination'
    }
})

const emit = defineEmits(['update:modelValue'])
const totalPages = computed(() => Math.ceil(props.totalItems / props.pageSize))
const effectivePage = computed(() => Math.max(1, Math.min(props.modelValue, totalPages.value)))
const pageNumbers = computed(() => {
    const visiblePageCount = 5
    let start = Math.max(1, effectivePage.value - 2)
    let end = Math.min(totalPages.value, start + visiblePageCount - 1)
    start = Math.max(1, end - visiblePageCount + 1)

    return Array.from({ length: end - start + 1 }, (_, index) => start + index)
})
const startItem = computed(() => (effectivePage.value - 1) * props.pageSize + 1)
const endItem = computed(() => Math.min(effectivePage.value * props.pageSize, props.totalItems))

function goToPage(page) {
    if (page < 1 || page > totalPages.value || page === props.modelValue) return
    emit('update:modelValue', page)
}
</script>

<template>
    <div v-if="totalItems > pageSize || $slots.default"
        class="mt-4 flex flex-col gap-3 text-sm text-gray-600 sm:flex-row sm:items-center sm:justify-between">
        <p v-if="totalItems > pageSize">Showing {{ startItem }}–{{ endItem }} of {{ totalItems }} {{ itemLabel }}</p>
        <nav v-if="totalItems > pageSize" class="flex flex-wrap items-center gap-1" :aria-label="ariaLabel">
            <button type="button" @click="goToPage(effectivePage - 1)" :disabled="effectivePage === 1"
                class="rounded-md border border-gray-200 bg-white px-3 py-2 transition hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50">
                Previous
            </button>
            <button v-for="page in pageNumbers" :key="page" type="button" @click="goToPage(page)"
                :aria-current="page === effectivePage ? 'page' : undefined"
                :class="page === effectivePage
                    ? 'border-blue-700 bg-blue-700 text-white'
                    : 'border-gray-200 bg-white text-gray-700 hover:bg-gray-50'"
                class="min-w-10 rounded-md border px-3 py-2 transition">
                {{ page }}
            </button>
            <button type="button" @click="goToPage(effectivePage + 1)" :disabled="effectivePage === totalPages"
                class="rounded-md border border-gray-200 bg-white px-3 py-2 transition hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-50">
                Next
            </button>
        </nav>
        <div v-if="$slots.default" class="ml-auto">
            <slot />
        </div>
    </div>
</template>
