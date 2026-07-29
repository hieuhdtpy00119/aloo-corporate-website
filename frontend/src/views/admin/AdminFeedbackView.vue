<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { Edit3, Eye, EyeOff, Plus, Trash2 } from 'lucide-vue-next'
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
import { feedbackService, resolveBackendAssetUrl } from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'

const { m, t } = useAdminModuleI18n('feedbacks')
const toast = useToastStore()
const testimonials = ref([])
const isLoading = ref(false)
const errorMessage = ref('')
const searchQuery = ref('')
const visibleFilter = ref('ALL')
const showModal = ref(false)
const editingId = ref(null)
const isSaving = ref(false)
const isTogglingVisible = ref(false)
const pendingDeleteId = ref(null)
const currentPage = ref(1)
const pageSize = 8

const form = reactive({
  customerName: '',
  avatarUrl: '',
  content: '',
  rating: 5,
  storeName: '',
  visible: true,
  sortOrder: 0,
})

const filteredTestimonials = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return testimonials.value.filter((item) => {
    const matchesKeyword = !keyword || [item.customerName, item.storeName, item.content]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
      .includes(keyword)
    const matchesVisible =
      visibleFilter.value === 'ALL' ||
      (visibleFilter.value === 'VISIBLE' && item.visible) ||
      (visibleFilter.value === 'HIDDEN' && !item.visible)
    return matchesKeyword && matchesVisible
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredTestimonials.value.length / pageSize)))
const paginatedTestimonials = computed(() =>
  filteredTestimonials.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)
const listCountText = computed(() => t('admin.shared.totalCount', { count: filteredTestimonials.value.length }))

const resetForm = () => {
  Object.assign(form, {
    customerName: '',
    avatarUrl: '',
    content: '',
    rating: 5,
    storeName: '',
    visible: true,
    sortOrder: 0,
  })
  editingId.value = null
}

const loadTestimonials = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const { data } = await feedbackService.adminList()
    testimonials.value = Array.isArray(data) ? data : []
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
    customerName: item.customerName || '',
    avatarUrl: item.avatarUrl || '',
    content: item.content || '',
    rating: Number(item.rating || 5),
    storeName: item.storeName || '',
    visible: item.visible !== false,
    sortOrder: Number(item.sortOrder || 0),
  })
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const buildPayload = () => ({
  customerName: form.customerName.trim(),
  avatarUrl: form.avatarUrl.trim(),
  content: form.content.trim(),
  rating: Number(form.rating || 5),
  storeName: form.storeName.trim(),
  visible: Boolean(form.visible),
  sortOrder: Number(form.sortOrder || 0),
})

const saveTestimonial = async () => {
  if (isSaving.value) return
  if (!form.customerName.trim() || !form.content.trim()) {
    toast.error(m('toasts.requiredFields'))
    return
  }
  isSaving.value = true
  try {
    const payload = buildPayload()
    const { data } = editingId.value
      ? await feedbackService.update(editingId.value, payload)
      : await feedbackService.create(payload)
    const index = testimonials.value.findIndex((item) => item.id === data.id)
    if (index === -1) testimonials.value.unshift(data)
    else testimonials.value.splice(index, 1, data)
    toast.success(editingId.value ? m('toasts.updated') : m('toasts.created'))
    closeModal()
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.saveError'))
  } finally {
    isSaving.value = false
  }
}

const toggleVisible = async (item) => {
  if (isTogglingVisible.value) return
  isTogglingVisible.value = true
  try {
    const { data } = await feedbackService.updateVisible(item.id, !item.visible)
    const index = testimonials.value.findIndex((entry) => entry.id === data.id)
    if (index !== -1) testimonials.value.splice(index, 1, data)
    toast.success(data.visible ? m('toasts.visibilityOn') : m('toasts.visibilityOff'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.visibilityError'))
  } finally {
    isTogglingVisible.value = false
  }
}

const confirmDelete = async () => {
  try {
    await feedbackService.remove(pendingDeleteId.value)
    testimonials.value = testimonials.value.filter((item) => item.id !== pendingDeleteId.value)
    toast.success(m('toasts.deleted'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.deleteError'))
  } finally {
    pendingDeleteId.value = null
  }
}

watch([searchQuery, visibleFilter], () => {
  currentPage.value = 1
})

watch(totalPages, (value) => {
  currentPage.value = Math.min(currentPage.value, value)
})

onMounted(loadTestimonials)
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
          <select v-model="visibleFilter" class="aloo-select">
            <option value="ALL">{{ m('filters.all') }}</option>
            <option value="VISIBLE">{{ m('filters.visible') }}</option>
            <option value="HIDDEN">{{ m('filters.hidden') }}</option>
          </select>
        </section>
      </AdminShellFrame>

      <AdminShellFrame v-if="errorMessage" as="p" variant="alert" class="admin-list-alert">
        {{ errorMessage }}
      </AdminShellFrame>

      <AdminShellFrame v-if="isLoading" variant="body" inner="pad">
        <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
      </AdminShellFrame>

      <AdminShellFrame v-else-if="!filteredTestimonials.length" variant="body" inner="pad">
        <EmptyState :title="m('empty')" />
      </AdminShellFrame>

      <AdminShellFrame v-else variant="body" visibility="desktop">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <table class="admin-shell-table">
            <colgroup>
              <col style="width: 28%" />
              <col style="width: 28%" />
              <col style="width: 10%" />
              <col style="width: 12%" />
              <col style="width: 10%" />
              <col style="width: 12%" />
            </colgroup>
            <thead>
              <tr>
                <th>{{ m('columns.customer') }}</th>
                <th>{{ m('columns.content') }}</th>
                <th>{{ m('columns.rating') }}</th>
                <th>{{ m('columns.visible') }}</th>
                <th>{{ m('columns.sortOrder') }}</th>
                <th>{{ m('columns.actions') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in paginatedTestimonials" :key="item.id">
                <td>
                  <div class="flex items-center gap-3">
                    <img v-if="item.avatarUrl" :src="resolveBackendAssetUrl(item.avatarUrl)" :alt="item.customerName" class="h-11 w-11 rounded-full object-cover" />
                    <div v-else class="grid h-11 w-11 place-items-center rounded-full bg-avocado-50 font-black text-avocado-800">{{ item.customerName?.charAt(0) || 'A' }}</div>
                    <div class="min-w-0">
                      <p class="truncate font-black text-avocado-950">{{ item.customerName }}</p>
                      <p class="text-xs font-bold text-slate-500">{{ item.storeName || 'ALOO' }}</p>
                    </div>
                  </div>
                </td>
                <td class="admin-shell-cell-muted admin-shell-cell-truncate">{{ item.content }}</td>
                <td class="font-black text-amber-500">{{ item.rating }}/5</td>
                <td>
                  <span class="rounded-full border px-3 py-1 text-xs font-black" :class="item.visible ? 'border-emerald-200 bg-emerald-50 text-emerald-700' : 'border-slate-200 bg-slate-50 text-slate-500'">
                    {{ item.visible ? m('visible') : m('hidden') }}
                  </span>
                </td>
                <td class="admin-shell-cell-strong">{{ item.sortOrder }}</td>
                <td>
                  <div class="flex gap-2">
                    <button class="rounded-lg border border-slate-200 p-2 text-slate-700 hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isTogglingVisible" :title="m('actions.toggleVisible')" @click="toggleVisible(item)">
                      <Eye v-if="!item.visible" class="h-4 w-4" />
                      <EyeOff v-else class="h-4 w-4" />
                    </button>
                    <button class="rounded-lg border border-avocado-200 p-2 text-avocado-700 hover:bg-avocado-50" :title="m('actions.edit')" @click="openEditModal(item)"><Edit3 class="h-4 w-4" /></button>
                    <button class="rounded-lg border border-red-200 p-2 text-red-600 hover:bg-red-50" :title="m('actions.delete')" @click="pendingDeleteId = item.id"><Trash2 class="h-4 w-4" /></button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="!isLoading && filteredTestimonials.length" variant="body" visibility="mobile">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <template #below>
            <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack">
              <article v-for="item in paginatedTestimonials" :key="item.id" class="admin-shell-mobile-card">
                <div class="flex items-start justify-between gap-3">
                  <div class="min-w-0">
                    <h2 class="truncate font-black text-avocado-950">{{ item.customerName }}</h2>
                    <p class="text-xs font-bold text-slate-500">{{ item.storeName || 'ALOO' }} · {{ item.rating }}/5</p>
                  </div>
                  <span class="rounded-full border px-3 py-1 text-xs font-black" :class="item.visible ? 'border-emerald-200 bg-emerald-50 text-emerald-700' : 'border-slate-200 bg-slate-50 text-slate-500'">{{ item.visible ? m('visible') : m('hidden') }}</span>
                </div>
                <p class="mt-3 line-clamp-3 text-sm leading-6 text-slate-600">{{ item.content }}</p>
                <div class="mt-4 flex gap-2">
                  <button class="rounded-lg border border-slate-200 px-3 py-2 text-xs font-bold text-slate-700 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isTogglingVisible" @click="toggleVisible(item)">{{ m('actions.toggleVisible') }}</button>
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 text-xs font-bold text-avocado-700" @click="openEditModal(item)">{{ m('actions.edit') }}</button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 text-xs font-bold text-red-600" @click="pendingDeleteId = item.id">{{ m('actions.delete') }}</button>
                </div>
              </article>
            </div>
          </template>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="filteredTestimonials.length" variant="footer">
        <Pagination v-if="filteredTestimonials.length" :page="currentPage" :total-pages="totalPages" :visible-count="paginatedTestimonials.length" :total-count="filteredTestimonials.length" :label="m('paginationLabel')" @prev="currentPage--" @next="currentPage++" />
      </AdminShellFrame>
    </AdminNestedShell>

    <BaseModal :show="showModal" :title="editingId ? m('edit') : m('create')" max-width="max-w-3xl" @close="closeModal">
      <form class="grid gap-4 md:grid-cols-2" @submit.prevent="saveTestimonial">
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">{{ m('fields.customerName') }}</span>
          <input v-model="form.customerName" required class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">{{ m('fields.storeName') }}</span>
          <input v-model="form.storeName" class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">{{ m('fields.avatarUrl') }}</span>
          <input v-model="form.avatarUrl" class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">{{ m('fields.rating') }}</span>
          <input v-model.number="form.rating" type="number" min="1" max="5" required class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 md:col-span-2">
          <span class="text-xs font-black uppercase text-slate-500">{{ m('fields.content') }}</span>
          <textarea v-model="form.content" required rows="5" class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
        </label>
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">{{ m('fields.sortOrder') }}</span>
          <input v-model.number="form.sortOrder" type="number" min="0" class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="flex items-center gap-3 rounded-xl border border-slate-200 px-4 py-3 text-sm font-bold text-slate-700">
          <input v-model="form.visible" type="checkbox" class="h-4 w-4 rounded border-slate-300" />
          {{ m('fieldsPublicVisible') }}
        </label>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-xl border border-slate-200 px-5 py-3 text-sm font-bold text-slate-600" @click="closeModal">{{ m('actions.cancel') }}</button>
          <button type="button" class="rounded-xl bg-avocado-800 px-5 py-3 text-sm font-black text-white disabled:cursor-not-allowed disabled:opacity-60" :disabled="isSaving" @click="saveTestimonial">{{ m('actions.save') }}</button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal :show="Boolean(pendingDeleteId)" @cancel="pendingDeleteId = null" @confirm="confirmDelete" />
  </AdminListPage>
</template>
