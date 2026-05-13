<script setup>
defineProps({
  eyebrow: String,
  title: String,
  description: String,
})
</script>

<template>
  <div class="mx-auto mb-10 max-w-3xl text-center">
    <p v-if="eyebrow" class="mb-3 text-sm font-black uppercase tracking-wider text-avocado-600">{{ eyebrow }}</p>
    <h2 class="text-3xl font-black text-avocado-950 sm:text-4xl">{{ title }}</h2>
    <p v-if="description" class="mt-4 text-base leading-7 text-slate-600">{{ description }}</p>
  </div>
</template>
