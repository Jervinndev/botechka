<template>
    <tbody class="divide-y divide-gray-100 animate-pulse" aria-label="Loading inventory">
        <tr v-for="row in 6" :key="row" class="grid grid-cols-8 items-center">
            <td v-for="column in 8" :key="column" class="p-3">
                <div :class="column === 5 ? 'w-20' : column === 6 ? 'w-24' : 'w-full'" class="h-4 bg-gray-200"></div>
            </td>
        </tr>
    </tbody>
</template>