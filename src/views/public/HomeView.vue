<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import HeroBanner from '../../components/public/HeroBanner.vue'
import SectionTitle from '../../components/public/SectionTitle.vue'
import ProductCard from '../../components/public/ProductCard.vue'
import FranchiseStep from '../../components/public/FranchiseStep.vue'
import { useAppStore } from '../../stores/appStore'

const { t, tm } = useI18n()
const store = useAppStore()
const products = computed(() => store.products.filter((product) => product.status === 'Đang bán').slice(0, 4))
const franchiseSteps = computed(() => tm('franchise.steps'))
</script>

<template>
  <HeroBanner />

  <section class="px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      :eyebrow="t('home.productsEyebrow')"
      :title="t('home.productsTitle')"
      :description="t('home.productsDescription')"
    />
    <div class="mx-auto grid max-w-7xl gap-6 md:grid-cols-2 lg:grid-cols-4">
      <ProductCard v-for="product in products" :key="product.id" :product="product" />
    </div>
  </section>

  <section class="bg-avocado-50 px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      :eyebrow="t('home.franchiseEyebrow')"
      :title="t('home.franchiseTitle')"
      :description="t('home.franchiseDescription')"
    />
    <div class="mx-auto grid max-w-5xl gap-5 md:grid-cols-2">
      <FranchiseStep v-for="step in franchiseSteps.slice(0, 4)" :key="step.id" :step="step" />
    </div>
  </section>
</template>
