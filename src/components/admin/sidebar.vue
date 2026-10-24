<script setup>
import {
    Bell,
    Bolt,
    Building2,
    ChevronsLeft,
    FileText,
    LayoutGrid,
    ListSortDescending,
    LogOut,
    MessageSquareWarning,
    Package,
    Pill,
    Truck,
    Users
} from '@lucide/vue'
import sidebarLogo from '../../assets/ChatGPT Image Sep 23, 2026, 03_08_04 PM(1).png'
import { Getuserprofile, Getuserinfo } from '../../services/Authservices'
import { computed, ref, onMounted } from 'vue'
import Logoutmodal from '../modals/logoutmodal.vue'

const props = defineProps({
    isBeneficiaryLayout: {
        type: Boolean,
        default: false
    }
})

const infos = ref(null)
const fname = ref(null)
const role = ref(null)
const isBeneficiary = ref(false)
const isCollapsed = ref(localStorage.getItem('sidebar_collapsed') === 'true')
const isLogoutModalOpen = ref(false)
const isMobileMenuOpen = ref(false)
const isExpanded = computed(() => !isCollapsed.value || (props.isBeneficiaryLayout && isMobileMenuOpen.value))


const overview = [
    { label: 'Dashboard', to: { name: 'dashboard' }, Icon: LayoutGrid }
]

const operationItems = [
    { label: 'Categories', to: { name: 'categories' }, Icon: ListSortDescending },
    { label: 'Inventory', to: { name: 'inventory' }, Icon: Package },
    { label: 'Distribution', to: { name: 'distribution' }, Icon: Truck },
    { label: 'Beneficiaries', to: { name: 'beneficiaries' }, Icon: Users },
    { label: 'Beneficiary Request', to: { name: 'beneficiaryrequest' }, Icon: Building2 },
]

const insight = [
    { label: 'Reports', to: { name: 'reports' }, Icon: MessageSquareWarning },
    { label: 'Notification', to: { name: 'notification' }, Icon: Bell }
]

const settings = [
    { label: 'Settings', to: { name: 'settings' }, Icon: Bolt },
]

const visibleOverview = computed(() => isBeneficiary.value
    ? [{ label: 'Dashboard', to: { name: 'beneficiary-dashboard' }, Icon: LayoutGrid }]
    : overview)

const visibleOperationItems = computed(() => isBeneficiary.value
    ? [{ label: 'Available medicines', to: { name: 'available-medicines' }, Icon: Pill },
    { label: 'Request medicines', to: { name: 'requestmedicines' }, Icon: FileText }
    ]
    : operationItems)

const visibleInsight = computed(() => isBeneficiary.value
    ? [{ label: 'Notification', to: { name: 'notificationbene' }, Icon: Bell }]
    : insight)

function toggle() {
    isCollapsed.value = !isCollapsed.value
    localStorage.setItem('sidebar_collapsed', String(isCollapsed.value))
}


onMounted(async () => {
    try {
        const profileResult = await Getuserprofile()
        if (!profileResult.success) {
            throw new Error(profileResult.error || 'Failed to load user profile.')
        }
        const profile = profileResult.data

        const userResult = await Getuserinfo()
        if (!userResult.success) {
            console.error('Failed to load sidebar user email:', userResult.error)
        }
        const userEmail = userResult.success ? userResult.data.email : ''

        infos.value = {
            ...profile,
            email: userEmail
        }

        const userRole = profile.role ? profile.role.toLowerCase() : 'beneficiary'
        isBeneficiary.value = userRole === 'beneficiary'

        const firstName = profile.f_name || userEmail.split('@')[0] || 'User'

        fname.value = {
            full_name: firstName,
            l_name: profile.l_name || '',
            m_name: profile.m_name || ''
        }

        role.value = {
            role: profile.role || (isBeneficiary.value ? 'Beneficiary' : 'Admin')
        }
    } catch (error) {
        console.error('Failed to load sidebar profile:', error)
    }
})
</script>

<template>
    <aside :class="[
        'p-4 bg-white transition-all duration-300 flex flex-col border-r border-gray-200',
        props.isBeneficiaryLayout ? 'w-full h-auto md:h-screen md:shrink-0' : 'h-screen',
        !props.isBeneficiaryLayout ? (isCollapsed ? 'w-20' : 'w-95') : (isCollapsed ? 'md:w-20' : 'md:w-95')
    ]">
        <div v-if="props.isBeneficiaryLayout" class="flex md:hidden items-center justify-between">
            <img :src="sidebarLogo" alt="Logo" class="w-30">
            <button type="button" class="p-2 bg-gray-100 hover:bg-gray-200 rounded-lg" :aria-expanded="isMobileMenuOpen"
                aria-label="Toggle navigation" @click="isMobileMenuOpen = !isMobileMenuOpen">
                <ChevronsLeft color="#808080"
                    :class="['transition-all duration-300', isMobileMenuOpen ? 'rotate-0' : 'rotate-180']" />
            </button>
        </div>
        <div :class="[
            'flex flex-col justify-between',
            props.isBeneficiaryLayout ? 'md:flex md:h-full' : 'h-full',
            props.isBeneficiaryLayout ? (isMobileMenuOpen ? 'flex' : 'hidden md:flex') : ''
        ]">
            <div>
                <div class="hidden md:flex items-center justify-between gap-3">
                    <div v-if="!isCollapsed" class="flex items-center gap-3">
                        <img :src="sidebarLogo" alt="Logo" class="w-30">
                    </div>
                    <button type="button" @click="toggle"
                        class="p-2 bg-gray-100 hover:bg-gray-200 rounded-lg"
                        :aria-expanded="!isCollapsed" aria-label="Toggle sidebar">
                        <ChevronsLeft color="#808080"
                            :class="['transition-all duration-300', isCollapsed ? 'rotate-180' : 'rotate-0']" />
                    </button>
                </div>
                <div>
                    <div class="flex flex-col gap-2 mt-6">
                        <h1 v-if="isExpanded" class="text-[14px] text-[#808080]">
                            {{ isBeneficiary ? 'My account' : 'Operation' }}
                        </h1>
                        <router-link v-for="over in visibleOverview" :key="over.label" :to="over.to"
                            class="flex items-center gap-2 p-2.5 rounded-lg text-slate-500 hover:bg-slate-100 hover:text-blue-700 transition-all font-medium text-sm"
                            active-class="!bg-blue-700 !text-white font-medium">
                            <component :is="over.Icon" :size="22" />
                            <h1 v-if="isExpanded" class="text-sm font-poppins">{{ over.label }}</h1>
                        </router-link>
                        <hr class="mt-1 text-gray-200">
                    </div>
                    <div class="flex flex-col gap-2 mt-4">
                        <h1 v-if="isExpanded" class="text-[14px] text-[#808080]">
                            {{ isBeneficiary ? 'Services' : 'Overview' }}
                        </h1>
                        <router-link v-for="opera in visibleOperationItems" :key="opera.label" :to="opera.to"
                            class="flex items-center gap-2 p-2.5 rounded-lg text-[#808080] hover:bg-slate-100 hover:text-blue-700 transition-all font-medium text-sm"
                            active-class="!bg-blue-700 !text-white">
                            <component :is="opera.Icon" :size="22" />
                            <h1 v-if="isExpanded" class="font-medium font-poppins">{{ opera.label }}</h1>
                        </router-link>
                    </div>
                    <div class="flex flex-col gap-2 mt-4">
                        <h1 v-if="isExpanded" class="text-[14px] text-[#808080]">
                            {{ isBeneficiary ? 'Insight' : 'Overview' }}
                        </h1>
                        <router-link v-for="ins in visibleInsight" :key="ins.label" :to="ins.to"
                            class="flex items-center gap-2 p-2.5 rounded-lg text-[#808080] hover:bg-slate-100 hover:text-blue-700 transition-all font-medium text-sm"
                            active-class="!bg-blue-700 !text-white">
                            <component :is="ins.Icon" :size="22" />
                            <h1 v-if="isExpanded" class="font-medium font-poppins">{{ ins.label }}</h1>
                        </router-link>
                    </div>
                </div>
            </div>

            <div>
                <div class="flex gap-2 font-poppins">
                    <div v-if="isExpanded && infos && fname && role" class="flex flex-col gap-1">
                        <h1>{{ fname.full_name }} {{ fname.m_name }} {{ fname.l_name }}</h1>
                        <p class="text-[#808080] text-sm">{{ infos.email }}</p>
                        <div
                            class="px-3 py-1 w-fit flex items-center justify-center bg-blue-700 text-white rounded-3xl mt-1">
                            <p class="capitalize text-xs">{{ role.role }}</p>
                        </div>
                    </div>
                </div>
                <hr class="mt-4 text-gray-200">
                <div class="flex flex-col gap-2 mt-4">
                    <router-link v-for="sets in settings" :key="sets.label" :to="sets.to"
                        class="flex items-center gap-2 p-2.5 rounded-lg text-[#808080] hover:bg-slate-100 hover:text-blue-700 transition-all font-medium text-sm"
                        active-class="!bg-blue-700 !text-white">
                        <component :is="sets.Icon" :size="22" />
                        <h1 v-if="isExpanded" class="font-medium font-inter">{{ sets.label }}</h1>
                    </router-link>

                    <button @click="isLogoutModalOpen = true"
                        class="flex items-center gap-2 p-2.5 rounded-lg text-[#808080] hover:bg-red-100 hover:text-red-600 transition-all font-medium text-sm cursor-pointer">
                        <LogOut />
                        <h1 v-if="isExpanded" class="font-medium font-inter">
                            Logout
                        </h1>
                    </button>
                </div>
            </div>
        </div>
    </aside>
    <Logoutmodal :IsOpen="isLogoutModalOpen" @close="isLogoutModalOpen = false" />
</template>