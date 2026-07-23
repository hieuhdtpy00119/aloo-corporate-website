<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { ArrowRight, ExternalLink, MapPin, ShoppingBag } from 'lucide-vue-next'
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
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import { useAdminModuleI18n } from '../../composables/useAdminModuleI18n'
import {
  homeSectionService,
  normalizeStorageAssetUrl,
  postService,
  productService,
  resolveBackendAssetUrl,
  uploadService,
} from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'

const toast = useToastStore()
const { m, t } = useAdminModuleI18n('homeSections')

const sections = ref([])
const isLoading = ref(false)
const errorMessage = ref('')
const showModal = ref(false)
const mode = ref('create')
const editingId = ref(null)
const pendingDeleteId = ref(null)
const searchQuery = ref('')
const statusFilter = ref(t('admin.shared.all'))
const typeFilter = ref(t('admin.shared.all'))
const currentPage = ref(1)
const isUploadingImage = ref(false)
const isSaving = ref(false)
const isLoadingLinkOptions = ref(false)
const linkType = ref('NONE')
const linkTarget = ref('')
const products = ref([])
const posts = ref([])
const pageSize = 6
const formErrors = ref({})
const sectionKeyTouched = ref(false)
const modalFormTab = ref('required')

const publishedPostStatuses = new Set(['Đã đăng', 'Đã xuất bản', 'Published', 'PUBLISHED'])
const isActiveProduct = (product) => ['ACTIVE', 'Đang bán'].includes(product?.status)
const isPublishedPost = (post) => publishedPostStatuses.has(post?.status)

const formTabItems = computed(() => [
  { key: 'required', label: m('formTabs.required') },
  { key: 'content', label: m('formTabs.content') },
  { key: 'preview', label: m('formTabs.preview') },
])

const formErrorTabMap = {
  title: 'required',
  sectionKey: 'required',
  sortOrder: 'required',
  imageUrl: 'required',
  customLink: 'content',
  linkTarget: 'content',
}

const linkableProducts = computed(() => {
  const active = products.value.filter(isActiveProduct)
  if (linkType.value !== 'PRODUCT' || !linkTarget.value) return active

  const selected = products.value.find((product) => String(product.slug || product.id) === linkTarget.value)
  if (selected && !active.some((product) => product.id === selected.id)) {
    return [selected, ...active]
  }
  return active
})

const linkablePosts = computed(() => {
  const published = posts.value.filter(isPublishedPost)
  if (linkType.value !== 'POST' || !linkTarget.value) return published

  const selected = posts.value.find((post) => String(post.slug || post.id) === linkTarget.value)
  if (selected && !published.some((post) => post.id === selected.id)) {
    return [selected, ...published]
  }
  return published
})

const showImageWarning = computed(
  () => form.status === 'ACTIVE' && !String(form.imageUrl || '').trim(),
)

const sectionStatuses = ['ACTIVE', 'INACTIVE']
const statusLabels = computed(() => ({
  ACTIVE: m('status.ACTIVE'),
  INACTIVE: m('status.INACTIVE'),
}))
const statusFilters = computed(() => [t('admin.shared.all'), ...sectionStatuses.map((status) => statusLabels.value[status])])
const typeOptions = ['FEATURED_CARD', 'CTA_CARD', 'PRODUCT_CARD', 'LOCATION_CARD']
const typeLabels = computed(() => ({
  FEATURED_CARD: m('types.FEATURED_CARD'),
  CTA_CARD: m('types.CTA_CARD'),
  PRODUCT_CARD: m('types.PRODUCT_CARD'),
  LOCATION_CARD: m('types.LOCATION_CARD'),
}))
const typeFilters = computed(() => [t('admin.shared.all'), ...typeOptions.map((type) => typeLabels.value[type])])
const staticLinkOptions = computed(() => [
  { label: m('staticLinks.home'), value: '/' },
  { label: m('staticLinks.products'), value: '/products' },
  { label: m('staticLinks.locations'), value: '/locations' },
  { label: m('staticLinks.franchise'), value: '/franchise' },
  { label: m('staticLinks.about'), value: '/about' },
  { label: m('staticLinks.blog'), value: '/blog' },
  { label: m('staticLinks.consultation'), value: '/consultation' },
  { label: m('staticLinks.contact'), value: '/contact' },
])
const linkTypeOptions = computed(() => [
  { value: 'NONE', label: m('linkTypes.NONE') },
  { value: 'STATIC', label: m('linkTypes.STATIC') },
  { value: 'PRODUCT', label: m('linkTypes.PRODUCT') },
  { value: 'POST', label: m('linkTypes.POST') },
  { value: 'CUSTOM', label: m('linkTypes.CUSTOM') },
])

const buildDefaultForm = () => ({
  sectionKey: '',
  type: 'FEATURED_CARD',
  title: '',
  subtitle: '',
  description: '',
  imageUrl: '',
  buttonText: '',
  buttonLink: '',
  badge: '',
  sortOrder: 0,
  status: 'ACTIVE',
})

const form = reactive(buildDefaultForm())
const imagePreviewUrl = computed(() => resolveBackendAssetUrl(form.imageUrl || ''))
const resolvedButtonLink = computed(() => {
  if (linkType.value === 'NONE') return ''
  if (linkType.value === 'STATIC') return linkTarget.value
  if (linkType.value === 'PRODUCT') return linkTarget.value ? `/products/${linkTarget.value}` : ''
  if (linkType.value === 'POST') return linkTarget.value ? `/blog/${linkTarget.value}` : ''
  return form.buttonLink.trim()
})
const cardPreview = computed(() => {
  const buttonLink = resolvedButtonLink.value
  const hasLink = Boolean(buttonLink)
  const buttonText = form.buttonText.trim()

  return {
    type: form.type || 'FEATURED_CARD',
    title: form.title || m('placeholders.title'),
    subtitle: form.subtitle.trim(),
    description: form.description || form.subtitle || '',
    cta: linkType.value === 'NONE' ? '' : buttonText || (hasLink ? m('defaults.buttonText') : ''),
    image: imagePreviewUrl.value,
    badge: form.badge || form.subtitle || m('defaults.previewBadge'),
  }
})

const selectedTypeDescription = computed(() => m(`typeDescriptions.${form.type}`) || m('formTabs.typeHint'))

const slugify = (value) =>
  value
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '')

const formatDate = (value) => {
  if (!value) return '—'
  return String(value).replace('T', ' ').slice(0, 16)
}

const sectionImageUrl = (section) => resolveBackendAssetUrl(section.imageUrl || '')

const statusClass = (status) =>
  status === 'ACTIVE'
    ? 'bg-green-50 text-green-700 border-green-200'
    : 'bg-gray-50 text-gray-700 border-gray-200'

const getStatusValue = (label) => Object.entries(statusLabels.value).find(([, value]) => value === label)?.[0] || label

const getTypeValue = (label) => Object.entries(typeLabels.value).find(([, value]) => value === label)?.[0] || label

const resetForm = () => {
  Object.assign(form, buildDefaultForm())
  linkType.value = 'NONE'
  linkTarget.value = ''
  editingId.value = null
  formErrors.value = {}
  sectionKeyTouched.value = false
  modalFormTab.value = 'required'
}

const inferLinkSelection = (link = '') => {
  const normalized = String(link || '').trim()
  if (!normalized) {
    linkType.value = 'NONE'
    linkTarget.value = ''
    return
  }
  if (staticLinkOptions.value.some((option) => option.value === normalized)) {
    linkType.value = 'STATIC'
    linkTarget.value = normalized
    return
  }
  if (normalized.startsWith('/products/')) {
    linkType.value = 'PRODUCT'
    linkTarget.value = normalized.replace('/products/', '')
    return
  }
  if (normalized.startsWith('/blog/')) {
    linkType.value = 'POST'
    linkTarget.value = normalized.replace('/blog/', '')
    return
  }
  linkType.value = 'CUSTOM'
  linkTarget.value = ''
}

const handleLinkTypeChange = () => {
  if (linkType.value === 'NONE') {
    linkTarget.value = ''
    return
  }
  if (linkType.value === 'STATIC') {
    linkTarget.value = '/products'
    return
  }
  if (linkType.value === 'CUSTOM') {
    linkTarget.value = ''
    form.buttonLink = ''
    return
  }
  linkTarget.value = ''
}

const normalizeSection = (section) => ({
  ...section,
  imageUrl: section.imageUrl || '',
  sortOrder: Number(section.sortOrder || 0),
  status: section.status || 'ACTIVE',
  type: section.type || 'FEATURED_CARD',
})

const fetchSections = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const { data } = await homeSectionService.list(false)
    sections.value = Array.isArray(data) ? data.map(normalizeSection) : []
  } catch (error) {
    errorMessage.value = error.response?.data?.message || m('toasts.loadError')
  } finally {
    isLoading.value = false
  }
}

const fetchLinkOptions = async () => {
  isLoadingLinkOptions.value = true
  try {
    const [productResponse, postResponse] = await Promise.all([productService.list(), postService.list()])
    products.value = Array.isArray(productResponse.data) ? productResponse.data : []
    posts.value = Array.isArray(postResponse.data) ? postResponse.data : []
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.linkOptionsError'))
  } finally {
    isLoadingLinkOptions.value = false
  }
}

const openCreateModal = () => {
  mode.value = 'create'
  resetForm()
  showModal.value = true
}

const openEditModal = (section) => {
  mode.value = 'edit'
  editingId.value = section.id
  formErrors.value = {}
  sectionKeyTouched.value = true
  modalFormTab.value = 'required'
  Object.assign(form, {
    ...buildDefaultForm(),
    sectionKey: section.sectionKey || '',
    type: section.type || 'FEATURED_CARD',
    title: section.title || '',
    subtitle: section.subtitle || '',
    description: section.description || '',
    imageUrl: normalizeStorageAssetUrl(section.imageUrl || ''),
    buttonText: section.buttonText || '',
    buttonLink: section.buttonLink || '',
    badge: section.badge || '',
    sortOrder: Number(section.sortOrder || 0),
    status: section.status || 'ACTIVE',
  })
  inferLinkSelection(section.buttonLink || '')
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const handleImageFileChange = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  isUploadingImage.value = true
  try {
    const { data } = await uploadService.image(file)
    form.imageUrl = normalizeStorageAssetUrl(data.url)
    toast.success(m('toasts.imageUploaded'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.imageError'))
  } finally {
    isUploadingImage.value = false
    event.target.value = ''
  }
}

const isDuplicateSectionKey = (sectionKey) =>
  sections.value.some(
    (section) => section.sectionKey === sectionKey.trim() && section.id !== editingId.value,
  )

const isValidUrl = (value) => {
  try {
    const url = new URL(value)
    return ['http:', 'https:'].includes(url.protocol)
  } catch {
    return false
  }
}

const isValidLinkUrl = (value) => {
  const text = String(value || '').trim()
  if (!text) return false
  if (text.startsWith('/')) return true
  return isValidUrl(text)
}

const isValidAssetUrl = (value) => {
  if (!value) return true
  return isValidLinkUrl(value)
}

const validateForm = () => {
  const errors = {}

  if (!form.title.trim()) errors.title = m('validation.title')

  if (mode.value === 'create' && !sectionKeyTouched.value && !form.sectionKey.trim() && form.title.trim()) {
    form.sectionKey = slugify(form.title)
  }
  if (!form.sectionKey.trim()) errors.sectionKey = m('validation.sectionKey')
  else if (isDuplicateSectionKey(form.sectionKey)) errors.sectionKey = m('validation.duplicateKey')

  if (Number.isNaN(Number(form.sortOrder)) || Number(form.sortOrder) < 0) {
    errors.sortOrder = m('validation.sortOrder')
  }

  if (form.imageUrl.trim() && !isValidAssetUrl(form.imageUrl)) {
    errors.imageUrl = m('validation.imageUrl')
  }

  if (linkType.value !== 'NONE') {
    if (!resolvedButtonLink.value) {
      if (linkType.value === 'CUSTOM') errors.customLink = m('validation.customLink')
      else if (linkType.value === 'PRODUCT') errors.linkTarget = m('validation.product')
      else if (linkType.value === 'POST') errors.linkTarget = m('validation.post')
      else errors.linkTarget = m('validation.staticPage')
    } else if (linkType.value === 'CUSTOM' && !isValidLinkUrl(form.buttonLink)) {
      errors.customLink = m('validation.customLinkFormat')
    }
  }

  formErrors.value = errors
  if (Object.keys(errors).length) {
    const firstErrorKey = Object.keys(errors)[0]
    modalFormTab.value = formErrorTabMap[firstErrorKey] || 'required'
  }
  return Object.keys(errors).length === 0
}

const saveSection = async () => {
  if (isSaving.value) return
  if (!validateForm()) return

  const sectionKey = form.sectionKey.trim()
  const payload = {
    sectionKey,
    type: form.type,
    title: form.title.trim(),
    subtitle: form.subtitle.trim(),
    description: form.description.trim(),
    imageUrl: normalizeStorageAssetUrl(form.imageUrl),
    buttonText: linkType.value === 'NONE' ? '' : form.buttonText.trim(),
    buttonLink: resolvedButtonLink.value,
    badge: form.badge.trim(),
    sortOrder: Number(form.sortOrder || 0),
    status: form.status,
  }

  isSaving.value = true
  try {
    const request = editingId.value ? homeSectionService.update(editingId.value, payload) : homeSectionService.create(payload)
    const { data } = await request
    const normalized = normalizeSection(data)
    const index = sections.value.findIndex((item) => item.id === normalized.id)
    if (index === -1) sections.value.unshift(normalized)
    else sections.value.splice(index, 1, normalized)
    toast.success(mode.value === 'create' ? m('toasts.created') : m('toasts.updated'))
    closeModal()
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.saveError'))
  } finally {
    isSaving.value = false
  }
}

const confirmDeleteSection = async () => {
  try {
    await homeSectionService.remove(pendingDeleteId.value)
    sections.value = sections.value.filter((section) => section.id !== pendingDeleteId.value)
    toast.success(m('toasts.deleted'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.deleteError'))
  } finally {
    pendingDeleteId.value = null
  }
}

const filteredSections = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return sections.value
    .filter((section) => {
      const matchesSearch =
        !keyword ||
        section.title?.toLowerCase().includes(keyword) ||
        section.sectionKey?.toLowerCase().includes(keyword) ||
        section.description?.toLowerCase().includes(keyword)
      const matchesStatus = statusFilter.value === t('admin.shared.all') || section.status === getStatusValue(statusFilter.value)
      const matchesType = typeFilter.value === t('admin.shared.all') || section.type === getTypeValue(typeFilter.value)
      return matchesSearch && matchesStatus && matchesType
    })
    .sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0))
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredSections.value.length / pageSize)))
const paginatedSections = computed(() =>
  filteredSections.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)
const listCountText = computed(() => t('admin.shared.totalCount', { count: filteredSections.value.length }))

watch(
  () => form.title,
  (title) => {
    if (mode.value === 'create' && !sectionKeyTouched.value) {
      form.sectionKey = slugify(title)
    }
  },
)

watch([searchQuery, statusFilter, typeFilter], () => {
  currentPage.value = 1
})

watch(totalPages, (value) => {
  currentPage.value = Math.min(currentPage.value, value)
})

onMounted(() => {
  fetchSections()
  fetchLinkOptions()
})
</script>

<template>
  <AdminListPage>
    <AdminNestedShell>
      <AdminShellFrame variant="header" inner="header">
        <AdminPageHeader :title="m('title')">
          <template #actions>
            <a
              href="/"
              target="_blank"
              rel="noopener noreferrer"
              class="admin-list-btn admin-list-btn--outline"
            >
              <ExternalLink class="h-4 w-4" />
              {{ m('previewHomepage') }}
            </a>
            <button class="admin-list-btn admin-list-btn--primary" @click="openCreateModal">
              {{ m('add') }}
            </button>
          </template>
        </AdminPageHeader>
      </AdminShellFrame>

      <AdminShellFrame variant="toolbar" inner="toolbar">
        <SearchFilterBar
          v-model:search="searchQuery"
          v-model:status="statusFilter"
          v-model:extra-filter="typeFilter"
          :search-label="m('filters.searchLabel')"
          :search-placeholder="m('filters.searchPlaceholder')"
          :status-label="t('admin.shared.status')"
          :status-options="statusFilters"
          :extra-label="m('filters.typeLabel')"
          :extra-options="typeFilters"
          :extra-placeholder="m('filters.typeAll')"
        />
      </AdminShellFrame>

      <AdminShellFrame v-if="errorMessage" as="p" variant="alert" class="admin-list-alert">
        {{ errorMessage }}
      </AdminShellFrame>

      <AdminShellFrame v-if="isLoading" variant="body" inner="pad">
        <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
      </AdminShellFrame>

      <AdminShellFrame v-else-if="!filteredSections.length" variant="body" inner="pad">
        <EmptyState :title="m('emptyTitle')" :description="m('emptyDescription')" />
      </AdminShellFrame>

      <AdminShellFrame v-else variant="body" visibility="desktop">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <table class="home-sections-table w-full table-fixed text-left">
            <colgroup>
              <col class="hs-col-image" />
              <col class="hs-col-content" />
              <col class="hs-col-type" />
              <col class="hs-col-link" />
              <col class="hs-col-order" />
              <col class="hs-col-updated" />
              <col class="hs-col-status" />
              <col class="hs-col-actions" />
            </colgroup>
            <thead class="border-b border-slate-200 bg-slate-50 text-xs font-semibold text-slate-600">
              <tr>
                <th class="hs-cell hs-cell--image">{{ m('columns.image') }}</th>
                <th class="hs-cell hs-cell--content">{{ m('columns.content') }}</th>
                <th class="hs-cell hs-cell--type">{{ m('columns.type') }}</th>
                <th class="hs-cell hs-cell--link">{{ m('columns.link') }}</th>
                <th class="hs-cell hs-cell--order">{{ m('columns.sortOrder') }}</th>
                <th class="hs-cell hs-cell--updated">{{ m('columns.updatedAt') }}</th>
                <th class="hs-cell hs-cell--status">{{ m('columns.status') }}</th>
                <th class="hs-cell hs-cell--actions">{{ m('columns.actions') }}</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100 text-[13px]">
              <tr v-for="section in paginatedSections" :key="section.id" class="hover:bg-slate-50/60">
                <td class="hs-cell hs-cell--image">
                  <img v-if="section.imageUrl" :src="sectionImageUrl(section)" :alt="section.title" class="h-14 w-20 rounded-lg object-cover" />
                  <div v-else class="grid h-14 w-20 place-items-center rounded-lg bg-slate-100 text-xs font-semibold text-slate-400">
                    {{ m('defaults.previewBadge') }}
                  </div>
                </td>
                <td class="hs-cell hs-cell--content">
                  <p class="truncate font-semibold text-slate-900">{{ section.title }}</p>
                  <p class="mt-1 truncate text-xs text-slate-500">{{ section.sectionKey }}</p>
                </td>
                <td class="hs-cell hs-cell--type overflow-hidden font-medium text-slate-600">
                  <span class="block truncate">{{ typeLabels[section.type] || section.type }}</span>
                </td>
                <td class="hs-cell hs-cell--link overflow-hidden text-slate-600">
                  <p class="truncate font-medium">{{ section.buttonText || m('linkCell.noButton') }}</p>
                  <p class="truncate text-xs text-slate-400">{{ section.buttonLink || m('linkCell.noLink') }}</p>
                </td>
                <td class="hs-cell hs-cell--order font-medium text-slate-700">{{ section.sortOrder }}</td>
                <td class="hs-cell hs-cell--updated text-xs text-slate-500">{{ formatDate(section.updatedAt) }}</td>
                <td class="hs-cell hs-cell--status overflow-hidden">
                  <span class="inline-flex max-w-full whitespace-nowrap rounded-full border px-2.5 py-1 text-[11px] font-semibold" :class="statusClass(section.status)">
                    {{ statusLabels[section.status] || section.status }}
                  </span>
                </td>
                <td class="hs-cell hs-cell--actions">
                  <div class="flex flex-nowrap justify-end gap-2">
                    <button class="admin-list-btn admin-list-btn--outline shrink-0 !min-h-[32px] !px-2.5 !py-1.5 !text-xs" @click="openEditModal(section)">
                      {{ m('actions.edit') }}
                    </button>
                    <button class="admin-list-btn admin-list-btn--danger shrink-0 !min-h-[32px] !px-2.5 !py-1.5 !text-xs" @click="pendingDeleteId = section.id">
                      {{ m('actions.delete') }}
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="!isLoading && filteredSections.length" variant="body" visibility="mobile">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <template #below>
            <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack">
              <article
                v-for="section in paginatedSections"
                :key="section.id"
                class="admin-shell-mobile-card"
              >
                <div class="flex items-start gap-3">
                  <img
                    v-if="section.imageUrl"
                    :src="resolveBackendAssetUrl(section.imageUrl)"
                    :alt="section.title"
                    class="h-16 w-16 rounded-xl object-cover"
                  />
                  <div class="min-w-0 flex-1">
                    <p class="font-black text-avocado-950">{{ section.title }}</p>
                    <p class="mt-1 text-xs text-slate-500">{{ section.sectionKey }}</p>
                  </div>
                </div>
                <div class="mt-4 flex gap-2">
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 text-xs font-bold text-avocado-700" @click="openEditModal(section)">
                    {{ m('actions.edit') }}
                  </button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 text-xs font-bold text-red-600" @click="pendingDeleteId = section.id">
                    {{ m('actions.delete') }}
                  </button>
                </div>
              </article>
            </div>
          </template>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="filteredSections.length" variant="footer">
        <Pagination
          :page="currentPage"
          :total-pages="totalPages"
          :visible-count="paginatedSections.length"
          :total-count="filteredSections.length"
          :label="m('paginationLabel')"
          @prev="currentPage = Math.max(1, currentPage - 1)"
          @next="currentPage = Math.min(totalPages, currentPage + 1)"
        />
      </AdminShellFrame>
    </AdminNestedShell>

    <BaseModal :show="showModal" :title="mode === 'create' ? m('create') : m('edit')" max-width="max-w-5xl" @close="closeModal">
      <form id="home-section-form" class="grid gap-5" @submit.prevent="saveSection">
        <AdminShellTabs
          v-model="modalFormTab"
          :items="formTabItems"
          :aria-label="m('formTabs.aria')"
        />

        <section v-show="modalFormTab === 'required'" class="home-section-form-panel grid gap-4 rounded-2xl bg-slate-50 p-5 md:grid-cols-2">
          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">{{ m('formSections.basic') }}</h3>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.title') }} *
            <input v-model="form.title" class="admin-input" :placeholder="m('placeholders.title')" />
            <span v-if="formErrors.title" class="text-xs font-bold text-red-600">{{ formErrors.title }}</span>
          </label>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.sectionKey') }} *
            <input
              v-model="form.sectionKey"
              class="admin-input"
              :class="mode === 'edit' ? 'cursor-not-allowed bg-slate-100 text-slate-600' : ''"
              :readonly="mode === 'edit'"
              :placeholder="m('placeholders.sectionKey')"
              @input="sectionKeyTouched = true"
            />
            <span v-if="formErrors.sectionKey" class="text-xs font-bold text-red-600">{{ formErrors.sectionKey }}</span>
            <span v-else-if="mode === 'edit'" class="text-xs font-semibold text-slate-500">{{ m('fields.sectionKeyLocked') }}</span>
          </label>
          <div class="grid grid-cols-2 gap-4 md:col-span-2">
            <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
              {{ m('fields.sortOrder') }}
              <input v-model.number="form.sortOrder" type="number" min="0" class="admin-input" />
              <span v-if="formErrors.sortOrder" class="text-xs font-bold text-red-600">{{ formErrors.sortOrder }}</span>
            </label>
            <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
              {{ m('fields.status') }}
              <select v-model="form.status" class="admin-input cursor-pointer">
                <option value="ACTIVE">{{ statusLabels.ACTIVE }}</option>
                <option value="INACTIVE">{{ statusLabels.INACTIVE }}</option>
              </select>
            </label>
          </div>

          <div class="grid gap-4 md:col-span-2 md:grid-cols-[minmax(0,1fr)_260px]">
            <h3 class="text-lg font-black text-avocado-950 md:col-span-2">{{ m('formSections.image') }}</h3>
            <div class="grid content-start gap-4">
              <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
                {{ m('fields.imageUrl') }}
                <input v-model="form.imageUrl" class="admin-input" :placeholder="m('placeholders.imageUrl')" />
                <span v-if="formErrors.imageUrl" class="text-xs font-bold text-red-600">{{ formErrors.imageUrl }}</span>
                <span v-else-if="showImageWarning" class="text-xs font-bold text-amber-700">{{ m('validation.imageRecommended') }}</span>
              </label>
              <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
                {{ m('fields.imageFile') }}
                <input
                  type="file"
                  accept=".jpg,.jpeg,.jfif,.png,.webp,.gif,image/jpeg,image/png,image/webp,image/gif"
                  class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-600 disabled:cursor-not-allowed disabled:opacity-60"
                  :disabled="isUploadingImage"
                  @change="handleImageFileChange"
                />
                <span v-if="isUploadingImage" class="text-xs font-bold text-avocado-700">{{ m('fields.uploading') }}</span>
              </label>
            </div>
            <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
              <div class="flex aspect-[4/3] items-center justify-center overflow-hidden bg-slate-100">
                <img v-if="imagePreviewUrl" :src="imagePreviewUrl" :alt="m('preview.alt')" class="aspect-[4/3] w-full object-cover" />
                <p v-else class="px-4 text-center text-sm font-bold text-slate-400">{{ m('defaults.noImage') }}</p>
              </div>
            </div>
          </div>
        </section>

        <section v-show="modalFormTab === 'content'" class="home-section-form-panel grid gap-4 rounded-2xl bg-slate-50 p-5 md:grid-cols-2">
          <p class="text-sm text-slate-500 md:col-span-2">{{ m('formTabs.contentHint') }}</p>
          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">{{ m('formSections.content') }}</h3>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.subtitle') }}
            <input v-model="form.subtitle" class="admin-input" :placeholder="m('placeholders.subtitle')" />
          </label>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.badge') }}
            <input v-model="form.badge" class="admin-input" :placeholder="m('placeholders.badge')" />
          </label>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            {{ m('fields.description') }}
            <textarea v-model="form.description" rows="4" class="admin-input resize-none" :placeholder="m('placeholders.description')" />
          </label>

          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">{{ m('formSections.button') }}</h3>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.buttonText') }}
            <input v-model="form.buttonText" class="admin-input" :placeholder="m('placeholders.buttonText')" />
          </label>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.linkType') }}
            <select v-model="linkType" class="admin-input cursor-pointer" @change="handleLinkTypeChange">
              <option v-for="option in linkTypeOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
            </select>
          </label>

          <label v-if="linkType === 'STATIC'" class="grid min-w-0 gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            {{ m('fields.staticPage') }}
            <select v-model="linkTarget" class="admin-input cursor-pointer">
              <option v-for="option in staticLinkOptions" :key="option.value" :value="option.value">{{ option.label }} - {{ option.value }}</option>
            </select>
            <span v-if="formErrors.linkTarget" class="text-xs font-bold text-red-600">{{ formErrors.linkTarget }}</span>
          </label>

          <label v-else-if="linkType === 'PRODUCT'" class="grid min-w-0 gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            {{ m('fields.product') }}
            <select v-model="linkTarget" class="admin-input cursor-pointer" :disabled="isLoadingLinkOptions">
              <option value="">{{ m('placeholders.selectProduct') }}</option>
              <option v-for="product in linkableProducts" :key="product.id" :value="String(product.slug || product.id)">
                {{ product.name }} - /products/{{ product.slug || product.id }}{{ !isActiveProduct(product) ? ` (${m('linkOptions.inactive')})` : '' }}
              </option>
            </select>
            <span v-if="formErrors.linkTarget" class="text-xs font-bold text-red-600">{{ formErrors.linkTarget }}</span>
            <span v-else-if="!linkableProducts.length && !isLoadingLinkOptions" class="text-xs font-semibold text-slate-500">{{ m('linkOptions.noActiveProducts') }}</span>
          </label>

          <label v-else-if="linkType === 'POST'" class="grid min-w-0 gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            {{ m('fields.post') }}
            <select v-model="linkTarget" class="admin-input cursor-pointer" :disabled="isLoadingLinkOptions">
              <option value="">{{ m('placeholders.selectPost') }}</option>
              <option v-for="post in linkablePosts" :key="post.id" :value="String(post.slug || post.id)">
                {{ post.title }} - /blog/{{ post.slug || post.id }}{{ !isPublishedPost(post) ? ` (${m('linkOptions.inactive')})` : '' }}
              </option>
            </select>
            <span v-if="formErrors.linkTarget" class="text-xs font-bold text-red-600">{{ formErrors.linkTarget }}</span>
            <span v-else-if="!linkablePosts.length && !isLoadingLinkOptions" class="text-xs font-semibold text-slate-500">{{ m('linkOptions.noPublishedPosts') }}</span>
          </label>

          <label v-else-if="linkType === 'CUSTOM'" class="grid min-w-0 gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            {{ m('fields.customLink') }}
            <input v-model="form.buttonLink" class="admin-input" :placeholder="m('placeholders.customLink')" />
            <span v-if="formErrors.customLink" class="text-xs font-bold text-red-600">{{ formErrors.customLink }}</span>
          </label>

          <div v-if="linkType !== 'NONE'" class="rounded-xl border border-avocado-100 bg-white px-4 py-3 text-sm font-semibold text-slate-600 md:col-span-2">
            {{ m('fields.linkPreview') }}:
            <span class="font-black text-avocado-800">{{ resolvedButtonLink || m('fields.linkPending') }}</span>
          </div>
        </section>

        <section v-show="modalFormTab === 'preview'" class="home-section-form-panel grid gap-4 rounded-2xl bg-slate-50 p-5">
          <p class="text-sm text-slate-500">{{ m('formTabs.previewHint') }}</p>
          <label class="grid max-w-md gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.type') }}
            <select v-model="form.type" class="admin-input cursor-pointer">
              <option v-for="type in typeOptions" :key="type" :value="type">{{ typeLabels[type] }}</option>
            </select>
            <span class="text-xs font-semibold text-slate-500">{{ selectedTypeDescription }}</span>
          </label>

          <div class="rounded-2xl border border-avocado-100 bg-white p-5">
            <h3 class="text-lg font-black text-avocado-950">{{ m('formSections.preview') }}</h3>
            <div
              class="mt-4 max-w-sm overflow-hidden rounded-3xl border bg-white shadow-sm"
              :class="cardPreview.type === 'LOCATION_CARD' ? 'border-brand-forest/15' : 'border-brand-forest/5'"
            >
              <div
                :class="[
                  'relative overflow-hidden',
                  cardPreview.type === 'PRODUCT_CARD' ? 'aspect-square' : 'aspect-[5/3]',
                ]"
              >
                <div
                  v-if="cardPreview.type === 'CTA_CARD'"
                  class="pointer-events-none absolute inset-0 z-[1] bg-gradient-to-t from-brand-dark/75 via-brand-dark/20 to-transparent"
                />
                <div
                  :class="[
                    'absolute top-4 left-4 z-10 inline-flex items-center gap-1.5 rounded-full px-3.5 py-1.5 text-xs font-bold backdrop-blur-md',
                    cardPreview.type === 'LOCATION_CARD' ? 'bg-brand-forest/90 text-brand-lime' : 'bg-brand-dark/80 text-brand-lime',
                  ]"
                >
                  <MapPin v-if="cardPreview.type === 'LOCATION_CARD'" class="h-3.5 w-3.5" />
                  <ShoppingBag v-else-if="cardPreview.type === 'PRODUCT_CARD'" class="h-3.5 w-3.5" />
                  {{ cardPreview.badge }}
                </div>
                <img v-if="cardPreview.image" :src="cardPreview.image" :alt="cardPreview.title" class="h-full w-full object-cover" />
                <div v-else class="grid h-full place-items-center bg-brand-lime/10 text-2xl font-black text-brand-forest">
                  {{ m('defaults.previewBadge') }}
                </div>
              </div>
              <div
                :class="[
                  'p-5',
                  cardPreview.type === 'CTA_CARD' ? 'bg-gradient-to-b from-white to-brand-cream/40' : '',
                ]"
              >
                <p
                  v-if="cardPreview.type === 'PRODUCT_CARD' && cardPreview.subtitle"
                  class="text-[11px] font-black uppercase tracking-[0.18em] text-brand-forest"
                >
                  {{ cardPreview.subtitle }}
                </p>
                <h4 class="text-xl font-bold text-brand-dark">{{ cardPreview.title }}</h4>
                <p class="mt-2.5 line-clamp-2 min-h-11 text-sm font-medium leading-relaxed text-brand-muted">{{ cardPreview.description }}</p>
                <div v-if="cardPreview.cta" class="mt-5 flex items-center border-t border-slate-50 pt-4">
                  <span
                    v-if="cardPreview.type === 'CTA_CARD'"
                    class="inline-flex items-center gap-1.5 rounded-full bg-brand-lime px-4 py-2 text-xs font-black uppercase tracking-wider text-brand-dark shadow-sm"
                  >
                    {{ cardPreview.cta }}
                    <ArrowRight class="h-4 w-4" />
                  </span>
                  <span
                    v-else-if="cardPreview.type === 'PRODUCT_CARD'"
                    class="inline-flex items-center gap-1.5 rounded-full bg-brand-lime/15 px-3.5 py-1.5 text-xs font-black uppercase tracking-wider text-brand-forest"
                  >
                    {{ cardPreview.cta }}
                    <ArrowRight class="h-4 w-4" />
                  </span>
                  <span
                    v-else
                    class="inline-flex items-center gap-1.5 text-xs font-black uppercase tracking-wider text-brand-forest"
                  >
                    {{ cardPreview.cta }}
                    <ArrowRight class="h-4 w-4" />
                  </span>
                </div>
              </div>
            </div>
          </div>
        </section>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-lg border border-slate-200 px-4 py-3 font-bold text-slate-600 hover:bg-slate-50" @click="closeModal">{{ m('actions.cancel') }}</button>
          <button
            class="rounded-lg bg-brand-forest px-4 py-3 font-black text-white hover:bg-avocado-800 disabled:cursor-not-allowed disabled:opacity-60"
            form="home-section-form"
            type="submit"
            :disabled="isUploadingImage || isSaving"
          >
            {{ mode === 'create' ? m('actions.saveCreate') : m('actions.saveUpdate') }}
          </button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal
      :show="pendingDeleteId !== null"
      :title="m('confirmDelete.title')"
      :message="m('confirmDelete.message')"
      :confirm-text="m('confirmDelete.confirm')"
      @cancel="pendingDeleteId = null"
      @confirm="confirmDeleteSection"
    />
  </AdminListPage>
</template>

<style scoped>
.home-sections-table .hs-col-image { width: 88px; }
.home-sections-table .hs-col-content { width: 22%; }
.home-sections-table .hs-col-type { width: 11%; }
.home-sections-table .hs-col-link { width: 17%; }
.home-sections-table .hs-col-order { width: 64px; }
.home-sections-table .hs-col-updated { width: 11%; }
.home-sections-table .hs-col-status { width: 13%; }
.home-sections-table .hs-col-actions { width: 150px; }

.home-sections-table .hs-cell {
  padding-top: 10px;
  padding-bottom: 10px;
  vertical-align: middle;
}

.home-sections-table .hs-cell--image {
  padding-left: 16px;
  padding-right: 8px;
}

.home-sections-table .hs-cell--content {
  padding-left: 12px;
  padding-right: 16px;
}

.home-sections-table .hs-cell--type {
  padding-left: 12px;
  padding-right: 12px;
}

.home-sections-table .hs-cell--link {
  padding-left: 12px;
  padding-right: 14px;
}

.home-sections-table .hs-cell--order {
  padding-left: 8px;
  padding-right: 8px;
  text-align: center;
}

.home-sections-table .hs-cell--updated {
  padding-left: 10px;
  padding-right: 10px;
}

.home-sections-table .hs-cell--status {
  padding-left: 10px;
  padding-right: 12px;
}

.home-sections-table .hs-cell--actions {
  padding-left: 10px;
  padding-right: 16px;
  text-align: right;
}

.home-section-form-panel {
  min-height: 280px;
}
</style>
