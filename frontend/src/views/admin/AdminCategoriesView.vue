<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'

const store = useAppStore()
const toast = useToastStore()

const showModal = ref(false)
const mode = ref('create')
const editingId = ref(null)
const pendingDeleteId = ref(null)
const searchQuery = ref('')
const statusFilter = ref('Tất cả')
const currentPage = ref(1)
const pageSize = 5
const isLoading = computed(() => store.loading.categories)
const errorMessage = computed(() => store.errors.categories)

const categoryStatuses = ['ACTIVE', 'INACTIVE']
const statusLabels = {
  ACTIVE: 'Đang hoạt động',
  INACTIVE: 'Tạm ẩn',
}
const statusFilters = ['Tất cả', ...categoryStatuses.map((status) => statusLabels[status])]

const form = reactive({
  name: '',
  slug: '',
  description: '',
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
  Object.assign(form, {
    name: '',
    slug: '',
    description: '',
    status: 'ACTIVE',
  })
  editingId.value = null
}

const statusClass = (status) =>
  status === 'ACTIVE'
    ? 'bg-green-50 text-green-700 border-green-200'
    : 'bg-gray-50 text-gray-700 border-gray-200'

const getStatusValue = (label) =>
  Object.entries(statusLabels).find(([, value]) => value === label)?.[0] || label

const openCreateModal = () => {
  mode.value = 'create'
  resetForm()
  showModal.value = true
}

const openEditModal = (category) => {
  mode.value = 'edit'
  editingId.value = category.id
  Object.assign(form, {
    name: category.name,
    slug: category.slug,
    description: category.description || '',
    status: category.status || 'ACTIVE',
  })
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const saveCategory = async () => {
  const payload = {
    id: editingId.value,
    name: form.name.trim(),
    slug: form.slug.trim(),
    description: form.description.trim(),
    status: form.status,
  }

  try {
    await store.saveCategory(payload)
    toast.success(mode.value === 'create' ? 'Đã thêm danh mục thành công' : 'Đã cập nhật danh mục thành công')
    closeModal()
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không lưu được danh mục')
  }
}

const confirmDeleteCategory = async () => {
  try {
    await store.deleteCategory(pendingDeleteId.value)
    toast.success('Đã xóa danh mục thành công')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không xóa được danh mục')
  } finally {
    pendingDeleteId.value = null
  }
}

const saveExistingCategoryStatus = async (category) => {
  try {
    await store.saveCategory(category)
    toast.success('Đã cập nhật trạng thái danh mục')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không cập nhật được trạng thái')
    store.fetchCategories()
  }
}

const filteredCategories = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return store.categories
    .filter((category) => {
      const matchesSearch =
        !keyword ||
        category.name.toLowerCase().includes(keyword) ||
        category.slug.toLowerCase().includes(keyword) ||
        category.description?.toLowerCase().includes(keyword)
      const matchesStatus =
        statusFilter.value === 'Tất cả' || category.status === getStatusValue(statusFilter.value)
      return matchesSearch && matchesStatus
    })
    .sort((a, b) => a.name.localeCompare(b.name, 'vi'))
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredCategories.value.length / pageSize)))
const paginatedCategories = computed(() =>
  filteredCategories.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)

watch(
  () => form.name,
  (name) => {
    if (!form.slug) form.slug = slugify(name)
  },
)

watch([searchQuery, statusFilter], () => {
  currentPage.value = 1
})

onMounted(() => {
  store.fetchCategories().catch(() => {
    toast.error('Không tải được danh mục')
  })
})
</script>

<template>
  <section>
    <div class="mb-6 flex flex-col justify-between gap-4 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm lg:flex-row lg:items-center">
      <div>
        <h1 class="text-3xl font-black text-avocado-950">Quản lý danh mục</h1>
        <p class="mt-2 text-slate-600">Quản lý danh mục bài viết và sản phẩm.</p>
      </div>
      <button class="rounded-xl bg-[#2D5A27] px-5 py-3 font-black text-white hover:bg-[#24491f]" @click="openCreateModal">
        Thêm danh mục
      </button>
    </div>

    <SearchFilterBar
      v-model:search="searchQuery"
      v-model:status="statusFilter"
      search-label="Tìm danh mục"
      search-placeholder="Tìm tên danh mục, slug, mô tả"
      status-label="Trạng thái"
      :status-options="statusFilters"
    />
    <p v-if="errorMessage" class="mb-4 rounded-lg bg-red-50 px-4 py-3 text-sm font-bold text-red-700">
      {{ errorMessage }}
    </p>

    <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
      <div class="overflow-x-auto">
        <table v-if="!isLoading && filteredCategories.length" class="min-w-[760px] w-full table-fixed whitespace-nowrap text-left">
          <colgroup>
            <col class="w-[22%]" />
            <col class="w-[20%]" />
            <col class="w-[28%]" />
            <col class="w-[15%]" />
            <col class="w-[15%]" />
          </colgroup>
          <thead class="bg-slate-50 text-sm font-black text-slate-600">
            <tr>
              <th class="px-5 py-4">Tên danh mục</th>
              <th class="px-5 py-4">Slug</th>
              <th class="px-5 py-4">Mô tả</th>
              <th class="px-5 py-4">Trạng thái</th>
              <th class="px-5 py-4 text-right">Hành động</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100 text-sm">
            <tr v-for="category in paginatedCategories" :key="category.id" class="hover:bg-slate-50/70">
              <td class="px-5 py-4">
                <p class="font-black text-avocado-950">{{ category.name }}</p>
              </td>
              <td class="px-5 py-4 font-semibold text-slate-600">
                <span class="block truncate">/{{ category.slug }}</span>
              </td>
              <td class="px-5 py-4 text-slate-600">
                <p class="truncate">{{ category.description || 'Chưa có mô tả' }}</p>
              </td>
              <td class="px-5 py-4">
                <select v-model="category.status" class="rounded-full border px-3 py-1.5 text-sm font-bold outline-none" :class="statusClass(category.status)" @change="saveExistingCategoryStatus(category)">
                  <option v-for="status in categoryStatuses" :key="status" :value="status">{{ statusLabels[status] }}</option>
                </select>
              </td>
              <td class="px-5 py-4">
                <div class="flex justify-end gap-2">
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 font-bold text-avocado-700 hover:bg-avocado-50" @click="openEditModal(category)">Sửa</button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600 hover:bg-red-50" @click="pendingDeleteId = category.id">Xóa</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <EmptyState v-if="isLoading || filteredCategories.length === 0" :loading="isLoading" message="Không có dữ liệu phù hợp" />
    </div>

    <Pagination
      :page="currentPage"
      :total-pages="totalPages"
      :visible-count="paginatedCategories.length"
      :total-count="filteredCategories.length"
      label="danh mục"
      @prev="currentPage = Math.max(1, currentPage - 1)"
      @next="currentPage = Math.min(totalPages, currentPage + 1)"
    />

    <BaseModal :show="showModal" :title="mode === 'create' ? 'Thêm danh mục' : 'Sửa danh mục'" max-width="max-w-2xl" @close="closeModal">
      <form id="category-form" class="grid gap-5 md:grid-cols-2" @submit.prevent="saveCategory">
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Tên danh mục
          <input v-model="form.name" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Slug
          <input v-model="form.slug" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Trạng thái
          <select v-model="form.status" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500">
            <option v-for="status in categoryStatuses" :key="status" :value="status">{{ statusLabels[status] }}</option>
          </select>
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
          Mô tả ngắn
          <textarea v-model="form.description" rows="3" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
        </label>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-lg border border-slate-200 px-4 py-3 font-bold text-slate-600 hover:bg-slate-50" @click="closeModal">Hủy</button>
          <button class="rounded-lg bg-[#2D5A27] px-4 py-3 font-black text-white hover:bg-[#24491f]" form="category-form" type="submit">
            {{ mode === 'create' ? 'Thêm mới' : 'Lưu thay đổi' }}
          </button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal :show="Boolean(pendingDeleteId)" @cancel="pendingDeleteId = null" @confirm="confirmDeleteCategory" />
  </section>
</template>
