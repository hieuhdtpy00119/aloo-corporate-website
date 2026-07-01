<script setup>
import { Search } from 'lucide-vue-next'
import { useI18n } from 'vue-i18n'

defineProps({
  embedded: {
    type: Boolean,
    default: false,
  },
  search: {
    type: String,
    default: '',
  },
  searchPlaceholder: {
    type: String,
    default: '',
  },
  searchLabel: {
    type: String,
    default: '',
  },
  status: {
    type: String,
    default: '',
  },
  statusLabel: {
    type: String,
    default: '',
  },
  statusOptions: {
    type: Array,
    default: () => [],
  },
  extraFilter: {
    type: String,
    default: '',
  },
  extraOptions: {
    type: Array,
    default: () => [],
  },
  extraPlaceholder: {
    type: String,
    default: '',
  },
  extraLabel: {
    type: String,
    default: '',
  },
})

defineEmits(['update:search', 'update:status', 'update:extraFilter'])

const { t } = useI18n()
</script>

<template>
  <div
    class="aloo-admin-toolbar"
    :class="[
      extraOptions.length ? 'lg:!grid-cols-[1fr_220px_220px]' : 'md:!grid-cols-[1fr_220px]',
      embedded ? 'aloo-admin-toolbar--embedded' : '',
    ]"
  >
    <label class="aloo-field">
      <span class="aloo-label">{{ searchLabel || t('admin.shared.search') }}</span>
      <span class="relative w-full">
        <Search class="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
        <input
          :value="search"
          type="search"
          :placeholder="searchPlaceholder || t('admin.shared.searchPlaceholder')"
          class="aloo-input !pl-11"
          @input="$emit('update:search', $event.target.value)"
        />
      </span>
    </label>

    <label v-if="extraOptions.length" class="aloo-field">
      <span class="aloo-label">{{ extraLabel || t('admin.shared.filter') }}</span>
      <select
        :value="extraFilter"
        class="aloo-select"
        @change="$emit('update:extraFilter', $event.target.value)"
      >
        <option v-for="option in extraOptions" :key="option" :value="option">{{ option || extraPlaceholder || t('admin.shared.all') }}</option>
      </select>
    </label>

    <label class="aloo-field">
      <span class="aloo-label">{{ statusLabel || t('admin.shared.status') }}</span>
      <select
        :value="status"
        class="aloo-select"
        @change="$emit('update:status', $event.target.value)"
      >
        <option v-for="option in statusOptions" :key="option" :value="option">{{ option }}</option>
      </select>
    </label>
  </div>
</template>
