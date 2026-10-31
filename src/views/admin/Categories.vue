<script setup>
import { ref, onMounted, computed } from 'vue';
import { AlignVerticalSpaceAround, Bell, TriangleAlert, Pill, List, LayoutDashboard } from '@lucide/vue'
import Categorymodal from '../../components/modals/Categorymodal.vue'
import CategoryMedicinesModal from '../../components/modals/CategoryMedicinesModal.vue'
import CategorySkeliton from '../../Skelitonloader/CategorySkeliton.vue'
import { getCategories, getMedicines } from '../../services/Fetches'

const categories = ref([]);
const medicines = ref([]);
const Isflex = ref(true)
const isCategoryModalOpen = ref(false);
const selectedCategory = ref(null)
const categorySearch = ref('')
const isLoading = ref(true);
const errorMessage = ref('');

async function fetchCategories() {
    isLoading.value = true;
    errorMessage.value = '';

    try {
        const [categoryData, medicineData] = await Promise.all([
            getCategories(),
            getMedicines()
        ]);
        categories.value = categoryData;
        medicines.value = medicineData;
    } catch (error) {
        console.error('Failed to fetch category inventory:', error);
        errorMessage.value = 'Failed to load categories and medicine stocks.';
    } finally {
        isLoading.value = false;
    }
}

const categoriesWithStock = computed(() => {
    const query = categorySearch.value.trim().toLowerCase()

    return categories.value
        .filter(category => category.status !== 'archived')
        .filter(category => !query || category.category_name?.toLowerCase().includes(query))
        .map(category => {
        const categoryMedicines = medicines.value.filter(
            medicine => medicine.category?.trim().toLowerCase() === category.category_name?.trim().toLowerCase()
        );
        const categoryStock = categoryMedicines.reduce(
            (total, medicine) => total + Math.max(Number(medicine.quantity) || 0, 0),
            0
        );
        const stockedCount = categoryMedicines.filter(medicine => Number(medicine.quantity) > 0).length

        return {
            ...category,
            totalStock: categoryStock,
            medicineCount: categoryMedicines.length,
            stockPercentage: categoryMedicines.length
                ? Math.round((stockedCount / categoryMedicines.length) * 100)
                : 0
        };
    });
});

const selectedCategoryMedicines = computed(() => {
    const categoryName = selectedCategory.value?.category_name?.trim().toLowerCase()
    if (!categoryName) return []

    return medicines.value.filter(
        medicine => medicine.category?.trim().toLowerCase() === categoryName
    )
})

const totalMedicineCount = computed(() => medicines.value.length);
const outOfStockCount = computed(() =>
    medicines.value.filter(medicine => Number(medicine.quantity) <= 0).length
);
const mostStockedCategory = computed(() =>
    categoriesWithStock.value.reduce(
        (mostStocked, category) => category.totalStock > (mostStocked?.totalStock ?? 0) ? category : mostStocked,
        null
    )
);

function openCategory(category) {
    selectedCategory.value = category
}

function closeCategoryModal() {
    selectedCategory.value = null
}

onMounted(() => {
    fetchCategories()
});

</script>

<template>
    <section>
        <div class="flex justify-between items-center ">
            <div>
                <h1 class="font-inter font-bold text-gray-800 text-lg">Category</h1>
                <p class="text-sm text-gray-500">Manage your medicine resources</p>
            </div>
            <div class="flex items-center gap-4">
                <Bell class="text-blue-700" />
                <div class="flex items-center justify-center gap-1 border border-gray-500/40 rounded-full p-1">
                    <img src="/src/assets/download (12).jpg" alt="" class="w-10 rounded-full">
                    <!-- <p class="text-sm">Mark Hello po</p> -->
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-6">
            <div class="bg-white p-4 text-black rounded-xl">
                <div class="flex items-center gap-2">
                    <div class="p-2 bg-blue-100/70 rounded-lg">
                        <Pill size="22" class="text-blue-700" />
                    </div>
                    <p class="text-sm font-medium">Total medicines</p>
                </div>
                <h1 class="text-2xl font-black text-gray-700 mt-2">{{ totalMedicineCount }}</h1>

            </div>
            <div class="bg-white p-4 text-black rounded-xl">
                <div class="flex items-center gap-2">
                    <div class="p-2 bg-blue-100/70 rounded-lg">
                        <AlignVerticalSpaceAround size="22" class="text-blue-700" />
                    </div>
                    <p class="text-sm font-medium">Most Stocked Category</p>
                </div>
                <h1 class="text-2xl font-black text-gray-700 mt-2">
                    {{ mostStockedCategory ? `${mostStockedCategory.category_name} (${mostStockedCategory.totalStock})` : 'None' }}
                </h1>

            </div>
            <div class="bg-white p-4 text-black rounded-xl">
                <div class="flex items-center gap-2">
                    <div class="p-2 bg-blue-100/70 rounded-lg">
                        <TriangleAlert size="22" class="text-blue-700" />
                    </div>
                    <p class="text-sm font-medium">Out of Stock Items</p>
                </div>
                <h1 class="text-2xl font-black text-gray-700 mt-2">{{ outOfStockCount }}</h1>

            </div>
        </div>
        <div class="flex justify-between items-center mt-4">
            <div class="flex gap-2">
                <input v-model="categorySearch" type="text" placeholder="Search categories..."
                    class="bg-white p-2 px-3 w-2xl rounded-xl">

            </div>
            <div class="flex justify-between items-center gap-3">
                <div>
                    <button @click="isCategoryModalOpen = true"
                        class="p-2 bg-blue-700 text-white rounded-xl px-4 font-inter">Add
                        category</button>
                </div>
                <div p-2>
                    <List @click="Isflex = false" />
                </div>
                <div p-2>
                    <LayoutDashboard @click="Isflex = true" />
                </div>
            </div>
        </div>
        <p v-if="errorMessage" class="mt-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">
            {{ errorMessage }}
        </p>
        <CategorySkeliton v-if="isLoading" />
        <div v-else-if="categoriesWithStock.length === 0" class="mt-4 rounded-xl bg-white p-6 text-center text-sm text-gray-500">
            No categories found. Add a category to get started.
        </div>
        <div v-else class="grid gap-4 mt-4 rounded-xl transition-all duration-100"
            :class="Isflex ? 'grid grid-cols-3' : 'flex'">
            <div v-for="cat in categoriesWithStock" :key="cat.id"
                role="button" tabindex="0" @click="openCategory(cat)"
                @keydown.enter="openCategory(cat)" @keydown.space.prevent="openCategory(cat)"
                class="flex flex-col justify-center gap-3 font-inter p-4 bg-white rounded-xl w-full cursor-pointer hover:ring-2 hover:ring-blue-200 transition">
                <div>
                    <h1 class="font-bold">{{ cat.category_name }}</h1>
                    <p class="text-sm text-gray-500">{{ cat.description }}
                    </p>
                </div>
                <div class="bg-gray-100 rounded-full" role="progressbar"
                    :aria-valuenow="Math.round(cat.stockPercentage)" aria-valuemin="0" aria-valuemax="100"
                    :aria-label="`${cat.category_name} stock share`">
                    <div class="bg-blue-700 h-3 rounded-full transition-all duration-300"
                        :style="{ width: `${cat.stockPercentage}%` }"></div>
                </div>
                <div class="flex justify-between items-center">
                    <h1>{{ cat.medicineCount }} items · {{ cat.stockPercentage }}% stocked</h1>
                </div>
            </div>
        </div>
    </section>

    <Categorymodal :IsOpen="isCategoryModalOpen" @close="isCategoryModalOpen = false"
        @category-added="fetchCategories" />
    <CategoryMedicinesModal :IsOpen="Boolean(selectedCategory)" :category="selectedCategory"
        :medicines="selectedCategoryMedicines" @close="closeCategoryModal" />
</template>