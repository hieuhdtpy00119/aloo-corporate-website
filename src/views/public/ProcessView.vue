<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import SectionTitle from '../../components/public/SectionTitle.vue'
import FranchiseStep from '../../components/public/FranchiseStep.vue'

const { t, tm } = useI18n()
const franchiseSteps = computed(() => tm('franchise.steps'))
</script>

<template>
  <section class="bg-avocado-50 px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      :eyebrow="t('process.eyebrow')"
      :title="t('process.title')"
      :description="t('process.description')"
    />
    <div class="mx-auto grid max-w-4xl gap-5">
      <FranchiseStep v-for="step in franchiseSteps" :key="step.id" :step="step" />
    </div>
  </section>
</template>
