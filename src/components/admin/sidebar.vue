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
    Users,
    ShieldCheck,
    UserRound
} from '@lucide/vue'

import { computed, onMounted, ref } from 'vue'
import sidebarLogo from '../../assets/ChatGPT Image Sep 23, 2026, 03_08_04 PM(1).png'
import { getCachedMyProfile, getMyProfile } from '../../services/Authservices.js'
import Logoutmodal from '../modals/logoutmodal.vue'

const props = defineProps({
    isBeneficiaryLayout: {
        type: Boolean,
        default: false
    }
})

const cachedProfile = getCachedMyProfile()
const infos = ref(cachedProfile ? { email: cachedProfile.email ?? '' } : null)
const profile = ref(cachedProfile)
const isLoadingProfile = ref(!cachedProfile)
const profileError = ref(false)

const isCollapsed = ref(typeof localStorage !== 'undefined' && localStorage.getItem('sidebar_collapsed' === 'true'))

const isLogoutModalOpen = ref(false)
const isMobileMenuOpen = ref(false)

const role = computed(() => profile.value?.role?.toLowerCase() ?? null)

const isBeneficiary = computed(() => role.value === 'beneficiary')
const isPersonnel = computed(() => role.value === 'personnel')
const isAdmin = computed(() => role.value === 'admin')
const isSuperAdmin = computed(() => role.value === 'super_admin')

const isAuthorizedRole = computed(() => ['beneficiary', 'personnel', 'admin', 'super_admin'].includes(role.value))

const isExpanded = computed(() => !isCollapsed.value || isMobileMenuOpen.value)

const overview = [
    {
        label: 'Dashboard',
        to: { name: 'dashboard' },
        Icon: LayoutGrid
    }
]

const beneficiaryOverview = [{ label: 'Dashboard', to: { name: 'beneficiary-dashboard' }, Icon: LayoutGrid }]

const operationItems = [
    {
        label: 'Categories',
        to: { name: 'categories' },
        Icon: ListSortDescending
    },
    {
        label: 'Inventory',
        to: { name: 'inventory' },
        Icon: Package
    },
    {
        label: 'Distribution',
        to: { name: 'distribution' },
        Icon: Truck
    },
    {
        label: 'Beneficiaries',
        to: { name: 'beneficiaries' },
        Icon: Users
    },
    {
        label: 'Beneficiary Request',
        to: { name: 'beneficiaryrequest' },
        Icon: Building2
    }
]

const personnelItems = [
    {
        label: 'Categories',
        to: { name: 'categories' },
        Icon: ListSortDescending
    },
    {
        label: 'Inventory',
        to: { name: 'inventory' },
        Icon: Package
    },
    {
        label: 'Distribution',
        to: { name: 'distribution' },
        Icon: Truck
    },
    {
        label: 'Beneficiary Request',
        to: { name: 'beneficiaryrequest' },
        Icon: Building2
    }
]

const beneficiaryItems = [
    {
        label: 'Available medicines',
        to: { name: 'available-medicines' },
        Icon: Pill
    },
    {
        label: 'Request medicines',
        to: { name: 'requestmedicines' },
        Icon: FileText
    }
]

const insight = [
    {
        label: 'Reports',
        to: { name: 'reports' },
        Icon: MessageSquareWarning
    },
    {
        label: 'Notification',
        to: { name: 'notification' },
        Icon: Bell
    }
]

const beneficiaryInsight = [
    {
        label: 'Notification',
        to: { name: 'notificationbene' },
        Icon: Bell
    }
]

const settings = [
    {
        label: 'Settings',
        to: { name: 'settings' },
        Icon: Bolt
    }
]

const visibleOverview = computed(() => {
    if (!role.value) return overview
    return isBeneficiary.value ? beneficiaryOverview : overview
})

const visibleOperationItems = computed(() => {
    if (!role.value) return operationItems
    if (isBeneficiary.value) return beneficiaryItems
    if (isPersonnel.value) return personnelItems
    return operationItems
})

const visibleInsight = computed(() => {
    if (!role.value) return insight
    if (isBeneficiary.value) return beneficiaryInsight
    return insight
})

const visibleSettings = computed(() => settings)

const displayName = computed(() => {
    if (!profile.value) return ''

    return [
        profile.value.fname,
        profile.value.mname,
        profile.value.lname
    ]
        .filter(name => name?.trim()).join(' ')
})

const displayRole = computed(() => {
    const labels = {
        beneficiary: 'Beneficiary',
        personnel: 'Personnel',
        admin: 'Admin',
        super_admin: 'Super Admin'
    }

    return labels[role.value] ?? ''
})

const displayEmail = computed(() =>
    infos.value?.email ?? ''
)

async function loadProfile() {
    try {
        const result = await getMyProfile()

        if (!result.success || !result.data) {
            throw new Error(result.error || 'Unable to load profile.')
        }

        const userProfile = result.data
        const userRole = userProfile.role?.toLowerCase()

        if (!['beneficiary', 'personnel', 'admin', 'super_admin'].includes(userRole)) {
            throw new Error('Unauthorized or invalid account role.')
        }

        profile.value = {
            id: userProfile.id,
            fname: userProfile.fname ?? '',
            mname: userProfile.mname ?? '',
            lname: userProfile.lname ?? '',
            contactnumber: userProfile.contactnumber ?? '',
            barangay: userProfile.barangay ?? '',
            email: userProfile.email ?? '',
            role: userRole
        }

        infos.value = {
            email: userProfile.email ?? ''
        }
    } catch (error) {
        console.error('Failed to load sidebar profile:', error)
        profileError.value = true
    } finally {
        isLoadingProfile.value = false
    }
}

function toggle() {
    isCollapsed.value = !isCollapsed.value
    localStorage.setItem('sidebar_collapsed', String(isCollapsed.value))
}

function closeMobileMenu() {
    isMobileMenuOpen.value = false
}

onMounted(() => {
    if (!cachedProfile) {
        loadProfile()
    }
})
</script>

<template>
    <aside :class="[
        'bg-white transition-all duration-300 flex flex-col border-r border-gray-200',
        'w-full h-16 md:h-screen md:p-4 md:shrink-0',
        isCollapsed ? 'md:w-20' : 'md:w-80'
    ]">
        <!-- Mobile header -->
        <div
            class="fixed inset-x-0 top-0 z-50 flex h-16 items-center justify-between border-b border-gray-200 bg-white px-4 md:hidden">
            <img :src="sidebarLogo" alt="BOTECHKA Logo" class="w-30" />

            <button type="button" class="rounded-lg bg-gray-100 p-2 hover:bg-gray-200" :aria-expanded="isMobileMenuOpen"
                aria-label="Toggle navigation" @click="isMobileMenuOpen = !isMobileMenuOpen">
                <ChevronsLeft color="#808080" :class="[
                    'transition-all duration-300',
                    isMobileMenuOpen ? 'rotate-0' : 'rotate-180'
                ]" />
            </button>
        </div>

        <!-- Mobile overlay -->
        <button v-if="isMobileMenuOpen" type="button" class="fixed inset-x-0 bottom-0 top-16 z-30 bg-black/30 md:hidden"
            aria-label="Close navigation" @click="closeMobileMenu" />

        <!-- Sidebar content -->
        <div :class="[
            'fixed bottom-0 left-0 top-16 z-40 flex w-72 max-w-[85vw] flex-col justify-between overflow-y-auto bg-white p-4 transition-transform duration-300 md:static md:z-auto md:h-full md:w-auto md:max-w-none md:overflow-visible md:p-0 md:translate-x-0',
            isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'
        ]">
            <div>
                <!-- Desktop logo and collapse -->
                <div class="hidden items-center justify-between gap-3 md:flex">
                    <img v-if="!isCollapsed" :src="sidebarLogo" alt="BOTECHKA Logo" class="w-30" />

                    <button type="button" @click="toggle" class="rounded-lg bg-gray-100 p-2 hover:bg-gray-200"
                        :aria-expanded="!isCollapsed" aria-label="Toggle sidebar">
                        <ChevronsLeft color="#808080" :class="[
                            'transition-all duration-300',
                            isCollapsed ? 'rotate-180' : 'rotate-0'
                        ]" />
                    </button>
                </div>

                <!-- Navigation links -->
                <div>
                    <!-- Dashboard -->
                    <div class="mt-6 flex flex-col gap-2">
                        <h2 v-if="isExpanded" class="text-[14px] text-[#808080]">
                            {{ isBeneficiary ? 'My account' : 'Operation' }}
                        </h2>

                        <router-link v-for="item in visibleOverview" :key="item.label" :to="item.to"
                            class="flex items-center gap-2 rounded-lg p-2.5 text-sm font-medium text-[#808080] transition-all hover:bg-slate-100 hover:text-blue-700"
                            active-class="!bg-blue-700 !text-white" @click="closeMobileMenu">
                            <component :is="item.Icon" :size="22" />

                            <span v-if="isExpanded" class="font-inter">
                                {{ item.label }}
                            </span>
                        </router-link>

                        <hr class="mt-1 border-gray-200" />
                    </div>

                    <!-- Operations -->
                    <div class="mt-4 flex flex-col gap-2">
                        <h2 v-if="isExpanded" class="text-[14px] text-[#808080]">
                            {{ isBeneficiary ? 'Services' : 'Management' }}
                        </h2>

                        <router-link v-for="item in visibleOperationItems" :key="item.label" :to="item.to"
                            class="flex items-center gap-2 rounded-lg p-2.5 text-sm font-medium text-[#808080] transition-all hover:bg-slate-100 hover:text-blue-700"
                            active-class="!bg-blue-700 !text-white" @click="closeMobileMenu">
                            <component :is="item.Icon" :size="22" />

                            <span v-if="isExpanded" class="font-inter">
                                {{ item.label }}
                            </span>
                        </router-link>
                    </div>

                    <!-- Reports and notifications -->
                    <div class="mt-4 flex flex-col gap-2">
                        <h2 v-if="isExpanded" class="text-[14px] text-[#808080]">
                            {{ isBeneficiary ? 'Updates' : 'Insights' }}
                        </h2>

                        <router-link v-for="item in visibleInsight" :key="item.label" :to="item.to"
                            class="flex items-center gap-2 rounded-lg p-2.5 text-sm font-medium text-[#808080] transition-all hover:bg-slate-100 hover:text-blue-700"
                            active-class="!bg-blue-700 !text-white" @click="closeMobileMenu">
                            <component :is="item.Icon" :size="22" />

                            <span v-if="isExpanded" class="font-inter">
                                {{ item.label }}
                            </span>
                        </router-link>
                    </div>

                    <!-- Super admin-only account management placeholder -->
                    <div v-if="isSuperAdmin" class="mt-4 flex flex-col gap-2">
                        <h2 v-if="isExpanded" class="text-[14px] text-[#808080]">
                            System
                        </h2>

                        <div class="flex items-center gap-2 rounded-lg p-2.5 text-sm font-medium text-gray-400"
                            :title="isExpanded ? 'User management route not configured yet' : 'User management'">
                            <UserRound :size="22" />

                            <span v-if="isExpanded" class="font-poppins">
                                User Management
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bottom: profile, settings and logout -->
            <div class="mt-6">
                <div v-if="isExpanded && profile && !profileError" class="flex flex-col gap-1 break-words font-poppins">
                    <h2 class="text-sm font-semibold text-gray-800">
                        {{ displayName || 'User' }}
                    </h2>

                    <p class="text-sm text-[#808080]">
                        {{ displayEmail }}
                    </p>

                    <div
                        class="mt-1 flex w-fit items-center justify-center rounded-3xl bg-blue-700 px-3 py-1 text-white">
                        <p class="text-xs capitalize">
                            {{ displayRole }}
                        </p>
                    </div>
                </div>

                <hr class="mt-4 border-gray-200" />

                <div class="mt-4 flex flex-col gap-2">
                    <router-link v-for="item in visibleSettings" :key="item.label" :to="item.to"
                        class="flex items-center gap-2 rounded-lg p-2.5 text-sm font-medium text-[#808080] transition-all hover:bg-slate-100 hover:text-blue-700"
                        active-class="!bg-blue-700 !text-white" @click="closeMobileMenu">
                        <component :is="item.Icon" :size="22" />

                        <span v-if="isExpanded" class="font-inter">
                            {{ item.label }}
                        </span>
                    </router-link>

                    <button type="button" @click="isLogoutModalOpen = true"
                        class="flex cursor-pointer items-center gap-2 rounded-lg p-2.5 text-sm font-medium text-[#808080] transition-all hover:bg-red-100 hover:text-red-600">
                        <LogOut :size="22" />

                        <span v-if="isExpanded" class="font-inter">
                            Logout
                        </span>
                    </button>
                </div>
            </div>
        </div>
    </aside>

    <Logoutmodal :IsOpen="isLogoutModalOpen" @close="isLogoutModalOpen = false" />
</template>