<script setup>
import { LayoutGrid, Package, Truck, Users, Building2, FileText, ChevronsLeft, ListSortDescending, Bolt, LogOut, Pill, MessageSquareWarning, Bell } from '@lucide/vue'
import { Signoutuser, Getuserprofile, Getuserinfo } from '../../services/Authservices'
import { computed, ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import Logoutmodal from '../modals/logoutmodal.vue'

const Isloading = ref(false)
const router = useRouter()
const infos = ref(null)
const fname = ref(null)
const role = ref(null)
const isBeneficiary = ref(false)
const Iscollapsed = ref(localStorage.getItem('sidebar_collapsed') === 'true')
const Ismodallogopen = ref(false)


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
    Iscollapsed.value = !Iscollapsed.value
    localStorage.setItem('sidebar_collapsed', Iscollapsed.value)
}


onMounted(async () => {
    try {
        const profileResult = await Getuserprofile()
        if (!profileResult.success) throw new Error(profileResult.error)
        const profile = profileResult.data

        const userResult = await Getuserinfo()
        const userEmail = userResult.success ? userResult.data.email : ''

        infos.value = {
            ...profile,
            email: userEmail
        }

        const userRole = profile.role ? profile.role.toLowerCase() : 'beneficiary'
        isBeneficiary.value = userRole === 'beneficiary'

        let firstName = profile.f_name || ''
        let lastName = profile.l_name || ''
        let middlename = profile.m_name || ''

        if (!firstName) {
            firstName = userEmail.split('@')[0] || 'User'
        }

        fname.value = {
            full_name: firstName,
            l_name: lastName,
            m_name: middlename
        }

        role.value = {
            role: profile.role || (isBeneficiary.value ? 'Beneficiary' : 'Admin')
        }
    }
    catch (error) {
        console.log("Error fetching profile:", error)
    }
})
</script>

<template>
    <aside
        :class="['h-screen p-4 bg-white transition-all duration-300 flex flex-col border-r border-gray-200', Iscollapsed ? 'w-20' : 'w-95']">
        <div class="flex flex-col justify-between h-full">
            <div>
                <div class="flex items-center justify-between gap-3">
                    <div v-if="!Iscollapsed" class="flex items-center gap-3">
                        <img src="/src/assets/ChatGPT Image Sep 23, 2026, 03_08_04 PM(1).png" alt="Logo" class="w-30">
                    </div>
                    <div @click="toggle" class="p-2 bg-gray-100 hover:bg-gray-200 rounded-lg cursor-pointer">
                        <ChevronsLeft color="#808080"
                            :class="['transition-all duration-300', Iscollapsed ? 'rotate-180' : 'rotate-0']" />
                    </div>
                </div>
                <div>
                    <div class="flex flex-col gap-2 mt-6">
                        <h1 v-if="!Iscollapsed" class="text-[14px] text-[#808080]">
                            {{ isBeneficiary ? 'My account' : 'Operation' }}
                        </h1>
                        <router-link v-for="over in visibleOverview" :key="over.to" :to="over.to"
                            class="flex items-center gap-2 p-2.5 rounded-lg text-slate-500 hover:bg-slate-100 hover:text-blue-700 transition-all font-medium text-sm"
                            active-class="!bg-blue-700 !text-white font-medium">
                            <component :is="over.Icon" :size="22" />
                            <h1 v-if="!Iscollapsed" class="text-sm font-poppins">{{ over.label }}</h1>
                        </router-link>
                        <hr class="mt-1 text-gray-200">
                    </div>
                    <div class="flex flex-col gap-2 mt-4">
                        <h1 v-if="!Iscollapsed" class="text-[14px] text-[#808080]">
                            {{ isBeneficiary ? 'Services' : 'Overview' }}
                        </h1>
                        <router-link v-for="opera in visibleOperationItems" :key="opera.to" :to="opera.to"
                            class="flex items-center gap-2 p-2.5 rounded-lg text-[#808080] hover:bg-slate-100 hover:text-blue-700 transition-all font-medium text-sm"
                            active-class="!bg-blue-700 !text-white">
                            <component :is="opera.Icon" :size="22" />
                            <h1 v-if="!Iscollapsed" class="font-medium font-poppins">{{ opera.label }}</h1>
                        </router-link>
                    </div>
                    <div class="flex flex-col gap-2 mt-4">
                        <h1 v-if="!Iscollapsed" class="text-[14px] text-[#808080]">
                            {{ isBeneficiary ? 'Insight' : 'Overview' }}
                        </h1>
                        <router-link v-for="ins in visibleInsight" :key="ins.to" :to="ins.to"
                            class="flex items-center gap-2 p-2.5 rounded-lg text-[#808080] hover:bg-slate-100 hover:text-blue-700 transition-all font-medium text-sm"
                            active-class="!bg-blue-700 !text-white">
                            <component :is="ins.Icon" :size="22" />
                            <h1 v-if="!Iscollapsed" class="font-medium font-poppins">{{ ins.label }}</h1>
                        </router-link>
                    </div>
                </div>
            </div>

            <div>
                <div class="flex gap-2 font-poppins">
                    <div v-if="!Iscollapsed && infos && fname && role" class="flex flex-col gap-1">
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
                    <router-link v-for="sets in settings" :key="sets.to" :to="sets.to"
                        class="flex items-center gap-2 p-2.5 rounded-lg text-[#808080] hover:bg-slate-100 hover:text-blue-700 transition-all font-medium text-sm"
                        active-class="!bg-blue-700 !text-white">
                        <component :is="sets.Icon" :size="22" />
                        <h1 v-if="!Iscollapsed" class="font-medium font-inter">{{ sets.label }}</h1>
                    </router-link>

                    <button @click="Ismodallogopen = true"
                        class="flex items-center gap-2 p-2.5 rounded-lg text-[#808080] hover:bg-red-100 hover:text-red-600 transition-all font-medium text-sm cursor-pointer">
                        <LogOut />
                        <h1 v-if="!Iscollapsed" class="font-medium font-inter">
                            Logout
                        </h1>
                    </button>
                </div>
            </div>
        </div>
    </aside>
    <Logoutmodal :IsOpen="Ismodallogopen" @close="Ismodallogopen = false" />
</template>