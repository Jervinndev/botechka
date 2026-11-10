<script setup>
import homeIllustration from '../assets/Screenshot 2026-10-18 192805-DnAjIRY2.png'
import {
    ShieldCheck, NotebookPen, Activity, CalendarClock, Pill, Van, TrendingUp
    , Mail, Stethoscope, CircleUser, ShoppingBag, MessageSquare

} from '@lucide/vue'
import { ref } from 'vue';



const forWhom = [
    {
        title: 'BENEFICIARIES',
        description: 'Senior citizens, PWDs, and regular qualified residents receiving free medicines from the Botika ng Bayan.',
        icon: `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>`,
        rotation: '-rotate-4'
    },
    {
        title: 'PHARMACIST & STAFF',
        description: 'The frontline personnel managing daily inventory, distribution, and record-keeping.',
        icon: `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>`,
        rotation: 'rotate-4'
    },
    {
        title: 'RURAL HEALTH UNIT',
        description: 'The RHU oversees and supervises the operations of the Botika ng Bayan in Calumpang.',
        icon: `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0H5m14 0h2M5 21H3m8-14h.01M11 11h.01M11 15h.01M15 7h.01M15 11h.01M15 15h.01M7 7h.01"/></svg>`,
        rotation: '-rotate-4'
    },
    {
        title: 'CALUMPANG COMMUNITY',
        description: 'The entire barangay relying on a consistent and dependable supply of medicine from the Botika ng Bayan.',
        icon: `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a4 4 0 00-3-3.87M9 20H4v-2a4 4 0 013-3.87m6-4.13a4 4 0 100-8 4 4 0 000 8zm-6 8v-2a4 4 0 014-4h4a4 4 0 014 4v2H7z"/></svg>`,
        rotation: 'rotate-4'
    },
]

const faqs = ref([
    { question: 'Do I need a prescription to receive medicine?', open: false },
    { question: 'Who is eligible to receive free medicine?', open: false },
    { question: 'How often can I receive medicine?', open: false },
    { question: 'What are the Botika ng Bayan operating hours?', open: false },
])


const features = ref([
    {
        title: 'Free Medicine Distribution',
        description: 'Recorded distribution to qualified beneficiaries — always free of charge.',
        icon: Pill
    },
    {
        title: 'Inventory Management',
        description: 'Monitor medicine stock levels, batch numbers, and expiration dates in real time.',
        icon: Van
    },
    {
        title: 'Expiration Monitoring',
        description: 'Batch-level expiry tracking with critical and warning alerts.',
        icon: ShoppingBag
    },
    {
        title: 'Inventory Forecasting',
        description: 'Identify fast- and slow-moving medicines to improve stock planning.',
        icon: TrendingUp

    },
    {
        title: 'Alerts & Notifications',
        description: 'Receive alerts for low stock and medicines nearing expiration.',
        icon: CalendarClock
    },
    {
        title: 'Reports & Analytics',
        description: 'Generate detailed inventory, distribution, and expiration reports.',
        icon: MessageSquare

    }
])


const benepisyaryoSteps = ref([
    {
        num: '01',
        title: 'Consult',
        desc: 'Present your prescription or health record to the Botika ng Bayan staff.'
    },
    {
        num: '02',
        title: 'Receive',
        desc: 'Receive the available medicine. Staff will follow FEFO (first expiry, first out) and record the distribution.'
    },
    {
        num: '03',
        title: 'Monitor',
        desc: 'Review updates on stock levels, analytics, and demand forecasts.'
    },
    {
        num: '04',
        title: 'Forecast',
        desc: 'Get automatic alerts when supplies fall below safe thresholds.'
    },
    {
        num: '05',
        title: 'Replenish',
        desc: 'Send restock requests directly to the Municipal Rural Health Unit.'
    }
])

const sistemaSteps = ref([
    {
        num: '01',
        title: 'Sign in to the system',
        desc: 'Enter your authorized account credentials to access the main dashboard.'
    },
    {
        num: '02',
        title: 'Review the inventory',
        desc: 'Check the medicine list, including batch numbers, quantities, and expiration dates.'
    },
    {
        num: '03',
        title: 'Add new stock',
        desc: 'Select Add New Item to record newly received medicines.'
    },
    {
        num: '04',
        title: 'Review forecasts',
        desc: 'Check which medicines are running low or nearing their stock thresholds.'
    },
    {
        num: '05',
        title: 'Submit a requisition',
        desc: 'Prepare and submit a restock request to the RHU for the supplies you need.'
    }
])

</script>


<template>
    <section class="box-bg relative overflow-hidden bg-white bg-center bg-cover">
        <div class="relative w-full flex items-center justify-center pt-25 2xl:pt-44 pb-6 transition-all duration-100">
            <div class="mx-auto max-w-7xl w-full grid 2xl:grid-cols-2 grid-cols-1">
                <div class="flex flex-col items-start gap-5 font-outfit max-w-xl 2xl:px-0 px-4">
                    <div class="flex items-center gap-2 px-3 py-1 rounded-full w-fit bg-white border border-black/30">
                        <div class="h-2 w-2 bg-blue-700 rounded-full">
                            <div class="h-2 w-2 bg-blue-700 rounded-full animate-ping"></div>
                        </div>
                        <p class="text-gray-700 text-sm">Rural Health Unit &middot; Botika ng Bayan</p>
                    </div>

                    <h1 class="text-4xl 2xl:text-6xl font-black font-inter leading-10 2xl:leading-18 text-black/80">
                        Smart <span class="text-blue-700">Medicine Management</span> for Botika ng Bayan.
                    </h1>

                    <p class="text-gray-700 leading-7 font-inter 2xl:text-lg text-md ">
                        BoTechka simplifies medicine inventory management and distribution for Botika ng Bayan in
                        Binangonan, Rizal.
                    </p>

                    <div class="grid 2xl:grid-cols-2 grid-cols-1 2xl:w-fit gap-3 text-md w-full">
                        <router-link to="/#services"
                            class="flex items-center justify-center 2xl:p-3 p-2.5 w-full 2xl:w-35 rounded-xl bg-blue-700 text-white font-semibold hover:bg-blue-800 transition-colors">
                            View Services
                        </router-link>
                        <router-link to="/register"
                            class="flex items-center justify-center 2xl:p-3 p-2.5 w-full 2xl:w-30 rounded-xl border border-black/10 bg-white text-gray-900 hover:bg-blue-50 transition-colors">
                            Get Started
                        </router-link>
                    </div>
                </div>
                <div class="flex flex-1 items-center justify-center [perspective:1000px] 2xl:pt-0 pt-8 p-4">
                    <img :src="homeIllustration" alt="Botika ng Bayan illustration"
                        class="hero-image w-full max-w-[600px] object-cover" />
                </div>
            </div>
        </div>
    </section>


    <!-- SERVICES -->
    <section ref="services" id="services"
        class="w-full flex items-center justify-center px-6 md:px-10 pt-16 pb-20 2xl:pt-24 2xl:pb-28 bg-white transition-all duration-100 scroll-mt-24">
        <div class="max-w-7xl mx-auto w-full">
            <div class="max-w-2xl mb-8">
                <p class="font-inter text-sm font-semibold uppercase tracking-[0.18em] text-blue-700">Services</p>
                <h2 class="mt-2 font-outfit text-3xl sm:text-4xl font-bold text-gray-900">Smarter medicine management
                </h2>
                <p class="mt-3 font-inter leading-relaxed text-gray-700">
                    From receiving supplies to distribution, the system supports every step of Botika ng Bayan
                    operations.
                </p>
            </div>
            <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
                <div v-for="(feature, index) in features" :key="index"
                    class="group grid gap-2.5 bg-white rounded-2xl p-6 border border-black/10 hover:-translate-y-1 transition-all duration-300">
                    <div
                        class="bg-blue-700/10 h-11 w-11 rounded-xl flex items-center justify-center text-blue-700 mb-3 group-hover:scale-110 transition-transform duration-300">
                        <component :is="feature.icon" class="w-5 h-5" />
                    </div>
                    <h3 class="font-semibold text-gray-900">{{ feature.title }}</h3>
                    <p class="text-gray-700 font-inter text-md leading-relaxed">
                        {{ feature.description }}
                    </p>
                </div>
            </div>
        </div>
    </section>

    <!-- <section class="bg-blue-700 h-100 w-full">

    </section>
 -->

    <!-- FOR WHOM + FAQ -->
    <section ref="built" id="community"
        class="w-full flex flex-col items-center justify-center 2xl:py-20 py-14 px-6 lg:px-16 overflow-hidden bg-gray-50 scroll-mt-24">
        <div class="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
            <div class="lg:col-span-6 grid 2xl:grid-cols-2 sm:grid-cols-1 gap-6 relative py-6 order-1">
                <div v-for="value in forWhom" :key="value.title"
                    class="bg-white grid gap-4 p-6 rounded-2xl border border-black/10 transform transition-transform hover:rotate-0 duration-300">
                    <div class="h-11 w-11 rounded-lg bg-blue-100 flex items-center justify-center text-blue-700"
                        v-html="value.icon"></div>
                    <h3 class="font-bold text-gray-900 text-lg tracking-wide">{{ value.title }}</h3>
                    <p class="text-md text-gray-700 font-inter leading-relaxed">{{ value.description }}</p>
                </div>
            </div>
            <div class="lg:col-span-6 flex flex-col gap-3 2xl:order-2">
                <h2 class="text-4xl 2xl:text-5xl font-extrabold text-gray-900 leading-tight">
                    Serving the <span class="text-blue-700">health of our community</span>
                </h2>
                <p class="2xl:text-lg text-md font-inter text-gray-700 leading-relaxed">
                    RHUBoTechka is a comprehensive system for inventory management, distribution monitoring, and
                    forecasting. It helps Botika ng Bayan in Binangonan, Rizal maintain a dependable medicine supply
                    for the community.
                </p>
                <div class="space-y-4 pt-2">
                    <div v-for="faq in faqs" :key="faq.question"
                        class="bg-white p-4 rounded-xl border border-black/10 flex items-center justify-between cursor-pointer transition-all"
                        @click="faq.open = !faq.open">
                        <span class="text-md font-regular font-inter text-gray-700">{{ faq.question }}</span>
                        <span
                            class="w-7 h-7 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center font-bold text-sm shrink-0 transition-transform"
                            :class="{ 'rotate-45': faq.open }">+</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section id="guidelines" class="scroll-mt-24 bg-white px-6 py-16 md:px-10 lg:py-20">
        <div class="mx-auto max-w-7xl">
            <div class="mx-auto mb-10 max-w-2xl text-center">
                <p class="font-inter text-sm font-semibold uppercase tracking-[0.18em] text-blue-700">Guidelines</p>
                <h2 class="mt-2 font-outfit text-3xl font-bold text-gray-900 sm:text-4xl">Medicine distribution
                    guidelines</h2>
                <p class="mt-3 font-inter leading-relaxed text-gray-700">
                    Prepare the required information and speak with staff to help make your visit smooth and efficient.
                </p>
            </div>
            <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                <article class="rounded-2xl border border-black/10 bg-white p-6">
                    <div
                        class="mb-4 flex h-11 w-11 items-center justify-center rounded-xl bg-blue-700/10 text-blue-700">
                        <NotebookPen class="h-5 w-5" />
                    </div>
                    <h3 class="font-outfit text-lg font-semibold text-gray-900">Bring your prescription</h3>
                    <p class="mt-2 font-inter text-sm leading-relaxed text-gray-700">Bring your prescription or health
                        record for review by Botika ng Bayan staff.</p>
                </article>
                <article class="rounded-2xl border border-black/10 bg-white p-6">
                    <div
                        class="mb-4 flex h-11 w-11 items-center justify-center rounded-xl bg-blue-700/10 text-blue-700">
                        <CircleUser class="h-5 w-5" />
                    </div>
                    <h3 class="font-outfit text-lg font-semibold text-gray-900">Confirm eligibility</h3>
                    <p class="mt-2 font-inter text-sm leading-relaxed text-gray-700">Ask staff whether you qualify as a
                        beneficiary and if any additional documents are needed.</p>
                </article>
                <article class="rounded-2xl border border-black/10 bg-white p-6">
                    <div
                        class="mb-4 flex h-11 w-11 items-center justify-center rounded-xl bg-blue-700/10 text-blue-700">
                        <Pill class="h-5 w-5" />
                    </div>
                    <h3 class="font-outfit text-lg font-semibold text-gray-900">Check medicine availability</h3>
                    <p class="mt-2 font-inter text-sm leading-relaxed text-gray-700">Staff will confirm the medicine and
                        available stock before processing distribution.</p>
                </article>
                <article class="rounded-2xl border border-black/10 bg-white p-6">
                    <div
                        class="mb-4 flex h-11 w-11 items-center justify-center rounded-xl bg-blue-700/10 text-blue-700">
                        <ShieldCheck class="h-5 w-5" />
                    </div>
                    <h3 class="font-outfit text-lg font-semibold text-gray-900">Record the distribution</h3>
                    <p class="mt-2 font-inter text-sm leading-relaxed text-gray-700">Staff will record distributed
                        medicine to keep inventory records accurate.</p>
                </article>
            </div>
        </div>
    </section>

    <section id="how-it-works" class="scroll-mt-24 bg-gray-50 px-6 py-16 md:px-10 lg:py-20">
        <div class="mx-auto max-w-7xl">
            <div class="mb-10 max-w-2xl">
                <p class="font-inter text-sm font-semibold uppercase tracking-[0.18em] text-blue-700">How it works</p>
                <h2 class="mt-2 font-outfit text-3xl font-bold text-gray-900 sm:text-4xl">A simple, clear process</h2>
                <p class="mt-3 font-inter leading-relaxed text-gray-700">RHUBoTechka supports both medicine distribution
                    and the day-to-day operations of Botika ng Bayan.</p>
            </div>
            <div class="grid gap-6 lg:grid-cols-2">
                <div class="rounded-3xl border border-black/10 bg-white p-6 sm:p-8">
                    <div class="mb-6 flex items-center gap-3">
                        <div class="flex h-11 w-11 items-center justify-center rounded-xl bg-blue-700 text-white">
                            <Stethoscope class="h-5 w-5" />
                        </div>
                        <div>
                            <p class="font-inter text-sm font-semibold uppercase tracking-wider text-blue-700">For
                                beneficiaries</p>
                            <h3 class="font-outfit text-xl font-bold text-gray-900">Receiving medicine</h3>
                        </div>
                    </div>
                    <ol class="space-y-4">
                        <li v-for="step in benepisyaryoSteps.slice(0, 2)" :key="step.num" class="flex gap-4">
                            <span
                                class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full  bg-blue-50 font-inter text-sm font-bold text-blue-700">{{
                                    step.num }}</span>
                            <div>
                                <h4 class="font-outfit font-semibold text-gray-900">{{ step.title }}</h4>
                                <p class="mt-1 font-inter text-sm leading-relaxed text-gray-700">{{ step.desc }}</p>
                            </div>
                        </li>
                    </ol>
                </div>
                <div class="rounded-3xl border border-black/10 bg-white p-6 sm:p-8">
                    <div class="mb-6 flex items-center gap-3">
                        <div class="flex h-11 w-11 items-center justify-center rounded-xl bg-blue-700/10 text-blue-700">
                            <Activity class="h-5 w-5" />
                        </div>
                        <div>
                            <p class="font-inter text-sm font-semibold uppercase tracking-wider text-blue-700">For staff
                            </p>
                            <h3 class="font-outfit text-xl font-bold text-gray-900">System management</h3>
                        </div>
                    </div>
                    <ol class="space-y-4">
                        <li v-for="step in sistemaSteps" :key="step.num" class="flex gap-4">
                            <span
                                class="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-blue-50 font-inter text-sm font-bold text-blue-700">{{
                                    step.num }}</span>
                            <div>
                                <h4 class="font-outfit font-semibold text-gray-900">{{ step.title }}</h4>
                                <p class="mt-1 font-inter text-sm leading-relaxed text-gray-700">{{ step.desc }}</p>
                            </div>
                        </li>
                    </ol>
                </div>
            </div>
        </div>
    </section>

    <section id="contact" class="scroll-mt-24 bg-blue-700 px-6 py-16 text-white md:px-10 lg:py-20">
        <div class="mx-auto grid max-w-7xl gap-10 lg:grid-cols-2 lg:items-center">
            <div>
                <p class="font-inter text-sm font-semibold uppercase tracking-[0.18em] text-white">Contact</p>
                <h2 class="mt-2 font-outfit text-3xl font-bold sm:text-4xl">Questions about Botika ng Bayan?</h2>
                <p class="mt-4 max-w-xl font-inter leading-relaxed text-white">
                    Contact the Rural Health Unit for questions about services, eligibility, or using RHUBoTechka.
                </p>
            </div>
            <div class="rounded-2xl border border-white/10 bg-white/10 p-6 sm:p-8">
                <div class="flex items-start gap-4">
                    <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-white/10 text-white">
                        <Mail class="h-5 w-5" />
                    </div>
                    <div>
                        <h3 class="font-outfit text-lg font-semibold">Botika ng Bayan · RHU</h3>
                        <p class="mt-1 font-inter text-sm leading-relaxed text-gray-50">Barangay Calumpang, Binangonan,
                            Rizal</p>
                        <a href="mailto:support@rhubotechka.local"
                            class="mt-4 inline-flex rounded-lg bg-white px-4 py-2.5 font-inter text-sm font-semibold text-black transition hover:bg-blue-800 hover:text-white">
                            Email us
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>
</template>


<style scoped>
.box-bg {
    background-image:
        linear-gradient(to right, #00000008 1px, transparent 0.5px),
        linear-gradient(to bottom, #00000008 1px, transparent 0.5px);

    background-size: 70px 70px;
    animation: gridMove 12s linear infinite;
}

@keyframes gridMove {
    from {
        background-position: 0 0;
    }

    to {
        background-position: 40px 40px;
    }
}

@media (prefers-reduced-motion: reduce) {
    .box-bg {
        animation: none;
    }
}

@keyframes float {

    0%,
    100% {
        transform: rotateX(55deg) rotateZ(-20deg) translateY(0);
    }

    50% {
        transform: rotateX(55deg) rotateZ(-20deg) translateY(-10px);
    }
}

.hero-image {
    animation: float 6s ease-in-out infinite;
}

@keyframes float-mobile {

    0%,
    100% {
        transform: translateY(0);
    }

    50% {
        transform: translateY(-10px);
    }
}

@media (max-width: 767px) {
    .hero-image {
        animation: float-mobile 6s ease-in-out infinite;
    }
}
</style>