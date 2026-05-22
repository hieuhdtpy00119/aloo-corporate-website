<script setup>
import Navbar from '../components/public/Navbar.vue'
import Footer from '../components/public/Footer.vue'
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
