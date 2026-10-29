<script setup>
import botikaLogo from '../../assets/BotikaBLUE-CcOSGtx9.png'
import { LaptopMinimal, Menu, X, Globe, ChevronDown, Home, Info, Wrench, FileText, HelpCircle, Mail, LogIn, LayoutGrid } from '@lucide/vue'
import { ref, onMounted, onUnmounted } from 'vue'
import { signOutUser, getSessionUser } from '../../services/Authservices'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const isLoggedIn = ref(false)
const userRole = ref('')
const Isloading = ref(false)
const Iscollapsed = ref(true)
const IsScrolled = ref(false)

const handleScroll = () => {
    if (window.scrollY > 20) {
        IsScrolled.value = true
    } else {
        IsScrolled.value = false
    }
}

const navLinks = [
    { label: 'Home', to: { path: '/' }, icon: Home },
    { label: 'About', to: { path: '/about' }, icon: Info },
    { label: 'Services', to: { path: '/', hash: '#services' }, icon: Wrench },
    { label: 'Guidelines', to: { path: '/Guidelines' }, icon: FileText },
    { label: 'How it works', to: { path: '/', hash: '#how-it-works' }, icon: HelpCircle },
    { label: 'Contact', to: { path: '/contact' }, icon: Mail },
]

function isActive(link) {
    if (link.to.hash) {
        return route.path === link.to.path && route.hash === link.to.hash
    }
    if (link.to.path === '/') {
        return route.path === '/' && !route.hash
    }
    return route.path === link.to.path
}

function handleGetStarted() {
    if (!isLoggedIn.value) {
        router.push('/register')
        return
    }

    router.push(userRole.value === 'beneficiary' ? '/beneficiary-dashboard' : '/dashboard')
}

function toggle() {
    Iscollapsed.value = !Iscollapsed.value
}

async function handleAuthAction() {
    if (isLoggedIn.value) {
        Isloading.value = true

        try {
            const result = await signOutUser()
            if (!result.success) throw new Error(result.error)
            isLoggedIn.value = false
            userRole.value = ''
        } catch (error) {
            console.error(error)
        } finally {
            Isloading.value = false
        }
    } else {
        router.push('/login')
    }
}

onMounted(async () => {
    try {
        const sessionResult = await getSessionUser()
        if (!sessionResult.success) throw new Error(sessionResult.error)

        const session = sessionResult.data
        isLoggedIn.value = !!session
        if (!session) return

        const isGoogleUser = session.user?.app_metadata?.providers?.includes('google')
        if (isGoogleUser) {
            userRole.value = 'beneficiary'
            return
        }

        const metadataRole = session.user?.user_metadata?.role?.toLowerCase()
        if (metadataRole) {
            userRole.value = metadataRole
            return
        }
    } catch (error) {
        console.error('Error resolving signed-in user role:', error)
    }
})


onMounted(() => {
    window.addEventListener('scroll', handleScroll)
})


onUnmounted(() => {
    window.removeEventListener('scroll', handleScroll)
})

</script>

<template>
    <header class="w-full fixed top-0 z-50 font-sans bg-gray-100/90 backdrop-blur-2xl"
        :class="IsScrolled ? 'border-b border-gray-200' : ''">
        <div class="max-w-7xl mx-auto w-full flex items-center justify-between 2xl:px-0 px-4 py-2.5">
            <router-link to="/" class="flex items-center gap-2">
                <img :src="botikaLogo" alt="RHUBoTechka logo" class="w-30 h-12 object-contain">
            </router-link>

            <nav class="2xl:flex hidden items-center justify-center gap-8 py-3 font-outfit text-sm text-gray-500">
                <router-link v-for="link in navLinks" :key="link.label" :to="link.to"
                    class="relative pb-1 group transition-colors"
                    :class="isActive(link) ? 'text-blue-700 font-semibold' : 'hover:text-blue-700'">
                    {{ link.label }}
                    <span
                        class="absolute bottom-0 left-0 w-full h-0.5 bg-blue-700 rounded-full transition-transform duration-300 origin-center"
                        :class="isActive(link) ? 'scale-x-100' : 'scale-x-0 group-hover:scale-x-100'"></span>
                </router-link>
            </nav>

            <div class="2xl:flex hidden items-center gap-3 font-outfit">
                <button @click="handleAuthAction" :disabled="Isloading"
                    class="bg-white hover:bg-white/20 text-gray-700 font-regular px-4 py-1.5 rounded-lg border border-white/20 text-sm transition-all">
                    {{ Isloading ? 'Logging out...' : (isLoggedIn ? 'Logout' : 'Sign in') }}
                </button>
                <button @click="handleGetStarted"
                    class="bg-blue-700 hover:bg-blue-900 text-white font-semibold px-4 py-1.5 rounded-lg text-sm transition-all">
                    {{ isLoggedIn ? 'Dashboard' : 'Get started' }}
                </button>
            </div>

            <div class="2xl:hidden flex bg-white rounded-lg p-2">
                <Menu v-if="Iscollapsed" @click="toggle" class="text-black" />
                <X v-else @click="toggle" class="text-black" />
            </div>
        </div>

        <!-- MOBILE MENU -->
        <Transition enter-active-class="transition duration-200 ease-out" enter-from-class="opacity-0 -translate-y-2"
            enter-to-class="opacity-100 translate-y-0" leave-active-class="transition duration-150 ease-in"
            leave-from-class="opacity-100 translate-y-0" leave-to-class="opacity-0 -translate-y-2">
            <div v-if="!Iscollapsed" class="2xl:hidden w-full bg-gray-100 border-b border-gray-200 overflow-hidden">
                <nav class="flex flex-col p-3">
                    <router-link v-for="link in navLinks" :key="link.label" :to="link.to" @click="toggle"
                        class="flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-outfit transition-colors"
                        :class="isActive(link) ? 'bg-blue-50 text-blue-700 font-semibold' : 'text-gray-500 hover:bg-gray-50'">
                        <component :is="link.icon" size="18" />
                        <span>{{ link.label }}</span>
                    </router-link>
                </nav>

                <div class="border-t border-gray-100 p-3 flex flex-col gap-2">
                    <button @click="handleAuthAction(); toggle()" :disabled="Isloading"
                        class="flex items-center justify-center gap-2 border border-gray-200 text-gray-600 font-regular px-5 py-2.5 rounded-xl text-sm transition-all">
                        <LogIn size="16" />
                        {{ Isloading ? 'Logging out...' : (isLoggedIn ? 'Logout' : 'Sign in') }}
                    </button>
                    <button @click="handleGetStarted(); toggle()"
                        class="flex items-center justify-center gap-2 bg-blue-700 hover:bg-blue-900 text-white font-regular px-5 py-2.5 rounded-xl text-sm transition-all">
                        <LayoutGrid size="16" />
                        {{ isLoggedIn ? 'Dashboard' : 'Get started' }}
                    </button>
                </div>
            </div>
        </Transition>
    </header>
</template>

<style scoped>
.box-bg {
    background-color: #f8fafc;

    /* Box / grid pattern */
    background-image:
        linear-gradient(to right, #cbd5e1 1px, transparent 1px),
        linear-gradient(to bottom, #cbd5e1 1px, transparent 1px);

    background-size: 40px 40px;
}
</style>