<script setup>
import { storeToRefs } from 'pinia'
import { useAppStore } from '../../stores/appStore'
import StatCard from '../../components/admin/StatCard.vue'

const store = useAppStore()
const { totalProducts, totalRegistrations, newRegistrations, contactedRegistrations } = storeToRefs(store)
</script>

<template>
  <section>
    <div class="mb-8">
      <h2 class="text-3xl font-black text-avocado-950">Dashboard</h2>
      <p class="mt-2 text-slate-600">Tong quan du lieu mau cua website ALOO.</p>
    </div>
    <div class="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
      <StatCard label="Tong san pham" :value="totalProducts" />
      <StatCard label="Tong dang ky tu van" :value="totalRegistrations" tone="yellow" />
      <StatCard label="Dang ky moi" :value="newRegistrations" />
      <StatCard label="Dang ky da lien he" :value="contactedRegistrations" tone="yellow" />
    </div>
  </section>
</template>
