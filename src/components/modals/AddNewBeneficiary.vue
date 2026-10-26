<script setup>
import { X } from '@lucide/vue'

defineProps({
  IsOpen: Boolean
})

const emit = defineEmits(['close'])
</script>

<template>
  <Transition
    enter-active-class="transition duration-200 ease-out"
    enter-from-class="opacity-0 -translate-y-2"
    enter-to-class="opacity-100 translate-y-0"
    leave-active-class="transition duration-150 ease-in"
    leave-from-class="opacity-100 translate-y-0"
    leave-to-class="opacity-0 -translate-y-2"
  >
    <section
      v-if="IsOpen"
      class="fixed inset-0 z-50 flex h-full w-full items-center justify-center overflow-y-auto bg-black/40 backdrop-blur-xs p-4"
    >
      <div class="max-h-[calc(100vh-2rem)] w-full max-w-2xl overflow-y-auto rounded-xl bg-white p-6 font-inter shadow-xl">
        <div class="flex items-start justify-between">
          <div>
            <h1 class="font-inter text-2xl font-bold text-[#404040]">Add New Beneficiary</h1>
            <p class="font-inter text-sm font-medium text-[#808080]">
              Register a beneficiary in your records.
            </p>
          </div>
          <button
            type="button"
            aria-label="Close"
            class="text-gray-400 transition hover:text-[#404040]"
            @click="emit('close')"
          >
            <X :size="22" />
          </button>
        </div>

        <div class="mt-6 grid grid-cols-1 gap-6">
          <section class="grid gap-2">
            <h2 class="font-inter text-lg font-semibold text-[#404040]">Identity</h2>

            <div class="mt-2 grid grid-cols-1 gap-3 sm:grid-cols-2">
              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">
                  First name <span class="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                  placeholder="e.g. Juan"
                  required
                >
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Middle name</label>
                <input
                  type="text"
                  class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                  placeholder="Middle name"
                >
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">
                  Last name <span class="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                  placeholder="e.g. Dela Cruz"
                  required
                >
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Suffix</label>
                <select
                  class="w-full cursor-pointer rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                >
                  <option value="">None</option>
                  <option>Jr.</option>
                  <option>Sr.</option>
                  <option>III</option>
                </select>
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Beneficiary ID</label>
                <input
                  type="text"
                  class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                  placeholder="Enter beneficiary ID"
                >
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Beneficiary type</label>
                <select
                  class="w-full cursor-pointer rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                >
                  <option value="">Select beneficiary type</option>
                  <option>Senior Citizen</option>
                  <option>PWD</option>
                  <option>Indigent</option>
                  <option>Minor</option>
                </select>
              </div>
            </div>
          </section>

          <section class="grid gap-2 border-t border-gray-100 pt-5">
            <h2 class="font-inter text-lg font-semibold text-[#404040]">Personal Details</h2>

            <div class="mt-2 grid grid-cols-1 gap-3 sm:grid-cols-3">
              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Sex</label>
                <select
                  class="w-full cursor-pointer rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                >
                  <option value="">Select sex</option>
                  <option>Male</option>
                  <option>Female</option>
                </select>
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Birth date</label>
                <input
                  type="date"
                  class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                >
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Age</label>
                <input
                  type="text"
                  readonly
                  placeholder="Calculated from birth date"
                  class="w-full cursor-not-allowed rounded-lg border border-gray-200 bg-gray-100 p-2 text-slate-600"
                >
              </div>
            </div>
          </section>

          <section class="grid gap-2 border-t border-gray-100 pt-5">
            <h2 class="font-inter text-lg font-semibold text-[#404040]">Contact and Location</h2>

            <div class="mt-2 grid grid-cols-1 gap-3">
              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Address</label>
                <input
                  type="text"
                  class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                  placeholder="House number, street, and subdivision"
                >
              </div>
            </div>

            <div class="mt-1 grid grid-cols-1 gap-3 sm:grid-cols-2">
              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Barangay</label>
                <select
                  class="w-full cursor-pointer rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                >
                  <option value="">Select barangay</option>
                  <option>Calumpang</option>
                  <option>Darangan</option>
                  <option>Libid</option>
                  <option>Poblacion</option>
                </select>
              </div>

              <div class="grid gap-1">
                <label class="font-inter text-sm font-medium text-[#404040]">Contact number</label>
                <input
                  type="tel"
                  class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700"
                  placeholder="e.g. 09XXXXXXXXX"
                >
              </div>
            </div>
          </section>
        </div>

        <div class="mt-6 flex flex-col-reverse justify-end gap-3 border-t border-gray-100 pt-4 sm:flex-row">
          <button
            type="button"
            class="rounded-lg border border-gray-200 px-5 py-2.5 text-sm font-medium text-gray-600 transition hover:bg-gray-50"
            @click="emit('close')"
          >
            Cancel
          </button>
          <button
            type="button"
            class="rounded-lg bg-blue-700 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-blue-800"
          >
            Save Beneficiary
          </button>
        </div>
      </div>
    </section>
  </Transition>
</template>
