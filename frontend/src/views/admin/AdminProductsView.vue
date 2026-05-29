<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import { menuPosterService, resolveBackendAssetUrl, uploadService } from '../../services/cmsService'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'
import { Plus, Edit2, Trash2, Image, Link, ChevronRight } from 'lucide-vue-next'

const store = useAppStore()
const toast = useToastStore()

const activeTab = ref('products')
const showModal = ref(false)
const mode = ref('create')
const editingId = ref(null)
const pendingDeleteId = ref(null)
const searchQuery = ref('')
const statusFilter = ref('Tất cả')
const currentPage = ref(1)
const isUploadingImage = ref(false)
const isUploadingGallery = ref(false)
const pageSize = 6

const showPosterModal = ref(false)
const posterMode = ref('create')
const editingPosterId = ref(null)
const pendingDeletePosterId = ref(null)
const posterSearchQuery = ref('')
const posterStatusFilter = ref('Tất cả')
const posterCurrentPage = ref(1)
const isLoadingMenuPosters = ref(false)
const menuPosterError = ref('')
const isUploadingPosterImage = ref(false)
const menuPosters = ref([])

const isLoading = computed(() => store.loading.products)
const errorMessage = computed(() => store.errors.products)
const productStatuses = ['ACTIVE', 'INACTIVE']
const statusLabels = {
  ACTIVE: 'Đang bán',
  INACTIVE: 'Tạm ẩn',
}
const statusFilters = ['Tất cả', ...productStatuses.map((status) => statusLabels[status])]
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
    .filter(Boolean)
)

const formGalleryPreviewUrls = computed(() =>
  formGalleryLines.value.map((url) => ({
    raw: url,
    preview: resolveBackendAssetUrl(url),
  }))
)

const posterForm = reactive({
  branchKey: '',
  title: '',
  subtitle: '',
  imageUrl: '',
  altText: '',
  sortOrder: 0,
  status: 'ACTIVE',
})

const slugify = (value) =>
  value
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '')

const resetForm = () => {
  Object.assign(form, defaultProductForm())
  editingId.value = null
}

const normalizeMenuPoster = (poster) => ({
  ...poster,
  branchKey: poster.branchKey || '',
  title: poster.title || '',
  subtitle: poster.subtitle || '',
  imageUrl: resolveBackendAssetUrl(poster.imageUrl || ''),
  altText: poster.altText || '',
  sortOrder: Number(poster.sortOrder || 0),
  status: poster.status || 'ACTIVE',
})

const resetPosterForm = () => {
  Object.assign(posterForm, {
    branchKey: '',
    title: '',
    subtitle: '',
    imageUrl: '',
    altText: '',
    sortOrder: 0,
    status: 'ACTIVE',
  })
  editingPosterId.value = null
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
    imageUrl: product.imageUrl || product.image || '',
    category: product.category || '',
    status: product.status || 'ACTIVE',
    shortDescription: product.shortDescription || '',
    detailContent: product.detailContent || '',
    ingredients: product.ingredients || '',
    tasteProfile: product.tasteProfile || '',
    servingSuggestion: product.servingSuggestion || '',
    gallery: product.gallery || '',
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

const openCreatePosterModal = () => {
  posterMode.value = 'create'
  resetPosterForm()
  showPosterModal.value = true
}

const openEditPosterModal = (poster) => {
  posterMode.value = 'edit'
  editingPosterId.value = poster.id
  Object.assign(posterForm, {
    branchKey: poster.branchKey || '',
    title: poster.title || '',
    subtitle: poster.subtitle || '',
    imageUrl: poster.imageUrl || '',
    altText: poster.altText || '',
    sortOrder: Number(poster.sortOrder || 0),
    status: poster.status || 'ACTIVE',
  })
  showPosterModal.value = true
}

const closePosterModal = () => {
  showPosterModal.value = false
  resetPosterForm()
}

const handleImageFileChange = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  isUploadingImage.value = true
  try {
    const { data } = await uploadService.image(file)
    form.imageUrl = data.url
    toast.success('Đã tải ảnh sản phẩm lên backend')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không tải được ảnh sản phẩm')
  } finally {
    isUploadingImage.value = false
    event.target.value = ''
  }
}


const allowedGalleryExtensions = ['jpg', 'jpeg', 'jfif', 'png', 'webp', 'gif']
const maxGalleryFileSize = 5 * 1024 * 1024

const imageUploadErrorMessage = (error) =>
  error.response?.data?.message || error.response?.data?.error || error.message || 'Không tải được ảnh'

const validateGalleryFile = (file) => {
  const extension = file.name.split('.').pop()?.toLowerCase() || ''
  if (!allowedGalleryExtensions.includes(extension)) {
    return `Định dạng .${extension || 'không rõ'} chưa được hỗ trợ`
  }
  if (file.size > maxGalleryFileSize) {
    return 'Ảnh vượt quá 5MB'
  }
  if (file.type && !file.type.startsWith('image/')) {
    return 'File không phải ảnh'
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
    toast.error(skippedFiles.slice(0, 2).join('\n') || 'Không có ảnh hợp lệ để upload')
    event.target.value = ''
    return
  }

  isUploadingGallery.value = true
  try {
    const results = await Promise.allSettled(validFiles.map((file) => uploadService.image(file)))
    const uploadedUrls = results
      .filter((result) => result.status === 'fulfilled' && result.value.data?.url)
      .map((result) => result.value.data.url)

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
      toast.success(`Đã tải ${uploadedUrls.length} ảnh vào gallery`)
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
  toast.success('Đã xóa ảnh khỏi gallery')
}
const handlePosterImageFileChange = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  isUploadingPosterImage.value = true
  try {
    const { data } = await uploadService.image(file)
    posterForm.imageUrl = data.url
    toast.success('Đã tải ảnh menu lên backend')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không tải được ảnh menu')
  } finally {
    isUploadingPosterImage.value = false
    event.target.value = ''
  }
}

const statusClass = (status) =>
  status === 'ACTIVE'
    ? 'border-emerald-200 bg-emerald-50 text-emerald-700'
    : 'border-slate-200 bg-slate-50 text-slate-500'

const getStatusValue = (label) =>
  Object.entries(statusLabels).find(([, value]) => value === label)?.[0] || label

const filteredProducts = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return store.products.filter((product) => {
    const matchesSearch =
      !keyword ||
      product.name?.toLowerCase().includes(keyword) ||
      product.slug?.toLowerCase().includes(keyword) ||
      product.category?.toLowerCase().includes(keyword)
    const matchesStatus = statusFilter.value === 'Tất cả' || product.status === getStatusValue(statusFilter.value)
    return matchesSearch && matchesStatus
  })
})

const filteredMenuPosters = computed(() => {
  const keyword = posterSearchQuery.value.trim().toLowerCase()
  return menuPosters.value.filter((poster) => {
    const haystack = [poster.title, poster.subtitle, poster.branchKey, poster.altText]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
    const matchesSearch = !keyword || haystack.includes(keyword)
    const matchesStatus = posterStatusFilter.value === 'Tất cả' || poster.status === getStatusValue(posterStatusFilter.value)
    return matchesSearch && matchesStatus
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredProducts.value.length / pageSize)))
const paginatedProducts = computed(() =>
  filteredProducts.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)
const totalPosterPages = computed(() => Math.max(1, Math.ceil(filteredMenuPosters.value.length / pageSize)))
const paginatedMenuPosters = computed(() =>
  filteredMenuPosters.value.slice((posterCurrentPage.value - 1) * pageSize, posterCurrentPage.value * pageSize),
)

const fetchMenuPosters = async () => {
  isLoadingMenuPosters.value = true
  menuPosterError.value = ''
  try {
    const { data } = await menuPosterService.list()
    menuPosters.value = Array.isArray(data) ? data.map(normalizeMenuPoster) : []
  } catch (error) {
    menuPosterError.value = error.response?.data?.message || 'Không tải được menu hiển thị'
    throw error
  } finally {
    isLoadingMenuPosters.value = false
  }
}

const saveProduct = async () => {
  if (!form.name.trim() || !form.slug.trim()) {
    toast.error('Vui lòng nhập tên và slug sản phẩm')
    return
  }

  try {
    await store.saveProduct({
      id: editingId.value,
      ...form,
    })
    toast.success(mode.value === 'create' ? 'Đã thêm sản phẩm thành công' : 'Đã cập nhật sản phẩm thành công')
    closeModal()
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không lưu được sản phẩm')
  }
}

const confirmDeleteProduct = async () => {
  try {
    await store.deleteProduct(pendingDeleteId.value)
    toast.success('Đã xóa sản phẩm thành công')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không xóa được sản phẩm')
  } finally {
    pendingDeleteId.value = null
  }
}

const saveMenuPoster = async () => {
  if (!posterForm.branchKey.trim() || !posterForm.title.trim()) {
    toast.error('Vui lòng nhập mã chi nhánh và tên menu')
    return
  }

  const payload = {
    branchKey: posterForm.branchKey.trim(),
    title: posterForm.title.trim(),
    subtitle: posterForm.subtitle.trim(),
    imageUrl: posterForm.imageUrl,
    altText: posterForm.altText.trim() || posterForm.title.trim(),
    sortOrder: Number(posterForm.sortOrder || 0),
    status: posterForm.status || 'ACTIVE',
  }

  try {
    const request = editingPosterId.value
      ? menuPosterService.update(editingPosterId.value, payload)
      : menuPosterService.create(payload)
    const { data } = await request
    const normalized = normalizeMenuPoster(data)
    const index = menuPosters.value.findIndex((item) => item.id === normalized.id)
    if (index === -1) menuPosters.value.unshift(normalized)
    else menuPosters.value.splice(index, 1, normalized)
    toast.success(posterMode.value === 'create' ? 'Đã thêm menu hiển thị' : 'Đã cập nhật menu hiển thị')
    closePosterModal()
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không lưu được menu hiển thị')
  }
}

const confirmDeleteMenuPoster = async () => {
  try {
    await menuPosterService.remove(pendingDeletePosterId.value)
    menuPosters.value = menuPosters.value.filter((item) => item.id !== pendingDeletePosterId.value)
    toast.success('Đã xóa menu hiển thị')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không xóa được menu hiển thị')
  } finally {
    pendingDeletePosterId.value = null
  }
}

watch(
  () => form.name,
  (name) => {
    if (!form.slug) form.slug = slugify(name)
  },
)

watch([searchQuery, statusFilter], () => {
  currentPage.value = 1
})

watch([posterSearchQuery, posterStatusFilter], () => {
  posterCurrentPage.value = 1
})

onMounted(() => {
  Promise.allSettled([store.fetchProducts(), store.fetchCategories(), fetchMenuPosters()]).then((results) => {
    if (results.some((result) => result.status === 'rejected')) {
      toast.error('Không tải được một phần dữ liệu sản phẩm')
    }
  })
})
</script>

<template>
  <section class="space-y-6 pb-10">
    <!-- Header Block -->
    <div class="flex flex-col justify-between gap-5 rounded-3xl border border-avocado-100/30 bg-white p-6 sm:p-8 shadow-sm lg:flex-row lg:items-center">
      <div>
        <span class="inline-block text-[10px] font-bold uppercase tracking-wider text-avocado-600">Products Catalog</span>
        <h1 class="mt-1 text-2xl font-black text-avocado-950">Quản lý sản phẩm</h1>
        <p class="mt-1 text-xs text-slate-400">Đồng bộ dữ liệu sản phẩm qua REST API.</p>
      </div>
      <button 
        class="rounded-full bg-avocado-600 hover:bg-avocado-700 px-6 py-3.5 text-xs font-bold uppercase tracking-wider text-white transition flex items-center justify-center gap-2 shadow-lg shadow-avocado-600/10" 
        @click="activeTab === 'products' ? openCreateModal() : openCreatePosterModal()"
      >
        <Plus class="h-4.5 w-4.5" />
        {{ activeTab === 'products' ? 'Thêm sản phẩm' : 'Thêm menu' }}
      </button>
    </div>

    <div class="inline-flex w-full rounded-3xl border border-slate-100 bg-white p-1.5 shadow-sm sm:w-auto">
      <button
        type="button"
        class="flex-1 rounded-2xl px-5 py-3 text-xs font-black uppercase tracking-wider transition sm:flex-none"
        :class="activeTab === 'products' ? 'bg-avocado-900 text-white shadow-sm' : 'text-slate-500 hover:bg-avocado-50 hover:text-avocado-900'"
        @click="activeTab = 'products'"
      >
        Sản phẩm
      </button>
      <button
        type="button"
        class="flex-1 rounded-2xl px-5 py-3 text-xs font-black uppercase tracking-wider transition sm:flex-none"
        :class="activeTab === 'menu' ? 'bg-avocado-900 text-white shadow-sm' : 'text-slate-500 hover:bg-avocado-50 hover:text-avocado-900'"
        @click="activeTab = 'menu'"
      >
        Menu hiển thị
      </button>
    </div>

    <!-- Filters -->
    <SearchFilterBar
      v-if="activeTab === 'products'"
      v-model:search="searchQuery"
      v-model:status="statusFilter"
      search-label="Tìm sản phẩm"
      search-placeholder="Tìm tên, slug, danh mục..."
      status-label="Trạng thái bán"
      :status-options="statusFilters"
    />

    <SearchFilterBar
      v-else
      v-model:search="posterSearchQuery"
      v-model:status="posterStatusFilter"
      search-label="Tìm menu"
      search-placeholder="Tìm tên menu, chi nhánh, khu vực..."
      status-label="Trạng thái hiển thị"
      :status-options="statusFilters"
    />
    
    <p v-if="activeTab === 'products' && errorMessage" class="rounded-2xl bg-red-50 border border-red-200/50 px-4 py-3 text-xs font-bold text-red-700">
      {{ errorMessage }}
    </p>
    <p v-if="activeTab === 'menu' && menuPosterError" class="rounded-2xl bg-red-50 border border-red-200/50 px-4 py-3 text-xs font-bold text-red-700">
      {{ menuPosterError }}
    </p>

    <!-- Table content -->
    <div v-if="activeTab === 'products'" class="overflow-hidden rounded-3xl border border-slate-100 bg-white shadow-sm">
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
              <th class="px-6 py-4">Ảnh</th>
              <th class="px-6 py-4">Sản phẩm</th>
              <th class="px-6 py-4">Slug</th>
              <th class="px-6 py-4">Danh mục</th>
              <th class="px-6 py-4">Trạng thái</th>
              <th class="px-6 py-4 text-right">Hành động</th>
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
                <p class="mt-1 truncate text-[10px] text-slate-400 max-w-[200px]">{{ product.description || 'Chưa có mô tả' }}</p>
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
                    title="Sửa" 
                    @click="openEditModal(product)"
                  >
                    <Edit2 class="h-3.5 w-3.5" />
                  </button>
                  <button 
                    class="rounded-xl border border-red-100 p-2 font-bold text-red-600 hover:bg-red-50 transition" 
                    title="Xóa" 
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
      <EmptyState v-if="isLoading || filteredProducts.length === 0" :loading="isLoading" message="Không có sản phẩm phù hợp" />
    </div>

    <div v-else class="overflow-hidden rounded-3xl border border-slate-100 bg-white shadow-sm">
      <div class="overflow-x-auto">
        <table v-if="!isLoadingMenuPosters && filteredMenuPosters.length" class="w-full min-w-[920px] table-fixed whitespace-nowrap text-left">
          <colgroup>
            <col class="w-[10%]" />
            <col class="w-[25%]" />
            <col class="w-[18%]" />
            <col class="w-[24%]" />
            <col class="w-[11%]" />
            <col class="w-[12%]" />
          </colgroup>
          <thead class="bg-slate-50/50 border-b border-slate-100 text-[10px] font-bold uppercase tracking-wider text-slate-400">
            <tr>
              <th class="px-6 py-4">Ảnh</th>
              <th class="px-6 py-4">Menu</th>
              <th class="px-6 py-4">Chi nhánh</th>
              <th class="px-6 py-4">Mô tả</th>
              <th class="px-6 py-4">Trạng thái</th>
              <th class="px-6 py-4 text-right">Hành động</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-50 text-xs">
            <tr v-for="poster in paginatedMenuPosters" :key="poster.id" class="hover:bg-slate-50/30 transition">
              <td class="px-6 py-4">
                <img
                  v-if="poster.imageUrl"
                  :src="poster.imageUrl"
                  :alt="poster.altText || poster.title"
                  class="h-14 w-12 rounded-xl object-cover border border-slate-100 shadow-sm"
                />
                <div v-else class="grid h-14 w-12 place-items-center rounded-xl bg-slate-50 border border-slate-100 text-[9px] font-bold text-slate-400">
                  <Image class="h-4 w-4" />
                </div>
              </td>
              <td class="px-6 py-4">
                <p class="truncate font-bold text-xs text-avocado-950">{{ poster.title }}</p>
                <p class="mt-1 truncate text-[10px] text-slate-400">Thứ tự: {{ poster.sortOrder }}</p>
              </td>
              <td class="truncate px-6 py-4 font-semibold text-slate-500">{{ poster.branchKey }}</td>
              <td class="px-6 py-4">
                <p class="truncate text-slate-500">{{ poster.subtitle || poster.altText || 'Chưa có mô tả' }}</p>
              </td>
              <td class="px-6 py-4">
                <span class="inline-flex min-w-[92px] justify-center rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(poster.status)">
                  {{ statusLabels[poster.status] || poster.status }}
                </span>
              </td>
              <td class="px-6 py-4">
                <div class="flex justify-end gap-1.5">
                  <button
                    class="rounded-xl border border-avocado-100/50 p-2 font-bold text-avocado-700 hover:bg-avocado-50/50 transition"
                    title="Sửa"
                    @click="openEditPosterModal(poster)"
                  >
                    <Edit2 class="h-3.5 w-3.5" />
                  </button>
                  <button
                    class="rounded-xl border border-red-100 p-2 font-bold text-red-600 hover:bg-red-50 transition"
                    title="Xóa"
                    @click="pendingDeletePosterId = poster.id"
                  >
                    <Trash2 class="h-3.5 w-3.5" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <EmptyState v-if="isLoadingMenuPosters || filteredMenuPosters.length === 0" :loading="isLoadingMenuPosters" message="Không có menu hiển thị phù hợp" />
    </div>

    <!-- Pagination -->
    <Pagination
      v-if="activeTab === 'products'"
      :page="currentPage"
      :total-pages="totalPages"
      :visible-count="paginatedProducts.length"
      :total-count="filteredProducts.length"
      label="sản phẩm"
      @prev="currentPage = Math.max(1, currentPage - 1)"
      @next="currentPage = Math.min(totalPages, currentPage + 1)"
    />

    <Pagination
      v-else
      :page="posterCurrentPage"
      :total-pages="totalPosterPages"
      :visible-count="paginatedMenuPosters.length"
      :total-count="filteredMenuPosters.length"
      label="menu"
      @prev="posterCurrentPage = Math.max(1, posterCurrentPage - 1)"
      @next="posterCurrentPage = Math.min(totalPosterPages, posterCurrentPage + 1)"
    />

    <!-- Edit modal -->
    <BaseModal :show="showModal" :title="mode === 'create' ? 'Thêm Sản Phẩm Mới' : 'Cập Nhật Sản Phẩm'" max-width="max-w-5xl" @close="closeModal">
      <form id="product-form" class="grid gap-5" @submit.prevent="saveProduct">
        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Tên sản phẩm *
            <input v-model="form.name" required class="admin-input-premium" placeholder="Nhập tên sản phẩm..." />
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Slug *
            <input v-model="form.slug" required class="admin-input-premium" placeholder="url-friendly-slug" />
          </label>
        </div>
        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Danh mục
            <input v-model="form.category" list="product-categories" class="admin-input-premium" placeholder="Chọn hoặc nhập danh mục" />
            <datalist id="product-categories">
              <option v-for="category in categoryOptions" :key="category" :value="category" />
            </datalist>
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Trạng thái
            <select v-model="form.status" class="admin-input-premium cursor-pointer">
              <option v-for="status in productStatuses" :key="status" :value="status">{{ statusLabels[status] }}</option>
            </select>
          </label>
        </div>

        <div class="h-px bg-slate-100 w-full my-2"></div>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          Đường dẫn ảnh (Image URL)
          <div class="relative">
            <Link class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 h-4.5 w-4.5" />
            <input v-model="form.imageUrl" class="admin-input-premium admin-input-with-icon" placeholder="https://..." />
          </div>
        </label>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          Hoặc tải ảnh mới từ máy tính
          <input
            type="file"
            accept=".jpg,.jpeg,.jfif,.png,.webp,.gif,image/jpeg,image/png,image/webp,image/gif"
            class="w-full text-xs font-bold text-slate-600 file:mr-4 file:rounded-xl file:border-0 file:bg-avocado-600 file:px-4 file:py-2.5 file:font-semibold file:text-white file:cursor-pointer hover:file:bg-avocado-700 transition"
            :disabled="isUploadingImage || isUploadingGallery"
            @change="handleImageFileChange"
          />
          <span v-if="isUploadingImage" class="text-xs font-bold text-avocado-700 animate-pulse">Đang upload lên máy chủ...</span>
        </label>

        <div v-if="formImagePreviewUrl" class="rounded-2xl border border-slate-100 bg-slate-50/50 p-4">
          <p class="mb-2 text-xs font-bold uppercase tracking-wider text-slate-400">Xem trước ảnh</p>
          <img :src="formImagePreviewUrl" alt="Xem trước sản phẩm" class="h-32 w-40 rounded-xl border border-slate-100 object-cover shadow-sm" />
        </div>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          Mô tả ngắn trên thẻ sản phẩm
          <textarea v-model="form.description" rows="3" class="admin-input-premium resize-none" placeholder="Mô tả ngắn dùng ở danh sách sản phẩm..."></textarea>
        </label>

        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Mô tả hero chi tiết
            <textarea v-model="form.shortDescription" rows="4" class="admin-input-premium resize-none" placeholder="Một đoạn giới thiệu hấp dẫn cho trang chi tiết..."></textarea>
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Hồ sơ hương vị
            <textarea v-model="form.tasteProfile" rows="4" class="admin-input-premium resize-none" placeholder="Béo mịn, thơm bơ, ngọt nhẹ, topping giòn..."></textarea>
          </label>
        </div>

        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Nguyên liệu chính
            <textarea v-model="form.ingredients" rows="5" class="admin-input-premium resize-none" placeholder="Mỗi dòng một nguyên liệu: Bơ sáp; Kem sữa; Dừa khô..."></textarea>
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Gợi ý thưởng thức
            <textarea v-model="form.servingSuggestion" rows="5" class="admin-input-premium resize-none" placeholder="Dùng ngay khi lạnh, phù hợp buổi chiều, thêm topping..."></textarea>
          </label>
        </div>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          Nội dung landing page
          <textarea v-model="form.detailContent" rows="6" class="admin-input-premium resize-none" placeholder="Viết câu chuyện sản phẩm, điểm khác biệt, quy trình chuẩn bị..."></textarea>
        </label>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          Gallery ảnh chi tiết
          <textarea v-model="form.gallery" rows="4" class="admin-input-premium resize-none" placeholder="Mỗi dòng một URL ảnh"></textarea>
          <input
            type="file"
            accept=".jpg,.jpeg,.jfif,.png,.webp,.gif,image/jpeg,image/png,image/webp,image/gif"
            multiple
            class="w-full text-xs font-bold text-slate-600 file:mr-4 file:rounded-xl file:border-0 file:bg-avocado-600 file:px-4 file:py-2.5 file:font-semibold file:text-white file:cursor-pointer hover:file:bg-avocado-700 transition"
            :disabled="isUploadingGallery"
            @change="handleGalleryFilesChange"
          />
          <span v-if="isUploadingGallery" class="text-xs font-bold text-avocado-700 animate-pulse">Đang upload nhiều ảnh gallery...</span>
          <span v-else class="text-[11px] font-semibold normal-case tracking-normal text-slate-400">Có thể chọn nhiều ảnh cùng lúc. URL ảnh sẽ tự thêm vào ô gallery.</span>
          <div v-if="formGalleryPreviewUrls.length" class="grid grid-cols-3 gap-3 rounded-2xl border border-slate-100 bg-slate-50/60 p-3 sm:grid-cols-5">
            <div
              v-for="(item, index) in formGalleryPreviewUrls"
              :key="item.raw"
              class="group relative overflow-hidden rounded-xl border border-slate-100 bg-white shadow-sm"
            >
              <img
                :src="item.preview"
                alt="Gallery sản phẩm"
                class="aspect-square w-full object-cover"
              />
              <button
                type="button"
                class="absolute right-2 top-2 inline-flex h-7 w-7 items-center justify-center rounded-full bg-white/95 text-sm font-black text-red-600 shadow-md ring-1 ring-red-100 transition hover:bg-red-50 hover:text-red-700 focus:outline-none focus:ring-2 focus:ring-red-300"
                title="Xóa ảnh khỏi gallery"
                aria-label="Xóa ảnh khỏi gallery"
                @click="removeGalleryImage(index)"
              >
                ×
              </button>
            </div>
          </div>
        </label>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          FAQ sản phẩm
          <textarea v-model="form.faqs" rows="4" class="admin-input-premium resize-none" placeholder="Mỗi dòng: Câu hỏi | Câu trả lời"></textarea>
        </label>

        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            SEO title
            <input v-model="form.seoTitle" class="admin-input-premium" placeholder="Tiêu đề SEO cho sản phẩm" />
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            SEO description
            <input v-model="form.seoDescription" class="admin-input-premium" placeholder="Mô tả SEO ngắn" />
          </label>
        </div>

        <label class="inline-flex items-center gap-3 rounded-2xl border border-slate-100 bg-slate-50/60 px-4 py-3 text-sm font-black text-slate-700">
          <input v-model="form.featured" type="checkbox" class="h-4 w-4 accent-avocado-700" />
          Đánh dấu sản phẩm nổi bật
        </label>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3 pt-3 border-t border-slate-100">
          <button class="rounded-full border border-slate-200 px-5 py-3 text-xs font-bold uppercase tracking-wider text-slate-500 hover:bg-slate-50 transition" @click="closeModal">Hủy bỏ</button>
          <button 
            class="rounded-full bg-avocado-600 px-6 py-3 text-xs font-bold uppercase tracking-wider text-white hover:bg-avocado-700 disabled:cursor-not-allowed disabled:opacity-60 transition shadow-md" 
            form="product-form" 
            type="submit" 
            :disabled="isUploadingImage || isUploadingGallery"
          >
            {{ mode === 'create' ? 'Tạo sản phẩm' : 'Lưu cập nhật' }}
          </button>
        </div>
      </template>
    </BaseModal>

    <BaseModal :show="showPosterModal" :title="posterMode === 'create' ? 'Thêm Menu Hiển Thị' : 'Cập Nhật Menu Hiển Thị'" max-width="max-w-2xl" @close="closePosterModal">
      <form id="poster-form" class="grid gap-5" @submit.prevent="saveMenuPoster">
        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Mã chi nhánh / khu vực *
            <input v-model="posterForm.branchKey" required class="admin-input-premium" placeholder="quy-nhon, nha-trang..." />
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Tên menu *
            <input v-model="posterForm.title" required class="admin-input-premium" placeholder="ALOO Menu Quy Nhơn" />
          </label>
        </div>

        <div class="grid gap-5 md:grid-cols-3">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500 md:col-span-2">
            Mô tả ngắn
            <input v-model="posterForm.subtitle" class="admin-input-premium" placeholder="Menu theo chi nhánh hoặc khu vực" />
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Thứ tự
            <input v-model.number="posterForm.sortOrder" type="number" min="0" class="admin-input-premium" />
          </label>
        </div>

        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Trạng thái
            <select v-model="posterForm.status" class="admin-input-premium cursor-pointer">
              <option v-for="status in productStatuses" :key="status" :value="status">{{ statusLabels[status] }}</option>
            </select>
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Alt text
            <input v-model="posterForm.altText" class="admin-input-premium" placeholder="Mô tả ảnh menu cho SEO" />
          </label>
        </div>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          Đường dẫn ảnh menu
          <div class="relative">
            <Link class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 h-4.5 w-4.5" />
            <input v-model="posterForm.imageUrl" class="admin-input-premium admin-input-with-icon" placeholder="https://..." />
          </div>
        </label>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          Hoặc tải ảnh menu từ máy tính
          <input
            type="file"
            accept=".jpg,.jpeg,.jfif,.png,.webp,.gif,image/jpeg,image/png,image/webp,image/gif"
            class="w-full text-xs font-bold text-slate-600 file:mr-4 file:rounded-xl file:border-0 file:bg-avocado-600 file:px-4 file:py-2.5 file:font-semibold file:text-white file:cursor-pointer hover:file:bg-avocado-700 transition"
            :disabled="isUploadingPosterImage"
            @change="handlePosterImageFileChange"
          />
          <span v-if="isUploadingPosterImage" class="text-xs font-bold text-avocado-700 animate-pulse">Đang upload ảnh menu...</span>
        </label>

        <div v-if="posterForm.imageUrl" class="rounded-2xl border border-slate-100 bg-slate-50/50 p-4">
          <p class="mb-2 text-xs font-bold uppercase tracking-wider text-slate-400">Xem trước menu</p>
          <img :src="posterForm.imageUrl" alt="Xem trước menu" class="h-44 w-32 rounded-xl border border-slate-100 object-cover shadow-sm" />
        </div>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3 pt-3 border-t border-slate-100">
          <button class="rounded-full border border-slate-200 px-5 py-3 text-xs font-bold uppercase tracking-wider text-slate-500 hover:bg-slate-50 transition" @click="closePosterModal">Hủy bỏ</button>
          <button
            class="rounded-full bg-avocado-600 px-6 py-3 text-xs font-bold uppercase tracking-wider text-white hover:bg-avocado-700 disabled:cursor-not-allowed disabled:opacity-60 transition shadow-md"
            form="poster-form"
            type="submit"
            :disabled="isUploadingPosterImage"
          >
            {{ posterMode === 'create' ? 'Tạo menu' : 'Lưu cập nhật' }}
          </button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal :show="Boolean(pendingDeleteId)" @cancel="pendingDeleteId = null" @confirm="confirmDeleteProduct" />
    <ConfirmModal :show="Boolean(pendingDeletePosterId)" @cancel="pendingDeletePosterId = null" @confirm="confirmDeleteMenuPoster" />
  </section>
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
  border-color: rgb(112, 149, 107);
  box-shadow: 0 0 0 3px rgba(112, 149, 107, 0.1);
}

.admin-input-with-icon {
  padding-left: 2.75rem;
}
</style>



