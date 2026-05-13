<script setup>
defineProps({
  product: {
    type: Object,
    required: true,
  },
})
</script>

<template>
  <article class="rounded-lg border border-avocado-100 bg-white p-6 shadow-sm transition hover:-translate-y-1 hover:shadow-lg">
    <div class="mb-5 grid h-20 w-20 place-items-center rounded-full bg-cream-200 text-xl font-black text-avocado-800">ALOO</div>
    <div class="mb-3 flex items-center justify-between gap-3">
      <span class="rounded-full bg-avocado-50 px-3 py-1 text-xs font-bold text-avocado-700">{{ product.category }}</span>
      <span class="font-black text-avocado-800">{{ product.price }}</span>
    </div>
    <h3 class="text-xl font-black text-avocado-950">{{ product.name }}</h3>
    <p class="mt-3 leading-7 text-slate-600">{{ product.description }}</p>
  </article>
</template>
