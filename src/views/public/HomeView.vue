<script setup>
import HeroBanner from '../../components/public/HeroBanner.vue'
import SectionTitle from '../../components/public/SectionTitle.vue'
import ProductCard from '../../components/public/ProductCard.vue'
import FranchiseStep from '../../components/public/FranchiseStep.vue'
import { banners, products, franchiseSteps } from '../../data/mockData'
</script>

<template>
  <HeroBanner :banner="banners[0]" />

  <section class="px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      eyebrow="San pham chu luc"
      title="Kem bo thuan Viet, de nho va de ban"
      description="Menu tap trung vao cac mon co kha nang ban lap lai cao, phu hop ca khach mua le va diem ban nhuong quyen."
    />
    <div class="mx-auto grid max-w-7xl gap-6 md:grid-cols-2 lg:grid-cols-4">
      <ProductCard v-for="product in products" :key="product.id" :product="product" />
    </div>
  </section>

  <section class="bg-avocado-50 px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      eyebrow="Nhuong quyen"
      title="Lo trinh mo cua hang ro rang"
      description="ALOO uu tien quy trinh de trien khai, quan ly chi phi va tao trai nghiem dong nhat giua cac diem ban."
    />
    <div class="mx-auto grid max-w-5xl gap-5 md:grid-cols-2">
      <FranchiseStep v-for="step in franchiseSteps.slice(0, 4)" :key="step.id" :step="step" />
    </div>
  </section>
</template>
