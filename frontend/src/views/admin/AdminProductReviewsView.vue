<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { CheckCircle2, Trash2, XCircle } from 'lucide-vue-next'
import AdminListPage from '../../components/admin/AdminListPage.vue'
import AdminNestedShell from '../../components/admin/shell/AdminNestedShell.vue'
import AdminShellFrame from '../../components/admin/shell/AdminShellFrame.vue'
import AdminShellTablePanel from '../../components/admin/shell/AdminShellTablePanel.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import { useAdminModuleI18n } from '../../composables/useAdminModuleI18n'
import { productReviewService, resolveBackendAssetUrl } from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'

const { m, t } = useAdminModuleI18n('productReviews')
const toast = useToastStore()
const reviews = ref([])
const isLoading = ref(false)
const errorMessage = ref('')
const searchQuery = ref('')
const statusFilter = ref('ALL')
const pendingDeleteId = ref(null)
const isModerating = ref(false)
const currentPage = ref(1)
const pageSize = 8

const statusClass = (status) => {
  if (status === 'APPROVED') return 'border-emerald-200 bg-emerald-50 text-emerald-700'
  if (status === 'REJECTED') return 'border-red-200 bg-red-50 text-red-700'
  return 'border-amber-200 bg-amber-50 text-amber-700'
}

const statusLabel = (status) => {
  if (status === 'APPROVED') return m('status.approved')
  if (status === 'REJECTED') return m('status.rejected')
  return m('status.pending')
}

const filteredReviews = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return reviews.value.filter((item) => {
    const matchesKeyword = !keyword || [item.customerName, item.productName, item.content]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
      .includes(keyword)
    const matchesStatus = statusFilter.value === 'ALL' || item.status === statusFilter.value
    return matchesKeyword && matchesStatus
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredReviews.value.length / pageSize)))
const paginatedReviews = computed(() =>
  filteredReviews.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)
const listCountText = computed(() => t('admin.shared.totalCount', { count: filteredReviews.value.length }))

const loadReviews = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const { data } = await productReviewService.adminList()
    reviews.value = Array.isArray(data) ? data : []
  } catch (error) {
    errorMessage.value = error.response?.data?.message || m('toasts.loadError')
  } finally {
    isLoading.value = false
  }
}

const updateReviewInList = (updated) => {
  const index = reviews.value.findIndex((item) => item.id === updated.id)
  if (index !== -1) reviews.value.splice(index, 1, updated)
}

const moderateReview = async (item, status) => {
  if (isModerating.value) return
  isModerating.value = true
  try {
    const { data } = await productReviewService.updateStatus(item.id, status)
    updateReviewInList(data)
    toast.success(status === 'APPROVED' ? m('toasts.approved') : m('toasts.rejected'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.statusError'))
  } finally {
    isModerating.value = false
  }
}

const confirmDelete = async () => {
  try {
    await productReviewService.remove(pendingDeleteId.value)
    reviews.value = reviews.value.filter((item) => item.id !== pendingDeleteId.value)
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

onMounted(loadReviews)
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
            <option value="PENDING">{{ m('filters.pending') }}</option>
            <option value="APPROVED">{{ m('filters.approved') }}</option>
            <option value="REJECTED">{{ m('filters.rejected') }}</option>
          </select>
        </section>
      </AdminShellFrame>

      <AdminShellFrame v-if="errorMessage" as="p" variant="alert" class="admin-list-alert">
        {{ errorMessage }}
      </AdminShellFrame>

      <AdminShellFrame v-if="isLoading" variant="body" inner="pad">
        <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
      </AdminShellFrame>

      <AdminShellFrame v-else-if="!filteredReviews.length" variant="body" inner="pad">
        <EmptyState :title="m('listTitle')" />
      </AdminShellFrame>

      <AdminShellFrame v-else variant="body" visibility="desktop">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <table class="admin-shell-table">
            <colgroup>
              <col style="width: 26%" />
              <col style="width: 16%" />
              <col style="width: 24%" />
              <col style="width: 10%" />
              <col style="width: 12%" />
              <col style="width: 12%" />
            </colgroup>
            <thead>
              <tr>
                <th>{{ m('columns.customer') }}</th>
                <th>{{ m('columns.product') }}</th>
                <th>{{ m('columns.content') }}</th>
                <th>{{ m('columns.rating') }}</th>
                <th>{{ m('columns.status') }}</th>
                <th>{{ m('columns.actions') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in paginatedReviews" :key="item.id">
                <td>
                  <div class="flex items-center gap-3">
                    <img v-if="item.avatarUrl" :src="resolveBackendAssetUrl(item.avatarUrl)" :alt="item.customerName" class="h-11 w-11 rounded-full object-cover" />
                    <div v-else class="grid h-11 w-11 place-items-center rounded-full bg-avocado-50 font-black text-avocado-800">{{ item.customerName?.charAt(0) || 'A' }}</div>
                    <div class="min-w-0">
                      <p class="truncate font-black text-avocado-950">{{ item.customerName }}</p>
                      <p class="text-xs font-bold text-slate-500">{{ new Date(item.createdAt).toLocaleString('vi-VN') }}</p>
                    </div>
                  </div>
                </td>
                <td class="admin-shell-cell-strong admin-shell-cell-truncate">{{ item.productName || `#${item.productId}` }}</td>
                <td class="admin-shell-cell-muted admin-shell-cell-truncate">{{ item.content }}</td>
                <td class="font-black text-amber-500">{{ item.rating }}/5</td>
                <td>
                  <span class="rounded-full border px-3 py-1 text-xs font-black" :class="statusClass(item.status)">
                    {{ statusLabel(item.status) }}
                  </span>
                </td>
                <td>
                  <div class="flex gap-2">
                    <button
                      v-if="item.status === 'PENDING' || item.status === 'REJECTED'"
                      class="rounded-lg border border-emerald-200 p-2 text-emerald-700 hover:bg-emerald-50"
                      :title="m('actions.approve')"
                      :disabled="isModerating"
                      @click="moderateReview(item, 'APPROVED')"
                    >
                      <CheckCircle2 class="h-4 w-4" />
                    </button>
                    <button
                      v-if="item.status === 'PENDING' || item.status === 'APPROVED'"
                      class="rounded-lg border border-red-200 p-2 text-red-600 hover:bg-red-50"
                      :title="m('actions.reject')"
                      :disabled="isModerating"
                      @click="moderateReview(item, 'REJECTED')"
                    >
                      <XCircle class="h-4 w-4" />
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

      <AdminShellFrame v-if="!isLoading && filteredReviews.length" variant="body" visibility="mobile">
        <AdminShellTablePanel :title="m('listTitle')" :count-text="listCountText">
          <template #below>
            <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack">
              <article v-for="item in paginatedReviews" :key="item.id" class="admin-shell-mobile-card">
                <div class="flex items-start justify-between gap-3">
                  <div class="min-w-0">
                    <h2 class="truncate font-black text-avocado-950">{{ item.customerName }}</h2>
                    <p class="text-xs font-bold text-slate-500">{{ item.productName || `#${item.productId}` }} · {{ item.rating }}/5</p>
                  </div>
                  <span class="rounded-full border px-3 py-1 text-xs font-black" :class="statusClass(item.status)">{{ statusLabel(item.status) }}</span>
                </div>
                <p class="mt-3 line-clamp-4 text-sm leading-6 text-slate-600">{{ item.content }}</p>
                <div class="mt-4 flex flex-wrap gap-2">
                  <button v-if="item.status === 'PENDING' || item.status === 'REJECTED'" class="rounded-lg border border-emerald-200 px-3 py-2 text-xs font-bold text-emerald-700 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isModerating" @click="moderateReview(item, 'APPROVED')">{{ m('actions.approve') }}</button>
                  <button v-if="item.status === 'PENDING' || item.status === 'APPROVED'" class="rounded-lg border border-red-200 px-3 py-2 text-xs font-bold text-red-600 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isModerating" @click="moderateReview(item, 'REJECTED')">{{ m('actions.reject') }}</button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 text-xs font-bold text-red-600" @click="pendingDeleteId = item.id">{{ m('actions.delete') }}</button>
                </div>
              </article>
            </div>
          </template>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="filteredReviews.length" variant="footer">
        <Pagination
          :page="currentPage"
          :total-pages="totalPages"
          :visible-count="paginatedReviews.length"
          :total-count="filteredReviews.length"
          :label="m('paginationLabel')"
          @prev="currentPage--"
          @next="currentPage++"
        />
      </AdminShellFrame>
    </AdminNestedShell>

    <ConfirmModal :show="Boolean(pendingDeleteId)" @cancel="pendingDeleteId = null" @confirm="confirmDelete" />
  </AdminListPage>
</template>
