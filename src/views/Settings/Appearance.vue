<script setup>
import { Palette } from '@lucide/vue'
</script>

<template>
    <div class="h-fit font-sans text-slate-900">
        <!-- Page header -->
        <header class="mb-5">
            <h1 class="flex items-center gap-2 text-xl font-bold text-slate-800">
                <Palette :size="22" /> Appearance
            </h1>
            <p class="mt-1 text-sm text-slate-500">Piliin ang tema ng iyong dashboard</p>
        </header>

        <!-- Theme options: radio inputs, so the selected state works without JS.
         Bind them with v-model="theme" (values: light, dark, system). -->
        <section class="grid max-w-3xl gap-4 sm:grid-cols-3">
            <!-- Light -->
            <label class="group block cursor-pointer">
                <input type="radio" name="theme" value="light" class="peer sr-only" checked />
                <div
                    class="overflow-hidden rounded-xl bg-white shadow-sm ring-1 ring-slate-200 transition group-hover:ring-blue-300 peer-checked:ring-2 peer-checked:ring-blue-600 peer-focus-visible:ring-2 peer-focus-visible:ring-blue-400">
                    <div class="relative h-24 w-full overflow-hidden">
                        <div class="flex h-full w-full bg-white">
                            <div class="flex w-[18%] flex-col gap-1.5 p-1.5 bg-slate-50">
                                <span class="h-1.5 w-full rounded-sm bg-blue-600"></span>
                                <span class="h-1 w-full rounded-sm bg-slate-200"></span><span
                                    class="h-1 w-full rounded-sm bg-slate-200"></span>
                                <span class="h-1 w-full rounded-sm bg-slate-200"></span><span
                                    class="h-1 w-full rounded-sm bg-slate-200"></span>
                            </div>
                            <div class="flex flex-1 flex-col gap-1.5 p-1.5">
                                <div class="grid grid-cols-4 gap-1">
                                    <span class="h-6 rounded bg-blue-600"></span>
                                    <span class="h-6 rounded bg-white border border-slate-200"></span><span
                                        class="h-6 rounded bg-white border border-slate-200"></span><span
                                        class="h-6 rounded bg-white border border-slate-200"></span>
                                </div>
                                <div class="grid flex-1 grid-cols-2 gap-1">
                                    <div class="rounded bg-white border border-slate-200"></div>
                                    <div class="flex items-end gap-0.5 rounded p-1 bg-white border border-slate-200">
                                        <span class="w-1 rounded-sm bg-blue-600" style="height:40%"></span><span
                                            class="w-1 rounded-sm bg-slate-200" style="height:70%"></span><span
                                            class="w-1 rounded-sm bg-blue-600" style="height:50%"></span><span
                                            class="w-1 rounded-sm bg-slate-200" style="height:85%"></span><span
                                            class="w-1 rounded-sm bg-blue-600" style="height:35%"></span><span
                                            class="w-1 rounded-sm bg-slate-200" style="height:60%"></span><span
                                            class="w-1 rounded-sm bg-blue-600" style="height:90%"></span><span
                                            class="w-1 rounded-sm bg-slate-200" style="height:45%"></span><span
                                            class="w-1 rounded-sm bg-blue-600" style="height:75%"></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <p class="py-2 text-center text-sm text-slate-700">Light</p>
                </div>
            </label>

            <!-- Dark -->
            <label class="group block cursor-pointer">
                <input type="radio" name="theme" value="dark" class="peer sr-only" />
                <div
                    class="overflow-hidden rounded-xl bg-white shadow-sm ring-1 ring-slate-200 transition group-hover:ring-blue-300 peer-checked:ring-2 peer-checked:ring-blue-600 peer-focus-visible:ring-2 peer-focus-visible:ring-blue-400">
                    <div class="relative h-24 w-full overflow-hidden">
                        <div class="flex h-full w-full bg-[#0f1a4a]">
                            <div class="flex w-[18%] flex-col gap-1.5 p-1.5 bg-[#16225c]">
                                <span class="h-1.5 w-full rounded-sm bg-blue-600"></span>
                                <span class="h-1 w-full rounded-sm bg-white/20"></span><span
                                    class="h-1 w-full rounded-sm bg-white/20"></span>
                                <span class="h-1 w-full rounded-sm bg-white/20"></span><span
                                    class="h-1 w-full rounded-sm bg-white/20"></span>
                            </div>
                            <div class="flex flex-1 flex-col gap-1.5 p-1.5">
                                <div class="grid grid-cols-4 gap-1">
                                    <span class="h-6 rounded bg-blue-600"></span>
                                    <span class="h-6 rounded bg-[#1b2a6b]"></span><span
                                        class="h-6 rounded bg-[#1b2a6b]"></span><span
                                        class="h-6 rounded bg-[#1b2a6b]"></span>
                                </div>
                                <div class="grid flex-1 grid-cols-2 gap-1">
                                    <div class="rounded bg-[#1b2a6b]"></div>
                                    <div class="flex items-end gap-0.5 rounded p-1 bg-[#1b2a6b]"><span
                                            class="w-1 rounded-sm bg-blue-600" style="height:40%"></span><span
                                            class="w-1 rounded-sm bg-white" style="height:70%"></span><span
                                            class="w-1 rounded-sm bg-blue-600" style="height:50%"></span><span
                                            class="w-1 rounded-sm bg-white" style="height:85%"></span><span
                                            class="w-1 rounded-sm bg-blue-600" style="height:35%"></span><span
                                            class="w-1 rounded-sm bg-white" style="height:60%"></span><span
                                            class="w-1 rounded-sm bg-blue-600" style="height:90%"></span><span
                                            class="w-1 rounded-sm bg-white" style="height:45%"></span><span
                                            class="w-1 rounded-sm bg-blue-600" style="height:75%"></span></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <p class="py-2 text-center text-sm text-slate-700">Dark</p>
                </div>
            </label>

            <!-- System -->
            <label class="group block cursor-pointer">
                <input type="radio" name="theme" value="system" class="peer sr-only" />
                <div
                    class="overflow-hidden rounded-xl bg-white shadow-sm ring-1 ring-slate-200 transition group-hover:ring-blue-300 peer-checked:ring-2 peer-checked:ring-blue-600 peer-focus-visible:ring-2 peer-focus-visible:ring-blue-400">
                    <div class="relative h-24 w-full overflow-hidden">
                        <div class="flex h-full w-full bg-white">
                            <div class="flex w-[18%] flex-col gap-1.5 p-1.5 bg-slate-50">
                                <span class="h-1.5 w-full rounded-sm bg-blue-600"></span>
                                <span class="h-1 w-full rounded-sm bg-slate-200"></span><span
                                    class="h-1 w-full rounded-sm bg-slate-200"></span>
                                <span class="h-1 w-full rounded-sm bg-slate-200"></span><span
                                    class="h-1 w-full rounded-sm bg-slate-200"></span>
                            </div>
                            <div class="flex flex-1 flex-col gap-1.5 p-1.5">
                                <div class="grid grid-cols-4 gap-1">
                                    <span class="h-6 rounded bg-blue-600"></span>
                                    <span class="h-6 rounded bg-white border border-slate-200"></span><span
                                        class="h-6 rounded bg-white border border-slate-200"></span><span
                                        class="h-6 rounded bg-white border border-slate-200"></span>
                                </div>
                                <div class="grid flex-1 grid-cols-2 gap-1">
                                    <div class="rounded bg-white border border-slate-200"></div>
                                    <div class="flex items-end gap-0.5 rounded p-1 bg-white border border-slate-200">
                                        <span class="w-1 rounded-sm bg-blue-600" style="height:40%"></span><span
                                            class="w-1 rounded-sm bg-slate-200" style="height:70%"></span><span
                                            class="w-1 rounded-sm bg-blue-600" style="height:50%"></span><span
                                            class="w-1 rounded-sm bg-slate-200" style="height:85%"></span><span
                                            class="w-1 rounded-sm bg-blue-600" style="height:35%"></span><span
                                            class="w-1 rounded-sm bg-slate-200" style="height:60%"></span><span
                                            class="w-1 rounded-sm bg-blue-600" style="height:90%"></span><span
                                            class="w-1 rounded-sm bg-slate-200" style="height:45%"></span><span
                                            class="w-1 rounded-sm bg-blue-600" style="height:75%"></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Right half shows the dark version -->
                        <div class="absolute inset-y-0 right-0 w-1/2 overflow-hidden">
                            <div class="-ml-[100%] h-full w-[200%]">
                                <div class="flex h-full w-full bg-[#0f1a4a]">
                                    <div class="flex w-[18%] flex-col gap-1.5 p-1.5 bg-[#16225c]">
                                        <span class="h-1.5 w-full rounded-sm bg-blue-600"></span>
                                        <span class="h-1 w-full rounded-sm bg-white/20"></span><span
                                            class="h-1 w-full rounded-sm bg-white/20"></span>
                                        <span class="h-1 w-full rounded-sm bg-white/20"></span><span
                                            class="h-1 w-full rounded-sm bg-white/20"></span>
                                    </div>
                                    <div class="flex flex-1 flex-col gap-1.5 p-1.5">
                                        <div class="grid grid-cols-4 gap-1">
                                            <span class="h-6 rounded bg-blue-600"></span>
                                            <span class="h-6 rounded bg-[#1b2a6b]"></span><span
                                                class="h-6 rounded bg-[#1b2a6b]"></span><span
                                                class="h-6 rounded bg-[#1b2a6b]"></span>
                                        </div>
                                        <div class="grid flex-1 grid-cols-2 gap-1">
                                            <div class="rounded bg-[#1b2a6b]"></div>
                                            <div class="flex items-end gap-0.5 rounded p-1 bg-[#1b2a6b]"><span
                                                    class="w-1 rounded-sm bg-blue-600" style="height:40%"></span><span
                                                    class="w-1 rounded-sm bg-white" style="height:70%"></span><span
                                                    class="w-1 rounded-sm bg-blue-600" style="height:50%"></span><span
                                                    class="w-1 rounded-sm bg-white" style="height:85%"></span><span
                                                    class="w-1 rounded-sm bg-blue-600" style="height:35%"></span><span
                                                    class="w-1 rounded-sm bg-white" style="height:60%"></span><span
                                                    class="w-1 rounded-sm bg-blue-600" style="height:90%"></span><span
                                                    class="w-1 rounded-sm bg-white" style="height:45%"></span><span
                                                    class="w-1 rounded-sm bg-blue-600" style="height:75%"></span></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <p class="py-2 text-center text-sm text-slate-700">System</p>
                </div>
            </label>
        </section>
    </div>
</template>