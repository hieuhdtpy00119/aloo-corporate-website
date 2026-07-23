<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const props = defineProps({
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
    default: '',
  },
})

defineEmits(['prev', 'next'])

const { t } = useI18n()
const resolvedLabel = computed(() => props.label || t('admin.shared.rows'))
</script>

<template>
  <div v-if="totalCount > 0" class="mt-3 flex flex-col justify-between gap-2 text-xs text-slate-600 sm:flex-row sm:items-center">
    <p>{{ t('admin.shared.paginationShowing', { visible: visibleCount, total: totalCount, label: resolvedLabel }) }}</p>
    <div class="flex items-center gap-2">
      <button class="rounded-lg border border-slate-200 px-2.5 py-1.5 text-xs font-semibold disabled:opacity-50" :disabled="page <= 1" @click="$emit('prev')">{{ t('admin.shared.paginationPrev') }}</button>
      <span class="px-1 text-xs font-semibold text-avocado-800">{{ t('admin.shared.paginationPage', { page, totalPages }) }}</span>
      <button class="rounded-lg border border-slate-200 px-2.5 py-1.5 text-xs font-semibold disabled:opacity-50" :disabled="page >= totalPages" @click="$emit('next')">{{ t('admin.shared.paginationNext') }}</button>
    </div>
  </div>
</template>
