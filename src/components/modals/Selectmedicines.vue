<script setup>
defineProps({
    IsOpen: Boolean
})

const emit = defineEmits(['close'])
</script>


<template>
    <Transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0 -translate-y-2"
        enter-to-class="opacity-100 translate-y-0" leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100 translate-y-0" leave-to-class="opacity-0 -translate-y-2">
        <section v-if="IsOpen"
            class="fixed inset-0 z-50 flex h-full w-full items-center justify-center overflow-y-auto bg-black/40 p-4">
            <div
                class="flex max-h-[calc(100vh-2rem)] w-full max-w-6xl flex-col overflow-hidden rounded-xl border border-gray-100 bg-white font-inter shadow-xl">

            <!-- Header -->
            <div class="flex items-center justify-between border-b border-gray-100 px-5 py-5 sm:px-8">
                <div class="flex items-center gap-4">
                    <div class="flex h-11 w-11 items-center justify-center rounded-xl bg-blue-50 text-blue-700">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none"
                            stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="m10 13 4-4" />
                            <path d="M16.5 3.5a5 5 0 0 1 7 7l-7 7a5 5 0 0 1-7-7l7-7Z"
                                transform="translate(-3 2) scale(.95)" />
                            <path d="M7.5 14.5a5 5 0 0 0 7 7l7-7a5 5 0 0 0-7-7l-7 7Z"
                                transform="translate(-3 -2) scale(.95)" />
                        </svg>
                    </div>

                    <div>
                        <h2 class="text-xl font-bold text-[#404040]">Select Medicines</h2>
                        <p class="mt-0.5 text-sm text-slate-500">
                            Browse or search for medicines to dispense.
                        </p>
                    </div>
                </div>

                <button type="button" @click="emit('close')"
                    class="flex h-8 w-8 items-center justify-center rounded-md text-slate-500 transition hover:bg-gray-100 hover:text-slate-800"
                    aria-label="Close">
                    <svg xmlns="http://www.w3.org/2000/svg" width="17" height="17" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                        <circle cx="12" cy="12" r="9" />
                        <path d="m9 9 6 6m0-6-6 6" />
                    </svg>
                </button>
            </div>

            <!-- Search and Filters -->
            <div class="flex flex-col gap-4 px-5 pt-5 sm:px-8 md:flex-row md:items-center">
                <div class="relative flex-1">
                    <svg class="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-500"
                        xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" stroke-width="2" stroke-linecap="round">
                        <circle cx="11" cy="11" r="7" />
                        <path d="m20 20-4-4" />
                    </svg>

                    <input type="text" placeholder="Search medicine (name, brand, or strength)..."
                        class="h-10 w-full rounded-lg border border-gray-200 bg-gray-50 pl-10 pr-4 text-sm text-slate-700 outline-none placeholder:text-slate-400 focus:border-blue-700" />
                </div>

                <div class="flex flex-wrap items-center gap-3">
                    <button type="button"
                        class="flex h-10 shrink-0 items-center gap-2 rounded-md border border-gray-200 px-4 text-sm font-medium text-gray-700 transition hover:bg-gray-50">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
                            stroke="currentColor" stroke-width="2" stroke-linecap="round">
                            <path d="M4 4h16l-6.5 8v6l-3 2v-8L4 4Z" />
                        </svg>
                        Category
                    </button>

                    <select
                        class="h-10 min-w-0 flex-1 rounded-lg border border-blue-700 bg-white px-3 text-sm text-slate-700 outline-none focus:ring-2 focus:ring-blue-100 sm:w-40">
                        <option>All</option>
                        <option>Antibiotics</option>
                        <option>Analgesics</option>
                        <option>Vitamins &amp; Supplements</option>
                    </select>

                    <button type="button"
                        class="flex h-10 shrink-0 items-center gap-2 rounded-md border border-gray-200 px-4 text-sm font-medium text-gray-600 transition hover:bg-gray-50 hover:text-gray-800">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none"
                            stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M20 7v5h-5" />
                            <path d="M4 17v-5h5" />
                            <path d="M5.6 9a7 7 0 0 1 11.5-2L20 12M4 12l2.9 5a7 7 0 0 0 11.5-2" />
                        </svg>
                        Clear Filters
                    </button>
                </div>
            </div>

            <!-- Medicine Table -->
            <div class="min-h-0 flex-1 overflow-auto px-5 pb-5 pt-5 sm:px-8">
                <table class="w-full min-w-[760px] border-collapse bg-white text-left">
                    <thead class="sticky top-0 z-10 bg-blue-700 text-white">
                        <tr class="text-left text-sm font-semibold">
                            <th class="w-10 rounded-tl-lg px-3 py-3">
                                <input type="checkbox"
                                    class="h-[17px] w-[17px] rounded border-slate-300 accent-blue-700" />
                            </th>
                            <th class="px-3 py-3">Medicine</th>
                            <th class="px-3 py-3">Category</th>
                            <th class="px-3 py-3">Strength / Form</th>
                            <th class="rounded-tr-lg px-3 py-3">Stock Level</th>
                        </tr>
                    </thead>

                    <tbody class="divide-y divide-gray-100 text-sm">
                        <!-- Amoxicillin -->
                        <tr class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
                            <td class="px-3 py-3">
                                <input type="checkbox"
                                    class="h-[17px] w-[17px] rounded border-slate-300 accent-blue-700" />
                            </td>
                            <td class="px-3 py-3">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-slate-200 bg-slate-100 text-xl">
                                        💊</div>
                                    <div>
                                        <p class="text-sm font-semibold text-slate-800">Amoxicillin</p>
                                        <p class="mt-0.5 text-xs text-slate-500">Amoxil</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-3 py-3">
                                <span
                                    class="inline-flex rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700">Antibiotics</span>
                            </td>
                            <td class="px-3 py-3 text-sm text-slate-700">500mg capsule</td>
                            <td class="px-3 py-3 text-sm font-semibold text-slate-800">120 pcs</td>
                        </tr>

                        <!-- Ciprofloxacin -->
                        <tr class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
                            <td class="px-3 py-3"><input type="checkbox"
                                    class="h-[17px] w-[17px] rounded border-slate-300 accent-blue-700" /></td>
                            <td class="px-2 py-3">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-slate-200 bg-slate-100 text-xl">
                                        💊</div>
                                    <div>
                                        <p class="text-sm font-semibold text-slate-800">Ciprofloxacin</p>
                                        <p class="mt-0.5 text-xs text-slate-500">Cipro</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-3 py-3"><span
                                    class="inline-flex rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700">Antibiotics</span>
                            </td>
                            <td class="px-3 py-3 text-sm text-slate-700">250mg tablet</td>
                            <td class="px-3 py-3 text-sm font-semibold text-slate-800">85 pcs</td>
                        </tr>

                        <!-- Azithromycin -->
                        <tr class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
                            <td class="px-3 py-3"><input type="checkbox"
                                    class="h-[17px] w-[17px] rounded border-slate-300 accent-blue-700" /></td>
                            <td class="px-2 py-3">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-slate-200 bg-slate-100 text-xl">
                                        🧴</div>
                                    <div>
                                        <p class="text-sm font-semibold text-slate-800">Azithromycin</p>
                                        <p class="mt-0.5 text-xs text-slate-500">Zithromax</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-3 py-3"><span
                                    class="inline-flex rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700">Antibiotics</span>
                            </td>
                            <td class="px-3 py-3 text-sm text-slate-700">200mg/5ml suspension</td>
                            <td class="px-3 py-3 text-sm font-semibold text-slate-800">12 pcs</td>
                        </tr>

                        <!-- Doxycycline -->
                        <tr class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
                            <td class="px-3 py-3"><input type="checkbox"
                                    class="h-[17px] w-[17px] rounded border-slate-300 accent-blue-700" /></td>
                            <td class="px-2 py-3">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-slate-200 bg-slate-100 text-xl">
                                        💊</div>
                                    <div>
                                        <p class="text-sm font-semibold text-slate-800">Doxycycline</p>
                                        <p class="mt-0.5 text-xs text-slate-500">Doxy 100</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-3 py-3"><span
                                    class="inline-flex rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700">Antibiotics</span>
                            </td>
                            <td class="px-3 py-3 text-sm text-slate-700">100mg capsule</td>
                            <td class="px-3 py-3 text-sm font-semibold text-slate-800">60 pcs</td>
                        </tr>

                        <!-- Metronidazole -->
                        <tr class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
                            <td class="px-3 py-3"><input type="checkbox"
                                    class="h-[17px] w-[17px] rounded border-slate-300 accent-blue-700" /></td>
                            <td class="px-2 py-3">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-slate-200 bg-slate-100 text-xl">
                                        💊</div>
                                    <div>
                                        <p class="text-sm font-semibold text-slate-500">Metronidazole</p>
                                        <p class="mt-0.5 text-xs text-slate-400">Flagyl</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-3 py-3"><span
                                    class="inline-flex rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700">Antibiotics</span>
                            </td>
                            <td class="px-3 py-3 text-sm text-slate-500">500mg tablet</td>
                            <td class="px-3 py-3 text-sm font-semibold text-red-500">0 pcs</td>
                        </tr>

                        <!-- Cephalexin -->
                        <tr class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
                            <td class="px-3 py-3"><input type="checkbox"
                                    class="h-[17px] w-[17px] rounded border-slate-300 accent-blue-700" /></td>
                            <td class="px-2 py-3">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-slate-200 bg-slate-100 text-xl">
                                        💊</div>
                                    <div>
                                        <p class="text-sm font-semibold text-slate-800">Cephalexin</p>
                                        <p class="mt-0.5 text-xs text-slate-500">Keflex</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-3 py-3"><span
                                    class="inline-flex rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700">Antibiotics</span>
                            </td>
                            <td class="px-3 py-3 text-sm text-slate-700">250mg capsule</td>
                            <td class="px-3 py-3 text-sm font-semibold text-slate-800">45 pcs</td>
                        </tr>

                        <!-- Clindamycin -->
                        <tr class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
                            <td class="px-3 py-3"><input type="checkbox"
                                    class="h-[17px] w-[17px] rounded border-slate-300 accent-blue-700" /></td>
                            <td class="px-2 py-3">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-slate-200 bg-slate-100 text-xl">
                                        🧴</div>
                                    <div>
                                        <p class="text-sm font-semibold text-slate-800">Clindamycin</p>
                                        <p class="mt-0.5 text-xs text-slate-500">Cleocin</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-3 py-3"><span
                                    class="inline-flex rounded-full bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700">Antibiotics</span>
                            </td>
                            <td class="px-3 py-3 text-sm text-slate-700">300mg capsule</td>
                            <td class="px-3 py-3 text-sm font-semibold text-slate-800">18 pcs</td>
                        </tr>

                        <!-- Paracetamol -->
                        <tr class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
                            <td class="px-3 py-3"><input type="checkbox"
                                    class="h-[17px] w-[17px] rounded border-slate-300 accent-blue-700" /></td>
                            <td class="px-2 py-3">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-slate-200 bg-slate-100 text-xl">
                                        💊</div>
                                    <div>
                                        <p class="text-sm font-semibold text-slate-800">Paracetamol</p>
                                        <p class="mt-0.5 text-xs text-slate-500">Biogesic</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-3 py-3"><span
                                    class="inline-flex rounded-full bg-orange-50 px-3 py-1 text-xs font-medium text-orange-700">Analgesics</span>
                            </td>
                            <td class="px-3 py-3 text-sm text-slate-700">500mg tablet</td>
                            <td class="px-3 py-3 text-sm font-semibold text-slate-800">200 pcs</td>
                        </tr>

                        <!-- Vitamin C -->
                        <tr class="transition-colors odd:bg-white even:bg-gray-50 hover:bg-blue-50">
                            <td class="px-3 py-3"><input type="checkbox"
                                    class="h-[17px] w-[17px] rounded border-slate-300 accent-blue-700" /></td>
                            <td class="px-2 py-3">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-slate-200 bg-slate-100 text-xl">
                                        💊</div>
                                    <div>
                                        <p class="text-sm font-semibold text-slate-800">Vitamin C</p>
                                        <p class="mt-0.5 text-xs text-slate-500">Redoxon</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-3 py-3"><span
                                    class="inline-flex rounded-full bg-green-50 px-3 py-1 text-xs font-medium text-green-700">Vitamins
                                    &amp; Supplements</span></td>
                            <td class="px-3 py-3 text-sm text-slate-700">500mg tablet</td>
                            <td class="px-3 py-3 text-sm font-semibold text-slate-800">95 pcs</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Footer -->
            <div
                class="flex flex-col gap-4 border-t border-gray-100 bg-white px-5 py-5 sm:flex-row sm:items-center sm:justify-between sm:px-8">
                <p class="text-sm text-slate-500">0 medicine(s) selected</p>

                <div class="flex items-center justify-end gap-3">
                    <button type="button" @click="emit('close')"
                        class="rounded-md border border-gray-200 px-4 py-2 text-sm font-medium text-gray-600 transition hover:bg-gray-50">
                        Cancel
                    </button>

                    <button type="button"
                        class="rounded-md bg-blue-700 px-4 py-2 text-sm font-semibold text-white transition hover:bg-blue-800">
                        Add to Dispense
                    </button>
                </div>
            </div>

            </div>
        </section>
    </Transition>
</template>