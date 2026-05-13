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
const provinceFilter = ref('Tất cả')
const isLoading = ref(false)
const currentPage = ref(1)
const pageSize = 5
const statusOptions = ['Đang hoạt động', 'Sắp khai trương']
const statusFilters = ['Tất cả', ...statusOptions]

const form = reactive({
  name: '',
  address: '',
  province: '',
  phone: '',
  openingHours: '',
  mapUrl: '',
  status: 'Đang hoạt động',
})

const resetForm = () => {
  form.name = ''
  form.address = ''
  form.province = ''
  form.phone = ''
  form.openingHours = ''
  form.mapUrl = ''
  form.status = 'Đang hoạt động'
  delete form.id
  editingId.value = null
}

const openCreateModal = () => {
  mode.value = 'create'
  resetForm()
  showModal.value = true
}

const openEditModal = (location) => {
  mode.value = 'edit'
  editingId.value = location.id
  Object.assign(form, { ...location })
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const saveLocation = () => {
  if (mode.value === 'create') {
    store.locations.push({ id: Date.now(), ...form })
    toast.success('Đã thêm địa điểm thành công')
  } else {
    const location = store.locations.find((item) => item.id === editingId.value)
    if (location) Object.assign(location, { ...form })
    toast.success('Đã cập nhật địa điểm thành công')
  }
  closeModal()
}

const deleteLocation = (locationId) => {
  pendingDeleteId.value = locationId
}

const confirmDeleteLocation = () => {
  const index = store.locations.findIndex((item) => item.id === pendingDeleteId.value)
  if (index !== -1) {
    store.locations.splice(index, 1)
    toast.success('Đã xóa địa điểm thành công')
  }
  pendingDeleteId.value = null
}

const notifyStatusChange = () => {
  toast.success('Đã cập nhật trạng thái địa điểm')
}

const statusClass = (status) => ({
  'bg-green-50 text-green-700 border-green-200': status === 'Đang hoạt động',
  'bg-yellow-50 text-yellow-700 border-yellow-200': status === 'Sắp khai trương',
})

const provinceFilters = computed(() => ['Tất cả', ...new Set(store.locations.map((item) => item.province))])

const filteredLocations = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return store.locations.filter((location) => {
    const matchesSearch =
      !keyword ||
      location.name.toLowerCase().includes(keyword) ||
      location.address.toLowerCase().includes(keyword) ||
      location.province.toLowerCase().includes(keyword)
    const matchesStatus = statusFilter.value === 'Tất cả' || location.status === statusFilter.value
    const matchesProvince = provinceFilter.value === 'Tất cả' || location.province === provinceFilter.value
    return matchesSearch && matchesStatus && matchesProvince
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredLocations.value.length / pageSize)))
const paginatedLocations = computed(() =>
  filteredLocations.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)

watch([searchQuery, statusFilter, provinceFilter], () => {
  currentPage.value = 1
})
</script>

<template>
  <section>
    <div class="mb-6 flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
      <div>
        <h2 class="text-3xl font-black text-avocado-950">Quản lý địa điểm</h2>
        <p class="mt-2 text-slate-600">Quản lý địa điểm cửa hàng ALOO bằng dữ liệu mock.</p>
      </div>
      <button class="rounded-xl bg-[#2D5A27] px-5 py-3 font-black text-white hover:bg-[#24491f]" @click="openCreateModal">
        Thêm địa điểm
      </button>
    </div>

    <SearchFilterBar
      v-model:search="searchQuery"
      v-model:status="statusFilter"
      v-model:extra-filter="provinceFilter"
      search-placeholder="Tìm chi nhánh, địa chỉ, tỉnh/thành"
      :status-options="statusFilters"
      :extra-options="provinceFilters"
    />

    <div class="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
      <EmptyState v-if="isLoading || filteredLocations.length === 0" :loading="isLoading" />
      <div class="overflow-x-auto">
        <table v-if="!isLoading && filteredLocations.length > 0" class="min-w-full divide-y divide-slate-200 text-left">
          <thead class="bg-slate-50">
            <tr>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Tên chi nhánh</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Địa chỉ</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Tỉnh/thành</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Điện thoại</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Trạng thái</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Hành động</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr v-for="location in paginatedLocations" :key="location.id" class="hover:bg-avocado-50/60">
              <td class="whitespace-nowrap px-5 py-4 text-sm font-bold text-avocado-950">{{ location.name }}</td>
              <td class="min-w-80 px-5 py-4 text-sm text-slate-700">{{ location.address }}</td>
              <td class="whitespace-nowrap px-5 py-4 text-sm text-slate-700">{{ location.province }}</td>
              <td class="whitespace-nowrap px-5 py-4 text-sm text-slate-700">{{ location.phone }}</td>
              <td class="whitespace-nowrap px-5 py-4 text-sm">
                <select v-model="location.status" class="rounded-full border px-3 py-1.5 text-sm font-bold outline-none" :class="statusClass(location.status)" @change="notifyStatusChange">
                  <option v-for="status in statusOptions" :key="status" :value="status">{{ status }}</option>
                </select>
              </td>
              <td class="whitespace-nowrap px-5 py-4 text-sm">
                <div class="flex gap-2">
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 font-bold text-avocado-700 hover:bg-avocado-50" @click="openEditModal(location)">Sửa</button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600 hover:bg-red-50" @click="deleteLocation(location.id)">Xóa</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <Pagination :page="currentPage" :total-pages="totalPages" :visible-count="paginatedLocations.length" :total-count="filteredLocations.length" label="địa điểm" @prev="currentPage--" @next="currentPage++" />

    <BaseModal :show="showModal" :title="mode === 'create' ? 'Thêm địa điểm' : 'Sửa địa điểm'" max-width="max-w-3xl" @close="closeModal">
      <form id="location-form" class="grid gap-5 md:grid-cols-2" @submit.prevent="saveLocation">
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Tên chi nhánh
          <input v-model="form.name" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Tỉnh/thành
          <input v-model="form.province" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
          Địa chỉ
          <input v-model="form.address" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Số điện thoại
          <input v-model="form.phone" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Giờ mở cửa
          <input v-model="form.openingHours" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Link bản đồ
          <input v-model="form.mapUrl" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
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
          <button class="rounded-lg bg-[#2D5A27] px-4 py-3 font-black text-white hover:bg-[#24491f]" form="location-form" type="submit">
            {{ mode === 'create' ? 'Thêm mới' : 'Lưu thay đổi' }}
          </button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal
      :show="Boolean(pendingDeleteId)"
      @cancel="pendingDeleteId = null"
      @confirm="confirmDeleteLocation"
    />
  </section>
</template>
