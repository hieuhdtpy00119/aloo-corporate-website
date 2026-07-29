<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { Edit2, Image as ImageIcon, Trash2 } from 'lucide-vue-next'
import AdminShellFrame from '../shell/AdminShellFrame.vue'
import AdminShellTablePanel from '../shell/AdminShellTablePanel.vue'
import BaseModal from '../BaseModal.vue'
import ConfirmModal from '../ConfirmModal.vue'
import EmptyState from '../EmptyState.vue'
import Pagination from '../Pagination.vue'
import SearchFilterBar from '../SearchFilterBar.vue'
import {
  menuPosterService,
  normalizeStorageAssetUrl,
  resolveBackendAssetUrl,
  uploadService,
} from '../../../services/cmsService'
import { useAdminModuleI18n } from '../../../composables/useAdminModuleI18n'
import { useToastStore } from '../../../stores/toastStore'

const { m, t } = useAdminModuleI18n('products')
const toast = useToastStore()

const posters = ref([])
const isLoading = ref(false)
const loadError = ref('')
const searchQuery = ref('')
const statusFilter = ref(t('admin.shared.all'))
const currentPage = ref(1)
const pageSize = 6
const showModal = ref(false)
const mode = ref('create')
const editingId = ref(null)
const pendingDeleteId = ref(null)
const isSaving = ref(false)
const isUploading = ref(false)

const statuses = ['ACTIVE', 'INACTIVE']
const statusLabels = computed(() => ({
  ACTIVE: m('status.visible'),
  INACTIVE: m('status.INACTIVE'),
}))
const statusOptions = computed(() => [t('admin.shared.all'), ...statuses.map((status) => statusLabels.value[status])])

const defaultForm = () => ({
  branchKey: '',
  title: '',
  subtitle: '',
  imageUrl: '',
  altText: '',
  sortOrder: 0,
  status: 'ACTIVE',
})
const form = reactive(defaultForm())
const previewUrl = computed(() => resolveBackendAssetUrl(form.imageUrl || ''))

const getStatusValue = (label) =>
  Object.entries(statusLabels.value).find(([, value]) => value === label)?.[0] || label

const filteredPosters = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return posters.value.filter((poster) => {
    const haystack = [poster.title, poster.subtitle, poster.branchKey, poster.altText]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
    const matchesSearch = !keyword || haystack.includes(keyword)
    const matchesStatus = statusFilter.value === t('admin.shared.all') || poster.status === getStatusValue(statusFilter.value)
    return matchesSearch && matchesStatus
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredPosters.value.length / pageSize)))
const paginatedPosters = computed(() =>
  filteredPosters.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)
const countText = computed(() => t('admin.shared.totalCount', { count: filteredPosters.value.length }))

const normalizePoster = (poster) => ({
  ...poster,
  branchKey: poster.branchKey || '',
  title: poster.title || '',
  subtitle: poster.subtitle || '',
  imageUrl: normalizeStorageAssetUrl(poster.imageUrl || ''),
  altText: poster.altText || '',
  sortOrder: Number(poster.sortOrder ?? 0),
  status: poster.status || 'ACTIVE',
})

const loadPosters = async () => {
  isLoading.value = true
  loadError.value = ''
  try {
    const { data } = await menuPosterService.list()
    posters.value = Array.isArray(data) ? data.map(normalizePoster) : []
  } catch (error) {
    loadError.value = error.response?.data?.message || m('uploadErrors.menuLoadFailed')
  } finally {
    isLoading.value = false
  }
}

const closeModal = () => {
  showModal.value = false
  editingId.value = null
  Object.assign(form, defaultForm())
}

const openCreate = () => {
  mode.value = 'create'
  editingId.value = null
  Object.assign(form, defaultForm())
  showModal.value = true
}

const openEdit = (poster) => {
  mode.value = 'edit'
  editingId.value = poster.id
  Object.assign(form, normalizePoster(poster))
  showModal.value = true
}

const uploadImage = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return
  isUploading.value = true
  try {
    const { data } = await uploadService.image(file)
    form.imageUrl = normalizeStorageAssetUrl(data.url)
    toast.success(m('toasts.menuImageUploaded'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.menuImageError'))
  } finally {
    isUploading.value = false
    event.target.value = ''
  }
}

const savePoster = async () => {
  if (isSaving.value) return
  if (!form.branchKey.trim() || !form.title.trim()) {
    toast.error(m('toasts.posterFieldsRequired'))
    return
  }
  if (Number.isNaN(Number(form.sortOrder)) || Number(form.sortOrder) < 0) {
    toast.error(m('validation.sortOrder'))
    return
  }

  const payload = {
    branchKey: form.branchKey.trim(),
    title: form.title.trim(),
    subtitle: form.subtitle.trim() || null,
    imageUrl: normalizeStorageAssetUrl(form.imageUrl),
    altText: form.altText.trim() || null,
    sortOrder: Number(form.sortOrder),
    status: form.status,
  }

  isSaving.value = true
  try {
    const request = editingId.value
      ? menuPosterService.update(editingId.value, payload)
      : menuPosterService.create(payload)
    const { data } = await request
    const normalized = normalizePoster(data)
    const index = posters.value.findIndex((item) => item.id === normalized.id)
    if (index === -1) posters.value.unshift(normalized)
    else posters.value.splice(index, 1, normalized)
    posters.value.sort((left, right) => left.sortOrder - right.sortOrder || left.id - right.id)
    toast.success(mode.value === 'create' ? m('toasts.posterCreated') : m('toasts.posterUpdated'))
    closeModal()
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.posterSaveError'))
  } finally {
    isSaving.value = false
  }
}

const deletePoster = async () => {
  try {
    await menuPosterService.remove(pendingDeleteId.value)
    posters.value = posters.value.filter((poster) => poster.id !== pendingDeleteId.value)
    toast.success(m('toasts.posterDeleted'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.posterDeleteError'))
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

onMounted(loadPosters)
defineExpose({ openCreate })
</script>

<template>
  <AdminShellFrame variant="toolbar" inner="toolbar">
    <SearchFilterBar
      v-model:search="searchQuery"
      v-model:status="statusFilter"
      :search-label="m('filters.menuSearchLabel')"
      :search-placeholder="m('filters.menuSearchPlaceholder')"
      :status-label="m('filters.menuStatusLabel')"
      :status-options="statusOptions"
    />
  </AdminShellFrame>

  <AdminShellFrame variant="body" inner="none">
    <AdminShellTablePanel :title="m('tabs.menu')" :count-text="countText">
      <div v-if="isLoading" class="p-8 text-center text-sm font-semibold text-slate-500">{{ t('admin.shared.loading') }}</div>
      <div v-else-if="loadError" class="m-5 rounded-xl border border-red-200 bg-red-50 p-4 text-sm font-semibold text-red-700">{{ loadError }}</div>
      <EmptyState v-else-if="!paginatedPosters.length" :title="m('emptyMenu')" />
      <table v-else class="admin-shell-table hidden md:table">
        <thead>
          <tr>
            <th>{{ m('columns.menu.image') }}</th>
            <th>{{ m('columns.menu.menu') }}</th>
            <th>{{ m('columns.menu.branch') }}</th>
            <th>{{ m('columns.menu.description') }}</th>
            <th>{{ m('columns.menu.status') }}</th>
            <th class="text-right">{{ m('columns.menu.actions') }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="poster in paginatedPosters" :key="poster.id">
            <td>
              <img v-if="poster.imageUrl" :src="resolveBackendAssetUrl(poster.imageUrl)" :alt="poster.altText || poster.title" class="h-14 w-20 rounded-xl border border-slate-100 object-cover" />
              <span v-else class="grid h-14 w-20 place-items-center rounded-xl bg-slate-100 text-slate-400"><ImageIcon class="h-5 w-5" /></span>
            </td>
            <td class="font-bold text-slate-900">{{ poster.title }}</td>
            <td><code class="rounded bg-slate-100 px-2 py-1 text-xs">{{ poster.branchKey }}</code></td>
            <td class="max-w-xs text-sm text-slate-600">{{ poster.subtitle || '-' }}</td>
            <td><span class="rounded-full border px-2.5 py-1 text-xs font-bold" :class="poster.status === 'ACTIVE' ? 'border-emerald-200 bg-emerald-50 text-emerald-700' : 'border-slate-200 bg-slate-50 text-slate-500'">{{ statusLabels[poster.status] || poster.status }}</span></td>
            <td>
              <div class="flex justify-end gap-2">
                <button class="rounded-xl border border-avocado-100 p-2 text-avocado-700 hover:bg-avocado-50" :title="m('actions.edit')" @click="openEdit(poster)"><Edit2 class="h-4 w-4" /></button>
                <button class="rounded-xl border border-red-100 p-2 text-red-600 hover:bg-red-50" :title="m('actions.delete')" @click="pendingDeleteId = poster.id"><Trash2 class="h-4 w-4" /></button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="!isLoading && !loadError && paginatedPosters.length" class="grid gap-3 p-4 md:hidden">
        <article v-for="poster in paginatedPosters" :key="poster.id" class="rounded-2xl border border-slate-200 bg-white p-4">
          <div class="flex gap-3">
            <img v-if="poster.imageUrl" :src="resolveBackendAssetUrl(poster.imageUrl)" :alt="poster.altText || poster.title" class="h-20 w-24 rounded-xl object-cover" />
            <div class="min-w-0 flex-1">
              <p class="font-black text-slate-900">{{ poster.title }}</p>
              <p class="mt-1 text-xs text-slate-500">{{ poster.branchKey }}</p>
              <p class="mt-2 text-sm text-slate-600">{{ poster.subtitle || '-' }}</p>
            </div>
          </div>
          <div class="mt-4 flex justify-end gap-2">
            <button class="rounded-lg border border-avocado-200 px-3 py-2 text-xs font-bold text-avocado-700" @click="openEdit(poster)">{{ m('actions.edit') }}</button>
            <button class="rounded-lg border border-red-200 px-3 py-2 text-xs font-bold text-red-600" @click="pendingDeleteId = poster.id">{{ m('actions.delete') }}</button>
          </div>
        </article>
      </div>
    </AdminShellTablePanel>

    <div class="px-5 pb-5">
      <Pagination
        :page="currentPage"
        :total-pages="totalPages"
        :visible-count="paginatedPosters.length"
        :total-count="filteredPosters.length"
        :label="m('paginationLabels.menu')"
        @prev="currentPage = Math.max(1, currentPage - 1)"
        @next="currentPage = Math.min(totalPages, currentPage + 1)"
      />
    </div>
  </AdminShellFrame>

  <BaseModal :show="showModal" :title="mode === 'create' ? m('modals.createPoster') : m('modals.editPoster')" max-width="max-w-3xl" @close="closeModal">
    <form id="menu-poster-form" class="grid gap-5 md:grid-cols-2" @submit.prevent="savePoster">
      <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
        {{ m('fields.branchKey') }}
        <input v-model="form.branchKey" required class="admin-input-premium" :placeholder="m('placeholders.branchKey')" />
      </label>
      <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
        {{ m('fields.menuTitle') }}
        <input v-model="form.title" required class="admin-input-premium" :placeholder="m('placeholders.menuTitle')" />
      </label>
      <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500 md:col-span-2">
        {{ m('fields.menuSubtitle') }}
        <textarea v-model="form.subtitle" rows="3" class="admin-input-premium resize-none" :placeholder="m('placeholders.menuSubtitle')" />
      </label>
      <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
        {{ m('fields.sortOrder') }}
        <input v-model.number="form.sortOrder" type="number" min="0" class="admin-input-premium" />
      </label>
      <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
        {{ m('fields.status') }}
        <select v-model="form.status" class="admin-input-premium cursor-pointer">
          <option v-for="status in statuses" :key="status" :value="status">{{ statusLabels[status] }}</option>
        </select>
      </label>
      <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500 md:col-span-2">
        {{ m('fields.menuImageUrl') }}
        <input v-model="form.imageUrl" class="admin-input-premium" :placeholder="m('placeholders.imageUrl')" />
        <span>{{ m('fields.uploadMenuImage') }}</span>
        <input type="file" accept="image/*" :disabled="isUploading || isSaving" class="w-full text-xs font-bold text-slate-600 file:mr-3 file:rounded-xl file:border-0 file:bg-avocado-600 file:px-4 file:py-2.5 file:font-semibold file:text-white" @change="uploadImage" />
        <span v-if="isUploading" class="text-xs font-bold normal-case text-avocado-700">{{ m('misc.uploadingMenu') }}</span>
        <img v-if="previewUrl" :src="previewUrl" :alt="form.altText || form.title" class="mt-2 h-40 w-full rounded-xl border border-slate-100 object-contain" />
      </label>
      <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500 md:col-span-2">
        {{ m('fields.altText') }}
        <input v-model="form.altText" class="admin-input-premium" :placeholder="m('placeholders.altText')" />
      </label>
    </form>
    <template #footer>
      <div class="flex justify-end gap-3">
        <button type="button" class="rounded-full border border-slate-200 px-5 py-3 text-xs font-bold uppercase tracking-wider text-slate-500" :disabled="isSaving" @click="closeModal">{{ m('actions.cancel') }}</button>
        <button form="menu-poster-form" type="submit" class="rounded-full bg-avocado-600 px-6 py-3 text-xs font-bold uppercase tracking-wider text-white disabled:opacity-60" :disabled="isSaving || isUploading">{{ mode === 'create' ? m('actions.saveCreate') : m('actions.saveUpdate') }}</button>
      </div>
    </template>
  </BaseModal>

  <ConfirmModal
    :show="Boolean(pendingDeleteId)"
    :title="m('confirmDelete.posterTitle')"
    :message="m('confirmDelete.posterMessage')"
    :confirm-text="m('confirmDelete.posterConfirm')"
    @cancel="pendingDeleteId = null"
    @confirm="deletePoster"
  />
</template>
