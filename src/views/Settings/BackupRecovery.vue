<script setup>
import {
    DatabaseBackup, CircleCheck, CalendarClock, Calendar, Cloud, HardDrive, Save,
    ShieldCheck, Database, ArrowRight, ArrowUpRight, Download, RotateCcw, CloudUpload,
    History, Eye, Info, ChevronDown, Lock,
} from '@lucide/vue'
</script>

<template>
    <div class="min-h-screen font-sans text-slate-900">
        <!-- Page header -->
        <header class="mb-5">
            <h1 class="flex items-center gap-2 text-xl font-bold">
                <DatabaseBackup :size="22" /> Backup &amp; Recovery
            </h1>
            <p class="mt-2 text-sm text-slate-600">
                <span>Last backup: <span class="font-semibold text-slate-900">2 hours ago</span></span>
                <span class="ml-5">Next scheduled backup: <span class="font-semibold text-slate-900">in 22
                        hours</span></span>
            </p>
            <p class="mt-2 flex items-center gap-2 text-sm font-medium text-emerald-600">
                <CircleCheck :size="16" /> Your latest backup was completed successfully.
            </p>
        </header>

        <!-- Automatic backup -->
        <section class="mb-5 rounded-2xl border border-slate-200 bg-white p-6 ">
            <div class="mb-5 flex items-start justify-between">
                <div class="flex items-center gap-3">
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
                        <CalendarClock :size="20" />
                    </span>
                    <div>
                        <h2 class="font-semibold">Automatic backup</h2>
                        <p class="text-xs text-slate-500">Set the backup schedule</p>
                    </div>
                </div>

                <!-- Toggle (CSS only: checked = on) -->
                <label class="flex cursor-pointer items-center gap-2 text-xs font-medium text-slate-600">
                    Enabled
                    <input type="checkbox" class="peer sr-only" checked />
                    <span
                        class="relative h-5 w-9 rounded-full bg-slate-300 transition peer-checked:bg-blue-600 after:absolute after:left-0.5 after:top-0.5 after:h-4 after:w-4 after:rounded-full after:bg-white after:transition after:content-[''] peer-checked:after:translate-x-4"></span>
                </label>
            </div>

            <div class="mb-5 grid gap-4 md:grid-cols-2">
                <div>
                    <label class="mb-1.5 block text-xs font-semibold text-slate-700">Frequency</label>
                    <div
                        class="relative flex items-center gap-2 rounded-lg border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm">
                        <Calendar :size="16" class="text-slate-600" />
                        <select class="w-full appearance-none bg-transparent pr-6 outline-none">
                            <option>Every 24 hours</option>
                            <option>Every 12 hours</option>
                            <option>Every week</option>
                        </select>
                        <ChevronDown :size="14" class="pointer-events-none absolute right-3" />
                    </div>
                </div>
                <div>
                    <label for="backup-start-time" class="mb-1.5 block text-xs font-semibold text-slate-700">Start time</label>
                    <input id="backup-start-time" type="time" value="06:00"
                        class="settings-picker w-full px-3 py-2.5 text-sm" />
                </div>
            </div>

            <div class="flex flex-wrap items-center justify-between gap-4">
                <div class="flex items-center gap-6">
                    <!-- Destination toggles -->
                    <label class="flex cursor-pointer items-center gap-2 text-sm text-slate-600">
                        <Cloud :size="18" class="text-blue-600" /> Cloud
                        <input type="checkbox" class="peer sr-only" />
                        <span
                            class="relative h-5 w-9 rounded-full bg-slate-300 transition peer-checked:bg-blue-600 after:absolute after:left-0.5 after:top-0.5 after:h-4 after:w-4 after:rounded-full after:bg-white after:transition after:content-[''] peer-checked:after:translate-x-4"></span>
                    </label>
                    <label class="flex cursor-pointer items-center gap-2 text-sm text-slate-600">
                        <HardDrive :size="18" class="text-blue-600" /> Local
                        <input type="checkbox" class="peer sr-only" checked />
                        <span
                            class="relative h-5 w-9 rounded-full bg-slate-300 transition peer-checked:bg-blue-600 after:absolute after:left-0.5 after:top-0.5 after:h-4 after:w-4 after:rounded-full after:bg-white after:transition after:content-[''] peer-checked:after:translate-x-4"></span>
                    </label>
                </div>

                <button
                    class="flex items-center gap-2 rounded-lg bg-blue-600 px-5 py-2.5 text-sm font-medium text-white hover:bg-blue-700">
                    <Save :size="16" /> Save schedule
                </button>
            </div>
        </section>

        <!-- Database backup overview -->
        <section class="mb-5 rounded-2xl border border-slate-200 bg-white p-6 ">
            <div class="mb-5 flex items-start justify-between gap-4">
                <div>
                    <h2 class="font-semibold">Database backup overview</h2>
                    <p class="text-xs text-slate-500">These verified backup copies are stored in different recovery
                        locations.</p>
                </div>
                <span class="flex items-center gap-1.5 text-xs font-medium text-blue-600">
                    <ShieldCheck :size="14" /> Verified 2 hours ago
                </span>
            </div>

            <!-- Flow: main database -> cloud copy -> local recovery -->
            <div class="mb-4 grid items-center gap-3 md:grid-cols-[1fr_auto_1fr_auto_1fr]">
                <div class="flex items-center justify-between rounded-xl border border-slate-200 p-4">
                    <div class="flex items-center gap-3">
                        <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-50 text-blue-600">
                            <Database :size="18" />
                        </span>
                        <div>
                            <p class="text-sm font-semibold">Main database</p>
                            <p class="text-xs text-slate-500">Supabase</p>
                        </div>
                    </div>
                    <span
                        class="rounded-full bg-blue-600 px-2.5 py-0.5 text-[10px] font-semibold text-white">Connected</span>
                </div>

                <ArrowRight :size="16" class="mx-auto text-slate-400" />

                <div class="flex items-center justify-between rounded-xl border border-slate-200 p-4">
                    <div class="flex items-center gap-3">
                        <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-50 text-blue-600">
                            <Cloud :size="18" />
                        </span>
                        <div>
                            <p class="text-sm font-semibold">Cloud copy</p>
                            <p class="text-xs text-slate-500">Encrypted</p>
                        </div>
                    </div>
                    <span
                        class="rounded-full bg-blue-600 px-2.5 py-0.5 text-[10px] font-semibold text-white">Current</span>
                </div>

                <ArrowRight :size="16" class="mx-auto text-slate-400" />

                <div class="flex items-center justify-between rounded-xl border border-slate-200 p-4">
                    <div class="flex items-center gap-3">
                        <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-50 text-blue-600">
                            <HardDrive :size="18" />
                        </span>
                        <div>
                            <p class="text-sm font-semibold">Local recovery</p>
                            <p class="text-xs text-slate-500">On-site recovery</p>
                        </div>
                    </div>
                    <span
                        class="rounded-full bg-blue-600 px-2.5 py-0.5 text-[10px] font-semibold text-white">Current</span>
                </div>
            </div>

            <!-- Quick actions -->
            <div class="grid gap-4 md:grid-cols-3">
                <button
                    class="rounded-xl border border-slate-200 p-4 text-left hover:border-blue-300 hover:bg-blue-50/40">
                    <div class="mb-6 flex items-start justify-between">
                        <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-50 text-blue-600">
                            <Download :size="18" />
                        </span>
                        <ArrowUpRight :size="16" class="text-blue-600" />
                    </div>
                    <p class="text-sm font-semibold">Export backup</p>
                    <p class="text-xs text-slate-500">Download an encrypted archive.</p>
                </button>

                <button
                    class="rounded-xl border border-slate-200 p-4 text-left hover:border-blue-300 hover:bg-blue-50/40">
                    <div class="mb-6 flex items-start justify-between">
                        <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-50 text-blue-600">
                            <RotateCcw :size="18" />
                        </span>
                        <ArrowUpRight :size="16" class="text-blue-600" />
                    </div>
                    <p class="text-sm font-semibold">Quick restore</p>
                    <p class="text-xs text-slate-500">Restore the latest valid copy.</p>
                </button>

                <button
                    class="rounded-xl border border-slate-200 p-4 text-left hover:border-blue-300 hover:bg-blue-50/40">
                    <div class="mb-6 flex items-start justify-between">
                        <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-50 text-blue-600">
                            <CloudUpload :size="18" />
                        </span>
                        <ArrowUpRight :size="16" class="text-blue-600" />
                    </div>
                    <p class="text-sm font-semibold">Restore from file</p>
                    <p class="text-xs text-slate-500">Upload a recovery archive.</p>
                </button>
            </div>
        </section>

        <!-- Backup history -->
        <section class="overflow-hidden rounded-2xl border border-slate-200 bg-white ">
            <div class="flex flex-wrap items-start justify-between gap-4 p-6 pb-4">
                <div class="flex items-center gap-3">
                    <span class="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-50 text-blue-600">
                        <History :size="20" />
                    </span>
                    <div>
                        <h2 class="font-semibold">Backup history</h2>
                        <p class="text-xs text-slate-500">Review automatic backups, exports, and restore activity.</p>
                    </div>
                </div>
            </div>

            <div class="flex gap-3 px-6 pb-4">
                <label
                    class="relative flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2 text-xs font-medium text-slate-700">
                    <Calendar :size="14" />
                    <select class="appearance-none bg-transparent pr-5 outline-none">
                        <option>Last 7 days</option>
                        <option>Last 30 days</option>
                        <option>Last 90 days</option>
                    </select>
                    <ChevronDown :size="12" class="pointer-events-none absolute right-3" />
                </label>
                <button
                    class="flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2 text-xs font-medium text-slate-700 hover:bg-slate-50">
                    <Download :size="14" /> Export log
                </button>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full min-w-[800px] text-left text-sm">
                    <thead>
                        <tr
                            class="border-y border-slate-200 bg-slate-50 text-[11px] font-semibold uppercase tracking-wide text-slate-500">
                            <th class="px-6 py-3">Date &amp; time</th>
                            <th class="px-6 py-3">Type</th>
                            <th class="px-6 py-3">Destination</th>
                            <th class="px-6 py-3">Status</th>
                            <th class="px-6 py-3">Size</th>
                            <th class="px-6 py-3 text-center">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <!-- History row (repeat per backup) -->
                        <tr class="hover:bg-slate-50">
                            <td class="px-6 py-3">
                                <p class="font-semibold">Sep 27, 2026</p>
                                <p class="text-xs text-slate-500">06:00 AM</p>
                            </td>
                            <td class="px-6 py-3"><span class="flex items-center gap-2">
                                    <CloudUpload :size="16" class="text-blue-600" /> Automatic backup
                                </span></td>
                            <td class="px-6 py-3"><span class="flex items-center gap-2 text-slate-600">
                                    <Cloud :size="16" /> Cloud + local
                                </span></td>
                            <td class="px-6 py-3"><span
                                    class="inline-flex items-center gap-1.5 rounded-full bg-emerald-100 px-3 py-1 text-xs font-semibold text-emerald-700"><span
                                        class="h-1.5 w-1.5 rounded-full bg-emerald-500"></span>Success</span></td>
                            <td class="px-6 py-3 text-slate-600">1.8 GB</td>
                            <td class="px-6 py-3 text-center"><button class="text-blue-600 hover:text-blue-800"
                                    aria-label="View details">
                                    <Eye :size="18" />
                                </button></td>
                        </tr>
                        <tr class="hover:bg-slate-50">
                            <td class="px-6 py-3">
                                <p class="font-semibold">Sep 26, 2026</p>
                                <p class="text-xs text-slate-500">06:00 AM</p>
                            </td>
                            <td class="px-6 py-3"><span class="flex items-center gap-2">
                                    <CloudUpload :size="16" class="text-blue-600" /> Automatic backup
                                </span></td>
                            <td class="px-6 py-3"><span class="flex items-center gap-2 text-slate-600">
                                    <Cloud :size="16" /> Cloud + local
                                </span></td>
                            <td class="px-6 py-3"><span
                                    class="inline-flex items-center gap-1.5 rounded-full bg-emerald-100 px-3 py-1 text-xs font-semibold text-emerald-700"><span
                                        class="h-1.5 w-1.5 rounded-full bg-emerald-500"></span>Success</span></td>
                            <td class="px-6 py-3 text-slate-600">1.8 GB</td>
                            <td class="px-6 py-3 text-center"><button class="text-blue-600 hover:text-blue-800"
                                    aria-label="View details">
                                    <Eye :size="18" />
                                </button></td>
                        </tr>
                        <tr class="hover:bg-slate-50">
                            <td class="px-6 py-3">
                                <p class="font-semibold">Sep 25, 2026</p>
                                <p class="text-xs text-slate-500">02:22 PM</p>
                            </td>
                            <td class="px-6 py-3"><span class="flex items-center gap-2">
                                    <RotateCcw :size="16" class="text-blue-600" /> Manual restore
                                </span></td>
                            <td class="px-6 py-3"><span class="flex items-center gap-2 text-slate-600">
                                    <HardDrive :size="16" /> Local recovery
                                </span></td>
                            <td class="px-6 py-3"><span
                                    class="inline-flex items-center gap-1.5 rounded-full bg-emerald-100 px-3 py-1 text-xs font-semibold text-emerald-700"><span
                                        class="h-1.5 w-1.5 rounded-full bg-emerald-500"></span>Success</span></td>
                            <td class="px-6 py-3 text-slate-600">1.7 GB</td>
                            <td class="px-6 py-3 text-center"><button class="text-blue-600 hover:text-blue-800"
                                    aria-label="View details">
                                    <Eye :size="18" />
                                </button></td>
                        </tr>
                        <!-- Failed row -->
                        <tr class="hover:bg-slate-50">
                            <td class="px-6 py-3">
                                <p class="font-semibold">Sep 25, 2026</p>
                                <p class="text-xs text-slate-500">06:00 AM</p>
                            </td>
                            <td class="px-6 py-3"><span class="flex items-center gap-2">
                                    <CloudUpload :size="16" class="text-blue-600" /> Automatic backup
                                </span></td>
                            <td class="px-6 py-3"><span class="flex items-center gap-2 text-slate-600">
                                    <Cloud :size="16" /> Cloud + local
                                </span></td>
                            <td class="px-6 py-3"><span
                                    class="inline-flex items-center gap-1.5 rounded-full bg-red-100 px-3 py-1 text-xs font-semibold text-red-600"><span
                                        class="h-1.5 w-1.5 rounded-full bg-red-500"></span>Failed</span></td>
                            <td class="px-6 py-3 text-slate-400">—</td>
                            <td class="px-6 py-3 text-center"><button class="text-blue-600 hover:text-blue-800"
                                    aria-label="View details">
                                    <Eye :size="18" />
                                </button></td>
                        </tr>
                        <tr class="hover:bg-slate-50">
                            <td class="px-6 py-3">
                                <p class="font-semibold">Sep 24, 2026</p>
                                <p class="text-xs text-slate-500">02:15 PM</p>
                            </td>
                            <td class="px-6 py-3"><span class="flex items-center gap-2">
                                    <Download :size="16" class="text-blue-600" /> Export backup
                                </span></td>
                            <td class="px-6 py-3"><span class="flex items-center gap-2 text-slate-600">
                                    <Lock :size="16" /> Secure download
                                </span></td>
                            <td class="px-6 py-3"><span
                                    class="inline-flex items-center gap-1.5 rounded-full bg-emerald-100 px-3 py-1 text-xs font-semibold text-emerald-700"><span
                                        class="h-1.5 w-1.5 rounded-full bg-emerald-500"></span>Success</span></td>
                            <td class="px-6 py-3 text-slate-600">1.8 GB</td>
                            <td class="px-6 py-3 text-center"><button class="text-blue-600 hover:text-blue-800"
                                    aria-label="View details">
                                    <Eye :size="18" />
                                </button></td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <p class="flex items-center gap-2 border-t border-slate-100 px-6 py-4 text-xs text-slate-500">
                <Info :size="14" /> Retention policy keeps daily recovery points for 30 days and monthly archives for 12
                months.
            </p>
        </section>
    </div>
</template>