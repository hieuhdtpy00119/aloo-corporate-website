<script setup>
import { computed, reactive, ref, watch } from 'vue'
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
const isLoading = ref(false)
const currentPage = ref(1)
const pageSize = 5
const statusOptions = ['Đang hiển thị', 'Ẩn', 'Hết hạn']
const statusFilters = ['Tất cả', ...statusOptions]

const form = reactive({
  title: '',
  description: '',
  image: '',
  position: '',
  status: 'Đang hiển thị',
})

const resetForm = () => {
  form.title = ''
  form.description = ''
  form.image = ''
  form.position = ''
  form.status = 'Đang hiển thị'
  editingId.value = null
}

const openCreateModal = () => {
  mode.value = 'create'
  resetForm()
  showModal.value = true
}

const openEditModal = (banner) => {
  mode.value = 'edit'
  editingId.value = banner.id
  Object.assign(form, {
    title: banner.title,
    description: banner.description,
    image: banner.image,
    position: banner.position || '',
    status: banner.status,
  })
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const saveBanner = () => {
  const payload = {
    title: form.title,
    description: form.description,
    subtitle: form.description,
    cta: 'Xem thêm',
    image: form.image,
    position: form.position,
    status: form.status,
  }

  if (mode.value === 'create') {
    store.banners.push({ id: Date.now(), ...payload })
    toast.success('Đã thêm banner thành công')
  } else {
    const banner = store.banners.find((item) => item.id === editingId.value)
    if (banner) Object.assign(banner, payload)
    toast.success('Đã cập nhật banner thành công')
  }

  closeModal()
}

const deleteBanner = (bannerId) => {
  pendingDeleteId.value = bannerId
}

const confirmDeleteBanner = () => {
  const index = store.banners.findIndex((item) => item.id === pendingDeleteId.value)
  if (index !== -1) {
    store.banners.splice(index, 1)
    toast.success('Đã xóa banner thành công')
  }
  pendingDeleteId.value = null
}

const notifyStatusChange = () => {
  toast.success('Đã cập nhật trạng thái banner')
}

const statusClass = (status) => ({
  'bg-green-50 text-green-700 border-green-200': status === 'Đang hiển thị',
  'bg-gray-50 text-gray-700 border-gray-200': status === 'Ẩn',
  'bg-red-50 text-red-700 border-red-200': status === 'Hết hạn',
})

const filteredBanners = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return store.banners.filter((banner) => {
    const matchesSearch =
      !keyword ||
      banner.title.toLowerCase().includes(keyword) ||
      banner.description.toLowerCase().includes(keyword) ||
      String(banner.position || '').toLowerCase().includes(keyword)
    const matchesStatus = statusFilter.value === 'Tất cả' || banner.status === statusFilter.value
    return matchesSearch && matchesStatus
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredBanners.value.length / pageSize)))
const paginatedBanners = computed(() =>
  filteredBanners.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)

watch([searchQuery, statusFilter], () => {
  currentPage.value = 1
})
</script>

<template>
  <section>
    <div class="mb-6 flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
      <div>
        <h2 class="text-3xl font-black text-avocado-950">Quản lý banner</h2>
        <p class="mt-2 text-slate-600">Quản lý banner trang chủ và các banner chiến dịch của ALOO.</p>
      </div>
      <button class="rounded-xl bg-[#2D5A27] px-5 py-3 font-black text-white hover:bg-[#24491f]" @click="openCreateModal">
        Thêm banner
      </button>
    </div>

    <SearchFilterBar v-model:search="searchQuery" v-model:status="statusFilter" search-placeholder="Tìm banner theo tiêu đề, mô tả, vị trí" :status-options="statusFilters" />

    <div class="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
      <EmptyState v-if="isLoading || filteredBanners.length === 0" :loading="isLoading" />
      <div class="overflow-x-auto">
        <table v-if="!isLoading && filteredBanners.length > 0" class="min-w-full divide-y divide-slate-200 text-left">
          <thead class="bg-slate-50">
            <tr>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Tiêu đề</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Mô tả</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Ảnh</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Vị trí</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Trạng thái</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Hành động</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr v-for="banner in paginatedBanners" :key="banner.id" class="hover:bg-avocado-50/60">
              <td class="min-w-56 px-5 py-4 text-sm font-bold text-avocado-950">{{ banner.title }}</td>
              <td class="min-w-80 px-5 py-4 text-sm text-slate-700">{{ banner.description }}</td>
              <td class="whitespace-nowrap px-5 py-4">
                <img :src="banner.image" :alt="banner.title" class="h-14 w-24 rounded-md object-cover" />
              </td>
              <td class="whitespace-nowrap px-5 py-4 text-sm text-slate-700">{{ banner.position }}</td>
              <td class="whitespace-nowrap px-5 py-4 text-sm">
                <select v-model="banner.status" class="rounded-full border px-3 py-1.5 text-sm font-bold outline-none" :class="statusClass(banner.status)" @change="notifyStatusChange">
                  <option v-for="status in statusOptions" :key="status" :value="status">{{ status }}</option>
                </select>
              </td>
              <td class="whitespace-nowrap px-5 py-4 text-sm">
                <div class="flex gap-2">
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 font-bold text-avocado-700 hover:bg-avocado-50" @click="openEditModal(banner)">Sửa</button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600 hover:bg-red-50" @click="deleteBanner(banner.id)">Xóa</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <Pagination :page="currentPage" :total-pages="totalPages" :visible-count="paginatedBanners.length" :total-count="filteredBanners.length" label="banner" @prev="currentPage--" @next="currentPage++" />

    <BaseModal :show="showModal" :title="mode === 'create' ? 'Thêm banner' : 'Sửa banner'" @close="closeModal">
      <form id="banner-form" class="grid gap-5 md:grid-cols-2" @submit.prevent="saveBanner">
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Tiêu đề
          <input v-model="form.title" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Vị trí
          <input v-model="form.position" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
          Mô tả
          <textarea v-model="form.description" required rows="3" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Ảnh
          <input v-model="form.image" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Trạng thái
          <select v-model="form.status" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500">
            <option v-for="status in statusOptions" :key="status" :value="status">{{ status }}</option>
          </select>
        </label>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-lg border border-slate-200 px-4 py-3 font-bold text-slate-600 hover:bg-slate-50" @click="closeModal">Hủy</button>
          <button class="rounded-lg bg-[#2D5A27] px-4 py-3 font-black text-white hover:bg-[#24491f]" form="banner-form" type="submit">
            {{ mode === 'create' ? 'Thêm mới' : 'Lưu thay đổi' }}
          </button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal
      :show="Boolean(pendingDeleteId)"
      @cancel="pendingDeleteId = null"
      @confirm="confirmDeleteBanner"
    />
  </section>
</template>
