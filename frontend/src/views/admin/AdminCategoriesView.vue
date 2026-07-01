<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import BaseModal from '../../components/admin/BaseModal.vue'
import AdminListPage from '../../components/admin/AdminListPage.vue'
import AdminNestedShell from '../../components/admin/shell/AdminNestedShell.vue'
import AdminShellFrame from '../../components/admin/shell/AdminShellFrame.vue'
import AdminShellTablePanel from '../../components/admin/shell/AdminShellTablePanel.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import { useAdminModuleI18n } from '../../composables/useAdminModuleI18n'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'
import { adminPaths } from '../../constants/adminPaths'

const { m, t } = useAdminModuleI18n('categories')
const store = useAppStore()
const toast = useToastStore()

const showModal = ref(false)
const mode = ref('create')
const editingId = ref(null)
const pendingDeleteId = ref(null)
const searchQuery = ref('')
const statusFilter = ref(t('admin.shared.all'))
const currentPage = ref(1)
const pageSize = 5
const isLoading = computed(() => store.loading.categories)
const errorMessage = computed(() => store.errors.categories)

const categoryStatuses = ['ACTIVE', 'INACTIVE']
const statusLabels = computed(() => ({
  ACTIVE: m('status.ACTIVE'),
  INACTIVE: m('status.INACTIVE'),
}))
const statusFilters = computed(() => [t('admin.shared.all'), ...categoryStatuses.map((status) => statusLabels.value[status])])

const form = reactive({
  name: '',
  slug: '',
  description: '',
  status: 'ACTIVE',
})

const slugify = (value) =>
  value
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '')

const resetForm = () => {
  Object.assign(form, {
    name: '',
    slug: '',
    description: '',
    status: 'ACTIVE',
  })
  editingId.value = null
}

const statusClass = (status) =>
  status === 'ACTIVE'
    ? 'bg-green-50 text-green-700 border-green-200'
    : 'bg-gray-50 text-gray-700 border-gray-200'

const getStatusValue = (label) =>
  Object.entries(statusLabels.value).find(([, value]) => value === label)?.[0] || label

const openCreateModal = () => {
  mode.value = 'create'
  resetForm()
  showModal.value = true
}

const openEditModal = (category) => {
  mode.value = 'edit'
  editingId.value = category.id
  Object.assign(form, {
    name: category.name,
    slug: category.slug,
    description: category.description || '',
    status: category.status || 'ACTIVE',
  })
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const saveCategory = async () => {
  if (!form.name.trim() || !form.slug.trim()) {
    toast.error(m('toasts.requiredFields'))
    return
  }

  const payload = {
    id: editingId.value,
    name: form.name.trim(),
    slug: form.slug.trim(),
    description: form.description.trim(),
    status: form.status,
  }

  try {
    await store.saveCategory(payload)
    toast.success(mode.value === 'create' ? m('toasts.created') : m('toasts.updated'))
    closeModal()
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.saveError'))
  }
}

const confirmDeleteCategory = async () => {
  try {
    await store.deleteCategory(pendingDeleteId.value)
    toast.success(m('toasts.deleted'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.deleteError'))
  } finally {
    pendingDeleteId.value = null
  }
}

const filteredCategories = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return store.categories
    .filter((category) => category.type === 'ARTICLE')
    .filter((category) => {
      const matchesSearch =
        !keyword ||
        category.name.toLowerCase().includes(keyword) ||
        category.slug.toLowerCase().includes(keyword) ||
        category.description?.toLowerCase().includes(keyword)
      const matchesStatus =
        statusFilter.value === t('admin.shared.all') || category.status === getStatusValue(statusFilter.value)
      return matchesSearch && matchesStatus
    })
    .sort((a, b) => a.name.localeCompare(b.name, 'vi'))
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredCategories.value.length / pageSize)))
const paginatedCategories = computed(() =>
  filteredCategories.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)
const listCountText = computed(() => t('admin.shared.totalCount', { count: filteredCategories.value.length }))

watch(
  () => form.name,
  (name) => {
    if (!form.slug) form.slug = slugify(name)
  },
)

watch([searchQuery, statusFilter], () => {
  currentPage.value = 1
})

onMounted(() => {
  store.fetchCategories().catch(() => {
    toast.error(m('toasts.loadError'))
  })
})
</script>

<template>
  <AdminListPage>
    <RouterLink :to="adminPaths.content.articles" class="inline-block text-sm font-semibold text-avocado-700 hover:text-avocado-900">
      {{ m('backToArticles', { label: t('admin.nav.articles') }) }}
    </RouterLink>

    <AdminNestedShell>
      <AdminShellFrame variant="header" inner="header">
        <AdminPageHeader :title="t('admin.nav.categories')">
          <template #actions>
            <button class="admin-list-btn admin-list-btn--primary" @click="openCreateModal">
              {{ m('add') }}
            </button>
          </template>
        </AdminPageHeader>
      </AdminShellFrame>

      <AdminShellFrame variant="toolbar" inner="toolbar">
        <SearchFilterBar
          v-model:search="searchQuery"
          v-model:status="statusFilter"
          :search-label="m('filters.searchLabel')"
          :search-placeholder="m('filters.searchPlaceholder')"
          :status-label="t('admin.shared.status')"
          :status-options="statusFilters"
        />
      </AdminShellFrame>

      <AdminShellFrame v-if="errorMessage" as="p" variant="alert" class="admin-list-alert">
        {{ errorMessage }}
      </AdminShellFrame>

      <AdminShellFrame v-if="isLoading" variant="body" inner="pad">
        <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
      </AdminShellFrame>

      <AdminShellFrame v-else-if="!filteredCategories.length" variant="body" inner="pad">
        <EmptyState :message="m('empty')" />
      </AdminShellFrame>

      <AdminShellFrame v-else variant="body" visibility="desktop">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <table class="admin-shell-table">
            <colgroup>
              <col style="width: 22%" />
              <col style="width: 20%" />
              <col style="width: 28%" />
              <col style="width: 15%" />
              <col style="width: 15%" />
            </colgroup>
            <thead>
              <tr>
                <th>{{ m('columns.name') }}</th>
                <th>{{ m('columns.slug') }}</th>
                <th>{{ m('columns.description') }}</th>
                <th class="text-center">{{ m('columns.status') }}</th>
                <th class="text-right">{{ m('columns.actions') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="category in paginatedCategories" :key="category.id">
                <td class="font-black text-avocado-950">
                  <span class="block truncate">{{ category.name }}</span>
                </td>
                <td class="admin-shell-cell-truncate admin-shell-cell-muted font-semibold">/{{ category.slug }}</td>
                <td class="admin-shell-cell-truncate admin-shell-cell-muted">{{ category.description || m('noDescription') }}</td>
                <td class="text-center">
                  <span class="inline-flex min-w-[122px] justify-center rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(category.status)">
                    {{ statusLabels[category.status] || category.status }}
                  </span>
                </td>
                <td>
                  <div class="flex justify-end gap-2">
                    <button class="admin-list-btn admin-list-btn--outline shrink-0 !min-h-[32px] !px-2.5 !py-1.5 !text-xs" @click="openEditModal(category)">
                      {{ m('actions.edit') }}
                    </button>
                    <button class="admin-list-btn admin-list-btn--danger shrink-0 !min-h-[32px] !px-2.5 !py-1.5 !text-xs" @click="pendingDeleteId = category.id">
                      {{ m('actions.delete') }}
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="!isLoading && filteredCategories.length" variant="body" visibility="mobile">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <template #below>
            <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack">
              <article v-for="category in paginatedCategories" :key="category.id" class="admin-shell-mobile-card">
                <div class="flex items-start justify-between gap-3">
                  <div class="min-w-0">
                    <h3 class="truncate font-black text-avocado-950">{{ category.name }}</h3>
                    <p class="mt-1 truncate text-xs font-semibold text-slate-500">/{{ category.slug }}</p>
                  </div>
                  <span class="shrink-0 rounded-full border px-3 py-1.5 text-xs font-black" :class="statusClass(category.status)">
                    {{ statusLabels[category.status] || category.status }}
                  </span>
                </div>
                <p class="mt-3 text-sm text-slate-600">{{ category.description || m('noDescription') }}</p>
                <div class="mt-4 flex flex-wrap gap-2">
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 text-xs font-bold text-avocado-700" @click="openEditModal(category)">
                    {{ m('actions.edit') }}
                  </button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 text-xs font-bold text-red-600" @click="pendingDeleteId = category.id">
                    {{ m('actions.delete') }}
                  </button>
                </div>
              </article>
            </div>
          </template>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="filteredCategories.length" variant="footer">
        <Pagination
          :page="currentPage"
          :total-pages="totalPages"
          :visible-count="paginatedCategories.length"
          :total-count="filteredCategories.length"
          :label="m('paginationLabel')"
          @prev="currentPage = Math.max(1, currentPage - 1)"
          @next="currentPage = Math.min(totalPages, currentPage + 1)"
        />
      </AdminShellFrame>
    </AdminNestedShell>

    <BaseModal :show="showModal" :title="mode === 'create' ? m('modals.create') : m('modals.edit')" max-width="max-w-2xl" @close="closeModal">
      <form id="category-form" class="grid gap-5 md:grid-cols-2" @submit.prevent="saveCategory">
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ m('fields.name') }}
          <input v-model="form.name" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ m('fields.slug') }}
          <input v-model="form.slug" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ m('fields.status') }}
          <select v-model="form.status" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500">
            <option v-for="status in categoryStatuses" :key="status" :value="status">{{ statusLabels[status] }}</option>
          </select>
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
          {{ m('fields.description') }}
          <textarea v-model="form.description" rows="3" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
        </label>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-lg border border-slate-200 px-4 py-3 font-bold text-slate-600 hover:bg-slate-50" @click="closeModal">
            {{ m('actions.cancel') }}
          </button>
          <button class="rounded-lg bg-brand-forest px-4 py-3 font-black text-white hover:bg-avocado-800" form="category-form" type="submit">
            {{ mode === 'create' ? m('actions.saveCreate') : m('actions.saveUpdate') }}
          </button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal :show="Boolean(pendingDeleteId)" @cancel="pendingDeleteId = null" @confirm="confirmDeleteCategory" />
  </AdminListPage>
</template>
