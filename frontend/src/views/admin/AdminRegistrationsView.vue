<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import AdminListPage from '../../components/admin/AdminListPage.vue'
import AdminNestedShell from '../../components/admin/shell/AdminNestedShell.vue'
import AdminShellFrame from '../../components/admin/shell/AdminShellFrame.vue'
import AdminShellTablePanel from '../../components/admin/shell/AdminShellTablePanel.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import { useAdminModuleI18n } from '../../composables/useAdminModuleI18n'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'
import {
  LEAD_STATUS_CODES,
  getLeadStatusBadgeClass,
  leadStatusLabel,
  normalizeLeadStatusCode,
} from '../../utils/leadStatus'

const { m, t } = useAdminModuleI18n('leads')
const store = useAppStore()
const toast = useToastStore()
const route = useRoute()
const router = useRouter()
const selectedRegistration = ref(null)
const pendingDeleteId = ref(null)
const searchQuery = ref('')
const statusFilter = ref(t('admin.shared.all'))
const isLoading = computed(() => store.loading.registrations)
const errorMessage = computed(() => store.errors.registrations)
const currentPage = ref(1)
const pageSize = 5
const registrationStatuses = LEAD_STATUS_CODES
const statusFilters = computed(() => [
  t('admin.shared.all'),
  ...registrationStatuses.map((code) => leadStatusLabel(code, t)),
])
const leadForm = reactive({
  status: 'NEW',
  note: '',
  lastContactedAt: '',
  assignedTo: '',
})

const registrations = computed(() => store.registrations)

const formatCurrency = (value) => `${new Intl.NumberFormat('vi-VN').format(Number(value || 0))} đ`

const statusClass = getLeadStatusBadgeClass

const getStatusFilterCode = (label) => {
  if (label === t('admin.shared.all')) return 'ALL'
  const match = registrationStatuses.find((code) => leadStatusLabel(code, t) === label)
  return match || label
}

const showDetail = (registration) => {
  selectedRegistration.value = registration
  Object.assign(leadForm, {
    status: normalizeLeadStatusCode(registration.status),
    note: registration.note || '',
    lastContactedAt: registration.lastContactedAt ? String(registration.lastContactedAt).replace(' ', 'T').slice(0, 16) : '',
    assignedTo: registration.assignedTo || '',
  })
  if (String(route.query.lead || '') !== String(registration.id)) {
    router.replace({ query: { ...route.query, lead: registration.id } })
  }
}

const notifyStatusChange = () => {
  toast.success(m('toasts.statusUpdated'))
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
    toast.error(error.response?.data?.message || m('toasts.statusError'))
  }
}

const saveLeadCare = () => {
  if (!selectedRegistration.value) return
  updateRegistrationStatus(selectedRegistration.value, leadForm.status)
}

const closeDetailModal = () => {
  selectedRegistration.value = null
  if (route.query.lead) {
    const nextQuery = { ...route.query }
    delete nextQuery.lead
    router.replace({ query: nextQuery })
  }
}

const openLeadFromQuery = () => {
  const leadId = route.query.lead
  if (!leadId) return
  const registration = store.registrations.find((item) => String(item.id) === String(leadId))
  if (registration) showDetail(registration)
}

const deleteRegistration = (registrationId) => {
  pendingDeleteId.value = registrationId
}

const confirmDeleteRegistration = async () => {
  try {
    await store.deleteRegistration(pendingDeleteId.value)
    toast.success(m('toasts.deleted'))
    if (selectedRegistration.value?.id === pendingDeleteId.value) {
      closeDetailModal()
    }
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.deleteError'))
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
    const matchesStatus =
      statusFilter.value === t('admin.shared.all') ||
      normalizeLeadStatusCode(registration.status) === getStatusFilterCode(statusFilter.value)
    return matchesSearch && matchesStatus
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredRegistrations.value.length / pageSize)))
const paginatedRegistrations = computed(() =>
  filteredRegistrations.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)
const listCountText = computed(() => t('admin.shared.totalCount', { count: filteredRegistrations.value.length }))

watch([searchQuery, statusFilter], () => {
  currentPage.value = 1
})

watch(
  () => route.query.lead,
  () => {
    if (!route.query.lead) {
      selectedRegistration.value = null
      return
    }
    openLeadFromQuery()
  },
)

onMounted(async () => {
  try {
    if (!store.registrations.length) {
      await store.fetchRegistrations()
    }
    openLeadFromQuery()
  } catch {
    toast.error(m('toasts.loadError'))
  }
})
</script>

<template>
  <AdminListPage>
    <AdminNestedShell>
      <AdminShellFrame variant="header" inner="header">
        <AdminPageHeader :title="m('title')" />
      </AdminShellFrame>

      <AdminShellFrame variant="toolbar" inner="toolbar">
        <SearchFilterBar
          v-model:search="searchQuery"
          v-model:status="statusFilter"
          :search-label="m('searchLabel')"
          :search-placeholder="m('searchPlaceholder')"
          :status-label="m('statusLabel')"
          :status-options="statusFilters"
        />
      </AdminShellFrame>

      <AdminShellFrame v-if="errorMessage" as="p" variant="alert" class="admin-list-alert">
        {{ errorMessage }}
      </AdminShellFrame>

      <AdminShellFrame v-if="isLoading" variant="body" inner="pad">
        <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
      </AdminShellFrame>

      <AdminShellFrame v-else-if="!filteredRegistrations.length" variant="body" inner="pad">
        <EmptyState :title="m('empty')" />
      </AdminShellFrame>

      <AdminShellFrame v-else variant="body" visibility="desktop">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <table class="admin-shell-table">
            <colgroup>
              <col style="width: 15%" />
              <col style="width: 12%" />
              <col style="width: 16%" />
              <col style="width: 11%" />
              <col style="width: 12%" />
              <col style="width: 18%" />
              <col style="width: 16%" />
            </colgroup>
            <thead>
              <tr>
                <th>{{ m('columns.name') }}</th>
                <th>{{ m('columns.phone') }}</th>
                <th>{{ m('columns.email') }}</th>
                <th>{{ m('columns.area') }}</th>
                <th class="text-right">{{ m('columns.capital') }}</th>
                <th class="text-center">{{ m('columns.status') }}</th>
                <th>{{ m('columns.actions') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="registration in paginatedRegistrations" :key="registration.id">
                <td class="font-bold text-avocado-950"><span class="block truncate">{{ registration.name }}</span></td>
                <td class="admin-shell-cell-nowrap admin-shell-cell-muted">{{ registration.phone }}</td>
                <td class="admin-shell-cell-truncate admin-shell-cell-muted" :title="registration.email">{{ registration.email }}</td>
                <td class="admin-shell-cell-nowrap admin-shell-cell-muted">{{ registration.area }}</td>
                <td class="text-right font-bold tabular-nums text-slate-800">{{ formatCurrency(registration.capital) }}</td>
                <td class="text-center">
                  <span class="inline-flex min-w-[112px] justify-center rounded-full px-3 py-1.5 text-xs font-black" :class="statusClass(registration.status)">
                    {{ leadStatusLabel(registration.status, t) }}
                  </span>
                </td>
                <td>
                  <div class="inline-flex min-w-[142px] items-center gap-2 whitespace-nowrap">
                    <button class="rounded-lg border border-blue-200 px-3 py-1.5 text-center font-bold leading-5 text-blue-700 hover:bg-blue-50" @click="showDetail(registration)">
                      {{ m('actions.detail') }}
                    </button>
                    <button class="rounded-lg border border-red-200 px-3 py-1.5 text-center font-bold leading-5 text-red-600 hover:bg-red-50" @click="deleteRegistration(registration.id)">
                      {{ m('actions.delete') }}
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="!isLoading && filteredRegistrations.length" variant="body" visibility="mobile">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <template #below>
            <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack">
              <article v-for="registration in paginatedRegistrations" :key="registration.id" class="admin-shell-mobile-card">
                <div class="flex items-start justify-between gap-3">
                  <div class="min-w-0">
                    <h3 class="truncate font-black text-avocado-950">{{ registration.name }}</h3>
                    <p class="mt-1 text-sm text-slate-600">{{ registration.phone }}</p>
                  </div>
                  <span class="shrink-0 rounded-full px-3 py-1.5 text-xs font-black" :class="statusClass(registration.status)">
                    {{ leadStatusLabel(registration.status, t) }}
                  </span>
                </div>
                <div class="mt-4 grid gap-2 text-sm text-slate-700">
                  <p><span class="font-bold text-slate-900">{{ m('columns.email') }}:</span> {{ registration.email }}</p>
                  <p><span class="font-bold text-slate-900">{{ m('columns.area') }}:</span> {{ registration.area }}</p>
                  <p><span class="font-bold text-slate-900">{{ m('columns.capital') }}:</span> {{ formatCurrency(registration.capital) }}</p>
                </div>
                <div class="mt-4 grid gap-2 sm:grid-cols-3">
                  <button class="rounded-lg border border-blue-200 px-3 py-2 text-sm font-bold text-blue-700 hover:bg-blue-50" @click="showDetail(registration)">
                    {{ m('actions.viewDetail') }}
                  </button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 text-sm font-bold text-red-600 hover:bg-red-50" @click="deleteRegistration(registration.id)">
                    {{ m('actions.delete') }}
                  </button>
                </div>
              </article>
            </div>
          </template>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="filteredRegistrations.length" variant="footer">
        <Pagination
          :page="currentPage"
          :total-pages="totalPages"
          :visible-count="paginatedRegistrations.length"
          :total-count="filteredRegistrations.length"
          :label="m('paginationLabel')"
          @prev="currentPage = Math.max(1, currentPage - 1)"
          @next="currentPage = Math.min(totalPages, currentPage + 1)"
        />
      </AdminShellFrame>
    </AdminNestedShell>

    <BaseModal :show="Boolean(selectedRegistration)" :title="m('detailTitle')" @close="closeDetailModal">
      <template v-if="selectedRegistration">
        <p class="mb-5 text-sm text-slate-500">{{ m('registrationId', { id: selectedRegistration.id }) }}</p>
        <dl class="grid gap-4 sm:grid-cols-2">
          <div class="rounded-lg bg-slate-50 p-4">
            <dt class="text-xs font-black uppercase text-slate-500">{{ m('fields.name') }}</dt>
            <dd class="mt-1 font-bold text-avocado-950">{{ selectedRegistration.name }}</dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4">
            <dt class="text-xs font-black uppercase text-slate-500">{{ m('fields.phone') }}</dt>
            <dd class="mt-1 font-bold text-avocado-950">{{ selectedRegistration.phone }}</dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4">
            <dt class="text-xs font-black uppercase text-slate-500">{{ m('fields.email') }}</dt>
            <dd class="mt-1 break-words font-bold text-avocado-950">{{ selectedRegistration.email }}</dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4">
            <dt class="text-xs font-black uppercase text-slate-500">{{ m('fields.areaOpen') }}</dt>
            <dd class="mt-1 font-bold text-avocado-950">{{ selectedRegistration.area }}</dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4">
            <dt class="text-xs font-black uppercase text-slate-500">{{ m('fields.capital') }}</dt>
            <dd class="mt-1 font-bold text-avocado-950">{{ formatCurrency(selectedRegistration.capital) }}</dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4">
            <dt class="text-xs font-black uppercase text-slate-500">{{ m('fields.registeredAt') }}</dt>
            <dd class="mt-1 font-bold text-avocado-950">{{ selectedRegistration.createdAt }}</dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4 sm:col-span-2">
            <dt class="text-xs font-black uppercase text-slate-500">{{ m('fields.status') }}</dt>
            <dd class="mt-2">
              <select v-model="leadForm.status" class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-bold outline-none focus:border-avocado-500">
                <option v-for="status in registrationStatuses" :key="status" :value="status">{{ leadStatusLabel(status, t) }}</option>
              </select>
            </dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4 sm:col-span-2">
            <dt class="text-xs font-black uppercase text-slate-500">{{ m('fields.leadCare') }}</dt>
            <dd class="mt-3 grid gap-3">
              <div class="grid gap-3 sm:grid-cols-2">
                <label class="grid gap-1">
                  <span class="text-xs font-bold text-slate-500">{{ m('fields.lastContact') }}</span>
                  <input v-model="leadForm.lastContactedAt" type="datetime-local" class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold outline-none focus:border-avocado-500" />
                </label>
                <label class="grid gap-1">
                  <span class="text-xs font-bold text-slate-500">{{ m('fields.assignedTo') }}</span>
                  <input v-model="leadForm.assignedTo" class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold outline-none focus:border-avocado-500" :placeholder="m('assignedPlaceholder')" />
                </label>
              </div>
              <textarea v-model="leadForm.note" rows="4" class="rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-semibold outline-none focus:border-avocado-500" :placeholder="m('notePlaceholder')"></textarea>
              <button type="button" class="w-fit rounded-xl bg-avocado-800 px-5 py-3 text-sm font-black text-white hover:bg-avocado-950" @click="saveLeadCare">
                {{ m('actions.saveLeadCare') }}
              </button>
            </dd>
          </div>
          <div class="rounded-lg bg-slate-50 p-4 sm:col-span-2">
            <dt class="text-xs font-black uppercase text-slate-500">{{ m('fields.note') }}</dt>
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
  </AdminListPage>
</template>
