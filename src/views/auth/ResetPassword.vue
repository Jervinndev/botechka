<script setup>
import { ref } from 'vue'
import { supabase } from '../../supabase/supabase'
import { useRouter } from 'vue-router'

const router = useRouter()
const password = ref('')
const confirmPassword = ref('')
const message = ref('')
const errorMessage = ref('')
const loading = ref(false)

async function handleResetPassword() {
    message.value = ''
    errorMessage.value = ''

    if (password.value.length < 8) {
        errorMessage.value =
            'The password must be at least 8 characters.'
        return
    }

    if (password.value !== confirmPassword.value) {
        errorMessage.value = 'Passwords do not match.'
        return
    }

    loading.value = true

    try {
        const { error } = await supabase.auth.updateUser({
            password: password.value
        })

        if (error) throw error

        message.value = 'Password updated successfully!'

        setTimeout(() => {
            router.push('/login')
        }, 1500)
    } catch (error) {
        errorMessage.value = error.message
    } finally {
        loading.value = false
    }
}
</script>

<template>
    <div class="min-h-screen flex items-center justify-center p-6 bg-gray-100">
        <form @submit.prevent="handleResetPassword" class="w-full max-w-md space-y-4 bg-white p-6 rounded-lg">
            <h1 class="text-2xl font-bold">Reset Password</h1>

            <input v-model="password" type="password" placeholder="New password" minlength="8" required
                class="w-full rounded-lg border p-3" />

            <input v-model="confirmPassword" type="password" placeholder="Confirm new password" minlength="8" required
                class="w-full rounded-lg border p-3" />

            <p v-if="message" class="text-green-600">
                {{ message }}
            </p>

            <p v-if="errorMessage" class="text-red-500">
                {{ errorMessage }}
            </p>

            <button type="submit" :disabled="loading" class="w-full rounded-lg bg-blue-700 p-3 text-white">
                {{ loading ? 'Updating...' : 'Update Password' }}
            </button>
        </form>
    </div>
</template>
