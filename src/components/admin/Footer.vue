<template>
    <footer class="bg-white text-gray-400 border-t border-slate-800/10 font-outfit">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 lg:py-16">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 lg:gap-12">
                <!-- Brand Info -->
                <div class="space-y-4">
                    <div class="flex items-center gap-3">
                        <router-link to="/" class="flex items-center gap-3">
                            <div>
                                <img src="/src/dist/BotikaBLUE.png" alt="" class="w-40">
                            </div>
                        </router-link>
                    </div>
                    <p class="text-md dark:text-gray-500 text-gray-400 leading-relaxed">
                        A Medicine Management System with Inventory Forecasting for Botika ng Bayan in Barangay
                        Calumpang, Binangonan, Rizal.
                    </p>
                </div>

                <!-- Quick Links -->
                <div class="space-y-4">
                    <h3 class="text-xs font-semibold text-gray-400  uppercase tracking-wider">
                        Quick Links
                    </h3>
                    <ul class="space-y-2.5 text-md text-gray-500">
                        <li><a href="#" class="hover:text-blue-400 transition-colors">Home</a></li>
                        <li><a href="#" class="hover:text-blue-400 transition-colors">About</a></li>
                        <li><a href="#" class="hover:text-blue-400 transition-colors">Services</a></li>
                        <li><a href="#" class="hover:text-blue-400 transition-colors">Guidelines</a></li>
                        <li><a href="#" class="hover:text-blue-400 transition-colors">Contact</a></li>
                    </ul>
                </div>

                <!-- System Features -->
                <div class="space-y-4">
                    <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wider">
                        System Features
                    </h3>
                    <ul class="space-y-2.5 text-md text-gray-500">
                        <li><a href="#" class="hover:text-blue-400 transition-colors">Inventory Forecasting</a></li>
                        <li><a href="#" class="hover:text-blue-400 transition-colors">Batch & Expiration Tracking</a>
                        </li>
                        <li><a href="#" class="hover:text-blue-400 transition-colors">Medicine Dispensing Logs</a></li>
                        <li><a href="#" class="hover:text-blue-400 transition-colors">Beneficiary Schedules</a></li>
                        <li><a href="#" class="hover:text-blue-400 transition-colors">Stock Demand Analytics</a></li>
                    </ul>
                </div>

                <!-- Location & Contact -->
                <div class="space-y-4">
                    <h3 class="text-xs font-semibold text-gray-400 uppercase tracking-wider">
                        Botika ng Bayan
                    </h3>
                    <div class="space-y-2.5 text-md ">
                        <p class="text-gray-500">
                            <span class="text-gray-500 font-medium">Barangay Calumpang</span><br />
                            Binangonan, Rizal
                        </p>
                        <p class="text-gray-500 text-md">
                            Municipal Rural Health Unit (RHU) Managed
                        </p>
                        <a href="mailto:support@rhubotechka.local"
                            class="text-md  text-blue-400 hover:text-blue-300 font-medium transition-colors inline-block pt-1">
                            support@rhubotechka.local
                        </a>
                    </div>
                </div>
            </div>

            <!-- Bottom Copyright -->
            <div
                class="mt-12 pt-6 dark:border-t dark:border-slate-800/10 border-t border-gray-50/10 flex flex-col sm:flex-row justify-between items-center gap-4 text-xs text-gray-400">
                <p>&copy; 2026 RHU-BoTechKa. All rights reserved.</p>
                <p class="text-gray-400 font-medium rounded-full">
                    Developed for Brgy. Calumpang, Binangonan, Rizal Capstone Project
                </p>
            </div>
        </div>
    </footer>
</template>