<script setup>
import { computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import SectionTitle from '../../components/public/SectionTitle.vue'
import CostCard from '../../components/public/CostCard.vue'
import { useFranchiseContentStore } from '../../stores/franchiseContentStore'

const { t } = useI18n()
const franchiseContentStore = useFranchiseContentStore()
const costItems = computed(() => franchiseContentStore.visibleCosts)

onMounted(() => {
  franchiseContentStore.fetchContent().catch(() => {})
})
</script>

<template>
  <main class="bg-[#faf8f2] text-avocado-950 pb-20 min-h-screen">
    <!-- Header Hero block -->
    <div class="relative bg-avocado-950 text-white overflow-hidden py-20 px-4 sm:px-6 lg:px-8 text-center">
      <div class="absolute inset-0 opacity-15">
        <img
          src="https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1600&q=80"
          alt="ALOO franchise cost"
          class="h-full w-full object-cover"
        />
      </div>
      <div class="absolute inset-0 bg-gradient-to-b from-transparent to-avocado-950/90"></div>
      <div class="relative max-w-3xl mx-auto space-y-4">
        <span class="inline-block text-xs font-bold uppercase tracking-[0.25em] text-cream-300 bg-white/5 border border-white/10 px-3.5 py-1 rounded-full">
          Báo giá đầu tư
        </span>
        <h1 class="text-4xl sm:text-5xl font-black tracking-tight text-white mt-3">Dự toán chi phí</h1>
        <p class="text-base sm:text-lg leading-relaxed text-avocado-100 max-w-2xl mx-auto mt-4">
          Chi tiết các khoản đầu tư ban đầu giúp bạn chuẩn bị tốt nhất về mặt tài chính.
        </p>
      </div>
    </div>

    <!-- Main Content -->
    <section class="max-w-6xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
      <SectionTitle
        :eyebrow="t('cost.eyebrow')"
        :title="t('cost.title')"
        :description="t('cost.description')"
      />
      <p v-if="franchiseContentStore.error" class="rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-center text-sm font-bold text-red-700">
        {{ franchiseContentStore.error }}
      </p>
      <div v-else-if="franchiseContentStore.loading" class="mx-auto grid max-w-6xl gap-6 md:grid-cols-3">
        <div v-for="i in 3" :key="i" class="h-56 animate-pulse rounded-3xl bg-white/70" />
      </div>
      <div v-else-if="costItems.length" class="mx-auto grid max-w-6xl gap-6 md:grid-cols-3">
        <CostCard v-for="item in costItems" :key="item.id" :item="item" />
      </div>
      <p v-else class="rounded-2xl border border-slate-200 bg-white px-5 py-12 text-center text-sm font-bold text-slate-500">
        Chưa có dữ liệu. Vui lòng thêm dữ liệu trong trang quản trị.
      </p>

      <!-- Quick Consultation CTA -->
      <div class="mt-16 text-center">
        <RouterLink to="/consultation" class="inline-flex rounded-full bg-avocado-900 text-white font-bold px-8 py-3.5 hover:bg-avocado-800 transition duration-300 shadow-md text-xs uppercase tracking-wider">
          Đăng ký nhận báo giá chi tiết từng tỉnh thành
        </RouterLink>
      </div>
    </section>
  </main>
</template>

