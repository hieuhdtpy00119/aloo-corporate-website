<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
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
const isLoading = computed(() => store.loading.registrations)
const errorMessage = computed(() => store.errors.registrations)
const currentPage = ref(1)
const pageSize = 5
const openStatusMenuId = ref(null)
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

const notifyStatusChange = () => {
  toast.success('Đã cập nhật trạng thái đăng ký')
}

const toggleStatusMenu = (registrationId) => {
  openStatusMenuId.value = openStatusMenuId.value === registrationId ? null : registrationId
}

const updateRegistrationStatus = async (registration, status) => {
  openStatusMenuId.value = null
  try {
    await store.updateRegistrationStatus(registration, status)
    notifyStatusChange()
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không cập nhật được trạng thái')
  }
}

const closeStatusMenu = () => {
  openStatusMenuId.value = null
}

const closeDetailModal = () => {
  selectedRegistration.value = null
}

const deleteRegistration = (registrationId) => {
  pendingDeleteId.value = registrationId
}

const confirmDeleteRegistration = async () => {
  try {
    await store.deleteRegistration(pendingDeleteId.value)
    toast.success('Đã xóa đăng ký tư vấn thành công')
    if (selectedRegistration.value?.id === pendingDeleteId.value) {
      closeDetailModal()
    }
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không xóa được đăng ký tư vấn')
  } finally {
    pendingDeleteId.value = null
  }
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

onMounted(() => {
  document.addEventListener('click', closeStatusMenu)
  store.fetchRegistrations().catch(() => {
    toast.error('Không tải được danh sách đăng ký tư vấn')
  })
})

onBeforeUnmount(() => {
  document.removeEventListener('click', closeStatusMenu)
})
</script>

<template>
  <section>
    <div class="mb-6">
      <h2 class="text-3xl font-black text-avocado-950">Đăng ký tư vấn</h2>
      <p class="mt-2 text-slate-600">Danh sách khách hàng tiềm năng và trạng thái xử lý tư vấn nhượng quyền.</p>
    </div>

    <SearchFilterBar v-model:search="searchQuery" v-model:status="statusFilter" search-placeholder="Tìm họ tên, điện thoại, email, khu vực" :status-options="statusFilters" />
    <p v-if="errorMessage" class="mb-4 rounded-lg bg-red-50 px-4 py-3 text-sm font-bold text-red-700">
      {{ errorMessage }}
    </p>

    <div class="rounded-lg border border-slate-200 bg-white shadow-sm">
      <EmptyState v-if="isLoading || filteredRegistrations.length === 0" :loading="isLoading" />
      <div v-if="!isLoading && filteredRegistrations.length > 0" class="hidden lg:block">
        <table class="w-full table-fixed divide-y divide-slate-200 whitespace-nowrap text-left">
          <colgroup>
            <col class="w-[15%]" />
            <col class="w-[12%]" />
            <col class="w-[16%]" />
            <col class="w-[11%]" />
            <col class="w-[12%]" />
            <col class="w-[18%]" />
            <col class="w-[16%]" />
          </colgroup>
          <thead class="bg-slate-50">
            <tr>
              <th class="px-3 py-3 text-xs font-black uppercase tracking-wide text-slate-500">Họ tên</th>
              <th class="px-3 py-3 text-xs font-black uppercase tracking-wide text-slate-500">Số điện thoại</th>
              <th class="px-3 py-3 text-xs font-black uppercase tracking-wide text-slate-500">Email</th>
              <th class="px-3 py-3 text-xs font-black uppercase tracking-wide text-slate-500">Khu vực</th>
              <th class="px-3 py-3 text-right text-xs font-black uppercase tracking-wide text-slate-500">Số vốn</th>
              <th class="px-3 py-3 text-center text-xs font-black uppercase tracking-wide text-slate-500">Trạng thái</th>
              <th class="px-3 py-3 text-xs font-black uppercase tracking-wide text-slate-500">Hành động</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr v-for="registration in paginatedRegistrations" :key="registration.id" class="align-middle hover:bg-avocado-50/60">
              <td class="px-3 py-2.5 text-sm font-bold text-avocado-950">
                <span class="block truncate">{{ registration.name }}</span>
              </td>
              <td class="whitespace-nowrap px-3 py-2.5 text-sm text-slate-700">{{ registration.phone }}</td>
              <td class="truncate px-3 py-2.5 text-sm text-slate-700" :title="registration.email">{{ registration.email }}</td>
              <td class="whitespace-nowrap px-3 py-2.5 text-sm text-slate-700">{{ registration.area }}</td>
              <td class="whitespace-nowrap px-3 py-2.5 text-right text-sm font-bold tabular-nums text-slate-800">{{ formatCurrency(registration.capital) }}</td>
              <td class="px-3 py-2.5 text-center text-sm">
                <div class="relative inline-block text-left" @click.stop>
                  <button
                    type="button"
                    class="flex h-9 w-full min-w-[180px] max-w-[200px] items-center justify-between gap-2 rounded-lg border px-3 text-sm font-black transition"
                    :class="getStatusSelectClass(registration.status)"
                    @click="toggleStatusMenu(registration.id)"
                  >
                    <span>{{ registration.status }}</span>
                    <span class="text-xs">⌄</span>
                  </button>
                  <div
                    v-if="openStatusMenuId === registration.id"
                    class="absolute left-0 z-50 mt-2 w-[180px] overflow-hidden rounded-xl border border-slate-200 bg-white p-1.5 text-left shadow-2xl shadow-slate-900/12"
                  >
                    <button
                      v-for="status in registrationStatuses"
                      :key="status"
                      type="button"
                      class="flex w-full items-center justify-between rounded-lg px-3 py-2 text-sm font-bold transition hover:bg-slate-50"
                      :class="registration.status === status ? 'bg-avocado-50 text-avocado-800' : 'text-slate-700'"
                      @click="updateRegistrationStatus(registration, status)"
                    >
                      <span>{{ status }}</span>
                      <span v-if="registration.status === status" class="text-avocado-700">✓</span>
                    </button>
                  </div>
                </div>
              </td>
              <td class="px-3 py-2.5 align-middle text-sm">
                <div class="inline-flex min-w-[142px] items-center gap-2 whitespace-nowrap">
                  <button class="rounded-lg border border-blue-200 px-3 py-1.5 text-center font-bold leading-5 text-blue-700 hover:bg-blue-50" @click="showDetail(registration)">
                    Chi tiết
                  </button>
                  <button class="rounded-lg border border-red-200 px-3 py-1.5 text-center font-bold leading-5 text-red-600 hover:bg-red-50" @click="deleteRegistration(registration.id)">
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
            <div class="relative" @click.stop>
              <button
                type="button"
                class="flex h-10 min-w-[150px] items-center justify-between gap-3 rounded-xl border px-3 text-sm font-black transition"
                :class="getStatusSelectClass(registration.status)"
                @click="toggleStatusMenu(registration.id)"
              >
                <span>{{ registration.status }}</span>
                <span class="text-xs">⌄</span>
              </button>
              <div
                v-if="openStatusMenuId === registration.id"
                class="absolute right-0 z-50 mt-2 w-[190px] overflow-hidden rounded-2xl border border-slate-200 bg-white p-1.5 text-left shadow-2xl shadow-slate-900/12"
              >
                <button
                  v-for="status in registrationStatuses"
                  :key="status"
                  type="button"
                  class="flex w-full items-center justify-between rounded-xl px-3 py-2.5 text-sm font-bold transition hover:bg-slate-50"
                  :class="registration.status === status ? 'bg-avocado-50 text-avocado-800' : 'text-slate-700'"
                  @click="updateRegistrationStatus(registration, status)"
                >
                  <span>{{ status }}</span>
                  <span v-if="registration.status === status" class="text-avocado-700">✓</span>
                </button>
              </div>
            </div>
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
