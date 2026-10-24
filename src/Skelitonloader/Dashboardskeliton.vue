<template>
    <section class="w-full animate-pulse font-poppins">
        <!-- Header Skeleton -->
        <div class="flex justify-between items-center">
            <div>
                <div class="h-5 w-28 bg-gray-200 rounded-md mb-2"></div>
                <div class="h-3 w-48 bg-gray-200 rounded-md"></div>
            </div>
            <div class="h-8 w-8 bg-gray-200 rounded-full"></div>
        </div>

        <!-- Top Cards Grid Skeleton -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mt-4">
            <div v-for="i in 4" :key="i"
                class="bg-white p-4 rounded-xl border border-gray-100 flex flex-col justify-between h-32">
                <div class="flex items-center gap-2">
                    <div class="w-9 h-9 bg-gray-200 rounded-lg"></div>
                    <div class="h-4 w-24 bg-gray-200 rounded-md"></div>
                </div>
                <div class="h-7 w-16 bg-gray-200 rounded-md my-2"></div>
                <div class="flex items-center justify-between">
                    <div class="h-3 w-24 bg-gray-200 rounded-md"></div>
                    <div class="w-7 h-7 bg-gray-200 rounded-full"></div>
                </div>
            </div>
        </div>

        <!-- Charts Skeleton -->
        <div class="mt-4">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                <div class="bg-white p-6 rounded-2xl border border-gray-100 h-80 flex flex-col justify-between">
                    <div class="h-4 w-36 bg-gray-200 rounded-md mb-4"></div>
                    <div class="w-full h-full bg-gray-100 rounded-xl"></div>
                </div>
                <div class="bg-white p-6 rounded-2xl border border-gray-100 h-80 flex flex-col justify-between">
                    <div class="h-4 w-48 bg-gray-200 rounded-md mb-4"></div>
                    <div class="w-full h-full bg-gray-100 rounded-xl"></div>
                </div>
            </div>
        </div>

        <!-- Tables Skeleton -->
        <div class="mt-4">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
                <div class="bg-white p-6 rounded-2xl border border-gray-100 h-72">
                    <div class="flex justify-between items-center mb-6">
                        <div class="h-5 w-28 bg-gray-200 rounded-md"></div>
                        <div class="h-8 w-24 bg-gray-200 rounded-xl"></div>
                    </div>
                    <div class="space-y-4">
                        <div v-for="i in 3" :key="i" class="h-8 bg-gray-100 rounded-md w-full"></div>
                    </div>
                </div>
                <div class="bg-white p-6 rounded-2xl border border-gray-100 h-72 flex flex-col justify-between">
                    <div>
                        <div class="h-5 w-36 bg-gray-200 rounded-md mb-2"></div>
                        <div class="h-3 w-48 bg-gray-100 rounded-md mb-6"></div>
                        <div class="space-y-3">
                            <div v-for="i in 3" :key="i" class="h-10 bg-gray-100 rounded-md w-full"></div>
                        </div>
                    </div>
                    <div class="h-10 bg-gray-200 rounded-xl w-full"></div>
                </div>
            </div>
        </div>
    </section>
</template>