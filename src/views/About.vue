<script setup>
import { ref, onMounted } from 'vue';
import { Eye, MapPin, Mail, Clock2 } from '@lucide/vue';
import gsap from 'gsap';


const visionMissionItems = [
    {
        title: 'VISION',
        description: 'Isang Botika ng Bayan na walang naaantalang suplay ng gamot — suportado ng teknolohiyang nagbibigay-daan sa mas episyenteng paglilingkod sa komunidad ng Calumpang.',
        icon: Eye
    },
    {
        title: 'MISSION',
        description: 'Magbigay ng real-time na kakayahan sa pagsubaybay ng imbentaryo, pagtataya ng suplay, at pamamahagi ng gamot upang walang residente ang mabale-wala dahil sa kakulangan sa stock.',
        icon: MapPin
    }
]

const objectivesItems = [
    {
        title: 'OBJECTIVES',
        description: 'Masubaybayan nang maayos ang mga batch numbers, manufacturing dates, at expiration dates ng bawat gamot.',
        icon: Mail
    },
    {
        title: 'CORE VALUES',
        description: 'Dedikasyon sa serbisyong pampublikong kalusugan, katumpakan sa datos, at mabilis na pagtugon sa pangangailangan.',
        icon: Clock2
    }
]

const faq = [
    {
        question: 'Ano ang RHUBoTechka?',
        answer: 'Ang RHUBoTechka ay isang inventory management system na ginawa para sa Botika ng Bayan sa Barangay Calumpang, Binangonan, Rizal. Tinutulungan nito ang RHU staff na subaybayan ang stock levels, batch numbers, expiration dates, at demand forecasting ng mga gamot.'
    },
    {
        question: 'Sino ang maaaring gumamit ng sistema?',
        answer: 'Ang RHUBoTechka ay para sa mga admin at staff ng Botika ng Bayan na namamahala ng inventory, distribution, at reports. Kailangan ng isang authorized account para makapag-log in sa dashboard.'
    },
    {
        question: 'Paano gumagana ang inventory forecasting?',
        answer: 'Sinusuri ng sistema ang distribution history para tantiyahin kung aling mga gamot ang mabilis o mabagal maubos, para makapaghanda nang maaga ang RHU staff sa mga restock request.'
    },
    {
        question: 'May bayad ba ang paggamit ng RHUBoTechka?',
        answer: 'Hindi. Ang RHUBoTechka ay isang internal na sistema para sa Botika ng Bayan, walang bayad ang paggamit nito para sa RHU staff.'
    },
    {
        question: 'Paano ako makakakuha ng account?',
        answer: 'Mag-click sa "Get Started" o "Register" button sa itaas, punan ang iyong impormasyon, at piliin ang iyong role. Kakailanganin ng approval mula sa RHU admin bago maka-access sa buong dashboard.'
    }
]


</script>

<template>
    <section class="relative min-h-screen py-8 px-4 sm:px-6 lg:px-8 pt-32 overflow-hidden">

        <!-- 1. Full-width Background Image sa likod ng buong section -->
        <div class="absolute inset-0 bg-cover bg-center bg-no-repeat"
            :style="{ backgroundImage: `url('/botika-ng-bayan.jpg')` }">
        </div>

        <!-- 2. White Shadow / Gradient Overlay (Para sa puting shadow effect papuntang kanan) -->
        <div
            class="absolute w-full inset-0 bg-gradient-to-r from-transparent via-blue-950/70 to-blue-950/70 pointer-events-none">
        </div>

        <!-- 3. Ang iyong eksaktong content structure (Naka-relative para lumitaw sa ibabaw ng background) -->
        <div class="relative z-10 max-w-7xl mx-auto grid lg:grid-cols-2 gap-12 items-start">

            <!-- Kaliwang bahagi (Puwede mong lagyan ng blangko o transparent spacer para mas ma-highlight ang kanan) -->
            <div class="hidden lg:block"></div>

            <!-- Kanang bahagi (Dito nakalagay ang lahat ng buong content at grid items mo) -->
            <div>
                <h1 class="text-3xl 2xl:text-5xl font-black font-outfit text-gray-100 leading-tight mt-4 mb-4">
                    Naglilingkod sa
                    <span class="text-blue-600">Kalusugan</span>
                    ng Calumpang
                </h1>
                <p class="text-gray-200 font-outfit text-lg leading-relaxed mb-10 max-w-xl">
                    Ang RHUBoTechka ay isang comprehensive na sistema para sa inventory management,
                    distribution monitoring, at inventory forecasting — tinutulungan ang Botika ng
                    Bayan sa Binangonan, Rizal na mapanatili ang sapat na suplay ng gamot para sa
                    komunidad.
                </p>
                <div class="grid sm:grid-cols-2 gap-4 mb-4">
                    <div v-for="(item, index) in visionMissionItems" :key="index"
                        class="bg-white rounded-2xl p-6 hover:-translate-y-1 transition-all duration-300">
                        <div
                            class="h-10 w-10 rounded-lg bg-blue-700/10 flex items-center justify-center text-blue-700 mb-4">
                            <component :is="item.icon" class="h-5 w-5" />
                        </div>
                        <h2 class="font-bold tracking-wide text-sm text-gray-900 mb-2">{{ item.title }}</h2>
                        <p class="text-[#808080] text-md font-outfit leading-relaxed">
                            {{ item.description }}
                        </p>
                    </div>
                </div>
                <div class="grid sm:grid-cols-2 gap-4">
                    <div v-for="(item, index) in objectivesItems" :key="index"
                        class="bg-white rounded-2xl p-6 hover:-translate-y-1 transition-all duration-300">
                        <div
                            class="h-10 w-10 rounded-lg bg-blue-700/10 flex items-center justify-center text-blue-700 mb-4">
                            <component :is="item.icon" class="h-5 w-5" />
                        </div>
                        <h2 class="font-bold tracking-wide text-sm text-gray-900 mb-2">{{ item.title }}</h2>
                        <p class="text-[#808080] text-md font-outfit leading-relaxed">
                            {{ item.description }}
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="py-16 px-6">
        <div class="max-w-3xl mx-auto text-center">
            <span class="inline-flex items-center gap-2 text-sm font-semibold text-blue-700 mb-3">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none"
                    stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10" />
                    <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
                    <path d="M12 17h.01" />
                </svg>
                FAQ
            </span>
            <h2 class="text-3xl font-extrabold font-outfit text-[#404040] mb-2">Frequently Asked Questions</h2>
            <p class="text-[#808080] font-outfit mb-10">Everything you need to know about RHUBoTechka.</p>
            <div class="space-y-4 text-left">
                <details v-for="(faq, index) in faq" :key="index" class="group bg-white rounded-2xl overflow-hidden">
                    <summary class="list-none cursor-pointer flex items-center justify-between gap-4 px-6 py-5">
                        <span class="font-bold font-outfit text-lg text-[#404040]">{{ faq.question }}</span>
                        <span
                            class="h-8 w-8 shrink-0 rounded-full bg-blue-700/10 text-blue-700 flex items-center justify-center transition-transform duration-300 group-open:rotate-45">
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none"
                                stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M5 12h14" />
                                <path d="M12 5v14" />
                            </svg>
                        </span>
                    </summary>
                    <p class="px-6 pb-5 text-[#808080] font-outfit text-md leading-relaxed">
                        {{ faq.answer }}
                    </p>
                </details>
            </div>
        </div>
    </section>
</template>