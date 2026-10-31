<script setup>
import homeIllustration from '../assets/Screenshot 2026-10-18 192805-DnAjIRY2.png'
import {
    ShieldCheck, NotebookPen, Activity, CalendarClock, Pill, Van, TrendingUp
    , Mail, Stethoscope, CircleUser, ShoppingBag, CalendarCheck2, MessageSquare

} from '@lucide/vue'
import { ref } from 'vue';



const forWhom = [
    {
        title: 'MGA BENEFICIARY',
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
        title: 'KOMUNIDAD NG CALUMPANG',
        description: 'The entire barangay relying on a consistent and dependable supply of medicine from the Botika ng Bayan.',
        icon: `<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a4 4 0 00-3-3.87M9 20H4v-2a4 4 0 013-3.87m6-4.13a4 4 0 100-8 4 4 0 000 8zm-6 8v-2a4 4 0 014-4h4a4 4 0 014 4v2H7z"/></svg>`,
        rotation: 'rotate-4'
    },
]

const faqs = ref([
    { question: 'Kailangan ba ng prescription para makabili ng gamot?', open: false },
    { question: 'Sino ang kwalipikadong tumanggap ng libreng gamot?', open: false },
    { question: 'Ilang beses pwedeng kumuha ng gamot kada buwan?', open: false },
    { question: 'Ano ang oras ng operasyon ng Botika ng Bayan?', open: false },
])


const features = ref([
    {
        title: 'Free Medicine Distribution',
        description: 'Recorded distribution to qualified beneficiaries — always free of charge.',
        icon: Pill
    },
    {
        title: 'Inventory Management',
        description: 'Real-time monitoring ng stock levels, batch numbers, at expiration dates ng lahat ng gamot.',
        icon: Van
    },
    {
        title: 'Expiration Monitoring',
        description: 'Batch-level expiry tracking with critical and warning alerts.',
        icon: ShoppingBag
    },
    {
        title: 'Inventory Forecasting',
        description: 'Prediction ng fast-moving at slow-moving na gamot para sa mas mahusay na stock planning.',
        icon: TrendingUp

    },
    {
        title: 'Alerts & Notifications',
        description: 'Automatic na alerts para sa low-stock at malapit nang mag-expire na gamot.',
        icon: CalendarClock
    },
    {
        title: 'Reports & Analytics',
        description: 'Pagbuo ng detalyadong reports para sa inventory, distribution, at expiration monitoring.',
        icon: MessageSquare

    }
])


const benepisyaryoSteps = ref([
    {
        num: '01',
        title: 'Consult',
        desc: 'Ipakita ang iyong reseta o health record sa Botika ng Bayan.'
    },
    {
        num: '02',
        title: 'Receive',
        desc: 'Tanggapin ang gamot na ibibigay ng FEFO (first expiry, first out) at mare-record.'
    },
    {
        num: '03',
        title: 'Monitor',
        desc: 'Subaybayan ang updates sa stock levels, analytics, at demand forecast.'
    },
    {
        num: '04',
        title: 'Forecast',
        desc: 'Awtomatikong alerto kapag bumaba sa ligtas na threshold ang supplies.'
    },
    {
        num: '05',
        title: 'Replenish',
        desc: 'Ipadala ang restock request diretso sa Municipal Rural Health Unit.'
    }
])

const sistemaSteps = ref([
    {
        num: '01',
        title: 'Mag-log in sa Sistema',
        desc: 'Ilagay ang iyong admin credentials upang makapasok sa pangunahing dashboard.'
    },
    {
        num: '02',
        title: 'I-check ang Inventory',
        desc: 'Tingnan ang listahan ng mga gamot, kasama ang batch numbers, quantity, at expiration dates.'
    },
    {
        num: '03',
        title: 'Magdagdag ng Bagong Stock',
        desc: 'Pindutin ang Add New Item button para i-encode ang mga bagong dating na gamot.'
    },
    {
        num: '04',
        title: 'Suriin ang Forecasting',
        desc: 'Abangan ang mga gamot na malapit nang maubos o abot sa low-stock threshold.'
    },
    {
        num: '05',
        title: 'Mag-submit ng Requisition',
        desc: 'Gumawa at magpasa ng restock request para sa mga kinakailangang suplay patungo sa RHU.'
    }
])

</script>


<template>
    <!-- HERO — real Botika ng Bayan photo as background, dark overlay for readability -->
    <section class="box-bg relative bg-center bg-cover">
        <div class="relative w-full flex items-center justify-center pt-25 2xl:pt-44 pb-6 transition-all duration-100">
            <div class="mx-auto max-w-7xl w-full grid 2xl:grid-cols-2 grid-cols-1">
                <div class="flex flex-col items-start gap-5 font-outfit max-w-xl 2xl:px-0 px-4">
                    <div class="flex items-center gap-2 px-3 py-1 rounded-full w-fit bg-white border border-black/10">
                        <div class="h-2 w-2 bg-blue-500 rounded-full">
                            <div class="h-2 w-2 bg-blue-500 rounded-full  animate-ping"></div>
                        </div>
                        <p class="text-gray-500 text-sm">Rural Health Unit &middot; Botika ng Bayan</p>
                    </div>

                    <h1 class="text-4xl 2xl:text-5xl font-black font-interl leading-10 2xl:leading-14 text-black/70">
                        Smart <span class="text-blue-700">Medicine Management</span> for Botika ng Bayan.
                    </h1>

                    <p class="text-gray-500 leading-7 font-inter 2xl:text-lg text-md ">
                        BoTechka simplifies medicine inventory management and distribution for Botika ng Bayan in
                        Binangonan, Rizal.
                    </p>

                    <div class="grid 2xl:grid-cols-2 grid-cols-1 2xl:w-fit gap-3 text-md w-full">
                        <button
                            class="2xl:p-3 p-2.5 w-full 2xl:w-35 rounded-xl bg-blue-700 text-white font-semibold hover:bg-blue-600 transition-colors">
                            View Details
                        </button>
                        <router-link to="/register"
                            class="flex items-center justify-center 2xl:p-3 p-2.5 w-full 2xl:w-30 rounded-xl  bg-white text-gray-800  hover:bg-white/10 transition-colors">
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
        class="w-full flex items-center justify-center px-6 md:px-10 pt-5 pb-20 2xl:pt-30 2xl:pb-28 transition-all duration-100">
        <div class="max-w-7xl mx-auto w-full">

            <!-- <div class="flex items-start justify-start flex-col gap-3 font-outfit text-start">
                <h1 class="text-3xl font-black text-gray-800">A Smart Way to Manage Medicine Resources
                </h1>
                <p class="text-gray-500 max-w-lg font-inter">
                    Mula sa pagtanggap ng suplay hanggang sa pamamahagi — sinusuportahan ng
                    sistema ang bawat hakbang ng operasyon ng Botika ng Bayan.
                </p>
            </div> -->
            <div class="grid md:grid-cols-3 gap-4 pt-8">
                <div v-for="(feature, index) in features" :key="index"
                    class="group grid gap-2.5 bg-white rounded-2xl p-6 border border-gray-100 hover:shadow-2xl hover:shadow-gray-200 hover:-translate-y-1 transition-all duration-300">
                    <div
                        class="bg-blue-700/10 h-11 w-11 rounded-xl flex items-center justify-center text-blue-700 mb-3 group-hover:scale-110 transition-transform duration-300">
                        <component :is="feature.icon" class="w-5 h-5" />
                    </div>
                    <h3 class="font-semibold text-gray-900">{{ feature.title }}</h3>
                    <p class="text-gray-400 font-inter text-md leading-relaxed">
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
    <section ref="built"
        class="w-full flex flex-col items-center justify-center 2xl:py-20 py-10 px-6 lg:px-16 overflow-hidden">
        <div class="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
            <div class="lg:col-span-6 grid 2xl:grid-cols-2 sm:grid-cols-1 gap-6 relative py-6 order-1">
                <div v-for="value in forWhom" :key="value.title"
                    class="bg-white  grid gap-4 p-6 rounded-2xl border border-slate-100 transform transition-transform hover:rotate-0 hover:shadow-2xl hover:shadow-gray-200 duration-300">
                    <div class="h-11 w-11 rounded-lg bg-blue-700/10 flex items-center justify-center text-blue-600"
                        v-html="value.icon"></div>
                    <h3 class="font-bold text-gray-900 text-lg tracking-wide">{{ value.title }}</h3>
                    <p class="text-md text-gray-400 font-inter leading-relaxed">{{ value.description }}</p>
                </div>
            </div>
            <div class="lg:col-span-6 flex flex-col gap-3 2xl:order-2">
                <h2 class="text-3xl lg:text-5xl font-extrabold text-black/70 leading-tight">
                    Nagsisilbi para sa <span class="text-blue-600">kalusugan ng komunidad</span>
                </h2>
                <p class="2xl:text-lg text-md font-inter text-gray-400 leading-relaxed">
                    Ang Botechka ay isang comprehensive na sistema para sa inventory management,
                    distribution monitoring, at inventory forecasting — tinutulungan ang Botika ng
                    Bayan sa Binangonan, Rizal na mapanatili ang sapat na suplay ng gamot para sa
                    komunidad.
                </p>
                <div class="space-y-4 pt-2">
                    <div v-for="faq in faqs" :key="faq.question"
                        class="bg-white p-4 rounded-xl border border-slate-100 flex items-center justify-between cursor-pointer hover:border-blue-200 transition-all"
                        @click="faq.open = !faq.open">
                        <span class="text-md font-regular font-inter text-gray-400">{{ faq.question }}</span>
                        <span
                            class="w-7 h-7 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center font-bold text-sm shrink-0 transition-transform"
                            :class="{ 'rotate-45': faq.open }">+</span>
                    </div>
                </div>
            </div>
        </div>
    </section>
</template>


<style scoped>
.box-bg {
    background-image:
        linear-gradient(to right, #00000010 1px, transparent 0.5px),
        linear-gradient(to bottom, #0000000d 1px, transparent 0.5px);

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