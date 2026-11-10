<script setup>
import { computed, onMounted, ref } from 'vue'
import { Eye, SquarePen, Archive, LayoutGrid, List, X } from '@lucide/vue'
import { archiveSupplier, getSuppliers, saveSupplier } from '../../services/Suppliers'

const suppliers = ref([])
const searchQuery = ref('')
const isLoading = ref(false)
const isSaving = ref(false)
const errorMessage = ref('')
const isModalOpen = ref(false)
const viewedSupplier = ref(null)
const supplierForm = ref(createEmptySupplier())

function createEmptySupplier() {
    return {
        id: null,
        supplier_code: '',
        company_name: '',
        contact_person: '',
        contact_number: '',
        email: '',
        location: '',
        supplier_type: 'Private'
    }
}

const filteredSuppliers = computed(() => {
    const query = searchQuery.value.trim().toLowerCase()
    if (!query) return suppliers.value
    return suppliers.value.filter((supplier) => [
        supplier.supplier_code,
        supplier.company_name,
        supplier.contact_person,
        supplier.contact_number,
        supplier.email,
        supplier.location,
        supplier.supplier_type
    ].some((value) => String(value || '').toLowerCase().includes(query)))
})

async function loadSuppliers() {
    isLoading.value = true
    errorMessage.value = ''
    try {
        suppliers.value = await getSuppliers()
    } catch (error) {
        console.error('Unable to load suppliers:', error)
        errorMessage.value = error.message || 'Unable to load suppliers.'
    } finally {
        isLoading.value = false
    }
}

function openCreateModal() {
    supplierForm.value = createEmptySupplier()
    errorMessage.value = ''
    isModalOpen.value = true
}

function openEditModal(supplier) {
    supplierForm.value = { ...supplier }
    errorMessage.value = ''
    isModalOpen.value = true
}

async function submitSupplier() {
    if (isSaving.value) return
    isSaving.value = true
    errorMessage.value = ''
    try {
        await saveSupplier(supplierForm.value)
        isModalOpen.value = false
        await loadSuppliers()
    } catch (error) {
        console.error('Unable to save supplier:', error)
        errorMessage.value = error.message || 'Unable to save supplier.'
    } finally {
        isSaving.value = false
    }
}

async function handleArchive(supplier) {
    if (!window.confirm(`Archive ${supplier.company_name}?`)) return
    try {
        await archiveSupplier(supplier.id)
        await loadSuppliers()
    } catch (error) {
        console.error('Unable to archive supplier:', error)
        errorMessage.value = error.message || 'Unable to archive supplier.'
    }
}
</script>

<template>
    <div class="h-fit font-sans text-slate-900">
        <header class="mb-4">
            <h1 class="text-lg font-bold">Supplier</h1>
            <p class="text-sm text-slate-500">Manage your medicine resources</p>
        </header>

        <section class="mb-3 flex flex-wrap items-center gap-2 rounded-md bg-white p-2">
            <div class="min-w-[240px] flex-1">
                <input v-model="searchQuery" type="search" placeholder="Search for Supplier Name or ID..."
                    class="settings-search w-full rounded-md bg-gray-100 p-2 text-sm outline-none placeholder:text-gray-400">
            </div>
            <button type="button" @click="openCreateModal"
                class="rounded-md bg-blue-700 px-4 py-2 text-sm font-medium text-white transition hover:bg-blue-800">
                Add Suppliers
            </button>
            <div class="flex items-center gap-1">
                <button type="button" class="flex h-9 w-9 items-center justify-center rounded-md text-slate-500 transition hover:bg-gray-100" aria-label="Grid view">
                    <LayoutGrid :size="16" />
                </button>
                <button type="button" class="flex h-9 w-9 items-center justify-center rounded-md text-slate-500 transition hover:bg-gray-100" aria-label="List view">
                    <List :size="16" />
                </button>
            </div>
        </section>

        <p v-if="errorMessage && !isModalOpen" role="alert" class="mb-3 rounded-lg bg-red-50 p-3 text-sm text-red-700">{{ errorMessage }}</p>

        <section class="overflow-x-auto rounded-lg bg-white shadow-sm">
            <table class="w-full min-w-[900px] text-left text-sm">
                <thead>
                    <tr class="bg-blue-600 text-xs font-semibold text-white">
                        <th class="px-5 py-4">Company</th>
                        <th class="px-5 py-4">ID</th>
                        <th class="px-5 py-4">Contact Person</th>
                        <th class="px-5 py-4">Contact Number</th>
                        <th class="px-5 py-4">Email</th>
                        <th class="px-5 py-4">Location</th>
                        <th class="px-5 py-4">Type</th>
                        <th class="px-5 py-4">Action</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                    <tr v-if="isLoading || !filteredSuppliers.length">
                        <td colspan="8" class="px-5 py-8 text-center text-sm text-slate-500">
                            {{ isLoading ? 'Loading suppliers...' : 'No suppliers found.' }}
                        </td>
                    </tr>
                    <tr v-for="supplier in filteredSuppliers" :key="supplier.id" class="hover:bg-slate-50">
                        <td class="px-5 py-4 text-slate-700">{{ supplier.company_name }}</td>
                        <td class="px-5 py-4 text-slate-700">{{ supplier.supplier_code }}</td>
                        <td class="px-5 py-4 text-slate-700">{{ supplier.contact_person || '—' }}</td>
                        <td class="px-5 py-4 text-slate-700">{{ supplier.contact_number || '—' }}</td>
                        <td class="px-5 py-4 text-slate-700">{{ supplier.email || '—' }}</td>
                        <td class="px-5 py-4 text-slate-700">{{ supplier.location || '—' }}</td>
                        <td class="px-5 py-4 text-slate-700">{{ supplier.supplier_type }}</td>
                        <td class="px-5 py-4">
                            <div class="flex items-center gap-2">
                                <button type="button" @click="viewedSupplier = supplier"
                                    class="flex h-8 w-8 items-center justify-center rounded-lg text-slate-600 hover:bg-slate-100" aria-label="View supplier">
                                    <Eye :size="17" />
                                </button>
                                <button type="button" @click="openEditModal(supplier)"
                                    class="flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-100" aria-label="Edit supplier">
                                    <SquarePen :size="15" />
                                </button>
                                <button type="button" @click="handleArchive(supplier)"
                                    class="flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-100" aria-label="Archive supplier">
                                    <Archive :size="15" />
                                </button>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </section>

        <div v-if="isModalOpen" class="fixed inset-0 z-[70] flex items-center justify-center bg-black/40 p-4">
            <form @submit.prevent="submitSupplier" class="max-h-[90vh] w-full max-w-xl overflow-y-auto rounded-xl bg-white p-6 shadow-xl">
                <div class="mb-5 flex items-start justify-between">
                    <div>
                        <h2 class="text-lg font-bold">{{ supplierForm.id ? 'Edit Supplier' : 'Add Supplier' }}</h2>
                        <p class="text-sm text-slate-500">Supplier information</p>
                    </div>
                    <button type="button" @click="isModalOpen = false" aria-label="Close modal" class="rounded-lg p-2 hover:bg-slate-100"><X :size="18" /></button>
                </div>
                <p v-if="errorMessage" role="alert" class="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">{{ errorMessage }}</p>
                <div class="grid gap-4 sm:grid-cols-2">
                    <label class="text-sm font-medium">Company name *
                        <input v-model.trim="supplierForm.company_name" required class="mt-1 w-full rounded-lg border border-slate-200 p-2.5">
                    </label>
                    <label class="text-sm font-medium">Supplier ID *
                        <input v-model.trim="supplierForm.supplier_code" required class="mt-1 w-full rounded-lg border border-slate-200 p-2.5">
                    </label>
                    <label class="text-sm font-medium">Contact person
                        <input v-model.trim="supplierForm.contact_person" class="mt-1 w-full rounded-lg border border-slate-200 p-2.5">
                    </label>
                    <label class="text-sm font-medium">Contact number
                        <input v-model.trim="supplierForm.contact_number" type="tel" class="mt-1 w-full rounded-lg border border-slate-200 p-2.5">
                    </label>
                    <label class="text-sm font-medium">Email
                        <input v-model.trim="supplierForm.email" type="email" class="mt-1 w-full rounded-lg border border-slate-200 p-2.5">
                    </label>
                    <label class="text-sm font-medium">Location
                        <input v-model.trim="supplierForm.location" class="mt-1 w-full rounded-lg border border-slate-200 p-2.5">
                    </label>
                    <label class="text-sm font-medium">Type
                        <select v-model="supplierForm.supplier_type" class="mt-1 w-full rounded-lg border border-slate-200 p-2.5">
                            <option>Private</option>
                            <option>Government</option>
                        </select>
                    </label>
                </div>
                <div class="mt-6 flex justify-end gap-3">
                    <button type="button" :disabled="isSaving" @click="isModalOpen = false"
                        class="rounded-lg border border-slate-200 px-4 py-2 text-sm text-slate-600">Cancel</button>
                    <button type="submit" :disabled="isSaving"
                        class="rounded-lg bg-blue-700 px-4 py-2 text-sm font-semibold text-white hover:bg-blue-800 disabled:opacity-50">
                        {{ isSaving ? 'Saving...' : 'Save Supplier' }}
                    </button>
                </div>
            </form>
        </div>

        <div v-if="viewedSupplier" class="fixed inset-0 z-[70] flex items-center justify-center bg-black/40 p-4">
            <section role="dialog" aria-modal="true" class="w-full max-w-lg rounded-xl bg-white p-6 shadow-xl">
                <div class="flex items-start justify-between">
                    <div><h2 class="text-lg font-bold">{{ viewedSupplier.company_name }}</h2><p class="text-sm text-slate-500">{{ viewedSupplier.supplier_code }}</p></div>
                    <button type="button" @click="viewedSupplier = null" aria-label="Close details" class="rounded-lg p-2 hover:bg-slate-100"><X :size="18" /></button>
                </div>
                <dl class="mt-5 grid gap-3 sm:grid-cols-2">
                    <div><dt class="text-xs text-slate-400">Contact person</dt><dd class="text-sm">{{ viewedSupplier.contact_person || '—' }}</dd></div>
                    <div><dt class="text-xs text-slate-400">Phone</dt><dd class="text-sm">{{ viewedSupplier.contact_number || '—' }}</dd></div>
                    <div><dt class="text-xs text-slate-400">Email</dt><dd class="text-sm">{{ viewedSupplier.email || '—' }}</dd></div>
                    <div><dt class="text-xs text-slate-400">Location</dt><dd class="text-sm">{{ viewedSupplier.location || '—' }}</dd></div>
                    <div><dt class="text-xs text-slate-400">Type</dt><dd class="text-sm">{{ viewedSupplier.supplier_type }}</dd></div>
                </dl>
            </section>
        </div>
    </div>
</template>
