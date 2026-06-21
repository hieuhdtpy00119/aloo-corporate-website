<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { ArrowRight, ExternalLink } from 'lucide-vue-next'
import BaseModal from '../../components/admin/BaseModal.vue'
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
const isLoadingLinkOptions = ref(false)
const linkType = ref('CUSTOM')
const linkTarget = ref('')
const products = ref([])
const posts = ref([])
const pageSize = 6

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
  subtitle: m('defaults.subtitle'),
  description: '',
  imageUrl: '',
  buttonText: m('defaults.buttonText'),
  buttonLink: '/',
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
const cardPreview = computed(() => ({
  title: form.title || m('placeholders.title'),
  description: form.description || form.subtitle || '',
  cta: linkType.value === 'NONE' ? '' : form.buttonText || m('defaults.buttonText'),
  to: resolvedButtonLink.value || '/',
  image: imagePreviewUrl.value,
  badge: form.badge || form.subtitle || m('defaults.previewBadge'),
}))

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
  linkType.value = 'CUSTOM'
  linkTarget.value = ''
  editingId.value = null
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
    if (!form.buttonText.trim()) form.buttonText = m('defaults.buttonText')
    return
  }
  linkTarget.value = ''
  if (linkType.value === 'PRODUCT' && !form.buttonText.trim()) form.buttonText = m('placeholders.buttonText')
  if (linkType.value === 'POST' && !form.buttonText.trim()) form.buttonText = m('defaults.buttonText')
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

const saveSection = async () => {
  const sectionKey = form.sectionKey.trim()
  if (!sectionKey || !form.title.trim()) {
    toast.error(m('toasts.requiredFields'))
    return
  }
  if (isDuplicateSectionKey(sectionKey)) {
    toast.error(m('toasts.duplicateKey'))
    return
  }
  if (linkType.value !== 'NONE' && form.buttonText.trim() && !resolvedButtonLink.value) {
    toast.error(m('toasts.linkRequired'))
    return
  }

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

watch(
  () => form.title,
  (title) => {
    if (mode.value === 'create' && !form.sectionKey) form.sectionKey = slugify(title)
  },
)

watch([searchQuery, statusFilter, typeFilter], () => {
  currentPage.value = 1
})

onMounted(() => {
  fetchSections()
  fetchLinkOptions()
})
</script>

<template>
  <section>
    <AdminPageHeader :title="m('title')" :description="m('description')">
      <template #actions>
        <a
          href="/"
          target="_blank"
          rel="noopener noreferrer"
          class="aloo-btn aloo-btn--secondary inline-flex items-center gap-2"
        >
          <ExternalLink class="h-4 w-4" />
          {{ m('previewHomepage') }}
        </a>
        <button class="aloo-btn aloo-btn--primary" @click="openCreateModal">
          {{ m('add') }}
        </button>
      </template>
    </AdminPageHeader>

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

    <p v-if="errorMessage" class="mb-4 rounded-lg bg-red-50 px-4 py-3 text-sm font-bold text-red-700">{{ errorMessage }}</p>

    <div class="hidden overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm lg:block">
      <div class="overflow-x-auto">
        <table v-if="!isLoading && filteredSections.length" class="min-w-[1080px] w-full table-fixed whitespace-nowrap text-left">
          <colgroup>
            <col class="w-[10%]" />
            <col class="w-[22%]" />
            <col class="w-[12%]" />
            <col class="w-[18%]" />
            <col class="w-[8%]" />
            <col class="w-[12%]" />
            <col class="w-[10%]" />
            <col class="w-[8%]" />
          </colgroup>
          <thead class="bg-slate-50 text-sm font-black text-slate-600">
            <tr>
              <th class="px-5 py-4">{{ m('columns.image') }}</th>
              <th class="px-5 py-4">{{ m('columns.content') }}</th>
              <th class="px-5 py-4">{{ m('columns.type') }}</th>
              <th class="px-5 py-4">{{ m('columns.link') }}</th>
              <th class="px-5 py-4">{{ m('columns.sortOrder') }}</th>
              <th class="px-5 py-4">{{ m('columns.updatedAt') }}</th>
              <th class="px-5 py-4">{{ m('columns.status') }}</th>
              <th class="px-5 py-4 text-right">{{ m('columns.actions') }}</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100 text-sm">
            <tr v-for="section in paginatedSections" :key="section.id" class="hover:bg-slate-50/70">
              <td class="px-5 py-4">
                <img v-if="section.imageUrl" :src="sectionImageUrl(section)" :alt="section.title" class="h-14 w-20 rounded-xl object-cover" />
                <div v-else class="grid h-14 w-20 place-items-center rounded-xl bg-slate-100 text-xs font-black text-slate-400">
                  {{ m('defaults.previewBadge') }}
                </div>
              </td>
              <td class="px-5 py-4">
                <p class="truncate font-black text-avocado-950">{{ section.title }}</p>
                <p class="mt-1 truncate text-xs font-semibold text-slate-500">{{ section.sectionKey }}</p>
              </td>
              <td class="px-5 py-4 font-bold text-slate-600">{{ typeLabels[section.type] || section.type }}</td>
              <td class="px-5 py-4 text-slate-600">
                <p class="truncate font-bold">{{ section.buttonText || m('linkCell.noButton') }}</p>
                <p class="truncate text-xs text-slate-400">{{ section.buttonLink || m('linkCell.noLink') }}</p>
              </td>
              <td class="px-5 py-4 font-bold text-slate-700">{{ section.sortOrder }}</td>
              <td class="px-5 py-4 text-xs font-semibold text-slate-500">{{ formatDate(section.updatedAt) }}</td>
              <td class="px-5 py-4">
                <span class="inline-flex min-w-[122px] justify-center rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(section.status)">
                  {{ statusLabels[section.status] || section.status }}
                </span>
              </td>
              <td class="px-5 py-4">
                <div class="flex justify-end gap-2">
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 font-bold text-avocado-700 hover:bg-avocado-50" @click="openEditModal(section)">
                    {{ m('actions.edit') }}
                  </button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600 hover:bg-red-50" @click="pendingDeleteId = section.id">
                    {{ m('actions.delete') }}
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        <div v-else-if="isLoading" class="grid gap-4 p-6 sm:grid-cols-2 lg:grid-cols-3" aria-busy="true">
          <div v-for="index in 3" :key="index" class="animate-pulse rounded-2xl border border-slate-100 p-4">
            <div class="h-14 w-20 rounded-xl bg-slate-100"></div>
            <div class="mt-4 h-4 w-2/3 rounded bg-slate-100"></div>
            <div class="mt-2 h-3 w-1/2 rounded bg-slate-100"></div>
          </div>
        </div>
        <EmptyState v-else :title="m('emptyTitle')" :description="m('emptyDescription')" />
      </div>
    </div>

    <div class="grid gap-4 lg:hidden">
      <div v-if="isLoading" class="grid gap-3">
        <div v-for="i in 3" :key="i" class="h-28 animate-pulse rounded-2xl bg-slate-100" />
      </div>
      <article
        v-for="section in paginatedSections"
        v-else-if="filteredSections.length"
        :key="section.id"
        class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm"
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

    <Pagination
      v-if="filteredSections.length"
      :page="currentPage"
      :total-pages="totalPages"
      :visible-count="paginatedSections.length"
      :total-count="filteredSections.length"
      :label="m('paginationLabel')"
      @prev="currentPage = Math.max(1, currentPage - 1)"
      @next="currentPage = Math.min(totalPages, currentPage + 1)"
    />

    <BaseModal :show="showModal" :title="mode === 'create' ? m('create') : m('edit')" max-width="max-w-5xl" @close="closeModal">
      <form id="home-section-form" class="grid gap-6" @submit.prevent="saveSection">
        <section class="grid gap-4 rounded-2xl bg-slate-50 p-5 md:grid-cols-2">
          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">{{ m('formSections.basic') }}</h3>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.title') }} *
            <input v-model="form.title" required class="admin-input" :placeholder="m('placeholders.title')" />
          </label>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.sectionKey') }} *
            <input
              v-model="form.sectionKey"
              required
              class="admin-input"
              :class="mode === 'edit' ? 'cursor-not-allowed bg-slate-100 text-slate-600' : ''"
              :readonly="mode === 'edit'"
              :placeholder="m('placeholders.sectionKey')"
            />
            <span v-if="mode === 'edit'" class="text-xs font-semibold text-slate-500">{{ m('fields.sectionKeyLocked') }}</span>
          </label>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
            {{ m('fields.type') }}
            <select v-model="form.type" class="admin-input cursor-pointer">
              <option v-for="type in typeOptions" :key="type" :value="type">{{ typeLabels[type] }}</option>
            </select>
          </label>
          <div class="grid grid-cols-2 gap-4">
            <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
              {{ m('fields.sortOrder') }}
              <input v-model.number="form.sortOrder" type="number" min="0" class="admin-input" />
            </label>
            <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
              {{ m('fields.status') }}
              <select v-model="form.status" class="admin-input cursor-pointer">
                <option value="ACTIVE">{{ statusLabels.ACTIVE }}</option>
                <option value="INACTIVE">{{ statusLabels.INACTIVE }}</option>
              </select>
            </label>
          </div>
        </section>

        <section class="grid gap-4 rounded-2xl bg-slate-50 p-5 md:grid-cols-2">
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
        </section>

        <section class="grid gap-4 rounded-2xl bg-slate-50 p-5 md:grid-cols-2">
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
          </label>

          <label v-else-if="linkType === 'PRODUCT'" class="grid min-w-0 gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            {{ m('fields.product') }}
            <select v-model="linkTarget" class="admin-input cursor-pointer" :disabled="isLoadingLinkOptions">
              <option value="">{{ m('placeholders.selectProduct') }}</option>
              <option v-for="product in products" :key="product.id" :value="String(product.slug || product.id)">
                {{ product.name }} - /products/{{ product.slug }}
              </option>
            </select>
          </label>

          <label v-else-if="linkType === 'POST'" class="grid min-w-0 gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            {{ m('fields.post') }}
            <select v-model="linkTarget" class="admin-input cursor-pointer" :disabled="isLoadingLinkOptions">
              <option value="">{{ m('placeholders.selectPost') }}</option>
              <option v-for="post in posts" :key="post.id" :value="String(post.slug || post.id)">
                {{ post.title }} - /blog/{{ post.slug || post.id }}
              </option>
            </select>
          </label>

          <label v-else-if="linkType === 'CUSTOM'" class="grid min-w-0 gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            {{ m('fields.customLink') }}
            <input v-model="form.buttonLink" class="admin-input" :placeholder="m('placeholders.customLink')" />
          </label>

          <div v-if="linkType !== 'NONE'" class="rounded-xl border border-avocado-100 bg-white px-4 py-3 text-sm font-semibold text-slate-600 md:col-span-2">
            {{ m('fields.linkPreview') }}:
            <span class="font-black text-avocado-800">{{ resolvedButtonLink || m('fields.linkPending') }}</span>
          </div>
        </section>

        <section class="grid gap-4 rounded-2xl bg-slate-50 p-5 md:grid-cols-[minmax(0,1fr)_260px]">
          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">{{ m('formSections.image') }}</h3>
          <div class="grid content-start gap-4">
            <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
              {{ m('fields.imageUrl') }}
              <input v-model="form.imageUrl" class="admin-input" :placeholder="m('placeholders.imageUrl')" />
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
        </section>

        <section class="rounded-2xl border border-avocado-100 bg-white p-5">
          <h3 class="text-lg font-black text-avocado-950">{{ m('formSections.preview') }}</h3>
          <div class="mt-4 max-w-sm overflow-hidden rounded-3xl border border-brand-forest/5 bg-white shadow-sm">
            <div class="relative aspect-[5/3] overflow-hidden">
              <div class="absolute top-4 left-4 z-10 rounded-full bg-brand-dark/80 px-3.5 py-1.5 text-xs font-bold text-brand-lime backdrop-blur-md">
                {{ cardPreview.badge }}
              </div>
              <img v-if="cardPreview.image" :src="cardPreview.image" :alt="cardPreview.title" class="h-full w-full object-cover" />
              <div v-else class="grid h-full place-items-center bg-brand-lime/10 text-2xl font-black text-brand-forest">
                {{ m('defaults.previewBadge') }}
              </div>
            </div>
            <div class="p-5">
              <h4 class="text-xl font-bold text-brand-dark">{{ cardPreview.title }}</h4>
              <p class="mt-2.5 line-clamp-2 min-h-11 text-sm font-medium leading-relaxed text-brand-muted">{{ cardPreview.description }}</p>
              <div v-if="cardPreview.cta" class="mt-5 flex items-center border-t border-slate-50 pt-4">
                <span class="inline-flex items-center gap-1.5 text-xs font-black uppercase tracking-wider text-brand-forest">
                  {{ cardPreview.cta }}
                  <ArrowRight class="h-4 w-4" />
                </span>
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
            :disabled="isUploadingImage"
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
  </section>
</template>

<style scoped>
.admin-input {
  width: 100%;
  border-radius: 0.75rem;
  border: 1px solid rgb(226, 232, 240);
  background: white;
  padding: 0.75rem 1rem;
  color: rgb(51, 65, 85);
  font-size: 0.875rem;
  font-weight: 600;
  outline: none;
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

.admin-input:focus {
  border-color: rgb(126, 199, 90);
  box-shadow: 0 0 0 3px rgba(112, 149, 107, 0.12);
}
</style>
