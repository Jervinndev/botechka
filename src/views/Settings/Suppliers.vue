<script setup>
import { Eye, SquarePen, Archive, LayoutGrid, List } from '@lucide/vue'
</script>

<template>
    <div class="h-fit font-sans text-slate-900">
        <!-- Page header -->
        <header class="mb-4">
            <h1 class="text-lg font-bold">Supplier</h1>
            <p class="text-sm text-slate-500">Manage your medicine resources</p>
        </header>

        <!-- Toolbar -->
        <section class="mb-3 flex flex-wrap items-center gap-2 rounded-md bg-white p-2">
            <div class="min-w-[240px] flex-1">
                <input type="text" placeholder="Search for Supplier Name or ID..."
                    class="settings-search w-full rounded-md bg-gray-100 p-2 text-sm outline-none placeholder:text-gray-400" />
            </div>

            <button
                class="rounded-md bg-blue-700 px-4 py-2 text-sm font-medium text-white transition hover:bg-blue-800">Add
                Suppliers</button>

            <!-- View toggle (active = blue-tinted) -->
            <div class="flex items-center gap-1">
                <button
                    class="flex h-9 w-9 items-center justify-center rounded-md text-slate-500 transition hover:bg-gray-100"
                    aria-label="Grid view">
                    <LayoutGrid :size="16" />
                </button>
                <button
                    class="flex h-9 w-9 items-center justify-center rounded-md text-slate-500 transition hover:bg-gray-100"
                    aria-label="List view">
                    <List :size="16" />
                </button>
            </div>
        </section>

        <!-- Suppliers table -->
        <section class="overflow-x-auto rounded-lg bg-white shadow-sm">
            <table class="w-full min-w-[900px] text-left text-sm">
                <thead>
                    <tr class="bg-blue-600 text-xs font-semibold text-white">
                        <th class="px-5 py-4">Company</th>
                        <th class="px-5 py-4">ID</th>
                        <th class="px-5 py-4">Contact Person</th>
                        <th class="px-5 py-4">Contact Number</th>
                        <th class="px-5 py-4">Email</th>
                        <th class="px-5 py-4">Location</th>
                        <th class="px-5 py-4">Type</th>
                        <th class="px-5 py-4">Action</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                    <!-- Supplier row (repeat per supplier) -->
                    <tr class="hover:bg-slate-50">
                        <td class="px-5 py-4 text-slate-700">RHU</td>
                        <td class="px-5 py-4 text-slate-700">SUP-001</td>
                        <td class="px-5 py-4 text-slate-700">Ann Reyes</td>
                        <td class="px-5 py-4 text-slate-700">09465290981</td>
                        <td class="px-5 py-4 text-slate-700">paul@gmail.com</td>
                        <td class="px-5 py-4 text-slate-700">Sanata cruz laguna</td>
                        <td class="px-5 py-4 text-slate-700">Private</td>
                        <td class="px-5 py-4">
                            <div class="flex items-center gap-2">
                                <button
                                    class="flex h-8 w-8 items-center justify-center rounded-lg text-slate-600 hover:bg-slate-100"
                                    aria-label="View supplier">
                                    <Eye :size="17" />
                                </button>
                                <button
                                    class="flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-100"
                                    aria-label="Edit supplier">
                                    <SquarePen :size="15" />
                                </button>
                                <button
                                    class="flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-100"
                                    aria-label="Archive supplier">
                                    <Archive :size="15" />
                                </button>
                            </div>
                        </td>
                    </tr>
                    <tr class="hover:bg-slate-50">
                        <td class="px-5 py-4 text-slate-700">RHU</td>
                        <td class="px-5 py-4 text-slate-700">SUP-001</td>
                        <td class="px-5 py-4 text-slate-700">Ann Reyes</td>
                        <td class="px-5 py-4 text-slate-700">09465290981</td>
                        <td class="px-5 py-4 text-slate-700">paul@gmail.com</td>
                        <td class="px-5 py-4 text-slate-700">Sanata cruz laguna</td>
                        <td class="px-5 py-4 text-slate-700">Govn.</td>
                        <td class="px-5 py-4">
                            <div class="flex items-center gap-2">
                                <button
                                    class="flex h-8 w-8 items-center justify-center rounded-lg text-slate-600 hover:bg-slate-100"
                                    aria-label="View supplier">
                                    <Eye :size="17" />
                                </button>
                                <button
                                    class="flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-100"
                                    aria-label="Edit supplier">
                                    <SquarePen :size="15" />
                                </button>
                                <button
                                    class="flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-100"
                                    aria-label="Archive supplier">
                                    <Archive :size="15" />
                                </button>
                            </div>
                        </td>
                    </tr>
                    <tr class="hover:bg-slate-50">
                        <td class="px-5 py-4 text-slate-700">RHU</td>
                        <td class="px-5 py-4 text-slate-700">SUP-001</td>
                        <td class="px-5 py-4 text-slate-700">Ann Reyes</td>
                        <td class="px-5 py-4 text-slate-700">09465290981</td>
                        <td class="px-5 py-4 text-slate-700">paul@gmail.com</td>
                        <td class="px-5 py-4 text-slate-700">Sanata cruz laguna</td>
                        <td class="px-5 py-4 text-slate-700">Govn.</td>
                        <td class="px-5 py-4">
                            <div class="flex items-center gap-2">
                                <button
                                    class="flex h-8 w-8 items-center justify-center rounded-lg text-slate-600 hover:bg-slate-100"
                                    aria-label="View supplier">
                                    <Eye :size="17" />
                                </button>
                                <button
                                    class="flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-100"
                                    aria-label="Edit supplier">
                                    <SquarePen :size="15" />
                                </button>
                                <button
                                    class="flex h-8 w-8 items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-100"
                                    aria-label="Archive supplier">
                                    <Archive :size="15" />
                                </button>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </section>
    </div>
</template>