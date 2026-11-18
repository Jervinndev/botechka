import { computed, ref, watch } from 'vue'

export function usePagination(items, pageSize = 10) {
    const currentPage = ref(1)
    const paginatedItems = computed(() => {
        const totalPages = Math.max(1, Math.ceil(items.value.length / pageSize))
        const page = Math.min(currentPage.value, totalPages)
        const start = (page - 1) * pageSize
        return items.value.slice(start, start + pageSize)
    })

    watch(items, () => {
        currentPage.value = 1
    })

    return { currentPage, paginatedItems }
}
