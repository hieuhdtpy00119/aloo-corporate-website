<script setup>
defineProps({
  step: {
    type: Object,
    required: true,
  },
})
</script>

<template>
  <div class="flex gap-4 rounded-lg border border-avocado-100 bg-white p-5 shadow-sm">
    <div class="grid h-11 w-11 shrink-0 place-items-center rounded-full bg-avocado-700 font-black text-white">{{ step.id }}</div>
    <div>
      <h3 class="font-black text-avocado-950">{{ step.title }}</h3>
      <p class="mt-2 leading-7 text-slate-600">{{ step.description }}</p>
    </div>
  </div>
</template>
