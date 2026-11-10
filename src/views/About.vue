<script setup>
import { Eye, MapPin, Mail, Clock2 } from '@lucide/vue';


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
    <main class="bg-slate-50">
        <section class="relative overflow-hidden bg-gradient-to-br from-blue-50 via-white to-blue-100 px-6 pb-16 pt-32 md:px-10 lg:pb-24">
            <div class="pointer-events-none absolute -right-24 -top-20 h-80 w-80 rounded-full bg-blue-200/40 blur-3xl"></div>
            <div class="relative mx-auto grid max-w-7xl gap-10 lg:grid-cols-2 lg:items-center">
                <div>
                    <p class="font-inter text-sm font-semibold uppercase tracking-[0.18em] text-blue-700">Tungkol sa RHUBoTechka</p>
                    <h1 class="mt-4 font-outfit text-4xl font-black leading-tight text-gray-900 sm:text-5xl">
                        Naglilingkod sa <span class="text-blue-700">kalusugan</span> ng Calumpang
                    </h1>
                    <p class="mt-5 max-w-xl font-inter text-base leading-relaxed text-gray-600 sm:text-lg">
                        Ang RHUBoTechka ay isang comprehensive na sistema para sa inventory management,
                        distribution monitoring, at inventory forecasting — tinutulungan ang Botika ng
                        Bayan sa Binangonan, Rizal na mapanatili ang sapat na suplay ng gamot para sa
                        komunidad.
                    </p>
                    <div class="mt-7 flex flex-wrap gap-3">
                        <router-link to="/#services" class="rounded-xl bg-blue-700 px-5 py-3 font-inter text-sm font-semibold text-white transition hover:bg-blue-800">
                            Tingnan ang serbisyo
                        </router-link>
                        <router-link to="/#contact" class="rounded-xl border border-blue-200 bg-white px-5 py-3 font-inter text-sm font-semibold text-blue-800 transition hover:bg-blue-50">
                            Makipag-ugnayan
                        </router-link>
                    </div>
                </div>
                <div class="grid gap-4 sm:grid-cols-2">
                    <div v-for="(item, index) in visionMissionItems" :key="index"
                        class="rounded-2xl border border-blue-100 bg-white p-6 shadow-lg shadow-blue-900/5 transition duration-300 hover:-translate-y-1">
                        <div class="mb-4 flex h-11 w-11 items-center justify-center rounded-xl bg-blue-700/10 text-blue-700">
                            <component :is="item.icon" class="h-5 w-5" />
                        </div>
                        <h2 class="mb-2 font-inter text-sm font-bold tracking-wide text-gray-900">{{ item.title }}</h2>
                        <p class="font-outfit text-sm leading-relaxed text-gray-600">{{ item.description }}</p>
                    </div>
                    <div v-for="(item, index) in objectivesItems" :key="`objective-${index}`"
                        class="rounded-2xl border border-blue-100 bg-white p-6 shadow-lg shadow-blue-900/5 transition duration-300 hover:-translate-y-1">
                        <div class="mb-4 flex h-11 w-11 items-center justify-center rounded-xl bg-blue-700/10 text-blue-700">
                            <component :is="item.icon" class="h-5 w-5" />
                        </div>
                        <h2 class="mb-2 font-inter text-sm font-bold tracking-wide text-gray-900">{{ item.title }}</h2>
                        <p class="font-outfit text-sm leading-relaxed text-gray-600">{{ item.description }}</p>
                    </div>
                </div>
            </div>
        </section>

    <section class="px-6 py-16 md:py-20">
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
                <details v-for="(faq, index) in faq" :key="index" class="group overflow-hidden rounded-2xl border border-blue-100 bg-white shadow-sm">
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
    </main>
</template>