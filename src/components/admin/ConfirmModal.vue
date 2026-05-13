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
    <p class="leading-7 text-slate-700">Bạn có chắc muốn xóa dữ liệu này không?</p>
    <template #footer>
      <div class="flex justify-end gap-3">
        <button class="rounded-lg border border-slate-200 px-4 py-3 font-bold text-slate-600 hover:bg-slate-50" @click="$emit('cancel')">Hủy</button>
        <button class="rounded-lg bg-red-600 px-4 py-3 font-black text-white hover:bg-red-700" @click="$emit('confirm')">Xóa</button>
      </div>
    </template>
  </BaseModal>
</template>
