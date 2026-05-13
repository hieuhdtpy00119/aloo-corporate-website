<script setup>
import { computed, ref, watch } from 'vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'

const store = useAppStore()
const toast = useToastStore()
const selectedRegistration = ref(null)
const pendingDeleteId = ref(null)
const searchQuery = ref('')
const statusFilter = ref('Tất cả')
const isLoading = ref(false)
const currentPage = ref(1)
const pageSize = 5
const registrationStatuses = ['Mới', 'Đã liên hệ', 'Đang tư vấn', 'Hoàn tất', 'Hủy']
const statusFilters = ['Tất cả', ...registrationStatuses]

const registrations = computed(() => store.registrations)

// Demo data is local mock data; currency is formatted for UI display only.
const formatCurrency = (value) => `${new Intl.NumberFormat('vi-VN').format(Number(value || 0))} đ`

const statusClass = (status) => ({
  'bg-blue-50 text-blue-700 ring-1 ring-blue-100': status === 'Mới',
  'bg-emerald-50 text-emerald-700 ring-1 ring-emerald-100': status === 'Đã liên hệ',
  'bg-amber-50 text-amber-700 ring-1 ring-amber-100': status === 'Đang tư vấn',
  'bg-purple-50 text-purple-700 ring-1 ring-purple-100': status === 'Hoàn tất',
  'bg-slate-100 text-slate-600 ring-1 ring-slate-200': status === 'Hủy',
})

const getStatusSelectClass = (status) => ({
  'bg-blue-50 text-blue-700 border-blue-200': status === 'Mới',
  'bg-emerald-50 text-emerald-700 border-emerald-200': status === 'Đã liên hệ',
  'bg-amber-50 text-amber-700 border-amber-200': status === 'Đang tư vấn',
  'bg-purple-50 text-purple-700 border-purple-200': status === 'Hoàn tất',
  'bg-red-50 text-red-700 border-red-200': status === 'Hủy',
})

const showDetail = (registration) => {
  selectedRegistration.value = registration
}

const closeDetailModal = () => {
  selectedRegistration.value = null
}

const deleteRegistration = (registrationId) => {
  pendingDeleteId.value = registrationId
}

const confirmDeleteRegistration = () => {
  const index = store.registrations.findIndex((item) => item.id === pendingDeleteId.value)
  if (index !== -1) {
    store.registrations.splice(index, 1)
    toast.success('Đã xóa đăng ký tư vấn thành công')
  }
  if (selectedRegistration.value?.id === pendingDeleteId.value) {
    closeDetailModal()
  }
  pendingDeleteId.value = null
}

const notifyStatusChange = () => {
  toast.success('Đã cập nhật trạng thái đăng ký')
}

const filteredRegistrations = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return registrations.value.filter((registration) => {
    const matchesSearch =
      !keyword ||
      registration.name.toLowerCase().includes(keyword) ||
      registration.phone.toLowerCase().includes(keyword) ||
      registration.email.toLowerCase().includes(keyword) ||
      registration.area.toLowerCase().includes(keyword)
    const matchesStatus = statusFilter.value === 'Tất cả' || registration.status === statusFilter.value
    return matchesSearch && matchesStatus
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredRegistrations.value.length / pageSize)))
const paginatedRegistrations = computed(() =>
  filteredRegistrations.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)

watch([searchQuery, statusFilter], () => {
  currentPage.value = 1
})
</script>

<template>
  <section>
    <div class="mb-6">
      <h2 class="text-3xl font-black text-avocado-950">Đăng ký tư vấn</h2>
      <p class="mt-2 text-slate-600">Danh sách khách hàng tiềm năng và trạng thái xử lý tư vấn nhượng quyền.</p>
    </div>

    <SearchFilterBar v-model:search="searchQuery" v-model:status="statusFilter" search-placeholder="Tìm họ tên, điện thoại, email, khu vực" :status-options="statusFilters" />

    <div class="rounded-lg border border-slate-200 bg-white shadow-sm">
      <EmptyState v-if="isLoading || filteredRegistrations.length === 0" :loading="isLoading" />
      <div v-if="!isLoading && filteredRegistrations.length > 0" class="hidden lg:block">
        <table class="w-full table-fixed divide-y divide-slate-200 text-left">
          <colgroup>
            <col class="w-[16%]" />
            <col class="w-[13%]" />
            <col class="w-[18%]" />
            <col class="w-[11%]" />
            <col class="w-[13%]" />
            <col class="w-[11%]" />
            <col class="w-[18%]" />
          </colgroup>
          <thead class="bg-slate-50">
            <tr>
              <th class="px-4 py-3 text-sm font-black text-slate-600">Họ tên</th>
              <th class="px-4 py-3 text-sm font-black text-slate-600">Số điện thoại</th>
              <th class="px-4 py-3 text-sm font-black text-slate-600">Email</th>
              <th class="px-4 py-3 text-sm font-black text-slate-600">Khu vực</th>
              <th class="px-4 py-3 text-right text-sm font-black text-slate-600">Số vốn</th>
              <th class="px-4 py-3 text-sm font-black text-slate-600">Trạng thái</th>
              <th class="px-4 py-3 text-sm font-black text-slate-600">Hành động</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr v-for="registration in paginatedRegistrations" :key="registration.id" class="align-middle hover:bg-avocado-50/60">
              <td class="px-4 py-3 text-sm font-bold text-avocado-950">{{ registration.name }}</td>
              <td class="px-4 py-3 text-sm text-slate-700">{{ registration.phone }}</td>
              <td class="truncate px-4 py-3 text-sm text-slate-700" :title="registration.email">{{ registration.email }}</td>
              <td class="px-4 py-3 text-sm text-slate-700">{{ registration.area }}</td>
              <td class="px-4 py-3 text-right text-sm font-bold tabular-nums text-slate-800">{{ formatCurrency(registration.capital) }}</td>
              <td class="px-4 py-3 text-sm">
                <select
                  v-model="registration.status"
                  class="w-full max-w-[132px] rounded-full border px-3 py-1.5 text-sm font-bold outline-none transition"
                  :class="getStatusSelectClass(registration.status)"
                  @change="notifyStatusChange"
                >
                  <option v-for="status in registrationStatuses" :key="status" :value="status">{{ status }}</option>
                </select>
              </td>
              <td class="px-4 py-3 align-middle text-sm">
                <div class="flex min-w-[160px] flex-wrap gap-2">
                  <button class="min-w-[92px] rounded-lg border border-blue-200 px-3 py-2 text-center font-bold leading-5 text-blue-700 hover:bg-blue-50" @click="showDetail(registration)">
                    Xem chi tiết
                  </button>
                  <button class="min-w-[58px] rounded-lg border border-red-200 px-3 py-2 text-center font-bold leading-5 text-red-600 hover:bg-red-50" @click="deleteRegistration(registration.id)">
                    Xóa
                  </button>
                </div>
              </td>
            </tr>
            <tr v-if="registrations.length === 0">
              <td colspan="7" class="px-5 py-8 text-center text-sm font-semibold text-slate-500">Chưa có đăng ký tư vấn nào.</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-if="!isLoading && filteredRegistrations.length > 0" class="grid gap-4 p-4 lg:hidden">
        <article v-for="registration in paginatedRegistrations" :key="registration.id" class="rounded-lg border border-slate-200 bg-white p-4 shadow-sm">
          <div class="flex items-start justify-between gap-3">
            <div>
              <h3 class="font-black text-avocado-950">{{ registration.name }}</h3>
              <p class="mt-1 text-sm text-slate-600">{{ registration.phone }}</p>
            </div>
            <select
              v-model="registration.status"
              class="rounded-full border px-3 py-1.5 text-sm font-bold outline-none transition"
              :class="getStatusSelectClass(registration.status)"
              @change="notifyStatusChange"
            >
              <option v-for="status in registrationStatuses" :key="status" :value="status">{{ status }}</option>
            </select>
          </div>
          <div class="mt-4 grid gap-2 text-sm text-slate-700">
            <p><span class="font-bold text-slate-900">Email:</span> {{ registration.email }}</p>
            <p><span class="font-bold text-slate-900">Khu vực:</span> {{ registration.area }}</p>
            <p><span class="font-bold text-slate-900">Số vốn:</span> {{ formatCurrency(registration.capital) }}</p>
          </div>
          <div class="mt-4 grid gap-2 sm:grid-cols-3">
            <button class="rounded-lg border border-blue-200 px-3 py-2 text-sm font-bold text-blue-700 hover:bg-blue-50" @click="showDetail(registration)">
              Xem chi tiết
            </button>
            <button class="rounded-lg border border-red-200 px-3 py-2 text-sm font-bold text-red-600 hover:bg-red-50" @click="deleteRegistration(registration.id)">
              Xóa
            </button>
          </div>
        </article>
      </div>
    </div>

    <Pagination :page="currentPage" :total-pages="totalPages" :visible-count="paginatedRegistrations.length" :total-count="filteredRegistrations.length" label="đăng ký" @prev="currentPage--" @next="currentPage++" />

    <BaseModal :show="Boolean(selectedRegistration)" title="Chi tiết đăng ký tư vấn" @close="closeDetailModal">
      <template v-if="selectedRegistration">
        <p class="mb-5 text-sm text-slate-500">Mã đăng ký #{{ selectedRegistration.id }}</p>
        <dl class="grid gap-4 sm:grid-cols-2">
          <div class="rounded-lg bg-slate-50 p-4">
            <dt class="text-xs font-black uppercase text-slate-500">Họ tên</dt>
            <dd class="mt-1 font-bold text-avocado-950">{{ selectedRegistration.name }}</dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4">
            <dt class="text-xs font-black uppercase text-slate-500">Số điện thoại</dt>
            <dd class="mt-1 font-bold text-avocado-950">{{ selectedRegistration.phone }}</dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4">
            <dt class="text-xs font-black uppercase text-slate-500">Email</dt>
            <dd class="mt-1 break-words font-bold text-avocado-950">{{ selectedRegistration.email }}</dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4">
            <dt class="text-xs font-black uppercase text-slate-500">Khu vực muốn mở cửa hàng</dt>
            <dd class="mt-1 font-bold text-avocado-950">{{ selectedRegistration.area }}</dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4">
            <dt class="text-xs font-black uppercase text-slate-500">Số vốn dự kiến</dt>
            <dd class="mt-1 font-bold text-avocado-950">{{ formatCurrency(selectedRegistration.capital) }}</dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4">
            <dt class="text-xs font-black uppercase text-slate-500">Ngày đăng ký</dt>
            <dd class="mt-1 font-bold text-avocado-950">{{ selectedRegistration.createdAt }}</dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4 sm:col-span-2">
            <dt class="text-xs font-black uppercase text-slate-500">Trạng thái</dt>
            <dd class="mt-2">
              <span class="rounded-full px-3 py-1 text-xs font-bold" :class="statusClass(selectedRegistration.status)">
                {{ selectedRegistration.status }}
              </span>
            </dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4 sm:col-span-2">
            <dt class="text-xs font-black uppercase text-slate-500">Ghi chú</dt>
            <dd class="mt-1 leading-7 text-slate-700">{{ selectedRegistration.note }}</dd>
          </div>
        </dl>
      </template>
    </BaseModal>

    <ConfirmModal
      :show="Boolean(pendingDeleteId)"
      @cancel="pendingDeleteId = null"
      @confirm="confirmDeleteRegistration"
    />
  </section>
</template>
