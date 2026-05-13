<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
import FranchiseStep from '../../components/public/FranchiseStep.vue'
import { franchiseSteps } from '../../data/mockData'
</script>

<template>
  <section class="bg-avocado-50 px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      eyebrow="Opening Process"
      title="Quy trinh mo cua hang"
      description="Tu tu van ban dau den khai truong, moi buoc deu co dau viec ro rang de nha dau tu de theo doi."
    />
    <div class="mx-auto grid max-w-4xl gap-5">
      <FranchiseStep v-for="step in franchiseSteps" :key="step.id" :step="step" />
    </div>
  </section>
</template>
