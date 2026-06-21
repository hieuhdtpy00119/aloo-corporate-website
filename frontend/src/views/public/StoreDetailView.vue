<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { Clock, Compass, MapPin, Phone } from 'lucide-vue-next'
import { locationService, resolveBackendAssetUrl } from '../../services/cmsService'
import { setSeoMeta } from '../../services/seoService'
import { trackEvent } from '../../services/analyticsService'

const route = useRoute()
const store = ref(null)
const loading = ref(false)
const errorMessage = ref('')

const normalizedStore = computed(() => {
  if (!store.value) return null
  const links = Array.isArray(store.value.links) ? store.value.links : []
  return {
    ...store.value,
    imageUrl: resolveBackendAssetUrl(store.value.coverImageUrl || store.value.imageUrl || ''),
    addressText: store.value.addressText || store.value.address || '',
    city: store.value.city || store.value.province || '',
    amenities: Array.isArray(store.value.amenities) ? store.value.amenities : [],
    links,
    mapUrl: store.value.mapUrl || links.find((link) => link.type === 'GOOGLE_MAPS')?.url || '',
  }
})

const statusLabel = (status) => {
  if (status === 'ACTIVE') return 'Đang hoạt động'
  if (status === 'COMING_SOON') return 'Sắp khai trương'
  if (status === 'TEMPORARILY_CLOSED') return 'Tạm nghỉ'
  if (status === 'MAINTENANCE') return 'Đang sửa chữa'
  return status || 'Đang cập nhật'
}

onMounted(async () => {
  loading.value = true
  errorMessage.value = ''
  try {
    const { data } = await locationService.getBySlug(route.params.slug)
    store.value = data
    setSeoMeta({
      title: `${data.name} | Hệ thống cửa hàng ALOO`,
      description: data.description || `${data.address || ''} - hotline ${data.phone || 'ALOO'}`,
      image: resolveBackendAssetUrl(data.coverImageUrl || data.imageUrl || '/logo-aloo.png'),
      url: window.location.href,
    })
  } catch (error) {
    errorMessage.value = error.response?.data?.message || 'Không tải được thông tin cửa hàng'
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="min-h-screen bg-brand-cream px-4 py-14 text-avocado-950 sm:px-6 lg:px-8">
    <div class="mx-auto max-w-[1240px]">
      <RouterLink to="/locations" class="text-sm font-black text-avocado-700 hover:text-avocado-950">
        ← Quay lại hệ thống cửa hàng
      </RouterLink>

      <p v-if="loading" class="py-20 text-center font-bold text-slate-400">Đang tải cửa hàng...</p>
      <p v-else-if="errorMessage" class="mt-8 rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-center font-bold text-red-700">
        {{ errorMessage }}
      </p>

      <article v-else-if="normalizedStore" class="mt-8 overflow-hidden rounded-[32px] border border-avocado-100/40 bg-white shadow-xl shadow-avocado-950/5">
        <div class="relative aspect-[16/7] bg-avocado-50">
          <img v-if="normalizedStore.imageUrl" :src="normalizedStore.imageUrl" :alt="normalizedStore.name" class="h-full w-full object-cover" />
          <div v-else class="grid h-full place-items-center text-4xl font-black text-avocado-700">ALOO</div>
          <div class="absolute left-6 top-6 rounded-full bg-white/92 px-4 py-2 text-xs font-black text-avocado-800 shadow-sm">
            {{ statusLabel(normalizedStore.status) }}
          </div>
        </div>

        <div class="grid gap-8 p-6 lg:grid-cols-[minmax(0,1fr)_280px] lg:p-8">
          <section>
            <p class="text-xs font-black uppercase tracking-[0.22em] text-cream-500">{{ normalizedStore.storeCode }}</p>
            <h1 class="mt-2 text-3xl font-black leading-tight text-avocado-950 sm:text-4xl">{{ normalizedStore.name }}</h1>
            <p v-if="normalizedStore.description" class="mt-4 max-w-2xl leading-7 text-slate-600">{{ normalizedStore.description }}</p>

            <div class="mt-7 space-y-4 rounded-3xl bg-avocado-50/40 p-5 text-sm text-slate-600">
              <p class="flex gap-3">
                <MapPin class="mt-0.5 h-4 w-4 shrink-0 text-avocado-700" />
                <span>{{ normalizedStore.addressText }}</span>
              </p>
              <p class="flex gap-3">
                <Clock class="mt-0.5 h-4 w-4 shrink-0 text-avocado-700" />
                <span>{{ normalizedStore.openingHours || 'Đang cập nhật' }}</span>
              </p>
              <p v-if="normalizedStore.phone" class="flex gap-3">
                <Phone class="mt-0.5 h-4 w-4 shrink-0 text-avocado-700" />
                <span>{{ normalizedStore.phone }}</span>
              </p>
            </div>

            <div v-if="normalizedStore.amenities.length" class="mt-6 flex flex-wrap gap-2">
              <span v-for="amenity in normalizedStore.amenities" :key="amenity" class="rounded-full bg-avocado-50 px-3 py-1.5 text-xs font-bold text-avocado-800">
                {{ amenity }}
              </span>
            </div>
          </section>

          <aside class="grid content-start gap-3">
            <a v-if="normalizedStore.mapUrl" :href="normalizedStore.mapUrl" target="_blank" rel="noreferrer" class="inline-flex justify-center gap-2 rounded-full bg-avocado-800 px-5 py-3 text-sm font-black text-white hover:bg-avocado-950" @click="trackEvent('click_google_maps', { store: normalizedStore.name })">
              <Compass class="h-4 w-4" />
              Xem bản đồ
            </a>
            <a v-if="normalizedStore.phone" :href="`tel:${normalizedStore.phone}`" class="inline-flex justify-center gap-2 rounded-full border border-avocado-200 px-5 py-3 text-sm font-black text-avocado-800 hover:bg-avocado-50" @click="trackEvent('click_hotline', { store: normalizedStore.name })">
              <Phone class="h-4 w-4" />
              Gọi điện
            </a>
          </aside>
        </div>
      </article>
    </div>
  </div>
</template>
