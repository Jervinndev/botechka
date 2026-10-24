<template>
    <section class="w-full min-w-0 font-inter">
        <!-- HEADER -->
        <div class="border-b border-gray-100">
            <h1 class="text-lg font-bold text-gray-800">Notifications</h1>
            <p class="text-xs text-gray-500">Stay up to date with activity across your workspace.</p>
        </div>

        <!-- SEARCH AND ACTIONS -->
        <div
            class="flex flex-col gap-3 border-b border-gray-100 bg-gray-50/50 py-3 sm:flex-row sm:items-center sm:justify-between">
            <div class="relative w-full sm:max-w-md">
                <input type="text" placeholder="Search Notifications"
                    class="w-full rounded-md border border-gray-200 bg-white py-2 pl-3 pr-10 text-xs text-gray-700 outline-none placeholder:text-gray-400 focus:border-blue-400" />
                <icon name="search" size="15" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-600" />
            </div>

            <div class="flex flex-wrap items-center gap-2">
                <button
                    class="flex items-center gap-2 rounded-md border border-gray-200 bg-white px-3 py-2 text-xs text-gray-700 transition hover:bg-gray-50">
                    <icon name="sliders-horizontal" size="14" />
                    Preferences
                </button>
                <button
                    class="flex items-center gap-2 rounded-md bg-blue-700 px-3 py-2 text-xs font-medium text-white transition hover:bg-blue-700">
                    <icon name="check-check" size="14" />
                    Mark all as read
                </button>
            </div>
        </div>

        <!-- NOTIFICATION PANEL -->
        <div class="overflow-hidden rounded-xl border border-gray-200 bg-white">
            <!-- TABS -->
            <div class="flex items-center gap-5 overflow-x-auto border-b border-gray-100 px-4 sm:px-6">
                <button
                    class="flex shrink-0 items-center gap-1.5 border-b-2 border-[#2638ff] py-4 text-xs font-medium text-gray-800">
                    All
                    <span class="rounded-full bg-indigo-50 px-1.5 py-0.5 text-[10px] text-indigo-500">12</span>
                </button>
                <button
                    class="shrink-0 border-b-2 border-transparent py-4 text-xs text-gray-500 transition hover:text-blue-600">Mentions</button>
                <button
                    class="shrink-0 border-b-2 border-transparent py-4 text-xs text-gray-500 transition hover:text-blue-600">System</button>
                <button
                    class="shrink-0 border-b-2 border-transparent py-4 text-xs text-gray-500 transition hover:text-blue-600">Updates</button>
            </div>

            <!-- TODAY LABEL -->
            <div class="flex items-center justify-between px-4 pb-2 pt-3 sm:px-6">
                <p class="text-[10px] font-medium uppercase tracking-wider text-slate-400">Today</p>
                <p class="text-[10px] text-[#2638ff]">3 unread</p>
            </div>

            <!-- NOTIFICATION 1 -->
            <div
                class="group flex items-start gap-3 border-b border-gray-100 bg-slate-50/70 px-4 py-4 transition hover:bg-gray-50 sm:px-6">
                <div class="flex h-8 w-8 shrink-0 items-center justify-center overflow-hidden rounded-full bg-gray-100">
                    <img src="/src/assets/download (12).jpg" alt="Mark" class="h-full w-full object-cover" />
                </div>

                <div class="min-w-0 flex-1">
                    <p class="text-xs font-medium text-gray-800">Mark added new stock</p>
                    <p class="mt-1 text-[11px] leading-4 text-slate-500">100 units of Paracetamol 500 mg were added to
                        inventory.</p>
                    <button
                        class="mt-2 rounded-md border border-gray-200 bg-white px-2.5 py-1 text-[10px] text-gray-700 transition hover:border-blue-300 hover:text-blue-600">Show
                        inventory</button>
                </div>

                <div class="flex shrink-0 items-center gap-2 pt-1">
                    <span class="text-[10px] text-slate-400">8 min</span>
                    <span class="h-1.5 w-1.5 rounded-full bg-indigo-500"></span>
                    <button aria-label="Notification options" class="ml-1 text-slate-400 hover:text-gray-700">
                        <icon name="menu" size="14" />
                    </button>
                </div>
            </div>

            <!-- NOTIFICATION 2 -->
            <div
                class="group flex items-start gap-3 border-b border-gray-100 bg-slate-50/70 px-4 py-4 transition hover:bg-gray-50 sm:px-6">
                <div
                    class="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-emerald-50 text-emerald-600">
                    <icon name="download" size="17" />
                </div>

                <div class="min-w-0 flex-1">
                    <p class="text-xs font-medium text-gray-800">Report generated</p>
                    <p class="mt-1 text-[11px] leading-4 text-slate-500">Your Monthly Dispensing Report is ready to
                        view.</p>
                    <button
                        class="mt-2 rounded-md border border-gray-200 bg-white px-2.5 py-1 text-[10px] text-gray-700 transition hover:border-blue-300 hover:text-blue-600">Download
                        PDF</button>
                </div>

                <div class="flex shrink-0 items-center gap-2 pt-1">
                    <span class="text-[10px] text-slate-400">42 min</span>
                    <span class="h-1.5 w-1.5 rounded-full bg-indigo-500"></span>
                    <button aria-label="Notification options" class="ml-1 text-slate-400 hover:text-gray-700">
                        <icon name="menu" size="14" />
                    </button>
                </div>
            </div>

            <!-- NOTIFICATION 3 -->
            <div
                class="group flex items-start gap-3 border-b border-gray-100 bg-slate-50/70 px-4 py-4 transition hover:bg-gray-50 sm:px-6">
                <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-amber-50 text-amber-600">
                    <icon name="shield-check" size="17" />
                </div>

                <div class="min-w-0 flex-1">
                    <p class="text-xs font-medium text-gray-800">New sign-in to your account</p>
                    <p class="mt-1 text-[11px] leading-4 text-slate-500">We noticed a sign-in from Chrome on macOS in
                        Binangonan, Rizal.</p>
                    <button
                        class="mt-2 rounded-md border border-gray-200 bg-white px-2.5 py-1 text-[10px] text-gray-700 transition hover:border-blue-300 hover:text-blue-600">Review
                        activity</button>
                </div>

                <div class="flex shrink-0 items-center gap-2 pt-1">
                    <span class="text-[10px] text-slate-400">2 hr</span>
                    <span class="h-1.5 w-1.5 rounded-full bg-indigo-500"></span>
                    <button aria-label="Notification options" class="ml-1 text-slate-400 hover:text-gray-700">
                        <icon name="menu" size="14" />
                    </button>
                </div>
            </div>

            <!-- EARLIER LABEL -->
            <div class="px-4 pb-2 pt-4 sm:px-6">
                <p class="text-[10px] font-medium uppercase tracking-wider text-slate-400">Earlier</p>
            </div>

            <!-- NOTIFICATION 4 -->
            <div
                class="group flex items-start gap-3 border-b border-gray-100 bg-white px-4 py-4 transition hover:bg-gray-50 sm:px-6">
                <div class="flex h-8 w-8 shrink-0 items-center justify-center overflow-hidden rounded-full bg-gray-100">
                    <img src="/src/assets/download (12).jpg" alt="Mark" class="h-full w-full object-cover" />
                </div>

                <div class="min-w-0 flex-1">
                    <p class="text-xs font-medium text-gray-800">Mark archived a medicine</p>
                    <p class="mt-1 text-[11px] leading-4 text-slate-500">Paracetamol 500 mg was moved to the archive.
                    </p>
                    <button
                        class="mt-2 rounded-md border border-gray-200 bg-white px-2.5 py-1 text-[10px] text-gray-700 transition hover:border-blue-300 hover:text-blue-600">View
                        task</button>
                </div>

                <div class="flex shrink-0 items-center gap-2 pt-1">
                    <span class="text-[10px] text-slate-400">Yesterday</span>
                    <button aria-label="Notification options" class="ml-1 text-slate-400 hover:text-gray-700">
                        <icon name="menu" size="14" />
                    </button>
                </div>
            </div>

            <!-- NOTIFICATION 5 -->
            <div
                class="group flex items-start gap-3 border-b border-gray-100 bg-white px-4 py-4 transition hover:bg-gray-50 sm:px-6">
                <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-violet-50 text-violet-500">
                    <icon name="chart-no-axes-column" size="17" />
                </div>

                <div class="min-w-0 flex-1">
                    <p class="text-xs font-medium text-gray-800">Dispensing Completed</p>
                    <p class="mt-1 text-[11px] leading-4 text-slate-500">A dispensing transaction for 3 medicines was
                        successfully recorded.</p>
                    <button
                        class="mt-2 rounded-md border border-gray-200 bg-white px-2.5 py-1 text-[10px] text-gray-700 transition hover:border-blue-300 hover:text-blue-600">View
                        transaction</button>
                </div>

                <div class="flex shrink-0 items-center gap-2 pt-1">
                    <span class="text-[10px] text-slate-400">Mon</span>
                    <button aria-label="Notification options" class="ml-1 text-slate-400 hover:text-gray-700">
                        <icon name="menu" size="14" />
                    </button>
                </div>
            </div>

            <!-- NOTIFICATION 6 -->
            <div class="group flex items-start gap-3 bg-white px-4 py-4 transition hover:bg-gray-50 sm:px-6">
                <div
                    class="flex h-8 w-8 shrink-0 items-center justify-center rounded-xl bg-emerald-50 text-emerald-600">
                    <icon name="calendar-check" size="17" />
                </div>

                <div class="min-w-0 flex-1">
                    <p class="text-xs font-medium text-gray-800">Medicine Expiring Soon</p>
                    <p class="mt-1 text-[11px] leading-4 text-slate-500">Paracetamol 500 mg will expire in 30 days.
                        Review the batch in inventory.</p>
                </div>

                <div class="flex shrink-0 items-center gap-2 pt-1">
                    <span class="text-[10px] text-slate-400">Sep 11</span>
                    <button aria-label="Notification options" class="ml-1 text-slate-400 hover:text-gray-700">
                        <icon name="menu" size="14" />
                    </button>
                </div>
            </div>
        </div>
    </section>
</template>
