<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
</script>

<template>
  <section class="px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      eyebrow="Lien he"
      title="Ket noi voi ALOO"
      description="Thong tin lien he mau cho website thuong hieu va nhuong quyen."
    />
    <div class="mx-auto grid max-w-5xl gap-6 md:grid-cols-3">
      <div class="rounded-lg border border-avocado-100 p-6">
        <h3 class="font-black text-avocado-950">Hotline</h3>
        <p class="mt-3 text-slate-600">0900 888 168</p>
      </div>
      <div class="rounded-lg border border-avocado-100 p-6">
        <h3 class="font-black text-avocado-950">Email</h3>
        <p class="mt-3 text-slate-600">franchise@aloo.vn</p>
      </div>
      <div class="rounded-lg border border-avocado-100 p-6">
        <h3 class="font-black text-avocado-950">Dia chi</h3>
        <p class="mt-3 text-slate-600">TP.HCM, Viet Nam</p>
      </div>
    </div>
  </section>
</template>
