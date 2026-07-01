<script setup>
import AdminShellTableHead from './AdminShellTableHead.vue'

defineProps({
  title: { type: String, default: '' },
  countText: { type: String, default: '' },
})
</script>

<template>
  <div class="admin-shell-frame__inner admin-shell-frame__inner--table">
    <AdminShellTableHead v-if="title" :title="title" :count-text="countText" />
    <div class="admin-shell-table-scroll" v-if="$slots.default">
      <slot />
    </div>
    <slot name="below" />
  </div>
</template>
