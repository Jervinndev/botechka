<script setup>
import {
    Bell, ChartColumn, Printer, Download, Search,
} from '@lucide/vue'
</script>



<template>

    <div class="font-inter text-slate-900">

        <!-- Page header -->

        <header class="mb-4 flex items-center justify-between">

            <div>

                <h1 class="font-inter text-lg font-bold text-[#404040]">Reports</h1>
                <p class="text-sm text-[#808080]">Overview of dashboard analytics</p>

            </div>

            <div class="flex items-center gap-4">

                <Bell class="text-blue-700" />
                <div class="flex items-center justify-center gap-1 rounded-full border border-gray-500/40 p-1">
                    <img src="/src/assets/download (12).jpg" alt="" class="w-10 rounded-full">
                </div>

            </div>

        </header>



        <!-- Report tabs (active = blue) -->

        <nav class="mb-4 inline-flex flex-wrap items-center gap-1 rounded-md bg-white p-2">
            <button class="rounded-md bg-blue-700 px-5 py-2.5 text-sm font-medium text-white">Category</button>
            <button class="rounded-md px-5 py-2.5 text-sm text-slate-700 transition hover:bg-slate-100">Inventory</button>
            <button class="rounded-md px-5 py-2.5 text-sm text-slate-700 transition hover:bg-slate-100">Dispensing</button>
            <button class="rounded-md px-5 py-2.5 text-sm text-slate-700 transition hover:bg-slate-100">Beneficiary</button>
            <button class="rounded-md px-5 py-2.5 text-sm text-slate-700 transition hover:bg-slate-100">Supplier</button>
            <button class="rounded-md px-5 py-2.5 text-sm text-slate-700 transition hover:bg-slate-100">Audit Trail</button>
            <button class="rounded-md px-5 py-2.5 text-sm text-slate-700 transition hover:bg-slate-100">Return</button>
        </nav>

        <section class="rounded-xl border border-gray-100 bg-white p-5">
            <div class="mb-4 flex flex-wrap items-start justify-between gap-4">
                <div class="flex items-center gap-3">
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-100 text-blue-700">
                        <ChartColumn :size="18" />
                    </span>
                    <div>
                        <h2 class="font-bold text-slate-900">Categories Report</h2>
                        <p class="text-xs text-slate-500">View All Current Categories</p>
                    </div>
                </div>
                <div class="flex gap-2">
                    <button
                        class="flex items-center gap-2 rounded-md bg-blue-700 px-4 py-2 text-sm font-medium text-white transition hover:bg-blue-800">
                        <Printer :size="15" /> Print Report
                    </button>
                    <button
                        class="flex items-center gap-2 rounded-md bg-blue-700 px-4 py-2 text-sm font-medium text-white transition hover:bg-blue-800">
                        <Download :size="15" /> Export Excel
                    </button>
                </div>
            </div>

            <div class="mb-4 flex flex-wrap items-center gap-3 text-sm text-slate-600">
                <label class="flex items-center gap-2 rounded-md border border-gray-200 bg-gray-50 px-3 py-2">
                    <select class="bg-transparent outline-none">
                        <option>All Categories</option>
                    </select>
                </label>
                <label class="flex items-center gap-2 rounded-md border border-gray-200 bg-gray-50 px-3 py-2">
                    <select class="bg-transparent outline-none">
                        <option>Sort (A-Z)</option>
                        <option>Sort (Z-A)</option>
                    </select>
                </label>
                <label class="flex items-center gap-2 rounded-md border border-gray-200 bg-gray-50 px-3 py-2">
                    <select class="bg-transparent outline-none">
                        <option>Healthy</option>
                        <option>Low</option>
                    </select>
                </label>
                <label class="flex items-center gap-2 rounded-md border border-gray-200 bg-gray-50 px-3 py-2">
                    <select class="bg-transparent outline-none">
                        <option>Mar 1, 2025 - Mar 31, 2025</option>
                    </select>
                </label>
                <div class="relative ml-auto w-64">
                    <Search :size="14" class="absolute left-3 top-1/2 -translate-y-1/2" />
                    <input type="text" placeholder="Search medicines..."
                        class="w-full rounded-md bg-gray-100 py-2 pl-9 pr-3 text-sm outline-none placeholder:text-gray-500 focus:ring-2 focus:ring-blue-200" />
                </div>
            </div>

            <div class="overflow-x-auto rounded-xl border border-slate-200">
                <table class="w-full min-w-[800px] text-left text-xs">
                    <thead>
                        <tr class="bg-blue-700 font-semibold text-white">
                            <th class="px-4 py-3.5">ID</th>
                            <th class="px-4 py-3.5">Category Name</th>
                            <th class="px-4 py-3.5">No. of Medicines</th>
                            <th class="px-4 py-3.5">Total Stock</th>
                            <th class="px-4 py-3.5">Low Stock</th>
                            <th class="px-4 py-3.5">Out of Stock</th>
                            <th class="px-4 py-3.5">Status</th>
                            <th class="px-4 py-3.5">Expired</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        <tr class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
                            <td class="px-4 py-3.5 text-slate-700">005</td>
                            <td class="px-4 py-3.5 font-bold text-slate-900">Vitamins and Supplements</td>
                            <td class="px-4 py-3.5 text-slate-700">10</td>
                            <td class="px-4 py-3.5 text-slate-700">520</td>
                            <td class="px-4 py-3.5 text-slate-700">3</td>
                            <td class="px-4 py-3.5 text-slate-700">0</td>
                            <td class="px-4 py-3.5"><span
                                    class="rounded-full bg-red-50 px-2.5 py-0.5 text-xs font-semibold text-red-600">Low</span>
                            </td>
                            <td class="px-4 py-3.5 text-red-600">0</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Footer / pagination -->
            <div class="mt-4 flex items-center justify-between text-sm text-slate-500">
                <p>Showing 1 to 5 of 5 entries</p>
                <div class="flex items-center gap-2">
                    <button class="rounded-md border border-gray-200 px-3 py-1.5 transition hover:bg-gray-50">Previous</button>
                    <button class="rounded-md bg-blue-700 px-3 py-1.5 font-semibold text-white">1</button>
                    <button class="rounded-md border border-gray-200 px-3 py-1.5 transition hover:bg-gray-50">Next</button>
                </div>
            </div>
        </section>
    </div>
</template>