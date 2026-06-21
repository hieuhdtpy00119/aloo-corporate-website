<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { Car, CreditCard, Eye, MapPin, Phone, Snowflake, Wifi } from 'lucide-vue-next'
import BaseModal from '../../components/admin/BaseModal.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import { uploadService } from '../../services/cmsService'
import { useAdminModuleI18n } from '../../composables/useAdminModuleI18n'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'

const { m, t } = useAdminModuleI18n('locations')
const store = useAppStore()
const toast = useToastStore()

const FEATURED_FILTER_ALL = 'ALL'
const FEATURED_FILTER_FEATURED = 'FEATURED'
const FEATURED_FILTER_NOT_FEATURED = 'NOT_FEATURED'

const showModal = ref(false)
const mode = ref('create')
const editingId = ref(null)
const pendingDeleteId = ref(null)
const previewLocation = ref(null)
const searchQuery = ref('')
const statusFilter = ref(t('admin.shared.all'))
const cityFilter = ref(t('admin.shared.all'))
const featuredFilter = ref(FEATURED_FILTER_ALL)
const isLoading = computed(() => store.loading.locations)
const errorMessage = computed(() => store.errors.locations)
const currentPage = ref(1)
const pageSize = 5
const formErrors = ref({})
const imagePreviewError = ref(false)
const isUploadingImage = ref(false)

const statusOptions = ['ACTIVE', 'COMING_SOON', 'TEMPORARILY_CLOSED', 'MAINTENANCE', 'INACTIVE']
const storeTypeOptions = ['FLAGSHIP', 'STANDARD', 'KIOSK', 'FRANCHISE', 'POPUP']
const amenityDefinitions = [
  { key: 'wifi', value: 'Wifi' },
  { key: 'ac', value: 'Máy lạnh' },
  { key: 'parking', value: 'Chỗ đậu xe' },
  { key: 'card', value: 'Thanh toán thẻ' },
  { key: 'takeaway', value: 'Mang đi' },
]
const amenityOptions = computed(() =>
  amenityDefinitions.map(({ key, value }) => ({
    key,
    value,
    label: m(`amenities.${key}`),
  })),
)

const storeTypeLabels = computed(() => ({
  FLAGSHIP: m('storeTypes.FLAGSHIP'),
  STANDARD: m('storeTypes.STANDARD'),
  KIOSK: m('storeTypes.KIOSK'),
  FRANCHISE: m('storeTypes.FRANCHISE'),
  POPUP: m('storeTypes.POPUP'),
}))

const defaultLinkTitle = () => m('defaults.linkTitle')

const featuredFilterOptions = computed(() => [
  { value: FEATURED_FILTER_ALL, label: t('admin.shared.all') },
  { value: FEATURED_FILTER_FEATURED, label: m('filters.featuredYes') },
  { value: FEATURED_FILTER_NOT_FEATURED, label: m('filters.featuredNo') },
])

const statusLabels = computed(() => ({
  ACTIVE: m('status.ACTIVE'),
  COMING_SOON: m('status.COMING_SOON'),
  TEMPORARILY_CLOSED: m('status.TEMPORARILY_CLOSED'),
  MAINTENANCE: m('status.MAINTENANCE'),
  INACTIVE: m('status.INACTIVE'),
}))

const amenityLabel = (value) => {
  const match = amenityDefinitions.find((item) => item.value === value)
  return match ? m(`amenities.${match.key}`) : value
}

const handleImageFile = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  isUploadingImage.value = true
  try {
    const { data } = await uploadService.image(file)
    form.coverImageUrl = data.url
    form.imageUrl = data.url
    imagePreviewError.value = false
    toast.success(m('toasts.imageUploaded'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.imageError'))
  } finally {
    isUploadingImage.value = false
    event.target.value = ''
  }
}

const getVisibleAmenities = (amenities) => amenities.slice(0, 3)

const getHiddenAmenityCount = (amenities) => Math.max(0, amenities.length - 3)

const amenityIcons = {
  Wifi,
  'Máy lạnh': Snowflake,
  'Chỗ đậu xe': Car,
  'Thanh toán thẻ': CreditCard,
  'Mang đi': MapPin,
}

const parseJsonArray = (value) => {
  try {
    const parsed = JSON.parse(value || '[]')
    return Array.isArray(parsed) ? parsed : []
  } catch {
    return []
  }
}

const jsonArrayToLines = (value) =>
  parseJsonArray(value)
    .filter((item) => typeof item === 'string' && item.trim())
    .join('\n')

const linesToJsonArray = (value) =>
  JSON.stringify(
    String(value || '')
      .split(/\r?\n/)
      .map((item) => item.trim())
      .filter(Boolean),
  )

const getPrimaryLink = (location) => {
  const links = Array.isArray(location.links) ? location.links : parseJsonArray(location.linksJson)
  return links.find((link) => link?.url) || {}
}

const form = reactive({
  storeCode: '',
  name: '',
  slug: '',
  addressText: '',
  mapUrl: '',
  phone: '',
  email: '',
  openingHours: '',
  storeType: 'STANDARD',
  description: '',
  coverImageUrl: '',
  imageUrl: '',
  city: '',
  district: '',
  ward: '',
  latitude: null,
  longitude: null,
  amenities: [],
  galleryText: '',
  menuPostersText: '',
  linkTitle: defaultLinkTitle(),
  linkUrl: '',
  displayOrder: 1,
  featured: false,
  status: 'ACTIVE',
})

const normalizeLocation = (location) => {
  const primaryLink = getPrimaryLink(location)
  const mapUrl = location.mapUrl || primaryLink.url || ''

  return {
    ...location,
    storeCode: location.storeCode || '',
    name: location.name || '',
    slug: location.slug || '',
    addressText: location.addressText || location.address || '',
    mapUrl,
    phone: location.phone || '',
    email: location.email || '',
    openingHours: location.openingHours || '',
    storeType: location.storeType || 'STANDARD',
    description: location.description || '',
    city: location.city || location.province || '',
    district: location.district || '',
    ward: location.ward || '',
    latitude: location.latitude ?? null,
    longitude: location.longitude ?? null,
    coverImageUrl: location.coverImageUrl || location.imageUrl || '',
    imageUrl:
      location.coverImageUrl ||
      location.imageUrl ||
      'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=900&q=80',
    amenities: Array.isArray(location.amenities) ? location.amenities : ['Wifi', 'Mang đi'],
    galleryText: jsonArrayToLines(location.galleryJson),
    menuPostersText: jsonArrayToLines(location.menuPostersJson),
    linkTitle: primaryLink.title || defaultLinkTitle(),
    linkUrl: primaryLink.url || mapUrl,
    displayOrder: Number(location.displayOrder || location.id || 1),
    featured: Boolean(location.featured),
    status:
      location.status === 'Đang hoạt động'
        ? 'ACTIVE'
        : location.status === 'Sắp khai trương'
          ? 'COMING_SOON'
          : location.status || 'ACTIVE',
  }
}

const normalizedLocations = computed(() => store.locations.map(normalizeLocation))

const statusClass = (status) => ({
  'bg-green-50 text-green-700 border-green-200': status === 'ACTIVE' || status === 'Đang hoạt động',
  'bg-amber-50 text-amber-700 border-amber-200': status === 'COMING_SOON' || status === 'Sắp khai trương',
  'bg-gray-50 text-gray-700 border-gray-200': status === 'TEMPORARILY_CLOSED',
  'bg-orange-50 text-orange-700 border-orange-200': status === 'MAINTENANCE',
})

const cityFilters = computed(() => [t('admin.shared.all'), ...new Set(normalizedLocations.value.map((item) => item.city).filter(Boolean))])
const statusFilters = computed(() => [t('admin.shared.all'), ...statusOptions.map((status) => statusLabels.value[status])])

const resetForm = () => {
  Object.assign(form, {
    storeCode: '',
    name: '',
    slug: '',
    addressText: '',
    mapUrl: '',
    phone: '',
    email: '',
    openingHours: '',
    storeType: 'STANDARD',
    description: '',
    coverImageUrl: '',
    imageUrl: '',
    city: '',
    district: '',
    ward: '',
    latitude: null,
    longitude: null,
    amenities: [],
    galleryText: '',
    menuPostersText: '',
    linkTitle: defaultLinkTitle(),
    linkUrl: '',
    displayOrder: 1,
    featured: false,
    status: 'ACTIVE',
  })
  formErrors.value = {}
  editingId.value = null
}

const openCreateModal = () => {
  mode.value = 'create'
  resetForm()
  imagePreviewError.value = false
  showModal.value = true
}

const openEditModal = (location) => {
  mode.value = 'edit'
  editingId.value = location.id
  Object.assign(form, normalizeLocation(location))
  formErrors.value = {}
  imagePreviewError.value = false
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const isValidUrl = (value) => {
  if (!value) return true
  try {
    const url = new URL(value)
    return ['http:', 'https:'].includes(url.protocol)
  } catch {
    return false
  }
}

const validateForm = () => {
  const errors = {}

  if (!form.storeCode.trim()) errors.storeCode = m('validation.storeCode')
  if (!form.name.trim()) errors.name = m('validation.name')
  if (!form.slug.trim()) errors.slug = m('validation.slug')
  if (!form.addressText.trim()) errors.addressText = m('validation.addressText')
  if (!form.city.trim()) errors.city = m('validation.city')
  if (form.phone.trim().length > 80) errors.phone = m('validation.phone')
  if (form.mapUrl && !isValidUrl(form.mapUrl)) errors.mapUrl = m('validation.mapUrl')
  if (form.linkUrl && !isValidUrl(form.linkUrl)) errors.linkUrl = m('validation.linkUrl')
  linesToJsonArray(form.galleryText)
  JSON.parse(linesToJsonArray(form.galleryText)).forEach((url) => {
    if (!isValidUrl(url)) errors.galleryText = m('validation.galleryText')
  })
  JSON.parse(linesToJsonArray(form.menuPostersText)).forEach((url) => {
    if (!isValidUrl(url)) errors.menuPostersText = m('validation.menuPostersText')
  })
  if (form.status === 'ACTIVE' && !form.openingHours?.trim()) errors.openingHours = m('validation.openingHours')
  if (Number.isNaN(Number(form.displayOrder))) errors.displayOrder = m('validation.displayOrder')

  formErrors.value = errors
  return Object.keys(errors).length === 0
}

const buildLinksJson = () => {
  const url = (form.linkUrl || form.mapUrl || '').trim()
  if (!url) return '[]'

  return JSON.stringify([
    {
      type: 'GOOGLE_MAPS',
      title: (form.linkTitle || defaultLinkTitle()).trim(),
      url,
    },
  ])
}

const buildPayload = () => ({
  id: editingId.value,
  storeCode: form.storeCode.trim(),
  name: form.name.trim(),
  slug: form.slug.trim(),
  addressText: form.addressText.trim(),
  address: form.addressText.trim(),
  mapUrl: form.mapUrl.trim(),
  phone: form.phone.trim(),
  email: form.email.trim(),
  openingHours: form.openingHours.trim(),
  storeType: form.storeType,
  description: form.description.trim(),
  coverImageUrl: (form.coverImageUrl || form.imageUrl).trim(),
  imageUrl: (form.coverImageUrl || form.imageUrl).trim(),
  city: form.city.trim(),
  province: form.city.trim(),
  district: form.district.trim(),
  ward: form.ward.trim(),
  latitude: form.latitude || null,
  longitude: form.longitude || null,
  amenities: [...form.amenities],
  galleryJson: linesToJsonArray(form.galleryText),
  amenitiesJson: JSON.stringify(form.amenities),
  menuPostersJson: linesToJsonArray(form.menuPostersText),
  linksJson: buildLinksJson(),
  displayOrder: Number(form.displayOrder) || 1,
  featured: form.featured,
  status: form.status,
})

const saveLocation = async () => {
  if (!validateForm()) return
  const payload = buildPayload()

  try {
    await store.saveLocation(payload)
    toast.success(mode.value === 'create' ? m('toasts.created') : m('toasts.updated'))
    closeModal()
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.saveError'))
  }
}

const confirmDeleteLocation = async () => {
  try {
    await store.deleteLocation(pendingDeleteId.value)
    toast.success(m('toasts.deleted'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.deleteError'))
  } finally {
    pendingDeleteId.value = null
  }
}

const getStatusValueFromLabel = (label) =>
  Object.entries(statusLabels.value).find(([, value]) => value === label)?.[0] || label

const filteredLocations = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return normalizedLocations.value
    .filter((location) => {
      const matchesSearch =
        !keyword ||
        location.name.toLowerCase().includes(keyword) ||
        location.addressText.toLowerCase().includes(keyword) ||
        location.city.toLowerCase().includes(keyword) ||
        location.district.toLowerCase().includes(keyword)
      const matchesCity = cityFilter.value === t('admin.shared.all') || location.city === cityFilter.value
      const matchesStatus =
        statusFilter.value === t('admin.shared.all') || location.status === getStatusValueFromLabel(statusFilter.value)
      const matchesFeatured =
        featuredFilter.value === FEATURED_FILTER_ALL ||
        (featuredFilter.value === FEATURED_FILTER_FEATURED && location.featured) ||
        (featuredFilter.value === FEATURED_FILTER_NOT_FEATURED && !location.featured)
      return matchesSearch && matchesCity && matchesStatus && matchesFeatured
    })
    .sort((a, b) => a.displayOrder - b.displayOrder)
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredLocations.value.length / pageSize)))
const paginatedLocations = computed(() =>
  filteredLocations.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)

watch([searchQuery, statusFilter, cityFilter, featuredFilter], () => {
  currentPage.value = 1
})

onMounted(() => {
  store.fetchLocations().catch(() => {
    toast.error(m('toasts.loadError'))
  })
})
</script>

<template>
  <section>
    <AdminPageHeader :eyebrow="m('eyebrow')" :title="m('title')" :description="m('description')">
      <template #actions>
        <button class="aloo-btn aloo-btn--primary" @click="openCreateModal">
          {{ m('add') }}
        </button>
      </template>
    </AdminPageHeader>

    <p v-if="errorMessage" class="rounded-lg bg-red-50 px-4 py-3 text-sm font-bold text-red-700">
      {{ errorMessage }}
    </p>

    <div class="aloo-admin-toolbar lg:!grid-cols-[1fr_180px_210px_170px]">
      <label class="aloo-field">
        <span class="aloo-label">{{ m('filters.searchLabel') }}</span>
        <input
          v-model="searchQuery"
          type="search"
          :placeholder="m('filters.searchPlaceholder')"
          class="aloo-input"
        />
      </label>
      <label class="aloo-field">
        <span class="aloo-label">{{ m('filters.cityLabel') }}</span>
        <select v-model="cityFilter" class="aloo-select">
          <option v-for="city in cityFilters" :key="city" :value="city">{{ city }}</option>
        </select>
      </label>
      <label class="aloo-field">
        <span class="aloo-label">{{ m('filters.statusLabel') }}</span>
        <select v-model="statusFilter" class="aloo-select">
          <option v-for="status in statusFilters" :key="status" :value="status">{{ status }}</option>
        </select>
      </label>
      <label class="aloo-field">
        <span class="aloo-label">{{ m('filters.featuredLabel') }}</span>
        <select v-model="featuredFilter" class="aloo-select">
          <option v-for="option in featuredFilterOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
        </select>
      </label>
    </div>

    <div class="hidden overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm lg:block">
      <EmptyState v-if="isLoading || filteredLocations.length === 0" :loading="isLoading" :message="m('empty')" />
      <div class="overflow-x-auto xl:overflow-x-visible">
        <table v-if="!isLoading && filteredLocations.length > 0" class="w-full min-w-[1080px] table-fixed whitespace-nowrap text-left xl:min-w-0">
          <colgroup>
            <col class="w-[6%]" />
            <col class="w-[19%]" />
            <col class="w-[22%]" />
            <col class="w-[10%]" />
            <col class="w-[10%]" />
            <col class="w-[14%]" />
            <col class="w-[19%]" />
          </colgroup>
          <thead class="bg-slate-50 text-xs font-black uppercase tracking-wide text-slate-500">
            <tr>
              <th class="px-3 py-3 text-center">{{ m('columns.image') }}</th>
              <th class="px-4 py-3 text-left">{{ m('columns.name') }}</th>
              <th class="px-4 py-3 text-left">{{ m('columns.address') }}</th>
              <th class="px-3 py-3 text-center">{{ m('columns.hours') }}</th>
              <th class="px-3 py-3 text-center">{{ m('columns.phone') }}</th>
              <th class="px-5 py-3 text-center">{{ m('columns.status') }}</th>
              <th class="py-3 pl-7 pr-4 text-left">{{ m('columns.actions') }}</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100 text-sm">
            <tr v-for="location in paginatedLocations" :key="location.id" class="align-middle transition hover:bg-slate-50/70">
              <td class="px-3 py-4 text-center">
                <img :src="location.imageUrl" :alt="location.name" class="mx-auto h-12 w-14 rounded-lg object-cover shadow-sm" />
              </td>
              <td class="px-4 py-4">
                <div class="space-y-1">
                  <h3 class="truncate font-black leading-5 text-avocado-950">{{ location.name }}</h3>
                  <div class="flex flex-wrap items-center gap-1.5 text-xs font-bold">
                    <span class="text-avocado-700">{{ location.city }} · {{ location.district }}</span>
                    <span class="rounded-full bg-slate-100 px-2 py-0.5 text-slate-500">#{{ location.displayOrder }}</span>
                  </div>
                  <span v-if="location.featured" class="inline-flex rounded-full bg-cream-100 px-2 py-0.5 text-xs font-black text-avocado-900">{{ m('featuredBadge') }}</span>
                </div>
              </td>
              <td class="px-4 py-4">
                <p class="truncate leading-5 text-slate-700">{{ location.addressText }}</p>
                <a :href="location.mapUrl" target="_blank" rel="noreferrer" class="mt-2 inline-flex items-center gap-1 text-xs font-black text-avocado-700 hover:text-avocado-900">
                  <MapPin class="h-3.5 w-3.5" /> {{ m('actions.viewMap') }}
                </a>
              </td>
              <td class="truncate px-3 py-4 text-center text-sm font-bold leading-5 text-slate-700">{{ location.openingHours || '-' }}</td>
              <td class="truncate px-3 py-4 text-center text-sm font-bold leading-5 text-slate-700">{{ location.phone }}</td>
              <td class="px-5 py-4 text-center">
                <span class="inline-flex min-w-[126px] justify-center whitespace-nowrap rounded-full border px-3 py-1.5 text-xs font-black leading-4" :class="statusClass(location.status)">
                  {{ statusLabels[location.status] || location.status }}
                </span>
              </td>
              <td class="py-4 pl-7 pr-4 text-left">
                <div class="inline-flex items-center justify-start gap-2.5 whitespace-nowrap">
                  <button class="rounded-lg border border-slate-200 px-2.5 py-2 text-xs font-bold text-slate-700 hover:bg-slate-50" @click="previewLocation = location">{{ m('actions.view') }}</button>
                  <button class="rounded-lg border border-avocado-200 px-2.5 py-2 text-xs font-bold text-avocado-700 hover:bg-avocado-50" @click="openEditModal(location)">{{ m('actions.edit') }}</button>
                  <button class="rounded-lg border border-red-200 px-2.5 py-2 text-xs font-bold text-red-600 hover:bg-red-50" @click="pendingDeleteId = location.id">{{ m('actions.delete') }}</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div class="grid gap-4 lg:hidden">
      <div v-if="isLoading" class="grid gap-3">
        <div v-for="i in 3" :key="i" class="h-28 animate-pulse rounded-2xl bg-slate-100" />
      </div>
      <EmptyState v-else-if="!filteredLocations.length" :message="m('empty')" />
      <article v-for="location in paginatedLocations" :key="location.id" class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
        <img :src="location.imageUrl" :alt="location.name" class="h-44 w-full object-cover" />
        <div class="p-5">
          <div class="flex items-start justify-between gap-3">
            <div>
              <h3 class="text-lg font-black text-avocado-950">{{ location.name }}</h3>
              <p class="mt-1 text-sm font-bold text-avocado-700">{{ location.city }} · {{ location.district }}</p>
            </div>
            <span class="shrink-0 whitespace-nowrap rounded-full border px-3 py-1 text-xs font-black" :class="statusClass(location.status)">
              {{ statusLabels[location.status] }}
            </span>
          </div>
          <p class="mt-4 leading-6 text-slate-600">{{ location.addressText }}</p>
          <div class="mt-4 flex flex-wrap gap-2">
            <span v-for="amenity in location.amenities.slice(0, 3)" :key="amenity" class="rounded-full bg-avocado-50 px-3 py-1 text-xs font-bold text-avocado-700">{{ amenityLabel(amenity) }}</span>
          </div>
          <div class="mt-5 flex flex-wrap justify-end gap-2">
            <button class="rounded-lg border border-slate-200 px-3 py-2 font-bold text-slate-700" @click="previewLocation = location">{{ m('preview') }}</button>
            <button class="rounded-lg border border-avocado-200 px-3 py-2 font-bold text-avocado-700" @click="openEditModal(location)">{{ m('actions.edit') }}</button>
            <button class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600" @click="pendingDeleteId = location.id">{{ m('actions.delete') }}</button>
          </div>
        </div>
      </article>
    </div>

    <Pagination :page="currentPage" :total-pages="totalPages" :visible-count="paginatedLocations.length" :total-count="filteredLocations.length" :label="m('paginationLabel')" @prev="currentPage = Math.max(1, currentPage - 1)" @next="currentPage = Math.min(totalPages, currentPage + 1)" />

    <BaseModal :show="showModal" :title="mode === 'create' ? m('create') : m('edit')" max-width="max-w-5xl" @close="closeModal">
      <form id="location-form" class="grid gap-6" @submit.prevent="saveLocation">
        <section class="grid gap-4 rounded-2xl bg-slate-50 p-5 md:grid-cols-2">
          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">{{ m('sections.basic') }}</h3>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.storeCode') }}
            <input v-model="form.storeCode" class="admin-input" :placeholder="m('placeholders.storeCode')" />
            <span v-if="formErrors.storeCode" class="text-xs font-bold text-red-600">{{ formErrors.storeCode }}</span>
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.name') }}
            <input v-model="form.name" class="admin-input" />
            <span v-if="formErrors.name" class="text-xs font-bold text-red-600">{{ formErrors.name }}</span>
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.slug') }}
            <input v-model="form.slug" class="admin-input" :placeholder="m('placeholders.slug')" />
            <span v-if="formErrors.slug" class="text-xs font-bold text-red-600">{{ formErrors.slug }}</span>
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.phone') }}
            <input v-model="form.phone" class="admin-input" />
            <span v-if="formErrors.phone" class="text-xs font-bold text-red-600">{{ formErrors.phone }}</span>
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.email') }}
            <input v-model="form.email" class="admin-input" />
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            {{ m('fields.addressText') }}
            <input v-model="form.addressText" class="admin-input" />
            <span v-if="formErrors.addressText" class="text-xs font-bold text-red-600">{{ formErrors.addressText }}</span>
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.openingHours') }}
            <input v-model="form.openingHours" class="admin-input" :placeholder="m('placeholders.openingHours')" />
            <span v-if="formErrors.openingHours" class="text-xs font-bold text-red-600">{{ formErrors.openingHours }}</span>
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.storeType') }}
            <select v-model="form.storeType" class="admin-input">
              <option v-for="type in storeTypeOptions" :key="type" :value="type">{{ storeTypeLabels[type] }}</option>
            </select>
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            {{ m('fields.description') }}
            <textarea v-model="form.description" rows="3" class="admin-input"></textarea>
          </label>
        </section>

        <section class="grid gap-4 rounded-2xl bg-slate-50 p-5 md:grid-cols-2">
          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">{{ m('sections.map') }}</h3>
          <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            {{ m('fields.mapUrl') }}
            <input v-model="form.mapUrl" class="admin-input" />
            <span v-if="formErrors.mapUrl" class="text-xs font-bold text-red-600">{{ formErrors.mapUrl }}</span>
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.city') }}
            <input v-model="form.city" class="admin-input" />
            <span v-if="formErrors.city" class="text-xs font-bold text-red-600">{{ formErrors.city }}</span>
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.district') }}
            <input v-model="form.district" class="admin-input" />
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.ward') }}
            <input v-model="form.ward" class="admin-input" />
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.latitude') }}
            <input v-model.number="form.latitude" type="number" step="0.0000001" class="admin-input" />
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.longitude') }}
            <input v-model.number="form.longitude" type="number" step="0.0000001" class="admin-input" />
          </label>
        </section>

        <section class="grid gap-4 rounded-2xl bg-slate-50 p-5 md:grid-cols-2">
          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">{{ m('sections.promo') }}</h3>
          <div class="grid gap-4 md:col-span-2 md:grid-cols-[1fr_240px]">
            <div class="grid gap-4">
              <label class="grid gap-2 text-sm font-bold text-slate-700">
                {{ m('fields.coverImageUrl') }}
                <input v-model="form.coverImageUrl" class="admin-input" @input="imagePreviewError = false" />
              </label>
              <label class="grid gap-2 text-sm font-bold text-slate-700">
                {{ m('fields.uploadImage') }}
                <input type="file" accept="image/*" class="rounded-xl border border-slate-200 bg-white px-4 py-3 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isUploadingImage" @change="handleImageFile" />
                <span v-if="isUploadingImage" class="text-xs font-bold text-avocado-700">{{ m('imagePreview.uploading') }}</span>
              </label>
            </div>
            <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
              <div class="flex aspect-[4/3] items-center justify-center overflow-hidden bg-slate-100">
                <img
                  v-if="(form.coverImageUrl || form.imageUrl) && !imagePreviewError"
                  :src="form.coverImageUrl || form.imageUrl"
                  :alt="m('preview.title')"
                  class="h-full w-full object-cover object-center"
                  @error="imagePreviewError = true"
                />
                <p v-else class="px-4 text-center text-sm font-bold text-slate-400">
                  {{ imagePreviewError ? m('imagePreview.loadFailed') : m('imagePreview.noImage') }}
                </p>
              </div>
            </div>
          </div>
          <div class="md:col-span-2">
            <p class="mb-3 text-sm font-bold text-slate-700">{{ m('fields.amenities') }}</p>
            <div class="flex flex-wrap gap-2">
              <label v-for="amenity in amenityOptions" :key="amenity.key" class="inline-flex cursor-pointer items-center gap-2 rounded-full border border-slate-200 bg-white px-3 py-2 text-sm font-bold text-slate-700 hover:bg-avocado-50">
                <input v-model="form.amenities" type="checkbox" :value="amenity.value" class="h-4 w-4 rounded border-slate-300" />
                {{ amenity.label }}
              </label>
            </div>
          </div>
          <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            {{ m('fields.galleryText') }}
            <textarea v-model="form.galleryText" rows="3" class="admin-input" :placeholder="m('placeholders.galleryText')"></textarea>
            <span class="text-xs font-semibold text-slate-400">{{ m('hints.galleryText') }}</span>
            <span v-if="formErrors.galleryText" class="text-xs font-bold text-red-600">{{ formErrors.galleryText }}</span>
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            {{ m('fields.menuPostersText') }}
            <textarea v-model="form.menuPostersText" rows="3" class="admin-input" :placeholder="m('placeholders.menuPostersText')"></textarea>
            <span class="text-xs font-semibold text-slate-400">{{ m('hints.menuPostersText') }}</span>
            <span v-if="formErrors.menuPostersText" class="text-xs font-bold text-red-600">{{ formErrors.menuPostersText }}</span>
          </label>
          <div class="grid gap-4 rounded-2xl border border-slate-200 bg-white p-4 md:col-span-2 md:grid-cols-[220px_1fr]">
            <label class="grid gap-2 text-sm font-bold text-slate-700">
              {{ m('fields.linkTitle') }}
              <input v-model="form.linkTitle" class="admin-input" :placeholder="m('placeholders.linkTitle')" />
            </label>
            <label class="grid gap-2 text-sm font-bold text-slate-700">
              {{ m('fields.linkUrl') }}
              <input v-model="form.linkUrl" class="admin-input" :placeholder="m('placeholders.linkUrl')" />
              <span v-if="formErrors.linkUrl" class="text-xs font-bold text-red-600">{{ formErrors.linkUrl }}</span>
            </label>
          </div>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.displayOrder') }}
            <input v-model.number="form.displayOrder" type="number" class="admin-input" />
            <span v-if="formErrors.displayOrder" class="text-xs font-bold text-red-600">{{ formErrors.displayOrder }}</span>
          </label>
          <label class="flex items-center gap-3 rounded-xl bg-white px-4 py-3 text-sm font-bold text-slate-700">
            <input v-model="form.featured" type="checkbox" class="h-4 w-4 rounded border-slate-300" />
            {{ m('fields.featured') }}
          </label>
        </section>

        <section class="rounded-2xl bg-slate-50 p-5">
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.status') }}
            <select v-model="form.status" class="admin-input">
              <option v-for="status in statusOptions" :key="status" :value="status">{{ statusLabels[status] }}</option>
            </select>
          </label>
        </section>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-lg border border-slate-200 px-4 py-3 font-bold text-slate-600 hover:bg-slate-50" @click="closeModal">{{ m('actions.cancel') }}</button>
          <button class="rounded-lg bg-brand-forest px-4 py-3 font-black text-white hover:bg-avocado-800 disabled:cursor-not-allowed disabled:opacity-60" form="location-form" type="submit" :disabled="isUploadingImage">
            {{ mode === 'create' ? m('actions.saveCreate') : m('actions.saveUpdate') }}
          </button>
        </div>
      </template>
    </BaseModal>

    <BaseModal :show="Boolean(previewLocation)" :title="m('preview.title')" max-width="max-w-2xl" @close="previewLocation = null">
      <article v-if="previewLocation" class="overflow-hidden rounded-3xl border border-avocado-100 bg-white shadow-xl">
        <img :src="previewLocation.imageUrl" :alt="previewLocation.name" class="h-72 w-full object-cover" />
        <div class="p-6">
          <div class="flex items-start justify-between gap-4">
            <div>
              <h2 class="text-2xl font-black text-avocado-950">{{ previewLocation.name }}</h2>
              <p class="mt-1 font-bold text-avocado-700">{{ previewLocation.city }} · {{ previewLocation.district }}</p>
            </div>
            <span class="rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(previewLocation.status)">
              {{ statusLabels[previewLocation.status] }}
            </span>
          </div>
          <div class="mt-5 space-y-3 leading-7 text-slate-600">
            <p>{{ previewLocation.addressText }}</p>
            <p><strong class="text-slate-900">{{ m('preview.hours') }}</strong> {{ previewLocation.openingHours }}</p>
            <p><strong class="text-slate-900">{{ m('preview.phone') }}</strong> {{ previewLocation.phone }}</p>
          </div>
          <div class="mt-5 flex flex-wrap gap-2">
            <span v-for="amenity in previewLocation.amenities" :key="amenity" class="rounded-full bg-avocado-50 px-3 py-1 text-xs font-bold text-avocado-700">{{ amenityLabel(amenity) }}</span>
          </div>
          <div class="mt-6 flex flex-col gap-3 sm:flex-row">
            <a :href="previewLocation.mapUrl" target="_blank" rel="noreferrer" class="rounded-full bg-cream-400 px-5 py-3 text-center font-black text-avocado-950 hover:bg-cream-300">{{ m('actions.viewMap') }}</a>
            <a :href="`tel:${previewLocation.phone}`" class="rounded-full bg-avocado-800 px-5 py-3 text-center font-black text-white hover:bg-avocado-900">{{ m('actions.callNow') }}</a>
          </div>
        </div>
      </article>
    </BaseModal>

    <ConfirmModal :show="Boolean(pendingDeleteId)" @cancel="pendingDeleteId = null" @confirm="confirmDeleteLocation" />
  </section>
</template>

<style scoped>
.admin-input {
  width: 100%;
  border-radius: 0.75rem;
  border: 1px solid rgb(226 232 240);
  background: white;
  padding: 0.75rem 1rem;
  outline: none;
}

.admin-input:focus {
  border-color: rgb(45 90 39);
}
</style>
