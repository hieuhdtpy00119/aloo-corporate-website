<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { useAppStore } from '../../stores/appStore'
import { Car, Clock, Compass, CreditCard, MapPin, Phone, Search, Snowflake, Wifi } from 'lucide-vue-next'

const { t } = useI18n()
const store = useAppStore()
const searchKeyword = ref('')
const selectedProvince = ref('all')

const normalizeLocation = (location) => ({
  ...location,
  addressText: location.addressText || location.address || '',
  city: location.city || location.province || '',
  imageUrl: location.imageUrl || '',
  amenities: Array.isArray(location.amenities) ? location.amenities : [],
  links: Array.isArray(location.links) ? location.links : [],
})

const locations = computed(() =>
  store.locations
    .map(normalizeLocation)
    .filter((location) => !['TEMPORARILY_CLOSED', 'Tạm đóng', 'INACTIVE'].includes(location.status)),
)
const provinces = computed(() =>
  ['all', ...new Set(locations.value.map((location) => location.city).filter(Boolean))],
)
const getProvinceLabel = (province) => (province === 'all' ? t('common.all') : province)
const getStatusLabel = (status) => {
  if (status === 'Đang hoạt động' || status === 'active' || status === 'ACTIVE') return t('locations.active')
  if (status === 'Sắp khai trương' || status === 'comingSoon' || status === 'COMING_SOON') return t('locations.comingSoon')
  if (status === 'MAINTENANCE') return t('locations.maintenance')
  if (status === 'FORMERLY_ACTIVE') return t('locations.formerlyActive')
  return status
}
const isFormerlyActive = (location) => location.status === 'FORMERLY_ACTIVE'

const filteredLocations = computed(() => {
  const keyword = searchKeyword.value.trim().toLowerCase()

  return locations.value.filter((location) => {
    const matchesProvince =
      selectedProvince.value === 'all' || location.city === selectedProvince.value
    const matchesKeyword =
      !keyword ||
      location.name.toLowerCase().includes(keyword) ||
      location.addressText.toLowerCase().includes(keyword)

    return matchesProvince && matchesKeyword
  })
})

const amenityIcons = {
  Wifi,
  'Máy lạnh': Snowflake,
  'Chỗ đậu xe': Car,
  'Thanh toán thẻ': CreditCard,
}

const getAmenityIcon = (amenity) => amenityIcons[amenity] || MapPin
const getOrderLink = (location) =>
  location.links.find((link) => ['ORDER', 'SHOPEEFOOD', 'GRABFOOD', 'DELIVERY'].includes(String(link.type || '').toUpperCase()))

const activeLocationCount = computed(() =>
  locations.value.filter((location) => ['ACTIVE', 'Đang hoạt động'].includes(location.status)).length,
)

const featuredLocationCount = computed(() => locations.value.filter((location) => location.featured).length)

onMounted(() => {
  store.fetchLocations().catch(() => {})
})
</script>

<template>
  <div class="min-h-screen bg-brand-cream pb-20 text-avocado-950">
    <div class="relative overflow-hidden bg-avocado-950 px-4 py-20 text-center text-white sm:px-6 lg:px-8">
      <div class="absolute inset-0">
        <img
          src="/about/aloo-locations-hero.png"
          alt="ALOO kiosk"
          class="h-full w-full object-cover object-center"
        />
      </div>
      <div class="absolute inset-0 bg-black/35"></div>
      <div class="relative mx-auto max-w-3xl space-y-4">
        <span class="inline-block rounded-full border border-white/10 bg-white/5 px-3.5 py-1 text-xs font-bold uppercase tracking-[0.25em] text-cream-300">
          {{ t('locations.eyebrow') }}
        </span>
        <h1 class="mt-3 text-4xl font-black tracking-tight text-white sm:text-5xl">{{ t('locations.title') }}</h1>
        <p class="mx-auto mt-4 max-w-2xl text-base leading-relaxed text-avocado-100 sm:text-lg">
          {{ t('locations.description') }}
        </p>
      </div>
    </div>

    <section class="mx-auto max-w-[1240px] px-4 py-16 sm:px-6 lg:px-8">
      <div class="mx-auto mb-10 grid max-w-4xl gap-3 sm:grid-cols-3">
        <template v-if="store.loading.locations">
          <div v-for="i in 3" :key="i" class="rounded-3xl border border-avocado-100/40 bg-white px-5 py-4 text-center shadow-sm">
            <div class="mx-auto h-8 w-12 animate-pulse rounded bg-slate-100"></div>
            <div class="mx-auto mt-3 h-3 w-24 animate-pulse rounded bg-slate-100"></div>
          </div>
        </template>
        <template v-else>
          <div class="rounded-3xl border border-avocado-100/40 bg-white px-5 py-4 text-center shadow-sm">
            <p class="text-2xl font-black text-avocado-950">{{ locations.length }}</p>
            <p class="mt-1 text-xs font-bold uppercase tracking-wider text-slate-400">{{ t('locations.statsTotal') }}</p>
          </div>
          <div class="rounded-3xl border border-emerald-100 bg-white px-5 py-4 text-center shadow-sm">
            <p class="text-2xl font-black text-emerald-700">{{ activeLocationCount }}</p>
            <p class="mt-1 text-xs font-bold uppercase tracking-wider text-slate-400">{{ t('locations.statsActive') }}</p>
          </div>
          <div class="rounded-3xl border border-cream-200 bg-white px-5 py-4 text-center shadow-sm">
            <p class="text-2xl font-black text-avocado-800">{{ featuredLocationCount }}</p>
            <p class="mt-1 text-xs font-bold uppercase tracking-wider text-slate-400">{{ t('locations.statsFeatured') }}</p>
          </div>
        </template>
      </div>

      <div class="mx-auto mb-12 grid max-w-4xl items-center gap-4 rounded-3xl border border-avocado-100/30 bg-white p-4 shadow-sm md:grid-cols-[1fr_240px]">
        <div class="relative flex-1">
          <Search class="absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400" />
          <input
            v-model="searchKeyword"
            type="search"
            :placeholder="t('locations.searchPlaceholder')"
            class="w-full rounded-2xl border border-slate-100 bg-slate-50/50 py-3 pl-12 pr-4 text-sm outline-none transition focus:border-avocado-500 focus:bg-white"
          />
        </div>
        <select
          v-model="selectedProvince"
          class="w-full rounded-2xl border border-slate-100 bg-slate-50/50 px-4 py-3 text-sm font-semibold text-slate-700 outline-none transition focus:border-avocado-500 focus:bg-white"
        >
          <option v-for="province in provinces" :key="province" :value="province">{{ getProvinceLabel(province) }}</option>
        </select>
      </div>

      <div v-if="store.loading.locations" class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        <article v-for="i in 6" :key="i" class="overflow-hidden rounded-3xl border border-avocado-100/30 bg-white shadow-sm">
          <div class="aspect-[4/3] animate-pulse bg-slate-100"></div>
          <div class="space-y-3 p-6">
            <div class="h-5 w-3/4 animate-pulse rounded bg-slate-100"></div>
            <div class="h-4 w-1/2 animate-pulse rounded bg-slate-100"></div>
            <div class="h-4 w-full animate-pulse rounded bg-slate-100"></div>
            <div class="h-4 w-2/3 animate-pulse rounded bg-slate-100"></div>
          </div>
        </article>
      </div>
      <p v-else-if="store.errors.locations" class="mx-auto max-w-lg rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-center font-bold text-red-700 shadow-sm">
        {{ store.errors.locations }}
      </p>
      <div v-else-if="filteredLocations.length > 0" class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        <article
          v-for="location in filteredLocations"
          :key="location.id"
          class="group flex flex-col justify-between overflow-hidden rounded-3xl border border-avocado-100/30 bg-white shadow-sm hover-lift"
        >
          <div>
            <div class="relative aspect-[4/3] overflow-hidden bg-avocado-50">
              <img
                v-if="location.imageUrl"
                :src="location.imageUrl"
                :alt="location.name"
                class="h-full w-full object-cover transition duration-500 group-hover:scale-105"
              />
              <div v-else class="grid h-full place-items-center text-2xl font-black text-avocado-700">ALOO</div>
              <div class="absolute left-4 top-4 flex flex-wrap gap-2">
                <span
                  class="rounded-full px-3 py-1 text-[10px] font-black tracking-wider shadow-sm"
                  :class="
                    location.status === 'Đang hoạt động' || location.status === 'active' || location.status === 'ACTIVE'
                      ? 'border border-emerald-100/70 bg-emerald-50 text-emerald-700'
                      : location.status === 'FORMERLY_ACTIVE'
                        ? 'border border-violet-100 bg-violet-50 text-violet-700'
                      : 'border border-amber-100/70 bg-amber-50 text-amber-700'
                  "
                >
                  {{ getStatusLabel(location.status) }}
                </span>
                <span v-if="location.featured" class="rounded-full border border-cream-200 bg-cream-100 px-3 py-1 text-[10px] font-black text-avocado-900 shadow-sm">
                  {{ t('locations.featured') }}
                </span>
              </div>
            </div>

            <div class="p-6">
              <div class="mb-5">
                <h3 class="text-lg font-bold leading-snug text-avocado-950">{{ location.name }}</h3>
                <p class="mt-1 inline-flex items-center gap-1 text-xs font-bold uppercase tracking-wider text-avocado-600">
                  <MapPin class="h-3.5 w-3.5" />
                  {{ location.city }}<span v-if="location.district"> · {{ location.district }}</span>
                </p>
              </div>

              <div class="space-y-3.5 border-t border-slate-50 pt-4 text-xs text-slate-500">
                <p class="flex gap-2">
                  <span class="shrink-0 font-bold text-slate-700">{{ t('common.address') }}:</span>
                  <span class="leading-relaxed">{{ location.addressText }}</span>
                </p>
                <p v-if="location.phone && !isFormerlyActive(location)" class="flex items-center gap-2">
                  <Phone class="h-3.5 w-3.5 text-slate-400" />
                  <span class="mr-1 shrink-0 font-bold text-slate-700">{{ t('common.phone') }}:</span>
                  <span>{{ location.phone }}</span>
                </p>
                <p v-if="location.openingHours && !isFormerlyActive(location)" class="flex items-center gap-2">
                  <Clock class="h-3.5 w-3.5 text-slate-400" />
                  <span class="mr-1 shrink-0 font-bold text-slate-700">{{ t('common.openingHours') }}:</span>
                  <span>{{ location.openingHours }}</span>
                </p>
              </div>

              <div v-if="location.amenities.length" class="mt-5 flex flex-wrap gap-2">
                <span
                  v-for="amenity in location.amenities.slice(0, 4)"
                  :key="amenity"
                  class="inline-flex items-center gap-1.5 rounded-full bg-avocado-50 px-3 py-1.5 text-[11px] font-bold text-avocado-800"
                >
                  <component :is="getAmenityIcon(amenity)" class="h-3.5 w-3.5" />
                  {{ amenity }}
                </span>
              </div>
            </div>
          </div>

          <div class="mt-auto border-t border-slate-50 p-5">
            <div class="grid gap-2 sm:grid-cols-2">
              <RouterLink
                v-if="location.slug"
                :to="`/locations/${location.slug}`"
                class="inline-flex items-center justify-center gap-1.5 rounded-full border border-avocado-200 px-4 py-2.5 text-xs font-bold text-avocado-800 transition hover:border-avocado-300 hover:bg-avocado-50/50"
              >
                {{ t('locations.detail') }}
              </RouterLink>
              <a
                v-if="location.mapUrl"
                :href="location.mapUrl"
                target="_blank"
                rel="noreferrer"
                class="inline-flex items-center justify-center gap-1.5 rounded-full border border-avocado-200 px-4 py-2.5 text-xs font-bold text-avocado-800 transition hover:border-avocado-300 hover:bg-avocado-50/50"
              >
                <Compass class="h-4 w-4" />
                {{ t('common.viewMap') }}
              </a>
              <a
                v-if="getOrderLink(location) && !isFormerlyActive(location)"
                :href="getOrderLink(location).url"
                target="_blank"
                rel="noreferrer"
                class="inline-flex items-center justify-center gap-1.5 rounded-full border border-cream-200 bg-cream-100 px-4 py-2.5 text-xs font-bold text-avocado-900 transition hover:bg-cream-200"
              >
                {{ t('locations.order') }}
              </a>
              <a
                v-if="location.phone && !isFormerlyActive(location)"
                :href="`tel:${location.phone}`"
                class="inline-flex items-center justify-center gap-1.5 rounded-full bg-avocado-800 px-4 py-2.5 text-xs font-bold text-white transition hover:bg-avocado-900"
              >
                <Phone class="h-4 w-4" />
                {{ t('locations.callNow') }}
              </a>
            </div>
          </div>
        </article>
      </div>
      <p
        v-else-if="locations.length === 0"
        class="mx-auto max-w-lg rounded-2xl border border-slate-200 bg-white px-5 py-16 text-center font-bold text-slate-400 shadow-sm"
      >
        {{ t('locations.emptyNoData') }}
      </p>
      <p v-else class="mx-auto max-w-lg rounded-2xl border border-slate-200 bg-white px-5 py-16 text-center font-bold text-slate-400 shadow-sm">
        {{ t('locations.emptyNoMatch') }}
      </p>
    </section>
  </div>
</template>
