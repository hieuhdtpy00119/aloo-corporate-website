<script setup>
defineProps({
  eyebrow: { type: String, default: '' },
  title: { type: String, required: true },
})
</script>

<template>
  <div class="aloo-admin-header max-lg:!grid-cols-1">
    <div class="min-w-0">
      <p v-if="eyebrow" class="aloo-eyebrow">{{ eyebrow }}</p>
      <h1 class="aloo-title aloo-title--admin mt-2">{{ title }}</h1>
    </div>
    <div v-if="$slots.actions" class="flex flex-wrap gap-3 max-lg:pt-2">
      <slot name="actions" />
    </div>
  </div>
</template>
