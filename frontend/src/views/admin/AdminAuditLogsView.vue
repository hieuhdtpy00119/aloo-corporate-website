<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import { auditLogService } from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'

const { t } = useI18n()
const toast = useToastStore()

const logs = ref([])
const isLoading = ref(false)
const errorMessage = ref('')
const currentPage = ref(1)
const pageSize = 20
const totalElements = ref(0)
const totalPages = ref(1)

const filters = reactive({
  actor: '',
  action: '',
  entityType: '',
  from: '',
  to: '',
})

const formatDate = (value) => (value ? String(value).replace('T', ' ').slice(0, 19) : '-')

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
    log.action || '',
    `${log.entityType || ''}${log.entityId ? ` #${log.entityId}` : ''}`,
    (log.details || '').replace(/\r?\n/g, ' '),
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
  <div>
    <AdminPageHeader
      :eyebrow="t('admin.nav.groups.system')"
      :title="t('admin.auditLogs.title')"
      :description="t('admin.auditLogs.description')"
    >
      <template #actions>
        <button
          type="button"
          class="aloo-btn aloo-btn--secondary disabled:cursor-not-allowed disabled:opacity-50"
          :disabled="!logs.length"
          @click="exportCsv"
        >
          {{ t('admin.auditLogs.exportCsv') }}
        </button>
      </template>
    </AdminPageHeader>

    <section class="aloo-admin-toolbar md:!grid-cols-2 xl:!grid-cols-5">
      <label class="aloo-field">
        <span class="aloo-label">{{ t('admin.auditLogs.filters.actor') }}</span>
        <input v-model="filters.actor" class="aloo-input" :placeholder="t('admin.auditLogs.filters.actorPlaceholder')" />
      </label>
      <label class="aloo-field">
        <span class="aloo-label">{{ t('admin.auditLogs.filters.action') }}</span>
        <input v-model="filters.action" class="aloo-input" :placeholder="t('admin.auditLogs.filters.actionPlaceholder')" />
      </label>
      <label class="aloo-field">
        <span class="aloo-label">{{ t('admin.auditLogs.filters.entityType') }}</span>
        <input v-model="filters.entityType" class="aloo-input" :placeholder="t('admin.auditLogs.filters.entityPlaceholder')" />
      </label>
      <label class="aloo-field">
        <span class="aloo-label">{{ t('admin.auditLogs.filters.from') }}</span>
        <input v-model="filters.from" type="date" class="aloo-input" />
      </label>
      <label class="aloo-field">
        <span class="aloo-label">{{ t('admin.auditLogs.filters.to') }}</span>
        <input v-model="filters.to" type="date" class="aloo-input" />
      </label>
      <div class="flex flex-wrap gap-2 md:col-span-2 xl:col-span-5">
        <button type="button" class="aloo-btn aloo-btn--primary" @click="applyFilters">
          {{ t('admin.auditLogs.filters.apply') }}
        </button>
        <button type="button" class="aloo-btn aloo-btn--secondary" @click="resetFilters">
          {{ t('admin.auditLogs.filters.reset') }}
        </button>
      </div>
    </section>

    <p v-if="errorMessage" class="rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-sm font-bold text-red-700">{{ errorMessage }}</p>

    <section class="overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm">
      <div v-if="isLoading" class="grid gap-3 p-5">
        <div v-for="i in 5" :key="i" class="h-14 animate-pulse rounded-2xl bg-slate-100" />
      </div>
      <EmptyState
        v-else-if="!logs.length"
        :title="t('admin.auditLogs.emptyTitle')"
        :description="t('admin.auditLogs.emptyDescription')"
      />
      <div v-else class="overflow-x-auto">
        <table class="min-w-[980px] w-full text-left text-sm">
          <thead class="bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
            <tr>
              <th class="px-5 py-4">{{ t('admin.auditLogs.columns.time') }}</th>
              <th class="px-5 py-4">{{ t('admin.auditLogs.columns.actor') }}</th>
              <th class="px-5 py-4">{{ t('admin.auditLogs.columns.action') }}</th>
              <th class="px-5 py-4">{{ t('admin.auditLogs.columns.entity') }}</th>
              <th class="px-5 py-4">{{ t('admin.auditLogs.columns.details') }}</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr v-for="log in logs" :key="log.id">
              <td class="whitespace-nowrap px-5 py-4 text-slate-600">{{ formatDate(log.createdAt) }}</td>
              <td class="px-5 py-4 font-semibold text-slate-700">{{ log.actorEmail }}</td>
              <td class="px-5 py-4 font-black text-avocado-900">{{ log.action }}</td>
              <td class="px-5 py-4 text-slate-600">{{ log.entityType }}<span v-if="log.entityId"> #{{ log.entityId }}</span></td>
              <td class="max-w-md truncate px-5 py-4 text-slate-600" :title="log.details">{{ log.details || '-' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-if="!isLoading && logs.length" class="px-5 pb-5 pt-2">
        <Pagination
          :page="currentPage"
          :total-pages="totalPages"
          :visible-count="logs.length"
          :total-count="totalElements"
          :label="t('admin.auditLogs.paginationLabel')"
          @prev="currentPage = Math.max(1, currentPage - 1); loadLogs()"
          @next="currentPage = Math.min(totalPages, currentPage + 1); loadLogs()"
        />
      </div>
    </section>
  </div>
</template>
