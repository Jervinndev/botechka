<script setup>
import { ref } from 'vue';
import { Bell, Plus, ChevronDown, Pencil, Trash, Eye } from '@lucide/vue'
import Addnewbeneficiary from '../../components/modals/AddNewBeneficiary.vue'

const Ismodalopen = ref(false)
</script>

<template>
    <section class="w-full">
        <div>
            <h1 class="font-inter font-bold text-[#404040] text-lg">Beneficiaries</h1>
            <p class="text-sm text-[#808080]">Manage your beneficiary information</p>
        </div>
        <div class="mt-4">
            <div class="bg-white p-2 rounded-md 2xl:flex grid w-full gap-2 items-center justify-between">
                <input type="text" placeholder="Search medicines...."
                    class="p-2 bg-gray-100 2xl:max-w-5xl max-w-full w-full rounded-md">
                <div class="flex gap-2 font-inter">
                    <!-- Button para buksan ang Add Medicine Modal -->
                    <button @click="Ismodalopen = true"
                        class="flex items-center justify-center bg-blue-700 text-white p-2 px-4 gap-2 rounded-md hover:bg-blue-800 transition">
                        <span class="2xl:text-md text-sm">Add New Beneficiary</span>
                    </button>
                </div>
            </div>
        </div>
        <div class="w-full rounded-xl mt-4">
            <div class="mb-3 flex flex-wrap items-center gap-2">
                <button
                    class="rounded-full border border-[#2638ff] bg-blue-700 px-4 py-1.5 text-sm text-white transition hover:bg-blue-700">All</button>
                <button
                    class="rounded-full border border-gray-200 bg-white px-4 py-1.5 text-sm text-gray-500 transition hover:bg-gray-100">Minor</button>
                <button
                    class="rounded-full border border-gray-200 bg-white px-4 py-1.5 text-sm text-gray-500 transition hover:bg-gray-100">Senior</button>
                <button
                    class="rounded-full border border-gray-200 bg-white px-4 py-1.5 text-sm text-gray-500 transition hover:bg-gray-100">PWD</button>
                <button
                    class="rounded-full border border-gray-200 bg-white px-4 py-1.5 text-sm text-gray-500 transition hover:bg-gray-100">Indigent</button>
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
                            <th class="p-3 font-semibold text-gray-50">Last Visit</th>
                            <th class="p-3 font-semibold text-gray-50">Eligibility</th>
                            <th class="p-3 font-semibold text-gray-50">Action</th>
                        </tr>
                    </thead>

                    <tbody class="divide-y divide-gray-100">
                        <tr class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
                            <td class="p-3 text-sm font-medium text-gray-700">Juan Dela Cruz</td>
                            <td class="p-3 text-sm text-gray-500">45237645</td>
                            <td class="p-3 text-sm text-gray-600">Tagpos</td>
                            <td class="p-3 text-sm text-gray-600">Indigent</td>
                            <td class="p-3 text-sm text-gray-600">21</td>
                            <td class="whitespace-nowrap p-3 text-sm text-gray-500">
                                Aug 25, 2004</td>
                            <td class="p-3"><span
                                    class="inline-flex whitespace-nowrap rounded-full bg-green-100 px-2 py-1 text-xs font-medium text-green-700">Eligible</span>
                            </td>
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

        <div class="mt-4 flex flex-col items-center justify-between gap-3 rounded-lg bg-white px-3 py-3 sm:flex-row">
            <p class="text-[11px] text-gray-500">Showing <span class="font-semibold text-gray-700">1</span> of <span
                    class="font-semibold text-gray-700">12</span> Beneficiaries</p>
            <div class="flex items-center gap-2">
                <button aria-label="Previous page"
                    class="flex h-7 w-7 items-center justify-center rounded-md text-lg text-gray-500 transition hover:bg-gray-100">‹</button>
                <button class="h-7 w-7 rounded-md bg-[#2638ff] text-[11px] text-white">1</button>
                <button class="h-7 w-7 rounded-md text-[11px] text-gray-500 transition hover:bg-gray-100">2</button>
                <button class="h-7 w-7 rounded-md text-[11px] text-gray-500 transition hover:bg-gray-100">3</button>
                <button aria-label="Next page"
                    class="flex h-7 w-7 items-center justify-center rounded-md text-lg text-gray-500 transition hover:bg-gray-100">›</button>
            </div>
        </div>
    </section>

    <Addnewbeneficiary :IsOpen="Ismodalopen" @close="Ismodalopen = false" />
</template>