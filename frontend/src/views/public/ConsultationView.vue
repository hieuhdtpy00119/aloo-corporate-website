<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
import ConsultationForm from '../../components/public/ConsultationForm.vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
</script>

<template>
  <div class="bg-brand-cream text-avocado-950 pb-20 min-h-screen">
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
          Hợp tác phát triển
        </span>
        <h1 class="text-4xl sm:text-5xl font-black tracking-tight text-white mt-3">Đăng Ký Tư Vấn</h1>
        <p class="text-base sm:text-lg leading-relaxed text-avocado-100 max-w-2xl mx-auto mt-4">
          Hãy để lại thông tin, đại diện ALOO sẽ trực tiếp liên hệ và hỗ trợ quý đối tác trong vòng 24 giờ làm việc.
        </p>
      </div>
    </div>

    <!-- Main Section -->
    <section class="max-w-4xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
      <SectionTitle
        :eyebrow="t('consultation.eyebrow')"
        :title="t('consultation.title')"
        :description="t('consultation.description')"
      />
      <div class="mx-auto max-w-2xl mt-10">
        <ConsultationForm />
      </div>
    </section>
  </div>
</template>
