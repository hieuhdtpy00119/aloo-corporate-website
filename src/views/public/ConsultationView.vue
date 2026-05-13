<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
import ConsultationForm from '../../components/public/ConsultationForm.vue'
</script>

<template>
  <section class="bg-avocado-50 px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      eyebrow="Dang ky tu van"
      title="Gui thong tin mo cua hang ALOO"
      description="Dien thong tin co ban de doi ngu tu van lien he va goi y mo hinh phu hop."
    />
    <div class="mx-auto max-w-4xl">
      <ConsultationForm />
    </div>
  </section>
</template>
