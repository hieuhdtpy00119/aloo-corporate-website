<script setup>
defineProps({
  title: { type: String, required: true },
  countText: { type: String, default: '' },
})
</script>

<template>
  <div class="admin-shell-table-head">
    <h2 class="admin-shell-table-head__title">{{ title }}</h2>
    <span v-if="countText" class="admin-shell-table-head__count">{{ countText }}</span>
  </div>
</template>
