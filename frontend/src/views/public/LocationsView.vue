<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { useI18n } from 'vue-i18n'
import SectionTitle from '../../components/public/SectionTitle.vue'
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
  store.locations.map(normalizeLocation).filter((location) => !['TEMPORARILY_CLOSED', 'Tạm đóng'].includes(location.status)),
)
const provinces = computed(() => ['all', ...new Set(locations.value.map((location) => location.city))])
const getProvinceLabel = (province) => (province === 'all' ? t('common.all') : province)
const getStatusLabel = (status) => {
  if (status === 'Đang hoạt động' || status === 'active' || status === 'ACTIVE') return t('locations.active')
  if (status === 'Sắp khai trương' || status === 'comingSoon' || status === 'COMING_SOON') return t('locations.comingSoon')
  if (status === 'MAINTENANCE') return 'Đang sửa chữa'
  return status
}

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
  <main class="bg-[#faf8f2] text-avocado-950 pb-20 min-h-screen">
    <!-- Header Hero block -->
    <div class="relative bg-avocado-950 text-white overflow-hidden py-20 px-4 sm:px-6 lg:px-8 text-center">
      <div class="absolute inset-0 opacity-15">
        <img
          src="https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1600&q=80"
          alt="ALOO store map"
          class="h-full w-full object-cover"
        />
      </div>
      <div class="absolute inset-0 bg-gradient-to-b from-transparent to-avocado-950/90"></div>
      <div class="relative max-w-3xl mx-auto space-y-4">
        <span class="inline-block text-xs font-bold uppercase tracking-[0.25em] text-cream-300 bg-white/5 border border-white/10 px-3.5 py-1 rounded-full">
          Hệ thống cửa hàng
        </span>
        <h1 class="text-4xl sm:text-5xl font-black tracking-tight text-white mt-3">Tìm ALOO Gần Nhất</h1>
        <p class="text-base sm:text-lg leading-relaxed text-avocado-100 max-w-2xl mx-auto mt-4">
          Ghé thăm ngay các cửa hàng ALOO trên toàn quốc để thưởng thức ly kem bơ dẻo mịn mát lạnh.
        </p>
      </div>
    </div>

    <!-- Main Section -->
    <section class="max-w-6xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
      <SectionTitle
        :eyebrow="t('locations.eyebrow')"
        :title="t('locations.title')"
        :description="t('locations.description')"
      />

      <div class="mx-auto mb-10 grid max-w-4xl gap-3 sm:grid-cols-3">
        <div class="rounded-3xl border border-avocado-100/40 bg-white px-5 py-4 text-center shadow-sm">
          <p class="text-2xl font-black text-avocado-950">{{ locations.length }}</p>
          <p class="mt-1 text-xs font-bold uppercase tracking-wider text-slate-400">Tổng chi nhánh</p>
        </div>
        <div class="rounded-3xl border border-emerald-100 bg-white px-5 py-4 text-center shadow-sm">
          <p class="text-2xl font-black text-emerald-700">{{ activeLocationCount }}</p>
          <p class="mt-1 text-xs font-bold uppercase tracking-wider text-slate-400">Đang hoạt động</p>
        </div>
        <div class="rounded-3xl border border-cream-200 bg-white px-5 py-4 text-center shadow-sm">
          <p class="text-2xl font-black text-avocado-800">{{ featuredLocationCount }}</p>
          <p class="mt-1 text-xs font-bold uppercase tracking-wider text-slate-400">Nổi bật</p>
        </div>
      </div>

      <!-- Search and Filter Bar -->
      <div class="mx-auto mb-12 grid max-w-4xl gap-4 rounded-3xl border border-avocado-100/30 bg-white p-4 shadow-sm md:grid-cols-[1fr_240px] items-center">
        <div class="relative flex-1">
          <Search class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 h-5 w-5" />
          <input
            v-model="searchKeyword"
            type="search"
            :placeholder="t('locations.searchPlaceholder')"
            class="w-full rounded-2xl border border-slate-100 bg-slate-50/50 pl-12 pr-4 py-3 text-sm outline-none focus:bg-white focus:border-avocado-500 transition"
          />
        </div>
        <select
          v-model="selectedProvince"
          class="w-full rounded-2xl border border-slate-100 bg-slate-50/50 px-4 py-3 text-sm font-semibold text-slate-700 outline-none focus:bg-white focus:border-avocado-500 transition"
        >
          <option v-for="province in provinces" :key="province" :value="province">{{ getProvinceLabel(province) }}</option>
        </select>
      </div>

      <!-- Loading / Errors -->
      <p v-if="store.loading.locations" class="text-center font-bold text-slate-400 py-16">
        Đang tải hệ thống cửa hàng...
      </p>
      <p v-else-if="store.errors.locations" class="rounded-2xl bg-red-50 border border-red-200 px-5 py-4 text-center font-bold text-red-700 max-w-lg mx-auto shadow-sm">
        {{ store.errors.locations }}
      </p>
      
      <!-- Locations Grid -->
      <div v-else-if="filteredLocations.length > 0" class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
        <article
          v-for="location in filteredLocations"
          :key="location.id"
          class="group overflow-hidden rounded-3xl border border-avocado-100/30 bg-white shadow-sm hover-lift flex flex-col justify-between"
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
                      ? 'bg-emerald-50 text-emerald-700 border border-emerald-100/70'
                      : 'bg-amber-50 text-amber-700 border border-amber-100/70'
                  "
                >
                  {{ getStatusLabel(location.status) }}
                </span>
                <span v-if="location.featured" class="rounded-full border border-cream-200 bg-cream-100 px-3 py-1 text-[10px] font-black text-avocado-900 shadow-sm">
                  Nổi bật
                </span>
              </div>
            </div>

            <div class="p-6">
              <div class="mb-5">
                <h3 class="text-lg font-bold text-avocado-950 leading-snug">{{ location.name }}</h3>
                <p class="mt-1 text-xs font-bold text-avocado-600 tracking-wider uppercase inline-flex items-center gap-1">
                  <MapPin class="h-3.5 w-3.5" />
                  {{ location.city }}<span v-if="location.district"> · {{ location.district }}</span>
                </p>
              </div>

              <div class="space-y-3.5 text-xs text-slate-500 border-t border-slate-50 pt-4">
                <p class="flex gap-2">
                  <span class="font-bold text-slate-700 shrink-0">{{ t('common.address') }}:</span>
                  <span class="leading-relaxed">{{ location.addressText }}</span>
                </p>
                <p class="flex items-center gap-2">
                  <Phone class="h-3.5 w-3.5 text-slate-400" />
                  <span class="font-bold text-slate-700 shrink-0 mr-1">{{ t('common.phone') }}:</span>
                  <span>{{ location.phone }}</span>
                </p>
                <p class="flex items-center gap-2">
                  <Clock class="h-3.5 w-3.5 text-slate-400" />
                  <span class="font-bold text-slate-700 shrink-0 mr-1">{{ t('common.openingHours') }}:</span>
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
                class="inline-flex justify-center items-center gap-1.5 rounded-full border border-avocado-200 hover:border-avocado-300 hover:bg-avocado-50/50 px-4 py-2.5 text-xs font-bold text-avocado-800 transition"
              >
                Chi tiết
              </RouterLink>
              <a
                v-if="location.mapUrl"
                :href="location.mapUrl"
                target="_blank"
                rel="noreferrer"
                class="inline-flex justify-center items-center gap-1.5 rounded-full border border-avocado-200 hover:border-avocado-300 hover:bg-avocado-50/50 px-4 py-2.5 text-xs font-bold text-avocado-800 transition"
              >
                <Compass class="h-4 w-4" />
                {{ t('common.viewMap') }}
              </a>
              <a
                v-if="getOrderLink(location)"
                :href="getOrderLink(location).url"
                target="_blank"
                rel="noreferrer"
                class="inline-flex justify-center items-center gap-1.5 rounded-full border border-cream-200 bg-cream-100 px-4 py-2.5 text-xs font-bold text-avocado-900 transition hover:bg-cream-200"
              >
                Đặt món
              </a>
              <a
                v-if="location.phone"
                :href="`tel:${location.phone}`"
                class="inline-flex justify-center items-center gap-1.5 rounded-full bg-avocado-800 px-4 py-2.5 text-xs font-bold text-white transition hover:bg-avocado-900"
              >
                <Phone class="h-4 w-4" />
                Gọi ngay
              </a>
            </div>
          </div>
        </article>
      </div>

      <p v-else class="rounded-2xl border border-slate-200 bg-white px-5 py-16 text-center font-bold text-slate-400 max-w-lg mx-auto shadow-sm">
        Không tìm thấy cửa hàng nào khớp với tìm kiếm.
      </p>
    </section>
  </main>
</template>
