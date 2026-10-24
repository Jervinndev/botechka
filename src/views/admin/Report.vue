<script setup>
import { Pill } from '@lucide/vue'
</script>

<template>
    <section class="w-full">
        <div>
            <h1 class="font-inter font-bold text-[#404040] text-md">Categories</h1>
            <p class="text-sm text-gray-400">Manage your medicine resources</p>
        </div>
        <!-- <div class="grid grid-cols-3 mt-4 gap-4">
            <div class="bg-white p-4 rounded-lg">
                <h1 class="text-gray-900">Total</h1>
                <div class="flex justify-between">
                    <h1 class="text-xl font-bold">855,876</h1>
                    <Pill />
                </div>
                <div class="flex justify-between mt-4 text-sm">
                    <h1 class="text-green-500">4.3%</h1>
                    <p class="text-gray-400">vs last month</p>
                </div>
            </div>
            <div class="bg-white p-4 rounded-lg">
                <h1 class="text-gray-900">Total</h1>
                <div class="flex justify-between">
                    <h1 class="text-xl font-bold">855,876</h1>
                    <Pill />
                </div>
                <div class="flex justify-between mt-4 text-sm">
                    <h1 class="text-green-500">4.3%</h1>
                    <p class="text-gray-400">vs last month</p>
                </div>
            </div>
            <div class="bg-white p-4 rounded-lg">
                <h1 class="text-gray-900">Total</h1>
                <div class="flex justify-between">
                    <h1 class="text-xl font-bold">855,876</h1>
                    <Pill />
                </div>
                <div class="flex justify-between mt-4 text-sm">
                    <h1 class="text-green-500">4.3%</h1>
                    <p class="text-gray-400">vs last month</p>
                </div>
            </div>
        </div> -->
        <div class="flex items-center justify-center mt-4 p-2 w-fit bg-white rounded-lg">
            <div class="grid grid-cols-6 gap-4 text-sm">
                <button class="p-2 bg-blue-700 text-white rounded-lg">Category</button>
                <button class="p-2 text-gray-500">Inventory</button>
                <button class="p-2 text-gray-500">Dispensing</button>
                <button class="p-2 text-gray-500">Analytics</button>
                <button class="p-2 text-gray-500">Supplier</button>
                <button class="p-2 text-gray-500">Audit Trail</button>
            </div>
        </div>

        <div>

        </div>
    </section>
</template>