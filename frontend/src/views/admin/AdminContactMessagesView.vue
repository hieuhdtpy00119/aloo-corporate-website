<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { Eye, Trash2 } from 'lucide-vue-next'
import AdminListPage from '../../components/admin/AdminListPage.vue'
import AdminNestedShell from '../../components/admin/shell/AdminNestedShell.vue'
import AdminShellFrame from '../../components/admin/shell/AdminShellFrame.vue'
import AdminShellTablePanel from '../../components/admin/shell/AdminShellTablePanel.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import { useAdminModuleI18n } from '../../composables/useAdminModuleI18n'
import { contactMessageService } from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'

const CONTACT_STATUSES = ['NEW', 'READ', 'REPLIED', 'ARCHIVED']

const { m, t } = useAdminModuleI18n('contactMessages')
const toast = useToastStore()
const messages = ref([])
const isLoading = ref(false)
const errorMessage = ref('')
const searchQuery = ref('')
const statusFilter = ref('ALL')
const selected = ref(null)
const pendingDeleteId = ref(null)
const isUpdatingStatus = ref(false)
const currentPage = ref(1)
const pageSize = 8

const statusLabel = (status) => {
  const code = String(status || 'NEW').toUpperCase()
  return m(`status.${code}`) || code
}

const statusClass = (status) => {
  const code = String(status || 'NEW').toUpperCase()
  if (code === 'NEW') return 'border-amber-200 bg-amber-50 text-amber-800'
  if (code === 'READ') return 'border-sky-200 bg-sky-50 text-sky-800'
  if (code === 'REPLIED') return 'border-emerald-200 bg-emerald-50 text-emerald-800'
  return 'border-slate-200 bg-slate-50 text-slate-600'
}

const filteredMessages = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return messages.value.filter((item) => {
    const matchesKeyword =
      !keyword ||
      [item.fullName, item.email, item.phone, item.subject, item.message]
        .filter(Boolean)
        .join(' ')
        .toLowerCase()
        .includes(keyword)
    const matchesStatus =
      statusFilter.value === 'ALL' || String(item.status || '').toUpperCase() === statusFilter.value
    return matchesKeyword && matchesStatus
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredMessages.value.length / pageSize)))
const paginatedMessages = computed(() =>
  filteredMessages.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)
const listCountText = computed(() => t('admin.shared.totalCount', { count: filteredMessages.value.length }))

const formatDate = (value) => {
  if (!value) return '—'
  const date = new Date(String(value).replace(' ', 'T'))
  if (Number.isNaN(date.getTime())) return value
  return new Intl.DateTimeFormat(undefined, {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date)
}

const loadMessages = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const { data } = await contactMessageService.list()
    messages.value = Array.isArray(data) ? data : []
  } catch (error) {
    errorMessage.value = error.response?.data?.message || m('toasts.loadError')
  } finally {
    isLoading.value = false
  }
}

const openDetail = async (item) => {
  selected.value = item
  if (String(item.status || '').toUpperCase() === 'NEW') {
    await updateStatus(item, 'READ', false)
  }
}

const closeDetail = () => {
  selected.value = null
}

const updateStatus = async (item, status, notify = true) => {
  if (isUpdatingStatus.value) return
  isUpdatingStatus.value = true
  try {
    const { data } = await contactMessageService.updateStatus(item.id, status)
    const index = messages.value.findIndex((entry) => entry.id === data.id)
    if (index !== -1) messages.value.splice(index, 1, data)
    if (selected.value?.id === data.id) selected.value = data
    if (notify) toast.success(m('toasts.statusUpdated'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.statusError'))
  } finally {
    isUpdatingStatus.value = false
  }
}

const confirmDelete = async () => {
  try {
    await contactMessageService.remove(pendingDeleteId.value)
    messages.value = messages.value.filter((item) => item.id !== pendingDeleteId.value)
    if (selected.value?.id === pendingDeleteId.value) selected.value = null
    toast.success(m('toasts.deleted'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.deleteError'))
  } finally {
    pendingDeleteId.value = null
  }
}

watch([searchQuery, statusFilter], () => {
  currentPage.value = 1
})

watch(totalPages, (value) => {
  currentPage.value = Math.min(currentPage.value, value)
})

onMounted(loadMessages)
</script>

<template>
  <AdminListPage>
    <AdminNestedShell>
      <AdminShellFrame variant="header" inner="header">
        <AdminPageHeader :title="m('title')" />
      </AdminShellFrame>

      <AdminShellFrame variant="toolbar" inner="toolbar" padded>
        <section class="aloo-admin-toolbar md:!grid-cols-[1fr_180px]">
          <input v-model="searchQuery" class="aloo-input" :placeholder="m('searchPlaceholder')" />
          <select v-model="statusFilter" class="aloo-select">
            <option value="ALL">{{ m('filters.all') }}</option>
            <option v-for="code in CONTACT_STATUSES" :key="code" :value="code">{{ statusLabel(code) }}</option>
          </select>
        </section>
      </AdminShellFrame>

      <AdminShellFrame v-if="errorMessage" as="p" variant="alert" class="admin-list-alert">
        {{ errorMessage }}
      </AdminShellFrame>

      <AdminShellFrame v-if="isLoading" variant="body" inner="pad">
        <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
      </AdminShellFrame>

      <AdminShellFrame v-else-if="!filteredMessages.length" variant="body" inner="pad">
        <EmptyState :title="m('empty')" />
      </AdminShellFrame>

      <AdminShellFrame v-else variant="body" visibility="desktop">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <table class="admin-shell-table">
            <thead>
              <tr>
                <th>{{ m('columns.name') }}</th>
                <th>{{ m('columns.contact') }}</th>
                <th>{{ m('columns.subject') }}</th>
                <th>{{ m('columns.status') }}</th>
                <th>{{ m('columns.createdAt') }}</th>
                <th>{{ m('columns.actions') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in paginatedMessages" :key="item.id">
                <td class="font-black text-avocado-950">{{ item.fullName }}</td>
                <td class="admin-shell-cell-muted">
                  <p>{{ item.phone }}</p>
                  <p class="text-xs">{{ item.email || '—' }}</p>
                </td>
                <td class="admin-shell-cell-truncate">{{ item.subject || m('noSubject') }}</td>
                <td>
                  <span class="rounded-full border px-3 py-1 text-xs font-black" :class="statusClass(item.status)">
                    {{ statusLabel(item.status) }}
                  </span>
                </td>
                <td class="admin-shell-cell-muted">{{ formatDate(item.createdAt) }}</td>
                <td>
                  <div class="flex gap-2">
                    <button class="rounded-lg border border-avocado-200 p-2 text-avocado-700 hover:bg-avocado-50" :title="m('actions.detail')" @click="openDetail(item)">
                      <Eye class="h-4 w-4" />
                    </button>
                    <button class="rounded-lg border border-red-200 p-2 text-red-600 hover:bg-red-50" :title="m('actions.delete')" @click="pendingDeleteId = item.id">
                      <Trash2 class="h-4 w-4" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="!isLoading && filteredMessages.length" variant="body" visibility="mobile">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <template #below>
            <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack">
              <article v-for="item in paginatedMessages" :key="item.id" class="admin-shell-mobile-card">
                <div class="flex items-start justify-between gap-3">
                  <div class="min-w-0">
                    <h2 class="truncate font-black text-avocado-950">{{ item.fullName }}</h2>
                    <p class="text-xs font-bold text-slate-500">{{ item.phone }}</p>
                  </div>
                  <span class="rounded-full border px-3 py-1 text-xs font-black" :class="statusClass(item.status)">{{ statusLabel(item.status) }}</span>
                </div>
                <p class="mt-3 line-clamp-2 text-sm text-slate-600">{{ item.subject || item.message }}</p>
                <div class="mt-4 flex gap-2">
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 text-xs font-bold text-avocado-700" @click="openDetail(item)">{{ m('actions.detail') }}</button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 text-xs font-bold text-red-600" @click="pendingDeleteId = item.id">{{ m('actions.delete') }}</button>
                </div>
              </article>
            </div>
          </template>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="filteredMessages.length" variant="footer">
        <Pagination
          :page="currentPage"
          :total-pages="totalPages"
          :visible-count="paginatedMessages.length"
          :total-count="filteredMessages.length"
          :label="m('paginationLabel')"
          @prev="currentPage--"
          @next="currentPage++"
        />
      </AdminShellFrame>
    </AdminNestedShell>

    <BaseModal :show="Boolean(selected)" :title="m('detailTitle')" max-width="max-w-2xl" @close="closeDetail">
      <div v-if="selected" class="grid gap-4">
        <div class="grid gap-1">
          <p class="text-xs font-black uppercase text-slate-500">{{ m('fields.name') }}</p>
          <p class="font-black text-avocado-950">{{ selected.fullName }}</p>
        </div>
        <div class="grid gap-4 md:grid-cols-2">
          <div class="grid gap-1">
            <p class="text-xs font-black uppercase text-slate-500">{{ m('fields.phone') }}</p>
            <p class="font-semibold text-slate-800">{{ selected.phone }}</p>
          </div>
          <div class="grid gap-1">
            <p class="text-xs font-black uppercase text-slate-500">{{ m('fields.email') }}</p>
            <p class="font-semibold text-slate-800">{{ selected.email || '—' }}</p>
          </div>
        </div>
        <div class="grid gap-1">
          <p class="text-xs font-black uppercase text-slate-500">{{ m('fields.subject') }}</p>
          <p class="font-semibold text-slate-800">{{ selected.subject || m('noSubject') }}</p>
        </div>
        <div class="grid gap-1">
          <p class="text-xs font-black uppercase text-slate-500">{{ m('fields.message') }}</p>
          <p class="whitespace-pre-wrap rounded-xl border border-slate-100 bg-slate-50 px-4 py-3 text-sm leading-6 text-slate-700">{{ selected.message }}</p>
        </div>
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">{{ m('fields.status') }}</span>
          <select
            class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"
            :value="String(selected.status || 'NEW').toUpperCase()"
            :disabled="isUpdatingStatus"
            @change="updateStatus(selected, $event.target.value)"
          >
            <option v-for="code in CONTACT_STATUSES" :key="code" :value="code">{{ statusLabel(code) }}</option>
          </select>
        </label>
        <p class="text-xs font-bold text-slate-500">{{ m('fields.createdAt') }}: {{ formatDate(selected.createdAt) }}</p>
      </div>
    </BaseModal>

    <ConfirmModal
      :show="pendingDeleteId != null"
      :title="t('admin.shared.confirmDeleteTitle')"
      :message="t('admin.shared.confirmDeleteMessage')"
      :confirm-label="t('admin.shared.confirmDelete')"
      @cancel="pendingDeleteId = null"
      @confirm="confirmDelete"
    />
  </AdminListPage>
</template>
