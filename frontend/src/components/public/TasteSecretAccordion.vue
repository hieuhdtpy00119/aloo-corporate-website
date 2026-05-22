<script setup>
import { ref } from 'vue'

const activeIndex = ref(0)

const items = [
  {
    title: 'Vị ngon bắt đầu từ bơ sáp',
    points: ['Chọn bơ chín tự nhiên', 'Bơ có độ béo, mịn và màu đẹp', 'Phù hợp với món kem bơ đặc trưng'],
  },
  {
    title: 'Kết cấu kem mịn và mát',
    points: ['Kem được phối vị vừa miệng', 'Không quá ngọt', 'Giữ cảm giác nhẹ và dễ ăn'],
  },
  {
    title: 'Topping tạo trải nghiệm',
    points: ['Dừa sấy giòn', 'Cacao thơm', 'Sầu riêng đậm vị', 'Tăng texture khi thưởng thức'],
  },
  {
    title: 'Không gian và trải nghiệm thương hiệu',
    points: ['Phù hợp check-in', 'Thân thiện với giới trẻ', 'Gợi cảm giác tươi mới, sạch và hiện đại'],
  },
]

const images = [
  'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=700&q=85',
  'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?auto=format&fit=crop&w=700&q=85',
]
</script>

<template>
  <section class="bg-[#fffaf0] px-4 py-16 sm:px-5 lg:px-6">
    <div class="mx-auto max-w-6xl">
      <div class="mb-9 text-center">
        <p class="text-xs font-black uppercase tracking-[0.2em] text-avocado-600">Secret to Great Taste</p>
        <h2 class="mt-2 text-3xl font-black tracking-tight text-avocado-950 md:text-5xl">Bí quyết tạo nên vị ngon ALOO</h2>
      </div>

      <div class="grid gap-8 lg:grid-cols-[0.95fr_1.05fr]">
        <div class="space-y-3">
          <button
            v-for="(item, index) in items"
            :key="item.title"
            class="w-full rounded-2xl border bg-white p-5 text-left transition"
            :class="activeIndex === index ? 'border-avocado-300 shadow-xl shadow-avocado-900/8' : 'border-avocado-100 hover:border-avocado-200'"
            @click="activeIndex = index"
          >
            <div class="flex items-center justify-between gap-4">
              <h3 class="text-lg font-black text-avocado-950">{{ item.title }}</h3>
              <span class="text-2xl font-black text-avocado-600">{{ activeIndex === index ? '−' : '+' }}</span>
            </div>
            <div v-if="activeIndex === index" class="mt-5 grid gap-2">
              <p v-for="point in item.points" :key="point" class="rounded-xl bg-avocado-50 px-3.5 py-2.5 text-sm font-semibold text-avocado-900">
                {{ point }}
              </p>
            </div>
          </button>
        </div>

        <div class="relative min-h-[520px]">
          <img :src="images[0]" alt="Bơ sáp ALOO" class="absolute left-0 top-0 h-[300px] w-[56%] rounded-[1.5rem] object-cover shadow-2xl shadow-avocado-900/15" />
          <img :src="images[1]" alt="Kem bơ ALOO" class="absolute right-0 top-20 h-[350px] w-[56%] rounded-[1.5rem] object-cover shadow-2xl shadow-avocado-900/15" />
          <img :src="images[2]" alt="Topping ALOO" class="absolute bottom-0 left-[15%] h-[220px] w-[50%] rounded-[1.5rem] object-cover shadow-2xl shadow-avocado-900/15" />
        </div>
      </div>
    </div>
  </section>
</template>
