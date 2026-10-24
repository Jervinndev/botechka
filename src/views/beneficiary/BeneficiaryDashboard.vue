<script setup>
import { ChevronsRight, ShieldCheck, BookPlus, Bell, AlignVerticalSpaceAround, TriangleAlert } from '@lucide/vue'
</script>


<template>
    <div class="flex justify-between items-center ">
        <div>
            <h1 class="font-inter font-bold text-[#404040] text-lg">My Dashboard</h1>
            <p class="text-sm text-[#808080]">Hello po! Jervin Kamusta!</p>
        </div>
        <div>
            <Bell class="text-blue-700" />
        </div>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mt-4">
        <div class="flex justify-between items-center bg-white p-4 text-black rounded-xl">
            <div class="flex flex-col items-start">
                <p class="text-sm font-medium">My Request</p>
                <h1 class="text-2xl font-bold text-gray-700">5</h1>
            </div>
            <div class="w-fit h-fit p-2 bg-blue-100/70 rounded-lg">
                <TriangleAlert size="22" class="text-blue-700" />
            </div>
        </div>
        <div class="flex justify-between items-center bg-white p-4 text-black rounded-xl">
            <div class="flex flex-col items-start">
                <p class="text-sm font-medium">Available Medicines</p>
                <h1 class="text-2xl font-bold text-gray-700">2,000</h1>
            </div>
            <div class="w-fit h-fit p-2 bg-blue-100/70 rounded-lg">
                <BookPlus size="22" class="text-blue-700" />
            </div>
        </div>
        <div class="flex justify-between items-center bg-white p-4 text-black rounded-xl">
            <div class="flex flex-col items-start">
                <p class="text-sm font-medium">Next Dispensing Date</p>
                <h1 class="text-2xl font-bold text-gray-700">24 days left</h1>
            </div>
            <div class="w-fit h-fit p-2 bg-blue-100/70 rounded-lg">
                <AlignVerticalSpaceAround size="22" class="text-blue-700" />
            </div>
        </div>
        <div class="flex justify-between items-center bg-white p-4 text-black rounded-xl">
            <div class="flex flex-col items-start">
                <p class="text-sm font-medium">Your Status</p>
                <h1 class="text-2xl font-bold text-gray-700">Not Eligible</h1>
            </div>
            <div class="w-fit h-fit p-2 bg-blue-100/70 rounded-lg">
                <TriangleAlert size="22" class="text-blue-700" />
            </div>
        </div>
    </div>


    <!-- Table -->
    <div class="mt-6 font-inter text-gray-800 bg-white p-4 rounded-lg">
        <div class="flex items-center gap-3 mb-4">
            <div class="p-2.5 bg-blue-100/70 rounded-xl text-blue-700">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                </svg>
            </div>
            <div>
                <h1 class="text-xl font-bold text-gray-900 tracking-tight">Medicine Release History</h1>
                <p class="text-xs text-gray-400 mt-0.5">View Your All History</p>
            </div>
        </div>

        <!-- Filters & Search Bar Row -->
        <div class="flex flex-col md:flex-row justify-between items-stretch md:items-center gap-4 mb-4">

            <!-- Search Input -->
            <div class="relative w-full md:w-96">
                <svg xmlns="http://www.w3.org/2000/svg"
                    class="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" fill="none"
                    viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <input type="text" placeholder="Search medicines..."
                    class="w-full bg-white text-xs text-gray-800 placeholder-gray-400 pl-10 pr-4 py-3 rounded-lg border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500" />
            </div>

            <!-- Filter Dropdown Button -->
            <div>
                <button
                    class="flex items-center gap-2 bg-white px-4 py-3 rounded-lg border border-gray-200 text-xs font-semibold text-gray-700 hover:bg-gray-50 transition">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-blue-600" fill="none"
                        viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                    </svg>
                    <span>All Medicine</span>
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-3.5 h-3.5 text-gray-400 ml-1" fill="none"
                        viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                    </svg>
                </button>
            </div>

        </div>

        <!-- Table Container -->
        <div class="bg-white rounded-lg border border-gray-200 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-blue-600 text-white text-xs font-semibold tracking-wider uppercase">
                            <th class="py-3.5 px-6">Transaction #</th>
                            <th class="py-3.5 px-6">Date & Time</th>
                            <th class="py-3.5 px-6">Medicine</th>
                            <th class="py-3.5 px-6">Quantity</th>
                            <th class="py-3.5 px-6">Purpose</th>
                            <th class="py-3.5 px-6">Dispense By</th>
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