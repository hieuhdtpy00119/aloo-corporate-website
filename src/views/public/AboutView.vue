<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
</script>

<template>
  <section class="bg-avocado-50 px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      eyebrow="Ve chung toi"
      title="ALOO xay dung tu huong vi quen thuoc cua nguoi Viet"
      description="Thuong hieu tap trung vao kem bo, nguyen lieu de tiep can va quy trinh van hanh gon de phu hop voi thi truong dia phuong."
    />
    <div class="mx-auto grid max-w-6xl gap-6 md:grid-cols-3">
      <div class="rounded-lg bg-white p-6 shadow-sm">
        <h3 class="font-black text-avocado-950">San pham tap trung</h3>
        <p class="mt-3 leading-7 text-slate-600">Menu khong dan trai, de dao tao va giu chat luong on dinh.</p>
      </div>
      <div class="rounded-lg bg-white p-6 shadow-sm">
        <h3 class="font-black text-avocado-950">Nhan dien sach</h3>
        <p class="mt-3 leading-7 text-slate-600">Mau xanh bo, vang kem va trang tao cam giac tuoi, mem va hien dai.</p>
      </div>
      <div class="rounded-lg bg-white p-6 shadow-sm">
        <h3 class="font-black text-avocado-950">Mo hinh linh hoat</h3>
        <p class="mt-3 leading-7 text-slate-600">Phu hop kiosk, cua hang nho va mo hinh flagship mini.</p>
      </div>
    </div>
  </section>
</template>
