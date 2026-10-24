<script setup>
import { Check, Pill, Eye, EyeOff } from '@lucide/vue'
import { registerUser } from '../../services/Authservices';
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const router = useRouter()

const email = ref('')
const password = ref('')
const fname = ref('')
const mname = ref('')
const lname = ref('')
const contactNumber = ref('') // Binago mula cont para tugma sa v-model
const barangay = ref('')      // Binago mula barangs para tugma sa v-model
const agree = ref(false)
const Isloading = ref(false)
const Errormessage = ref('')
const comfirmpass = ref('')
const showPassword = ref(false)

function togglePassword() {
    showPassword.value = !showPassword.value
}


async function handlesubmit() {
    if (!agree.value) {
        Errormessage.value = 'Please agree to the terms and policy before creating your account.'
        return
    }

    if (password.value !== comfirmpass.value) {
        Errormessage.value = 'Passwords do not match. Please re-enter your password.'
        return
    }

    Isloading.value = true
    Errormessage.value = ''

    try {
        const result = await registerUser({
            email: email.value,
            password: password.value,
            firstname: fname.value,
            middlename: mname.value,
            lastname: lname.value,
            contact: contactNumber.value, // Itinugma sa variable
            barangays: barangay.value      // Itinugma sa variable
        })

        if (result.success) {
            email.value = ''
            password.value = ''
            fname.value = ''
            mname.value = ''
            lname.value = ''
            contactNumber.value = ''
            barangay.value = ''

            Isloading.value = false

            router.push('/verification')
        } else {
            Errormessage.value = result.error || 'Registration failed. Please try again.'
        }
    } catch (error) {
        Errormessage.value = error.message || 'Registration failed. Please try again.'
    } finally {
        Isloading.value = false // Siniguro na laging mag-false ang loading kahit mag-error
    }
}

// async function handleSocialLogin(provider) {
//     sessionStorage.setItem('botechka-oauth-loading', 'true')
//     window.dispatchEvent(new Event('botechka-oauth-start'))
//     const result = await signInWithProvider(provider);
//     if (!result.success) {
//         Errormessage.value = result.error;
//         sessionStorage.removeItem('botechka-oauth-loading')
//     }
// }
</script>

<template>
    <section class="grid min-h-screen 2xl:grid-cols-2 grid-cols-1 2xl:p-0">
        <div class="grid relative 2xl:flex hidden">
            <div class="relative w-full">
                <img src="/src/assets/Botikangbayan.jpg" alt="" class="h-full">
            </div>
            <div
                class="w-full absolute 2xl:h-screen h-fit bg-blue-800/88 backdrop-blur-xl 2xl:flex hidden flex-col justify-between items-center 2xl:p-10 p-4">
                <div class="text-white w-full flex flex-col justify-center items-center gap-6 h-full">
                    <router-link to="/">
                        <div class="flex flex-col items-start justify-start">
                            <img src="/src/dist/assets/BotikaWHITE-B0wYbg7D.png" alt="" class="w-60">
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
                <form @submit.prevent="handlesubmit" class="flex flex-col gap-4 mt-10">
                    <div v-if="Errormessage" class="bg-red-50 text-red-600 p-2 rounded-lg text-sm">
                        {{ Errormessage }}
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <div class="flex flex-col gap-1">
                            <label for="firtsname" class="text-[#404040] font-inter text-sm font-medium">First
                                name <span class="text-red-500">*</span></label>
                            <input v-model="fname" type="text" id="firtsname"
                                class="bg-gray-50 w-full border border-gray-200 rounded-lg p-2 focus:outline-none focus:border-none focus:ring-2 focus:ring-blue-700"
                                placeholder="John Juan" required>
                        </div>
                        <div class="flex flex-col gap-1">
                            <label for="Middlename" class="text-[#404040] font-inter text-sm font-medium">Middle
                                name <span class="text-red-500">*</span></label>
                            <input v-model="mname" type="text" id="Middlename"
                                class="bg-gray-50 w-full border border-gray-200 rounded-lg p-2 focus:outline-none focus:border-none focus:ring-2 focus:ring-blue-700"
                                placeholder="Anain">
                        </div>
                    </div>
                    <div class="flex flex-col gap-1 col-span-2 2xl:col-span-1">
                        <label for="Lastname" class="text-[#404040] font-inter text-sm font-medium">Last
                            name <span class="text-red-500">*</span></label>
                        <input v-model="lname" type="text" id="Lastname"
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
                            <input v-model="password" :type="showPassword ? 'text' : 'password'" id="pass"
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
                        <input v-model="comfirmpass" type="password" id="comfirm"
                            class="bg-gray-50 border border-gray-200 rounded-lg p-2 focus:outline-none focus:border-none focus:ring-2 focus:ring-blue-700"
                            placeholder="•••••••" required>
                    </div>
                    <div class=" flex items-center justify-start gap-2">
                        <input v-model="agree" type="checkbox" id="agree">
                        <label for="agree" class="text-[#404040] text-sm">Agree to the terms &amp; policy</label>
                    </div>
                    <div class="flex items-center justify-center p-2 bg-blue-700 rounded-xl text-white"
                        :class="{ 'opacity-60 cursor-not-allowed': Isloading }">
                        <button type="submit" :disabled="Isloading" class="w-full">
                            {{ Isloading ? 'Creating....' : 'Create account' }}
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