<script setup>
defineProps({
  title: { type: String, required: true },
  countText: { type: String, default: '' },
})
</script>

<template>
  <div class="admin-list-panel admin-list-table-panel">
    <div class="admin-list-table-panel__head">
      <h2 class="admin-list-table-panel__title">{{ title }}</h2>
      <span v-if="countText" class="admin-list-table-panel__count">{{ countText }}</span>
    </div>
    <div class="admin-list-table-panel__body">
      <slot />
    </div>
  </div>
</template>
