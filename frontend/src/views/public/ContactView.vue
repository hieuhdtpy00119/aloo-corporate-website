<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
import { useI18n } from 'vue-i18n'
import { Phone, Mail, MapPin, Sparkles } from 'lucide-vue-next'

const { t } = useI18n()
</script>

<template>
  <main class="bg-[#faf8f2] text-avocado-950 pb-20 min-h-screen">
    <!-- Header Hero block -->
    <div class="relative bg-avocado-950 text-white overflow-hidden py-20 px-4 sm:px-6 lg:px-8 text-center">
      <div class="absolute inset-0 opacity-15">
        <img
          src="https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1600&q=80"
          alt="ALOO store map"
          class="h-full w-full object-cover"
        />
      </div>
      <div class="absolute inset-0 bg-gradient-to-b from-transparent to-avocado-950/90"></div>
      <div class="relative max-w-3xl mx-auto space-y-4">
        <span class="inline-block text-xs font-bold uppercase tracking-[0.25em] text-cream-300 bg-white/5 border border-white/10 px-3.5 py-1 rounded-full">
          Liên hệ ALOO
        </span>
        <h1 class="text-4xl sm:text-5xl font-black tracking-tight text-white mt-3">Kết Nối Với Chúng Tôi</h1>
        <p class="text-base sm:text-lg leading-relaxed text-avocado-100 max-w-2xl mx-auto mt-4">
          Chúng tôi luôn sẵn sàng lắng nghe mọi ý kiến đóng góp, thắc mắc cũng như yêu cầu hợp tác từ quý khách.
        </p>
      </div>
    </div>

    <!-- Main Section -->
    <section class="max-w-6xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
      <SectionTitle
        :eyebrow="t('contact.eyebrow')"
        :title="t('contact.title')"
        :description="t('contact.description')"
      />
      <div class="mx-auto grid max-w-5xl gap-6 md:grid-cols-3 mt-10">
        <!-- Phone card -->
        <div class="rounded-3xl border border-avocado-100/35 bg-white p-8 shadow-sm hover-lift flex flex-col justify-between">
          <div>
            <div class="grid h-12 w-12 place-items-center rounded-2xl bg-avocado-50 text-avocado-700 shadow-inner mb-6">
              <Phone class="h-5 w-5" />
            </div>
            <h3 class="text-xl font-bold text-avocado-950">{{ t('footer.hotline') }}</h3>
            <p class="mt-4 text-sm text-slate-500 font-semibold leading-relaxed">0900 888 168</p>
          </div>
        </div>

        <!-- Email card -->
        <div class="rounded-3xl border border-avocado-100/35 bg-white p-8 shadow-sm hover-lift flex flex-col justify-between">
          <div>
            <div class="grid h-12 w-12 place-items-center rounded-2xl bg-avocado-50 text-avocado-700 shadow-inner mb-6">
              <Mail class="h-5 w-5" />
            </div>
            <h3 class="text-xl font-bold text-avocado-950">{{ t('footer.email') }}</h3>
            <p class="mt-4 text-sm text-slate-500 font-semibold leading-relaxed">franchise@aloo.vn</p>
          </div>
        </div>

        <!-- Address card -->
        <div class="rounded-3xl border border-avocado-100/35 bg-white p-8 shadow-sm hover-lift flex flex-col justify-between">
          <div>
            <div class="grid h-12 w-12 place-items-center rounded-2xl bg-avocado-50 text-avocado-700 shadow-inner mb-6">
              <MapPin class="h-5 w-5" />
            </div>
            <h3 class="text-xl font-bold text-avocado-950">{{ t('footer.address') }}</h3>
            <p class="mt-4 text-sm text-slate-500 leading-relaxed">{{ t('footer.addressValue') }}</p>
          </div>
        </div>
      </div>

      <!-- Quick Franchise CTA -->
      <div class="mt-20 overflow-hidden rounded-[2.5rem] bg-gradient-to-br from-avocado-950 via-avocado-900 to-[#122310] p-8 sm:p-12 text-white relative shadow-xl">
        <div class="absolute -right-20 -top-20 w-80 h-80 bg-cream-400/5 rounded-full blur-3xl pointer-events-none"></div>
        <div class="grid gap-6 lg:grid-cols-[1fr_auto] lg:items-center relative z-10">
          <div class="space-y-3">
            <span class="inline-flex items-center gap-1.5 text-xs font-bold uppercase tracking-[0.2em] text-cream-300">
              <Sparkles class="h-3.5 w-3.5 fill-cream-300" />
              Đăng ký tư vấn trực tiếp
            </span>
            <h2 class="text-2xl sm:text-3xl font-black">Nhận tư vấn nhượng quyền chi tiết qua Zalo/Điện thoại</h2>
            <p class="max-w-2xl text-sm leading-relaxed text-avocado-100/90">
              Đội ngũ phụ trách dự án F&B của ALOO sẽ gửi thông tin hồ sơ nhượng quyền & khảo sát địa điểm chi tiết cho bạn.
            </p>
          </div>
          <RouterLink
            to="/consultation"
            class="rounded-full bg-cream-400 px-8 py-4 text-center font-bold text-avocado-950 hover:bg-cream-300 transition duration-300 shadow-lg shadow-cream-400/20 text-xs uppercase tracking-wider"
          >
            Đăng ký tư vấn miễn phí
          </RouterLink>
        </div>
      </div>
    </section>
  </main>
</template>

