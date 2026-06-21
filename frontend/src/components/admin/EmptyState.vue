<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const props = defineProps({
  loading: {
    type: Boolean,
    default: false,
  },
  message: {
    type: String,
    default: '',
  },
  title: {
    type: String,
    default: '',
  },
  description: {
    type: String,
    default: '',
  },
})

const { t } = useI18n()

const resolvedMessage = computed(() => props.message || t('admin.common.emptyDefault'))
</script>

<template>
  <div class="px-5 py-10 text-center">
    <p v-if="loading" class="text-sm font-semibold text-slate-500">{{ t('admin.common.loading') }}</p>
    <template v-else>
      <p v-if="title" class="text-base font-bold text-slate-700">{{ title }}</p>
      <p class="text-sm font-semibold text-slate-500" :class="title ? 'mt-2' : ''">
        {{ description || resolvedMessage }}
      </p>
    </template>
  </div>
</template>
