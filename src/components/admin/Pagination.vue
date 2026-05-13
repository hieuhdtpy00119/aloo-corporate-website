<script setup>
defineProps({
  page: {
    type: Number,
    required: true,
  },
  totalPages: {
    type: Number,
    required: true,
  },
  visibleCount: {
    type: Number,
    required: true,
  },
  totalCount: {
    type: Number,
    required: true,
  },
  label: {
    type: String,
    default: 'dòng',
  },
})

defineEmits(['prev', 'next'])
</script>

<template>
  <div v-if="totalCount > 0" class="mt-4 flex flex-col justify-between gap-3 text-sm text-slate-600 sm:flex-row sm:items-center">
    <p>Hiển thị {{ visibleCount }} / {{ totalCount }} {{ label }}</p>
    <div class="flex items-center gap-2">
      <button class="rounded-lg border border-slate-200 px-3 py-2 font-bold disabled:opacity-50" :disabled="page === 1" @click="$emit('prev')">Trước</button>
      <span class="font-bold text-avocado-800">Trang {{ page }} / {{ totalPages }}</span>
      <button class="rounded-lg border border-slate-200 px-3 py-2 font-bold disabled:opacity-50" :disabled="page === totalPages" @click="$emit('next')">Sau</button>
    </div>
  </div>
</template>
