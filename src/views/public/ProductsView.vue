<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import SectionTitle from '../../components/public/SectionTitle.vue'
import ProductCard from '../../components/public/ProductCard.vue'
import { useAppStore } from '../../stores/appStore'

const { t } = useI18n()
const store = useAppStore()
const products = computed(() => store.products.filter((product) => product.status === 'Đang bán'))
</script>

<template>
  <section class="px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      :eyebrow="t('products.eyebrow')"
      :title="t('products.title')"
      :description="t('products.description')"
    />
    <div class="mx-auto grid max-w-7xl gap-6 md:grid-cols-2 lg:grid-cols-4">
      <ProductCard v-for="product in products" :key="product.id" :product="product" />
    </div>
  </section>
</template>
