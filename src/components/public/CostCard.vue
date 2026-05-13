<script setup>
defineProps({
  item: {
    type: Object,
    required: true,
  },
})
</script>

<template>
  <article class="rounded-lg border border-cream-200 bg-white p-6 shadow-sm">
    <h3 class="text-xl font-black text-avocado-950">{{ item.title }}</h3>
    <p class="mt-4 text-3xl font-black text-avocado-700">{{ item.amount }}</p>
    <p class="mt-4 leading-7 text-slate-600">{{ item.note }}</p>
  </article>
</template>
