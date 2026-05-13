<script setup>
defineProps({
  columns: {
    type: Array,
    required: true,
  },
  rows: {
    type: Array,
    required: true,
  },
  actions: {
    type: Boolean,
    default: false,
  },
})
</script>

<template>
  <div class="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-slate-200 text-left">
        <thead class="bg-slate-50">
          <tr>
            <th v-for="column in columns" :key="column.key" class="px-5 py-4 text-sm font-black text-slate-600">
              {{ column.label }}
            </th>
            <th v-if="actions" class="px-5 py-4 text-sm font-black text-slate-600">Thao tac</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          <tr v-for="row in rows" :key="row.id" class="hover:bg-avocado-50/60">
            <td v-for="column in columns" :key="column.key" class="whitespace-nowrap px-5 py-4 text-sm text-slate-700">
              <span
                v-if="column.key === 'status'"
                class="rounded-full px-3 py-1 text-xs font-bold"
                :class="{
                  'bg-blue-50 text-blue-700': row[column.key] === 'Moi',
                  'bg-emerald-50 text-emerald-700': row[column.key] === 'Da lien he',
                  'bg-emerald-50 text-emerald-700': row[column.key] === 'Dang hien thi',
                  'bg-emerald-50 text-emerald-700': row[column.key] === 'Da dang',
                  'bg-amber-50 text-amber-700': row[column.key] === 'Dang tu van',
                  'bg-amber-50 text-amber-700': row[column.key] === 'Ban nhap',
                  'bg-amber-50 text-amber-700': row[column.key] === 'Len lich',
                  'bg-avocado-50 text-avocado-700': row[column.key] === 'Hoan tat',
                  'bg-slate-100 text-slate-600': row[column.key] === 'Tam an',
                  'bg-red-50 text-red-700': row[column.key] === 'Huy',
                }"
              >
                {{ row[column.key] }}
              </span>
              <img
                v-else-if="column.type === 'image'"
                :src="row[column.key]"
                :alt="row.title || 'Anh'"
                class="h-14 w-24 rounded-md object-cover"
              />
              <span v-else>{{ row[column.key] }}</span>
            </td>
            <td v-if="actions" class="whitespace-nowrap px-5 py-4 text-sm">
              <button class="mr-2 rounded-lg border border-avocado-200 px-3 py-2 font-bold text-avocado-700 hover:bg-avocado-50">Sua</button>
              <button class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600 hover:bg-red-50">Xoa</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
