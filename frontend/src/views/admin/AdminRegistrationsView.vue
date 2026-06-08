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
const selectedRegistration = ref(null)
const pendingDeleteId = ref(null)
const searchQuery = ref('')
const statusFilter = ref('Tất cả')
const isLoading = computed(() => store.loading.registrations)
const errorMessage = computed(() => store.errors.registrations)
const currentPage = ref(1)
const pageSize = 5
const registrationStatuses = ['Mới', 'Đã liên hệ', 'Đang tư vấn', 'Tiềm năng', 'Đã ký', 'Từ chối']
const statusFilters = ['Tất cả', ...registrationStatuses]
const leadForm = reactive({
  status: 'Mới',
  note: '',
  lastContactedAt: '',
  assignedTo: '',
})

const registrations = computed(() => store.registrations)

const formatCurrency = (value) => `${new Intl.NumberFormat('vi-VN').format(Number(value || 0))} đ`

const statusClass = (status) => ({
  'bg-blue-50 text-blue-700 ring-1 ring-blue-100': status === 'Mới',
  'bg-emerald-50 text-emerald-700 ring-1 ring-emerald-100': status === 'Đã liên hệ',
  'bg-amber-50 text-amber-700 ring-1 ring-amber-100': status === 'Đang tư vấn',
  'bg-orange-50 text-orange-700 ring-1 ring-orange-100': status === 'Tiềm năng',
  'bg-purple-50 text-purple-700 ring-1 ring-purple-100': status === 'Đã ký',
  'bg-slate-100 text-slate-600 ring-1 ring-slate-200': status === 'Từ chối',
})

const getStatusSelectClass = (status) => ({
  'bg-blue-50 text-blue-700 border-blue-200': status === 'Mới',
  'bg-emerald-50 text-emerald-700 border-emerald-200': status === 'Đã liên hệ',
  'bg-amber-50 text-amber-700 border-amber-200': status === 'Đang tư vấn',
  'bg-orange-50 text-orange-700 border-orange-200': status === 'Tiềm năng',
  'bg-purple-50 text-purple-700 border-purple-200': status === 'Đã ký',
  'bg-red-50 text-red-700 border-red-200': status === 'Từ chối',
})

const showDetail = (registration) => {
  selectedRegistration.value = registration
  Object.assign(leadForm, {
    status: registration.status || 'Mới',
    note: registration.note || '',
    lastContactedAt: registration.lastContactedAt ? String(registration.lastContactedAt).replace(' ', 'T').slice(0, 16) : '',
    assignedTo: registration.assignedTo || '',
  })
}

const notifyStatusChange = () => {
  toast.success('Đã cập nhật trạng thái đăng ký')
}

const updateRegistrationStatus = async (registration, status) => {
  try {
    const updated = await store.updateRegistrationStatus(registration, status, {
      note: leadForm.note,
      lastContactedAt: leadForm.lastContactedAt || null,
      assignedTo: leadForm.assignedTo,
    })
    selectedRegistration.value = updated
    showDetail(updated)
    notifyStatusChange()
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không cập nhật được trạng thái')
  }
}

const saveLeadCare = () => {
  if (!selectedRegistration.value) return
  updateRegistrationStatus(selectedRegistration.value, leadForm.status)
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
  store.fetchRegistrations().catch(() => {
    toast.error('Không tải được danh sách đăng ký tư vấn')
  })
})
</script>

<template>
  <section>
    <div class="mb-6">
      <h2 class="text-3xl font-black text-avocado-950">Đăng ký tư vấn</h2>
      <p class="mt-2 text-slate-600">Danh sách khách hàng tiềm năng và trạng thái xử lý tư vấn nhượng quyền.</p>
    </div>

    <SearchFilterBar
      v-model:search="searchQuery"
      v-model:status="statusFilter"
      search-label="Tìm lead"
      search-placeholder="Tìm họ tên, điện thoại, email, khu vực"
      status-label="Trạng thái tư vấn"
      :status-options="statusFilters"
    />
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
                <span class="inline-flex min-w-[112px] justify-center rounded-full px-3 py-1.5 text-xs font-black" :class="statusClass(registration.status)">
                  {{ registration.status }}
                </span>
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
            <span class="shrink-0 rounded-full px-3 py-1.5 text-xs font-black" :class="statusClass(registration.status)">
              {{ registration.status }}
            </span>
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
              <select v-model="leadForm.status" class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-bold outline-none focus:border-avocado-500">
                <option v-for="status in registrationStatuses" :key="status" :value="status">{{ status }}</option>
              </select>
            </dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4 sm:col-span-2">
            <dt class="text-xs font-black uppercase text-slate-500">Chăm sóc lead</dt>
            <dd class="mt-3 grid gap-3">
              <div class="grid gap-3 sm:grid-cols-2">
                <label class="grid gap-1">
                  <span class="text-xs font-bold text-slate-500">Lần liên hệ cuối</span>
                  <input v-model="leadForm.lastContactedAt" type="datetime-local" class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold outline-none focus:border-avocado-500" />
                </label>
                <label class="grid gap-1">
                  <span class="text-xs font-bold text-slate-500">Người phụ trách</span>
                  <input v-model="leadForm.assignedTo" class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold outline-none focus:border-avocado-500" placeholder="Tên admin hoặc sale" />
                </label>
              </div>
              <textarea v-model="leadForm.note" rows="4" class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold outline-none focus:border-avocado-500" placeholder="Ghi chú chăm sóc lead"></textarea>
              <button type="button" class="w-fit rounded-xl bg-avocado-800 px-5 py-3 text-sm font-black text-white hover:bg-avocado-950" @click="saveLeadCare">
                Lưu chăm sóc lead
              </button>
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
