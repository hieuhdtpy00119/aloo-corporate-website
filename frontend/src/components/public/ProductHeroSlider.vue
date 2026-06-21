<script setup>
import { computed } from 'vue'

const props = defineProps({
  featuredProducts: {
    type: Array,
    default: () => [],
  },
})

const hero = computed(() => {
  const source = props.featuredProducts[0] || {}
  return {
    title: source.title || source.name || 'Sản phẩm ALOO',
    image:
      source.backgroundImage ||
      source.backgroundImageUrl ||
      source.bgImage ||
      source.imageUrl ||
      source.image ||
      '',
  }
})
</script>

<template>
  <section class="relative overflow-hidden bg-brand-dark" aria-label="Banner sản phẩm ALOO">
    <div class="relative h-[42vh] min-h-[360px] sm:h-[46vh] sm:min-h-[420px] lg:h-[50vh] lg:min-h-[460px]">
      <img
        v-if="hero.image"
        :src="hero.image"
        :alt="hero.title"
        class="h-full w-full object-cover object-center"
        loading="eager"
        fetchpriority="high"
      />
      <div v-else class="h-full w-full bg-[linear-gradient(135deg,#FFF7E6,#CDECA6_45%,#0D2F1B)]"></div>

      <div class="absolute inset-0 bg-[linear-gradient(180deg,rgba(5,28,14,0.04),rgba(5,28,14,0.24))]"></div>
    </div>
  </section>
</template>
