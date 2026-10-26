<script setup>
import { X } from '@lucide/vue'

defineProps({
    IsOpen: Boolean
})

const emit = defineEmits(['close'])
</script>

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

                <div class="mt-6 grid grid-cols-1 gap-4">
                    <div class="grid gap-1">
                        <label for="purpose-name" class="font-inter text-sm font-medium text-[#404040]">
                            Purpose name
                        </label>
                        <input id="purpose-name" type="text" placeholder="e.g. Fever"
                            class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700">
                    </div>

                    <div class="grid gap-1">
                        <label for="purpose-desc" class="font-inter text-sm font-medium text-[#404040]">
                            Short description
                        </label>
                        <input id="purpose-desc" type="text" placeholder="e.g. For reducing fever"
                            class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700">
                    </div>
                </div>

                <div class="mt-6 flex flex-col-reverse justify-end gap-2 border-t border-gray-100 pt-4 sm:flex-row">
                    <button type="button" @click="emit('close')"
                        class="cursor-pointer rounded-xl bg-gray-100 p-2 px-4 text-[#404040] transition hover:bg-gray-200">
                        Cancel
                    </button>
                    <button type="button"
                        class="cursor-pointer rounded-xl bg-blue-700 p-2 px-5 text-white transition hover:bg-blue-800">
                        Save Purpose
                    </button>
                </div>
            </div>
        </section>
    </Transition>
</template>
