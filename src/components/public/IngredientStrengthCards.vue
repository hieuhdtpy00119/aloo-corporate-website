<script setup>
const strengths = [
  {
    title: 'Bơ sáp Tây Nguyên',
    description: 'Bơ chín tự nhiên, béo mịn và thơm nhẹ.',
    image: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=900&q=85',
  },
  {
    title: 'Kem tươi mát lạnh',
    description: 'Kết cấu mịn, vị ngọt vừa và dễ ăn.',
    image: 'https://images.unsplash.com/photo-1488900128323-21503983a07e?auto=format&fit=crop&w=900&q=85',
  },
  {
    title: 'Topping giòn thơm',
    description: 'Dừa sấy, cacao, sầu riêng và nguyên liệu chọn lọc.',
    image: 'https://images.unsplash.com/photo-1587314168485-3236d6710814?auto=format&fit=crop&w=900&q=85',
  },
]
</script>

<template>
  <section id="signature-products" class="bg-[#fff8e3] px-4 py-16 sm:px-5 lg:px-6">
    <div class="mx-auto max-w-6xl">
      <div class="mb-8 text-center">
        <p class="text-xs font-black uppercase tracking-[0.2em] text-avocado-600">ALOO Strength</p>
        <h2 class="mt-2 text-3xl font-black tracking-tight text-avocado-950 md:text-5xl">Vị ngon bắt đầu từ nguyên liệu thật.</h2>
      </div>
      <div class="grid gap-5 lg:grid-cols-3">
        <article v-for="item in strengths" :key="item.title" class="group relative min-h-[340px] overflow-hidden rounded-[1.25rem]">
          <img :src="item.image" :alt="item.title" class="absolute inset-0 h-full w-full object-cover transition duration-700 group-hover:scale-105" />
          <div class="absolute inset-0 bg-gradient-to-t from-black/72 via-black/18 to-transparent"></div>
          <div class="absolute bottom-0 left-0 right-0 p-5 text-white">
            <h3 class="text-2xl font-black leading-tight">{{ item.title }}</h3>
            <p class="mt-2 max-w-sm text-sm leading-6 text-white/82">{{ item.description }}</p>
          </div>
        </article>
      </div>
    </div>
  </section>
</template>
