<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
import { useI18n } from 'vue-i18n'

const { t, tm } = useI18n()
</script>

<template>
  <section class="px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      :eyebrow="t('franchise.eyebrow')"
      :title="t('franchise.title')"
      :description="t('franchise.description')"
    />
    <div class="mx-auto grid max-w-6xl gap-6 lg:grid-cols-2">
      <div class="rounded-lg bg-avocado-700 p-8 text-white">
        <h3 class="text-2xl font-black">{{ t('franchise.benefitsTitle') }}</h3>
        <ul class="mt-5 space-y-3 leading-7 text-avocado-50">
          <li v-for="benefit in tm('franchise.benefits')" :key="benefit">{{ benefit }}</li>
        </ul>
      </div>
      <div class="rounded-lg border border-avocado-100 bg-white p-8 shadow-sm">
        <h3 class="text-2xl font-black text-avocado-950">{{ t('franchise.partnerTitle') }}</h3>
        <p class="mt-5 leading-8 text-slate-600">
          {{ t('franchise.partnerDescription') }}
        </p>
      </div>
    </div>
  </section>
</template>
