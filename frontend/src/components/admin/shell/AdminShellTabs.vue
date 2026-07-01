<script setup>
defineProps({
  items: { type: Array, default: () => [] },
  modelValue: { type: String, default: '' },
  ariaLabel: { type: String, default: '' },
})

defineEmits(['update:modelValue'])
</script>

<template>
  <nav class="admin-shell-tabs" :aria-label="ariaLabel">
    <button
      v-for="item in items"
      :key="item.key"
      type="button"
      class="admin-shell-tabs__btn"
      :class="{ 'admin-shell-tabs__btn--active': modelValue === item.key }"
      @click="$emit('update:modelValue', item.key)"
    >
      {{ item.label }}
    </button>
  </nav>
</template>
