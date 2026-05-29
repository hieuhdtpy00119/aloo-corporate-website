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
  <section class="bg-brand-cream/20 text-brand-dark min-h-screen pb-20">
    <!-- Hero Header -->
    <div class="relative overflow-hidden bg-brand-dark px-4 py-24 text-white sm:px-6 lg:px-8">
      <div class="absolute inset-0 opacity-20 mix-blend-luminosity">
        <img
          src="https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=1600&q=80"
          alt="ALOO franchise"
          class="h-full w-full object-cover"
        />
      </div>
      <!-- Radial glow -->
      <div class="absolute -right-20 -top-20 w-96 h-96 bg-brand-lime/10 rounded-full blur-3xl pointer-events-none"></div>
      
      <div class="relative mx-auto max-w-[1280px] space-y-4">
        <span class="inline-block text-xs font-black uppercase tracking-[0.25em] text-brand-lime bg-white/5 border border-white/10 px-3.5 py-1.5 rounded-full">
          {{ t('franchise.eyebrow') }}
        </span>
        <h1 class="text-4xl sm:text-6xl font-black leading-tight max-w-4xl font-display">{{ t('franchise.title') }}</h1>
        <p class="max-w-2xl text-base sm:text-lg leading-relaxed text-brand-cream/90 mt-4">
          {{ t('franchise.description') }}
        </p>
        <div class="pt-6">
          <RouterLink
            to="/consultation"
            class="inline-flex rounded-full bg-brand-lime px-8 py-4 font-black text-brand-dark shadow-lg shadow-brand-lime/25 transition hover:bg-brand-lime/90 uppercase tracking-wider text-xs"
          >
            Đăng ký tư vấn ngay
          </RouterLink>
        </div>
      </div>
    </div>

    <!-- Main lists -->
    <div class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-[1280px] space-y-24">
        <p v-if="franchiseStore.loading" class="rounded-2xl border border-slate-100 bg-white px-5 py-16 text-center text-sm font-bold text-slate-400 max-w-md mx-auto shadow-sm">
          Đang tải nội dung nhượng quyền...
        </p>
        <p v-else-if="franchiseStore.error" class="rounded-2xl bg-red-50 border border-red-200 px-5 py-4 text-center text-sm font-bold text-red-700 max-w-md mx-auto shadow-sm">
          {{ franchiseStore.error }}
        </p>
        
        <div v-else class="space-y-24">
          <!-- Benefits Section -->
          <section v-if="franchiseStore.visibleBenefits.length" class="space-y-12">
            <div class="text-center sm:text-left border-b border-brand-forest/5 pb-4">
              <span class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">Quyền lợi</span>
              <h2 class="mt-2 text-3xl font-black text-brand-dark lg:text-4xl font-display">Lợi ích nhượng quyền cùng ALOO</h2>
            </div>
            <div class="grid gap-6 md:grid-cols-3">
              <article
                v-for="(item, idx) in franchiseStore.visibleBenefits"
                :key="item.id"
                class="rounded-3xl border border-brand-forest/5 bg-white p-8 shadow-sm hover-lift flex flex-col justify-between"
              >
                <div>
                  <div class="mb-6 grid h-12 w-12 place-items-center rounded-2xl bg-brand-lime/10 text-brand-forest text-lg font-black shadow-inner">
                    <Award v-if="idx === 0" class="h-5 w-5" />
                    <TrendingUp v-else-if="idx === 1" class="h-5 w-5" />
                    <ShieldCheck v-else class="h-5 w-5" />
                  </div>
                  <h3 class="text-xl font-bold text-brand-dark font-display">{{ item.title }}</h3>
                  <p class="mt-3 text-sm leading-relaxed text-brand-muted font-medium">{{ item.description }}</p>
                </div>
              </article>
            </div>
          </section>

          <!-- Conditions Section -->
          <section v-if="franchiseStore.visibleConditions.length" class="space-y-12">
            <div class="text-center sm:text-left border-b border-brand-forest/5 pb-4">
              <span class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">Tiêu chuẩn</span>
              <h2 class="mt-2 text-3xl font-black text-brand-dark lg:text-4xl font-display">Điều kiện hợp tác</h2>
            </div>
            <div class="grid gap-6 lg:grid-cols-3">
              <article
                v-for="item in franchiseStore.visibleConditions"
                :key="item.id"
                class="rounded-3xl border border-brand-forest/5 bg-white p-8 shadow-sm hover-lift transition"
              >
                <h3 class="text-lg font-bold text-brand-dark flex items-center gap-2 font-display">
                  <span class="h-2.5 w-2.5 rounded-full bg-brand-sand"></span>
                  {{ item.title }}
                </h3>
                <p class="mt-4 text-sm leading-relaxed text-brand-muted font-medium">{{ item.description }}</p>
              </article>
            </div>
          </section>

          <!-- Process Section -->
          <section v-if="franchiseStore.visibleProcess.length" class="space-y-12">
            <div class="text-center sm:text-left border-b border-brand-forest/5 pb-4">
              <span class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">Lộ trình</span>
              <h2 class="mt-2 text-3xl font-black text-brand-dark lg:text-4xl font-display">Quy trình mở cửa hàng</h2>
            </div>
            <!-- Vertical Timeline flow -->
            <div class="relative border-l border-brand-lime/30 ml-4 md:ml-8 pl-8 space-y-8 py-2">
              <article
                v-for="(item, index) in franchiseStore.visibleProcess"
                :key="item.id"
                class="relative rounded-3xl border border-brand-forest/5 bg-white p-6 shadow-sm hover-lift flex flex-col sm:flex-row gap-5 items-start sm:items-center"
              >
                <!-- Dot marker -->
                <div class="absolute -left-[45px] top-6 grid h-8 w-8 place-items-center rounded-full bg-brand-forest text-white text-xs font-black ring-4 ring-white shadow-md">
                  {{ index + 1 }}
                </div>
                <div class="grid h-12 w-12 shrink-0 place-items-center rounded-xl bg-brand-lime/10 text-brand-forest font-black">
                  <Sparkles class="h-5 w-5" />
                </div>
                <div class="min-w-0">
                  <h3 class="text-lg font-bold text-brand-dark font-display">{{ item.title }}</h3>
                  <p class="mt-2 text-sm leading-relaxed text-brand-muted font-medium">{{ item.description }}</p>
                </div>
              </article>
            </div>
          </section>

          <!-- Costs Section -->
          <section v-if="franchiseStore.visibleCosts.length" class="space-y-12">
            <div class="text-center sm:text-left border-b border-brand-forest/5 pb-4">
              <span class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">Ngân sách</span>
              <h2 class="mt-2 text-3xl font-black text-brand-dark lg:text-4xl font-display">Chi phí đầu tư dự kiến</h2>
            </div>
            <div class="grid gap-6 lg:grid-cols-3">
              <article
                v-for="item in franchiseStore.visibleCosts"
                :key="item.id"
                class="rounded-3xl border border-brand-forest/5 bg-white p-8 shadow-sm hover-lift flex flex-col justify-between"
              >
                <div>
                  <h3 class="text-xl font-bold text-brand-dark font-display">{{ item.title }}</h3>
                  <p class="mt-4 text-3xl font-black text-brand-forest tracking-tight font-display">{{ item.amount }}</p>
                  <div class="mt-4 h-px bg-slate-100 w-full"></div>
                  <p class="mt-4 text-sm leading-relaxed text-brand-muted font-medium">{{ item.note }}</p>
                </div>
              </article>
            </div>
          </section>

          <!-- Premium CTA Banner -->
          <section class="overflow-hidden rounded-[2.5rem] bg-gradient-to-br from-brand-dark via-brand-dark/95 to-brand-forest p-8 text-white shadow-2xl lg:p-14 relative border border-white/5">
            <div class="absolute -right-20 -top-20 w-80 h-80 bg-brand-lime/10 rounded-full blur-3xl pointer-events-none"></div>
            <div class="grid gap-6 lg:grid-cols-[1fr_auto] lg:items-center relative z-10">
              <div class="space-y-3">
                <span class="inline-flex items-center gap-1.5 text-xs font-black uppercase tracking-[0.2em] text-brand-lime bg-white/5 border border-white/10 px-3.5 py-1.5 rounded-full">
                  <Sparkles class="h-3.5 w-3.5 fill-brand-lime" />
                  Đồng hành bền vững
                </span>
                <h2 class="text-3xl font-black font-display">Sẵn sàng khởi nghiệp kinh doanh cùng ALOO?</h2>
                <p class="max-w-2xl text-sm leading-relaxed text-brand-cream/90">
                  Gửi thông tin đăng ký tư vấn để đội ngũ ALOO liên hệ giới thiệu chi tiết về sản phẩm, cơ hội khu vực và dự toán đầu tư tối ưu nhất.
                </p>
              </div>
              <RouterLink
                to="/consultation"
                class="rounded-full bg-brand-lime px-8 py-4 text-center font-black text-brand-dark hover:bg-brand-lime/90 transition duration-300 shadow-lg shadow-brand-lime/20 text-xs uppercase tracking-wider"
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
