<script setup>
import { Search } from 'lucide-vue-next'

defineProps({
  search: {
    type: String,
    default: '',
  },
  searchPlaceholder: {
    type: String,
    default: 'Tìm kiếm',
  },
  searchLabel: {
    type: String,
    default: 'Tìm kiếm',
  },
  status: {
    type: String,
    default: 'Tất cả',
  },
  statusLabel: {
    type: String,
    default: 'Trạng thái',
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
  extraLabel: {
    type: String,
    default: 'Bộ lọc',
  },
})

defineEmits(['update:search', 'update:status', 'update:extraFilter'])
</script>

<template>
  <div
    class="mb-6 grid gap-4 rounded-3xl border border-slate-100 bg-white p-4.5 shadow-sm"
    :class="extraOptions.length ? 'lg:grid-cols-[1fr_220px_220px]' : 'md:grid-cols-[1fr_220px]'"
  >
    <label class="grid gap-2">
      <span class="text-[11px] font-black uppercase tracking-[0.14em] text-slate-500">{{ searchLabel }}</span>
      <span class="relative w-full">
        <Search class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 h-4.5 w-4.5" />
        <input
          :value="search"
          type="search"
          :placeholder="searchPlaceholder"
          class="w-full rounded-2xl border border-slate-100 bg-slate-50/50 pl-11 pr-4 py-3.5 text-xs font-semibold text-slate-700 outline-none focus:bg-white focus:border-avocado-500 focus:ring-3 focus:ring-avocado-50 transition"
          @input="$emit('update:search', $event.target.value)"
        />
      </span>
    </label>

    <label v-if="extraOptions.length" class="grid gap-2">
      <span class="text-[11px] font-black uppercase tracking-[0.14em] text-slate-500">{{ extraLabel }}</span>
      <select
        :value="extraFilter"
        class="rounded-2xl border border-slate-100 bg-slate-50/50 px-4 py-3.5 text-xs font-semibold text-slate-700 outline-none focus:bg-white focus:border-avocado-500 focus:ring-3 focus:ring-avocado-50 transition cursor-pointer"
        @change="$emit('update:extraFilter', $event.target.value)"
      >
        <option v-for="option in extraOptions" :key="option" :value="option">{{ option || extraPlaceholder }}</option>
      </select>
    </label>

    <label class="grid gap-2">
      <span class="text-[11px] font-black uppercase tracking-[0.14em] text-slate-500">{{ statusLabel }}</span>
      <select
        :value="status"
        class="rounded-2xl border border-slate-100 bg-slate-50/50 px-4 py-3.5 text-xs font-semibold text-slate-700 outline-none focus:bg-white focus:border-avocado-500 focus:ring-3 focus:ring-avocado-50 transition cursor-pointer"
        @change="$emit('update:status', $event.target.value)"
      >
        <option v-for="option in statusOptions" :key="option" :value="option">{{ option }}</option>
      </select>
    </label>
  </div>
</template>
