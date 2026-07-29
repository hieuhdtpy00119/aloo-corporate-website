<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import AdminShellFrame from '../shell/AdminShellFrame.vue'
import AdminShellTablePanel from '../shell/AdminShellTablePanel.vue'
import AdminShellTabs from '../shell/AdminShellTabs.vue'
import BaseModal from '../BaseModal.vue'
import ConfirmModal from '../ConfirmModal.vue'
import EmptyState from '../EmptyState.vue'
import Pagination from '../Pagination.vue'
import SearchFilterBar from '../SearchFilterBar.vue'
import { normalizeStorageAssetUrl, resolveBackendAssetUrl, uploadService } from '../../../services/cmsService'
import { useAdminModuleI18n } from '../../../composables/useAdminModuleI18n'
import { useAppStore } from '../../../stores/appStore'
import { useToastStore } from '../../../stores/toastStore'
import { Edit2, Trash2, Image, Link } from 'lucide-vue-next'
import ProductImage from '../../public/ProductImage.vue'
import AvatarCropModal from '../../shared/AvatarCropModal.vue'

const { m, t } = useAdminModuleI18n('products')
const store = useAppStore()
const toast = useToastStore()

const showModal = ref(false)
const mode = ref('create')
const editingId = ref(null)
const pendingDeleteId = ref(null)
const searchQuery = ref('')
const statusFilter = ref(t('admin.shared.all'))
const currentPage = ref(1)
const isUploadingImage = ref(false)
const isUploadingGallery = ref(false)
const isSaving = ref(false)
const pageSize = 6
const formErrors = ref({})
const slugTouched = ref(false)
const modalFormTab = ref('required')
const showProductCropper = ref(false)
const productCropperSrc = ref('')
const productCropperFileName = ref('product.jpg')
const originalFeatured = ref(false)
const originalFeaturedOrder = ref(0)

const isLoading = computed(() => store.loading.products)
const errorMessage = computed(() => store.errors.products)
const productStatuses = ['ACTIVE', 'INACTIVE']
const statusLabels = computed(() => ({
  ACTIVE: m('status.ACTIVE'),
  INACTIVE: m('status.INACTIVE'),
}))
const statusFilters = computed(() => [t('admin.shared.all'), ...productStatuses.map((status) => statusLabels.value[status])])
const categoryOptions = computed(() =>
  [
    ...new Set(
      store.categories
        .filter((category) => category.status === 'ACTIVE' && category.type === 'PRODUCT')
        .map((category) => category.name),
    ),
  ].filter(Boolean),
)

const formTabItems = computed(() => [
  { key: 'required', label: m('formTabs.required') },
  { key: 'content', label: m('formTabs.content') },
  { key: 'mediaSeo', label: m('formTabs.mediaSeo') },
])

const formErrorTabMap = {
  name: 'required',
  slug: 'required',
  featured: 'required',
  featuredOrder: 'required',
  imageUrl: 'required',
  gallery: 'mediaSeo',
  faqs: 'mediaSeo',
  seoTitle: 'mediaSeo',
  seoDescription: 'mediaSeo',
}

const defaultProductForm = () => ({
  name: '',
  slug: '',
  description: '',
  imageUrl: '',
  category: '',
  price: 0,
  status: 'ACTIVE',
  sortOrder: 0,
  shortDescription: '',
  detailContent: '',
  ingredients: '',
  tasteProfile: '',
  servingSuggestion: '',
  gallery: '',
  faqs: '',
  featured: false,
  seoTitle: '',
  seoDescription: '',
})

const form = reactive(defaultProductForm())

const formImagePreviewUrl = computed(() => resolveBackendAssetUrl(form.imageUrl || ''))
const formGalleryLines = computed(() =>
  String(form.gallery || '')
    .split(/\r?\n/)
    .map((url) => url.trim())
    .filter(Boolean),
)

const formGalleryPreviewUrls = computed(() =>
  formGalleryLines.value.map((url) => ({
    raw: url,
    preview: resolveBackendAssetUrl(url),
  })),
)

const showImageWarning = computed(
  () => form.status === 'ACTIVE' && !String(form.imageUrl || '').trim(),
)

const productCardPreview = computed(() => ({
  name: form.name.trim() || m('placeholders.name'),
  category: form.category.trim() || m('fieldHints.noCategory'),
  description: form.shortDescription.trim() || form.description.trim() || m('misc.noDescription'),
  image: formImagePreviewUrl.value,
}))

const usedFeaturedOrders = computed(() =>
  new Set(
    store.products
      .filter(
        (product) =>
          product.id !== editingId.value &&
          product.featured &&
          ['ACTIVE', 'Đang bán'].includes(product.status),
      )
      .map((product) => Number(product.sortOrder))
      .filter((order) => order >= 1 && order <= 5),
  ),
)

const handleFeaturedChange = () => {
  if (!form.featured) {
    form.sortOrder = 0
    return
  }
  const currentOrder = Number(form.sortOrder)
  if (currentOrder >= 1 && currentOrder <= 5 && !usedFeaturedOrders.value.has(currentOrder)) return
  form.sortOrder = [1, 2, 3, 4, 5].find((order) => !usedFeaturedOrders.value.has(order)) || 1
}

const slugify = (value) =>
  value
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '')

const normalizeGalleryForStorage = (gallery) =>
  String(gallery || '')
    .split(/\r?\n/)
    .map((url) => normalizeStorageAssetUrl(url.trim()))
    .filter(Boolean)
    .join('\n')

const productPublicUrl = (slug) => (slug?.trim() ? `/products/${encodeURIComponent(slug.trim())}` : '')

const isValidUrl = (value) => {
  try {
    const url = new URL(value)
    return ['http:', 'https:'].includes(url.protocol)
  } catch {
    return false
  }
}

const isValidAssetUrl = (value) => {
  const text = String(value || '').trim()
  if (!text) return true
  if (text.startsWith('/')) return true
  return isValidUrl(text)
}

const isValidFaqLine = (line) => {
  const [question, ...answerParts] = String(line).split('|')
  return Boolean(question?.trim() && answerParts.join('|').trim())
}

const isDuplicateSlug = (slug) => {
  const normalized = slug.trim().toLowerCase()
  return store.products.some(
    (product) => String(product.slug || '').toLowerCase() === normalized && product.id !== editingId.value,
  )
}

const resetForm = () => {
  Object.assign(form, defaultProductForm())
  editingId.value = null
  originalFeatured.value = false
  originalFeaturedOrder.value = 0
  formErrors.value = {}
  slugTouched.value = false
  modalFormTab.value = 'required'
}

const openCreateModal = () => {
  mode.value = 'create'
  resetForm()
  showModal.value = true
}

const openEditModal = (product) => {
  mode.value = 'edit'
  editingId.value = product.id
  originalFeatured.value = Boolean(product.featured)
  originalFeaturedOrder.value = Number(product.sortOrder || 0)
  formErrors.value = {}
  slugTouched.value = true
  modalFormTab.value = 'required'
  Object.assign(form, {
    ...defaultProductForm(),
    name: product.name || '',
    slug: product.slug || '',
    description: product.description || '',
    imageUrl: normalizeStorageAssetUrl(product.imageUrl || product.image || ''),
    category: product.category || '',
    price: Number(product.price ?? 0),
    status: product.status || 'ACTIVE',
    sortOrder: Number(product.sortOrder || 0),
    shortDescription: product.shortDescription || '',
    detailContent: product.detailContent || '',
    ingredients: product.ingredients || '',
    tasteProfile: product.tasteProfile || '',
    servingSuggestion: product.servingSuggestion || '',
    gallery: normalizeGalleryForStorage(product.gallery || ''),
    faqs: product.faqs || '',
    featured: Boolean(product.featured),
    seoTitle: product.seoTitle || '',
    seoDescription: product.seoDescription || '',
  })
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const validateForm = () => {
  const errors = {}

  if (!form.name.trim()) errors.name = m('validation.name')
  if (mode.value === 'create' && !slugTouched.value && !form.slug.trim() && form.name.trim()) {
    form.slug = slugify(form.name)
  }
  if (!form.slug.trim()) errors.slug = m('validation.slug')
  else if (isDuplicateSlug(form.slug)) errors.slug = m('validation.duplicateSlug')

  if (Number.isNaN(Number(form.price)) || Number(form.price) < 0) {
    errors.price = m('validation.price')
  }
  const featuredOrder = Number(form.sortOrder)
  if (form.featured && (!Number.isInteger(featuredOrder) || featuredOrder < 1 || featuredOrder > 5)) {
    errors.featuredOrder = m('validation.featuredOrder')
  }

  if (form.imageUrl.trim() && !isValidAssetUrl(form.imageUrl)) {
    errors.imageUrl = m('validation.imageUrl')
  }

  for (const url of formGalleryLines.value) {
    if (!isValidAssetUrl(url)) {
      errors.gallery = m('validation.gallery')
      break
    }
  }

  const faqLines = String(form.faqs || '')
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean)
  if (faqLines.some((line) => !isValidFaqLine(line))) {
    errors.faqs = m('validation.faqs')
  }

  if (form.seoTitle.trim().length > 260) errors.seoTitle = m('validation.seoTitle')
  if (form.seoDescription.trim().length > 500) errors.seoDescription = m('validation.seoDescription')

  formErrors.value = errors
  if (Object.keys(errors).length) {
    const firstErrorKey = Object.keys(errors)[0]
    modalFormTab.value = formErrorTabMap[firstErrorKey] || 'required'
  }
  return Object.keys(errors).length === 0
}

const handleImageFileChange = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  productCropperFileName.value = file.name
  const reader = new FileReader()
  reader.onload = () => {
    productCropperSrc.value = String(reader.result || '')
    showProductCropper.value = true
  }
  reader.onerror = () => toast.error(m('toasts.imageUploadError'))
  reader.readAsDataURL(file)
  event.target.value = ''
}

const handleCroppedProductImage = async (file) => {
  showProductCropper.value = false
  isUploadingImage.value = true
  try {
    const { data } = await uploadService.image(file)
    form.imageUrl = normalizeStorageAssetUrl(data.url)
    toast.success(m('toasts.imageUploaded'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.imageUploadError'))
  } finally {
    isUploadingImage.value = false
    productCropperSrc.value = ''
  }
}

const allowedGalleryExtensions = ['jpg', 'jpeg', 'jfif', 'png', 'webp', 'gif']
const maxGalleryFileSize = 5 * 1024 * 1024

const imageUploadErrorMessage = (error) =>
  error.response?.data?.message || error.response?.data?.error || error.message || m('uploadErrors.imageUploadFailed')

const validateGalleryFile = (file) => {
  const extension = file.name.split('.').pop()?.toLowerCase() || ''
  if (!allowedGalleryExtensions.includes(extension)) {
    return m('uploadErrors.unsupportedFormat', {
      extension: extension || m('uploadErrors.unknownExtension'),
    })
  }
  if (file.size > maxGalleryFileSize) {
    return m('uploadErrors.fileTooLarge')
  }
  if (file.type && !file.type.startsWith('image/')) {
    return m('uploadErrors.notAnImage')
  }
  return ''
}

const handleGalleryFilesChange = async (event) => {
  const files = Array.from(event.target.files || [])
  if (!files.length) return

  const validFiles = []
  const skippedFiles = []
  files.forEach((file) => {
    const reason = validateGalleryFile(file)
    if (reason) skippedFiles.push(`${file.name}: ${reason}`)
    else validFiles.push(file)
  })

  if (!validFiles.length) {
    toast.error(skippedFiles.slice(0, 2).join('\n') || m('toasts.galleryNoValid'))
    event.target.value = ''
    return
  }

  isUploadingGallery.value = true
  try {
    const results = await Promise.allSettled(validFiles.map((file) => uploadService.image(file)))
    const uploadedUrls = results
      .filter((result) => result.status === 'fulfilled' && result.value.data?.url)
      .map((result) => normalizeStorageAssetUrl(result.value.data.url))

    const failedFiles = results
      .map((result, index) => ({ result, file: validFiles[index] }))
      .filter(({ result }) => result.status === 'rejected')
      .map(({ result, file }) => `${file.name}: ${imageUploadErrorMessage(result.reason)}`)

    if (uploadedUrls.length) {
      const currentUrls = String(form.gallery || '')
        .split(/\r?\n/)
        .map((url) => url.trim())
        .filter(Boolean)
      form.gallery = [...currentUrls, ...uploadedUrls]
        .filter((url, index, all) => all.indexOf(url) === index)
        .join('\n')
      toast.success(m('toasts.galleryUploaded', { count: uploadedUrls.length }))
    }

    const errors = [...skippedFiles, ...failedFiles]
    if (errors.length) {
      toast.error(errors.slice(0, 2).join('\n'))
    }
  } finally {
    isUploadingGallery.value = false
    event.target.value = ''
  }
}

const removeGalleryImage = (indexToRemove) => {
  form.gallery = formGalleryLines.value
    .filter((_, index) => index !== indexToRemove)
    .join('\n')
  toast.success(m('toasts.galleryRemoved'))
}

const statusClass = (status) =>
  status === 'ACTIVE'
    ? 'border-emerald-200 bg-emerald-50 text-emerald-700'
    : 'border-slate-200 bg-slate-50 text-slate-500'

const getStatusValue = (label) =>
  Object.entries(statusLabels.value).find(([, value]) => value === label)?.[0] || label

const filteredProducts = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return store.products.filter((product) => {
    const matchesSearch =
      !keyword ||
      product.name?.toLowerCase().includes(keyword) ||
      product.slug?.toLowerCase().includes(keyword) ||
      product.category?.toLowerCase().includes(keyword)
    const matchesStatus = statusFilter.value === t('admin.shared.all') || product.status === getStatusValue(statusFilter.value)
    return matchesSearch && matchesStatus
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredProducts.value.length / pageSize)))
const paginatedProducts = computed(() =>
  filteredProducts.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)
const listCountText = computed(() => t('admin.shared.totalCount', { count: filteredProducts.value.length }))

const saveProduct = async () => {
  if (isSaving.value) return
  if (!validateForm()) return

  isSaving.value = true
  try {
    const targetOrder = Number(form.sortOrder || 0)
    const conflictingProduct = form.featured
      ? store.products.find(
          (product) =>
            product.id !== editingId.value &&
            product.featured &&
            ['ACTIVE', 'Đang bán'].includes(product.status) &&
            Number(product.sortOrder) === targetOrder,
        )
      : null

    if (conflictingProduct) {
      const shouldSwap =
        originalFeatured.value &&
        originalFeaturedOrder.value >= 1 &&
        originalFeaturedOrder.value <= 5 &&
        originalFeaturedOrder.value !== targetOrder
      await store.saveProduct({
        ...conflictingProduct,
        featured: shouldSwap,
        sortOrder: shouldSwap ? originalFeaturedOrder.value : 0,
      })
    }

    await store.saveProduct({
      id: editingId.value,
      ...form,
      imageUrl: normalizeStorageAssetUrl(form.imageUrl),
      gallery: normalizeGalleryForStorage(form.gallery),
      sortOrder: Number(form.sortOrder || 0),
    })
    toast.success(mode.value === 'create' ? m('toasts.productCreated') : m('toasts.productUpdated'))
    closeModal()
  } catch (error) {
    const message = error.response?.data?.message || m('toasts.productSaveError')
    if (String(message).toLowerCase().includes('slug')) {
      formErrors.value = { ...formErrors.value, slug: m('validation.duplicateSlug') }
      modalFormTab.value = 'required'
    }
    toast.error(message)
  } finally {
    isSaving.value = false
  }
}

const confirmDeleteProduct = async () => {
  try {
    await store.deleteProduct(pendingDeleteId.value)
    toast.success(m('toasts.productDeleted'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.productDeleteError'))
  } finally {
    pendingDeleteId.value = null
  }
}

watch(
  () => form.name,
  (name) => {
    if (mode.value === 'create' && !slugTouched.value) {
      form.slug = slugify(name)
    }
  },
)

watch([searchQuery, statusFilter], () => {
  currentPage.value = 1
})

watch(totalPages, (value) => {
  currentPage.value = Math.min(currentPage.value, value)
})

onMounted(() => {
  Promise.allSettled([store.fetchProducts(), store.fetchCategories()]).then((results) => {
    if (results.some((result) => result.status === 'rejected')) {
      toast.error(m('toasts.partialLoadError'))
    }
  })
})

defineExpose({ openCreate: openCreateModal })
</script>

<template>
  <AdminShellFrame variant="toolbar" inner="toolbar">
    <SearchFilterBar
      v-model:search="searchQuery"
      v-model:status="statusFilter"
      :search-label="m('filters.productsSearchLabel')"
      :search-placeholder="m('filters.productsSearchPlaceholder')"
      :status-label="m('filters.productsStatusLabel')"
      :status-options="statusFilters"
    />
  </AdminShellFrame>

  <AdminShellFrame v-if="errorMessage" as="p" variant="alert" class="admin-list-alert">
    {{ errorMessage }}
  </AdminShellFrame>

  <AdminShellFrame v-if="isLoading" variant="body" inner="pad">
    <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
  </AdminShellFrame>

  <AdminShellFrame v-else-if="!filteredProducts.length" variant="body" inner="pad">
    <EmptyState :message="m('empty')" />
  </AdminShellFrame>

  <AdminShellFrame v-else variant="body" visibility="desktop">
    <AdminShellTablePanel :title="m('tabs.products')" :count-text="listCountText">
      <table class="admin-shell-table">
        <colgroup>
          <col style="width: 9%" />
          <col style="width: 28%" />
          <col style="width: 18%" />
          <col style="width: 18%" />
          <col style="width: 13%" />
          <col style="width: 14%" />
        </colgroup>
        <thead>
          <tr>
            <th>{{ m('columns.products.image') }}</th>
            <th>{{ m('columns.products.name') }}</th>
            <th>{{ m('columns.products.slug') }}</th>
            <th>{{ m('columns.products.category') }}</th>
            <th class="text-center">{{ m('columns.products.status') }}</th>
            <th class="text-right">{{ m('columns.products.actions') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="product in paginatedProducts" :key="product.id">
            <td>
              <img
                v-if="product.imageUrl"
                :src="product.imageUrl"
                :alt="product.name"
                class="h-10 w-12 rounded-xl border border-slate-100 object-cover shadow-sm"
              />
              <div v-else class="grid h-10 w-12 place-items-center rounded-xl border border-slate-100 bg-slate-50 text-slate-400">
                <Image class="h-4 w-4" />
              </div>
            </td>
            <td>
              <p class="truncate font-bold text-avocado-950">{{ product.name }}</p>
            </td>
            <td class="admin-shell-cell-truncate admin-shell-cell-muted">/{{ product.slug }}</td>
            <td class="admin-shell-cell-truncate admin-shell-cell-muted">
              <span class="inline-block rounded-lg border border-slate-100 bg-slate-50 px-2 py-0.5 font-medium">{{ product.category || '-' }}</span>
            </td>
            <td class="text-center">
              <span class="inline-flex min-w-[92px] justify-center rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(product.status)">
                {{ statusLabels[product.status] || product.status }}
              </span>
            </td>
            <td>
              <div class="flex justify-end gap-1.5">
                <button
                  class="rounded-xl border border-avocado-100/50 p-2 font-bold text-avocado-700 transition hover:bg-avocado-50/50"
                  :title="m('actions.edit')"
                  @click="openEditModal(product)"
                >
                  <Edit2 class="h-3.5 w-3.5" />
                </button>
                <button
                  class="rounded-xl border border-red-100 p-2 font-bold text-red-600 transition hover:bg-red-50"
                  :title="m('actions.delete')"
                  @click="pendingDeleteId = product.id"
                >
                  <Trash2 class="h-3.5 w-3.5" />
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </AdminShellTablePanel>
  </AdminShellFrame>

  <AdminShellFrame v-if="!isLoading && filteredProducts.length" variant="body" visibility="mobile">
    <AdminShellTablePanel :title="m('tabs.products')" :count-text="listCountText">
      <template #below>
        <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack">
          <article v-for="product in paginatedProducts" :key="product.id" class="admin-shell-mobile-card">
            <div class="flex items-start gap-3">
              <img
                v-if="product.imageUrl"
                :src="product.imageUrl"
                :alt="product.name"
                class="h-14 w-14 rounded-xl border border-slate-100 object-cover"
              />
              <div v-else class="grid h-14 w-14 shrink-0 place-items-center rounded-xl border border-slate-100 bg-slate-50 text-slate-400">
                <Image class="h-5 w-5" />
              </div>
              <div class="min-w-0 flex-1">
                <h3 class="truncate font-black text-avocado-950">{{ product.name }}</h3>
                <p class="mt-1 truncate text-xs font-semibold text-slate-500">/{{ product.slug }}</p>
              </div>
              <span class="shrink-0 rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(product.status)">
                {{ statusLabels[product.status] || product.status }}
              </span>
            </div>
            <p class="mt-3 text-sm text-slate-700">
              <span class="font-bold text-slate-900">{{ m('columns.products.category') }}:</span>
              {{ product.category || '-' }}
            </p>
            <div class="mt-4 flex flex-wrap gap-2">
              <button class="rounded-lg border border-avocado-200 px-3 py-2 text-xs font-bold text-avocado-700" @click="openEditModal(product)">
                {{ m('actions.edit') }}
              </button>
              <button class="rounded-lg border border-red-200 px-3 py-2 text-xs font-bold text-red-600" @click="pendingDeleteId = product.id">
                {{ m('actions.delete') }}
              </button>
            </div>
          </article>
        </div>
      </template>
    </AdminShellTablePanel>
  </AdminShellFrame>

  <AdminShellFrame v-if="filteredProducts.length" variant="footer">
    <Pagination
      :page="currentPage"
      :total-pages="totalPages"
      :visible-count="paginatedProducts.length"
      :total-count="filteredProducts.length"
      :label="m('paginationLabels.products')"
      @prev="currentPage = Math.max(1, currentPage - 1)"
      @next="currentPage = Math.min(totalPages, currentPage + 1)"
    />
  </AdminShellFrame>

  <BaseModal :show="showModal" :title="mode === 'create' ? m('modals.createProduct') : m('modals.editProduct')" max-width="max-w-5xl" @close="closeModal">
    <form id="product-form" class="grid gap-5" @submit.prevent="saveProduct">
      <AdminShellTabs
        v-model="modalFormTab"
        :items="formTabItems"
        :aria-label="m('formTabs.aria')"
      />

      <section v-show="modalFormTab === 'required'" class="product-form-panel grid gap-5 rounded-2xl bg-slate-50 p-5">
        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.name') }}
            <input v-model="form.name" class="admin-input-premium" :placeholder="m('placeholders.name')" />
            <span v-if="formErrors.name" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.name }}</span>
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.slug') }}
            <input
              v-model="form.slug"
              class="admin-input-premium"
              :class="{ 'cursor-not-allowed bg-slate-50 text-slate-500': mode === 'edit' }"
              :readonly="mode === 'edit'"
              :placeholder="m('placeholders.slug')"
              @input="slugTouched = true"
            />
            <span v-if="formErrors.slug" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.slug }}</span>
            <span v-else-if="mode === 'edit'" class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('misc.slugLocked') }}</span>
          </label>
        </div>

        <div class="grid items-start gap-5 sm:grid-cols-2 lg:grid-cols-[1.25fr_1fr_1fr]">
          <label class="grid w-full content-start gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.category') }}
            <input
              v-model="form.category"
              list="product-categories"
              class="admin-input-premium"
              :placeholder="m('placeholders.category')"
            />
            <datalist id="product-categories">
              <option v-for="category in categoryOptions" :key="category" :value="category" />
            </datalist>
            <span class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.category') }}</span>
          </label>
          <label class="grid w-full content-start gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.price') }}
            <input v-model.number="form.price" type="number" min="0" step="1000" class="admin-input-premium" />
            <span v-if="formErrors.price" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.price }}</span>
          </label>
          <label class="grid w-full content-start gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.status') }}
            <select v-model="form.status" class="admin-input-premium cursor-pointer">
              <option v-for="status in productStatuses" :key="status" :value="status">{{ statusLabels[status] }}</option>
            </select>
          </label>
        </div>

        <div class="grid gap-4 rounded-2xl border border-avocado-200 bg-avocado-50/70 px-4 py-3.5 text-sm text-slate-700 sm:grid-cols-[minmax(0,1fr)_180px] sm:items-start">
          <label class="flex cursor-pointer items-start gap-3">
            <input v-model="form.featured" type="checkbox" class="mt-0.5 h-5 w-5 shrink-0 accent-avocado-700" @change="handleFeaturedChange" />
            <span>
              <span class="block font-black text-avocado-950">{{ m('fields.featured') }}</span>
              <span class="mt-1 block text-xs font-semibold leading-5 text-slate-500">{{ m('fieldHints.featured') }}</span>
              <span v-if="formErrors.featured" class="mt-1 block text-xs font-bold leading-5 text-red-600">{{ formErrors.featured }}</span>
            </span>
          </label>
          <label v-if="form.featured" class="grid content-start gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.featuredOrder') }}
            <select v-model.number="form.sortOrder" class="admin-input-premium cursor-pointer">
              <option v-for="order in 5" :key="order" :value="order">{{ order }}</option>
            </select>
            <span v-if="formErrors.featuredOrder" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.featuredOrder }}</span>
          </label>
        </div>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          {{ m('fields.imageUrl') }}
          <div class="relative">
            <Link class="absolute left-4 top-1/2 h-4.5 w-4.5 -translate-y-1/2 text-slate-400" />
            <input v-model="form.imageUrl" class="admin-input-premium admin-input-with-icon" :placeholder="m('placeholders.imageUrl')" />
          </div>
          <span v-if="formErrors.imageUrl" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.imageUrl }}</span>
          <span v-else-if="showImageWarning" class="text-xs font-bold normal-case tracking-normal text-amber-700">{{ m('validation.imageRecommended') }}</span>
        </label>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          {{ m('fields.uploadImage') }}
          <input
            type="file"
            accept=".jpg,.jpeg,.jfif,.png,.webp,.gif,image/jpeg,image/png,image/webp,image/gif"
            class="w-full text-xs font-bold text-slate-600 file:mr-4 file:cursor-pointer file:rounded-xl file:border-0 file:bg-avocado-600 file:px-4 file:py-2.5 file:font-semibold file:text-white transition hover:file:bg-avocado-700"
            :disabled="isUploadingImage || isUploadingGallery || isSaving"
            @change="handleImageFileChange"
          />
          <span v-if="isUploadingImage" class="text-xs font-bold normal-case tracking-normal text-avocado-700 animate-pulse">{{ m('misc.uploading') }}</span>
        </label>

        <div class="grid gap-4 md:grid-cols-[minmax(0,1fr)_220px]">
          <div v-if="formImagePreviewUrl" class="rounded-2xl border border-slate-100 bg-white p-4">
            <p class="mb-3 text-xs font-bold uppercase tracking-wider text-slate-500">{{ m('misc.imagePreview') }}</p>
            <ProductImage :src="formImagePreviewUrl" :alt="form.name || ''" class="h-40 w-full max-w-xs rounded-xl border border-slate-100 shadow-sm" />
          </div>
          <article class="rounded-2xl border border-brand-forest/5 bg-white p-4 shadow-sm">
            <p class="mb-3 text-xs font-bold uppercase tracking-wider text-slate-500">{{ m('misc.productCardPreview') }}</p>
            <div class="aspect-square overflow-hidden rounded-2xl bg-brand-cream/30">
              <ProductImage v-if="productCardPreview.image" :src="productCardPreview.image" :alt="productCardPreview.name" class="h-full w-full" />
              <div v-else class="grid h-full place-items-center text-lg font-black text-brand-forest">ALOO</div>
            </div>
            <div class="mt-3 space-y-1">
              <p class="text-sm font-bold text-brand-dark">{{ productCardPreview.name }}</p>
              <p class="text-xs font-medium text-brand-muted">{{ productCardPreview.category }}</p>
              <p class="line-clamp-2 text-xs leading-relaxed text-brand-muted">{{ productCardPreview.description }}</p>
            </div>
          </article>
        </div>
      </section>

      <section v-show="modalFormTab === 'content'" class="product-form-panel grid gap-5 rounded-2xl bg-slate-50 p-5">
        <p class="text-sm text-slate-500">{{ m('formTabs.contentHint') }}</p>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          {{ m('fields.shortDescription') }}
          <textarea v-model="form.shortDescription" rows="3" class="admin-input-premium resize-none" :placeholder="m('placeholders.shortDescription')" />
          <span class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.shortDescription') }}</span>
        </label>

        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.listDescription') }}
            <textarea v-model="form.description" rows="4" class="admin-input-premium resize-none" :placeholder="m('placeholders.listDescription')" />
            <span class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.listDescription') }}</span>
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.tasteProfile') }}
            <textarea v-model="form.tasteProfile" rows="4" class="admin-input-premium resize-none" :placeholder="m('placeholders.tasteProfile')" />
          </label>
        </div>

        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.ingredients') }}
            <textarea v-model="form.ingredients" rows="5" class="admin-input-premium resize-none" :placeholder="m('placeholders.ingredients')" />
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.servingSuggestion') }}
            <textarea v-model="form.servingSuggestion" rows="5" class="admin-input-premium resize-none" :placeholder="m('placeholders.servingSuggestion')" />
          </label>
        </div>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          {{ m('fields.detailContent') }}
          <textarea v-model="form.detailContent" rows="6" class="admin-input-premium resize-none" :placeholder="m('placeholders.detailContent')" />
          <span class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.detailContent') }}</span>
        </label>
      </section>

      <section v-show="modalFormTab === 'mediaSeo'" class="product-form-panel grid gap-5 rounded-2xl bg-slate-50 p-5">
        <p class="text-sm text-slate-500">{{ m('formTabs.mediaSeoHint') }}</p>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          {{ m('fields.gallery') }}
          <textarea v-model="form.gallery" rows="4" class="admin-input-premium resize-none" :placeholder="m('placeholders.gallery')" />
          <span v-if="formErrors.gallery" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.gallery }}</span>
          <span v-else class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('misc.galleryMultiHint') }}</span>
          <input
            type="file"
            accept=".jpg,.jpeg,.jfif,.png,.webp,.gif,image/jpeg,image/png,image/webp,image/gif"
            multiple
            class="w-full text-xs font-bold text-slate-600 file:mr-4 file:cursor-pointer file:rounded-xl file:border-0 file:bg-avocado-600 file:px-4 file:py-2.5 file:font-semibold file:text-white transition hover:file:bg-avocado-700"
            :disabled="isUploadingGallery"
            @change="handleGalleryFilesChange"
          />
          <span v-if="isUploadingGallery" class="text-xs font-bold normal-case tracking-normal text-avocado-700 animate-pulse">{{ m('misc.uploadingGallery') }}</span>
          <div v-if="formGalleryPreviewUrls.length" class="grid grid-cols-3 gap-3 rounded-2xl border border-slate-100 bg-white p-3 sm:grid-cols-5">
            <div
              v-for="(item, index) in formGalleryPreviewUrls"
              :key="item.raw"
              class="group relative overflow-hidden rounded-xl border border-slate-100 bg-white shadow-sm"
            >
              <img :src="item.preview" :alt="m('misc.galleryAlt')" class="aspect-square w-full object-cover" />
              <button
                type="button"
                class="absolute right-2 top-2 inline-flex h-7 w-7 items-center justify-center rounded-full bg-white/95 text-sm font-black text-red-600 shadow-md ring-1 ring-red-100 transition hover:bg-red-50 hover:text-red-700 focus:outline-none focus:ring-2 focus:ring-red-300"
                :title="m('misc.removeGalleryImage')"
                :aria-label="m('misc.removeGalleryImage')"
                @click="removeGalleryImage(index)"
              >
                ×
              </button>
            </div>
          </div>
        </label>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          {{ m('fields.faqs') }}
          <textarea v-model="form.faqs" rows="4" class="admin-input-premium resize-none" :placeholder="m('placeholders.faqs')" />
          <span v-if="formErrors.faqs" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.faqs }}</span>
          <span v-else class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.faqs') }}</span>
        </label>

        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.seoTitle') }}
            <input v-model="form.seoTitle" class="admin-input-premium" :placeholder="m('placeholders.seoTitle')" />
            <span v-if="formErrors.seoTitle" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.seoTitle }}</span>
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.seoDescription') }}
            <input v-model="form.seoDescription" class="admin-input-premium" :placeholder="m('placeholders.seoDescription')" />
            <span v-if="formErrors.seoDescription" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.seoDescription }}</span>
          </label>
        </div>

      </section>
    </form>
    <template #footer>
      <div class="flex flex-col gap-3 border-t border-slate-100 pt-3 sm:flex-row sm:items-center sm:justify-between">
        <a
          v-if="form.slug.trim()"
          :href="productPublicUrl(form.slug)"
          target="_blank"
          rel="noopener noreferrer"
          class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-avocado-700 hover:text-avocado-800"
        >
          <Link class="h-3.5 w-3.5" />
          {{ m('previewPublic') }}
        </a>
        <div v-else class="hidden sm:block"></div>
        <div class="flex justify-end gap-3">
          <button class="rounded-full border border-slate-200 px-5 py-3 text-xs font-bold uppercase tracking-wider text-slate-500 transition hover:bg-slate-50" @click="closeModal">{{ m('actions.cancel') }}</button>
          <button
            class="rounded-full bg-avocado-600 px-6 py-3 text-xs font-bold uppercase tracking-wider text-white shadow-md transition hover:bg-avocado-700 disabled:cursor-not-allowed disabled:opacity-60"
            form="product-form"
            type="submit"
            :disabled="isUploadingImage || isUploadingGallery || isSaving"
          >
            {{ mode === 'create' ? m('addProduct') : m('actions.saveUpdate') }}
          </button>
        </div>
      </div>
    </template>
  </BaseModal>

  <ConfirmModal
    :show="Boolean(pendingDeleteId)"
    :title="m('confirmDelete.title')"
    :message="m('confirmDelete.message')"
    :confirm-text="m('confirmDelete.confirm')"
    @cancel="pendingDeleteId = null"
    @confirm="confirmDeleteProduct"
  />

  <AvatarCropModal
    :show="showProductCropper"
    :image-src="productCropperSrc"
    :file-name="productCropperFileName"
    variant="product"
    @close="showProductCropper = false"
    @confirm="handleCroppedProductImage"
  />
</template>

<style scoped>
.product-form-panel {
  min-height: 280px;
}
</style>
