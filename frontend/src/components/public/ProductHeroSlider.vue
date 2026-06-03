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
    <div class="relative h-[460px] sm:h-[560px] lg:h-[640px]">
      <img
        v-if="hero.image"
        :src="hero.image"
        :alt="hero.title"
        class="h-full w-full object-cover object-center"
        loading="eager"
        fetchpriority="high"
      />
      <div v-else class="h-full w-full bg-[linear-gradient(135deg,#f6eddc,#dfeec8_45%,#173f25)]"></div>

      <div class="absolute inset-0 bg-[linear-gradient(90deg,rgba(8,32,18,0.24),rgba(8,32,18,0.02)_42%,rgba(8,32,18,0.22)),linear-gradient(180deg,rgba(255,255,255,0.04),rgba(8,32,18,0.38))]"></div>

    </div>
  </section>
</template>
