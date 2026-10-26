<script setup>
import { ref, computed } from 'vue'
import { addCategory } from '../../services/Medicines.js'

const props = defineProps({
    IsOpen: Boolean
})

const emit = defineEmits(['close', 'category-added'])

const categoryName = ref('')
const categoryDescription = ref('')
const loading = ref(false)

const isTyping = computed(() => {
    return categoryName.value.trim() !== '' || categoryDescription.value.trim() !== ''
})

async function handleSave() {
    if (!categoryName.value.trim()) {
        alert('Please enter a category name.')
        return
    }

    loading.value = true

    const { data, error } = await addCategory({
        name: categoryName.value,
        description: categoryDescription.value
    })

    loading.value = false

    if (error) {
        alert('Failed to save category. Please try again.')
    } else {
        // Reset fields
        categoryName.value = ''
        categoryDescription.value = ''

        // I-emit para ma-notify ang parent component
        emit('category-added', data)
        emit('close')
    }
}
</script>

<template>
    <Transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0 -translate-y-2"
        enter-to-class="opacity-100 translate-y-0" leave-active-class="transition duration-100 ease-in"
        leave-from-class="opacity-100 translate-y-0" leave-to-class="opacity-0 -translate-y-2">
        <section v-if="IsOpen"
            class="fixed inset-0 z-50 flex h-full w-full items-center justify-center overflow-y-auto bg-black/40 p-4 font-inter">
            <div class="max-h-[calc(100vh-2rem)] w-full max-w-md overflow-y-auto rounded-xl bg-white p-6">
                <div>
                    <h1 class="mt-2 font-inter text-2xl font-bold text-[#404040]">Add Categories</h1>
                    <p class="font-inter text-sm font-medium text-[#808080]">Add a new category to your inventory</p>
                </div>

                <div class="grid gap-2 mt-6">
                    <label for="category-name" class="font-inter text-sm font-medium text-[#404040]">Category Name</label>
                    <input v-model="categoryName" type="text" id="category-name" placeholder="Enter category name"
                        class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700" />
                </div>

                <div class="grid gap-2 mt-4">
                    <label for="category-description" class="font-inter text-sm font-medium text-[#404040]">Category Description</label>
                    <input v-model="categoryDescription" type="text" id="category-description"
                        placeholder="Enter category description"
                        class="w-full rounded-lg border border-gray-200 bg-gray-50 p-2 focus:outline-none focus:ring-2 focus:ring-blue-700" />
                </div>

                <!-- Lilitaw lamang ang Preview kapag nagsimula nang mag-type ang user -->
                <div v-if="isTyping" class="mt-6 transition-all duration-300">
                    <h1 class="font-inter text-sm font-medium text-[#404040]">Preview</h1>
                    <div class="mt-2 flex flex-col items-start justify-center rounded-lg border border-gray-200 p-4">
                        <div class="flex justify-between items-center gap-2 w-full">
                            <div class="flex flex-col justify-start items-start">
                                <h1 class="font-inter text-lg font-medium text-[#404040]">{{ categoryName || 'Category Name' }}</h1>
                                <p class="font-inter text-sm font-medium text-[#808080]">{{ categoryDescription || 'Category Description' }}</p>
                            </div>
                            <div class="p-1 px-4 rounded-full bg-red-100">
                                <h1 class="text-sm text-red-600 font-medium">New</h1>
                            </div>
                        </div>
                        <div class="bg-gray-100 w-full rounded-full mt-2">
                            <div class="bg-blue-700 w-0 p-1.5 rounded-full"></div>
                        </div>
                        <p class="mt-2 font-inter text-sm font-medium text-[#808080]">0% stocks</p>
                    </div>
                </div>

                <div class="flex justify-end items-center gap-2 mt-6">
                    <button @click="emit('close')"
                        class="cursor-pointer rounded-xl bg-gray-100 p-2 px-4 text-[#404040] transition hover:bg-gray-200">Cancel</button>
                    <button @click="handleSave" :disabled="loading"
                        class="cursor-pointer rounded-xl bg-blue-700 p-2 px-5 text-white transition hover:bg-blue-800 disabled:cursor-not-allowed disabled:opacity-60">
                        {{ loading ? 'Adding...' : 'Add Category' }}
                    </button>
                </div>
            </div>
        </section>
    </Transition>
</template>