<script setup>
import Navbar from '../components/public/Navbar.vue'
import Footer from '../components/public/Footer.vue'
</script>

<template>
  <div class="min-h-screen bg-white text-slate-900">
    <Navbar />
    <main>
      <RouterView />
    </main>
    <Footer />
  </div>
</template>
