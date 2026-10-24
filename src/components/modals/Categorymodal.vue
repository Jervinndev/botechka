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
            class="absolute top-0 left-0 w-full h-full bg-black/40 flex justify-center items-center font-inter">
            <div class="bg-white p-6 rounded-xl w-md">
                <div>
                    <h1 class="text-2xl font-black mt-2 text-gray-800">Add Categories</h1>
                    <p class="text-sm text-gray-500">Add a new category to your inventory</p>
                </div>

                <div class="grid gap-2 mt-6">
                    <label for="category-name" class="font-bold">Category Name</label>
                    <input v-model="categoryName" type="text" id="category-name" placeholder="Enter category name"
                        class="bg-gray-100 p-2 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500" />
                </div>

                <div class="grid gap-2 mt-4">
                    <label for="category-description" class="font-bold">Category Description</label>
                    <input v-model="categoryDescription" type="text" id="category-description"
                        placeholder="Enter category description"
                        class="bg-gray-100 p-2 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500" />
                </div>

                <!-- Lilitaw lamang ang Preview kapag nagsimula nang mag-type ang user -->
                <div v-if="isTyping" class="mt-6 transition-all duration-300">
                    <h1 class="font-bold">Preview</h1>
                    <div class="flex items-start justify-center flex-col border border-gray-500/20 rounded-lg p-4 mt-2">
                        <div class="flex justify-between items-center gap-2 w-full">
                            <div class="flex flex-col justify-start items-start">
                                <h1 class="text-lg font-medium">{{ categoryName || 'Category Name' }}</h1>
                                <p class="text-sm text-gray-500">{{ categoryDescription || 'Category Description' }}</p>
                            </div>
                            <div class="p-1 px-4 rounded-full bg-red-100">
                                <h1 class="text-sm text-red-600 font-medium">New</h1>
                            </div>
                        </div>
                        <div class="bg-gray-100 w-full rounded-full mt-2">
                            <div class="bg-blue-700 w-0 p-1.5 rounded-full"></div>
                        </div>
                        <p class="text-sm text-gray-500 mt-2">0% stocks</p>
                    </div>
                </div>

                <div class="flex justify-end items-center gap-2 mt-6">
                    <button @click="emit('close')"
                        class="bg-gray-100 text-gray-700 py-2 px-4 rounded-xl hover:bg-gray-200 cursor-pointer">Cancel</button>
                    <button @click="handleSave" :disabled="loading"
                        class="bg-blue-700 text-white py-2 px-4 rounded-xl hover:bg-blue-800 cursor-pointer">
                        {{ loading ? 'Adding...' : 'Add Category' }}
                    </button>
                </div>
            </div>
        </section>
    </Transition>
</template>