<script setup>
import {
  Bell, Search, Clock, CircleCheck, CircleX, ClipboardList, Eye, Check, X,
  Calendar, Package, ChevronDown, ChevronLeft, ChevronRight, Pill,
} from '@lucide/vue'
</script>

<template>
  <div class="min-h-screen bg-slate-50 px-6 py-6 font-sans text-slate-900">
    <!-- Page header -->
    <header class="mb-5 flex items-start justify-between">
      <div>
        <h1 class="text-xl font-semibold">Beneficiary Request</h1>
        <p class="text-sm text-slate-500">Review and manage medicine requests from beneficiaries</p>
      </div>
      <div class="flex items-center gap-4">
        <button class="text-blue-600 hover:text-blue-700" aria-label="Notifications"><Bell :size="24" /></button>
        <div class="flex items-center gap-2 rounded-full border border-slate-200 bg-white py-1 pl-1 pr-4">
          <div class="flex h-8 w-8 items-center justify-center rounded-full bg-blue-600 text-xs font-semibold text-white">PS</div>
          <span class="text-sm font-medium">Hello Paul!</span>
        </div>
      </div>
    </header>

    <!-- Summary cards (repeat per status) -->
    <section class="mb-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
      <div class="flex items-center gap-4 rounded-2xl bg-white p-5 shadow-sm">
        <span class="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-50 text-blue-600"><ClipboardList :size="22" /></span>
        <div>
          <p class="text-sm text-slate-500">Total Requests</p>
          <p class="text-2xl font-semibold">128</p>
        </div>
      </div>
      <div class="flex items-center gap-4 rounded-2xl bg-white p-5 shadow-sm">
        <span class="flex h-12 w-12 items-center justify-center rounded-xl bg-amber-50 text-amber-500"><Clock :size="22" /></span>
        <div>
          <p class="text-sm text-slate-500">Pending</p>
          <p class="text-2xl font-semibold">24</p>
        </div>
      </div>
      <div class="flex items-center gap-4 rounded-2xl bg-white p-5 shadow-sm">
        <span class="flex h-12 w-12 items-center justify-center rounded-xl bg-green-50 text-green-600"><CircleCheck :size="22" /></span>
        <div>
          <p class="text-sm text-slate-500">Approved</p>
          <p class="text-2xl font-semibold">92</p>
        </div>
      </div>
      <div class="flex items-center gap-4 rounded-2xl bg-white p-5 shadow-sm">
        <span class="flex h-12 w-12 items-center justify-center rounded-xl bg-red-50 text-red-500"><CircleX :size="22" /></span>
        <div>
          <p class="text-sm text-slate-500">Rejected</p>
          <p class="text-2xl font-semibold">12</p>
        </div>
      </div>
    </section>

    <!-- Tabs + filters -->
    <section class="rounded-2xl bg-white p-4 shadow-sm">
      <!-- Status tabs (active tab = blue) -->
      <div class="mb-4 flex flex-wrap gap-2">
        <button class="rounded-lg bg-blue-600 px-5 py-2 text-sm font-medium text-white">All</button>
        <button class="rounded-lg border border-slate-200 px-5 py-2 text-sm font-medium text-slate-600 hover:bg-slate-50">Pending</button>
        <button class="rounded-lg border border-slate-200 px-5 py-2 text-sm font-medium text-slate-600 hover:bg-slate-50">Approved</button>
        <button class="rounded-lg border border-slate-200 px-5 py-2 text-sm font-medium text-slate-600 hover:bg-slate-50">Rejected</button>
      </div>

      <div class="relative">
        <input
          type="text"
          placeholder="Search for Beneficiary Request.."
          class="w-full rounded-lg bg-slate-100 px-5 py-3 pr-12 text-sm outline-none placeholder:text-slate-400 focus:ring-2 focus:ring-blue-200"
        />
        <Search :size="18" class="absolute right-4 top-1/2 -translate-y-1/2" />
      </div>

      <div class="mt-3 flex flex-wrap items-center gap-3 text-sm text-slate-500">
        <label class="flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2"><Package :size="15" />
          <select class="bg-transparent outline-none"><option>All Categories</option></select></label>
        <label class="flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2"><Calendar :size="15" /><span>From -</span>
          <input type="date" class="bg-transparent outline-none" /></label>
        <label class="flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2"><Calendar :size="15" /><span>To -</span>
          <input type="date" class="bg-transparent outline-none" /></label>
        <label class="flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2"><Package :size="15" />
          <select class="bg-transparent outline-none"><option>All Stock Status</option></select></label>
      </div>
    </section>

    <!-- Requests table -->
    <section class="mt-4 overflow-x-auto rounded-2xl bg-white shadow-sm">
      <table class="w-full min-w-[900px] text-left text-sm">
        <thead>
          <tr class="bg-blue-600 text-xs font-semibold uppercase tracking-wide text-white">
            <th class="px-6 py-4">Request #</th>
            <th class="px-6 py-4">Beneficiary</th>
            <th class="px-6 py-4">Medicine Requested</th>
            <th class="px-6 py-4">Quantity</th>
            <th class="px-6 py-4">Date Requested</th>
            <th class="px-6 py-4">Status</th>
            <th class="px-6 py-4 text-right">Action</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          <!-- Pending row (repeat per request) -->
          <tr class="hover:bg-slate-50">
            <td class="px-6 py-4 font-semibold text-slate-600">REQ-0001</td>
            <td class="px-6 py-4">
              <p class="font-semibold text-slate-600">Marites Ocampo</p>
              <p class="text-xs text-slate-400">Senior Citizen</p>
            </td>
            <td class="px-6 py-4">
              <div class="flex items-center gap-3">
                <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-pink-50 text-pink-500"><Pill :size="18" /></span>
                <span class="font-semibold leading-tight text-slate-600">Paracetamol 500mg</span>
                <ChevronDown :size="14" class="ml-4 text-slate-500" />
              </div>
            </td>
            <td class="px-6 py-4 text-slate-500">10 pcs</td>
            <td class="px-6 py-4 text-slate-500">Oct 25, 2026</td>
            <td class="px-6 py-4">
              <span class="rounded-full bg-amber-50 px-3 py-1 text-xs font-semibold text-amber-600">Pending</span>
            </td>
            <td class="px-6 py-4">
              <div class="flex justify-end gap-2">
                <button class="flex h-9 w-9 items-center justify-center rounded-lg bg-slate-100 text-slate-600 hover:bg-slate-200" aria-label="View request"><Eye :size="18" /></button>
                <button class="flex h-9 w-9 items-center justify-center rounded-lg bg-green-50 text-green-600 hover:bg-green-100" aria-label="Approve"><Check :size="18" /></button>
                <button class="flex h-9 w-9 items-center justify-center rounded-lg bg-red-50 text-red-500 hover:bg-red-100" aria-label="Reject"><X :size="18" /></button>
              </div>
            </td>
          </tr>

          <!-- Approved row (only the view button) -->
          <tr class="hover:bg-slate-50">
            <td class="px-6 py-4 font-semibold text-slate-600">REQ-0002</td>
            <td class="px-6 py-4">
              <p class="font-semibold text-slate-600">Juan Dela Cruz</p>
              <p class="text-xs text-slate-400">PWD</p>
            </td>
            <td class="px-6 py-4">
              <div class="flex items-center gap-3">
                <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-pink-50 text-pink-500"><Pill :size="18" /></span>
                <span class="font-semibold leading-tight text-slate-600">Amoxicillin 500mg</span>
                <ChevronDown :size="14" class="ml-4 text-slate-500" />
              </div>
            </td>
            <td class="px-6 py-4 text-slate-500">21 pcs</td>
            <td class="px-6 py-4 text-slate-500">Oct 24, 2026</td>
            <td class="px-6 py-4">
              <span class="rounded-full bg-green-50 px-3 py-1 text-xs font-semibold text-green-700">Approved</span>
            </td>
            <td class="px-6 py-4">
              <div class="flex justify-end gap-2">
                <button class="flex h-9 w-9 items-center justify-center rounded-lg bg-slate-100 text-slate-600 hover:bg-slate-200" aria-label="View request"><Eye :size="18" /></button>
              </div>
            </td>
          </tr>

          <!-- Rejected row -->
          <tr class="hover:bg-slate-50">
            <td class="px-6 py-4 font-semibold text-slate-600">REQ-0003</td>
            <td class="px-6 py-4">
              <p class="font-semibold text-slate-600">Pedro Lim</p>
              <p class="text-xs text-slate-400">Indigent</p>
            </td>
            <td class="px-6 py-4">
              <div class="flex items-center gap-3">
                <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-pink-50 text-pink-500"><Pill :size="18" /></span>
                <span class="font-semibold leading-tight text-slate-600">Metronidazole 500mg</span>
                <ChevronDown :size="14" class="ml-4 text-slate-500" />
              </div>
            </td>
            <td class="px-6 py-4 text-slate-500">15 pcs</td>
            <td class="px-6 py-4 text-slate-500">Oct 23, 2026</td>
            <td class="px-6 py-4">
              <span class="rounded-full bg-red-50 px-3 py-1 text-xs font-semibold text-red-500">Rejected</span>
            </td>
            <td class="px-6 py-4">
              <div class="flex justify-end gap-2">
                <button class="flex h-9 w-9 items-center justify-center rounded-lg bg-slate-100 text-slate-600 hover:bg-slate-200" aria-label="View request"><Eye :size="18" /></button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <!-- Empty state (show when there are no results)
      <p class="px-6 py-10 text-center text-slate-400">No requests found.</p>
      -->

      <!-- Pagination -->
      <div class="flex items-center justify-between border-t border-slate-100 px-6 py-4 text-sm text-slate-500">
        <p>Showing 1 to 10 of 128 requests</p>
        <div class="flex items-center gap-2">
          <button class="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 hover:bg-slate-50" aria-label="Previous page"><ChevronLeft :size="16" /></button>
          <button class="h-9 w-9 rounded-lg bg-blue-600 text-sm font-medium text-white">1</button>
          <button class="h-9 w-9 rounded-lg border border-slate-200 text-sm hover:bg-slate-50">2</button>
          <button class="h-9 w-9 rounded-lg border border-slate-200 text-sm hover:bg-slate-50">3</button>
          <button class="flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 hover:bg-slate-50" aria-label="Next page"><ChevronRight :size="16" /></button>
        </div>
      </div>
    </section>
  </div>
</template>