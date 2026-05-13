<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
import CostCard from '../../components/public/CostCard.vue'
import { costItems } from '../../data/mockData'
</script>

<template>
  <section class="px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      eyebrow="Estimated Cost"
      title="Chi phi dau tu tham khao"
      description="Cac muc chi phi la du lieu mau cho giao dien, giup nguoi xem hinh dung quy mo dau tu ban dau."
    />
    <div class="mx-auto grid max-w-6xl gap-6 md:grid-cols-3">
      <CostCard v-for="item in costItems" :key="item.id" :item="item" />
    </div>
  </section>
</template>
