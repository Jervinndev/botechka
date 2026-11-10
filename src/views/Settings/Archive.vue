<script setup>
import { computed, onMounted, ref } from 'vue'
import { Archive, Search, Building2, Pill, User, RotateCcw, Trash } from '@lucide/vue'
import { getArchivedRecords, permanentlyDeleteSupplier, setRecordArchived } from '../../services/Archive'

const records = ref([])
const searchQuery = ref('')
const selectedType = ref('All')
const isLoading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

const filteredRecords = computed(() => {
    const query = searchQuery.value.trim().toLowerCase()
    return records.value.filter((record) => {
        const typeMatches = selectedType.value === 'All' || record.type === selectedType.value
        const queryMatches = !query || `${record.name} ${record.code} ${record.type}`.toLowerCase().includes(query)
        return typeMatches && queryMatches
    })
})

async function loadArchive() {
    isLoading.value = true
    errorMessage.value = ''
    try {
        records.value = await getArchivedRecords()
    } catch (error) {
        console.error('Unable to load archived records:', error)
        errorMessage.value = error.message || 'Unable to load archive records.'
    } finally {
        isLoading.value = false
    }
}

function getRecordIcon(type) {
    if (type === 'Medicines') return Pill
    if (type === 'Beneficiaries') return User
    return Building2
}

async function restoreRecord(record) {
    errorMessage.value = ''
    successMessage.value = ''
    try {
        await setRecordArchived(record.type, record.id, false)
        successMessage.value = `${record.name} was restored.`
        await loadArchive()
    } catch (error) {
        console.error('Unable to restore archived record:', error)
        errorMessage.value = error.message || 'Unable to restore this record.'
    }
}

async function permanentlyDelete(record) {
    if (record.type !== 'Suppliers') return
    if (!window.confirm(`Permanently delete ${record.name}? This cannot be undone.`)) return

    errorMessage.value = ''
    successMessage.value = ''
    try {
        await permanentlyDeleteSupplier(record.id)
        successMessage.value = `${record.name} was permanently deleted.`
        await loadArchive()
    } catch (error) {
        console.error('Unable to permanently delete supplier:', error)
        errorMessage.value = error.message || 'Unable to delete this supplier.'
    }
}

onMounted(loadArchive)
</script>

<template>
    <div class="h-fit font-sans text-slate-900">
        <header class="mb-4">
            <h1 class="flex items-center gap-2 text-lg font-bold"><Archive :size="20" /> Archive Records</h1>
        </header>

        <div class="relative mb-4 max-w-xl">
            <Search :size="16" class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
            <input v-model="searchQuery" type="search" placeholder="Search archived record..."
                class="w-full rounded-lg border border-slate-200 bg-white py-2.5 pl-11 pr-4 text-sm outline-none placeholder:text-slate-400 focus:border-blue-500">
        </div>

        <div class="mb-4 flex flex-wrap gap-2">
            <button v-for="type in ['All', 'Medicines', 'Beneficiaries', 'Suppliers']" :key="type"
                type="button" @click="selectedType = type"
                :class="selectedType === type
                    ? 'bg-blue-600 text-white'
                    : 'border border-slate-200 bg-white text-slate-600 hover:border-blue-300 hover:text-blue-600'"
                class="rounded-full px-4 py-1.5 text-xs font-medium">
                {{ type }}
            </button>
        </div>

        <p v-if="successMessage" role="status" class="mb-3 rounded-lg bg-emerald-50 p-3 text-sm text-emerald-700">{{ successMessage }}</p>
        <p v-if="errorMessage" role="alert" class="mb-3 rounded-lg bg-red-50 p-3 text-sm text-red-700">{{ errorMessage }}</p>

        <section class="overflow-hidden rounded-2xl border border-slate-200 bg-white">
            <p v-if="isLoading" class="px-6 py-10 text-center text-sm text-slate-500">Loading archive...</p>
            <p v-else-if="!filteredRecords.length" class="px-6 py-10 text-center text-sm text-slate-500">
                No archived {{ selectedType === 'All' ? 'records' : selectedType.toLowerCase() }} found.
            </p>
            <ul v-else class="divide-y divide-slate-100">
                <li v-for="record in filteredRecords" :key="`${record.type}-${record.id}`"
                    class="flex flex-wrap items-center justify-between gap-4 px-5 py-4 hover:bg-slate-50">
                    <div class="flex items-center gap-4">
                        <span class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-slate-100 text-slate-600">
                            <component :is="getRecordIcon(record.type)" :size="18" />
                        </span>
                        <div>
                            <p class="text-sm font-bold">{{ record.name }}
                                <span class="ml-1 text-xs font-normal text-slate-400">#{{ record.code }}</span>
                            </p>
                            <p class="text-xs text-slate-500">
                                {{ record.type }} · Archived {{ new Date(record.archivedAt).toLocaleDateString() }}
                            </p>
                        </div>
                    </div>
                    <div class="flex gap-2">
                        <button type="button" @click="restoreRecord(record)"
                            class="flex items-center gap-2 rounded-lg border border-slate-200 px-4 py-2 text-xs font-semibold hover:bg-slate-50">
                            <RotateCcw :size="14" /> Restore
                        </button>
                        <button v-if="record.type === 'Suppliers'" type="button" @click="permanentlyDelete(record)"
                            class="flex items-center gap-2 rounded-lg border border-red-200 px-4 py-2 text-xs font-semibold text-red-600 hover:bg-red-50">
                            <Trash :size="14" /> Delete permanently
                        </button>
                    </div>
                </li>
            </ul>
        </section>
    </div>
</template>
