<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { Edit3, Plus, Trash2 } from 'lucide-vue-next'
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
import { brandTimelineService, resolveBackendAssetUrl } from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'

const { m, t } = useAdminModuleI18n('brandTimeline')
const toast = useToastStore()
const items = ref([])
const isLoading = ref(false)
const errorMessage = ref('')
const searchQuery = ref('')
const statusFilter = ref('ALL')
const showModal = ref(false)
const editingId = ref(null)
const isSaving = ref(false)
const pendingDeleteId = ref(null)
const currentPage = ref(1)
const pageSize = 8

const form = reactive({
  year: '',
  title: '',
  description: '',
  imageUrl: '',
  sortOrder: 0,
  status: 'ACTIVE',
})

const filteredItems = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return items.value.filter((item) => {
    const matchesKeyword =
      !keyword ||
      [item.year, item.title, item.description].filter(Boolean).join(' ').toLowerCase().includes(keyword)
    const matchesStatus =
      statusFilter.value === 'ALL' || String(item.status || '').toUpperCase() === statusFilter.value
    return matchesKeyword && matchesStatus
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredItems.value.length / pageSize)))
const paginatedItems = computed(() =>
  filteredItems.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)
const listCountText = computed(() => t('admin.shared.totalCount', { count: filteredItems.value.length }))

const resetForm = () => {
  Object.assign(form, {
    year: '',
    title: '',
    description: '',
    imageUrl: '',
    sortOrder: 0,
    status: 'ACTIVE',
  })
  editingId.value = null
}

const loadItems = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const { data } = await brandTimelineService.list(false)
    items.value = Array.isArray(data) ? data : []
  } catch (error) {
    errorMessage.value = error.response?.data?.message || m('toasts.loadError')
  } finally {
    isLoading.value = false
  }
}

const openCreateModal = () => {
  resetForm()
  showModal.value = true
}

const openEditModal = (item) => {
  editingId.value = item.id
  Object.assign(form, {
    year: item.year || '',
    title: item.title || '',
    description: item.description || '',
    imageUrl: item.imageUrl || '',
    sortOrder: Number(item.sortOrder || 0),
    status: String(item.status || 'ACTIVE').toUpperCase(),
  })
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const buildPayload = () => ({
  year: form.year.trim(),
  title: form.title.trim(),
  description: form.description.trim(),
  imageUrl: form.imageUrl.trim(),
  sortOrder: Number(form.sortOrder || 0),
  status: form.status,
})

const saveItem = async () => {
  if (isSaving.value) return
  if (!form.year.trim() || !form.title.trim()) {
    toast.error(m('toasts.requiredFields'))
    return
  }
  isSaving.value = true
  try {
    const payload = buildPayload()
    const { data } = editingId.value
      ? await brandTimelineService.update(editingId.value, payload)
      : await brandTimelineService.create(payload)
    const index = items.value.findIndex((entry) => entry.id === data.id)
    if (index === -1) items.value.unshift(data)
    else items.value.splice(index, 1, data)
    toast.success(editingId.value ? m('toasts.updated') : m('toasts.created'))
    closeModal()
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.saveError'))
  } finally {
    isSaving.value = false
  }
}

const confirmDelete = async () => {
  try {
    await brandTimelineService.remove(pendingDeleteId.value)
    items.value = items.value.filter((item) => item.id !== pendingDeleteId.value)
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

onMounted(loadItems)
</script>

<template>
  <AdminListPage>
    <AdminNestedShell>
      <AdminShellFrame variant="header" inner="header">
        <AdminPageHeader :title="m('title')">
          <template #actions>
            <button class="admin-list-btn admin-list-btn--primary" @click="openCreateModal">
              <Plus class="h-4 w-4" />
              {{ m('add') }}
            </button>
          </template>
        </AdminPageHeader>
      </AdminShellFrame>

      <AdminShellFrame variant="toolbar" inner="toolbar" padded>
        <section class="aloo-admin-toolbar md:!grid-cols-[1fr_180px]">
          <input v-model="searchQuery" class="aloo-input" :placeholder="m('searchPlaceholder')" />
          <select v-model="statusFilter" class="aloo-select">
            <option value="ALL">{{ m('filters.all') }}</option>
            <option value="ACTIVE">{{ m('filters.active') }}</option>
            <option value="INACTIVE">{{ m('filters.inactive') }}</option>
          </select>
        </section>
      </AdminShellFrame>

      <AdminShellFrame v-if="errorMessage" as="p" variant="alert" class="admin-list-alert">
        {{ errorMessage }}
      </AdminShellFrame>

      <AdminShellFrame v-if="isLoading" variant="body" inner="pad">
        <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
      </AdminShellFrame>

      <AdminShellFrame v-else-if="!filteredItems.length" variant="body" inner="pad">
        <EmptyState :title="m('empty')" />
      </AdminShellFrame>

      <AdminShellFrame v-else variant="body" visibility="desktop">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <table class="admin-shell-table">
            <thead>
              <tr>
                <th>{{ m('columns.year') }}</th>
                <th>{{ m('columns.title') }}</th>
                <th>{{ m('columns.status') }}</th>
                <th>{{ m('columns.sortOrder') }}</th>
                <th>{{ m('columns.actions') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in paginatedItems" :key="item.id">
                <td class="font-black text-avocado-950">{{ item.year }}</td>
                <td>
                  <div class="flex items-center gap-3">
                    <img
                      v-if="item.imageUrl"
                      :src="resolveBackendAssetUrl(item.imageUrl)"
                      :alt="item.title"
                      class="h-11 w-11 rounded-xl object-cover"
                    />
                    <div class="min-w-0">
                      <p class="truncate font-black text-avocado-950">{{ item.title }}</p>
                      <p class="line-clamp-1 text-xs font-bold text-slate-500">{{ item.description }}</p>
                    </div>
                  </div>
                </td>
                <td>
                  <span
                    class="rounded-full border px-3 py-1 text-xs font-black"
                    :class="String(item.status).toUpperCase() === 'ACTIVE'
                      ? 'border-emerald-200 bg-emerald-50 text-emerald-700'
                      : 'border-slate-200 bg-slate-50 text-slate-500'"
                  >
                    {{ String(item.status).toUpperCase() === 'ACTIVE' ? m('filters.active') : m('filters.inactive') }}
                  </span>
                </td>
                <td class="admin-shell-cell-strong">{{ item.sortOrder }}</td>
                <td>
                  <div class="flex gap-2">
                    <button class="rounded-lg border border-avocado-200 p-2 text-avocado-700 hover:bg-avocado-50" :title="m('actions.edit')" @click="openEditModal(item)">
                      <Edit3 class="h-4 w-4" />
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

      <AdminShellFrame v-if="!isLoading && filteredItems.length" variant="body" visibility="mobile">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <template #below>
            <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack">
              <article v-for="item in paginatedItems" :key="item.id" class="admin-shell-mobile-card">
                <div class="flex items-start justify-between gap-3">
                  <div class="min-w-0">
                    <p class="text-xs font-black text-avocado-700">{{ item.year }}</p>
                    <h2 class="truncate font-black text-avocado-950">{{ item.title }}</h2>
                  </div>
                  <span class="rounded-full border px-3 py-1 text-xs font-black" :class="String(item.status).toUpperCase() === 'ACTIVE' ? 'border-emerald-200 bg-emerald-50 text-emerald-700' : 'border-slate-200 bg-slate-50 text-slate-500'">
                    {{ String(item.status).toUpperCase() === 'ACTIVE' ? m('filters.active') : m('filters.inactive') }}
                  </span>
                </div>
                <p class="mt-3 line-clamp-2 text-sm text-slate-600">{{ item.description }}</p>
                <div class="mt-4 flex gap-2">
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 text-xs font-bold text-avocado-700" @click="openEditModal(item)">{{ m('actions.edit') }}</button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 text-xs font-bold text-red-600" @click="pendingDeleteId = item.id">{{ m('actions.delete') }}</button>
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
          @prev="currentPage--"
          @next="currentPage++"
        />
      </AdminShellFrame>
    </AdminNestedShell>

    <BaseModal :show="showModal" :title="editingId ? m('edit') : m('create')" max-width="max-w-3xl" @close="closeModal">
      <form class="grid gap-4 md:grid-cols-2" @submit.prevent="saveItem">
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">{{ m('fields.year') }}</span>
          <input v-model="form.year" required class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">{{ m('fields.sortOrder') }}</span>
          <input v-model.number="form.sortOrder" type="number" min="0" class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 md:col-span-2">
          <span class="text-xs font-black uppercase text-slate-500">{{ m('fields.title') }}</span>
          <input v-model="form.title" required class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 md:col-span-2">
          <span class="text-xs font-black uppercase text-slate-500">{{ m('fields.description') }}</span>
          <textarea v-model="form.description" rows="4" class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 md:col-span-2">
          <span class="text-xs font-black uppercase text-slate-500">{{ m('fields.imageUrl') }}</span>
          <input v-model="form.imageUrl" class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">{{ m('fields.status') }}</span>
          <select v-model="form.status" class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500">
            <option value="ACTIVE">{{ m('filters.active') }}</option>
            <option value="INACTIVE">{{ m('filters.inactive') }}</option>
          </select>
        </label>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-xl border border-slate-200 px-5 py-3 text-sm font-bold text-slate-600" @click="closeModal">{{ m('actions.cancel') }}</button>
          <button type="button" class="rounded-xl bg-avocado-800 px-5 py-3 text-sm font-black text-white disabled:cursor-not-allowed disabled:opacity-60" :disabled="isSaving" @click="saveItem">{{ m('actions.save') }}</button>
        </div>
      </template>
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
