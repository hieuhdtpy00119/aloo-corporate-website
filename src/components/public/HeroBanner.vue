<script setup>
defineProps({
  banner: {
    type: Object,
    required: true,
  },
})
</script>

<template>
  <section class="overflow-hidden bg-gradient-to-br from-avocado-50 via-white to-cream-100">
    <div class="mx-auto grid max-w-7xl items-center gap-10 px-4 py-16 sm:px-6 lg:grid-cols-2 lg:px-8 lg:py-20">
      <div>
        <p class="mb-4 inline-flex rounded-full bg-avocado-100 px-4 py-2 text-sm font-bold text-avocado-800">
          Thuong hieu kem bo Viet Nam
        </p>
        <h1 class="max-w-3xl text-4xl font-black leading-tight text-avocado-950 sm:text-5xl lg:text-6xl">
          {{ banner.title }}
        </h1>
        <p class="mt-5 max-w-2xl text-lg leading-8 text-slate-700">
          {{ banner.subtitle }}
        </p>
        <div class="mt-8 flex flex-col gap-3 sm:flex-row">
          <RouterLink to="/consultation" class="rounded-full bg-avocado-700 px-6 py-3 text-center font-bold text-white shadow-lg shadow-avocado-900/10 hover:bg-avocado-800">
            {{ banner.cta }}
          </RouterLink>
          <RouterLink to="/products" class="rounded-full border border-avocado-200 bg-white px-6 py-3 text-center font-bold text-avocado-800 hover:bg-avocado-50">
            Xem san pham
          </RouterLink>
        </div>
      </div>
      <div class="relative">
        <div class="aspect-[4/3] overflow-hidden rounded-[2rem] bg-avocado-100 shadow-2xl shadow-avocado-900/10">
          <img :src="banner.image" alt="Kem bo ALOO" class="h-full w-full object-cover" />
        </div>
        <div class="absolute -bottom-5 left-6 rounded-2xl bg-white px-5 py-4 shadow-xl">
          <p class="text-sm font-semibold text-slate-500">Mo hinh linh hoat</p>
          <p class="text-2xl font-black text-avocado-800">Kiosk - Store - Mini flagship</p>
        </div>
      </div>
    </div>
  </section>
</template>
