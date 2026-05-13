<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
</script>

<template>
  <section class="px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      eyebrow="Co hoi hop tac"
      title="Nhuong quyen ALOO cho nha dau tu dia phuong"
      description="Trang gioi thieu mo hinh thuong hieu, cac goi dau tu va ly do ALOO phu hop voi thi truong kem bo Viet Nam."
    />
    <div class="mx-auto grid max-w-6xl gap-6 lg:grid-cols-2">
      <div class="rounded-lg bg-avocado-700 p-8 text-white">
        <h3 class="text-2xl font-black">Gia tri nhan duoc</h3>
        <ul class="mt-5 space-y-3 leading-7 text-avocado-50">
          <li>Cong thuc va dinh luong mon chu luc.</li>
          <li>Bo nhan dien cua hang, menu va vat pham ban hang.</li>
          <li>Dao tao van hanh, pha che, quan ly nguyen lieu.</li>
          <li>Ho tro khai truong va theo doi sau mo ban.</li>
        </ul>
      </div>
      <div class="rounded-lg border border-avocado-100 bg-white p-8 shadow-sm">
        <h3 class="text-2xl font-black text-avocado-950">Doi tac phu hop</h3>
        <p class="mt-5 leading-8 text-slate-600">
          ALOO phu hop voi nguoi co mat bang nho, nha dau tu lan dau mo cua hang F&B, hoac chu kinh doanh muon them mot san pham co tinh mua lap lai cao.
        </p>
      </div>
    </div>
  </section>
</template>
