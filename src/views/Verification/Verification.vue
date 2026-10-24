<script setup>
import { onMounted, ref } from 'vue';
import { useRouter } from 'vue-router';
import { Gesstsessionuser, Signoutuser, syncUserProfile } from '../../services/Authservices.js';

const router = useRouter();
const profileError = ref('');
const isSigningOut = ref(false);

onMounted(async () => {
    const sessionResult = await Gesstsessionuser();

    if (!sessionResult.success) {
        profileError.value = sessionResult.error;
        return;
    }

    if (sessionResult.data?.user) {
        const result = await syncUserProfile(sessionResult.data.user);
        if (!result.success) profileError.value = result.error;
    }
});

const goToLogin = async () => {
    isSigningOut.value = true;
    profileError.value = '';

    try {
        const result = await Signoutuser();
        if (!result.success) {
            profileError.value = result.error || 'Unable to return to login. Please try again.';
            return;
        }

        await router.replace('/login');
    } catch (error) {
        console.error('Failed to return to login:', error);
        profileError.value = error instanceof Error
            ? error.message
            : 'Unable to return to login. Please try again.';
    } finally {
        isSigningOut.value = false;
    }
};
</script>


<template>
    <div class="min-h-screen flex items-center justify-center bg-blue-50/30 p-4 font-sans">
        <div class="max-w-md w-full bg-white rounded-lg p-8 text-center">

            <div
                class="mx-auto flex h-20 w-20 items-center justify-center rounded-full bg-blue-50 text-blue-600 mb-6 border border-blue-100">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-10 w-10" fill="none" viewBox="0 0 24 24"
                    stroke="currentColor" stroke-width="2">
                    <path stroke-linecap="round" stroke-linejoin="round"
                        d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                </svg>
            </div>

            <h2 class="text-2xl font-black text-blue-700 uppercase tracking-tight mb-2">Check your inbox</h2>
            <p class="text-gray-600 text-md mb-8 font-inter">
                We've sent a verification link to your email address. Please click the link to continue your
                journey.
            </p>

            <p v-if="profileError" class="mb-4 text-sm text-red-600" role="alert">
                {{ profileError }}
            </p>

            <button @click="goToLogin" :disabled="isSigningOut"
                class="w-full py-3 bg-blue-700 hover:bg-blue-800 text-white font-medium text-sm rounded-xl active:scale-95 disabled:cursor-not-allowed disabled:opacity-60">
                back to login
            </button>

            <div class="mt-6">
                <p class="text-sm text-gray-500 font-inter font-medium">
                    Didn't receive the email?
                    <button class="text-blue-600 text-sm font-bold hover:underline ml-1">Click to resend</button>
                </p>
            </div>
        </div>
    </div>
</template>
