<script setup>
defineProps({
  src: {
    type: String,
    required: true,
  },
  alt: {
    type: String,
    default: '',
  },
})
</script>

<template>
  <div class="relative overflow-hidden bg-brand-cream/40">
    <img :src="src" :alt="alt" class="h-full w-full object-cover" />
  </div>
</template>
