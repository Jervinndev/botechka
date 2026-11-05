<script setup>
import { computed, onMounted, ref } from 'vue'
import { Pencil, Trash, Eye, RotateCcw } from '@lucide/vue'
import Addnewbeneficiary from '../../components/modals/AddNewBeneficiary.vue'
import { getBeneficiaries } from '../../services/Beneficiaries'

const isModalOpen = ref(false)
const beneficiaries = ref([])
const searchQuery = ref('')
const selectedType = ref('All')
const isLoading = ref(false)
const errorMessage = ref('')

const filteredBeneficiaries = computed(() => {
    const query = searchQuery.value.trim().toLowerCase()

    return beneficiaries.value.filter((beneficiary) => {
        const matchesSearch = !query || [
            beneficiary.beneficiary_code,
            beneficiary.first_name,
            beneficiary.middle_name,
            beneficiary.last_name,
            beneficiary.suffix,
            beneficiary.barangay,
            beneficiary.status,
            beneficiary.eligibility,
            beneficiary.beneficiary_type
        ].some((value) => value?.toLowerCase().includes(query))
        const matchesType = selectedType.value === 'All'
            || beneficiary.beneficiary_type?.toLowerCase() === selectedType.value.toLowerCase()

        return matchesSearch && matchesType
    })
})

async function fetchBeneficiaries() {
    isLoading.value = true
    errorMessage.value = ''

    const result = await getBeneficiaries()
    if (result.error) {
        errorMessage.value = 'Hindi ma-load ang beneficiaries. Subukan ulit.'
        isLoading.value = false
        return
    }

    beneficiaries.value = result.data || []
    isLoading.value = false
}

function getFullName(beneficiary) {
    return [
        beneficiary.first_name,
        beneficiary.middle_name,
        beneficiary.last_name,
        beneficiary.suffix
    ].filter(Boolean).join(' ')
}

function getAge(birthDate) {
    if (!birthDate) return '—'
    const today = new Date()
    const [year, month, day] = birthDate.slice(0, 10).split('-').map(Number)
    const birth = new Date(year, month - 1, day)
    if (Number.isNaN(birth.getTime()) || birth > today) return '—'
    let age = today.getFullYear() - birth.getFullYear()
    const hasHadBirthday = today.getMonth() > birth.getMonth()
        || (today.getMonth() === birth.getMonth() && today.getDate() >= birth.getDate())
    if (!hasHadBirthday) age -= 1
    return age >= 0 ? age : '—'
}

function formatDate(date) {
    if (!date) return '—'
    return new Date(`${date}T00:00:00`).toLocaleDateString()
}

onMounted(fetchBeneficiaries)
</script>

<template>
    <section class="w-full">
        <div>
            <h1 class="font-inter font-bold text-[#404040] text-lg">Beneficiaries</h1>
            <p class="text-sm text-[#808080]">Manage your beneficiary information</p>
        </div>
        <div class="mt-4">
            <div class="bg-white p-2 rounded-md 2xl:flex grid w-full gap-2 items-center justify-between">
                <input v-model="searchQuery" type="search" placeholder="Search beneficiaries..."
                    class="p-2 bg-gray-100 2xl:max-w-5xl max-w-full w-full rounded-md">
                <div class="flex gap-2 font-inter">
                    <button @click="isModalOpen = true"
                        class="flex items-center justify-center bg-blue-700 text-white p-2 px-4 gap-2 rounded-md hover:bg-blue-800 transition">
                        <span class="2xl:text-md text-sm">Add New Beneficiary</span>
                    </button>
                </div>
            </div>
        </div>
        <div class="w-full rounded-xl mt-4">
            <div class="mb-3 flex flex-wrap items-center gap-2">
                <button v-for="type in ['All', 'PWD', 'Regular', 'Senior']" :key="type"
                    type="button" @click="selectedType = type"
                    :class="selectedType === type
                        ? 'border-[#2638ff] bg-blue-700 text-white'
                        : 'border-gray-200 bg-white text-gray-500 hover:bg-gray-100'"
                    class="rounded-full border px-4 py-1.5 text-sm transition">
                    {{ type }}
                </button>
                <span class="ml-auto text-sm text-gray-500">{{ filteredBeneficiaries.length }} Beneficiaries</span>
                <button type="button" @click="fetchBeneficiaries" :disabled="isLoading"
                    aria-label="Reload beneficiaries" title="Reload beneficiaries"
                    class="flex h-9 w-9 items-center justify-center rounded-full border border-gray-200 bg-white text-gray-500 transition hover:bg-gray-100 disabled:opacity-50">
                    <RotateCcw :size="16" :class="{ 'animate-spin': isLoading }" />
                </button>
            </div>
            <div class="w-full overflow-x-auto rounded-xl border border-gray-100 bg-white">
                <table class="w-full min-w-[1000px] border-collapse text-left">
                    <thead class="bg-blue-700 text-white">
                        <tr>
                            <th class="p-3 font-semibold text-gray-50">Beneficiary Name</th>
                            <th class="p-3 font-semibold text-gray-50">ID</th>
                            <th class="p-3 font-semibold text-gray-50">Barangay</th>
                            <th class="p-3 font-semibold text-gray-50">Beneficiary Type</th>
                            <th class="p-3 font-semibold text-gray-50">Age</th>
                            <th class="p-3 font-semibold text-gray-50">Registered</th>
                            <th class="p-3 font-semibold text-gray-50">Eligibility</th>
                            <th class="p-3 font-semibold text-gray-50">Status</th>
                            <th class="p-3 font-semibold text-gray-50">Action</th>
                        </tr>
                    </thead>

                    <tbody class="divide-y divide-gray-100">
                        <tr v-if="isLoading">
                            <td colspan="9" class="p-6 text-center text-sm text-gray-500">Loading beneficiaries...</td>
                        </tr>
                        <tr v-else-if="errorMessage">
                            <td colspan="9" class="p-6 text-center text-sm text-red-600">{{ errorMessage }}</td>
                        </tr>
                        <tr v-else-if="filteredBeneficiaries.length === 0">
                            <td colspan="9" class="p-6 text-center text-sm text-gray-500">
                                {{ searchQuery ? 'No matching beneficiaries found.' : 'No beneficiaries yet.' }}
                            </td>
                        </tr>
                        <tr v-for="beneficiary in filteredBeneficiaries" :key="beneficiary.beneficiary_id"
                            class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
                            <td class="p-3 text-sm font-medium text-gray-700">{{ getFullName(beneficiary) }}</td>
                            <td class="p-3 text-sm text-gray-500">{{ beneficiary.beneficiary_code }}</td>
                            <td class="p-3 text-sm text-gray-600">{{ beneficiary.barangay || '—' }}</td>
                            <td class="p-3 text-sm text-gray-600">{{ beneficiary.beneficiary_type || '—' }}</td>
                            <td class="p-3 text-sm text-gray-600">{{ getAge(beneficiary.birth_date) }}</td>
                            <td class="whitespace-nowrap p-3 text-sm text-gray-500">{{ formatDate(beneficiary.registration_date) }}</td>
                            <td class="p-3">
                                <span class="inline-flex whitespace-nowrap rounded-full bg-green-100 px-2 py-1 text-xs font-medium text-green-700">
                                    {{ beneficiary.eligibility || '—' }}
                                </span>
                            </td>
                            <td class="p-3 text-sm text-gray-600">{{ beneficiary.status || '—' }}</td>
                            <td class="p-3">
                                <div class="flex items-center gap-2">
                                <button title="View"
                                    class="rounded-lg border border-gray-300 p-1.5 text-gray-500 transition hover:bg-blue-50">
                                    <Pencil size="18" />
                                </button>
                                <button title="Edit"
                                    class="rounded-lg border border-gray-300 p-1.5 text-gray-500 transition hover:bg-amber-50">
                                    <Trash size="18" />
                                </button>
                                <button title="Archive"
                                    class="rounded-lg border border-gray-300 p-1.5 text-gray-500 transition hover:bg-gray-100">
                                    <Eye size="18" />
                                </button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="mt-4 rounded-lg bg-white px-3 py-3">
            <p class="text-[11px] text-gray-500">
                Showing <span class="font-semibold text-gray-700">{{ filteredBeneficiaries.length }}</span>
                of <span class="font-semibold text-gray-700">{{ beneficiaries.length }}</span> Beneficiaries
            </p>
        </div>
    </section>

    <Addnewbeneficiary :IsOpen="isModalOpen" @close="isModalOpen = false" @saved="fetchBeneficiaries" />
</template>