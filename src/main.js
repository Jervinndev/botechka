import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import router from './router/index.js'
import { VueDatePicker } from '@vuepic/vue-datepicker';
import '@vuepic/vue-datepicker/dist/main.css'

function applySavedTheme() {
    const theme = localStorage.getItem('theme') || 'system'
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
    document.documentElement.classList.toggle('dark', theme === 'dark' || (theme === 'system' && prefersDark))
}

applySavedTheme()
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
    if ((localStorage.getItem('theme') || 'system') === 'system') applySavedTheme()
})

createApp(App).component('VueDatePicker', VueDatePicker).use(router).mount('#app')
