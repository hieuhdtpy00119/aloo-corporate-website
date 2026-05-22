<script setup>
defineProps({
  step: {
    type: Object,
    required: true,
  },
})
</script>

<template>
  <div class="flex flex-col sm:flex-row gap-5 rounded-3xl border border-avocado-100/35 bg-white p-6 shadow-sm hover-lift transition">
    <div class="grid h-12 w-12 shrink-0 place-items-center rounded-2xl bg-cream-400 font-black text-avocado-950 text-lg shadow-sm">{{ String(step.id).padStart(2, '0') }}</div>
    <div>
      <h3 class="font-bold text-lg text-avocado-950">{{ step.title }}</h3>
      <p class="mt-2 text-sm leading-relaxed text-slate-500">{{ step.description }}</p>
    </div>
  </div>
</template>

