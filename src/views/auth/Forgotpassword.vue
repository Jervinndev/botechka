<script setup>
import { ref } from 'vue'
import { forgotPassword } from '../../services/Forgotpassword'

const email = ref('')
const loading = ref(false)
const message = ref('')
const errorMessage = ref('')

async function handleForgotPassword() {
    loading.value = true
    message.value = ''
    errorMessage.value = ''

    try {
        await forgotPassword(email.value.trim())

        message.value =
            'Kung registered ang email mo, tingnan ang inbox para sa password reset link.'
    } catch (error) {
        errorMessage.value = error.message
    } finally {
        loading.value = false
    }
}
</script>

<template>
    <div class="min-h-screen flex items-center justify-center p-6 bg-gray-100">
        <form @submit.prevent="handleForgotPassword" class="w-full max-w-md space-y-4 p-6 rounded-lg bg-white">
            <h1 class="text-2xl font-bold">Forgot Password?</h1>

            <p class="text-gray-500">
                Enter your email to receive a password reset link.
            </p>

            <input v-model="email" type="email" placeholder="Enter your email" required
                class="w-full rounded-lg border p-3" />

            <p v-if="message" class="text-green-600">
                {{ message }}
            </p>

            <p v-if="errorMessage" class="text-red-500">
                {{ errorMessage }}
            </p>

            <button type="submit" :disabled="loading"
                class="w-full rounded-lg bg-blue-700 p-3 text-white disabled:opacity-50">
                {{ loading ? 'Sending...' : 'Send Reset Link' }}
            </button>
        </form>
    </div>
</template>
