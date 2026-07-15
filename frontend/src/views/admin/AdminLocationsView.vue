<script setup>
import { computed, nextTick, onMounted, reactive, ref, watch } from 'vue'
import { MapPin } from 'lucide-vue-next'
import AdminLinkPicker from '../../components/admin/AdminLinkPicker.vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import AdminListPage from '../../components/admin/AdminListPage.vue'
import AdminNestedShell from '../../components/admin/shell/AdminNestedShell.vue'
import AdminShellFrame from '../../components/admin/shell/AdminShellFrame.vue'
import AdminShellTablePanel from '../../components/admin/shell/AdminShellTablePanel.vue'
import AdminShellTabs from '../../components/admin/shell/AdminShellTabs.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import { normalizeStorageAssetUrl, resolveBackendAssetUrl, uploadService } from '../../services/cmsService'
import { useAdminModuleI18n } from '../../composables/useAdminModuleI18n'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'
import { isValidAdminLinkUrl } from '../../utils/adminLinkPicker'

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
const slugTouched = ref(false)
const modalFormTab = ref('required')

const formTabItems = computed(() => [
  { key: 'required', label: m('formTabs.required') },
  { key: 'content', label: m('formTabs.content') },
  { key: 'preview', label: m('formTabs.preview') },
])

const formErrorTabMap = {
  storeCode: 'required',
  name: 'required',
  slug: 'required',
  addressText: 'required',
  city: 'required',
  phone: 'required',
  openingHours: 'required',
  mapUrl: 'required',
  coverImageUrl: 'required',
  galleryText: 'content',
  menuPostersText: 'content',
  displayOrder: 'content',
}

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

const slugify = (value) =>
  String(value || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')

const normalizeTimeValue = (value) => {
  const raw = String(value || '').trim()
  if (!raw) return ''
  const match = raw.match(/^(\d{1,2}):(\d{2})(?::\d{2})?$/)
  if (!match) return ''
  const hours = Number(match[1])
  const minutes = Number(match[2])
  if (Number.isNaN(hours) || Number.isNaN(minutes) || hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
    return ''
  }
  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`
}

const parseBusinessHours = (location) => {
  const rows = Array.isArray(location?.businessHours) ? location.businessHours : []
  if (!rows.length) return { opensAt: '', closesAt: '' }
  const row = rows.find((hour) => !hour.isClosed && (hour.openTime || hour.closeTime)) || rows[0]
  return {
    opensAt: normalizeTimeValue(row?.openTime),
    closesAt: normalizeTimeValue(row?.closeTime),
  }
}

const parseOpeningHours = (value) => {
  const text = String(value || '').trim()
  if (!text || text === '-' || text === ' - ') return { opensAt: '', closesAt: '' }
  const match = text.match(/^(\d{1,2}:\d{2})(?::\d{2})?\s*[-–—]\s*(\d{1,2}:\d{2})(?::\d{2})?$/)
  if (!match) return { opensAt: '', closesAt: '' }
  return {
    opensAt: normalizeTimeValue(match[1]),
    closesAt: normalizeTimeValue(match[2]),
  }
}

const resolveOpeningHours = (location) => {
  const parsed = parseOpeningHours(location?.openingHours || '')
  if (parsed.opensAt && parsed.closesAt) return parsed
  return parseBusinessHours(location)
}

const buildOpeningHours = (opensAt, closesAt) => {
  const open = normalizeTimeValue(opensAt)
  const close = normalizeTimeValue(closesAt)
  if (!open || !close) return ''
  return `${open} - ${close}`
}

const openingHoursPreview = computed(() => buildOpeningHours(form.opensAt, form.closesAt))

const blurOpeningTime = (field) => {
  form[field] = normalizeTimeValue(form[field])
}

const blurSlug = () => {
  form.slug = slugify(form.slug)
  slugTouched.value = true
}

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
    form.coverImageUrl = normalizeStorageAssetUrl(data.url)
    form.imageUrl = form.coverImageUrl
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

const menuPostersJsonToLines = (value) => {
  const parsed = parseJsonArray(value)
  return parsed
    .map((item) => {
      if (typeof item === 'string') return item.trim()
      if (item && typeof item === 'object') {
        return String(item.imageUrl || item.url || '').trim()
      }
      return ''
    })
    .filter(Boolean)
    .join('\n')
}

const linesToMenuPostersJson = (value) =>
  JSON.stringify(
    String(value || '')
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter(Boolean)
      .map((imageUrl, index) => ({
        title: 'Menu ALOO',
        imageUrl,
        sortOrder: index,
        isActive: true,
      })),
  )

const parseAmenities = (location) => {
  if (Array.isArray(location.amenities) && location.amenities.length) {
    return location.amenities.filter((item) => typeof item === 'string' && item.trim())
  }
  return parseJsonArray(location.amenitiesJson).filter((item) => typeof item === 'string' && item.trim())
}

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
  opensAt: '',
  closesAt: '',
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
  displayOrder: 1,
  featured: false,
  status: 'ACTIVE',
})

const normalizeLocation = (location) => {
  const primaryLink = getPrimaryLink(location)
  const mapUrl = location.mapUrl || location.googleMapUrl || primaryLink.url || ''
  const hours = resolveOpeningHours(location)

  return {
    ...location,
    storeCode: location.storeCode || '',
    name: location.name || '',
    slug: location.slug || '',
    addressText: location.addressText || location.address || '',
    mapUrl,
    phone: location.phone || '',
    email: location.email || '',
    opensAt: hours.opensAt,
    closesAt: hours.closesAt,
    openingHours: location.openingHours || '',
    storeType: location.storeType || 'STANDARD',
    description: location.description || '',
    city: location.city || location.province || '',
    district: location.district || '',
    ward: location.ward || '',
    latitude: location.latitude ?? null,
    longitude: location.longitude ?? null,
    coverImageUrl: normalizeStorageAssetUrl(location.coverImageUrl || location.imageUrl || ''),
    imageUrl: resolveBackendAssetUrl(location.coverImageUrl || location.imageUrl || ''),
    amenities: parseAmenities(location),
    galleryText: jsonArrayToLines(location.galleryJson),
    menuPostersText: menuPostersJsonToLines(location.menuPostersJson),
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
    opensAt: '',
    closesAt: '',
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
    displayOrder: 1,
    featured: false,
    status: 'ACTIVE',
  })
  formErrors.value = {}
  editingId.value = null
  slugTouched.value = false
}

const coverPreviewUrl = computed(() => resolveBackendAssetUrl(form.coverImageUrl || ''))

const showImageWarning = computed(
  () => form.status === 'ACTIVE' && !String(form.coverImageUrl || '').trim(),
)

const pendingDeleteItem = computed(() =>
  normalizedLocations.value.find((location) => location.id === pendingDeleteId.value) || null,
)

const formPreviewOpeningHours = computed(() => buildOpeningHours(form.opensAt, form.closesAt))

const publicPreviewUrl = computed(() => (form.slug.trim() ? `/locations/${form.slug.trim()}` : '/locations'))

const scrollToFirstFormError = () => {
  nextTick(() => {
    const formEl = document.getElementById('location-form')
    const errorEl = formEl?.querySelector('.text-red-600')
    errorEl?.scrollIntoView({ behavior: 'smooth', block: 'center' })
  })
}

const focusFirstErrorTab = (errors) => {
  const firstErrorKey = Object.keys(errors)[0]
  if (!firstErrorKey) return
  modalFormTab.value = formErrorTabMap[firstErrorKey] || 'required'
  scrollToFirstFormError()
}

const openCreateModal = () => {
  mode.value = 'create'
  resetForm()
  modalFormTab.value = 'required'
  imagePreviewError.value = false
  showModal.value = true
}

const openEditModal = (location) => {
  mode.value = 'edit'
  editingId.value = location.id
  Object.assign(form, normalizeLocation(location))
  formErrors.value = {}
  modalFormTab.value = 'required'
  imagePreviewError.value = false
  showModal.value = true
}

const openPreviewModal = (location) => {
  openEditModal(location)
  modalFormTab.value = 'preview'
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const isValidAssetUrl = (value) => {
  const text = String(value || '').trim()
  if (!text) return true
  if (text.startsWith('/uploads/') || text.startsWith('/')) return true
  try {
    const url = new URL(text)
    return ['http:', 'https:'].includes(url.protocol)
  } catch {
    return false
  }
}

const hydrateOpeningTimes = () => {
  if (form.opensAt && form.closesAt) return
  const parsed = parseOpeningHours(form.openingHours || '')
  if (parsed.opensAt && !form.opensAt) form.opensAt = parsed.opensAt
  if (parsed.closesAt && !form.closesAt) form.closesAt = parsed.closesAt
}

const validateForm = () => {
  const errors = {}
  hydrateOpeningTimes()

  if (!form.storeCode.trim()) errors.storeCode = m('validation.storeCode')
  if (!form.name.trim()) errors.name = m('validation.name')
  if (!form.slug.trim() && form.name.trim()) form.slug = slugify(form.name)
  else form.slug = slugify(form.slug)
  if (!form.slug.trim()) errors.slug = m('validation.slug')
  if (!form.addressText.trim()) errors.addressText = m('validation.addressText')
  if (!form.city.trim()) errors.city = m('validation.city')
  if (form.phone.trim().length > 80) errors.phone = m('validation.phone')
  if (form.mapUrl && !isValidAdminLinkUrl(form.mapUrl)) errors.mapUrl = m('validation.linkUrl')
  if (form.coverImageUrl.trim() && !isValidAssetUrl(form.coverImageUrl)) {
    errors.coverImageUrl = m('validation.imageUrl')
  }
  JSON.parse(linesToJsonArray(form.galleryText)).forEach((url) => {
    if (!isValidAssetUrl(url)) errors.galleryText = m('validation.galleryText')
  })
  JSON.parse(linesToMenuPostersJson(form.menuPostersText)).forEach((poster) => {
    if (!isValidAssetUrl(poster.imageUrl)) errors.menuPostersText = m('validation.menuPostersText')
  })
  const openTime = normalizeTimeValue(form.opensAt)
  const closeTime = normalizeTimeValue(form.closesAt)
  const openingHours = buildOpeningHours(openTime, closeTime)
  if (form.status === 'ACTIVE') {
    if (!openTime || !closeTime) errors.openingHours = m('validation.openingHours')
    else if (!openingHours) errors.openingHours = m('validation.openingHoursFormat')
  }
  if (Number.isNaN(Number(form.displayOrder))) errors.displayOrder = m('validation.displayOrder')

  formErrors.value = errors
  if (Object.keys(errors).length) focusFirstErrorTab(errors)
  return Object.keys(errors).length === 0
}

const buildLinksJson = () => {
  const url = form.mapUrl.trim()
  if (!url) return '[]'

  return JSON.stringify([
    {
      type: 'GOOGLE_MAPS',
      title: defaultLinkTitle(),
      url,
    },
  ])
}

const buildPayload = () => {
  const openingHours = buildOpeningHours(
    normalizeTimeValue(form.opensAt),
    normalizeTimeValue(form.closesAt),
  )

  return {
    id: editingId.value,
    storeCode: form.storeCode.trim(),
    name: form.name.trim(),
    slug: slugify(form.slug.trim()),
    addressText: form.addressText.trim(),
    address: form.addressText.trim(),
    mapUrl: form.mapUrl.trim(),
    phone: form.phone.trim(),
    email: form.email.trim(),
    openingHours,
    storeType: form.storeType,
    description: form.description.trim(),
    coverImageUrl: normalizeStorageAssetUrl((form.coverImageUrl || '').trim()),
    imageUrl: normalizeStorageAssetUrl((form.coverImageUrl || '').trim()),
    city: form.city.trim(),
    province: form.city.trim(),
    district: form.district.trim(),
    ward: form.ward.trim(),
    latitude: form.latitude || null,
    longitude: form.longitude || null,
    amenities: [...form.amenities],
    galleryJson: linesToJsonArray(form.galleryText),
    amenitiesJson: JSON.stringify(form.amenities),
    menuPostersJson: linesToMenuPostersJson(form.menuPostersText),
    linksJson: buildLinksJson(),
    displayOrder: Number(form.displayOrder) || 1,
    featured: form.featured,
    status: form.status,
  }
}

const saveLocation = async () => {
  if (!validateForm()) {
    const firstError = Object.values(formErrors.value)[0]
    toast.error(firstError || m('validation.formInvalid'))
    return
  }
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
const listCountText = computed(() => t('admin.shared.totalCount', { count: filteredLocations.value.length }))

watch([searchQuery, statusFilter, cityFilter, featuredFilter], () => {
  currentPage.value = 1
})

watch(
  () => form.name,
  (name) => {
    if (mode.value === 'create' && !slugTouched.value) {
      form.slug = slugify(name)
    }
  },
)

onMounted(() => {
  store.fetchLocations().catch(() => {
    toast.error(m('toasts.loadError'))
  })
})
</script>

<template>
  <AdminListPage>
    <AdminNestedShell>
      <AdminShellFrame variant="header" inner="header">
        <AdminPageHeader :eyebrow="m('eyebrow')" :title="m('title')">
          <template #actions>
            <button class="admin-list-btn admin-list-btn--primary" @click="openCreateModal">
              {{ m('add') }}
            </button>
          </template>
        </AdminPageHeader>
      </AdminShellFrame>

      <AdminShellFrame variant="toolbar" inner="toolbar">
        <section class="aloo-admin-toolbar lg:!grid-cols-[1fr_180px_210px_170px]">
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
        </section>
      </AdminShellFrame>

      <AdminShellFrame v-if="errorMessage" as="p" variant="alert" class="admin-list-alert">
        {{ errorMessage }}
      </AdminShellFrame>

      <AdminShellFrame v-if="isLoading" variant="body" inner="pad">
        <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
      </AdminShellFrame>

      <AdminShellFrame v-else-if="!filteredLocations.length" variant="body" inner="pad">
        <EmptyState :message="m('empty')" />
      </AdminShellFrame>

      <AdminShellFrame v-else variant="body" visibility="desktop">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <table class="admin-shell-table locations-table">
            <colgroup>
              <col class="locations-col-image" />
              <col class="locations-col-name" />
              <col class="locations-col-address" />
              <col class="locations-col-hours" />
              <col class="locations-col-phone" />
              <col class="locations-col-status" />
              <col class="locations-col-actions" />
            </colgroup>
            <thead>
              <tr>
                <th class="locations-cell locations-cell--image">{{ m('columns.image') }}</th>
                <th class="locations-cell locations-cell--name">{{ m('columns.name') }}</th>
                <th class="locations-cell locations-cell--address">{{ m('columns.address') }}</th>
                <th class="locations-cell locations-cell--hours">{{ m('columns.hours') }}</th>
                <th class="locations-cell locations-cell--phone">{{ m('columns.phone') }}</th>
                <th class="locations-cell locations-cell--status">{{ m('columns.status') }}</th>
                <th class="locations-cell locations-cell--actions">{{ m('columns.actions') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="location in paginatedLocations" :key="location.id">
                <td class="locations-cell locations-cell--image">
                  <img v-if="location.imageUrl" :src="location.imageUrl" :alt="location.name" class="locations-thumb" />
                  <div v-else class="locations-thumb locations-thumb--placeholder">ALOO</div>
                </td>
                <td class="locations-cell locations-cell--name">
                  <div class="space-y-1">
                    <h3 class="truncate font-black leading-5 text-avocado-950">{{ location.name }}</h3>
                    <div class="flex flex-wrap items-center gap-1.5 text-xs font-bold">
                      <span class="text-avocado-700">{{ location.city }} · {{ location.district }}</span>
                      <span class="rounded-full bg-slate-100 px-2 py-0.5 text-slate-500">#{{ location.displayOrder }}</span>
                    </div>
                    <span v-if="location.featured" class="inline-flex rounded-full bg-cream-100 px-2 py-0.5 text-xs font-black text-avocado-900">{{ m('featuredBadge') }}</span>
                  </div>
                </td>
                <td class="locations-cell locations-cell--address">
                  <p class="truncate leading-5 text-slate-700">{{ location.addressText }}</p>
                  <a :href="location.mapUrl" target="_blank" rel="noreferrer" class="mt-2 inline-flex items-center gap-1 text-xs font-black text-avocado-700 hover:text-avocado-900">
                    <MapPin class="h-3.5 w-3.5 shrink-0" /> {{ m('actions.viewMap') }}
                  </a>
                </td>
                <td class="locations-cell locations-cell--hours admin-shell-cell-muted">{{ location.openingHours || '-' }}</td>
                <td class="locations-cell locations-cell--phone admin-shell-cell-muted">
                  <span class="locations-phone">{{ location.phone }}</span>
                </td>
                <td class="locations-cell locations-cell--status">
                  <span class="locations-status" :class="statusClass(location.status)">
                    {{ statusLabels[location.status] || location.status }}
                  </span>
                </td>
                <td class="locations-cell locations-cell--actions">
                  <div class="locations-actions">
                    <button type="button" class="locations-action-btn" @click="openPreviewModal(location)">{{ m('actions.view') }}</button>
                    <button type="button" class="locations-action-btn locations-action-btn--primary" @click="openEditModal(location)">{{ m('actions.edit') }}</button>
                    <button type="button" class="locations-action-btn locations-action-btn--danger" @click="pendingDeleteId = location.id">{{ m('actions.delete') }}</button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="!isLoading && filteredLocations.length" variant="body" visibility="mobile">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <template #below>
            <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack">
              <article v-for="location in paginatedLocations" :key="location.id" class="admin-shell-mobile-card overflow-hidden !p-0">
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
                    <button class="rounded-lg border border-slate-200 px-3 py-2 font-bold text-slate-700" @click="openPreviewModal(location)">{{ m('preview') }}</button>
                    <button class="rounded-lg border border-avocado-200 px-3 py-2 font-bold text-avocado-700" @click="openEditModal(location)">{{ m('actions.edit') }}</button>
                    <button class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600" @click="pendingDeleteId = location.id">{{ m('actions.delete') }}</button>
                  </div>
                </div>
              </article>
            </div>
          </template>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="filteredLocations.length" variant="footer">
        <Pagination
          :page="currentPage"
          :total-pages="totalPages"
          :visible-count="paginatedLocations.length"
          :total-count="filteredLocations.length"
          :label="m('paginationLabel')"
          @prev="currentPage = Math.max(1, currentPage - 1)"
          @next="currentPage = Math.min(totalPages, currentPage + 1)"
        />
      </AdminShellFrame>
    </AdminNestedShell>

    <BaseModal :show="showModal" :title="mode === 'create' ? m('modals.create') : m('modals.edit')" max-width="max-w-5xl" @close="closeModal">
      <form id="location-form" class="grid gap-5" @submit.prevent="saveLocation">
        <AdminShellTabs
          v-model="modalFormTab"
          :items="formTabItems"
          :aria-label="m('formTabs.aria')"
        />

        <section v-show="modalFormTab === 'required'" class="locations-form-panel grid gap-5 rounded-2xl border border-slate-200 bg-white p-5">
          <div class="grid gap-5 md:grid-cols-2">
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.storeCode') }}
              <input
                v-model="form.storeCode"
                class="admin-input-premium"
                :class="{ 'cursor-not-allowed bg-slate-50 text-slate-500': mode === 'edit' }"
                :readonly="mode === 'edit'"
                :placeholder="m('placeholders.storeCode')"
              />
              <span v-if="formErrors.storeCode" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.storeCode }}</span>
              <span v-else-if="mode === 'edit'" class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.storeCodeLocked') }}</span>
              <span v-else class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.storeCode') }}</span>
            </label>
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.name') }}
              <input v-model="form.name" class="admin-input-premium" />
              <span v-if="formErrors.name" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.name }}</span>
            </label>
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.slug') }}
              <input
                v-model="form.slug"
                class="admin-input-premium"
                :placeholder="m('placeholders.slug')"
                @input="slugTouched = true"
                @blur="blurSlug"
              />
              <span v-if="formErrors.slug" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.slug }}</span>
              <span v-else class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.slug') }}</span>
            </label>
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.phone') }}
              <input v-model="form.phone" class="admin-input-premium" />
              <span v-if="formErrors.phone" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.phone }}</span>
            </label>
          </div>

          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.addressText') }}
            <input v-model="form.addressText" class="admin-input-premium" />
            <span v-if="formErrors.addressText" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.addressText }}</span>
          </label>

          <div class="grid gap-5 md:grid-cols-2">
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.city') }}
              <input v-model="form.city" class="admin-input-premium" />
              <span v-if="formErrors.city" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.city }}</span>
            </label>
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.district') }}
              <input v-model="form.district" class="admin-input-premium" />
            </label>
          </div>

          <div class="grid gap-5 md:grid-cols-2">
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.storeType') }}
              <select v-model="form.storeType" class="admin-input-premium cursor-pointer">
                <option v-for="type in storeTypeOptions" :key="type" :value="type">{{ storeTypeLabels[type] }}</option>
              </select>
            </label>
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.status') }}
              <select v-model="form.status" class="admin-input-premium cursor-pointer">
                <option v-for="status in statusOptions" :key="status" :value="status">{{ statusLabels[status] }}</option>
              </select>
            </label>
          </div>

          <div class="grid gap-2">
            <span class="text-xs font-bold uppercase tracking-wider text-slate-500">{{ m('fields.openingHours') }}</span>
            <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
              <label class="grid gap-1.5 text-xs font-semibold normal-case tracking-normal text-slate-600">
                {{ m('fields.opensAt') }}
                <input
                  v-model="form.opensAt"
                  type="text"
                  inputmode="numeric"
                  maxlength="5"
                  placeholder="07:00"
                  class="admin-input-premium font-mono tracking-wide"
                  @blur="blurOpeningTime('opensAt')"
                />
              </label>
              <label class="grid gap-1.5 text-xs font-semibold normal-case tracking-normal text-slate-600">
                {{ m('fields.closesAt') }}
                <input
                  v-model="form.closesAt"
                  type="text"
                  inputmode="numeric"
                  maxlength="5"
                  placeholder="22:00"
                  class="admin-input-premium font-mono tracking-wide"
                  @blur="blurOpeningTime('closesAt')"
                />
              </label>
            </div>
            <span class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('hints.openingHours') }}</span>
            <span v-if="openingHoursPreview" class="text-xs font-bold normal-case tracking-normal text-avocado-800">{{ openingHoursPreview }}</span>
            <span v-if="formErrors.openingHours" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.openingHours }}</span>
          </div>

          <div class="grid gap-2">
            <p class="text-xs font-bold uppercase tracking-wider text-slate-500">{{ m('fields.mapUrl') }}</p>
            <AdminLinkPicker
              v-model="form.mapUrl"
              module="locations"
              :allow-hash="false"
              :allow-none="true"
              :error="formErrors.mapUrl"
            />
            <span v-if="!formErrors.mapUrl" class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.mapUrl') }}</span>
          </div>

          <div class="grid gap-4 md:grid-cols-[minmax(0,1fr)_220px]">
            <div class="grid content-start gap-3">
              <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
                {{ m('fields.coverImageUrl') }}
                <input v-model="form.coverImageUrl" class="admin-input-premium" @input="imagePreviewError = false" />
                <span v-if="formErrors.coverImageUrl" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.coverImageUrl }}</span>
                <span v-else-if="showImageWarning" class="text-xs font-bold normal-case tracking-normal text-amber-700">{{ m('validation.imageRecommended') }}</span>
                <span v-else class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.imageUrl') }}</span>
              </label>
              <label class="grid gap-2 text-xs font-semibold normal-case tracking-normal text-slate-600">
                {{ m('fields.uploadImage') }}
                <input
                  type="file"
                  accept=".jpg,.jpeg,.jfif,.png,.webp,.gif,image/jpeg,image/png,image/webp,image/gif"
                  class="rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm font-semibold text-slate-600 file:mr-3 file:cursor-pointer file:rounded-lg file:border-0 file:bg-avocado-600 file:px-3 file:py-2 file:text-xs file:font-bold file:text-white hover:file:bg-avocado-700 disabled:cursor-not-allowed disabled:opacity-60"
                  :disabled="isUploadingImage"
                  @change="handleImageFile"
                />
                <span v-if="isUploadingImage" class="text-xs font-bold text-avocado-700">{{ m('imagePreview.uploading') }}</span>
              </label>
            </div>
            <div class="overflow-hidden rounded-2xl border border-slate-200 bg-slate-50 shadow-sm">
              <div class="flex aspect-[4/3] items-center justify-center overflow-hidden">
                <img
                  v-if="coverPreviewUrl && !imagePreviewError"
                  :src="coverPreviewUrl"
                  :alt="m('preview.title')"
                  class="h-full w-full object-cover object-center"
                  @error="imagePreviewError = true"
                />
                <p v-else class="px-4 text-center text-xs font-semibold text-slate-400">
                  {{ imagePreviewError ? m('imagePreview.loadFailed') : m('imagePreview.noImage') }}
                </p>
              </div>
            </div>
          </div>
        </section>

        <section v-show="modalFormTab === 'content'" class="locations-form-panel grid gap-5 rounded-2xl border border-slate-200 bg-white p-5">
          <p class="text-sm text-slate-500">{{ m('formTabs.contentHint') }}</p>

          <div class="grid gap-5 md:grid-cols-2">
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.email') }}
              <input v-model="form.email" type="email" class="admin-input-premium" />
            </label>
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.displayOrder') }}
              <input v-model.number="form.displayOrder" type="number" min="0" class="admin-input-premium" />
              <span v-if="formErrors.displayOrder" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.displayOrder }}</span>
              <span v-else class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.displayOrder') }}</span>
            </label>
          </div>

          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.description') }}
            <textarea v-model="form.description" rows="3" class="admin-input-premium resize-none" />
          </label>

          <div>
            <p class="mb-3 text-xs font-bold uppercase tracking-wider text-slate-500">{{ m('fields.amenities') }}</p>
            <div class="flex flex-wrap gap-2">
              <label v-for="amenity in amenityOptions" :key="amenity.key" class="inline-flex cursor-pointer items-center gap-2 rounded-full border border-slate-200 bg-white px-3 py-2 text-sm font-bold text-slate-700 hover:bg-avocado-50">
                <input v-model="form.amenities" type="checkbox" :value="amenity.value" class="h-4 w-4 accent-avocado-700" />
                {{ amenity.label }}
              </label>
            </div>
          </div>

          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.galleryText') }}
            <textarea v-model="form.galleryText" rows="3" class="admin-input-premium resize-none" :placeholder="m('placeholders.galleryText')" />
            <span v-if="formErrors.galleryText" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.galleryText }}</span>
            <span v-else class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.galleryText') }}</span>
          </label>

          <label class="inline-flex items-center gap-3 rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-bold text-slate-700">
            <input v-model="form.featured" type="checkbox" class="h-4 w-4 accent-avocado-700" />
            {{ m('fields.featured') }}
          </label>

          <div class="grid gap-5 md:grid-cols-3">
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.ward') }}
              <input v-model="form.ward" class="admin-input-premium" />
            </label>
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.latitude') }}
              <input v-model.number="form.latitude" type="number" step="0.0000001" class="admin-input-premium" />
            </label>
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.longitude') }}
              <input v-model.number="form.longitude" type="number" step="0.0000001" class="admin-input-premium" />
            </label>
          </div>

          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.menuPostersText') }}
            <textarea v-model="form.menuPostersText" rows="3" class="admin-input-premium resize-none" :placeholder="m('placeholders.menuPostersText')" />
            <span v-if="formErrors.menuPostersText" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.menuPostersText }}</span>
            <span v-else class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.menuPostersText') }}</span>
          </label>
        </section>

        <section v-show="modalFormTab === 'preview'" class="grid gap-4 rounded-2xl bg-slate-50 p-5">
          <p class="text-sm text-slate-500">{{ m('formTabs.previewHint') }}</p>
          <article class="overflow-hidden rounded-3xl border border-avocado-100 bg-white shadow-xl">
            <div class="relative aspect-[16/7] bg-avocado-50">
              <img
                v-if="coverPreviewUrl && !imagePreviewError"
                :src="coverPreviewUrl"
                :alt="form.name || m('preview.title')"
                class="h-full w-full object-cover"
              />
              <div v-else class="grid h-full place-items-center text-2xl font-black text-avocado-700">ALOO</div>
              <span class="absolute left-4 top-4 rounded-full border px-3 py-1 text-xs font-black" :class="statusClass(form.status)">
                {{ statusLabels[form.status] || form.status }}
              </span>
            </div>
            <div class="p-6">
              <p v-if="form.storeCode" class="text-xs font-black uppercase tracking-[0.22em] text-cream-500">{{ form.storeCode }}</p>
              <h2 class="mt-2 text-2xl font-black text-avocado-950">{{ form.name || '—' }}</h2>
              <p class="mt-1 font-bold text-avocado-700">{{ form.city || '—' }}<span v-if="form.district"> · {{ form.district }}</span></p>
              <p v-if="form.description" class="mt-4 leading-7 text-slate-600">{{ form.description }}</p>
              <div class="mt-5 space-y-3 text-sm text-slate-600">
                <p v-if="form.addressText">{{ form.addressText }}</p>
                <p><strong class="text-slate-900">{{ m('preview.hours') }}</strong> {{ formPreviewOpeningHours || '—' }}</p>
                <p v-if="form.phone"><strong class="text-slate-900">{{ m('preview.phone') }}</strong> {{ form.phone }}</p>
              </div>
              <div v-if="form.amenities.length" class="mt-5 flex flex-wrap gap-2">
                <span v-for="amenity in form.amenities" :key="amenity" class="rounded-full bg-avocado-50 px-3 py-1 text-xs font-bold text-avocado-700">{{ amenityLabel(amenity) }}</span>
              </div>
              <div v-if="form.featured" class="mt-4">
                <span class="inline-flex rounded-full bg-cream-100 px-2 py-0.5 text-xs font-black text-avocado-900">{{ m('featuredBadge') }}</span>
              </div>
            </div>
          </article>
          <p v-if="form.status === 'ACTIVE'" class="text-xs font-semibold text-emerald-700">{{ m('formTabs.previewActive') }}</p>
          <p v-else class="text-xs font-semibold text-slate-500">{{ m('formTabs.previewHidden') }}</p>
          <a
            v-if="form.slug"
            :href="publicPreviewUrl"
            target="_blank"
            rel="noopener noreferrer"
            class="inline-flex w-fit items-center gap-2 rounded-full border border-avocado-200 px-5 py-2.5 text-xs font-bold uppercase tracking-wider text-avocado-700 transition hover:bg-avocado-50"
          >
            {{ m('formTabs.openPublic') }}
          </a>
        </section>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-lg border border-slate-200 px-4 py-3 font-bold text-slate-600 hover:bg-slate-50" type="button" @click="closeModal">{{ m('actions.cancel') }}</button>
          <button class="rounded-lg bg-brand-forest px-4 py-3 font-black text-white hover:bg-avocado-800 disabled:cursor-not-allowed disabled:opacity-60" type="button" :disabled="isUploadingImage" @click="saveLocation">
            {{ mode === 'create' ? m('actions.saveCreate') : m('actions.saveUpdate') }}
          </button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal
      :show="Boolean(pendingDeleteId)"
      :title="m('confirmDelete.title')"
      :message="m('confirmDelete.message', { name: pendingDeleteItem?.name || '' })"
      :confirm-text="m('confirmDelete.confirm')"
      @cancel="pendingDeleteId = null"
      @confirm="confirmDeleteLocation"
    />
  </AdminListPage>
</template>

<style scoped>
.locations-form-panel {
  min-height: 280px;
}

.locations-table {
  min-width: 980px;
}

.locations-col-image { width: 88px; }
.locations-col-name { width: 20%; }
.locations-col-address { width: 26%; }
.locations-col-hours { width: 96px; }
.locations-col-phone { width: 120px; }
.locations-col-status { width: 132px; }
.locations-col-actions { width: 188px; }

.locations-cell {
  overflow: hidden;
  vertical-align: middle;
}

.locations-table :deep(th.locations-cell--image),
.locations-table :deep(td.locations-cell--image) {
  text-align: center;
}

.locations-table :deep(th.locations-cell--hours),
.locations-table :deep(td.locations-cell--hours),
.locations-table :deep(th.locations-cell--phone),
.locations-table :deep(td.locations-cell--phone),
.locations-table :deep(th.locations-cell--status),
.locations-table :deep(td.locations-cell--status) {
  text-align: center;
}

.locations-table :deep(th.locations-cell--actions),
.locations-table :deep(td.locations-cell--actions) {
  text-align: right;
}

.locations-thumb {
  width: 56px;
  height: 48px;
  margin-inline: auto;
  border-radius: 0.5rem;
  object-fit: cover;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.08);
}

.locations-thumb--placeholder {
  display: grid;
  place-items: center;
  background: #f0fdf4;
  font-size: 10px;
  font-weight: 800;
  color: #166534;
}

.locations-phone {
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.locations-status {
  display: inline-flex;
  max-width: 100%;
  align-items: center;
  justify-content: center;
  border-radius: 9999px;
  border-width: 1px;
  border-style: solid;
  padding: 0.25rem 0.625rem;
  font-size: 11px;
  font-weight: 800;
  line-height: 1.25;
  white-space: nowrap;
}

.locations-actions {
  display: flex;
  flex-wrap: nowrap;
  justify-content: flex-end;
  gap: 0.375rem;
}

.locations-action-btn {
  flex-shrink: 0;
  border-radius: 0.5rem;
  border: 1px solid #e2e8f0;
  background: #fff;
  padding: 0.375rem 0.625rem;
  font-size: 11px;
  font-weight: 700;
  color: #334155;
  white-space: nowrap;
}

.locations-action-btn:hover {
  background: #f8fafc;
}

.locations-action-btn--primary {
  border-color: #bbf7d0;
  color: #166534;
}

.locations-action-btn--primary:hover {
  background: #f0fdf4;
}

.locations-action-btn--danger {
  border-color: #fecaca;
  color: #dc2626;
}

.locations-action-btn--danger:hover {
  background: #fef2f2;
}
</style>
