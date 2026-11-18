<script setup>
import { ChevronsRight, ShieldCheck, BookPlus, AlignVerticalSpaceAround, TriangleAlert, Plus } from '@lucide/vue'
import BeneficiaryTopActions from '../../components/beneficiary/BeneficiaryTopActions.vue'
</script>


<template>
    <div>
        <div class="flex items-center justify-between gap-3">
            <div>
                <h1 class="font-inter font-bold text-[#404040] text-lg">My Dashboard</h1>
                <p class="text-sm text-[#808080]">Hello po! Jervin Kamusta!</p>
            </div>
            <div>
                <BeneficiaryTopActions />
            </div>
        </div>
    </div>
    <div class="grid grid-cols-2 md:grid-cols-2 lg:grid-cols-4 gap-4 mt-4">
        <div class="flex justify-between items-center bg-white p-4 text-black rounded-xl">
            <div class="flex flex-col items-start">
                <p class="2xl:text-sm text-xs font-medium">My Request</p>
                <h1 class="2xl:text-2xl text-md font-bold text-gray-700">5</h1>
            </div>
            <div class="w-fit h-fit p-2 bg-blue-100/70 rounded-lg">
                <TriangleAlert size="22" class="text-blue-700" />
            </div>
        </div>
        <div class="flex justify-between items-center bg-white p-4 text-black rounded-xl">
            <div class="flex flex-col items-start">
                <p class="2xl:text-sm text-xs font-medium">Available Medicines</p>
                <h1 class="2xl:text-2xl text-md font-bold text-gray-700">2,000</h1>
            </div>
            <div class="w-fit h-fit p-2 bg-blue-100/70 rounded-lg">
                <BookPlus size="22" class="text-blue-700" />
            </div>
        </div>
        <div class="flex justify-between items-center bg-white p-4 text-black rounded-xl">
            <div class="flex flex-col items-start">
                <p class="2xl:text-sm text-xs font-medium">Next Dispensing Date</p>
                <h1 class="2xl:text-2xl text-md font-bold text-gray-700">24 days left</h1>
            </div>
            <div class="w-fit h-fit p-2 bg-blue-100/70 rounded-lg">
                <AlignVerticalSpaceAround size="22" class="text-blue-700" />
            </div>
        </div>
        <div class="flex justify-between items-center bg-white p-4 text-black rounded-xl">
            <div class="flex flex-col items-start">
                <p class="2xl:text-sm text-xs font-medium">Your Status</p>
                <h1 class="2xl:text-2xl text-md font-bold text-gray-700">Not Eligible</h1>
            </div>
            <div class="w-fit h-fit p-2 bg-blue-100/70 rounded-lg">
                <TriangleAlert size="22" class="text-blue-700" />
            </div>
        </div>
    </div>


    <!-- Table -->
    <div class="mt-6 font-inter text-gray-800 bg-white p-4 rounded-lg">
        <div class="flex items-center gap-3 mb-4">
            <div>
                <h1 class="2xl:text-xl text-md font-bold text-black/80 tracking-tight">Medicine Release History</h1>
                <p class="text-xs text-gray-400 mt-0.5">View Your All History</p>
            </div>
        </div>

        <!-- Filters & Search Bar Row -->
        <div class="flex justify-between items-stretch md:items-center gap-4 mb-4">

            <!-- Search Input -->
            <div class="flex items-center gap-2 w-full md:w-auto">
                <div class="relative w-full md:w-96">
                    <svg xmlns="http://www.w3.org/2000/svg"
                        class="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" fill="none"
                        viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                    <input type="text" placeholder="Search medicines..."
                        class="w-full bg-white text-xs text-gray-700 placeholder-gray-400 pl-10 pr-4 py-3 rounded-lg border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500" />

                </div>
            </div>
            <button class="flex item-center justify-center w-12 rounded-sm p-2 bg-blue-700 text-white">
                <Plus />
            </button>
        </div>

        <!-- Table Container -->
        <div class="bg-white rounded-lg border border-black/5 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-blue-700 text-white text-xs font-semibold tracking-wider uppercase">
                            <th class="py-3.5 px-4">Transaction #</th>
                            <th class="py-3.5 px-3">Date & Time</th>
                            <th class="py-3.5 px-3">Medicine</th>
                            <th class="py-3.5 px-3">Quantity</th>
                            <th class="py-3.5 px-3">Purpose</th>
                            <th class="py-3.5 px-3">Dispense By</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100 text-xs">
                        <tr class="hover:bg-gray-50/50 transition">
                            <td class="py-4 px-6 text-sm font-semibold text-gray-900">DSP-0001</td>
                            <td class="py-4 px-6 text-sm text-gray-500">Sep 27, 2026 – <br>8:15 AM</td>
                            <td class="py-4 px-6">
                                <div class="flex items-center justify-between pr-6">
                                    <div>
                                        <span class="font-bold text-sm text-gray-900">Paracetamol</span>
                                        <p class="text-xs text-gray-400">500 mg</p>
                                    </div>
                                </div>
                            </td>
                            <td class="py-4 px-6 font-medium text-sm text-gray-800">60 pcs</td>
                            <td class="py-4 px-6 text-sm text-gray-700">Fever</td>
                            <td class="py-4 px-6 text-sm font-medium text-gray-800">Mark De Jesus</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</template>