<script setup>
import { Eye, EyeOff } from '@lucide/vue'
import botikaLogo from '../../assets/BotikaWHITE-B0wYbg7D.png'
import botikaBackground from '../../assets/Botikangbayan.jpg'
import { registerUser } from '../../services/Authservices';
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter()

const email = ref('')
const password = ref('')
const firstName = ref('')
const middleName = ref('')
const lastName = ref('')
const contactNumber = ref('')
const barangay = ref('')
const agree = ref(false)
const isLoading = ref(false)
const errorMessage = ref('')
const confirmPassword = ref('')
const showPassword = ref(false)

function togglePassword() {
    showPassword.value = !showPassword.value
}

async function handleSubmit() {
    errorMessage.value = ''
    if (!agree.value) {
        errorMessage.value = 'Please agree to the terms and policy before creating your account.'
        return
    }

    if (password.value !== confirmPassword.value) {
        errorMessage.value = 'Passwords do not match.'
        return
    }

    isLoading.value = true

    try {
        const result = await registerUser({
            email: email.value,
            password: password.value,
            firstName: firstName.value,
            middleName: middleName.value,
            lastName: lastName.value,
            contactNumber: contactNumber.value,
            barangay: barangay.value
        })

        if (!result.success) {
            errorMessage.value = result.error || 'Registration failed. Please try again.'
            return
        }

        await router.push('/verification')
    } catch (error) {
        errorMessage.value = error instanceof Error ? error.message : 'Registration failed. Please try again.'
    } finally {
        isLoading.value = false
    }
}
</script>

<template>
    <section class="grid min-h-screen 2xl:grid-cols-2 grid-cols-1 2xl:p-0">
        <div class="grid relative 2xl:flex hidden">
            <div class="relative w-full">
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

        <div class="w-full min-h-screen bg-gray-100 flex items-start 2xl:items-center justify-center p-4">
            <div class="p-6 bg-white rounded-xl w-full max-w-110">
                <div>
                    <h1 class="text-2xl font-bold font-inter text-[#404040] text-[24px]">Register now!</h1>
                    <p class="text-[#808080] font-inter font-medium text-sm">Register to create yout account</p>
                </div>
                <form @submit.prevent="handleSubmit" class="flex flex-col gap-4 mt-10">
                    <div v-if="errorMessage" class="bg-red-50 text-red-600 p-2 rounded-lg text-sm">
                        {{ errorMessage }}
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div class="flex flex-col gap-1">
                            <label for="firstName" class="text-[#404040] font-inter text-sm font-medium">First
                                name <span class="text-red-500">*</span></label>
                            <input v-model="firstName" type="text" id="firstName"
                                class="bg-gray-50 w-full border border-gray-200 rounded-lg p-2 focus:outline-none focus:border-none focus:ring-2 focus:ring-blue-700"
                                placeholder="John Juan" required>
                        </div>
                        <div class="flex flex-col gap-1">
                            <label for="middleName" class="text-[#404040] font-inter text-sm font-medium">Middle
                                name <span class="text-red-500">*</span></label>
                            <input v-model="middleName" type="text" id="middleName"
                                class="bg-gray-50 w-full border border-gray-200 rounded-lg p-2 focus:outline-none focus:border-none focus:ring-2 focus:ring-blue-700"
                                placeholder="Anain">
                        </div>
                    </div>
                    <div class="flex flex-col gap-1 col-span-2 2xl:col-span-1">
                        <label for="lastName" class="text-[#404040] font-inter text-sm font-medium">Last
                            name <span class="text-red-500">*</span></label>
                        <input v-model="lastName" type="text" id="lastName"
                            class="bg-gray-50 w-full border border-gray-200 rounded-lg p-2 focus:outline-none focus:border-none focus:ring-2 focus:ring-blue-700"
                            placeholder="Dela Cruz" required>
                    </div>
                    <div class="flex flex-col gap-1">
                        <label for="contact_number" class="text-[#404040] font-inter text-sm font-medium">Contact
                            Number <span class="text-red-500">*</span></label>
                        <input v-model="contactNumber" type="tel" id="contact_number"
                            class="bg-gray-50 border border-gray-200 rounded-lg p-2 focus:outline-none focus:border-none focus:ring-2 focus:ring-blue-700"
                            placeholder="09123456789" required>
                    </div>
                    <div class="flex flex-col gap-1">
                        <label for="barangay" class="text-[#404040] font-inter text-sm font-medium">Barangay <span
                                class="text-red-500">*</span></label>
                        <input v-model="barangay" type="text" id="barangay"
                            class="bg-gray-50 border border-gray-200 rounded-lg p-2 focus:outline-none focus:border-none focus:ring-2 focus:ring-blue-700"
                            placeholder="Ilagay ang pangalan ng Barangay" required>
                    </div>
                    <div class=" flex flex-col gap-1">
                        <label for="email" class="text-[#404040] font-inter text-sm font-medium">Email <span
                                class="text-red-500">*</span></label>
                        <input v-model="email" type="email" id="email"
                            class="bg-gray-50 border border-gray-200 rounded-lg p-2 focus:outline-none focus:border-none focus:ring-2 focus:ring-blue-700"
                            placeholder="Example@gmail.com" required>
                    </div>
                    <div class="grid gap-1">
                        <label for="pass" class="text-[#404040] text-[14px] font-medium">Password <span
                                class="text-red-500">*</span></label>
                        <div class="relative">
                            <input v-model="password" :type="showPassword ? 'text' : 'password'" id="pass" required
                                class="bg-gray-50 border border-gray-200 rounded-lg p-2 pr-10 w-full focus:outline-none focus:border-none focus:ring-2 focus:ring-blue-700"
                                placeholder="•••••••">
                            <button type="button" @click="togglePassword"
                                class="absolute inset-y-0 right-3 flex items-center text-gray-400 hover:text-gray-600">
                                <EyeOff v-if="!showPassword" size="18" />
                                <Eye v-else size="18" />
                            </button>
                        </div>
                    </div>
                    <div class=" flex flex-col gap-1">
                        <label for="comfirm" class="text-[#404040] font-inter text-sm font-medium">Confirm
                            Password <span class="text-red-500">*</span></label>
                        <input v-model="confirmPassword" type="password" id="confirmPassword"
                            class="bg-gray-50 border border-gray-200 rounded-lg p-2 focus:outline-none focus:border-none focus:ring-2 focus:ring-blue-700"
                            placeholder="•••••••" required>
                    </div>
                    <div class=" flex items-center justify-start gap-2">
                        <input v-model="agree" type="checkbox" id="agree">
                        <label for="agree" class="text-[#404040] text-sm">Agree to the terms &amp; policy</label>
                    </div>
                    <div class="flex items-center justify-center p-2 bg-blue-700 rounded-xl text-white"
                        :class="{ 'opacity-60 cursor-not-allowed': isLoading }">
                        <button type="submit" :disabled="isLoading" class="w-full">
                            {{ isLoading ? 'Creating...' : 'Create account' }}
                        </button>
                    </div>
                    <div class="flex items-center justify-center">
                        <p class="text-[#404040] text-sm">Already have an account? <router-link to="/login"
                                class="text-blue-700"> Login
                                here</router-link></p>
                    </div>
                </form>
                <!-- <div class="flex gap-4 mt-6 border border-gray-200 p-2 hover:bg-gray-50 relative rounded-lg">
                    <button @click="handleSocialLogin('google')"
                        class="w-full py-2 rounded-lg flex items-center justify-center gap-2 font-inter text-sm">
                        <span>Sign up with google</span>
                    </button>
                    <img src="/src/assets/Botikangbayan.jpg" alt="" class="h-10 absolute">
                </div> -->
            </div>
        </div>
    </section>
</template>