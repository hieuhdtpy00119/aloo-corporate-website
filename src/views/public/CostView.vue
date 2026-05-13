<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import SectionTitle from '../../components/public/SectionTitle.vue'
import CostCard from '../../components/public/CostCard.vue'

const { t, tm } = useI18n()
const costItems = computed(() => tm('cost.items'))
</script>

<template>
  <section class="px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      :eyebrow="t('cost.eyebrow')"
      :title="t('cost.title')"
      :description="t('cost.description')"
    />
    <div class="mx-auto grid max-w-6xl gap-6 md:grid-cols-3">
      <CostCard v-for="item in costItems" :key="item.id" :item="item" />
    </div>
  </section>
</template>
