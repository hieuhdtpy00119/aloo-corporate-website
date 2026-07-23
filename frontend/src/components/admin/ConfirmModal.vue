<script setup>
import { computed, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
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
    default: '',
  },
  message: {
    type: String,
    default: '',
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
const { t } = useI18n()

const isVisible = computed(() => props.show || props.open)
const isConfirming = ref(false)
const resolvedTitle = computed(() => props.title || t('admin.shared.confirmDeleteTitle'))
const resolvedMessage = computed(() => props.message || t('admin.shared.confirmDeleteMessage'))
const resolvedConfirmLabel = computed(() => props.confirmText || props.confirmLabel || t('admin.shared.confirmDelete'))

const cancel = () => {
  if (isConfirming.value) return
  emit('cancel')
  emit('close')
}

const confirm = () => {
  if (isConfirming.value) return
  isConfirming.value = true
  emit('confirm')
}

watch(isVisible, (visible) => {
  if (!visible) isConfirming.value = false
})
</script>

<template>
  <BaseModal :show="isVisible" :title="resolvedTitle" max-width="max-w-md" @close="cancel">
    <p class="leading-relaxed text-sm text-slate-500">
      {{ resolvedMessage }}
    </p>
    <template #footer>
      <div class="flex flex-col-reverse gap-3 sm:flex-row sm:justify-end">
        <button type="button" class="rounded-full border border-slate-200 px-5 py-3 text-xs font-bold uppercase tracking-wider text-slate-500 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isConfirming" @click="cancel">{{ t('admin.shared.cancel') }}</button>
        <button type="button" class="rounded-full bg-red-600 px-6 py-3 text-xs font-bold uppercase tracking-wider text-white shadow-md shadow-red-600/10 transition hover:bg-red-500 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isConfirming" @click="confirm">
          {{ resolvedConfirmLabel }}
        </button>
      </div>
    </template>
  </BaseModal>
</template>
