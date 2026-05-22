<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
import { useI18n } from 'vue-i18n'
import { Heart, Sparkles, Smile, Award } from 'lucide-vue-next'

const { t, tm } = useI18n()
</script>

<template>
  <main class="bg-[#faf8f2] text-avocado-950 pb-20">
    <!-- Header Hero block -->
    <div class="relative bg-avocado-950 text-white overflow-hidden py-24 px-4 sm:px-6 lg:px-8 text-center">
      <div class="absolute inset-0 opacity-15">
        <img
          src="https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2?auto=format&fit=crop&w=1600&q=80"
          alt="ALOO Brand Background"
          class="h-full w-full object-cover"
        />
      </div>
      <div class="absolute inset-0 bg-gradient-to-b from-transparent to-avocado-950/90"></div>
      <div class="relative max-w-3xl mx-auto space-y-4">
        <span class="inline-block text-xs font-bold uppercase tracking-[0.25em] text-cream-300 bg-white/5 border border-white/10 px-3.5 py-1 rounded-full">
          Về chúng tôi
        </span>
        <h1 class="text-4xl sm:text-5xl font-black tracking-tight text-white mt-3">Về ALOO Kem Bơ</h1>
        <p class="text-base sm:text-lg leading-relaxed text-avocado-100 max-w-2xl mx-auto mt-4">
          Thương hiệu kem bơ thuần Việt tập trung vào nguyên liệu tươi, công thức ổn định và trải nghiệm cửa hàng dễ nhân rộng.
        </p>
      </div>
    </div>

    <!-- Main Content -->
    <section class="max-w-6xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
      <SectionTitle
        :eyebrow="t('about.eyebrow')"
        :title="t('about.title')"
        :description="t('about.description')"
      />
      
      <div class="grid gap-8 md:grid-cols-3 mt-12">
        <div 
          v-for="(card, index) in tm('about.cards')" 
          :key="card.title" 
          class="rounded-3xl border border-avocado-100/35 bg-white p-8 shadow-sm hover-lift flex flex-col justify-between"
        >
          <div>
            <div class="grid h-12 w-12 place-items-center rounded-2xl bg-avocado-50 text-avocado-700 shadow-inner mb-6">
              <Heart v-if="index === 0" class="h-6 w-6" />
              <Sparkles v-else-if="index === 1" class="h-6 w-6" />
              <Smile v-else class="h-6 w-6" />
            </div>
            <h3 class="text-xl font-bold text-avocado-950">{{ card.title }}</h3>
            <p class="mt-4 text-sm leading-relaxed text-slate-500">{{ card.description }}</p>
          </div>
        </div>
      </div>

      <!-- Asymmetrical highlight segment -->
      <div class="mt-20 overflow-hidden rounded-[2.5rem] bg-gradient-to-r from-avocado-900 to-avocado-950 p-8 sm:p-12 text-white relative shadow-xl">
        <div class="absolute -right-20 -top-20 w-80 h-80 bg-cream-400/5 rounded-full blur-3xl pointer-events-none"></div>
        <div class="grid gap-10 md:grid-cols-[1fr_auto] md:items-center">
          <div class="space-y-4">
            <span class="text-xs font-bold uppercase tracking-[0.2em] text-cream-300">Tầm nhìn</span>
            <h2 class="text-2xl sm:text-3xl font-black">Xây dựng chuỗi kem bơ bền vững hàng đầu Việt Nam</h2>
            <p class="text-sm leading-relaxed text-avocado-100/90 max-w-3xl">
              ALOO hướng tới việc đồng hành cùng người nông dân vùng cao Đắk Lắk, chuẩn hóa quy trình chuỗi cung ứng khép kín và mang đến cho thực khách những sản phẩm từ bơ tươi ngon, bổ dưỡng nhất dưới một nhận diện trẻ trung, hiện đại.
            </p>
          </div>
          <RouterLink to="/franchise" class="rounded-full bg-cream-400 text-avocado-950 font-bold px-6 py-3.5 hover:bg-cream-300 transition duration-300 text-center shadow-lg shadow-cream-400/20 text-xs uppercase tracking-wider">
            Xem cơ hội nhượng quyền
          </RouterLink>
        </div>
      </div>
    </section>
  </main>
</template>
