<script setup>
defineProps({
  loading: {
    type: Boolean,
    default: false,
  },
  message: {
    type: String,
    default: 'Không có dữ liệu phù hợp',
  },
})
</script>

<template>
  <div class="px-5 py-10 text-center text-sm font-semibold text-slate-500">
    {{ loading ? 'Đang tải dữ liệu...' : message }}
  </div>
</template>
