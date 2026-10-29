import { createRouter, createWebHistory } from 'vue-router'
import { getCachedMyProfile, getMyProfile, getSessionUser } from '../services/Authservices.js'

// Home page
import Register from '../views/auth/register.vue'
import Login from '../views/auth/login.vue'
import Home from '../views/home.vue'
import About from '../views/About.vue'
import Pagenotfound from '../views/pagenotfound/Pagenotfound.vue'

//Admin dashboard inamo
import Adminlayout from '../components/layout/Adminlayout.vue'
import Dashboard from '../views/admin/Dashboard.vue'
import Inventory from '../views/admin/Inventory.vue'
import Distribution from '../views/admin/Distribution.vue'
import Reports from '../views/admin/Report.vue'
import Categories from '../views/admin/Categories.vue'
import Beneficiary from '../views/admin/Beneficiary.vue'
import Settings from '../views/admin/Settings.vue'
import SettingsAppearance from '../views/Settings/Appearance.vue'
import SettingsAccountManagement from '../views/Settings/AccountManagement.vue'
import SettingsBackupRecovery from '../views/Settings/BackupRecovery.vue'
import SettingsArchive from '../views/Settings/Archive.vue'
import SettingsConfiguration from '../views/Settings/Configuration.vue'
import SettingsSuppliers from '../views/Settings/Suppliers.vue'
import Verification from '../views/Verification/Verification.vue'
import Notification from '../views/admin/Notification.vue'
import Forgotpassword from '../views/auth/Forgotpassword.vue'
import Resetpassword from '../views/auth/ResetPassword.vue'
import Beneficiaryrequest from '../views/admin/BeneficiaryRequest.vue'

// Beneficiary pages
import BeneficiaryDashboard from '../views/beneficiary/BeneficiaryDashboard.vue'
import AvailableMedicines from '../views/beneficiary/AvailableMedicines.vue'
import Beneficiarylayout from '../components/layout/Beneficiarylayout.vue'
import Notificationbene from '../views/beneficiary/Notificationbene.vue'
import Requestmedicines from '../views/beneficiary/Requestmedicines.vue'

// eto mga routes naman to
const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path: '/:pathMatch(.*)*',
            name: 'Pagenotfound',
            component: Pagenotfound,
            meta: { hideHeader: true }
        },
        {
            path: '/',
            name: 'home',
            component: Home
        },
        {
            path: '/about',
            name: 'about',
            component: About
        },
        {
            path: '/register',
            name: 'register',
            component: Register,
            meta: { hideHeader: true }
        },
        {
            path: '/verification',
            name: 'Verification',
            component: Verification,
            meta: { hideHeader: true }
        },
        {
            path: '/login',
            name: 'login',
            component: Login,
            meta: { hideHeader: true }
        },
        {
            path: '/forgot-password',
            name: 'forgot-password',
            component: Forgotpassword,
            meta: { hideHeader: true }
        },
        {
            path: '/reset-password',
            name: 'reset-password',
            component: Resetpassword,
            meta: { hideHeader: true }
        },
        {
            path: '/benefeciarylayout',
            name: 'benefeciarylayout',
            component: Beneficiarylayout,
            meta: { requiresAuth: true, beneficiaryOnly: true, hideHeader: true },
            redirect: { name: 'beneficiary-dashboard' },
            children: [
                {
                    path: '/beneficiary-dashboard',
                    name: 'beneficiary-dashboard',
                    component: BeneficiaryDashboard,
                    meta: { requiresAuth: true, beneficiaryOnly: true, hideHeader: true }
                },
                {
                    path: '/available-medicines',
                    name: 'available-medicines',
                    component: AvailableMedicines,
                    meta: { requiresAuth: true, beneficiaryOnly: true, hideHeader: true }
                },
                {
                    path: '/notificationbene',
                    name: 'notificationbene',
                    component: Notificationbene,
                    meta: { requiresAuth: true, beneficiaryOnly: true, hideHeader: true }
                },
                {
                    path: '/requestmedicines',
                    name: 'requestmedicines',
                    component: Requestmedicines,
                    meta: { requiresAuth: true, beneficiaryOnly: true, hideHeader: true }
                },
            ]
        },
        {
            path: '/Adminlayout',
            name: 'Adminlayout',
            component: Adminlayout,
            meta: { requiresAuth: true, hideHeader: true },
            redirect: { name: 'dashboard' },
            children: [
                {
                    path: '/dashboard',
                    name: 'dashboard',
                    component: Dashboard,
                    meta: { hideHeader: true },
                },
                {
                    path: '/inventory',
                    name: 'inventory',
                    component: Inventory,
                },
                {
                    path: '/distribution',
                    name: 'distribution',
                    component: Distribution,
                },
                {
                    path: '/reports',
                    name: 'reports',
                    component: Reports,
                },
                {
                    path: '/notification',
                    name: 'notification',
                    component: Notification
                },
                {
                    path: '/categories',
                    name: 'categories',
                    component: Categories,
                },
                {
                    path: '/beneficiaries',
                    name: 'beneficiaries',
                    component: Beneficiary,
                },
                {
                    path: '/beneficiaryrequest',
                    name: 'beneficiaryrequest',
                    component: Beneficiaryrequest,
                },
                {
                    path: '/settings',
                    name: 'settings',
                    component: Settings,
                    redirect: { name: 'settings-appearance' },
                    children: [
                        {
                            path: 'appearance',
                            name: 'settings-appearance',
                            component: SettingsAppearance
                        },
                        {
                            path: 'account-management',
                            name: 'settings-account-management',
                            component: SettingsAccountManagement
                        },
                        {
                            path: 'backup-recovery',
                            name: 'settings-backup-recovery',
                            component: SettingsBackupRecovery
                        },
                        {
                            path: 'archive',
                            name: 'settings-archive',
                            component: SettingsArchive
                        },
                        {
                            path: 'configuration',
                            name: 'settings-configuration',
                            component: SettingsConfiguration
                        },
                        {
                            path: 'suppliers',
                            name: 'settings-suppliers',
                            component: SettingsSuppliers
                        }
                    ]
                }
            ]
        }

    ],
    scrollBehavior(to, from, Saveposition) {
        if (Saveposition) {
            return Saveposition
        } else {
            return {
                top: 0,
                left: 0,
                behavior: 'instant'
            }
        }
    }
})


router.beforeEach(async (to, from) => {
    const sessionResult = await getSessionUser()
    if (!sessionResult.success) {
        console.error('Unable to check the current session:', sessionResult.error)
        return to.meta.requiresAuth ? { name: 'login' } : true
    }

    const session = sessionResult.data
    const user = session?.user
    const isAuthenticated = Boolean(user)

    if (to.name === 'Verification' && from.name !== 'register') {
        return { name: 'register' }
    }

    if (to.meta.requiresAuth && !isAuthenticated) {
        return { name: 'login' }
    }

    let role = ''
    if (isAuthenticated && (to.meta.requiresAuth || to.name === 'login' || to.name === 'register')) {
        let profile = getCachedMyProfile(user.id)
        if (!profile) {
            const profileResult = await getMyProfile()
            if (!profileResult.success) {
                console.error('Unable to load the current user profile:', profileResult.error)
                if (to.meta.requiresAuth) {
                    return { name: 'login' }
                }
            } else {
                profile = profileResult.data
            }
        }
        role = profile?.role?.toLowerCase() || ''
    }

    if (to.meta.beneficiaryOnly && role !== 'beneficiary') {
        return { name: role ? 'dashboard' : 'login' }
    }

    if (isAuthenticated && role === 'beneficiary' && to.meta.requiresAuth && !to.meta.beneficiaryOnly) {
        return { name: 'beneficiary-dashboard' }
    }

    if (isAuthenticated && (to.name === 'login' || to.name === 'register')) {
        return { name: role === 'beneficiary' ? 'beneficiary-dashboard' : 'dashboard' }
    }

    return true
})

export default router   