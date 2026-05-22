<script setup>
import { ChevronDown, ChevronLeft, ChevronRight, ChevronUp } from 'lucide-vue-next'

defineProps({
  slides: {
    type: Array,
    default: () => [],
  },
  activeIndex: {
    type: Number,
    default: 0,
  },
})

defineEmits(['select', 'prev', 'next'])
</script>

<template>
  <div class="absolute bottom-5 left-1/2 z-40 flex -translate-x-1/2 items-center gap-2 rounded-full border border-white/15 bg-black/42 p-2 shadow-2xl shadow-black/20 backdrop-blur-2xl lg:left-7 lg:top-1/2 lg:bottom-auto lg:-translate-x-0 lg:-translate-y-1/2 lg:flex-col">
    <button class="flex h-8 w-8 items-center justify-center rounded-full text-sm font-black text-white/80 transition hover:bg-white/15 hover:text-white focus:outline-none focus:ring-2 focus:ring-cream-200" aria-label="Sản phẩm trước" @click="$emit('prev')">
      <ChevronUp class="hidden h-4 w-4 lg:block" aria-hidden="true" />
      <ChevronLeft class="h-4 w-4 lg:hidden" aria-hidden="true" />
    </button>

    <div class="flex gap-2 lg:flex-col">
      <button
        v-for="(slide, index) in slides"
        :key="slide.id"
        class="relative h-10 w-10 overflow-hidden rounded-full border transition duration-300 focus:outline-none focus:ring-2 focus:ring-cream-200 sm:h-12 sm:w-12 lg:h-14 lg:w-14"
        :class="
          activeIndex === index
            ? 'scale-110 border-cream-200 opacity-100 shadow-lg shadow-cream-200/25'
            : 'border-white/20 opacity-55 hover:scale-105 hover:border-white/60 hover:opacity-95'
        "
        :aria-label="slide.title"
        @click="$emit('select', index)"
      >
        <img :src="slide.thumbnailImage || slide.productImage" :alt="slide.title" class="h-full w-full object-cover" loading="lazy" />
        <span class="absolute inset-0" :class="activeIndex === index ? 'bg-transparent' : 'bg-black/25'"></span>
      </button>
    </div>

    <button class="flex h-8 w-8 items-center justify-center rounded-full text-sm font-black text-white/80 transition hover:bg-white/15 hover:text-white focus:outline-none focus:ring-2 focus:ring-cream-200" aria-label="Sản phẩm tiếp theo" @click="$emit('next')">
      <ChevronDown class="hidden h-4 w-4 lg:block" aria-hidden="true" />
      <ChevronRight class="h-4 w-4 lg:hidden" aria-hidden="true" />
    </button>
  </div>
</template>
