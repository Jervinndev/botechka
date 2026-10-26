import { createRouter, createWebHistory } from 'vue-router'
import { Gesstsessionuser, Getuserprofile } from '../services/Authservices.js'

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


router.beforeEach(async (to, from, next) => {

    const sessionResult = await Gesstsessionuser()
    const session = sessionResult.success ? sessionResult.data : null
    let role = session?.user_metadata?.role?.toLowerCase()
    const isGoogleUser = session?.user?.app_metadata?.providers?.includes('google')

    if (session && !role) {
        const profileResult = await Getuserprofile()
        role = profileResult.success ? profileResult.data?.role?.toLowerCase() : ''
    }

    if (to.meta.requiresAuth && !session) {

        return next('/register')
    }

    if (session && (role === 'beneficiary' || isGoogleUser) && to.meta.requiresAuth && !to.meta.beneficiaryOnly) {
        return next('/benefeciarylayout')
    }

    if (to.meta.beneficiaryOnly && role !== 'beneficiary' && !isGoogleUser) {
        return next('/beneficiary-dashboard')
    }

    if (to.name === 'Verification') {
        if (from.name !== 'register') {
            return next('/register')
        }
    }

    if ((to.name === 'login' || to.name === 'register') && session) {
        return next('beneficiary-dashboard')
    }

    next()
})

export default router   