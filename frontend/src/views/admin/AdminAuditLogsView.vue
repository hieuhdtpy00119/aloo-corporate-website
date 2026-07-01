<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import AdminListPage from '../../components/admin/AdminListPage.vue'
import AdminNestedShell from '../../components/admin/shell/AdminNestedShell.vue'
import AdminShellFrame from '../../components/admin/shell/AdminShellFrame.vue'
import AdminShellTablePanel from '../../components/admin/shell/AdminShellTablePanel.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import { Clock, FileText, Target, User } from 'lucide-vue-next'
import { auditLogService } from '../../services/cmsService'
import { formatAuditAction, formatAuditDetails, formatAuditEntity } from '../../utils/auditLogLabels'

const { t } = useI18n()

const logs = ref([])
const isLoading = ref(false)
const errorMessage = ref('')
const currentPage = ref(1)
const pageSize = 20
const totalElements = ref(0)
const totalPages = ref(1)
const selectedLog = ref(null)

const showDetailModal = computed(() => Boolean(selectedLog.value))

const detailModalTitle = computed(() => (
  selectedLog.value ? actionLabel(selectedLog.value) : t('admin.auditLogs.detailModal.title')
))

const filters = reactive({
  actor: '',
  action: '',
  entityType: '',
  from: '',
  to: '',
})

const formatDate = (value) => (value ? String(value).replace('T', ' ').slice(0, 19) : '-')

const actionLabel = (log) => formatAuditAction(log.action, t)
const entityLabel = (log) => formatAuditEntity(log, t)
const detailsLabel = (log) => formatAuditDetails(log, t)

const openDetail = (log) => {
  selectedLog.value = log
}

const closeDetail = () => {
  selectedLog.value = null
}

const listCountText = computed(() => t('admin.shared.totalCount', { count: totalElements.value }))

const queryParams = computed(() => {
  const params = {
    page: currentPage.value - 1,
    size: pageSize,
  }
  if (filters.actor.trim()) params.actor = filters.actor.trim()
  if (filters.action.trim()) params.action = filters.action.trim()
  if (filters.entityType.trim()) params.entityType = filters.entityType.trim()
  if (filters.from) params.from = `${filters.from}T00:00:00`
  if (filters.to) params.to = `${filters.to}T23:59:59`
  return params
})

const loadLogs = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const { data } = await auditLogService.list(queryParams.value)
    logs.value = Array.isArray(data?.items) ? data.items : Array.isArray(data) ? data : []
    totalElements.value = Number(data?.totalElements ?? logs.value.length)
    totalPages.value = Math.max(1, Number(data?.totalPages ?? 1))
  } catch (error) {
    errorMessage.value = error.response?.data?.message || t('admin.auditLogs.loadError')
  } finally {
    isLoading.value = false
  }
}

const applyFilters = () => {
  currentPage.value = 1
  loadLogs()
}

const resetFilters = () => {
  filters.actor = ''
  filters.action = ''
  filters.entityType = ''
  filters.from = ''
  filters.to = ''
  applyFilters()
}

const goPrevPage = () => {
  currentPage.value = Math.max(1, currentPage.value - 1)
  loadLogs()
}

const goNextPage = () => {
  currentPage.value = Math.min(totalPages.value, currentPage.value + 1)
  loadLogs()
}

const exportCsv = () => {
  if (!logs.value.length) return
  const header = [
    t('admin.auditLogs.columns.time'),
    t('admin.auditLogs.columns.actor'),
    t('admin.auditLogs.columns.action'),
    t('admin.auditLogs.columns.entity'),
    t('admin.auditLogs.columns.details'),
  ]
  const rows = logs.value.map((log) => [
    formatDate(log.createdAt),
    log.actorEmail || '',
    actionLabel(log),
    entityLabel(log),
    detailsLabel(log),
  ])
  const csv = [header, ...rows]
    .map((row) => row.map((cell) => `"${String(cell).replace(/"/g, '""')}"`).join(','))
    .join('\n')
  const blob = new Blob([`\uFEFF${csv}`], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `audit-log-${new Date().toISOString().slice(0, 10)}.csv`
  link.click()
  URL.revokeObjectURL(url)
}

onMounted(loadLogs)
</script>

<template>
  <AdminListPage>
    <AdminNestedShell>
      <AdminShellFrame variant="header" inner="header">
        <AdminPageHeader :title="t('admin.auditLogs.title')">
          <template #actions>
            <button
              type="button"
              class="admin-list-btn admin-list-btn--outline disabled:cursor-not-allowed disabled:opacity-50"
              :disabled="!logs.length"
              @click="exportCsv"
            >
              {{ t('admin.auditLogs.exportCsv') }}
            </button>
          </template>
        </AdminPageHeader>
      </AdminShellFrame>

      <AdminShellFrame variant="toolbar" inner="toolbar" padded>
        <section class="aloo-admin-toolbar admin-shell-toolbar admin-shell-toolbar--audit">
          <label class="aloo-field">
            <span class="aloo-label">{{ t('admin.auditLogs.filters.actor') }}</span>
            <input
              v-model="filters.actor"
              class="aloo-input"
              :placeholder="t('admin.auditLogs.filters.actorPlaceholder')"
              @keyup.enter="applyFilters"
            />
          </label>
          <label class="aloo-field">
            <span class="aloo-label">{{ t('admin.auditLogs.filters.action') }}</span>
            <input
              v-model="filters.action"
              class="aloo-input"
              :placeholder="t('admin.auditLogs.filters.actionPlaceholder')"
              @keyup.enter="applyFilters"
            />
          </label>
          <label class="aloo-field">
            <span class="aloo-label">{{ t('admin.auditLogs.filters.entityType') }}</span>
            <input
              v-model="filters.entityType"
              class="aloo-input"
              :placeholder="t('admin.auditLogs.filters.entityPlaceholder')"
              @keyup.enter="applyFilters"
            />
          </label>
          <label class="aloo-field">
            <span class="aloo-label">{{ t('admin.auditLogs.filters.from') }}</span>
            <input v-model="filters.from" type="date" class="aloo-input" />
          </label>
          <label class="aloo-field">
            <span class="aloo-label">{{ t('admin.auditLogs.filters.to') }}</span>
            <input v-model="filters.to" type="date" class="aloo-input" />
          </label>
          <div class="admin-shell-toolbar__actions">
            <button type="button" class="admin-list-btn admin-list-btn--primary" @click="applyFilters">
              {{ t('admin.auditLogs.filters.apply') }}
            </button>
            <button type="button" class="admin-list-btn admin-list-btn--outline" @click="resetFilters">
              {{ t('admin.auditLogs.filters.reset') }}
            </button>
          </div>
        </section>
      </AdminShellFrame>

      <AdminShellFrame
        v-if="errorMessage"
        as="p"
        variant="alert"
        class="admin-list-alert"
      >
        {{ errorMessage }}
      </AdminShellFrame>

      <AdminShellFrame v-if="isLoading" variant="body" inner="pad">
        <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
      </AdminShellFrame>

      <AdminShellFrame v-else-if="!logs.length" variant="body" inner="pad">
        <EmptyState
          :title="t('admin.auditLogs.emptyTitle')"
          :description="t('admin.auditLogs.emptyDescription')"
        />
      </AdminShellFrame>

      <AdminShellFrame v-else variant="body" visibility="desktop">
        <AdminShellTablePanel
          :title="t('admin.auditLogs.listTitle')"
          :count-text="listCountText"
        >
          <table class="admin-shell-table">
            <colgroup>
              <col style="width: 16%" />
              <col style="width: 18%" />
              <col style="width: 16%" />
              <col style="width: 16%" />
              <col style="width: 34%" />
            </colgroup>
            <thead>
              <tr>
                <th>{{ t('admin.auditLogs.columns.time') }}</th>
                <th>{{ t('admin.auditLogs.columns.actor') }}</th>
                <th>{{ t('admin.auditLogs.columns.action') }}</th>
                <th>{{ t('admin.auditLogs.columns.entity') }}</th>
                <th>{{ t('admin.auditLogs.columns.details') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="log in logs"
                :key="log.id"
                class="admin-audit-log-row"
                tabindex="0"
                @click="openDetail(log)"
                @keyup.enter="openDetail(log)"
              >
                <td class="admin-shell-cell-muted admin-shell-cell-nowrap">{{ formatDate(log.createdAt) }}</td>
                <td class="admin-shell-cell-strong admin-shell-cell-truncate">{{ log.actorEmail }}</td>
                <td class="admin-shell-cell-action admin-shell-cell-truncate" :title="log.action">{{ actionLabel(log) }}</td>
                <td class="admin-shell-cell-muted admin-shell-cell-truncate admin-shell-cell-strong">{{ entityLabel(log) }}</td>
                <td class="admin-shell-cell-muted admin-shell-cell-truncate" :title="detailsLabel(log)">{{ detailsLabel(log) }}</td>
              </tr>
            </tbody>
          </table>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="!isLoading && logs.length" variant="body" visibility="mobile">
        <AdminShellTablePanel
          :title="t('admin.auditLogs.listTitle')"
          :count-text="listCountText"
        >
          <template #below>
            <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack">
              <article
                v-for="log in logs"
                :key="log.id"
                class="admin-shell-mobile-card admin-audit-log-row"
                tabindex="0"
                @click="openDetail(log)"
                @keyup.enter="openDetail(log)"
              >
                <p class="admin-shell-mobile-card__time">{{ formatDate(log.createdAt) }}</p>
                <p class="admin-shell-mobile-card__action">{{ actionLabel(log) }}</p>
                <p class="admin-shell-mobile-card__actor">{{ log.actorEmail }}</p>
                <p class="admin-shell-mobile-card__entity">{{ entityLabel(log) }}</p>
                <p class="admin-shell-mobile-card__details">{{ detailsLabel(log) }}</p>
              </article>
            </div>
          </template>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="!isLoading && totalElements" variant="footer">
        <Pagination
          :page="currentPage"
          :total-pages="totalPages"
          :visible-count="logs.length"
          :total-count="totalElements"
          :label="t('admin.auditLogs.paginationLabel')"
          @prev="goPrevPage"
          @next="goNextPage"
        />
      </AdminShellFrame>
    </AdminNestedShell>

    <BaseModal
      :show="showDetailModal"
      :title="detailModalTitle"
      max-width="max-w-xl"
      @close="closeDetail"
    >
      <div v-if="selectedLog" class="space-y-5">
        <section class="overflow-hidden rounded-2xl border border-avocado-100 bg-gradient-to-br from-avocado-50 via-white to-cream-50 p-5 shadow-sm">
          <p class="text-[11px] font-bold uppercase tracking-[0.14em] text-avocado-700">
            {{ t('admin.auditLogs.detailModal.summaryEyebrow') }}
          </p>
          <p class="mt-2 text-xl font-bold tracking-tight text-avocado-950">
            {{ entityLabel(selectedLog) }}
          </p>
          <div class="mt-3 inline-flex items-center gap-2 rounded-full border border-avocado-100 bg-white/80 px-3 py-1.5 text-xs font-semibold text-slate-600">
            <Clock class="h-3.5 w-3.5 text-avocado-600" />
            {{ formatDate(selectedLog.createdAt) }}
          </div>
        </section>

        <div class="grid gap-3 sm:grid-cols-2">
          <article class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
            <div class="mb-2 flex items-center gap-2 text-avocado-700">
              <User class="h-4 w-4" />
              <p class="text-[11px] font-bold uppercase tracking-[0.12em] text-slate-500">
                {{ t('admin.auditLogs.columns.actor') }}
              </p>
            </div>
            <p class="break-all text-sm font-semibold text-slate-800">{{ selectedLog.actorEmail }}</p>
          </article>

          <article class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
            <div class="mb-2 flex items-center gap-2 text-avocado-700">
              <Target class="h-4 w-4" />
              <p class="text-[11px] font-bold uppercase tracking-[0.12em] text-slate-500">
                {{ t('admin.auditLogs.columns.action') }}
              </p>
            </div>
            <p class="text-sm font-semibold text-slate-800">{{ actionLabel(selectedLog) }}</p>
          </article>
        </div>

        <section class="rounded-2xl border border-slate-200 bg-slate-50/70 p-5 shadow-sm">
          <div class="mb-3 flex items-center gap-2 text-avocado-700">
            <FileText class="h-4 w-4" />
            <h3 class="text-[11px] font-bold uppercase tracking-[0.12em] text-slate-500">
              {{ t('admin.auditLogs.columns.details') }}
            </h3>
          </div>
          <p class="text-sm leading-7 text-slate-700">
            {{ detailsLabel(selectedLog) }}
          </p>
        </section>
      </div>

      <template #footer>
        <div class="flex justify-end">
          <button type="button" class="admin-list-btn admin-list-btn--primary" @click="closeDetail">
            {{ t('admin.auditLogs.detailModal.close') }}
          </button>
        </div>
      </template>
    </BaseModal>
  </AdminListPage>
</template>
