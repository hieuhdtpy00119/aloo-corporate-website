<script setup>
import { computed, onBeforeUnmount, reactive, ref, watch } from 'vue'
import BaseModal from '../admin/BaseModal.vue'
import { useToastStore } from '../../stores/toastStore'

const props = defineProps({
  show: {
    type: Boolean,
    default: false,
  },
  imageSrc: {
    type: String,
    default: '',
  },
  fileName: {
    type: String,
    default: 'avatar.jpg',
  },
})

const emit = defineEmits(['close', 'confirm'])

const toast = useToastStore()

const viewportSize = 280
const exportSize = 512
const zoom = ref(1)
const offset = reactive({ x: 0, y: 0 })
const imageMeta = reactive({ w: 0, h: 0 })
const isDragging = ref(false)
const isExporting = ref(false)
const dragStart = reactive({ x: 0, y: 0, offsetX: 0, offsetY: 0 })
const viewportRef = ref(null)

const baseScale = computed(() => {
  if (!imageMeta.w || !imageMeta.h) return 1
  return Math.max(viewportSize / imageMeta.w, viewportSize / imageMeta.h)
})

const scale = computed(() => baseScale.value * zoom.value)

const displaySize = computed(() => ({
  w: imageMeta.w * scale.value,
  h: imageMeta.h * scale.value,
}))

const imageStyle = computed(() => ({
  width: `${displaySize.value.w}px`,
  height: `${displaySize.value.h}px`,
  transform: `translate(${offset.x}px, ${offset.y}px)`,
}))

const clampOffset = () => {
  const minX = viewportSize - displaySize.value.w
  const minY = viewportSize - displaySize.value.h
  offset.x = Math.min(0, Math.max(minX, offset.x))
  offset.y = Math.min(0, Math.max(minY, offset.y))
}

const resetPosition = () => {
  offset.x = (viewportSize - displaySize.value.w) / 2
  offset.y = (viewportSize - displaySize.value.h) / 2
  clampOffset()
}

const loadImageMeta = () => {
  if (!props.imageSrc) {
    imageMeta.w = 0
    imageMeta.h = 0
    return
  }

  const img = new Image()
  img.onload = () => {
    imageMeta.w = img.naturalWidth
    imageMeta.h = img.naturalHeight
    zoom.value = 1
    resetPosition()
  }
  img.src = props.imageSrc
}

watch(
  () => props.imageSrc,
  () => loadImageMeta(),
  { immediate: true },
)

watch(zoom, () => {
  resetPosition()
})

const endDrag = () => {
  isDragging.value = false
}

const onPointerDown = (event) => {
  if (!props.imageSrc) return
  isDragging.value = true
  dragStart.x = event.clientX
  dragStart.y = event.clientY
  dragStart.offsetX = offset.x
  dragStart.offsetY = offset.y
  event.currentTarget.setPointerCapture?.(event.pointerId)
}

const onPointerMove = (event) => {
  if (!isDragging.value) return
  offset.x = dragStart.offsetX + (event.clientX - dragStart.x)
  offset.y = dragStart.offsetY + (event.clientY - dragStart.y)
  clampOffset()
}

const onPointerUp = (event) => {
  if (!isDragging.value) return
  event.currentTarget.releasePointerCapture?.(event.pointerId)
  endDrag()
}

const exportCroppedFile = () =>
  new Promise((resolve, reject) => {
    const img = new Image()
    img.onload = () => {
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      if (!ctx) {
        reject(new Error('Canvas not supported'))
        return
      }

      const currentScale = scale.value
      const srcSize = viewportSize / currentScale
      const srcX = -offset.x / currentScale
      const srcY = -offset.y / currentScale

      canvas.width = exportSize
      canvas.height = exportSize
      ctx.drawImage(img, srcX, srcY, srcSize, srcSize, 0, 0, exportSize, exportSize)

      canvas.toBlob(
        (blob) => {
          if (!blob) {
            reject(new Error('Could not export image'))
            return
          }

          const baseName = props.fileName.replace(/\.[^/.]+$/, '') || 'avatar'
          resolve(new File([blob], `${baseName}_avatar.jpg`, { type: 'image/jpeg' }))
        },
        'image/jpeg',
        0.92,
      )
    }
    img.onerror = () => reject(new Error('Could not load image'))
    img.src = props.imageSrc
  })

const handleConfirm = async () => {
  if (!props.imageSrc || isExporting.value) return

  isExporting.value = true
  try {
    const file = await exportCroppedFile()
    emit('confirm', file)
  } catch {
    toast.error('Không xử lý được ảnh, vui lòng thử lại')
  } finally {
    isExporting.value = false
  }
}

onBeforeUnmount(() => {
  endDrag()
})
</script>

<template>
  <BaseModal :show="show" title="Căn chỉnh ảnh đại diện" max-width="max-w-md" @close="$emit('close')">
    <div class="space-y-5">
      <p class="text-sm leading-6 text-slate-600">
        Kéo ảnh để chọn vùng hiển thị trong khung tròn. Dùng thanh zoom nếu cần phóng to.
      </p>

      <div class="flex flex-col items-center gap-4">
        <div
          ref="viewportRef"
          class="relative touch-none overflow-hidden rounded-full border-4 border-avocado-500 bg-slate-900 shadow-inner"
          :class="isDragging ? 'cursor-grabbing' : 'cursor-grab'"
          :style="{ width: `${viewportSize}px`, height: `${viewportSize}px` }"
          @pointerdown="onPointerDown"
          @pointermove="onPointerMove"
          @pointerup="onPointerUp"
          @pointercancel="onPointerUp"
          @lostpointercapture="endDrag"
        >
          <img
            v-if="imageSrc"
            :src="imageSrc"
            alt="Ảnh để căn chỉnh"
            draggable="false"
            class="absolute left-0 top-0 max-w-none select-none"
            :style="imageStyle"
          />
        </div>

        <p class="text-xs font-semibold text-slate-500">Xem trước giống ảnh đại diện trên website</p>
      </div>

      <label class="grid gap-2 text-sm font-bold text-slate-700">
        Phóng to: {{ Math.round(zoom * 100) }}%
        <input
          v-model.number="zoom"
          type="range"
          min="1"
          max="3"
          step="0.01"
          class="h-2 w-full cursor-pointer appearance-none rounded-lg bg-slate-200 accent-avocado-600"
        />
      </label>
    </div>

    <template #footer>
      <div class="flex justify-end gap-3">
        <button
          type="button"
          class="rounded-xl border border-slate-200 px-5 py-2.5 text-sm font-black text-slate-600 transition hover:bg-slate-50"
          :disabled="isExporting"
          @click="$emit('close')"
        >
          Hủy
        </button>
        <button
          type="button"
          class="rounded-xl bg-avocado-800 px-5 py-2.5 text-sm font-black text-white transition hover:bg-avocado-900 disabled:cursor-not-allowed disabled:opacity-60"
          :disabled="isExporting || !imageSrc"
          @click="handleConfirm"
        >
          {{ isExporting ? 'Đang xử lý...' : 'Lưu ảnh đại diện' }}
        </button>
      </div>
    </template>
  </BaseModal>
</template>
