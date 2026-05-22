<script setup>
import { onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { useFranchiseContentStore } from '../../stores/franchiseContentStore'
import { Award, ShieldCheck, TrendingUp, Sparkles, ArrowRight } from 'lucide-vue-next'

const { t } = useI18n()
const franchiseStore = useFranchiseContentStore()

onMounted(() => {
  franchiseStore.fetchContent().catch(() => {})
})
</script>

<template>
  <section class="bg-[#faf8f2] text-avocado-950 min-h-screen pb-20">
    <!-- Hero Header -->
    <div class="relative overflow-hidden bg-avocado-950 px-4 py-24 text-white sm:px-6 lg:px-8">
      <div class="absolute inset-0 opacity-20 mix-blend-luminosity">
        <img
          src="https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=1600&q=80"
          alt="ALOO franchise"
          class="h-full w-full object-cover"
        />
      </div>
      <!-- Radial glow -->
      <div class="absolute -right-20 -top-20 w-96 h-96 bg-cream-400/10 rounded-full blur-3xl pointer-events-none"></div>
      
      <div class="relative mx-auto max-w-6xl space-y-4">
        <span class="inline-block text-xs font-bold uppercase tracking-[0.25em] text-cream-300 bg-white/5 border border-white/10 px-3.5 py-1 rounded-full">
          {{ t('franchise.eyebrow') }}
        </span>
        <h1 class="text-4xl sm:text-6xl font-black leading-tight max-w-4xl">{{ t('franchise.title') }}</h1>
        <p class="max-w-2xl text-base sm:text-lg leading-relaxed text-avocado-50/90 mt-4">
          {{ t('franchise.description') }}
        </p>
        <div class="pt-6">
          <RouterLink
            to="/consultation"
            class="inline-flex rounded-full bg-cream-400 px-8 py-4 font-bold text-avocado-950 shadow-lg shadow-cream-400/25 transition hover:bg-cream-300 uppercase tracking-wider text-xs"
          >
            Đăng ký tư vấn ngay
          </RouterLink>
        </div>
      </div>
    </div>

    <!-- Main lists -->
    <div class="px-4 py-16 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-6xl space-y-20">
        <p v-if="franchiseStore.loading" class="rounded-2xl border border-slate-100 bg-white px-5 py-16 text-center text-sm font-bold text-slate-400 max-w-md mx-auto shadow-sm">
          Đang tải nội dung nhượng quyền...
        </p>
        <p v-else-if="franchiseStore.error" class="rounded-2xl bg-red-50 border border-red-200 px-5 py-4 text-center text-sm font-bold text-red-700 max-w-md mx-auto shadow-sm">
          {{ franchiseStore.error }}
        </p>
        
        <div v-else class="space-y-20">
          <!-- Benefits Section -->
          <section v-if="franchiseStore.visibleBenefits.length">
            <div class="mb-10 text-center sm:text-left">
              <span class="text-xs font-bold uppercase tracking-[0.2em] text-avocado-600">Quyền lợi</span>
              <h2 class="mt-2 text-3xl font-black text-avocado-950">Lợi ích nhượng quyền cùng ALOO</h2>
              <div class="mt-2 h-1 w-12 bg-cream-400 rounded-full mx-auto sm:mx-0"></div>
            </div>
            <div class="grid gap-6 md:grid-cols-3">
              <article
                v-for="(item, idx) in franchiseStore.visibleBenefits"
                :key="item.id"
                class="rounded-3xl border border-avocado-100/35 bg-white p-8 shadow-sm hover-lift flex flex-col justify-between"
              >
                <div>
                  <div class="mb-6 grid h-12 w-12 place-items-center rounded-2xl bg-avocado-50 text-avocado-700 text-lg font-black shadow-inner">
                    <Award v-if="idx === 0" class="h-5 w-5" />
                    <TrendingUp v-else-if="idx === 1" class="h-5 w-5" />
                    <ShieldCheck v-else class="h-5 w-5" />
                  </div>
                  <h3 class="text-xl font-bold text-avocado-950">{{ item.title }}</h3>
                  <p class="mt-3 text-sm leading-relaxed text-slate-500">{{ item.description }}</p>
                </div>
              </article>
            </div>
          </section>

          <!-- Conditions Section -->
          <section v-if="franchiseStore.visibleConditions.length">
            <div class="mb-10 text-center sm:text-left">
              <span class="text-xs font-bold uppercase tracking-[0.2em] text-avocado-600">Tiêu chuẩn</span>
              <h2 class="mt-2 text-3xl font-black text-avocado-950">Điều kiện hợp tác</h2>
              <div class="mt-2 h-1 w-12 bg-cream-400 rounded-full mx-auto sm:mx-0"></div>
            </div>
            <div class="grid gap-6 lg:grid-cols-3">
              <article
                v-for="item in franchiseStore.visibleConditions"
                :key="item.id"
                class="rounded-3xl border border-avocado-100/35 bg-white p-8 shadow-sm hover-lift transition"
              >
                <h3 class="text-lg font-bold text-avocado-950 flex items-center gap-2">
                  <span class="h-2 w-2 rounded-full bg-cream-400"></span>
                  {{ item.title }}
                </h3>
                <p class="mt-4 text-sm leading-relaxed text-slate-500">{{ item.description }}</p>
              </article>
            </div>
          </section>

          <!-- Process Section -->
          <section v-if="franchiseStore.visibleProcess.length">
            <div class="mb-10 text-center sm:text-left">
              <span class="text-xs font-bold uppercase tracking-[0.2em] text-avocado-600">Lộ trình</span>
              <h2 class="mt-2 text-3xl font-black text-avocado-950">Quy trình mở cửa hàng</h2>
              <div class="mt-2 h-1 w-12 bg-cream-400 rounded-full mx-auto sm:mx-0"></div>
            </div>
            <div class="relative grid gap-5">
              <article
                v-for="(item, index) in franchiseStore.visibleProcess"
                :key="item.id"
                class="grid gap-6 rounded-3xl border border-avocado-100/35 bg-white p-6 shadow-sm hover-lift md:grid-cols-[80px_1fr] items-center"
              >
                <div class="grid h-16 w-16 place-items-center rounded-2xl bg-cream-400 text-2xl font-black text-avocado-950 shadow-sm mx-auto md:mx-0">
                  {{ String(index + 1).padStart(2, '0') }}
                </div>
                <div class="text-center md:text-left">
                  <h3 class="text-lg font-bold text-avocado-950">{{ item.title }}</h3>
                  <p class="mt-2 text-sm leading-relaxed text-slate-500">{{ item.description }}</p>
                </div>
              </article>
            </div>
          </section>

          <!-- Costs Section -->
          <section v-if="franchiseStore.visibleCosts.length">
            <div class="mb-10 text-center sm:text-left">
              <span class="text-xs font-bold uppercase tracking-[0.2em] text-avocado-600">Ngân sách</span>
              <h2 class="mt-2 text-3xl font-black text-avocado-950">Chi phí đầu tư dự kiến</h2>
              <div class="mt-2 h-1 w-12 bg-cream-400 rounded-full mx-auto sm:mx-0"></div>
            </div>
            <div class="grid gap-6 lg:grid-cols-3">
              <article
                v-for="item in franchiseStore.visibleCosts"
                :key="item.id"
                class="rounded-3xl border border-avocado-100/35 bg-white p-8 shadow-sm hover-lift flex flex-col justify-between"
              >
                <div>
                  <h3 class="text-xl font-bold text-avocado-950">{{ item.title }}</h3>
                  <p class="mt-4 text-3xl font-black text-avocado-800 tracking-tight">{{ item.amount }}</p>
                  <div class="mt-4 h-px bg-slate-100 w-full"></div>
                  <p class="mt-4 text-sm leading-relaxed text-slate-500">{{ item.note }}</p>
                </div>
              </article>
            </div>
          </section>

          <!-- Premium CTA Banner -->
          <section class="overflow-hidden rounded-[2.5rem] bg-gradient-to-br from-avocado-950 via-avocado-900 to-[#122310] p-8 text-white shadow-2xl lg:p-12 relative">
            <div class="absolute -right-20 -top-20 w-80 h-80 bg-cream-400/5 rounded-full blur-3xl pointer-events-none"></div>
            <div class="grid gap-6 lg:grid-cols-[1fr_auto] lg:items-center relative z-10">
              <div class="space-y-3">
                <span class="inline-flex items-center gap-1.5 text-xs font-bold uppercase tracking-[0.2em] text-cream-300">
                  <Sparkles class="h-3.5 w-3.5 fill-cream-300" />
                  Đồng hành bền vững
                </span>
                <h2 class="text-3xl font-black">Sẵn sàng khởi nghiệp kinh doanh cùng ALOO?</h2>
                <p class="max-w-2xl text-sm leading-relaxed text-avocado-100/90">
                  Gửi thông tin đăng ký tư vấn để đội ngũ ALOO liên hệ giới thiệu chi tiết về sản phẩm, cơ hội khu vực và dự toán đầu tư tối ưu nhất.
                </p>
              </div>
              <RouterLink
                to="/consultation"
                class="rounded-full bg-cream-400 px-8 py-4 text-center font-bold text-avocado-950 hover:bg-cream-300 transition duration-300 shadow-lg shadow-cream-400/20 text-xs uppercase tracking-wider"
              >
                Đăng ký tư vấn miễn phí
              </RouterLink>
            </div>
          </section>
        </div>
      </div>
    </div>
  </section>
</template>

