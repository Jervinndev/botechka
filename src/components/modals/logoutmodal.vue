<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { signOutUser } from '../../services/Authservices'

const Isloading = ref(false)
const router = useRouter()

async function Logout() {
    Isloading.value = true

    try {
        const result = await signOutUser()
        if (!result.success) throw new Error(result.error)
        localStorage.removeItem('sidebar_collapsed')
        router.push('/')
    } catch (error) {
        console.error(error)
    } finally {
        Isloading.value = false
    }
}

const props = defineProps({
    IsOpen: Boolean
})
const emit = defineEmits(['close'])
</script>

<template>
    <section v-if="IsOpen"
        class="w-full fixed h-screen flex items-center justify-center absolute top-0 left-0 bg-black/40 backdrop-blur-xs z-50 p-4">
        <div class="bg-white p-4 rounded-xl shadow-md w-sm">
            <h1 class="text-xl font-bold"> Sign out </h1>
            <p class="text-gray-600 mt-2"> Are you sure you want to logout? </p>
            <div class="flex gap-2 mt-4 items-end justify-end">
                <button @click="emit('close')"
                    class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-2 px-4 rounded"> Cancel
                </button>
                <button @click="Logout" :disabled="Isloading" :class="[
                    'flex items-center gap-2 p-3 rounded-lg bg-blue-700 text-gray-100 transition-all font-medium text-sm cursor-pointer',
                    Isloading ? 'opacity-20 pointer-events-none cursor-not-allowed' : ''
                ]">
                    <h1 v-if="!Iscollapsed" class="font-medium font-inter">
                        {{ Isloading ? 'Logging out...' : 'Logout' }}
                    </h1>
                </button>
            </div>
        </div>
    </section>
</template>