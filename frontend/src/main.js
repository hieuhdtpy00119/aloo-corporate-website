import { createApp } from 'vue'
import './style.css'
import App from './App.vue'
import router from './router'
import { createPinia } from 'pinia'
import i18n from './plugins/i18n'
import { initAnalytics } from './services/analyticsService'

if (import.meta.env.DEV && 'serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then((registrations) => {
    registrations.forEach((registration) => registration.unregister())
  })
}

createApp(App).use(createPinia()).use(router).use(i18n).mount('#app')
initAnalytics()
