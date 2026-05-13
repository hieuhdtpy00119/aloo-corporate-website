<script setup>
defineProps({
  search: {
    type: String,
    default: '',
  },
  searchPlaceholder: {
    type: String,
    default: 'Tìm kiếm',
  },
  status: {
    type: String,
    default: 'Tất cả',
  },
  statusOptions: {
    type: Array,
    default: () => ['Tất cả'],
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
    default: 'Tất cả',
  },
})

defineEmits(['update:search', 'update:status', 'update:extraFilter'])
</script>

<template>
  <div class="mb-4 grid gap-3 rounded-lg border border-slate-200 bg-white p-4 shadow-sm" :class="extraOptions.length ? 'lg:grid-cols-[1fr_220px_220px]' : 'md:grid-cols-[1fr_220px]'">
    <input
      :value="search"
      type="search"
      :placeholder="searchPlaceholder"
      class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"
      @input="$emit('update:search', $event.target.value)"
    />
    <select
      v-if="extraOptions.length"
      :value="extraFilter"
      class="rounded-lg border border-slate-200 px-4 py-3 font-semibold outline-none focus:border-avocado-500"
      @change="$emit('update:extraFilter', $event.target.value)"
    >
      <option v-for="option in extraOptions" :key="option" :value="option">{{ option || extraPlaceholder }}</option>
    </select>
    <select
      :value="status"
      class="rounded-lg border border-slate-200 px-4 py-3 font-semibold outline-none focus:border-avocado-500"
      @change="$emit('update:status', $event.target.value)"
    >
      <option v-for="option in statusOptions" :key="option" :value="option">{{ option }}</option>
    </select>
  </div>
</template>
