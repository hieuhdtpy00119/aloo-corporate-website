<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import SectionTitle from '../../components/public/SectionTitle.vue'
import FranchiseStep from '../../components/public/FranchiseStep.vue'

const { t, tm } = useI18n()
const franchiseSteps = computed(() => tm('franchise.steps'))
</script>

<template>
  <main class="bg-[#faf8f2] text-avocado-950 pb-20 min-h-screen">
    <!-- Header Hero block -->
    <div class="relative bg-avocado-950 text-white overflow-hidden py-20 px-4 sm:px-6 lg:px-8 text-center">
      <div class="absolute inset-0 opacity-15">
        <img
          src="https://images.unsplash.com/photo-1578345218746-50a229b3d0f8?auto=format&fit=crop&w=1600&q=80"
          alt="ALOO franchise process"
          class="h-full w-full object-cover"
        />
      </div>
      <div class="absolute inset-0 bg-gradient-to-b from-transparent to-avocado-950/90"></div>
      <div class="relative max-w-3xl mx-auto space-y-4">
        <span class="inline-block text-xs font-bold uppercase tracking-[0.25em] text-cream-300 bg-white/5 border border-white/10 px-3.5 py-1 rounded-full">
          Hợp tác mở quán
        </span>
        <h1 class="text-4xl sm:text-5xl font-black tracking-tight text-white mt-3">Quy trình vận hành</h1>
        <p class="text-base sm:text-lg leading-relaxed text-avocado-100 max-w-2xl mx-auto mt-4">
          Quy trình 6 bước rõ ràng từ lúc ký kết hợp đồng đến ngày khai trương hồng phát.
        </p>
      </div>
    </div>

    <!-- Main Content -->
    <section class="max-w-4xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
      <SectionTitle
        :eyebrow="t('process.eyebrow')"
        :title="t('process.title')"
        :description="t('process.description')"
      />
      <div class="mx-auto grid gap-6 mt-10">
        <FranchiseStep v-for="step in franchiseSteps" :key="step.id" :step="step" />
      </div>

      <!-- Quick Consultation CTA -->
      <div class="mt-16 text-center">
        <RouterLink to="/consultation" class="inline-flex rounded-full bg-avocado-900 text-white font-bold px-8 py-3.5 hover:bg-avocado-800 transition duration-300 shadow-md text-xs uppercase tracking-wider">
          Xem lịch sử các cửa hàng đã mở
        </RouterLink>
      </div>
    </section>
  </main>
</template>

