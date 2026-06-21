<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
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
const pageSize = 6

const isLoading = computed(() => store.loading.products)
const errorMessage = computed(() => store.errors.products)
const productStatuses = ['ACTIVE', 'INACTIVE']
const statusLabels = computed(() => ({
  ACTIVE: m('status.ACTIVE'),
  INACTIVE: m('status.INACTIVE'),
}))
const statusFilters = computed(() => [t('admin.shared.all'), ...productStatuses.map((status) => statusLabels.value[status])])
const categoryOptions = computed(() => [
  '',
  ...new Set(store.categories.filter((category) => category.status === 'ACTIVE').map((category) => category.name)),
])

const defaultProductForm = () => ({
  name: '',
  slug: '',
  description: '',
  imageUrl: '',
  category: '',
  status: 'ACTIVE',
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

const resetForm = () => {
  Object.assign(form, defaultProductForm())
  editingId.value = null
}

const openCreateModal = () => {
  mode.value = 'create'
  resetForm()
  showModal.value = true
}

const openEditModal = (product) => {
  mode.value = 'edit'
  editingId.value = product.id
  Object.assign(form, {
    ...defaultProductForm(),
    name: product.name || '',
    slug: product.slug || '',
    description: product.description || '',
    imageUrl: normalizeStorageAssetUrl(product.imageUrl || product.image || ''),
    category: product.category || '',
    status: product.status || 'ACTIVE',
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

const handleImageFileChange = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  isUploadingImage.value = true
  try {
    const { data } = await uploadService.image(file)
    form.imageUrl = normalizeStorageAssetUrl(data.url)
    toast.success(m('toasts.imageUploaded'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.imageUploadError'))
  } finally {
    isUploadingImage.value = false
    event.target.value = ''
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

const saveProduct = async () => {
  if (!form.name.trim() || !form.slug.trim()) {
    toast.error(m('toasts.nameSlugRequired'))
    return
  }

  try {
    await store.saveProduct({
      id: editingId.value,
      ...form,
      imageUrl: normalizeStorageAssetUrl(form.imageUrl),
      gallery: normalizeGalleryForStorage(form.gallery),
    })
    toast.success(mode.value === 'create' ? m('toasts.productCreated') : m('toasts.productUpdated'))
    closeModal()
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.productSaveError'))
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
    if (mode.value === 'create' && !form.slug) form.slug = slugify(name)
  },
)

watch([searchQuery, statusFilter], () => {
  currentPage.value = 1
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
  <div class="space-y-6">
    <SearchFilterBar
      v-model:search="searchQuery"
      v-model:status="statusFilter"
      :search-label="m('filters.productsSearchLabel')"
      :search-placeholder="m('filters.productsSearchPlaceholder')"
      :status-label="m('filters.productsStatusLabel')"
      :status-options="statusFilters"
    />

    <p v-if="errorMessage" class="rounded-2xl bg-red-50 border border-red-200/50 px-4 py-3 text-xs font-bold text-red-700">
      {{ errorMessage }}
    </p>

    <div class="overflow-hidden rounded-3xl border border-slate-100 bg-white shadow-sm">
      <div class="overflow-x-auto">
        <table v-if="!isLoading && filteredProducts.length" class="w-full min-w-[820px] table-fixed whitespace-nowrap text-left">
          <colgroup>
            <col class="w-[9%]" />
            <col class="w-[28%]" />
            <col class="w-[18%]" />
            <col class="w-[18%]" />
            <col class="w-[13%]" />
            <col class="w-[14%]" />
          </colgroup>
          <thead class="bg-slate-50/50 border-b border-slate-100 text-[10px] font-bold uppercase tracking-wider text-slate-400">
            <tr>
              <th class="px-6 py-4">{{ m('columns.products.image') }}</th>
              <th class="px-6 py-4">{{ m('columns.products.name') }}</th>
              <th class="px-6 py-4">{{ m('columns.products.slug') }}</th>
              <th class="px-6 py-4">{{ m('columns.products.category') }}</th>
              <th class="px-6 py-4">{{ m('columns.products.status') }}</th>
              <th class="px-6 py-4 text-right">{{ m('columns.products.actions') }}</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-50 text-xs">
            <tr v-for="product in paginatedProducts" :key="product.id" class="hover:bg-slate-50/30 transition">
              <td class="px-6 py-4">
                <img
                  v-if="product.imageUrl"
                  :src="product.imageUrl"
                  :alt="product.name"
                  class="h-10 w-12 rounded-xl object-cover border border-slate-100 shadow-sm"
                />
                <div v-else class="grid h-10 w-12 place-items-center rounded-xl bg-slate-50 border border-slate-100 text-[9px] font-bold text-slate-400">
                  <Image class="h-4 w-4" />
                </div>
              </td>
              <td class="px-6 py-4">
                <p class="truncate font-bold text-xs text-avocado-950">{{ product.name }}</p>
                <p class="mt-1 truncate text-[10px] text-slate-400 max-w-[200px]">{{ product.shortDescription || product.description || m('misc.noDescription') }}</p>
              </td>
              <td class="truncate px-6 py-4 font-semibold text-slate-500">/{{ product.slug }}</td>
              <td class="truncate px-6 py-4 text-slate-500">
                <span class="inline-block bg-slate-50 border border-slate-100 px-2 py-0.5 rounded-lg font-medium">{{ product.category || '-' }}</span>
              </td>
              <td class="px-6 py-4">
                <span class="inline-flex min-w-[92px] justify-center rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(product.status)">
                  {{ statusLabels[product.status] || product.status }}
                </span>
              </td>
              <td class="px-6 py-4">
                <div class="flex justify-end gap-1.5">
                  <button
                    class="rounded-xl border border-avocado-100/50 p-2 font-bold text-avocado-700 hover:bg-avocado-50/50 transition"
                    :title="m('actions.edit')"
                    @click="openEditModal(product)"
                  >
                    <Edit2 class="h-3.5 w-3.5" />
                  </button>
                  <button
                    class="rounded-xl border border-red-100 p-2 font-bold text-red-600 hover:bg-red-50 transition"
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
      </div>
      <EmptyState v-if="isLoading || filteredProducts.length === 0" :loading="isLoading" :message="m('empty')" />
    </div>

    <Pagination
      :page="currentPage"
      :total-pages="totalPages"
      :visible-count="paginatedProducts.length"
      :total-count="filteredProducts.length"
      :label="m('paginationLabels.products')"
      @prev="currentPage = Math.max(1, currentPage - 1)"
      @next="currentPage = Math.min(totalPages, currentPage + 1)"
    />

    <BaseModal :show="showModal" :title="mode === 'create' ? m('modals.createProduct') : m('modals.editProduct')" max-width="max-w-5xl" @close="closeModal">
      <form id="product-form" class="grid gap-5" @submit.prevent="saveProduct">
        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.name') }}
            <input v-model="form.name" required class="admin-input-premium" :placeholder="m('placeholders.name')" />
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.slug') }}
            <input
              v-model="form.slug"
              required
              class="admin-input-premium"
              :class="{ 'cursor-not-allowed bg-slate-50 text-slate-500': mode === 'edit' }"
              :readonly="mode === 'edit'"
              :placeholder="m('placeholders.slug')"
            />
            <span v-if="mode === 'edit'" class="text-[11px] font-semibold normal-case tracking-normal text-slate-400">{{ m('misc.slugLocked') }}</span>
          </label>
        </div>
        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.category') }}
            <input v-model="form.category" list="product-categories" class="admin-input-premium" :placeholder="m('placeholders.category')" />
            <datalist id="product-categories">
              <option v-for="category in categoryOptions" :key="category" :value="category" />
            </datalist>
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.status') }}
            <select v-model="form.status" class="admin-input-premium cursor-pointer">
              <option v-for="status in productStatuses" :key="status" :value="status">{{ statusLabels[status] }}</option>
            </select>
          </label>
        </div>

        <div class="h-px bg-slate-100 w-full my-2"></div>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          {{ m('fields.imageUrl') }}
          <div class="relative">
            <Link class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 h-4.5 w-4.5" />
            <input v-model="form.imageUrl" class="admin-input-premium admin-input-with-icon" :placeholder="m('placeholders.imageUrl')" />
          </div>
        </label>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          {{ m('fields.uploadImage') }}
          <input
            type="file"
            accept=".jpg,.jpeg,.jfif,.png,.webp,.gif,image/jpeg,image/png,image/webp,image/gif"
            class="w-full text-xs font-bold text-slate-600 file:mr-4 file:rounded-xl file:border-0 file:bg-avocado-600 file:px-4 file:py-2.5 file:font-semibold file:text-white file:cursor-pointer hover:file:bg-avocado-700 transition"
            :disabled="isUploadingImage || isUploadingGallery"
            @change="handleImageFileChange"
          />
          <span v-if="isUploadingImage" class="text-xs font-bold text-avocado-700 animate-pulse">{{ m('misc.uploading') }}</span>
        </label>

        <div v-if="formImagePreviewUrl" class="rounded-2xl border border-slate-100 bg-slate-50/50 p-4">
          <p class="mb-2 text-xs font-bold uppercase tracking-wider text-slate-400">{{ m('misc.imagePreview') }}</p>
          <img :src="formImagePreviewUrl" :alt="m('misc.productImagePreview')" class="h-32 w-40 rounded-xl border border-slate-100 object-cover shadow-sm" />
        </div>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          {{ m('fields.shortDescription') }}
          <textarea v-model="form.shortDescription" rows="3" class="admin-input-premium resize-none" :placeholder="m('placeholders.shortDescription')"></textarea>
        </label>

        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.heroDescription') }}
            <textarea v-model="form.description" rows="4" class="admin-input-premium resize-none" :placeholder="m('placeholders.heroDescription')"></textarea>
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.tasteProfile') }}
            <textarea v-model="form.tasteProfile" rows="4" class="admin-input-premium resize-none" :placeholder="m('placeholders.tasteProfile')"></textarea>
          </label>
        </div>

        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.ingredients') }}
            <textarea v-model="form.ingredients" rows="5" class="admin-input-premium resize-none" :placeholder="m('placeholders.ingredients')"></textarea>
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.servingSuggestion') }}
            <textarea v-model="form.servingSuggestion" rows="5" class="admin-input-premium resize-none" :placeholder="m('placeholders.servingSuggestion')"></textarea>
          </label>
        </div>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          {{ m('fields.detailContent') }}
          <textarea v-model="form.detailContent" rows="6" class="admin-input-premium resize-none" :placeholder="m('placeholders.detailContent')"></textarea>
        </label>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          {{ m('fields.gallery') }}
          <textarea v-model="form.gallery" rows="4" class="admin-input-premium resize-none" :placeholder="m('placeholders.gallery')"></textarea>
          <input
            type="file"
            accept=".jpg,.jpeg,.jfif,.png,.webp,.gif,image/jpeg,image/png,image/webp,image/gif"
            multiple
            class="w-full text-xs font-bold text-slate-600 file:mr-4 file:rounded-xl file:border-0 file:bg-avocado-600 file:px-4 file:py-2.5 file:font-semibold file:text-white file:cursor-pointer hover:file:bg-avocado-700 transition"
            :disabled="isUploadingGallery"
            @change="handleGalleryFilesChange"
          />
          <span v-if="isUploadingGallery" class="text-xs font-bold text-avocado-700 animate-pulse">{{ m('misc.uploadingGallery') }}</span>
          <span v-else class="text-[11px] font-semibold normal-case tracking-normal text-slate-400">{{ m('misc.galleryMultiHint') }}</span>
          <div v-if="formGalleryPreviewUrls.length" class="grid grid-cols-3 gap-3 rounded-2xl border border-slate-100 bg-slate-50/60 p-3 sm:grid-cols-5">
            <div
              v-for="(item, index) in formGalleryPreviewUrls"
              :key="item.raw"
              class="group relative overflow-hidden rounded-xl border border-slate-100 bg-white shadow-sm"
            >
              <img
                :src="item.preview"
                :alt="m('misc.galleryAlt')"
                class="aspect-square w-full object-cover"
              />
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
          <textarea v-model="form.faqs" rows="4" class="admin-input-premium resize-none" :placeholder="m('placeholders.faqs')"></textarea>
        </label>

        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.seoTitle') }}
            <input v-model="form.seoTitle" class="admin-input-premium" :placeholder="m('placeholders.seoTitle')" />
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.seoDescription') }}
            <input v-model="form.seoDescription" class="admin-input-premium" :placeholder="m('placeholders.seoDescription')" />
          </label>
        </div>

        <label class="inline-flex items-center gap-3 rounded-2xl border border-slate-100 bg-slate-50/60 px-4 py-3 text-sm font-black text-slate-700">
          <input v-model="form.featured" type="checkbox" class="h-4 w-4 accent-avocado-700" />
          {{ m('fields.featured') }}
        </label>
      </form>
      <template #footer>
        <div class="flex flex-col gap-3 border-t border-slate-100 pt-3 sm:flex-row sm:items-center sm:justify-between">
          <a
            v-if="mode === 'edit' && form.slug.trim()"
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
            <button class="rounded-full border border-slate-200 px-5 py-3 text-xs font-bold uppercase tracking-wider text-slate-500 hover:bg-slate-50 transition" @click="closeModal">{{ m('actions.cancel') }}</button>
            <button
              class="rounded-full bg-avocado-600 px-6 py-3 text-xs font-bold uppercase tracking-wider text-white hover:bg-avocado-700 disabled:cursor-not-allowed disabled:opacity-60 transition shadow-md"
              form="product-form"
              type="submit"
              :disabled="isUploadingImage || isUploadingGallery"
            >
              {{ mode === 'create' ? m('addProduct') : m('actions.saveUpdate') }}
            </button>
          </div>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal :show="Boolean(pendingDeleteId)" @cancel="pendingDeleteId = null" @confirm="confirmDeleteProduct" />
  </div>
</template>

<style scoped>
.admin-input-premium {
  width: 100%;
  border-radius: 1rem;
  border: 1px solid rgb(241, 245, 249);
  background: rgb(248, 250, 252, 0.5);
  padding: 0.75rem 1rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: rgb(30, 41, 59);
  outline: none;
  transition: all 0.2s;
}

.admin-input-premium:focus {
  background: white;
  border-color: rgb(126, 199, 90);
  box-shadow: 0 0 0 3px rgba(112, 149, 107, 0.1);
}

.admin-input-with-icon {
  padding-left: 2.75rem;
}
</style>
