<script setup>
import {
    User, Search, Package, ChevronDown, ChevronLeft, ChevronRight, ArrowUpRight,
    EllipsisVertical, Pencil, Plus,
} from '@lucide/vue'
</script>

<template>
    <div class="h-fit font-sans text-slate-900">
        <!-- Page header -->
        <header class="mb-5 flex items-start gap-3">
            <User :size="22" class="mt-1" />
            <div>
                <h1 class="text-xl font-bold text-slate-900">Account Management</h1>
                <p class="text-sm text-slate-500">Manage access, assign roles, and keep your workspace secure.</p>
            </div>
        </header>

        <!-- Role summary cards (repeat per role) -->
        <section class="mb-5 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <div class="rounded-2xl border border-blue-100 bg-white p-4 ">
                <div class="flex items-start justify-between gap-3">
                    <div>
                        <p class="text-sm font-semibold text-slate-900">Super Admin</p>
                        <p class="text-xs text-slate-500">Manages Admin</p>
                    </div>
                    <p class="text-3xl font-bold leading-none text-slate-900">1</p>
                </div>
                <div class="mt-4 flex items-center justify-between text-xs font-medium text-slate-500">
                    <span class="flex items-center gap-2"><span class="h-2 w-2 rounded-full bg-blue-500"></span>1
                        admin</span>
                    <ArrowUpRight :size="14" class="text-blue-500" />
                </div>
            </div>
            <div class="rounded-2xl border border-blue-100 bg-white p-4 ">
                <div class="flex items-start justify-between gap-3">
                    <div>
                        <p class="text-sm font-semibold text-slate-900">Administrators</p>
                        <p class="text-xs text-slate-500">Full workspace access</p>
                    </div>
                    <p class="text-3xl font-bold leading-none text-slate-900">1</p>
                </div>
                <div class="mt-4 flex items-center justify-between text-xs font-medium text-slate-500">
                    <span class="flex items-center gap-2"><span class="h-2 w-2 rounded-full bg-blue-500"></span>1
                        admin</span>
                    <ArrowUpRight :size="14" class="text-blue-500" />
                </div>
            </div>
            <div class="rounded-2xl border border-blue-100 bg-white p-4 ">
                <div class="flex items-start justify-between gap-3">
                    <div>
                        <p class="text-sm font-semibold text-slate-900">Personnel</p>
                        <p class="text-xs text-slate-500">Standard operational access</p>
                    </div>
                    <p class="text-3xl font-bold leading-none text-slate-900">6</p>
                </div>
                <div class="mt-4 flex items-center justify-between text-xs font-medium text-slate-500">
                    <span class="flex items-center gap-2"><span class="h-2 w-2 rounded-full bg-emerald-500"></span>6
                        active this week</span>
                    <ArrowUpRight :size="14" class="text-emerald-500" />
                </div>
            </div>
            <div class="rounded-2xl border border-blue-100 bg-white p-4 ">
                <div class="flex items-start justify-between gap-3">
                    <div>
                        <p class="text-sm font-semibold text-slate-900">Beneficiaries</p>
                        <p class="text-xs text-slate-500">View only medicines and history</p>
                    </div>
                    <p class="text-3xl font-bold leading-none text-slate-900">7</p>
                </div>
                <div class="mt-4 flex items-center justify-between text-xs font-medium text-slate-500">
                    <span class="flex items-center gap-2"><span class="h-2 w-2 rounded-full bg-violet-500"></span>2
                        Active</span>
                    <ArrowUpRight :size="14" class="text-violet-500" />
                </div>
            </div>
        </section>

        <!-- All users -->
        <section class="mb-5 overflow-hidden rounded-2xl border border-slate-200 bg-white ">
            <div class="flex flex-wrap items-end justify-between gap-4 p-5">
                <div>
                    <h2 class="flex items-center gap-2 text-xl font-bold">
                        All users
                        <span
                            class="rounded-full bg-blue-50 px-2.5 py-0.5 text-xs font-semibold text-blue-600">29</span>
                    </h2>
                    <p class="text-xs text-slate-500">Review and manage user</p>
                </div>

                <div class="flex flex-wrap items-end gap-3">
                    <div class="relative w-72">
                        <Search :size="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                        <input type="text" placeholder="Search name, email, or username..."
                            class="w-full rounded-lg border border-slate-200 bg-slate-50 py-2.5 pl-10 pr-3 text-sm outline-none placeholder:text-slate-400 focus:border-blue-500" />
                    </div>

                    <div>
                        <label
                            class="relative flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2 text-sm text-slate-500">
                            <Package :size="15" />
                            <select class="settings-filter-select appearance-none bg-transparent pr-6 outline-none">
                                <option>All roles</option>
                                <option>Admin</option>
                                <option>Personnel</option>
                                <option>Beneficiaries</option>
                            </select>
                            <ChevronDown :size="14" class="pointer-events-none absolute right-3" />
                        </label>
                    </div>

                    <div>
                        <label
                            class="relative flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2 text-sm text-slate-500">
                            <Package :size="15" />
                            <select class="settings-filter-select appearance-none bg-transparent pr-6 outline-none">
                                <option>All statuses</option>
                                <option>Active</option>
                                <option>Inactive</option>
                            </select>
                            <ChevronDown :size="14" class="pointer-events-none absolute right-3" />
                        </label>
                    </div>

                    <button
                        class="flex items-center gap-1 rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-blue-700">
                        <Plus :size="14" /> Add User
                    </button>
                </div>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full min-w-[900px] text-left text-sm">
                    <thead>
                        <tr
                            class="border-y border-slate-200 bg-slate-50 text-[11px] font-semibold uppercase tracking-wide text-slate-500">
                            <th class="w-12 px-5 py-3"><input type="checkbox" class="h-4 w-4 rounded border-slate-300"
                                    aria-label="Select all users" /></th>
                            <th class="px-5 py-3">User</th>
                            <th class="px-5 py-3">Email address</th>
                            <th class="px-5 py-3">Role</th>
                            <th class="px-5 py-3">Status</th>
                            <th class="px-5 py-3">Created</th>
                            <th class="px-5 py-3"></th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <!-- User row (repeat per user) -->
                        <tr class="hover:bg-slate-50">
                            <td class="px-5 py-4"><input type="checkbox" class="h-4 w-4 rounded border-slate-300"
                                    aria-label="Select user" /></td>
                            <td class="px-5 py-4">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-blue-600 text-xs font-semibold text-white">
                                        AC</div>
                                    <div>
                                        <p class="font-semibold text-slate-900">Amelia Carter</p>
                                        <p class="text-xs text-slate-500">@amelia</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-5 py-4 text-slate-700">amelia.carter@northwell.io</td>
                            <td class="px-5 py-4"><span
                                    class="rounded-full px-3 py-1 text-xs font-semibold bg-blue-50 text-blue-600">Admin</span>
                            </td>
                            <td class="px-5 py-4"><span
                                    class="inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-semibold bg-emerald-100 text-emerald-700"><span
                                        class="h-1.5 w-1.5 rounded-full bg-emerald-500"></span>Active</span></td>
                            <td class="px-5 py-4 font-medium text-slate-500">Mar. 28, 2026</td>
                            <td class="px-5 py-4 text-right"><button
                                    class="rounded-lg p-2 text-slate-500 hover:bg-slate-100" aria-label="More actions">
                                    <EllipsisVertical :size="18" />
                                </button></td>
                        </tr>
                        <tr class="hover:bg-slate-50">
                            <td class="px-5 py-4"><input type="checkbox" class="h-4 w-4 rounded border-slate-300"
                                    aria-label="Select user" /></td>
                            <td class="px-5 py-4">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-blue-600 text-xs font-semibold text-white">
                                        MC</div>
                                    <div>
                                        <p class="font-semibold text-slate-900">Marcus Chen</p>
                                        <p class="text-xs text-slate-500">@marcus</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-5 py-4 text-slate-700">marcus.chen@northwell.io</td>
                            <td class="px-5 py-4"><span
                                    class="rounded-full px-3 py-1 text-xs font-semibold bg-emerald-50 text-emerald-600">Personnel</span>
                            </td>
                            <td class="px-5 py-4"><span
                                    class="inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-semibold bg-emerald-100 text-emerald-700"><span
                                        class="h-1.5 w-1.5 rounded-full bg-emerald-500"></span>Active</span></td>
                            <td class="px-5 py-4 font-medium text-slate-500">Mar. 28, 2026</td>
                            <td class="px-5 py-4 text-right"><button
                                    class="rounded-lg p-2 text-slate-500 hover:bg-slate-100" aria-label="More actions">
                                    <EllipsisVertical :size="18" />
                                </button></td>
                        </tr>
                        <tr class="hover:bg-slate-50">
                            <td class="px-5 py-4"><input type="checkbox" class="h-4 w-4 rounded border-slate-300"
                                    aria-label="Select user" /></td>
                            <td class="px-5 py-4">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-blue-600 text-xs font-semibold text-white">
                                        PS</div>
                                    <div>
                                        <p class="font-semibold text-slate-900">Priya Shah</p>
                                        <p class="text-xs text-slate-500">@priya</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-5 py-4 text-slate-700">priya.shah@northwell.io</td>
                            <td class="px-5 py-4"><span
                                    class="rounded-full px-3 py-1 text-xs font-semibold bg-emerald-50 text-emerald-600">Personnel</span>
                            </td>
                            <td class="px-5 py-4"><span
                                    class="inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-semibold bg-emerald-100 text-emerald-700"><span
                                        class="h-1.5 w-1.5 rounded-full bg-emerald-500"></span>Active</span></td>
                            <td class="px-5 py-4 font-medium text-slate-500">Mar. 28, 2026</td>
                            <td class="px-5 py-4 text-right"><button
                                    class="rounded-lg p-2 text-slate-500 hover:bg-slate-100" aria-label="More actions">
                                    <EllipsisVertical :size="18" />
                                </button></td>
                        </tr>
                        <tr class="hover:bg-slate-50">
                            <td class="px-5 py-4"><input type="checkbox" class="h-4 w-4 rounded border-slate-300"
                                    aria-label="Select user" /></td>
                            <td class="px-5 py-4">
                                <div class="flex items-center gap-3">
                                    <div
                                        class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-blue-600 text-xs font-semibold text-white">
                                        NW</div>
                                    <div>
                                        <p class="font-semibold text-slate-900">Noah Williams</p>
                                        <p class="text-xs text-slate-500">@noah</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-5 py-4 text-slate-700">noah.w@northwell.io</td>
                            <td class="px-5 py-4"><span
                                    class="rounded-full px-3 py-1 text-xs font-semibold bg-violet-100 text-violet-600">Beneficiaries</span>
                            </td>
                            <td class="px-5 py-4"><span
                                    class="inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-semibold bg-amber-100 text-amber-700"><span
                                        class="h-1.5 w-1.5 rounded-full bg-amber-500"></span>Inactive</span></td>
                            <td class="px-5 py-4 font-medium text-slate-500">Mar. 28, 2026</td>
                            <td class="px-5 py-4 text-right"><button
                                    class="rounded-lg p-2 text-slate-500 hover:bg-slate-100" aria-label="More actions">
                                    <EllipsisVertical :size="18" />
                                </button></td>
                        </tr>

                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <div class="flex items-center justify-between px-5 py-4 text-xs text-slate-500">
                <p>Showing 1–7 of 29 users</p>
                <div class="flex items-center gap-2">
                    <button
                        class="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 hover:bg-slate-50"
                        aria-label="Previous page">
                        <ChevronLeft :size="16" />
                    </button>
                    <button class="h-9 w-9 rounded-lg bg-blue-600 text-sm font-medium text-white">1</button>
                    <button class="h-9 w-9 rounded-lg border border-slate-200 text-sm hover:bg-slate-50">2</button>
                    <button class="h-9 w-9 rounded-lg border border-slate-200 text-sm hover:bg-slate-50">3</button>
                    <button
                        class="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 hover:bg-slate-50"
                        aria-label="Next page">
                        <ChevronRight :size="16" />
                    </button>
                </div>
            </div>
        </section>
    </div>
</template>