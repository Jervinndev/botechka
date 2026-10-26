<script setup>
import { Archive, Search, Pill, User, Building2 } from '@lucide/vue'
</script>

<template>
    <div class="h-fit font-sans text-slate-900">
        <!-- Page header -->
        <header class="mb-4">
            <h1 class="flex items-center gap-2 text-lg font-bold">
                <Archive :size="20" /> Archive Records
            </h1>
        </header>

        <!-- Search -->
        <div class="relative mb-4 max-w-xl">
            <Search :size="16" class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
            <input type="text" placeholder="Search for Archive Name or ID..."
                class="w-full rounded-lg border border-slate-200 bg-white py-2.5 pl-11 pr-4 text-sm outline-none placeholder:text-slate-400 focus:border-blue-500" />
        </div>

        <!-- Filter pills (active = blue) -->
        <div class="mb-4 flex flex-wrap gap-2">
            <button class="rounded-full bg-blue-600 px-5 py-1.5 text-xs font-semibold text-white">All</button>
            <button
                class="rounded-full border border-slate-200 bg-white px-4 py-1.5 text-xs font-medium text-slate-600 hover:border-blue-300 hover:text-blue-600">Medicines</button>
            <button
                class="rounded-full border border-slate-200 bg-white px-4 py-1.5 text-xs font-medium text-slate-600 hover:border-blue-300 hover:text-blue-600">Beneficiaries</button>
            <button
                class="rounded-full border border-slate-200 bg-white px-4 py-1.5 text-xs font-medium text-slate-600 hover:border-blue-300 hover:text-blue-600">Suppliers</button>
            <button
                class="rounded-full border border-slate-200 bg-white px-4 py-1.5 text-xs font-medium text-slate-600 hover:border-blue-300 hover:text-blue-600">Dispense</button>
        </div>

        <!-- Archive list (repeat one row per archived record) -->
        <section class="overflow-hidden rounded-2xl border border-slate-200 bg-white">
            <ul class="divide-y divide-slate-100">
                <!-- Medicine -->
                <li class="flex flex-wrap items-center justify-between gap-4 px-5 py-4 hover:bg-slate-50">
                    <div class="flex items-center gap-4">
                        <span
                            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-slate-100 text-slate-600">
                            <Pill :size="18" />
                        </span>
                        <div>
                            <p class="text-sm font-bold">Napa Extra <span
                                    class="ml-1 text-xs font-normal text-slate-400">#ARC-2026-001</span></p>
                            <p class="text-xs text-slate-500">Medicine · Archived by Jervin Villones · Sep 2, 2026</p>
                        </div>
                    </div>
                    <div class="flex gap-2">
                        <button
                            class="rounded-lg border border-slate-200 px-4 py-2 text-xs font-semibold hover:bg-slate-50">Restore</button>
                        <button
                            class="rounded-lg border border-red-200 px-4 py-2 text-xs font-semibold text-red-600 hover:bg-red-50">Delete
                            permanently</button>
                    </div>
                </li>

                <!-- Beneficiary -->
                <li class="flex flex-wrap items-center justify-between gap-4 px-5 py-4 hover:bg-slate-50">
                    <div class="flex items-center gap-4">
                        <span
                            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-slate-100 text-slate-600">
                            <User :size="18" />
                        </span>
                        <div>
                            <p class="text-sm font-bold">Bien Villareal <span
                                    class="ml-1 text-xs font-normal text-slate-400">#ARC-2026-001</span></p>
                            <p class="text-xs text-slate-500">Beneficiary · Archived by Jervin Villones · Aug 28, 2026
                            </p>
                        </div>
                    </div>
                    <div class="flex gap-2">
                        <button
                            class="rounded-lg border border-slate-200 px-4 py-2 text-xs font-semibold hover:bg-slate-50">Restore</button>
                        <button
                            class="rounded-lg border border-red-200 px-4 py-2 text-xs font-semibold text-red-600 hover:bg-red-50">Delete
                            permanently</button>
                    </div>
                </li>

                <!-- Supplier -->
                <li class="flex flex-wrap items-center justify-between gap-4 px-5 py-4 hover:bg-slate-50">
                    <div class="flex items-center gap-4">
                        <span
                            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-slate-100 text-slate-600">
                            <Building2 :size="18" />
                        </span>
                        <div>
                            <p class="text-sm font-bold">Beximco Pharmaceuticals Ltd. <span
                                    class="ml-1 text-xs font-normal text-slate-400">#ARC-2026-001</span></p>
                            <p class="text-xs text-slate-500">Supplier · Archived by Jervin Villones · Aug 20, 2026</p>
                        </div>
                    </div>
                    <div class="flex gap-2">
                        <button
                            class="rounded-lg border border-slate-200 px-4 py-2 text-xs font-semibold hover:bg-slate-50">Restore</button>
                        <button
                            class="rounded-lg border border-red-200 px-4 py-2 text-xs font-semibold text-red-600 hover:bg-red-50">Delete
                            permanently</button>
                    </div>
                </li>

                <!-- Medicine -->
                <li class="flex flex-wrap items-center justify-between gap-4 px-5 py-4 hover:bg-slate-50">
                    <div class="flex items-center gap-4">
                        <span
                            class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-slate-100 text-slate-600">
                            <Pill :size="18" />
                        </span>
                        <div>
                            <p class="text-sm font-bold">Metronidazole 500mg <span
                                    class="ml-1 text-xs font-normal text-slate-400">#ARC-2026-001</span></p>
                            <p class="text-xs text-slate-500">Medicine · Archived by Jervin Villones · Aug 15, 2026</p>
                        </div>
                    </div>
                    <div class="flex gap-2">
                        <button
                            class="rounded-lg border border-slate-200 px-4 py-2 text-xs font-semibold hover:bg-slate-50">Restore</button>
                        <button
                            class="rounded-lg border border-red-200 px-4 py-2 text-xs font-semibold text-red-600 hover:bg-red-50">Delete
                            permanently</button>
                    </div>
                </li>
            </ul>

            <!-- Empty state (show when nothing is archived)
      <p class="px-6 py-10 text-center text-sm text-slate-400">No archived records found.</p>
      -->
        </section>
    </div>
</template>