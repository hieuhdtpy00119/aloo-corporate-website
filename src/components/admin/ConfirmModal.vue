<script setup>
import BaseModal from './BaseModal.vue'

defineProps({
  show: {
    type: Boolean,
    default: false,
  },
})

defineEmits(['cancel', 'confirm'])
</script>

<template>
  <BaseModal :show="show" title="Xác nhận xóa" max-width="max-w-md" @close="$emit('cancel')">
    <p class="leading-relaxed text-sm text-slate-500">
      Hành động này không thể hoàn tác. Bạn có chắc chắn muốn xóa vĩnh viễn mục dữ liệu này khỏi cơ sở dữ liệu hệ thống?
    </p>
    <template #footer>
      <div class="flex justify-end gap-3">
        <button class="rounded-full border border-slate-200 px-5 py-3 text-xs font-bold uppercase tracking-wider text-slate-500 hover:bg-slate-50 transition" @click="$emit('cancel')">Hủy bỏ</button>
        <button class="rounded-full bg-red-600 px-6 py-3 text-xs font-bold uppercase tracking-wider text-white hover:bg-red-500 transition shadow-md shadow-red-600/10" @click="$emit('confirm')">Xác nhận xóa</button>
      </div>
    </template>
  </BaseModal>
</template>

