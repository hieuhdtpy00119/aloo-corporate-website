<script setup>
defineProps({
  eyebrow: {
    type: String,
    default: '',
  },
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    default: '',
  },
  admin: {
    type: Boolean,
    default: false,
  },
})
</script>

<template>
  <header :class="admin ? 'aloo-admin-header' : 'aloo-section-header'">
    <div class="aloo-section-header">
      <p v-if="eyebrow" class="aloo-eyebrow">{{ eyebrow }}</p>
      <h1 class="aloo-title" :class="{ 'aloo-title--admin': admin }">{{ title }}</h1>
      <p v-if="description" class="aloo-copy">{{ description }}</p>
      <slot name="meta" />
    </div>

    <div v-if="$slots.actions" class="aloo-actions">
      <slot name="actions" />
    </div>
  </header>
</template>
