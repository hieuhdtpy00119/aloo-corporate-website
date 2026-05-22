<script setup>
import { computed, onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import SectionTitle from '../../components/public/SectionTitle.vue'
import { useAppStore } from '../../stores/appStore'
import { MapPin, Search, Phone, Clock, Compass } from 'lucide-vue-next'

const { t } = useI18n()
const store = useAppStore()
const searchKeyword = ref('')
const selectedProvince = ref('all')

const normalizeLocation = (location) => ({
  ...location,
  addressText: location.addressText || location.address || '',
  city: location.city || location.province || '',
  imageUrl: location.imageUrl || '',
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
          class="rounded-3xl border border-avocado-100/30 bg-white p-6 shadow-sm hover-lift flex flex-col justify-between"
        >
          <div>
            <div class="flex items-start justify-between gap-4 mb-5">
              <div>
                <h3 class="text-lg font-bold text-avocado-950 leading-snug">{{ location.name }}</h3>
                <p class="mt-1 text-xs font-bold text-avocado-600 tracking-wider uppercase inline-flex items-center gap-1">
                  <MapPin class="h-3.5 w-3.5" />
                  {{ location.city }}
                </p>
              </div>
              <span
                class="rounded-full px-3 py-1 text-[10px] font-bold tracking-wider uppercase inline-block shadow-inner"
                :class="
                  location.status === 'Đang hoạt động' || location.status === 'active' || location.status === 'ACTIVE'
                    ? 'bg-emerald-50 text-emerald-700 border border-emerald-100/50'
                    : 'bg-amber-50 text-amber-700 border border-amber-100/50'
                "
              >
                {{ getStatusLabel(location.status) }}
              </span>
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
          </div>

          <div class="mt-6 border-t border-slate-50 pt-4">
            <a
              :href="location.mapUrl"
              target="_blank"
              rel="noreferrer"
              class="w-full text-center inline-flex justify-center items-center gap-1.5 rounded-full border border-avocado-200 hover:border-avocado-300 hover:bg-avocado-50/50 px-4 py-2.5 text-xs font-bold text-avocado-800 transition"
            >
              <Compass class="h-4 w-4" />
              {{ t('common.viewMap') }}
            </a>
          </div>
        </article>
      </div>

      <p v-else class="rounded-2xl border border-slate-200 bg-white px-5 py-16 text-center font-bold text-slate-400 max-w-lg mx-auto shadow-sm">
        Không tìm thấy cửa hàng nào khớp với tìm kiếm.
      </p>
    </section>
  </main>
</template>

