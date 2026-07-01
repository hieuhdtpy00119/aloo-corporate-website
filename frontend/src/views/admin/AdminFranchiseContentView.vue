<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import AdminLinkPicker from '../../components/admin/AdminLinkPicker.vue'
import AdminListPage from '../../components/admin/AdminListPage.vue'
import AdminNestedShell from '../../components/admin/shell/AdminNestedShell.vue'
import AdminShellFrame from '../../components/admin/shell/AdminShellFrame.vue'
import AdminShellTablePanel from '../../components/admin/shell/AdminShellTablePanel.vue'
import AdminShellTabs from '../../components/admin/shell/AdminShellTabs.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import { useAdminModuleI18n } from '../../composables/useAdminModuleI18n'
import { franchiseContentService, normalizeStorageAssetUrl, postService, productService, resolveBackendAssetUrl, uploadService } from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'
import {
  FRANCHISE_ADMIN_SECTION_KEYS,
  FRANCHISE_SECTION_SCHEMAS,
  FRANCHISE_SINGLETON_SECTIONS,
  contentPrimaryTitleKey,
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
const formErrors = ref({})
const modalFormTab = ref('required')
const uploadingImageKey = ref('')
const isLoadingLinkOptions = ref(false)
const products = ref([])
const posts = ref([])

const SECTION_LINK_DEFAULTS = {
  hero: {
    buttonLink: '/consultation',
    secondaryButtonLink: '#investment',
  },
  cta: {
    buttonLink: '/consultation',
  },
}
const searchQuery = ref('')
const sectionFilter = ref(t('admin.shared.all'))
const statusFilter = ref(t('admin.shared.all'))
const currentPage = ref(1)
const pageSize = 8

const LEGACY_SECTION_KEYS = ['costs', 'benefits']
const ALL_SECTION_KEYS = [...FRANCHISE_ADMIN_SECTION_KEYS, ...LEGACY_SECTION_KEYS]

const sectionOptions = computed(() =>
  FRANCHISE_ADMIN_SECTION_KEYS.map((value) => ({
    value,
    label: m(`sections.${value}`),
  })),
)

const sectionLabels = computed(() =>
  Object.fromEntries(ALL_SECTION_KEYS.map((value) => [value, m(`sections.${value}`)])),
)
const sectionFilters = computed(() => [
  t('admin.shared.all'),
  ...ALL_SECTION_KEYS.map((value) => sectionLabels.value[value]),
])

const formTabItems = computed(() => [
  { key: 'required', label: m('formTabs.required') },
  { key: 'content', label: m('formTabs.content') },
  { key: 'preview', label: m('formTabs.preview') },
])

const formErrorTabMap = computed(() => {
  const map = { sortOrder: 'required' }
  if (!primaryTitleKey.value) map.title = 'required'
  sectionSchema.value.forEach((field) => {
    map[field.key] = 'content'
  })
  return map
})

const PUBLIC_SECTION_HASH = {
  investment: 'investment',
  process: 'process',
}

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
const primaryTitleKey = computed(() => contentPrimaryTitleKey(form.sectionKey))
const showAdminTitleField = computed(() => !primaryTitleKey.value)
const isLegacySection = computed(() => LEGACY_SECTION_KEYS.includes(form.sectionKey))
const isSectionLocked = computed(() => mode.value === 'edit')

const publicPreviewUrl = computed(() => {
  const hash = PUBLIC_SECTION_HASH[form.sectionKey]
  return hash ? `/franchise#${hash}` : '/franchise'
})

const singletonWarning = computed(() => {
  if (mode.value !== 'create' || !FRANCHISE_SINGLETON_SECTIONS.includes(form.sectionKey)) return ''
  const existing = items.value.find(
    (item) => item.sectionKey === form.sectionKey && item.status === 'ACTIVE',
  )
  if (!existing) return ''
  return m('validation.singletonExists', { section: sectionLabels.value[form.sectionKey] || form.sectionKey })
})

const pendingDeleteItem = computed(() => items.value.find((item) => item.id === pendingDeleteId.value) || null)

const contentFieldError = (key) => {
  const code = formErrors.value[key]
  if (!code) return ''
  if (code === 'required') return m('validation.fieldRequired', { field: m(`contentFields.${key}`) })
  if (code === 'invalidUrl') return m('validation.linkUrl')
  if (code === 'invalidImage') return m('validation.imageUrl')
  return code
}

const imagePreviewUrl = (fieldKey) => resolveBackendAssetUrl(contentFields[fieldKey] || '')

const normalizeContentImageFields = (sectionKey, fields) => {
  const schema = FRANCHISE_SECTION_SCHEMAS[sectionKey] || []
  schema
    .filter((field) => field.type === 'image')
    .forEach((field) => {
      if (fields[field.key]) {
        fields[field.key] = normalizeStorageAssetUrl(fields[field.key])
      }
    })
}

const handleImageFileChange = async (event, fieldKey) => {
  const file = event.target.files?.[0]
  if (!file) return

  uploadingImageKey.value = fieldKey
  try {
    const { data } = await uploadService.image(file)
    contentFields[fieldKey] = normalizeStorageAssetUrl(data.url)
    toast.success(m('toasts.imageUploaded'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.imageError'))
  } finally {
    uploadingImageKey.value = ''
    event.target.value = ''
  }
}

const getSectionValue = (label) => {
  const match = ALL_SECTION_KEYS.map((value) => ({ value, label: sectionLabels.value[value] })).find(
    (item) => item.label === label,
  )
  return match?.value || label
}

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
  formErrors.value = {}
  modalFormTab.value = 'required'
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

const fetchLinkOptions = async () => {
  if (products.value.length && posts.value.length) return
  isLoadingLinkOptions.value = true
  try {
    const [productResponse, postResponse] = await Promise.all([productService.list(), postService.list()])
    products.value = Array.isArray(productResponse.data) ? productResponse.data : []
    posts.value = Array.isArray(postResponse.data) ? postResponse.data : []
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.linkOptionsError'))
  } finally {
    isLoadingLinkOptions.value = false
  }
}

const applySectionContentDefaults = (sectionKey) => {
  const fields = defaultFranchiseContentFields(sectionKey)
  if (mode.value === 'create') {
    Object.assign(fields, SECTION_LINK_DEFAULTS[sectionKey] || {})
  }
  Object.assign(contentFields, fields)
}

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
const listCountText = computed(() => t('admin.shared.totalCount', { count: filteredItems.value.length }))

watch([searchQuery, sectionFilter, statusFilter], () => {
  currentPage.value = 1
})

const openCreateModal = () => {
  mode.value = 'create'
  resetForm()
  applySectionContentDefaults(form.sectionKey)
  fetchLinkOptions()
  showModal.value = true
}

const openEditModal = (item) => {
  mode.value = 'edit'
  editingId.value = item.id
  formErrors.value = {}
  modalFormTab.value = 'required'
  fetchLinkOptions()
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
  normalizeContentImageFields(item.sectionKey, contentFields)
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const resolvePayloadTitle = () => {
  const key = primaryTitleKey.value
  if (key) return String(contentFields[key] ?? '').trim()
  return form.title.trim()
}

const validateForm = () => {
  const errors = {}
  const contentValidation = validateFranchiseContent(form.sectionKey, contentFields)
  Object.assign(errors, contentValidation)

  const title = resolvePayloadTitle()
  if (!title) {
    if (primaryTitleKey.value) errors[primaryTitleKey.value] = 'required'
    else errors.title = m('validation.title')
  }

  if (Number(form.sortOrder) < 0 || Number.isNaN(Number(form.sortOrder))) {
    errors.sortOrder = m('validation.sortOrder')
  }

  if (form.sectionKey === 'process') {
    const step = Number(contentFields.stepNumber)
    if (!Number.isFinite(step) || step < 1) {
      errors.stepNumber = m('validation.stepNumber')
    }
  }

  return errors
}

const focusFirstErrorTab = (errors) => {
  const firstErrorKey = Object.keys(errors)[0]
  if (!firstErrorKey) return
  modalFormTab.value = formErrorTabMap.value[firstErrorKey] || 'content'
}

const buildPayload = () => {
  const errors = validateForm()
  if (Object.keys(errors).length) {
    formErrors.value = errors
    focusFirstErrorTab(errors)
    throw new Error('validation')
  }

  const contentSnapshot = { ...contentFields }
  normalizeContentImageFields(form.sectionKey, contentSnapshot)
  const content = serializeFranchiseContent(form.sectionKey, contentSnapshot)
  return {
    sectionKey: form.sectionKey,
    title: resolvePayloadTitle(),
    content,
    amount: null,
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
    if (error.message === 'validation') {
      toast.error(m('toasts.requiredFields'))
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

onMounted(() => {
  fetchItems()
  fetchLinkOptions()
})

watch(
  () => form.sectionKey,
  (sectionKey) => {
    if (mode.value === 'create') {
      applySectionContentDefaults(sectionKey)
    }
  },
)
</script>

<template>
  <AdminListPage>
    <AdminNestedShell>
      <AdminShellFrame variant="header" inner="header">
        <AdminPageHeader
          :eyebrow="t('admin.nav.franchise')"
          :title="m('title')"
        >
          <template #actions>
            <a
              href="/franchise"
              target="_blank"
              rel="noopener noreferrer"
              class="admin-list-btn admin-list-btn--outline"
            >
              {{ m('previewPublic') }}
            </a>
            <button type="button" class="admin-list-btn admin-list-btn--primary" @click="openCreateModal">
              {{ m('add') }}
            </button>
          </template>
        </AdminPageHeader>
      </AdminShellFrame>

      <AdminShellFrame variant="toolbar" inner="toolbar">
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
      </AdminShellFrame>

      <AdminShellFrame v-if="errorMessage" as="p" variant="alert" class="admin-list-alert">
        {{ errorMessage }}
      </AdminShellFrame>

      <AdminShellFrame v-if="isLoading" variant="body" inner="pad">
        <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
      </AdminShellFrame>

      <AdminShellFrame v-else-if="!filteredItems.length" variant="body" inner="pad">
        <EmptyState :message="m('empty')" />
      </AdminShellFrame>

      <AdminShellFrame v-else variant="body" visibility="desktop">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <table class="admin-shell-table">
            <colgroup>
              <col style="width: 16%" />
              <col style="width: 30%" />
              <col style="width: 10%" />
              <col style="width: 20%" />
              <col style="width: 12%" />
              <col style="width: 12%" />
            </colgroup>
            <thead>
              <tr>
                <th>{{ m('columns.section') }}</th>
                <th>{{ m('columns.title') }}</th>
                <th>{{ m('columns.sortOrder') }}</th>
                <th>{{ m('columns.note') }}</th>
                <th class="text-center">{{ m('columns.status') }}</th>
                <th class="text-right">{{ m('columns.actions') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in paginatedItems" :key="item.id">
                <td class="admin-shell-cell-muted font-semibold">
                  {{ sectionLabels[item.sectionKey] || item.sectionKey }}
                </td>
                <td>
                  <p class="truncate font-black text-avocado-950">{{ item.title }}</p>
                </td>
                <td class="admin-shell-cell-muted">{{ item.sortOrder }}</td>
                <td class="admin-shell-cell-truncate admin-shell-cell-muted">{{ item.note || '—' }}</td>
                <td class="text-center">
                  <span class="inline-flex min-w-[108px] justify-center rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(item.status)">
                    {{ statusLabels[item.status] || item.status }}
                  </span>
                </td>
                <td>
                  <div class="flex justify-end gap-2">
                    <button class="admin-list-btn admin-list-btn--outline shrink-0 !min-h-[32px] !px-2.5 !py-1.5 !text-xs" @click="openEditModal(item)">
                      {{ m('actions.edit') }}
                    </button>
                    <button class="admin-list-btn admin-list-btn--danger shrink-0 !min-h-[32px] !px-2.5 !py-1.5 !text-xs" @click="pendingDeleteId = item.id">
                      {{ m('actions.delete') }}
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="!isLoading && filteredItems.length" variant="body" visibility="mobile">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <template #below>
            <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack">
              <article v-for="item in paginatedItems" :key="item.id" class="admin-shell-mobile-card">
                <div class="flex items-start justify-between gap-3">
                  <div class="min-w-0">
                    <p class="text-xs font-semibold text-slate-500">{{ sectionLabels[item.sectionKey] || item.sectionKey }}</p>
                    <h3 class="mt-1 truncate font-black text-avocado-950">{{ item.title }}</h3>
                  </div>
                  <span class="shrink-0 rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(item.status)">
                    {{ statusLabels[item.status] || item.status }}
                  </span>
                </div>
                <div class="mt-4 grid gap-2 text-sm text-slate-700">
                  <p><span class="font-bold text-slate-900">{{ m('columns.sortOrder') }}:</span> {{ item.sortOrder }}</p>
                  <p v-if="item.note"><span class="font-bold text-slate-900">{{ m('columns.note') }}:</span> {{ item.note }}</p>
                </div>
                <div class="mt-4 flex flex-wrap gap-2">
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 text-xs font-bold text-avocado-700" @click="openEditModal(item)">
                    {{ m('actions.edit') }}
                  </button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 text-xs font-bold text-red-600" @click="pendingDeleteId = item.id">
                    {{ m('actions.delete') }}
                  </button>
                </div>
              </article>
            </div>
          </template>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="filteredItems.length" variant="footer">
        <Pagination
          :page="currentPage"
          :total-pages="totalPages"
          :visible-count="paginatedItems.length"
          :total-count="filteredItems.length"
          :label="m('paginationLabel')"
          @prev="currentPage = Math.max(1, currentPage - 1)"
          @next="currentPage = Math.min(totalPages, currentPage + 1)"
        />
      </AdminShellFrame>
    </AdminNestedShell>

    <BaseModal
      :show="showModal"
      :title="mode === 'create' ? m('modals.create') : m('modals.edit')"
      max-width="max-w-4xl"
      @close="closeModal"
    >
      <form id="franchise-content-form" class="grid gap-5" @submit.prevent="saveItem">
        <AdminShellTabs
          v-model="modalFormTab"
          :items="formTabItems"
          :aria-label="m('formTabs.aria')"
        />

        <p v-if="singletonWarning" class="rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm font-semibold text-amber-800">
          {{ singletonWarning }}
        </p>
        <p v-if="isLegacySection" class="rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-600">
          {{ m('validation.legacySection') }}
        </p>

        <section v-show="modalFormTab === 'required'" class="franchise-form-panel grid gap-5 rounded-2xl border border-slate-200 bg-white p-5">
          <div class="grid gap-5 md:grid-cols-2">
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.section') }}
              <select
                v-model="form.sectionKey"
                class="admin-input-premium cursor-pointer"
                :disabled="isSectionLocked"
                :class="{ 'cursor-not-allowed bg-slate-100 text-slate-500': isSectionLocked }"
              >
                <option v-for="option in sectionOptions" :key="option.value" :value="option.value">{{ option.label }}</option>
                <option v-if="isLegacySection" :value="form.sectionKey">{{ sectionLabels[form.sectionKey] }}</option>
              </select>
              <span v-if="isSectionLocked" class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.sectionLocked') }}</span>
            </label>
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.status') }}
              <select v-model="form.status" class="admin-input-premium cursor-pointer">
                <option v-for="(label, value) in statusLabels" :key="value" :value="value">{{ label }}</option>
              </select>
            </label>
          </div>

          <div class="grid gap-5 md:grid-cols-2">
            <label v-if="showAdminTitleField" class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
              {{ m('fields.adminTitle') }}
              <input v-model="form.title" class="admin-input-premium" :placeholder="m('placeholders.adminTitle')" />
              <span v-if="formErrors.title" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.title }}</span>
              <span v-else class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.adminTitle') }}</span>
            </label>
            <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500" :class="{ 'md:col-span-2': !showAdminTitleField }">
              {{ m('fields.sortOrder') }}
              <input v-model.number="form.sortOrder" type="number" min="0" class="admin-input-premium" />
              <span v-if="formErrors.sortOrder" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ formErrors.sortOrder }}</span>
              <span v-else class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.sortOrder') }}</span>
            </label>
          </div>

          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.note') }}
            <input v-model="form.note" class="admin-input-premium" :placeholder="m('placeholders.adminNote')" />
            <span class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.adminNote') }}</span>
          </label>
        </section>

        <section v-show="modalFormTab === 'content'" class="franchise-form-panel grid gap-4 rounded-2xl border border-slate-200 bg-white p-5">
          <p class="text-sm text-slate-500">{{ m('formTabs.contentHint') }}</p>
          <div class="grid gap-4 md:grid-cols-2">
            <template v-for="field in sectionSchema" :key="field.key">
              <div
                v-if="field.type === 'image'"
                class="grid gap-4 md:col-span-2 md:grid-cols-[minmax(0,1fr)_220px]"
              >
                <div class="grid content-start gap-3">
                  <p class="text-xs font-bold uppercase tracking-wider text-slate-500">
                    {{ m(`contentFields.${field.key}`) }}<span v-if="field.required" class="text-red-500"> *</span>
                  </p>
                  <input
                    v-model="contentFields[field.key]"
                    class="admin-input-premium"
                    :placeholder="m('placeholders.imageUrl')"
                  />
                  <label class="grid gap-2 text-xs font-semibold normal-case tracking-normal text-slate-600">
                    {{ m('fields.imageFile') }}
                    <input
                      type="file"
                      accept=".jpg,.jpeg,.jfif,.png,.webp,.gif,image/jpeg,image/png,image/webp,image/gif"
                      class="rounded-xl border border-slate-300 bg-white px-4 py-3 text-sm font-semibold text-slate-600 file:mr-3 file:cursor-pointer file:rounded-lg file:border-0 file:bg-avocado-600 file:px-3 file:py-2 file:text-xs file:font-bold file:text-white hover:file:bg-avocado-700 disabled:cursor-not-allowed disabled:opacity-60"
                      :disabled="Boolean(uploadingImageKey)"
                      @change="handleImageFileChange($event, field.key)"
                    />
                  </label>
                  <span v-if="uploadingImageKey === field.key" class="text-xs font-bold text-avocado-700">{{ m('fields.uploading') }}</span>
                  <span v-if="contentFieldError(field.key)" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ contentFieldError(field.key) }}</span>
                  <span v-else class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.imageUrl') }}</span>
                </div>
                <div class="overflow-hidden rounded-2xl border border-slate-200 bg-slate-50 shadow-sm">
                  <div class="flex aspect-[4/3] items-center justify-center overflow-hidden">
                    <img
                      v-if="imagePreviewUrl(field.key)"
                      :src="imagePreviewUrl(field.key)"
                      :alt="m('preview.imageAlt')"
                      class="h-full w-full object-cover"
                    />
                    <p v-else class="px-4 text-center text-xs font-semibold text-slate-400">{{ m('preview.noImage') }}</p>
                  </div>
                </div>
              </div>
              <label
                v-else-if="field.type !== 'checkbox'"
                class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500"
                :class="{ 'md:col-span-2': field.type === 'textarea' || field.type === 'url' || field.type === 'image' }"
              >
                {{ m(`contentFields.${field.key}`) }}<span v-if="field.required" class="text-red-500"> *</span>
                <select
                  v-if="field.type === 'select'"
                  v-model="contentFields[field.key]"
                  class="admin-input-premium cursor-pointer bg-white"
                >
                  <option v-for="option in field.options" :key="option" :value="option">{{ option }}</option>
                </select>
                <input
                  v-else-if="field.type === 'number'"
                  v-model.number="contentFields[field.key]"
                  type="number"
                  :min="field.min || 0"
                  class="admin-input-premium bg-white"
                />
                <textarea
                  v-else-if="field.type === 'textarea'"
                  v-model="contentFields[field.key]"
                  :rows="field.rows || 3"
                  class="admin-input-premium bg-white"
                />
                <AdminLinkPicker
                  v-else-if="field.type === 'url'"
                  v-model="contentFields[field.key]"
                  module="franchise"
                  :products="products"
                  :posts="posts"
                  :loading="isLoadingLinkOptions"
                  :allow-hash="true"
                  :error="contentFieldError(field.key)"
                />
                <input
                  v-else
                  v-model="contentFields[field.key]"
                  class="admin-input-premium bg-white"
                />
                <span v-if="field.type !== 'url' && contentFieldError(field.key)" class="text-xs font-bold normal-case tracking-normal text-red-600">{{ contentFieldError(field.key) }}</span>
                <span v-else-if="field.type !== 'url' && field.key === primaryTitleKey" class="text-xs font-semibold normal-case tracking-normal text-slate-500">{{ m('fieldHints.contentTitle') }}</span>
              </label>
              <label v-else class="inline-flex items-center gap-3 rounded-xl border border-slate-200 bg-white px-4 py-3 text-sm font-bold text-slate-700 md:col-span-2">
                <input v-model="contentFields[field.key]" type="checkbox" class="h-4 w-4 accent-avocado-700" />
                {{ m(`contentFields.${field.key}`) }}
              </label>
            </template>
          </div>
        </section>

        <section v-show="modalFormTab === 'preview'" class="grid gap-4 rounded-2xl bg-slate-50 p-5">
          <p class="text-sm leading-7 text-slate-600">{{ m(`sectionHints.${form.sectionKey}`) }}</p>
          <div class="rounded-2xl border border-avocado-100 bg-white p-5">
            <p class="text-xs font-black uppercase tracking-wider text-avocado-600">{{ sectionLabels[form.sectionKey] }}</p>
            <p class="mt-2 text-lg font-black text-avocado-950">{{ resolvePayloadTitle() || '—' }}</p>
            <p v-if="form.status === 'ACTIVE'" class="mt-3 text-xs font-semibold text-emerald-700">{{ m('formTabs.previewActive') }}</p>
            <p v-else class="mt-3 text-xs font-semibold text-slate-500">{{ m('formTabs.previewHidden') }}</p>
          </div>
          <a
            :href="publicPreviewUrl"
            target="_blank"
            rel="noopener noreferrer"
            class="inline-flex w-fit items-center gap-2 rounded-full border border-avocado-200 px-5 py-2.5 text-xs font-bold uppercase tracking-wider text-avocado-700 transition hover:bg-avocado-50"
          >
            {{ m('formTabs.openPublic') }}
          </a>
        </section>
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

    <ConfirmModal
      :show="Boolean(pendingDeleteId)"
      :title="m('confirmDelete.title')"
      :message="m('confirmDelete.message', { title: pendingDeleteItem?.title || '' })"
      :confirm-text="m('confirmDelete.confirm')"
      @cancel="pendingDeleteId = null"
      @confirm="confirmDelete"
    />
  </AdminListPage>
</template>

<style scoped>
.franchise-form-panel {
  min-height: 280px;
}
</style>
