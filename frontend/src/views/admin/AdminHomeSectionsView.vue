<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import { homeSectionService, postService, productService, resolveBackendAssetUrl, uploadService } from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'

const toast = useToastStore()

const sections = ref([])
const isLoading = ref(false)
const errorMessage = ref('')
const showModal = ref(false)
const mode = ref('create')
const editingId = ref(null)
const pendingDeleteId = ref(null)
const searchQuery = ref('')
const statusFilter = ref('Tất cả')
const currentPage = ref(1)
const isUploadingImage = ref(false)
const isLoadingLinkOptions = ref(false)
const linkType = ref('CUSTOM')
const linkTarget = ref('')
const products = ref([])
const posts = ref([])
const pageSize = 6

const statusLabels = {
  ACTIVE: 'Đang hiển thị',
  INACTIVE: 'Tạm ẩn',
}
const statusFilters = ['Tất cả', ...Object.values(statusLabels)]
const typeOptions = ['FEATURED_CARD', 'CTA_CARD', 'PRODUCT_CARD', 'LOCATION_CARD']
const typeLabels = {
  FEATURED_CARD: 'Card nổi bật',
  CTA_CARD: 'Card CTA',
  PRODUCT_CARD: 'Card sản phẩm',
  LOCATION_CARD: 'Card cửa hàng',
}
const staticLinkOptions = [
  { label: 'Trang chủ', value: '/' },
  { label: 'Sản phẩm', value: '/products' },
  { label: 'Hệ thống cửa hàng', value: '/locations' },
  { label: 'Nhượng quyền', value: '/franchise' },
  { label: 'Về ALOO', value: '/about' },
  { label: 'Blog', value: '/blog' },
  { label: 'Đăng ký tư vấn', value: '/consultation' },
  { label: 'Liên hệ', value: '/contact' },
]
const linkTypeOptions = [
  { value: 'NONE', label: 'Không hiển thị nút' },
  { value: 'STATIC', label: 'Trang có sẵn' },
  { value: 'PRODUCT', label: 'Sản phẩm cụ thể' },
  { value: 'POST', label: 'Bài viết cụ thể' },
  { value: 'CUSTOM', label: 'Link tùy chỉnh' },
]

const defaultForm = () => ({
  sectionKey: '',
  type: 'FEATURED_CARD',
  title: '',
  subtitle: 'Tuyển chọn',
  description: '',
  imageUrl: '',
  buttonText: 'Xem thêm',
  buttonLink: '/',
  badge: '',
  sortOrder: 0,
  status: 'ACTIVE',
})

const form = reactive(defaultForm())
const imagePreviewUrl = computed(() => resolveBackendAssetUrl(form.imageUrl || ''))
const resolvedButtonLink = computed(() => {
  if (linkType.value === 'NONE') return ''
  if (linkType.value === 'STATIC') return linkTarget.value
  if (linkType.value === 'PRODUCT') return linkTarget.value ? `/products/${linkTarget.value}` : ''
  if (linkType.value === 'POST') return linkTarget.value ? `/blog/${linkTarget.value}` : ''
  return form.buttonLink.trim()
})

const slugify = (value) =>
  value
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '')

const statusClass = (status) =>
  status === 'ACTIVE'
    ? 'bg-green-50 text-green-700 border-green-200'
    : 'bg-gray-50 text-gray-700 border-gray-200'

const getStatusValue = (label) => Object.entries(statusLabels).find(([, value]) => value === label)?.[0] || label

const resetForm = () => {
  Object.assign(form, defaultForm())
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
  if (staticLinkOptions.some((option) => option.value === normalized)) {
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
    if (!form.buttonText.trim()) form.buttonText = 'Xem thêm'
    return
  }
  linkTarget.value = ''
  if (linkType.value === 'PRODUCT' && !form.buttonText.trim()) form.buttonText = 'Xem sản phẩm'
  if (linkType.value === 'POST' && !form.buttonText.trim()) form.buttonText = 'Đọc bài viết'
}

const normalizeSection = (section) => ({
  ...section,
  imageUrl: resolveBackendAssetUrl(section.imageUrl || ''),
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
    errorMessage.value = error.response?.data?.message || 'Không tải được nội dung trang chủ'
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
    toast.error(error.response?.data?.message || 'Không tải được danh sách link gợi ý')
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
    ...defaultForm(),
    sectionKey: section.sectionKey || '',
    type: section.type || 'FEATURED_CARD',
    title: section.title || '',
    subtitle: section.subtitle || '',
    description: section.description || '',
    imageUrl: section.imageUrl || '',
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
    form.imageUrl = data.url
    toast.success('Đã tải ảnh block trang chủ')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không tải được ảnh')
  } finally {
    isUploadingImage.value = false
    event.target.value = ''
  }
}

const saveSection = async () => {
  if (!form.sectionKey.trim() || !form.title.trim()) {
    toast.error('Vui lòng nhập mã block và tiêu đề')
    return
  }
  if (linkType.value !== 'NONE' && form.buttonText.trim() && !resolvedButtonLink.value) {
    toast.error('Vui lòng chọn hoặc nhập link cho nút')
    return
  }

  const payload = {
    sectionKey: form.sectionKey.trim(),
    type: form.type,
    title: form.title.trim(),
    subtitle: form.subtitle.trim(),
    description: form.description.trim(),
    imageUrl: form.imageUrl,
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
    toast.success(mode.value === 'create' ? 'Đã thêm block trang chủ' : 'Đã cập nhật block trang chủ')
    closeModal()
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không lưu được block trang chủ')
  }
}

const confirmDeleteSection = async () => {
  try {
    await homeSectionService.remove(pendingDeleteId.value)
    sections.value = sections.value.filter((section) => section.id !== pendingDeleteId.value)
    toast.success('Đã xóa block trang chủ')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không xóa được block trang chủ')
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
      const matchesStatus = statusFilter.value === 'Tất cả' || section.status === getStatusValue(statusFilter.value)
      return matchesSearch && matchesStatus
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
    if (!form.sectionKey) form.sectionKey = slugify(title)
  },
)

watch([searchQuery, statusFilter], () => {
  currentPage.value = 1
})

onMounted(() => {
  fetchSections()
  fetchLinkOptions()
})
</script>

<template>
  <section>
    <div class="mb-6 flex flex-col justify-between gap-4 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm lg:flex-row lg:items-center">
      <div>
        <p class="text-sm font-bold text-slate-500">CMS trang chủ</p>
        <h1 class="text-3xl font-black text-avocado-950">Nội dung nổi bật trang chủ</h1>
        <p class="mt-2 text-slate-600">Quản lý các block hiển thị ở mục Tuyển chọn / Nổi bật hôm nay.</p>
      </div>
      <button class="rounded-xl bg-[#2D5A27] px-5 py-3 font-black text-white hover:bg-[#24491f]" @click="openCreateModal">
        Thêm block
      </button>
    </div>

    <SearchFilterBar
      v-model:search="searchQuery"
      v-model:status="statusFilter"
      search-label="Tìm block"
      search-placeholder="Tìm tiêu đề, mã block, mô tả"
      status-label="Trạng thái"
      :status-options="statusFilters"
    />

    <p v-if="errorMessage" class="mb-4 rounded-lg bg-red-50 px-4 py-3 text-sm font-bold text-red-700">{{ errorMessage }}</p>

    <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
      <div class="overflow-x-auto">
        <table v-if="!isLoading && filteredSections.length" class="min-w-[980px] w-full table-fixed whitespace-nowrap text-left">
          <colgroup>
            <col class="w-[12%]" />
            <col class="w-[24%]" />
            <col class="w-[14%]" />
            <col class="w-[22%]" />
            <col class="w-[16%]" />
            <col class="w-[12%]" />
          </colgroup>
          <thead class="bg-slate-50 text-sm font-black text-slate-600">
            <tr>
              <th class="px-5 py-4">Ảnh</th>
              <th class="px-5 py-4">Nội dung</th>
              <th class="px-5 py-4">Loại</th>
              <th class="px-5 py-4">Liên kết</th>
              <th class="px-5 py-4">Trạng thái</th>
              <th class="px-5 py-4 text-right">Hành động</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100 text-sm">
            <tr v-for="section in paginatedSections" :key="section.id" class="hover:bg-slate-50/70">
              <td class="px-5 py-4">
                <img v-if="section.imageUrl" :src="section.imageUrl" :alt="section.title" class="h-14 w-20 rounded-xl object-cover" />
                <div v-else class="grid h-14 w-20 place-items-center rounded-xl bg-slate-100 text-xs font-black text-slate-400">ALOO</div>
              </td>
              <td class="px-5 py-4">
                <p class="truncate font-black text-avocado-950">{{ section.title }}</p>
                <p class="mt-1 truncate text-xs font-semibold text-slate-500">{{ section.sectionKey }} · #{{ section.sortOrder }}</p>
              </td>
              <td class="px-5 py-4 font-bold text-slate-600">{{ typeLabels[section.type] || section.type }}</td>
              <td class="px-5 py-4 text-slate-600">
                <p class="truncate font-bold">{{ section.buttonText || 'Không có nút' }}</p>
                <p class="truncate text-xs text-slate-400">{{ section.buttonLink || 'Chưa gắn link' }}</p>
              </td>
              <td class="px-5 py-4">
                <span class="inline-flex min-w-[122px] justify-center rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(section.status)">
                  {{ statusLabels[section.status] || section.status }}
                </span>
              </td>
              <td class="px-5 py-4">
                <div class="flex justify-end gap-2">
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 font-bold text-avocado-700 hover:bg-avocado-50" @click="openEditModal(section)">Sửa</button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600 hover:bg-red-50" @click="pendingDeleteId = section.id">Xóa</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
        <div v-else-if="isLoading" class="p-10 text-center text-sm font-bold text-slate-500">Đang tải nội dung trang chủ...</div>
        <EmptyState v-else title="Chưa có block trang chủ" description="Thêm block đầu tiên để hiển thị ở mục Nổi bật hôm nay." />
      </div>
    </div>

    <Pagination
      v-if="filteredSections.length"
      :page="currentPage"
      :total-pages="totalPages"
      :visible-count="paginatedSections.length"
      :total-count="filteredSections.length"
      label="block"
      @prev="currentPage = Math.max(1, currentPage - 1)"
      @next="currentPage = Math.min(totalPages, currentPage + 1)"
    />

    <BaseModal :show="showModal" :title="mode === 'create' ? 'Thêm block trang chủ' : 'Cập nhật block trang chủ'" max-width="max-w-5xl" @close="closeModal">
      <form id="home-section-form" class="grid gap-6" @submit.prevent="saveSection">
        <section class="grid gap-4 rounded-2xl bg-slate-50 p-5 md:grid-cols-2">
          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">Thông tin cơ bản</h3>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
                  Tiêu đề *
            <input v-model="form.title" required class="admin-input" placeholder="Kem bơ truyền thống" />
                </label>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
                  Mã block *
            <input v-model="form.sectionKey" required class="admin-input" placeholder="featured-product" />
                </label>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
                  Loại block
            <select v-model="form.type" class="admin-input cursor-pointer">
                    <option v-for="type in typeOptions" :key="type" :value="type">{{ typeLabels[type] }}</option>
                  </select>
                </label>
          <div class="grid grid-cols-2 gap-4">
            <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
                    Thứ tự
              <input v-model.number="form.sortOrder" type="number" min="0" class="admin-input" />
                  </label>
            <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
                    Trạng thái
              <select v-model="form.status" class="admin-input cursor-pointer">
                      <option value="ACTIVE">Đang hiển thị</option>
                      <option value="INACTIVE">Tạm ẩn</option>
                    </select>
                  </label>
                </div>
        </section>

        <section class="grid gap-4 rounded-2xl bg-slate-50 p-5 md:grid-cols-2">
          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">Nội dung hiển thị</h3>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
                  Nhãn nhỏ
            <input v-model="form.subtitle" class="admin-input" placeholder="Tuyển chọn" />
                </label>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
                  Badge trên ảnh
            <input v-model="form.badge" class="admin-input" placeholder="Bán chạy nhất" />
                </label>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700 md:col-span-2">
                  Mô tả
            <textarea v-model="form.description" rows="4" class="admin-input resize-none" placeholder="Mô tả ngắn hiển thị trên card..."></textarea>
                </label>
        </section>

        <section class="grid gap-4 rounded-2xl bg-slate-50 p-5 md:grid-cols-2">
          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">Nút điều hướng</h3>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
            Text nút
            <input v-model="form.buttonText" class="admin-input" placeholder="Xem sản phẩm" />
          </label>
          <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
            Kiểu liên kết
            <select v-model="linkType" class="admin-input cursor-pointer" @change="handleLinkTypeChange">
              <option v-for="option in linkTypeOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
            </select>
          </label>

          <label v-if="linkType === 'STATIC'" class="grid min-w-0 gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            Chọn trang
            <select v-model="linkTarget" class="admin-input cursor-pointer">
              <option v-for="option in staticLinkOptions" :key="option.value" :value="option.value">{{ option.label }} - {{ option.value }}</option>
            </select>
          </label>

          <label v-else-if="linkType === 'PRODUCT'" class="grid min-w-0 gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            Chọn sản phẩm
            <select v-model="linkTarget" class="admin-input cursor-pointer" :disabled="isLoadingLinkOptions">
              <option value="">Chọn sản phẩm để gắn link</option>
              <option v-for="product in products" :key="product.id" :value="String(product.slug || product.id)">
                {{ product.name }} - /products/{{ product.slug }}
              </option>
            </select>
          </label>

          <label v-else-if="linkType === 'POST'" class="grid min-w-0 gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            Chọn bài viết
            <select v-model="linkTarget" class="admin-input cursor-pointer" :disabled="isLoadingLinkOptions">
              <option value="">Chọn bài viết để gắn link</option>
              <option v-for="post in posts" :key="post.id" :value="String(post.slug || post.id)">
                {{ post.title }} - /blog/{{ post.slug || post.id }}
              </option>
            </select>
          </label>

          <label v-else-if="linkType === 'CUSTOM'" class="grid min-w-0 gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            Link tùy chỉnh
            <input v-model="form.buttonLink" class="admin-input" placeholder="/products/kem-bo-truyen-thong hoặc https://..." />
          </label>

          <div v-if="linkType !== 'NONE'" class="rounded-xl border border-avocado-100 bg-white px-4 py-3 text-sm font-semibold text-slate-600 md:col-span-2">
            Link sẽ lưu:
            <span class="font-black text-avocado-800">{{ resolvedButtonLink || 'Chưa chọn link' }}</span>
          </div>
        </section>

        <section class="grid gap-4 rounded-2xl bg-slate-50 p-5 md:grid-cols-[minmax(0,1fr)_260px]">
          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">Hình ảnh</h3>
          <div class="grid content-start gap-4">
            <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
              Image URL
              <input v-model="form.imageUrl" class="admin-input" placeholder="https://... hoặc /uploads/..." />
            </label>
            <label class="grid min-w-0 gap-2 text-sm font-bold text-slate-700">
              Chọn file ảnh
              <input type="file" accept=".jpg,.jpeg,.jfif,.png,.webp,.gif,image/jpeg,image/png,image/webp,image/gif" class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-600 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isUploadingImage" @change="handleImageFileChange" />
              <span v-if="isUploadingImage" class="text-xs font-bold text-avocado-700">Đang upload lên máy chủ...</span>
            </label>
          </div>
          <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
            <div class="flex aspect-[4/3] items-center justify-center overflow-hidden bg-slate-100">
              <img v-if="imagePreviewUrl" :src="imagePreviewUrl" alt="Xem trước block" class="aspect-[4/3] w-full object-cover" />
              <p v-else class="px-4 text-center text-sm font-bold text-slate-400">Chưa có ảnh</p>
            </div>
          </div>
        </section>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-lg border border-slate-200 px-4 py-3 font-bold text-slate-600 hover:bg-slate-50" @click="closeModal">Hủy</button>
          <button class="rounded-lg bg-[#2D5A27] px-4 py-3 font-black text-white hover:bg-[#24491f] disabled:cursor-not-allowed disabled:opacity-60" form="home-section-form" type="submit" :disabled="isUploadingImage">
            {{ mode === 'create' ? 'Thêm mới' : 'Lưu thay đổi' }}
          </button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal
      :show="pendingDeleteId !== null"
      title="Xóa block trang chủ?"
      message="Block này sẽ bị xóa khỏi CMS trang chủ. Hành động này không thể hoàn tác."
      confirm-text="Xóa block"
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
  border-color: rgb(112, 149, 107);
  box-shadow: 0 0 0 3px rgba(112, 149, 107, 0.12);
}
</style>
