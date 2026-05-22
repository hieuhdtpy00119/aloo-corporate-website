<script setup>
defineProps({
  eyebrow: String,
  title: String,
  description: String,
})
</script>

<template>
  <div class="mx-auto mb-12 max-w-2xl text-center">
    <span v-if="eyebrow" class="mb-3 inline-block text-[11px] font-bold uppercase tracking-[0.2em] text-avocado-600 bg-avocado-50 border border-avocado-100/50 px-3 py-1 rounded-full shadow-inner">{{ eyebrow }}</span>
    <h2 class="text-3xl font-black text-avocado-950 sm:text-4xl mt-2">{{ title }}</h2>
    <div class="mt-3.5 h-1 w-12 bg-cream-400 rounded-full mx-auto"></div>
    <p v-if="description" class="mt-4 text-sm leading-relaxed text-slate-500 max-w-xl mx-auto">{{ description }}</p>
  </div>
</template>

