<script setup>
import { watch } from 'vue'
import { useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import Navbar from '../components/public/Navbar.vue'
import Footer from '../components/public/Footer.vue'
import { applyRouteSeo } from '../services/seoService'

const route = useRoute()
const { locale, t } = useI18n()

watch(locale, () => {
  applyRouteSeo(route.path, t)
})
</script>

<template>
  <div class="flex min-h-screen flex-col bg-white text-slate-900">
    <Navbar />
    <main class="min-h-[calc(100vh-4rem)] flex-1">
      <RouterView v-slot="{ Component }">
        <component :is="Component" :key="$route.fullPath" />
      </RouterView>
    </main>
    <Footer />
  </div>
</template>
