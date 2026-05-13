<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
</script>

<template>
  <section class="px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      :eyebrow="t('contact.eyebrow')"
      :title="t('contact.title')"
      :description="t('contact.description')"
    />
    <div class="mx-auto grid max-w-5xl gap-6 md:grid-cols-3">
      <div class="rounded-lg border border-avocado-100 p-6">
        <h3 class="font-black text-avocado-950">{{ t('footer.hotline') }}</h3>
        <p class="mt-3 text-slate-600">0900 888 168</p>
      </div>
      <div class="rounded-lg border border-avocado-100 p-6">
        <h3 class="font-black text-avocado-950">{{ t('footer.email') }}</h3>
        <p class="mt-3 text-slate-600">franchise@aloo.vn</p>
      </div>
      <div class="rounded-lg border border-avocado-100 p-6">
        <h3 class="font-black text-avocado-950">{{ t('footer.address') }}</h3>
        <p class="mt-3 text-slate-600">{{ t('footer.addressValue') }}</p>
      </div>
    </div>
  </section>
</template>
