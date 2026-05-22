<script setup>
defineProps({
  item: {
    type: Object,
    required: true,
  },
})
</script>

<template>
  <article class="rounded-3xl border border-avocado-100/40 bg-white p-6 shadow-sm hover-lift transition">
    <h3 class="text-xl font-bold text-avocado-950">{{ item.title }}</h3>
    <p class="mt-4 text-3xl font-black text-avocado-800 tracking-tight">{{ item.amount }}</p>
    <div class="mt-4 h-px bg-slate-100 w-full"></div>
    <p class="mt-4 text-sm leading-relaxed text-slate-500">{{ item.note }}</p>
  </article>
</template>

