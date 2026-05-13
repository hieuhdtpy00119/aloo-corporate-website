<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
import ProductCard from '../../components/public/ProductCard.vue'
import { products } from '../../data/mockData'
</script>

<template>
  <section class="px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      eyebrow="Menu ALOO"
      title="Danh muc san pham mau"
      description="Cac san pham duoc thiet ke de trinh bay ro loi ich, gia ban va nhom mon trong demo frontend."
    />
    <div class="mx-auto grid max-w-7xl gap-6 md:grid-cols-2 lg:grid-cols-4">
      <ProductCard v-for="product in products" :key="product.id" :product="product" />
    </div>
  </section>
</template>
