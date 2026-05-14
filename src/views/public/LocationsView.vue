<script setup>
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import SectionTitle from '../../components/public/SectionTitle.vue'
import { useAppStore } from '../../stores/appStore'

const { t } = useI18n()
const store = useAppStore()
const searchKeyword = ref('')
const selectedProvince = ref('all')

const locations = computed(() => store.locations.filter((location) => location.status !== 'Tạm đóng'))
const provinces = computed(() => ['all', ...new Set(locations.value.map((location) => location.province))])
const getProvinceLabel = (province) => (province === 'all' ? t('common.all') : province)
const getStatusLabel = (status) => {
  if (status === 'Đang hoạt động' || status === 'active') return t('locations.active')
  if (status === 'Sắp khai trương' || status === 'comingSoon') return t('locations.comingSoon')
  return status
}

const filteredLocations = computed(() => {
  const keyword = searchKeyword.value.trim().toLowerCase()

  return locations.value.filter((location) => {
    const matchesProvince =
      selectedProvince.value === 'all' || location.province === selectedProvince.value
    const matchesKeyword =
      !keyword ||
      location.name.toLowerCase().includes(keyword) ||
      location.address.toLowerCase().includes(keyword)

    return matchesProvince && matchesKeyword
  })
})
</script>

<template>
  <section class="bg-avocado-50 px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      :eyebrow="t('locations.eyebrow')"
      :title="t('locations.title')"
      :description="t('locations.description')"
    />

    <div class="mx-auto mb-8 grid max-w-5xl gap-4 rounded-lg border border-avocado-100 bg-white p-5 shadow-sm md:grid-cols-[1fr_240px]">
      <input
        v-model="searchKeyword"
        type="search"
        :placeholder="t('locations.searchPlaceholder')"
        class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"
      />
      <select
        v-model="selectedProvince"
        class="rounded-lg border border-slate-200 px-4 py-3 font-semibold text-slate-700 outline-none focus:border-avocado-500"
      >
        <option v-for="province in provinces" :key="province" :value="province">{{ getProvinceLabel(province) }}</option>
      </select>
    </div>

    <div class="mx-auto grid max-w-7xl gap-6 md:grid-cols-2 xl:grid-cols-3">
      <article
        v-for="location in filteredLocations"
        :key="location.id"
        class="rounded-lg border border-avocado-100 bg-white p-6 shadow-sm transition hover:-translate-y-1 hover:shadow-lg"
      >
        <div class="mb-4 flex items-start justify-between gap-4">
          <div>
            <h3 class="text-xl font-black text-avocado-950">{{ location.name }}</h3>
            <p class="mt-1 text-sm font-bold text-avocado-700">{{ location.province }}</p>
          </div>
          <span
            class="rounded-full px-3 py-1 text-xs font-bold"
            :class="
              location.status === 'Đang hoạt động' || location.status === 'active'
                ? 'bg-emerald-50 text-emerald-700'
                : 'bg-amber-50 text-amber-700'
            "
          >
            {{ getStatusLabel(location.status) }}
          </span>
        </div>
        <div class="space-y-3 text-sm leading-6 text-slate-600">
          <p><span class="font-bold text-slate-800">{{ t('common.address') }}:</span> {{ location.address }}</p>
          <p><span class="font-bold text-slate-800">{{ t('common.phone') }}:</span> {{ location.phone }}</p>
          <p><span class="font-bold text-slate-800">{{ t('common.openingHours') }}:</span> {{ location.openingHours }}</p>
        </div>
        <a
          :href="location.mapUrl"
          target="_blank"
          rel="noreferrer"
          class="mt-6 inline-flex rounded-full bg-cream-400 px-5 py-3 text-sm font-black text-avocado-950 hover:bg-cream-300"
        >
          {{ t('common.viewMap') }}
        </a>
      </article>
    </div>

    <p v-if="filteredLocations.length === 0" class="mx-auto mt-10 max-w-xl text-center font-semibold text-slate-500">
      {{ t('common.noLocationFound') }}
    </p>
  </section>
</template>
