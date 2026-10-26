<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center p-4">
    <div class="absolute inset-0 bg-slate-900/40"></div>
    <div class="relative w-full max-w-lg rounded-2xl bg-white p-7 shadow-xl" role="dialog" aria-modal="true">
      <h3 class="text-xl font-semibold">Add Purpose</h3>
      <p class="mb-5 text-sm text-slate-400">Add a purpose for dispensing</p>

      <label class="mb-2 block text-lg font-semibold text-slate-700" for="purpose-name">Purpose Name</label>
      <input
        id="purpose-name"
        type="text"
        placeholder="e.g. FEVER"
        class="mb-4 w-full rounded-lg border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none placeholder:text-slate-400 focus:border-blue-500"
      />

      <label class="mb-2 block text-lg font-semibold text-slate-700" for="purpose-desc">Short description</label>
      <input
        id="purpose-desc"
        type="text"
        placeholder="e.g. For reducing fever"
        class="mb-6 w-full rounded-lg border border-slate-200 bg-slate-50 px-4 py-3 text-sm outline-none placeholder:text-slate-400 focus:border-blue-500"
      />

      <div class="flex justify-end gap-3">
        <button class="rounded-lg border border-slate-200 px-6 py-2.5 text-sm font-medium hover:bg-slate-50">Cancel</button>
        <button class="rounded-lg bg-blue-600 px-6 py-2.5 text-sm font-medium text-white hover:bg-blue-700">Save</button>
      </div>
    </div>
  </div>
  <AddNewPurpose/>
</template>