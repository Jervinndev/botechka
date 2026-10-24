<script setup>
import { ref } from 'vue';
import Requestbeneficiarymodal from '../../components/modals/Requestbeneficiarymodal.vue';

const Ismodalopen = ref(false)
</script>

<template>
    <div class="font-inter text-gray-800">

        <!-- Top Header -->
        <div class="flex justify-between items-center mb-6">
            <div>
                <h1 class="text-lg font-bold text-gray-600 tracking-tight">Beneficiary Request Portal</h1>
                <p class="text-sm text-gray-500 mt-0.5">Submit and monitor your medicine requests easily</p>
            </div>
        </div>

        <!-- Stats / Overview Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
            <div class="bg-white p-5 rounded-2xl border border-gray-200 flex items-center justify-between">
                <div>
                    <p class="text-xs text-gray-400 font-medium">Total Requests</p>
                    <h2 class="text-2xl font-bold text-gray-900 mt-1">4</h2>
                </div>
                <div class="p-3 bg-blue-50 text-blue-600 rounded-xl">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                </div>
            </div>

            <div class="bg-white p-5 rounded-2xl border border-gray-200 flex items-center justify-between">
                <div>
                    <p class="text-xs text-gray-400 font-medium">Pending Approval</p>
                    <h2 class="text-2xl font-bold text-amber-600 mt-1">2</h2>
                </div>
                <div class="p-3 bg-amber-50 text-amber-600 rounded-xl">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                </div>
            </div>

            <div class="bg-white p-5 rounded-2xl border border-gray-200 flex items-center justify-between">
                <div>
                    <p class="text-xs text-gray-400 font-medium">Approved / Ready</p>
                    <h2 class="text-2xl font-bold text-emerald-600 mt-1">2</h2>
                </div>
                <div class="p-3 bg-emerald-50 text-emerald-600 rounded-xl">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24"
                        stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                    </svg>
                </div>
            </div>
        </div>

        <!-- Search & Filters -->
        <div class="flex flex-col md:flex-row justify-between items-stretch md:items-center gap-4 mb-4">
            <div class="relative w-full md:w-96">
                <svg xmlns="http://www.w3.org/2000/svg"
                    class="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" fill="none"
                    viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <input type="text" placeholder="Search your requests..."
                    class="w-full bg-white text-xs text-gray-800 placeholder-gray-400 pl-10 pr-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500" />
            </div>

            <div class="flex items-center gap-2">
                <button
                    class="px-3.5 py-2.5 bg-blue-50 text-blue-700 border border-blue-200 rounded-xl text-xs font-semibold">
                    All Status
                </button>
                <button
                    class="px-3.5 py-2.5 bg-white text-gray-600 border border-gray-200 rounded-xl text-xs font-semibold hover:bg-gray-50 transition">
                    Pending
                </button>
                <button
                    class="px-3.5 py-2.5 bg-white text-gray-600 border border-gray-200 rounded-xl text-xs font-semibold hover:bg-gray-50 transition">
                    Approved
                </button>
                <button @click="Ismodalopen = true"
                    class="px-4 py-2.5 bg-blue-700 text-white text-xs font-semibold rounded-lg hover:bg-blue-700 transition">
                    + Request Medicine
                </button>
            </div>
        </div>

        <!-- Requests History Table -->
        <div class="bg-white rounded-lg border border-gray-200 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-blue-700 text-white text-[11px] font-semibold tracking-wider uppercase">
                            <th class="py-3.5 px-6">Request ID</th>
                            <th class="py-3.5 px-6">Date Requested</th>
                            <th class="py-3.5 px-6">Medicine Name</th>
                            <th class="py-3.5 px-6">Quantity</th>
                            <th class="py-3.5 px-6">Purpose / Ailment</th>
                            <th class="py-3.5 px-6">Status</th>
                            <th class="py-3.5 px-6 text-right">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 text-xs">

                        <tr class="hover:bg-gray-50/50 transition">
                            <td class="py-4 px-6 font-semibold text-gray-900">REQ-2026-01</td>
                            <td class="py-4 px-6 text-gray-500">Sep 27, 2026</td>
                            <td class="py-4 px-6">
                                <span class="font-bold text-gray-900">Paracetamol</span>
                                <p class="text-[11px] text-gray-400">500mg tablet</p>
                            </td>
                            <td class="py-4 px-6 font-medium text-gray-700">20 pcs</td>
                            <td class="py-4 px-6 text-gray-600">Fever and headache</td>
                            <td class="py-4 px-6">
                                <span
                                    class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-[11px] font-semibold bg-amber-50 text-amber-700">
                                    <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
                                    Pending
                                </span>
                            </td>
                            <td class="py-4 px-6 text-right">
                                <button
                                    class="px-3 py-1.5 bg-gray-100 text-gray-600 hover:bg-gray-200 font-semibold rounded-lg transition">
                                    Cancel
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <Requestbeneficiarymodal :IsOpen="Ismodalopen" @close="Ismodalopen = false" />
</template>