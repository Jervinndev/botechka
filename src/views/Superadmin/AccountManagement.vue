<script setup>
import { computed, onMounted, ref } from 'vue'
import {
    User, Search, Package, ChevronDown, ChevronLeft, ChevronRight, ArrowUpRight,
    EllipsisVertical, Pencil, Plus, X
} from '@lucide/vue'
import {
    createManagedAccount,
    getManagedAccounts,
    updateManagedAccountRole
} from '../../services/AccountManagement'

const accounts = ref([])
const searchQuery = ref('')
const selectedRole = ref('All roles')
const isLoading = ref(false)
const isSaving = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const isCreateModalOpen = ref(false)
const roleModalAccount = ref(null)
const newAccount = ref({
    firstName: '',
    middleName: '',
    lastName: '',
    contactNumber: '',
    barangay: '',
    email: '',
    password: '',
    confirmPassword: '',
    role: 'personnel'
})
const newRole = ref('')

const filteredAccounts = computed(() => {
    const query = searchQuery.value.trim().toLowerCase()
    return accounts.value.filter((account) => {
        const searchMatches = !query || [
            account.fname,
            account.mname,
            account.lname,
            account.email,
            account.role
        ].some((value) => String(value || '').toLowerCase().includes(query))
        const roleMatches = selectedRole.value === 'All roles'
            || account.role?.toLowerCase() === selectedRole.value.toLowerCase().replace(' ', '_')
        return searchMatches && roleMatches
    })
})

const roleCounts = computed(() => ({
    super_admin: accounts.value.filter((account) => account.role?.toLowerCase() === 'super_admin').length,
    admin: accounts.value.filter((account) => account.role?.toLowerCase() === 'admin').length,
    personnel: accounts.value.filter((account) => account.role?.toLowerCase() === 'personnel').length,
    beneficiary: accounts.value.filter((account) => account.role?.toLowerCase() === 'beneficiary').length
}))

async function loadAccounts() {
    isLoading.value = true
    errorMessage.value = ''
    try {
        accounts.value = await getManagedAccounts()
    } catch (error) {
        console.error('Unable to load managed accounts:', error)
        errorMessage.value = error.message || 'Unable to load accounts.'
    } finally {
        isLoading.value = false
    }
}

function getName(account) {
    return [account.fname, account.mname, account.lname].filter(Boolean).join(' ') || account.email
}

function getInitials(account) {
    return [account.fname, account.lname]
        .filter(Boolean)
        .map((name) => name[0])
        .join('')
        .toUpperCase() || account.email?.[0]?.toUpperCase() || '?'
}

function formatCreatedAt(date) {
    if (!date) return '—'
    const parsedDate = new Date(date)
    return Number.isNaN(parsedDate.getTime()) ? '—' : parsedDate.toLocaleDateString()
}

function openCreateModal() {
    errorMessage.value = ''
    successMessage.value = ''
    newAccount.value = {
        firstName: '',
        middleName: '',
        lastName: '',
        contactNumber: '',
        barangay: '',
        email: '',
        password: '',
        confirmPassword: '',
        role: 'personnel'
    }
    isCreateModalOpen.value = true
}

async function saveNewAccount() {
    if (isSaving.value) return
    errorMessage.value = ''
    successMessage.value = ''
    if (newAccount.value.password !== newAccount.value.confirmPassword) {
        errorMessage.value = 'Passwords do not match.'
        return
    }
    isSaving.value = true
    try {
        await createManagedAccount(newAccount.value)
        isCreateModalOpen.value = false
        successMessage.value = 'Account created successfully.'
        await loadAccounts()
    } catch (error) {
        console.error('Unable to create account:', error)
        errorMessage.value = error.message || 'Unable to create account.'
    } finally {
        isSaving.value = false
    }
}

function openRoleModal(account) {
    roleModalAccount.value = account
    newRole.value = account.role?.toLowerCase() || 'personnel'
    errorMessage.value = ''
    successMessage.value = ''
}

async function saveRole() {
    if (!roleModalAccount.value || isSaving.value) return
    isSaving.value = true
    errorMessage.value = ''
    try {
        await updateManagedAccountRole(roleModalAccount.value.id, newRole.value)
        roleModalAccount.value = null
        successMessage.value = 'Account role updated.'
        await loadAccounts()
    } catch (error) {
        console.error('Unable to update account role:', error)
        errorMessage.value = error.message || 'Unable to update account role.'
    } finally {
        isSaving.value = false
    }
}

onMounted(loadAccounts)
</script>

<template>
    <div class="h-fit font-sans text-slate-900">
        <header class="mb-5 flex items-start gap-3">
            <User :size="22" class="mt-1" />
            <div>
                <h1 class="text-xl font-bold text-slate-900">Account Management</h1>
                <p class="text-sm text-slate-500">Manage access, assign roles, and keep your workspace secure.</p>
            </div>
        </header>

        <p v-if="successMessage" role="status" class="mb-4 rounded-lg bg-emerald-50 p-3 text-sm text-emerald-700">
            {{ successMessage }}
        </p>
        <p v-if="errorMessage && !isCreateModalOpen && !roleModalAccount" role="alert"
            class="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">{{ errorMessage }}</p>

        <section class="mb-5 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            <div v-for="card in [
                { label: 'Super Admin', detail: 'Account management access', role: 'super_admin', color: 'bg-blue-500' },
                { label: 'Administrators', detail: 'Administrative access', role: 'admin', color: 'bg-blue-500' },
                { label: 'Personnel', detail: 'Operational access', role: 'personnel', color: 'bg-emerald-500' },
                { label: 'Beneficiaries', detail: 'Beneficiary access', role: 'beneficiary', color: 'bg-violet-500' }
            ]" :key="card.role" class="rounded-2xl border border-blue-100 bg-white p-4">
                <div class="flex items-start justify-between gap-3">
                    <div>
                        <p class="text-sm font-semibold text-slate-900">{{ card.label }}</p>
                        <p class="text-xs text-slate-500">{{ card.detail }}</p>
                    </div>
                    <p class="text-3xl font-bold leading-none text-slate-900">{{ roleCounts[card.role] }}</p>
                </div>
                <div class="mt-4 flex items-center justify-between text-xs font-medium text-slate-500">
                    <span class="flex items-center gap-2">
                        <span class="h-2 w-2 rounded-full" :class="card.color"></span>
                        {{ roleCounts[card.role] }} account(s)
                    </span>
                    <ArrowUpRight :size="14" class="text-blue-500" />
                </div>
            </div>
        </section>

        <section class="mb-5 overflow-hidden rounded-2xl border border-slate-200 bg-white">
            <div class="flex flex-wrap items-end justify-between gap-4 p-5">
                <div>
                    <h2 class="flex items-center gap-2 text-xl font-bold">
                        All users
                        <span class="rounded-full bg-blue-50 px-2.5 py-0.5 text-xs font-semibold text-blue-600">
                            {{ filteredAccounts.length }}
                        </span>
                    </h2>
                    <p class="text-xs text-slate-500">Review and manage user accounts</p>
                </div>

                <div class="flex flex-wrap items-end gap-3">
                    <div class="relative w-72">
                        <Search :size="16" class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                        <input v-model="searchQuery" type="search" placeholder="Search name or email..."
                            class="w-full rounded-lg border border-slate-200 bg-slate-50 py-2.5 pl-10 pr-3 text-sm outline-none placeholder:text-slate-400 focus:border-blue-500" />
                    </div>

                    <label class="relative flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2 text-sm text-slate-500">
                        <Package :size="15" />
                        <select v-model="selectedRole" class="settings-filter-select appearance-none bg-transparent pr-6 outline-none">
                            <option>All roles</option>
                            <option>Super Admin</option>
                            <option>Admin</option>
                            <option>Personnel</option>
                            <option>Beneficiary</option>
                        </select>
                        <ChevronDown :size="14" class="pointer-events-none absolute right-3" />
                    </label>

                    <button type="button" @click="openCreateModal"
                        class="flex items-center gap-1 rounded-lg bg-blue-600 px-4 py-2.5 text-sm font-medium text-white hover:bg-blue-700">
                        <Plus :size="14" /> Add User
                    </button>
                </div>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full min-w-[900px] text-left text-sm">
                    <thead>
                        <tr class="border-y border-slate-200 bg-slate-50 text-[11px] font-semibold uppercase tracking-wide text-slate-500">
                            <th class="px-5 py-3">User</th>
                            <th class="px-5 py-3">Email address</th>
                            <th class="px-5 py-3">Role</th>
                            <th class="px-5 py-3">Created</th>
                            <th class="px-5 py-3"></th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <tr v-if="isLoading">
                            <td colspan="5" class="px-5 py-8 text-center text-sm text-slate-500">Loading accounts...</td>
                        </tr>
                        <tr v-else-if="!filteredAccounts.length">
                            <td colspan="5" class="px-5 py-8 text-center text-sm text-slate-500">
                                {{ errorMessage || 'No accounts found.' }}
                            </td>
                        </tr>
                        <tr v-for="account in filteredAccounts" :key="account.id" class="hover:bg-slate-50">
                            <td class="px-5 py-4">
                                <div class="flex items-center gap-3">
                                    <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-blue-600 text-xs font-semibold text-white">
                                        {{ getInitials(account) }}
                                    </div>
                                    <div>
                                        <p class="font-semibold text-slate-900">{{ getName(account) }}</p>
                                        <p class="text-xs text-slate-500">{{ account.id }}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-5 py-4 text-slate-700">{{ account.email }}</td>
                            <td class="px-5 py-4">
                                <span class="rounded-full bg-blue-50 px-3 py-1 text-xs font-semibold text-blue-600">
                                    {{ account.role?.replace('_', ' ') }}
                                </span>
                            </td>
                            <td class="px-5 py-4 font-medium text-slate-500">{{ formatCreatedAt(account.created_at) }}</td>
                            <td class="px-5 py-4 text-right">
                                <button type="button" @click="openRoleModal(account)"
                                    class="rounded-lg p-2 text-slate-500 hover:bg-slate-100" aria-label="Change account role">
                                    <EllipsisVertical :size="18" />
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>

        <div v-if="isCreateModalOpen" class="fixed inset-0 z-[70] flex items-center justify-center bg-black/40 p-4">
            <form @submit.prevent="saveNewAccount" class="max-h-[90vh] w-full max-w-xl overflow-y-auto rounded-xl bg-white p-6 shadow-xl">
                <div class="mb-5 flex items-center justify-between">
                    <div>
                        <h2 class="text-lg font-bold text-slate-900">Create Account</h2>
                        <p class="text-sm text-slate-500">Enter the same details used during registration.</p>
                    </div>
                    <button type="button" @click="isCreateModalOpen = false" aria-label="Close modal"
                        class="rounded-lg p-2 text-slate-500 hover:bg-slate-100"><X :size="18" /></button>
                </div>
                <p v-if="errorMessage" role="alert" class="mb-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">{{ errorMessage }}</p>
                <div class="grid gap-4 sm:grid-cols-2">
                    <label class="text-sm font-medium text-slate-700">First name *
                        <input v-model.trim="newAccount.firstName" required autocomplete="given-name"
                            class="mt-1 w-full rounded-lg border border-slate-200 bg-gray-50 p-2.5 outline-none focus:border-blue-500">
                    </label>
                    <label class="text-sm font-medium text-slate-700">Middle name
                        <input v-model.trim="newAccount.middleName" autocomplete="additional-name"
                            class="mt-1 w-full rounded-lg border border-slate-200 bg-gray-50 p-2.5 outline-none focus:border-blue-500">
                    </label>
                    <label class="text-sm font-medium text-slate-700">Last name *
                        <input v-model.trim="newAccount.lastName" required autocomplete="family-name"
                            class="mt-1 w-full rounded-lg border border-slate-200 bg-gray-50 p-2.5 outline-none focus:border-blue-500">
                    </label>
                    <label class="text-sm font-medium text-slate-700">Contact number *
                        <input v-model.trim="newAccount.contactNumber" required type="tel" autocomplete="tel"
                            class="mt-1 w-full rounded-lg border border-slate-200 bg-gray-50 p-2.5 outline-none focus:border-blue-500">
                    </label>
                    <label class="text-sm font-medium text-slate-700">Barangay *
                        <input v-model.trim="newAccount.barangay" required autocomplete="address-level3"
                            class="mt-1 w-full rounded-lg border border-slate-200 bg-gray-50 p-2.5 outline-none focus:border-blue-500">
                    </label>
                    <label class="text-sm font-medium text-slate-700">Email *
                        <input v-model.trim="newAccount.email" required type="email" autocomplete="email"
                            class="mt-1 w-full rounded-lg border border-slate-200 bg-gray-50 p-2.5 outline-none focus:border-blue-500">
                    </label>
                    <label class="text-sm font-medium text-slate-700">Password *
                        <input v-model="newAccount.password" required type="password" minlength="8" autocomplete="new-password"
                            class="mt-1 w-full rounded-lg border border-slate-200 bg-gray-50 p-2.5 outline-none focus:border-blue-500">
                    </label>
                    <label class="text-sm font-medium text-slate-700">Confirm password *
                        <input v-model="newAccount.confirmPassword" required type="password" minlength="8" autocomplete="new-password"
                            class="mt-1 w-full rounded-lg border border-slate-200 bg-gray-50 p-2.5 outline-none focus:border-blue-500">
                    </label>
                    <label class="text-sm font-medium text-slate-700">Role *
                        <select v-model="newAccount.role" required
                            class="mt-1 w-full rounded-lg border border-slate-200 bg-gray-50 p-2.5 outline-none focus:border-blue-500">
                            <option value="personnel">Personnel</option>
                            <option value="admin">Admin</option>
                            <option value="beneficiary">Beneficiary</option>
                            <option value="super_admin">Super Admin</option>
                        </select>
                    </label>
                </div>
                <div class="mt-6 flex justify-end gap-3">
                    <button type="button" :disabled="isSaving" @click="isCreateModalOpen = false"
                        class="rounded-lg border border-slate-200 px-4 py-2 text-sm text-slate-600 hover:bg-slate-50">Cancel</button>
                    <button type="submit" :disabled="isSaving"
                        class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50">
                        {{ isSaving ? 'Creating...' : 'Create Account' }}
                    </button>
                </div>
            </form>
        </div>

        <div v-if="roleModalAccount" class="fixed inset-0 z-[70] flex items-center justify-center bg-black/40 p-4">
            <form @submit.prevent="saveRole" class="w-full max-w-md rounded-xl bg-white p-6 shadow-xl">
                <div class="flex items-start justify-between gap-3">
                    <div>
                        <h2 class="text-lg font-bold text-slate-900">Change account role</h2>
                        <p class="mt-1 text-sm text-slate-500">{{ getName(roleModalAccount) }}</p>
                    </div>
                    <button type="button" @click="roleModalAccount = null" aria-label="Close modal"
                        class="rounded-lg p-2 text-slate-500 hover:bg-slate-100"><X :size="18" /></button>
                </div>
                <p v-if="errorMessage" role="alert" class="mt-4 rounded-lg bg-red-50 p-3 text-sm text-red-700">{{ errorMessage }}</p>
                <label class="mt-5 block text-sm font-medium text-slate-700">Role
                    <select v-model="newRole" class="mt-1 w-full rounded-lg border border-slate-200 p-2.5">
                        <option value="personnel">Personnel</option>
                        <option value="admin">Admin</option>
                        <option value="beneficiary">Beneficiary</option>
                        <option value="super_admin">Super Admin</option>
                    </select>
                </label>
                <div class="mt-6 flex justify-end gap-3">
                    <button type="button" :disabled="isSaving" @click="roleModalAccount = null"
                        class="rounded-lg border border-slate-200 px-4 py-2 text-sm text-slate-600 hover:bg-slate-50">Cancel</button>
                    <button type="submit" :disabled="isSaving || newRole === roleModalAccount.role"
                        class="rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50">
                        {{ isSaving ? 'Saving...' : 'Save role' }}
                    </button>
                </div>
            </form>
        </div>
    </div>
</template>
