<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
import ConsultationForm from '../../components/public/ConsultationForm.vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
</script>

<template>
  <section class="bg-avocado-50 px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      :eyebrow="t('consultation.eyebrow')"
      :title="t('consultation.title')"
      :description="t('consultation.description')"
    />
    <div class="mx-auto max-w-4xl">
      <ConsultationForm />
    </div>
  </section>
</template>
