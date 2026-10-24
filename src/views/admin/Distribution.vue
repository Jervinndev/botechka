<script setup>
import {
    Bell,
    Search,
    RotateCcw,
    UserRoundPlus,
    Plus,
    Minus,
    Pill,
    ClipboardList,
    PackagePlus,
    X,
    ChevronDown,
} from '@lucide/vue'
</script>

<template>
    <section class="w-full">
        <!-- HEADER -->
        <div class="flex justify-between items-center gap-4">
            <div>
                <h1 class="font-inter font-bold text-[#404040] text-lg">Distribution</h1>
                <p class="text-sm text-[#808080]">Manage your distribution channels and logistics</p>
            </div>

            <div class="flex items-center gap-4">
                <Bell class="text-blue-700" :size="20" />
                <div class="flex items-center justify-center gap-1 border border-gray-500/40 rounded-full p-1">
                    <img src="/src/assets/download (12).jpg" alt="Profile"
                        class="w-10 h-10 rounded-full object-cover" />
                </div>
            </div>
        </div>
        <div class="grid grid-cols-1 mt-4 gap-4 items-start">
            <div class="w-full grid grid-cols-2 gap-4 min-w-0">
                <div class="bg-white p-4 w-full rounded-lg border border-gray-100">
                    <div>
                        <h1 class="font-bold text-xl text-gray-800">New Distribution</h1>
                        <p class="text-sm text-gray-400 mt-1">Record medicine given to a beneficiary</p>
                    </div>
                    <div class="mt-4 p-4 border border-black/10 rounded-xl">
                        <div class="flex justify-between items-center gap-2">
                            <h2 class="text-sm font-medium text-gray-700">Beneficiary </h2>
                            <button
                                class="flex items-center gap-1.5 px-3 py-2 bg-blue-700 text-white rounded-lg hover:bg-blue-600 transition text-xs whitespace-nowrap">
                                <UserRoundPlus :size="15" />
                                Add New
                            </button>
                        </div>
                        <div class="relative mt-3">
                            <select
                                class="appearance-none w-full border border-black/10 rounded-xl p-2.5 pr-9 text-sm text-gray-600 outline-none focus:border-blue-500 bg-white">
                                <option value="">Select Beneficiary</option>
                            </select>
                            <ChevronDown :size="16"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" />
                        </div>
                    </div>
                    <div class="mt-4 p-4 border border-black/10 rounded-xl">
                        <div class="flex justify-between items-center gap-2">
                            <h2 class="text-sm font-medium text-gray-700">Purpose (Ailment)</h2>
                            <button
                                class="flex items-center gap-1.5 px-3 py-2 bg-blue-700 text-white rounded-lg hover:bg-blue-600 transition text-xs whitespace-nowrap">
                                <Plus :size="15" />
                                Add New
                            </button>
                        </div>
                        <div class="relative mt-3">
                            <select
                                class="appearance-none w-full border border-black/10 rounded-xl p-2.5 pr-9 text-sm text-gray-600 outline-none focus:border-blue-500 bg-white">
                                <option value="">Select Purpose</option>
                            </select>
                            <ChevronDown :size="16"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" />
                        </div>
                    </div>

                    <div class="mt-4 p-4 border border-black/10 rounded-xl">
                        <div class="flex justify-between items-center gap-2">
                            <h2 class="text-sm font-medium text-gray-700">Medicines</h2>
                            <button
                                class="flex items-center gap-1.5 px-3 py-2 bg-blue-700 text-white rounded-lg hover:bg-blue-600 transition text-xs whitespace-nowrap">
                                <PackagePlus :size="15" />
                                Add Item
                            </button>
                        </div>
                        <div class="flex items-center gap-3 mt-3">
                            <div class="relative flex-1 min-w-0">
                                <select
                                    class="appearance-none w-full border border-black/10 rounded-xl p-2.5 pr-8 text-sm text-gray-600 outline-none focus:border-blue-500 bg-white">
                                    <option value="">Select Medicine</option>
                                </select>
                                <ChevronDown :size="15"
                                    class="absolute right-2.5 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none" />
                            </div>
                            <div
                                class="flex items-center justify-between gap-3 border border-black/10 rounded-xl px-2 py-2 shrink-0">
                                <button type="button" aria-label="Decrease quantity"
                                    class="text-gray-500 hover:text-blue-700 transition">
                                    <Minus :size="15" />
                                </button>
                                <span class="text-sm font-medium text-gray-700 min-w-4 text-center">10</span>
                                <button type="button" aria-label="Increase quantity"
                                    class="text-gray-500 hover:text-blue-700 transition">
                                    <Plus :size="15" />
                                </button>
                            </div>
                            <button type="button" aria-label="Remove medicine"
                                class="flex items-center justify-center h-9 w-9 border border-red-100 rounded-xl text-red-500 hover:bg-red-50 transition shrink-0">
                                <X :size="16" />
                            </button>
                        </div>
                    </div>
                    <div class="flex items-center justify-end gap-2 mt-5">
                        <button
                            class="px-4 py-2.5 rounded-xl border border-gray-200 text-gray-600 text-sm hover:bg-gray-50 transition">
                            Clear
                        </button>

                        <button
                            class="flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-blue-700 text-white text-sm hover:bg-blue-600 transition">
                            <ClipboardList :size="16" />
                            Record Distribution
                        </button>
                    </div>
                </div>

                <div class="bg-white p-4 w-full rounded-lg border border-gray-100">
                    <div class="flex items-center gap-2">
                        <div class="flex items-center justify-center h-9 w-9 rounded-lg bg-blue-50 text-blue-700">
                            <ClipboardList :size="18" />
                        </div>
                        <div>
                            <h1 class="font-bold text-lg text-gray-800">Dispense Summary</h1>
                            <p class="text-xs text-gray-400 mt-0.5">Distribution details</p>
                        </div>
                    </div>
                    <div class="mt-4 border border-black/10 rounded-xl p-4">
                        <div class="flex justify-between items-center py-2">
                            <span class="text-sm text-gray-500">Beneficiary</span>
                            <span class="text-sm font-medium text-gray-700">Not selected</span>
                        </div>
                        <div class="flex justify-between items-center py-2 border-t border-gray-100">
                            <span class="text-sm text-gray-500">Medicine Items</span>
                            <span class="text-sm font-medium text-gray-700">0</span>
                        </div>
                        <div class="flex justify-between items-center py-2 border-t border-gray-100">
                            <span class="text-sm text-gray-500">Total Quantity</span>
                            <span class="text-sm font-semibold text-blue-700">0</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="bg-white flex flex-col gap-4 min-w-0 rounded-lg p-4">
                <div class="grid gap-3">
                    <div class="w-full flex flex-col sm:flex-row sm:justify-between gap-3">
                        <div class="relative w-full sm:max-w-[300px]">
                            <Search :size="17" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                            <input type="text" placeholder="Search..."
                                class="border border-black/10 rounded-xl py-2 pl-9 pr-3 w-full outline-none focus:border-blue-500 text-sm" />
                        </div>
                        <button
                            class="flex items-center justify-center gap-2 px-4 py-2 bg-blue-700 text-white rounded-xl hover:bg-blue-600 transition text-sm whitespace-nowrap">
                            <RotateCcw :size="16" />Return Medicines
                        </button>
                    </div>
                    <div class="flex flex-wrap items-center gap-2">
                        <select class="filter-input">
                            <option value="">All Categories</option>
                            <option value="General Medicine">General Medicine</option>
                            <option value="Cold Chain">Cold Chain</option>
                            <option value="High-Alert">High-Alert</option>
                        </select>
                        <div class="flex items-center gap-2 border border-gray-200 rounded-lg px-2 py-1.5">
                            <CalendarDays :size="14" class="text-gray-500 shrink-0" />
                            <input type="date" aria-label="Start date"
                                class="text-xs text-gray-600 bg-transparent outline-none w-[120px]" />
                        </div>
                        <div class="flex items-center gap-2 border border-gray-200 rounded-lg px-2 py-1.5">
                            <CalendarDays :size="14" class="text-gray-500 shrink-0" />
                            <input type="date" aria-label="End date"
                                class="text-xs text-gray-600 bg-transparent outline-none w-[120px]" />
                        </div>
                        <div class="flex items-center gap-2 border border-gray-200 rounded-lg px-2 py-1.5">
                            <Clock :size="14" class="text-gray-500 shrink-0" />
                            <input type="time" aria-label="Start time"
                                class="text-xs text-gray-600 bg-transparent outline-none w-[95px]" />
                        </div>
                        <div class="flex items-center gap-2 border border-gray-200 rounded-lg px-2 py-1.5">
                            <Clock :size="14" class="text-gray-500 shrink-0" />
                            <input type="time" aria-label="End time"
                                class="text-xs text-gray-600 bg-transparent outline-none w-[95px]" />
                        </div>
                        <select class="filter-input">
                            <option value="">All Expiry</option>
                            <option value="valid">Not Expired</option>
                            <option value="expiring">Expiring Soon</option>
                            <option value="expired">Expired</option>
                        </select>
                        <select class="filter-input">
                            <option value="">All Stock Status</option>
                            <option value="available">Available</option>
                            <option value="low">Low Stock</option>
                            <option value="out">Out of Stock</option>
                        </select>
                    </div>
                </div>
                <div class="w-full overflow-x-auto border border-gray-100 rounded-lg">

                    <table class="w-full min-w-[700px] border-collapse text-left">

                        <thead>
                            <tr class="bg-[#2638FF] text-white">

                                <th class="px-4 py-3 text-[12px] font-semibold uppercase tracking-wide">
                                    Transaction #
                                </th>

                                <th class="px-4 py-3 text-[12px] font-semibold uppercase tracking-wide">
                                    Beneficiary
                                </th>

                                <th class="px-4 py-3 text-[12px] font-semibold uppercase tracking-wide">
                                    Medicine (Per Reseta)
                                </th>

                                <th class="px-4 py-3 text-[12px] font-semibold uppercase tracking-wide">
                                    Quantity
                                </th>

                                <th class="px-4 py-3 text-[12px] font-semibold uppercase tracking-wide">
                                    Purpose
                                </th>

                                <th class="px-4 py-3 text-[12px] font-semibold uppercase tracking-wide text-center">
                                    Action
                                </th>

                            </tr>
                        </thead>

                        <tbody class="divide-y divide-gray-100">

                            <!-- ROW 1 -->
                            <tr class="hover:bg-gray-50 transition-colors">

                                <td class="px-4 py-3 text-xs text-gray-500 whitespace-nowrap">
                                    DIST-0001
                                </td>

                                <td class="px-4 py-3">
                                    <p class="text-xs font-medium text-gray-700">
                                        Marites Ocampo
                                    </p>
                                    <p class="text-[12px] text-gray-400 mt-1">
                                        Senior Citizen
                                    </p>
                                </td>

                                <td class="px-4 py-3">
                                    <div class="flex items-center gap-2">
                                        <div
                                            class="w-7 h-7 rounded-lg bg-pink-50 text-pink-500 flex items-center justify-center shrink-0">
                                            <Pill :size="15" />
                                        </div>

                                        <div>
                                            <p class="text-sm font-medium text-gray-700">
                                                Paracetamol
                                            </p>
                                            <p class="text-[12px] text-gray-400">
                                                Tablet
                                            </p>
                                        </div>
                                    </div>
                                </td>

                                <td class="px-4 py-3 text-sm text-gray-500 whitespace-nowrap">
                                    60 pcs
                                </td>

                                <td class="px-4 py-3 text-sm text-gray-500">
                                    Ubo
                                </td>

                                <td class="px-4 py-3">
                                    <div class="flex items-center justify-center gap-2">

                                        <button type="button" title="View transaction"
                                            class="table-action hover:text-blue-600 hover:bg-blue-50">
                                            <Eye :size="16" />
                                        </button>

                                        <button type="button" title="Return medicine"
                                            class="table-action hover:text-red-500 hover:bg-red-50">
                                            <RotateCcw :size="15" />
                                        </button>

                                    </div>
                                </td>

                            </tr>

                            <!-- ROW 2 -->
                            <tr class="hover:bg-gray-50 transition-colors">

                                <td class="px-4 py-3 text-sm text-gray-500 whitespace-nowrap">
                                    DIST-0002
                                </td>

                                <td class="px-4 py-3">
                                    <p class="text-sm font-medium text-gray-700">
                                        Juan Dela Cruz
                                    </p>
                                    <p class="text-[12px] text-gray-400 mt-1">
                                        Regular Beneficiary
                                    </p>
                                </td>

                                <td class="px-4 py-3">
                                    <div class="flex items-center gap-2">
                                        <div
                                            class="w-7 h-7 rounded-lg bg-pink-50 text-pink-500 flex items-center justify-center shrink-0">
                                            <Pill :size="15" />
                                        </div>

                                        <div>
                                            <p class="text-sm font-medium text-gray-700">
                                                Paracetamol
                                            </p>
                                            <p class="text-[12px] text-gray-400">
                                                Tablet
                                            </p>
                                        </div>
                                    </div>
                                </td>

                                <td class="px-4 py-3 text-sm text-gray-500 whitespace-nowrap">
                                    10 pcs
                                </td>

                                <td class="px-4 py-3 text-sm text-gray-500">
                                    Lagnat
                                </td>

                                <td class="px-4 py-3">
                                    <div class="flex items-center justify-center gap-2">

                                        <button type="button" title="View transaction"
                                            class="table-action hover:text-blue-600 hover:bg-blue-50">
                                            <Eye :size="16" />
                                        </button>

                                        <button type="button" title="Return medicine"
                                            class="table-action hover:text-red-500 hover:bg-red-50">
                                            <RotateCcw :size="15" />
                                        </button>

                                    </div>
                                </td>

                            </tr>

                            <!-- ROW 3 -->
                            <tr class="hover:bg-gray-50 transition-colors">

                                <td class="px-4 py-3 text-sm text-gray-500 whitespace-nowrap">
                                    DIST-0003
                                </td>

                                <td class="px-4 py-3">
                                    <p class="text-sm font-medium text-gray-700">
                                        Ana Santos
                                    </p>
                                    <p class="text-[12px] text-gray-400 mt-1">
                                        Senior Citizen
                                    </p>
                                </td>

                                <td class="px-4 py-3">
                                    <div class="flex items-center gap-2">
                                        <div
                                            class="w-7 h-7 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
                                            <Pill :size="15" />
                                        </div>

                                        <div>
                                            <p class="text-sm font-medium text-gray-700">
                                                Amlodipine
                                            </p>
                                            <p class="text-[12px] text-gray-400">
                                                Tablet
                                            </p>
                                        </div>
                                    </div>
                                </td>

                                <td class="px-4 py-3 text-sm text-gray-500 whitespace-nowrap">
                                    30 pcs
                                </td>

                                <td class="px-4 py-3 text-sm text-gray-500">
                                    High Blood Pressure
                                </td>

                                <td class="px-4 py-3">
                                    <div class="flex items-center justify-center gap-2">

                                        <button type="button" title="View transaction"
                                            class="table-action hover:text-blue-600 hover:bg-blue-50">
                                            <Eye :size="16" />
                                        </button>

                                        <button type="button" title="Return medicine"
                                            class="table-action hover:text-red-500 hover:bg-red-50">
                                            <RotateCcw :size="15" />
                                        </button>

                                    </div>
                                </td>

                            </tr>

                        </tbody>

                    </table>
                </div>
            </div>
        </div>
    </section>
</template>
