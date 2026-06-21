<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import { useAdminModuleI18n } from '../../composables/useAdminModuleI18n'
import { franchiseContentService } from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'
import {
  FRANCHISE_SECTION_SCHEMAS,
  defaultFranchiseContentFields,
  parseFranchiseContent,
  serializeFranchiseContent,
  validateFranchiseContent,
} from '../../utils/franchiseContentSchema'

const { m, t } = useAdminModuleI18n('franchise')
const toast = useToastStore()

const items = ref([])
const isLoading = ref(false)
const errorMessage = ref('')
const showModal = ref(false)
const mode = ref('create')
const editingId = ref(null)
const pendingDeleteId = ref(null)
const searchQuery = ref('')
const sectionFilter = ref(t('admin.shared.all'))
const statusFilter = ref(t('admin.shared.all'))
const currentPage = ref(1)
const pageSize = 8

const sectionKeys = [
  'hero',
  'advantages',
  'models',
  'investment',
  'profit',
  'process',
  'founder_story',
  'faq',
  'cta',
  'costs',
  'benefits',
]

const sectionOptions = computed(() =>
  sectionKeys.map((value) => ({
    value,
    label: m(`sections.${value}`),
  })),
)

const sectionLabels = computed(() => Object.fromEntries(sectionOptions.value.map((item) => [item.value, item.label])))
const sectionFilters = computed(() => [t('admin.shared.all'), ...sectionOptions.value.map((item) => item.label)])

const statusLabels = computed(() => ({
  ACTIVE: m('status.ACTIVE'),
  INACTIVE: m('status.INACTIVE'),
  HIDDEN: m('status.HIDDEN'),
}))
const statusFilters = computed(() => [t('admin.shared.all'), ...Object.values(statusLabels.value)])

const defaultForm = () => ({
  sectionKey: 'hero',
  title: '',
  content: '{}',
  amount: '',
  note: '',
  sortOrder: 0,
  status: 'ACTIVE',
})

const form = reactive(defaultForm())
const contentFields = reactive(defaultFranchiseContentFields('hero'))

const sectionSchema = computed(() => FRANCHISE_SECTION_SCHEMAS[form.sectionKey] || [{ key: 'body', type: 'textarea', rows: 6 }])

const getSectionValue = (label) => sectionOptions.value.find((item) => item.label === label)?.value || label

const getStatusValue = (label) =>
  Object.entries(statusLabels.value).find(([, value]) => value === label)?.[0] || label

const statusClass = (status) => {
  if (status === 'ACTIVE') return 'border-emerald-200 bg-emerald-50 text-emerald-700'
  if (status === 'HIDDEN') return 'border-slate-200 bg-slate-100 text-slate-600'
  return 'border-amber-200 bg-amber-50 text-amber-700'
}

const resetForm = () => {
  Object.assign(form, defaultForm())
  Object.assign(contentFields, defaultFranchiseContentFields(form.sectionKey))
  editingId.value = null
}

const normalizeItem = (item) => ({
  id: item.id,
  sectionKey: item.sectionKey,
  title: item.title,
  content: item.content || '',
  amount: item.amount || '',
  note: item.note || '',
  sortOrder: Number(item.sortOrder || 0),
  status: item.status || 'ACTIVE',
})

const fetchItems = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const { data } = await franchiseContentService.list()
    items.value = Array.isArray(data) ? data.map(normalizeItem) : []
  } catch (error) {
    errorMessage.value = error.response?.data?.message || m('toasts.loadError')
    toast.error(errorMessage.value)
  } finally {
    isLoading.value = false
  }
}

const filteredItems = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return items.value
    .filter((item) => {
      const haystack = [item.title, item.sectionKey, item.amount, item.note, item.content]
        .filter(Boolean)
        .join(' ')
        .toLowerCase()
      const matchesSearch = !keyword || haystack.includes(keyword)
      const matchesSection =
        sectionFilter.value === t('admin.shared.all') || item.sectionKey === getSectionValue(sectionFilter.value)
      const matchesStatus =
        statusFilter.value === t('admin.shared.all') || item.status === getStatusValue(statusFilter.value)
      return matchesSearch && matchesSection && matchesStatus
    })
    .sort((a, b) => a.sectionKey.localeCompare(b.sectionKey) || a.sortOrder - b.sortOrder || a.id - b.id)
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredItems.value.length / pageSize)))
const paginatedItems = computed(() =>
  filteredItems.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)

watch([searchQuery, sectionFilter, statusFilter], () => {
  currentPage.value = 1
})

const openCreateModal = () => {
  mode.value = 'create'
  resetForm()
  Object.assign(contentFields, defaultFranchiseContentFields(form.sectionKey))
  showModal.value = true
}

const openEditModal = (item) => {
  mode.value = 'edit'
  editingId.value = item.id
  Object.assign(form, {
    sectionKey: item.sectionKey,
    title: item.title,
    content: item.content || '{}',
    amount: item.amount || '',
    note: item.note || '',
    sortOrder: item.sortOrder,
    status: item.status,
  })
  Object.assign(contentFields, parseFranchiseContent(item.sectionKey, item.content))
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const buildPayload = () => {
  const missing = validateFranchiseContent(form.sectionKey, contentFields)
  if (missing.length) {
    throw new Error('required')
  }
  const content = serializeFranchiseContent(form.sectionKey, contentFields)
  return {
    sectionKey: form.sectionKey,
    title: form.title.trim(),
    content,
    amount: form.amount.trim() || null,
    note: form.note.trim() || null,
    sortOrder: Number(form.sortOrder || 0),
    status: form.status,
  }
}

const saveItem = async () => {
  try {
    const payload = buildPayload()
    const request = editingId.value
      ? franchiseContentService.update(editingId.value, payload)
      : franchiseContentService.create(payload)
    const { data } = await request
    const normalized = normalizeItem(data)
    const index = items.value.findIndex((item) => item.id === normalized.id)
    if (index === -1) items.value.unshift(normalized)
    else items.value.splice(index, 1, normalized)
    toast.success(mode.value === 'create' ? m('toasts.created') : m('toasts.updated'))
    closeModal()
  } catch (error) {
    if (error instanceof SyntaxError || error.message === 'required') {
      toast.error(m('toasts.requiredFields'))
      return
    }
    if (error instanceof SyntaxError) {
      toast.error(m('toasts.invalidJson'))
      return
    }
    toast.error(error.response?.data?.message || m('toasts.saveError'))
  }
}

const confirmDelete = async () => {
  try {
    await franchiseContentService.remove(pendingDeleteId.value)
    items.value = items.value.filter((item) => item.id !== pendingDeleteId.value)
    toast.success(m('toasts.deleted'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.deleteError'))
  } finally {
    pendingDeleteId.value = null
  }
}

onMounted(fetchItems)

watch(
  () => form.sectionKey,
  (sectionKey) => {
    if (mode.value === 'create') {
      Object.assign(contentFields, defaultFranchiseContentFields(sectionKey))
    }
  },
)
</script>

<template>
  <section>
    <AdminPageHeader
      :eyebrow="t('admin.nav.franchise')"
      :title="m('title')"
      :description="m('description')"
    >
      <template #actions>
        <a
          href="/franchise"
          target="_blank"
          rel="noopener noreferrer"
          class="aloo-btn aloo-btn--secondary"
        >
          {{ m('previewPublic') }}
        </a>
        <button type="button" class="aloo-btn aloo-btn--primary" @click="openCreateModal">
          {{ m('add') }}
        </button>
      </template>
    </AdminPageHeader>

    <SearchFilterBar
      v-model:search="searchQuery"
      v-model:status="statusFilter"
      v-model:extra-filter="sectionFilter"
      :search-label="m('filters.searchLabel')"
      :search-placeholder="m('filters.searchPlaceholder')"
      :status-label="t('admin.shared.status')"
      :status-options="statusFilters"
      :extra-label="m('filters.sectionLabel')"
      :extra-options="sectionFilters"
      :extra-placeholder="m('filters.sectionAll')"
    />

    <p v-if="errorMessage" class="rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-xs font-bold text-red-700" role="alert">
      {{ errorMessage }}
    </p>

    <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
      <div class="overflow-x-auto">
        <table v-if="!isLoading && filteredItems.length" class="min-w-[980px] w-full table-fixed whitespace-nowrap text-left">
          <colgroup>
            <col class="w-[14%]" />
            <col class="w-[24%]" />
            <col class="w-[12%]" />
            <col class="w-[10%]" />
            <col class="w-[14%]" />
            <col class="w-[12%]" />
            <col class="w-[14%]" />
          </colgroup>
          <thead class="bg-slate-50 text-sm font-black text-slate-600">
            <tr>
              <th class="px-5 py-4">{{ m('columns.section') }}</th>
              <th class="px-5 py-4">{{ m('columns.title') }}</th>
              <th class="px-5 py-4">{{ m('columns.amount') }}</th>
              <th class="px-5 py-4">{{ m('columns.sortOrder') }}</th>
              <th class="px-5 py-4">{{ m('columns.note') }}</th>
              <th class="px-5 py-4">{{ m('columns.status') }}</th>
              <th class="px-5 py-4 text-right">{{ m('columns.actions') }}</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100 text-sm">
            <tr v-for="item in paginatedItems" :key="item.id" class="hover:bg-slate-50/70">
              <td class="px-5 py-4 font-semibold text-slate-700">
                {{ sectionLabels[item.sectionKey] || item.sectionKey }}
              </td>
              <td class="px-5 py-4">
                <p class="truncate font-black text-avocado-950">{{ item.title }}</p>
              </td>
              <td class="truncate px-5 py-4 text-slate-600">{{ item.amount || '—' }}</td>
              <td class="px-5 py-4 text-slate-600">{{ item.sortOrder }}</td>
              <td class="px-5 py-4 text-slate-600">
                <p class="truncate">{{ item.note || '—' }}</p>
              </td>
              <td class="px-5 py-4">
                <span class="inline-flex min-w-[108px] justify-center rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(item.status)">
                  {{ statusLabels[item.status] || item.status }}
                </span>
              </td>
              <td class="px-5 py-4">
                <div class="flex justify-end gap-2">
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 font-bold text-avocado-700 hover:bg-avocado-50" @click="openEditModal(item)">
                    {{ m('actions.edit') }}
                  </button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600 hover:bg-red-50" @click="pendingDeleteId = item.id">
                    {{ m('actions.delete') }}
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <EmptyState v-if="isLoading || filteredItems.length === 0" :loading="isLoading" :message="m('empty')" />
    </div>

    <Pagination
      :page="currentPage"
      :total-pages="totalPages"
      :visible-count="paginatedItems.length"
      :total-count="filteredItems.length"
      :label="m('paginationLabel')"
      @prev="currentPage = Math.max(1, currentPage - 1)"
      @next="currentPage = Math.min(totalPages, currentPage + 1)"
    />

    <BaseModal
      :show="showModal"
      :title="mode === 'create' ? m('modals.create') : m('modals.edit')"
      max-width="max-w-3xl"
      @close="closeModal"
    >
      <form id="franchise-content-form" class="grid gap-5 md:grid-cols-2" @submit.prevent="saveItem">
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ m('fields.section') }}
          <select v-model="form.sectionKey" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500">
            <option v-for="option in sectionOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
          </select>
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ m('fields.title') }}
          <input v-model="form.title" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ m('fields.amount') }}
          <input v-model="form.amount" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ m('fields.sortOrder') }}
          <input v-model.number="form.sortOrder" type="number" min="0" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ m('fields.status') }}
          <select v-model="form.status" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500">
            <option v-for="(label, value) in statusLabels" :key="value" :value="value">{{ label }}</option>
          </select>
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
          {{ m('fields.note') }}
          <input v-model="form.note" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
          {{ m('fields.content') }}
          <div class="grid gap-4 rounded-2xl border border-slate-100 bg-slate-50/60 p-4 md:grid-cols-2">
            <template v-for="field in sectionSchema" :key="field.key">
              <label
                v-if="field.type !== 'checkbox'"
                class="grid gap-2 text-xs font-bold uppercase tracking-wide text-slate-500"
                :class="{ 'md:col-span-2': field.type === 'textarea' }"
              >
                {{ m(`contentFields.${field.key}`) }}
                <select
                  v-if="field.type === 'select'"
                  v-model="contentFields[field.key]"
                  class="rounded-lg border border-slate-200 bg-white px-4 py-3 text-sm outline-none focus:border-avocado-500"
                >
                  <option v-for="option in field.options" :key="option" :value="option">{{ option }}</option>
                </select>
                <input
                  v-else-if="field.type === 'number'"
                  v-model.number="contentFields[field.key]"
                  type="number"
                  :min="field.min || 0"
                  class="rounded-lg border border-slate-200 bg-white px-4 py-3 text-sm outline-none focus:border-avocado-500"
                />
                <textarea
                  v-else-if="field.type === 'textarea'"
                  v-model="contentFields[field.key]"
                  :rows="field.rows || 3"
                  class="rounded-lg border border-slate-200 bg-white px-4 py-3 text-sm outline-none focus:border-avocado-500"
                />
                <input
                  v-else
                  v-model="contentFields[field.key]"
                  class="rounded-lg border border-slate-200 bg-white px-4 py-3 text-sm outline-none focus:border-avocado-500"
                />
              </label>
              <label v-else class="inline-flex items-center gap-3 rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-bold text-slate-700 md:col-span-2">
                <input v-model="contentFields[field.key]" type="checkbox" class="h-4 w-4 accent-avocado-700" />
                {{ m(`contentFields.${field.key}`) }}
              </label>
            </template>
          </div>
        </label>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-lg border border-slate-200 px-4 py-3 font-bold text-slate-600 hover:bg-slate-50" type="button" @click="closeModal">
            {{ m('actions.cancel') }}
          </button>
          <button class="rounded-lg bg-brand-forest px-4 py-3 font-black text-white hover:bg-avocado-800" form="franchise-content-form" type="submit">
            {{ mode === 'create' ? m('actions.saveCreate') : m('actions.saveUpdate') }}
          </button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal :show="Boolean(pendingDeleteId)" @cancel="pendingDeleteId = null" @confirm="confirmDelete" />
  </section>
</template>
