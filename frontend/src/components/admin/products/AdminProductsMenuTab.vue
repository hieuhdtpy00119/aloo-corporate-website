<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import BaseModal from '../BaseModal.vue'
import ConfirmModal from '../ConfirmModal.vue'
import EmptyState from '../EmptyState.vue'
import Pagination from '../Pagination.vue'
import SearchFilterBar from '../SearchFilterBar.vue'
import { menuPosterService, normalizeStorageAssetUrl, resolveBackendAssetUrl, uploadService } from '../../../services/cmsService'
import { useAdminModuleI18n } from '../../../composables/useAdminModuleI18n'
import { useToastStore } from '../../../stores/toastStore'
import { Edit2, Trash2, Image, Link } from 'lucide-vue-next'

const { m, t } = useAdminModuleI18n('products')
const toast = useToastStore()

const showPosterModal = ref(false)
const posterMode = ref('create')
const editingPosterId = ref(null)
const pendingDeletePosterId = ref(null)
const posterSearchQuery = ref('')
const posterStatusFilter = ref(t('admin.shared.all'))
const posterCurrentPage = ref(1)
const isLoadingMenuPosters = ref(false)
const menuPosterError = ref('')
const isUploadingPosterImage = ref(false)
const menuPosters = ref([])
const pageSize = 6

const productStatuses = ['ACTIVE', 'INACTIVE']
const statusLabels = computed(() => ({
  ACTIVE: m('status.ACTIVE'),
  INACTIVE: m('status.INACTIVE'),
}))
const heroStatusLabels = computed(() => ({
  ACTIVE: m('status.visible'),
  INACTIVE: m('status.INACTIVE'),
}))
const posterStatusFilters = computed(() => [t('admin.shared.all'), ...productStatuses.map((status) => heroStatusLabels.value[status])])

const posterForm = reactive({
  branchKey: '',
  title: '',
  subtitle: '',
  imageUrl: '',
  altText: '',
  sortOrder: 0,
  status: 'ACTIVE',
})

const normalizeMenuPoster = (poster) => ({
  ...poster,
  branchKey: poster.branchKey || '',
  title: poster.title || '',
  subtitle: poster.subtitle || '',
  imageUrl: normalizeStorageAssetUrl(poster.imageUrl || ''),
  altText: poster.altText || '',
  sortOrder: Number(poster.sortOrder || 0),
  status: poster.status || 'ACTIVE',
})

const posterImagePreviewUrl = computed(() => resolveBackendAssetUrl(posterForm.imageUrl || ''))

const resetPosterForm = () => {
  Object.assign(posterForm, {
    branchKey: '',
    title: '',
    subtitle: '',
    imageUrl: '',
    altText: '',
    sortOrder: 0,
    status: 'ACTIVE',
  })
  editingPosterId.value = null
}

const openCreatePosterModal = () => {
  posterMode.value = 'create'
  resetPosterForm()
  showPosterModal.value = true
}

const openEditPosterModal = (poster) => {
  posterMode.value = 'edit'
  editingPosterId.value = poster.id
  Object.assign(posterForm, {
    branchKey: poster.branchKey || '',
    title: poster.title || '',
    subtitle: poster.subtitle || '',
    imageUrl: poster.imageUrl || '',
    altText: poster.altText || '',
    sortOrder: Number(poster.sortOrder || 0),
    status: poster.status || 'ACTIVE',
  })
  showPosterModal.value = true
}

const closePosterModal = () => {
  showPosterModal.value = false
  resetPosterForm()
}

const handlePosterImageFileChange = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  isUploadingPosterImage.value = true
  try {
    const { data } = await uploadService.image(file)
    posterForm.imageUrl = normalizeStorageAssetUrl(data.url)
    toast.success(m('toasts.menuImageUploaded'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.menuImageError'))
  } finally {
    isUploadingPosterImage.value = false
    event.target.value = ''
  }
}

const statusClass = (status) =>
  status === 'ACTIVE'
    ? 'border-emerald-200 bg-emerald-50 text-emerald-700'
    : 'border-slate-200 bg-slate-50 text-slate-500'

const getStatusValue = (label) =>
  [...Object.entries(statusLabels.value), ...Object.entries(heroStatusLabels.value)].find(([, value]) => value === label)?.[0] || label

const filteredMenuPosters = computed(() => {
  const keyword = posterSearchQuery.value.trim().toLowerCase()
  return menuPosters.value.filter((poster) => {
    const haystack = [poster.title, poster.subtitle, poster.branchKey, poster.altText]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
    const matchesSearch = !keyword || haystack.includes(keyword)
    const matchesStatus = posterStatusFilter.value === t('admin.shared.all') || poster.status === getStatusValue(posterStatusFilter.value)
    return matchesSearch && matchesStatus
  })
})

const totalPosterPages = computed(() => Math.max(1, Math.ceil(filteredMenuPosters.value.length / pageSize)))
const paginatedMenuPosters = computed(() =>
  filteredMenuPosters.value.slice((posterCurrentPage.value - 1) * pageSize, posterCurrentPage.value * pageSize),
)

const fetchMenuPosters = async () => {
  isLoadingMenuPosters.value = true
  menuPosterError.value = ''
  try {
    const { data } = await menuPosterService.list()
    menuPosters.value = Array.isArray(data) ? data.map(normalizeMenuPoster) : []
  } catch (error) {
    menuPosterError.value = error.response?.data?.message || m('uploadErrors.menuLoadFailed')
    throw error
  } finally {
    isLoadingMenuPosters.value = false
  }
}

const saveMenuPoster = async () => {
  if (!posterForm.branchKey.trim() || !posterForm.title.trim()) {
    toast.error(m('toasts.posterFieldsRequired'))
    return
  }

  const payload = {
    branchKey: posterForm.branchKey.trim(),
    title: posterForm.title.trim(),
    subtitle: posterForm.subtitle.trim(),
    imageUrl: normalizeStorageAssetUrl(posterForm.imageUrl),
    altText: posterForm.altText.trim() || posterForm.title.trim(),
    sortOrder: Number(posterForm.sortOrder || 0),
    status: posterForm.status || 'ACTIVE',
  }

  try {
    const request = editingPosterId.value
      ? menuPosterService.update(editingPosterId.value, payload)
      : menuPosterService.create(payload)
    const { data } = await request
    const normalized = normalizeMenuPoster(data)
    const index = menuPosters.value.findIndex((item) => item.id === normalized.id)
    if (index === -1) menuPosters.value.unshift(normalized)
    else menuPosters.value.splice(index, 1, normalized)
    toast.success(posterMode.value === 'create' ? m('toasts.posterCreated') : m('toasts.posterUpdated'))
    closePosterModal()
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.posterSaveError'))
  }
}

const confirmDeleteMenuPoster = async () => {
  try {
    await menuPosterService.remove(pendingDeletePosterId.value)
    menuPosters.value = menuPosters.value.filter((item) => item.id !== pendingDeletePosterId.value)
    toast.success(m('toasts.posterDeleted'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.posterDeleteError'))
  } finally {
    pendingDeletePosterId.value = null
  }
}

watch([posterSearchQuery, posterStatusFilter], () => {
  posterCurrentPage.value = 1
})

onMounted(() => {
  fetchMenuPosters().catch(() => {
    toast.error(m('toasts.partialLoadError'))
  })
})

defineExpose({ openCreate: openCreatePosterModal })
</script>

<template>
  <div class="space-y-6">
    <SearchFilterBar
      v-model:search="posterSearchQuery"
      v-model:status="posterStatusFilter"
      :search-label="m('filters.menuSearchLabel')"
      :search-placeholder="m('filters.menuSearchPlaceholder')"
      :status-label="m('filters.menuStatusLabel')"
      :status-options="posterStatusFilters"
    />

    <p v-if="menuPosterError" class="rounded-2xl bg-red-50 border border-red-200/50 px-4 py-3 text-xs font-bold text-red-700">
      {{ menuPosterError }}
    </p>

    <div class="overflow-hidden rounded-3xl border border-slate-100 bg-white shadow-sm">
      <div class="overflow-x-auto">
        <table v-if="!isLoadingMenuPosters && filteredMenuPosters.length" class="w-full min-w-[920px] table-fixed whitespace-nowrap text-left">
          <colgroup>
            <col class="w-[10%]" />
            <col class="w-[25%]" />
            <col class="w-[18%]" />
            <col class="w-[24%]" />
            <col class="w-[11%]" />
            <col class="w-[12%]" />
          </colgroup>
          <thead class="bg-slate-50/50 border-b border-slate-100 text-[10px] font-bold uppercase tracking-wider text-slate-400">
            <tr>
              <th class="px-6 py-4">{{ m('columns.menu.image') }}</th>
              <th class="px-6 py-4">{{ m('columns.menu.menu') }}</th>
              <th class="px-6 py-4">{{ m('columns.menu.branch') }}</th>
              <th class="px-6 py-4">{{ m('columns.menu.description') }}</th>
              <th class="px-6 py-4">{{ m('columns.menu.status') }}</th>
              <th class="px-6 py-4 text-right">{{ m('columns.menu.actions') }}</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-50 text-xs">
            <tr v-for="poster in paginatedMenuPosters" :key="poster.id" class="hover:bg-slate-50/30 transition">
              <td class="px-6 py-4">
                <img
                  v-if="poster.imageUrl"
                  :src="resolveBackendAssetUrl(poster.imageUrl)"
                  :alt="poster.altText || poster.title"
                  class="h-14 w-12 rounded-xl object-cover border border-slate-100 shadow-sm"
                />
                <div v-else class="grid h-14 w-12 place-items-center rounded-xl bg-slate-50 border border-slate-100 text-[9px] font-bold text-slate-400">
                  <Image class="h-4 w-4" />
                </div>
              </td>
              <td class="px-6 py-4">
                <p class="truncate font-bold text-xs text-avocado-950">{{ poster.title }}</p>
                <p class="mt-1 truncate text-[10px] text-slate-400">{{ m('misc.sortOrder', { order: poster.sortOrder }) }}</p>
              </td>
              <td class="truncate px-6 py-4 font-semibold text-slate-500">{{ poster.branchKey }}</td>
              <td class="px-6 py-4">
                <p class="truncate text-slate-500">{{ poster.subtitle || poster.altText || m('misc.noDescription') }}</p>
              </td>
              <td class="px-6 py-4">
                <span class="inline-flex min-w-[92px] justify-center rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(poster.status)">
                  {{ statusLabels[poster.status] || poster.status }}
                </span>
              </td>
              <td class="px-6 py-4">
                <div class="flex justify-end gap-1.5">
                  <button
                    class="rounded-xl border border-avocado-100/50 p-2 font-bold text-avocado-700 hover:bg-avocado-50/50 transition"
                    :title="m('actions.edit')"
                    @click="openEditPosterModal(poster)"
                  >
                    <Edit2 class="h-3.5 w-3.5" />
                  </button>
                  <button
                    class="rounded-xl border border-red-100 p-2 font-bold text-red-600 hover:bg-red-50 transition"
                    :title="m('actions.delete')"
                    @click="pendingDeletePosterId = poster.id"
                  >
                    <Trash2 class="h-3.5 w-3.5" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <EmptyState v-if="isLoadingMenuPosters || filteredMenuPosters.length === 0" :loading="isLoadingMenuPosters" :message="m('emptyMenu')" />
    </div>

    <Pagination
      :page="posterCurrentPage"
      :total-pages="totalPosterPages"
      :visible-count="paginatedMenuPosters.length"
      :total-count="filteredMenuPosters.length"
      :label="m('paginationLabels.menu')"
      @prev="posterCurrentPage = Math.max(1, posterCurrentPage - 1)"
      @next="posterCurrentPage = Math.min(totalPosterPages, posterCurrentPage + 1)"
    />

    <BaseModal :show="showPosterModal" :title="posterMode === 'create' ? m('modals.createPoster') : m('modals.editPoster')" max-width="max-w-2xl" @close="closePosterModal">
      <form id="poster-form" class="grid gap-5" @submit.prevent="saveMenuPoster">
        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.branchKey') }}
            <input v-model="posterForm.branchKey" required class="admin-input-premium" :placeholder="m('placeholders.branchKey')" />
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.menuTitle') }}
            <input v-model="posterForm.title" required class="admin-input-premium" :placeholder="m('placeholders.menuTitle')" />
          </label>
        </div>

        <div class="grid gap-5 md:grid-cols-3">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500 md:col-span-2">
            {{ m('fields.menuSubtitle') }}
            <input v-model="posterForm.subtitle" class="admin-input-premium" :placeholder="m('placeholders.menuSubtitle')" />
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.sortOrder') }}
            <input v-model.number="posterForm.sortOrder" type="number" min="0" class="admin-input-premium" />
          </label>
        </div>

        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.status') }}
            <select v-model="posterForm.status" class="admin-input-premium cursor-pointer">
              <option v-for="status in productStatuses" :key="status" :value="status">{{ statusLabels[status] }}</option>
            </select>
          </label>
          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            {{ m('fields.altText') }}
            <input v-model="posterForm.altText" class="admin-input-premium" :placeholder="m('placeholders.altText')" />
          </label>
        </div>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          {{ m('fields.menuImageUrl') }}
          <div class="relative">
            <Link class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 h-4.5 w-4.5" />
            <input v-model="posterForm.imageUrl" class="admin-input-premium admin-input-with-icon" :placeholder="m('placeholders.imageUrl')" />
          </div>
        </label>

        <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
          {{ m('fields.uploadMenuImage') }}
          <input
            type="file"
            accept=".jpg,.jpeg,.jfif,.png,.webp,.gif,image/jpeg,image/png,image/webp,image/gif"
            class="w-full text-xs font-bold text-slate-600 file:mr-4 file:rounded-xl file:border-0 file:bg-avocado-600 file:px-4 file:py-2.5 file:font-semibold file:text-white file:cursor-pointer hover:file:bg-avocado-700 transition"
            :disabled="isUploadingPosterImage"
            @change="handlePosterImageFileChange"
          />
          <span v-if="isUploadingPosterImage" class="text-xs font-bold text-avocado-700 animate-pulse">{{ m('misc.uploadingMenu') }}</span>
        </label>

        <div v-if="posterImagePreviewUrl" class="rounded-2xl border border-slate-100 bg-slate-50/50 p-4">
          <p class="mb-2 text-xs font-bold uppercase tracking-wider text-slate-400">{{ m('misc.menuPreview') }}</p>
          <img :src="posterImagePreviewUrl" :alt="m('misc.menuPreview')" class="h-44 w-32 rounded-xl border border-slate-100 object-cover shadow-sm" />
        </div>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3 pt-3 border-t border-slate-100">
          <button class="rounded-full border border-slate-200 px-5 py-3 text-xs font-bold uppercase tracking-wider text-slate-500 hover:bg-slate-50 transition" @click="closePosterModal">{{ m('actions.cancel') }}</button>
          <button
            class="rounded-full bg-avocado-600 px-6 py-3 text-xs font-bold uppercase tracking-wider text-white hover:bg-avocado-700 disabled:cursor-not-allowed disabled:opacity-60 transition shadow-md"
            form="poster-form"
            type="submit"
            :disabled="isUploadingPosterImage"
          >
            {{ posterMode === 'create' ? m('addPoster') : m('actions.saveUpdate') }}
          </button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal :show="Boolean(pendingDeletePosterId)" @cancel="pendingDeletePosterId = null" @confirm="confirmDeleteMenuPoster" />
  </div>
</template>

<style scoped>
.admin-input-premium {
  width: 100%;
  border-radius: 1rem;
  border: 1px solid rgb(241, 245, 249);
  background: rgb(248, 250, 252, 0.5);
  padding: 0.75rem 1rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: rgb(30, 41, 59);
  outline: none;
  transition: all 0.2s;
}

.admin-input-premium:focus {
  background: white;
  border-color: rgb(126, 199, 90);
  box-shadow: 0 0 0 3px rgba(112, 149, 107, 0.1);
}

.admin-input-with-icon {
  padding-left: 2.75rem;
}
</style>
