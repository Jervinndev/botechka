<script setup>
import { Check, Eye, EyeOff, Pill } from '@lucide/vue'
import botikaLogo from '../../assets/BotikaWHITE-B0wYbg7D.png'
import botikaBackground from '../../assets/Botikangbayan.jpg'
import { loginUser } from '../../services/Authservices';
import { useRouter } from 'vue-router';
import { onMounted, ref } from 'vue';

const router = useRouter()

const email = ref('')
const password = ref('')
const Isloading = ref(false)
const isGoogleLoading = ref(false)
const Errormessage = ref('')
const showPassword = ref(false)
const rememberMe = ref(false)

function togglePassword() {
    showPassword.value = !showPassword.value
}

// async function handleGoogleLogin() {
//     Isloading.value = true
//     isGoogleLoading.value = true
//     Errormessage.value = ''
//     sessionStorage.setItem('botechka-oauth-loading', 'true')
//     window.dispatchEvent(new Event('botechka-oauth-start'))

//     const result = await signInWithProvider('google')
//     if (!result.success) {
//         Errormessage.value = result.error || 'Google login failed.'
//         Isloading.value = false
//         isGoogleLoading.value = false
//         sessionStorage.removeItem('botechka-oauth-loading')
//     }
// }

async function handlesubmit() {
    Isloading.value = true
    Errormessage.value = ''

    try {
        const result = await loginUser({
            email: email.value,
            password: password.value
        })

        if (result.success) {
            email.value = ''
            password.value = ''

            const role = result.data?.user?.user_metadata?.role?.toLowerCase()
            router.push(role === 'beneficiary' ? '/beneficiary-dashboard' : '/dashboard')
        } else {
            const rawError = result.error ? result.error.toLowerCase() : ''

            if (rawError.includes('confirmed') || rawError.includes('confirmation')) {
                Errormessage.value = 'Please comfirm verification in your inbox pare ko!'
            } else if (rawError.includes('invalid clones') || rawError.includes('invalid credentials')) {
                Errormessage.value = 'Invalid credentials'
            } else {
                Errormessage.value = result.error || 'Error'
            }
        }
    } catch (error) {
        Errormessage.value = error instanceof Error ? error.message : 'Error'
    } finally {
        Isloading.value = false
    }
}

onMounted(() => {
    const savedEmail = localStorage.getItem('remembered_email')
    if (savedEmail) {
        email.value = savedEmail
        rememberMe.value = true
    }
})
</script>

<template>
    <div v-if="isGoogleLoading" class="fixed inset-0 z-100 flex min-h-screen items-center justify-center bg-gray-100">
        <div class="flex flex-col items-center gap-4 text-blue-700">
            <div class="h-10 w-10 animate-spin rounded-full border-4 border-blue-200 border-t-blue-700"></div>
            <p class="text-sm font-medium">Connecting to Google...</p>
        </div>
    </div>
    <section class="grid 2xl:grid-cols-2 grid-cols-1 2xl:p-0">
        <div class="grid relative 2xl:flex hidden">
            <div class="relative w-full 2xl:flex hidden">
                <img :src="botikaBackground" alt="" class="h-full">
            </div>
            <div
                class="w-full absolute 2xl:h-screen h-fit bg-blue-800/88 backdrop-blur-xl 2xl:flex hidden flex-col justify-between items-center 2xl:p-10 p-4">
                <div class="text-white w-full flex flex-col justify-center items-center gap-6 h-full">
                    <router-link to="/">
                        <div class="flex flex-col items-start justify-start">
                            <img :src="botikaLogo" alt="" class="w-60">
                        </div>
                    </router-link>
                    <!-- <div class="mt-8">
                    <img src="/src/assets/Laboratory research Illustration.png" alt="" class="w-100">
                </div> -->
                    <div class="flex flex-col items-center justify-center">
                        <h1
                            class="2xl:text-4xl text-center text-3xl text-gray-200 font-bold 2xl:w-2xl font-inter leading-10">
                            "Keeping Medicines
                            Available,
                            Keeping
                            Communities Healthy."
                        </h1>
                        <p class="text-gray-300 2xl:w-xl mt-3 font-inter text-center">Walang Bayad, Para sa
                            Kalusugan ng
                            Lahat.
                            syempre
                            ganon yun
                            eh
                            pilipino
                            tayo mabilis kasi pag libre try nyo kainin gamot sabay sabay.
                        </p>
                    </div>
                </div>
                <p class="text-gray-300 font-inter pt-5 ">&copy; 2026 RHU-BoTechKa. All rights reserved.</p>
            </div>
        </div>
        <div class="w-full h-screen bg-gray-100 flex items-center justify-center p-4">
            <div class="p-6 bg-white rounded-xl w-100">
                <div>
                    <h1 class="text-2xl font-bold text-[#404040] text-[24px]">Welcome back Master!</h1>
                    <p class="text-[#808080] text-[14px]">Login to create yout account</p>
                </div>
                <form @submit.prevent="handlesubmit" class="grid gap-4 mt-10">
                    <div v-if="Errormessage" class="bg-red-50 text-red-600 p-2 rounded-lg text-sm">
                        {{ Errormessage }}
                    </div>
                    <div class="grid gap-1">
                        <label for="email" class="text-[#404040] text-[14px] font-medium">Email</label>
                        <input v-model="email" type="email" id="email"
                            class="bg-gray-50 border border-gray-200 rounded-lg p-2 focus:outline-none focus:border-none focus:ring-2 focus:ring-blue-700"
                            placeholder="ex:example@gmail.com" required>
                    </div>
                    <div class="grid gap-1">
                        <label for="pass" class="text-[#404040] text-[14px] font-medium">Password</label>
                        <div class="relative">
                            <input v-model="password" :type="showPassword ? 'text' : 'password'" id="pass"
                                class="bg-gray-50 border border-gray-200 rounded-lg p-2 pr-10 w-full focus:outline-none focus:border-none focus:ring-2 focus:ring-blue-700"
                                placeholder="•••••••" required>
                            <button type="button" @click="togglePassword"
                                class="absolute inset-y-0 right-3 flex items-center text-gray-400 hover:text-gray-600">
                                <EyeOff v-if="!showPassword" size="18" />
                                <Eye v-else size="18" />
                            </button>
                        </div>
                    </div>
                    <div class="flex items-center justify-between text-[14px]">
                        <label class="flex items-center gap-2 text-[#404040]">
                            <input v-model="rememberMe" type="checkbox" id="remember"> Remember me
                        </label>
                        <router-link to="/forgot-password" class="text-blue-700">Forgot password?</router-link>
                    </div>
                    <div class="flex items-center justify-center p-2 bg-blue-700 rounded-xl text-white"
                        :class="{ 'opacity-60 cursor-not-allowed': Isloading }">
                        <button type="submit" :disabled="Isloading" class="w-full">
                            {{ Isloading ? 'Signing....' : 'Sign in' }}
                        </button>
                    </div>

                    <div class="flex items-center justify-center">
                        <p class="text-[#404040] text-[14px]">Don't have an account? <router-link to="/register"
                                class="text-blue-700">Register here</router-link></p>
                    </div>

                    <!-- <div class="flex gap-4 mt-6 border border-gray-200 p-2 hover:bg-gray-50 relative rounded-lg">
                        <button @click="handleGoogleLogin" :disabled="Isloading"
                            class="w-full py-2 rounded-lg flex items-center justify-center gap-2 font-inter text-sm">
                            <span>{{ Isloading ? 'Connecting to Google...' : 'Continue with Google' }}</span>
                        </button>
                        <img src="/src/assets/Botikangbayan.jpg" alt="" class="h-10 absolute">
                    </div> -->
                </form>
            </div>
        </div>
    </section>
</template>