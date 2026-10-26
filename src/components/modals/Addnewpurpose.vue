<template>
    <Transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0 -translate-y-2"
        enter-to-class="opacity-100 translate-y-0" leave-active-class="transition duration-150 ease-in"
        leave-from-class="opacity-100 translate-y-0" leave-to-class="opacity-0 -translate-y-2">
        <section v-if="IsOpen"
            class="fixed inset-0 z-50 flex h-full w-full items-center justify-center overflow-y-auto bg-black/40 backdrop-blur-xs p-4">
            <div class="max-h-[calc(100vh-2rem)] w-full max-w-2xl overflow-y-auto rounded-xl bg-white p-6 font-inter shadow-xl">
                <div class="flex items-start justify-between">
                    <div>
                        <h1 class="font-inter text-2xl font-bold text-[#404040]">Add Purpose</h1>
                        <p class="font-inter text-sm font-medium text-[#808080]">
                            Add a purpose for dispensing.
                        </p>
                    </div>
                    <button type="button" aria-label="Close"
                        class="text-gray-400 transition hover:text-[#404040]" @click="emit('close')">
                        <X :size="22" />
                    </button>
                </div>

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