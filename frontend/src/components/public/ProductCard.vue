<script setup>
defineProps({
  product: {
    type: Object,
    required: true,
  },
})
</script>

<template>
  <article class="rounded-lg border border-avocado-100 bg-white p-5 shadow-sm transition hover:-translate-y-1 hover:shadow-lg">
    <div class="mb-4 grid h-16 w-16 place-items-center rounded-full bg-cream-200 text-base font-black text-avocado-800">ALOO</div>
    <div class="mb-2.5 flex items-center justify-between gap-3">
      <span class="rounded-full bg-avocado-50 px-2.5 py-1 text-[11px] font-bold text-avocado-700">{{ product.category }}</span>
      <span class="text-sm font-black text-avocado-800">{{ product.price }}</span>
    </div>
    <h3 class="text-lg font-black text-avocado-950">{{ product.name }}</h3>
    <p class="mt-2 text-sm leading-6 text-slate-600">{{ product.description }}</p>
  </article>
</template>
