<script setup>
defineProps({
  label: String,
  value: [String, Number],
  tone: {
    type: String,
    default: 'green',
  },
})
</script>

<template>
  <article class="rounded-lg border border-slate-200 bg-white p-6 shadow-sm">
    <p class="text-sm font-bold text-slate-500">{{ label }}</p>
    <p class="mt-3 text-4xl font-black" :class="tone === 'yellow' ? 'text-cream-600' : 'text-avocado-700'">{{ value }}</p>
  </article>
</template>
