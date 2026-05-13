<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
import { useI18n } from 'vue-i18n'

const { t, tm } = useI18n()
</script>

<template>
  <section class="bg-avocado-50 px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      :eyebrow="t('about.eyebrow')"
      :title="t('about.title')"
      :description="t('about.description')"
    />
    <div class="mx-auto grid max-w-6xl gap-6 md:grid-cols-3">
      <div v-for="card in tm('about.cards')" :key="card.title" class="rounded-lg bg-white p-6 shadow-sm">
        <h3 class="font-black text-avocado-950">{{ card.title }}</h3>
        <p class="mt-3 leading-7 text-slate-600">{{ card.description }}</p>
      </div>
    </div>
  </section>
</template>
