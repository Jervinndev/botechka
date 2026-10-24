<script setup>
import { onMounted, ref } from 'vue'
import { ArrowLeft, Pill, Bell } from '@lucide/vue'
import { useRouter } from 'vue-router'
</script>

<template>
    <div class="flex justify-between items-center ">
        <div>
            <h1 class="font-inter font-bold text-[#404040] text-lg">Available Medicines</h1>
            <p class="text-sm text-[#808080]">Hello po! Jervin Kamusta!</p>
        </div>
        <div>
            <Bell class="text-blue-700" />
        </div>
    </div>


    <div class="font-inter text-gray-800 mt-4">
        <div class="flex flex-col md:flex-row justify-between items-stretch md:items-center gap-4 mb-6">
            <div class="relative w-full max-w-4xl">
                <svg xmlns="http://www.w3.org/2000/svg"
                    class="w-4 h-4 text-gray-400 absolute left-3.5 top-1/2 -translate-y-1/2" fill="none"
                    viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                <input type="text" placeholder="Search medicines..."
                    class="w-full bg-white text-xs text-gray-800 placeholder-gray-400 pl-10 pr-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-1 focus:ring-blue-500 " />
            </div>
            <div>
                <button
                    class="flex items-center gap-2 bg-white px-4 py-3 rounded-xl border border-gray-200 text-xs font-semibold text-gray-700 hover:bg-gray-50 transition ">
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4 text-blue-600" fill="none"
                        viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                            d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                    </svg>
                    <span>All Categories</span>
                    <svg xmlns="http://www.w3.org/2000/svg" class="w-3.5 h-3.5 text-gray-400 ml-1" fill="none"
                        viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                    </svg>
                </button>
            </div>

        </div>
        <div class="mb-4">
            <h2 class="text-base font-bold text-gray-900 tracking-tight">All Medicines</h2>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div class="bg-white p-4 rounded-2xl border border-gray-200  flex flex-col justify-between gap-4">
                <div class="flex items-start gap-3">
                    <div
                        class="w-16 h-12 bg-gray-50 rounded-lg flex items-center justify-center p-1 border border-gray-100 shrink-0">
                        <img src="https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=100&auto=format&fit=crop&q=60"
                            alt="Paracetamol" class="w-full h-full object-contain" />
                    </div>
                    <div>
                        <h3 class="text-sm font-bold text-gray-900 leading-snug">Paracetamol</h3>
                        <p class="text-xs text-gray-500">Biogesic</p>
                        <p class="text-[11px] text-gray-400 mt-0.5">500 mg &middot; Tablet</p>
                    </div>
                </div>
                <div class="flex justify-between items-center pt-2 border-t border-gray-50 text-xs">
                    <span class="font-bold text-gray-900">250 in stock</span>
                    <span
                        class="flex items-center gap-1 text-emerald-600 font-semibold bg-emerald-50 px-2.5 py-1 rounded-md text-[11px]">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                        Available now
                    </span>
                </div>
            </div>

            <!-- Card 2: Ibuprofen -->
            <div class="bg-white p-4 rounded-2xl border border-gray-200  flex flex-col justify-between gap-4">
                <div class="flex items-start gap-3">
                    <div
                        class="w-16 h-12 bg-gray-50 rounded-lg flex items-center justify-center p-1 border border-gray-100 shrink-0">
                        <img src="https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=100&auto=format&fit=crop&q=60"
                            alt="Ibuprofen" class="w-full h-full object-contain" />
                    </div>
                    <div>
                        <h3 class="text-sm font-bold text-gray-900 leading-snug">Ibuprofen</h3>
                        <p class="text-xs text-gray-500">Medicol</p>
                        <p class="text-[11px] text-gray-400 mt-0.5">200 mg &middot; Capsule</p>
                    </div>
                </div>
                <div class="flex justify-between items-center pt-2 border-t border-gray-50 text-xs">
                    <span class="font-bold text-gray-900">180 in stock</span>
                    <span
                        class="flex items-center gap-1 text-emerald-600 font-semibold bg-emerald-50 px-2.5 py-1 rounded-md text-[11px]">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                        Available now
                    </span>
                </div>
            </div>

            <!-- Card 3: Amoxicillin -->
            <div class="bg-white p-4 rounded-2xl border border-gray-200  flex flex-col justify-between gap-4">
                <div class="flex items-start gap-3">
                    <div
                        class="w-16 h-12 bg-gray-50 rounded-lg flex items-center justify-center p-1 border border-gray-100 shrink-0">
                        <img src="https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=100&auto=format&fit=crop&q=60"
                            alt="Amoxicillin" class="w-full h-full object-contain" />
                    </div>
                    <div>
                        <h3 class="text-sm font-bold text-gray-900 leading-snug">Amoxicillin</h3>
                        <p class="text-xs text-gray-500">Amoxil</p>
                        <p class="text-[11px] text-gray-400 mt-0.5">500 mg &middot; Capsule</p>
                    </div>
                </div>
                <div class="flex justify-between items-center pt-2 border-t border-gray-50 text-xs">
                    <span class="font-bold text-gray-900">120 in stock</span>
                    <span
                        class="flex items-center gap-1 text-emerald-600 font-semibold bg-emerald-50 px-2.5 py-1 rounded-md text-[11px]">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                        Available now
                    </span>
                </div>
            </div>

            <!-- Card 4: Cetirizine -->
            <div class="bg-white p-4 rounded-2xl border border-gray-200  flex flex-col justify-between gap-4">
                <div class="flex items-start gap-3">
                    <div
                        class="w-16 h-12 bg-gray-50 rounded-lg flex items-center justify-center p-1 border border-gray-100 shrink-0">
                        <img src="https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=100&auto=format&fit=crop&q=60"
                            alt="Cetirizine" class="w-full h-full object-contain" />
                    </div>
                    <div>
                        <h3 class="text-sm font-bold text-gray-900 leading-snug">Cetirizine</h3>
                        <p class="text-xs text-gray-500">Allerta</p>
                        <p class="text-[11px] text-gray-400 mt-0.5">10 mg &middot; Tablet</p>
                    </div>
                </div>
                <div class="flex justify-between items-center pt-2 border-t border-gray-50 text-xs">
                    <span class="font-bold text-gray-900">200 in stock</span>
                    <span
                        class="flex items-center gap-1 text-emerald-600 font-semibold bg-emerald-50 px-2.5 py-1 rounded-md text-[11px]">
                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                        Available now
                    </span>
                </div>
            </div>
        </div>
    </div>
</template>
