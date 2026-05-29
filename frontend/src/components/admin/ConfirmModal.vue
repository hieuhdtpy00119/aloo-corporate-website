<script setup>
import { computed } from 'vue'
import BaseModal from './BaseModal.vue'

const props = defineProps({
  show: {
    type: Boolean,
    default: false,
  },
  open: {
    type: Boolean,
    default: false,
  },
  title: {
    type: String,
    default: 'Xác nhận xóa',
  },
  message: {
    type: String,
    default: 'Hành động này không thể hoàn tác. Bạn có chắc chắn muốn xóa vĩnh viễn mục dữ liệu này khỏi cơ sở dữ liệu hệ thống?',
  },
  confirmText: {
    type: String,
    default: '',
  },
  confirmLabel: {
    type: String,
    default: '',
  },
})

const emit = defineEmits(['cancel', 'close', 'confirm'])

const isVisible = computed(() => props.show || props.open)
const resolvedConfirmLabel = computed(() => props.confirmText || props.confirmLabel || 'Xác nhận xóa')

const cancel = () => {
  emit('cancel')
  emit('close')
}
</script>

<template>
  <BaseModal :show="isVisible" :title="title" max-width="max-w-md" @close="cancel">
    <p class="leading-relaxed text-sm text-slate-500">
      {{ message }}
    </p>
    <template #footer>
      <div class="flex flex-col-reverse gap-3 sm:flex-row sm:justify-end">
        <button class="rounded-full border border-slate-200 px-5 py-3 text-xs font-bold uppercase tracking-wider text-slate-500 transition hover:bg-slate-50" @click="cancel">Hủy bỏ</button>
        <button class="rounded-full bg-red-600 px-6 py-3 text-xs font-bold uppercase tracking-wider text-white shadow-md shadow-red-600/10 transition hover:bg-red-500" @click="$emit('confirm')">
          {{ resolvedConfirmLabel }}
        </button>
      </div>
    </template>
  </BaseModal>
</template>
