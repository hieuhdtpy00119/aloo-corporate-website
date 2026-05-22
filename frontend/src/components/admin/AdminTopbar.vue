<script setup>
import UserMenu from '../public/UserMenu.vue'
import { ExternalLink } from 'lucide-vue-next'
</script>

<template>
  <header class="sticky top-0 z-30 flex items-center justify-between gap-4 border-b border-slate-100 bg-white/80 backdrop-blur-md px-6 py-4">
    <div class="min-w-0">
      <p class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Hệ thống quản trị</p>
      <h1 class="truncate text-lg font-bold text-avocado-950 mt-0.5">ALOO CMS Panel</h1>
    </div>
    <div class="flex shrink-0 items-center gap-3">
      <RouterLink
        to="/"
        class="hidden rounded-full border border-avocado-200/50 hover:bg-avocado-50/50 px-4 py-2 text-xs font-bold text-avocado-800 sm:inline-flex items-center gap-1.5 transition"
      >
        <ExternalLink class="h-3.5 w-3.5" />
        Xem Website
      </RouterLink>
      <div class="h-8 w-px bg-slate-100 hidden sm:block"></div>
      <UserMenu />
    </div>
  </header>
</template>

