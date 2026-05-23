<script setup>
import { computed } from 'vue'

const props = defineProps({
  status: {
    type: String,
    default: '',
  },
  label: {
    type: String,
    default: '',
  },
})

const statusMap = {
  ACTIVE: { label: 'Đang hoạt động', tone: 'success' },
  AVAILABLE: { label: 'Đang bán', tone: 'success' },
  PUBLISHED: { label: 'Đã xuất bản', tone: 'success' },
  APPROVED: { label: 'Đã duyệt', tone: 'success' },
  COMPLETED: { label: 'Hoàn tất', tone: 'success' },
  CONTACTED: { label: 'Đã liên hệ', tone: 'success' },
  FEATURED: { label: 'Nổi bật', tone: 'success' },
  OPEN: { label: 'Đang mở', tone: 'success' },
  DRAFT: { label: 'Bản nháp', tone: 'neutral' },
  INACTIVE: { label: 'Tạm ẩn', tone: 'neutral' },
  HIDDEN: { label: 'Đã ẩn', tone: 'neutral' },
  ARCHIVED: { label: 'Lưu trữ', tone: 'neutral' },
  NEW: { label: 'Mới', tone: 'info' },
  PENDING: { label: 'Chờ xử lý', tone: 'warning' },
  REVIEWING: { label: 'Đang duyệt', tone: 'warning' },
  IN_PROGRESS: { label: 'Đang xử lý', tone: 'warning' },
  OPENING_SOON: { label: 'Sắp khai trương', tone: 'warning' },
  OUT_OF_STOCK: { label: 'Tạm hết', tone: 'danger' },
  CANCELLED: { label: 'Đã hủy', tone: 'danger' },
  DELETED: { label: 'Đã xóa', tone: 'danger' },
}

const normalizedStatus = computed(() => String(props.status || '').trim().toUpperCase())

const displayStatus = computed(() => {
  const mapped = statusMap[normalizedStatus.value]
  return {
    label:
      props.label ||
      mapped?.label ||
      normalizedStatus.value
        .toLowerCase()
        .replaceAll('_', ' ')
        .replace(/(^|\s)\S/g, (char) => char.toUpperCase()),
    tone: mapped?.tone || 'neutral',
  }
})
</script>

<template>
  <span class="aloo-status" :class="`aloo-status--${displayStatus.tone}`">
    {{ displayStatus.label }}
  </span>
</template>
