<script setup>
import { computed, ref, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import AdminListPage from '../../components/admin/AdminListPage.vue'
import AdminNestedShell from '../../components/admin/shell/AdminNestedShell.vue'
import AdminShellFrame from '../../components/admin/shell/AdminShellFrame.vue'
import AdminShellTablePanel from '../../components/admin/shell/AdminShellTablePanel.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'
import {
  ARTICLE_STATUS_CODES,
  articleStatusFilterOptions,
  articleStatusFilterValue,
  articleStatusLabel,
  getArticleStatusBadgeClass,
  normalizeArticleStatus,
} from '../../utils/articleStatus'
import { adminPaths } from '../../constants/adminPaths'

const router = useRouter()
const store = useAppStore()
const toast = useToastStore()
const { t } = useI18n()

const search = ref('')
const statusFilter = ref(t('admin.shared.all'))
const categoryFilter = ref('')
const page = ref(1)
const perPage = 5
const pendingDelete = ref(null)
const isLoading = computed(() => store.loading.posts)
const postsError = computed(() => store.errors.posts)

const categoryOptions = computed(() => [
  '',
  ...store.categories
    .filter((category) => category.type === 'ARTICLE' && category.status === 'ACTIVE')
    .sort((a, b) => a.sortOrder - b.sortOrder)
    .map((category) => category.name),
])

const articleStatuses = computed(() => articleStatusFilterOptions(t))

const getSeoScore = (post) => {
  let score = 0
  if ((post.title || '').length >= 35 && (post.title || '').length <= 70) score += 20
  if ((post.slug || '').length > 0) score += 15
  if ((post.excerpt || '').length >= 80) score += 20
  if (post.image || post.thumbnailUrl || post.thumbnail_url) score += 15
  if ((post.content || '').length >= 500) score += 20
  if (Array.isArray(post.tags) && post.tags.length) score += 10
  return Math.min(score, 100)
}

const filteredArticles = computed(() => {
  const keyword = search.value.trim().toLowerCase()
  const selectedStatus = articleStatusFilterValue(statusFilter.value, t)
  return store.posts.filter((post) => {
    const haystack = [post.title, post.category, post.author, post.excerpt, ...(post.tags || [])]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
    const status = normalizeArticleStatus(post.status)
    const matchesSearch = !keyword || haystack.includes(keyword)
    const matchesStatus = selectedStatus === 'ALL' || status === selectedStatus
    const matchesCategory = !categoryFilter.value || post.category === categoryFilter.value
    return matchesSearch && matchesStatus && matchesCategory
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredArticles.value.length / perPage)))
const paginatedArticles = computed(() => {
  const start = (page.value - 1) * perPage
  return filteredArticles.value.slice(start, start + perPage)
})
const listCountText = computed(() => t('admin.shared.totalCount', { count: filteredArticles.value.length }))

watch([search, statusFilter, categoryFilter], () => {
  page.value = 1
})

watch(totalPages, (value) => {
  page.value = Math.min(page.value, value)
})

const openDelete = (post) => {
  pendingDelete.value = post
}

const deleteArticle = async () => {
  if (!pendingDelete.value) return
  try {
    await store.deletePost(pendingDelete.value.id)
    toast.success(t('admin.articles.toasts.deleted'))
  } catch (error) {
    toast.error(error.response?.data?.message || error.message || t('admin.articles.toasts.deleteError'))
  } finally {
    pendingDelete.value = null
  }
}
</script>

<template>
  <AdminListPage>
    <AdminNestedShell>
      <AdminShellFrame variant="header" inner="header">
        <AdminPageHeader
          :eyebrow="t('admin.articles.eyebrow')"
          :title="t('admin.articles.title')"
        >
          <template #actions>
            <RouterLink
              :to="adminPaths.content.articleCategories"
              class="admin-list-btn admin-list-btn--outline"
            >
              {{ t('admin.nav.categories') }}
            </RouterLink>
            <button
              type="button"
              class="admin-list-btn admin-list-btn--primary"
              @click="router.push(adminPaths.content.articleNew)"
            >
              {{ t('admin.articles.add') }}
            </button>
          </template>
        </AdminPageHeader>
      </AdminShellFrame>

      <AdminShellFrame variant="toolbar" inner="toolbar">
        <SearchFilterBar
          v-model:search="search"
          v-model:status="statusFilter"
          v-model:extra-filter="categoryFilter"
          :search-label="t('admin.articles.searchLabel')"
          :search-placeholder="t('admin.articles.searchPlaceholder')"
          :status-label="t('admin.articles.statusLabel')"
          :status-options="articleStatuses"
          :extra-options="categoryOptions"
          :extra-label="t('admin.articles.categoryLabel')"
          :extra-placeholder="t('admin.articles.categoryAll')"
        />
      </AdminShellFrame>

      <AdminShellFrame v-if="postsError" as="p" variant="alert" class="admin-list-alert">
        {{ postsError }}
      </AdminShellFrame>

      <AdminShellFrame v-if="isLoading" variant="body" inner="pad">
        <p class="sr-only" role="status">{{ t('admin.common.loading') }}</p>
        <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
      </AdminShellFrame>

      <AdminShellFrame v-else-if="!filteredArticles.length" variant="body" inner="pad">
        <EmptyState :message="t('admin.articles.empty')" />
      </AdminShellFrame>

      <AdminShellFrame v-else variant="body" visibility="desktop">
        <AdminShellTablePanel :title="t('admin.articles.listTitle')" :count-text="listCountText">
          <table class="admin-shell-table">
            <colgroup>
              <col style="width: 26%" />
              <col style="width: 15%" />
              <col style="width: 13%" />
              <col style="width: 12%" />
              <col style="width: 12%" />
              <col style="width: 9%" />
              <col style="width: 13%" />
            </colgroup>
            <thead>
              <tr>
                <th>{{ t('admin.articles.columns.title') }}</th>
                <th>{{ t('admin.articles.columns.category') }}</th>
                <th>{{ t('admin.articles.columns.author') }}</th>
                <th>{{ t('admin.articles.columns.publishedAt') }}</th>
                <th class="text-center">{{ t('admin.articles.columns.status') }}</th>
                <th class="text-center">{{ t('admin.articles.columns.seo') }}</th>
                <th class="text-center">{{ t('admin.articles.columns.actions') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="post in paginatedArticles" :key="post.id">
                <td>
                  <p class="truncate font-black text-avocado-950">{{ post.title }}</p>
                  <p class="mt-1 truncate text-xs font-semibold text-slate-500">/{{ post.slug || post.id }}</p>
                </td>
                <td class="admin-shell-cell-truncate admin-shell-cell-muted">{{ post.category }}</td>
                <td class="admin-shell-cell-truncate admin-shell-cell-muted">{{ post.author || 'ALOO Editorial' }}</td>
                <td class="admin-shell-cell-nowrap admin-shell-cell-muted">{{ post.publishedAt || post.date || t('admin.articles.notScheduled') }}</td>
                <td class="text-center">
                  <span class="inline-flex rounded-full border px-3 py-1 text-xs font-black" :class="getArticleStatusBadgeClass(post.status)">
                    {{ articleStatusLabel(post.status, t) }}
                  </span>
                </td>
                <td class="text-center">
                  <span class="inline-flex min-w-10 justify-center font-black tabular-nums" :class="getSeoScore(post) >= 70 ? 'text-green-700' : 'text-orange-600'">
                    {{ getSeoScore(post) }}
                  </span>
                </td>
                <td>
                  <div class="flex justify-center gap-2">
                    <button
                      type="button"
                      class="admin-list-btn admin-list-btn--outline shrink-0 !min-h-[32px] !px-2.5 !py-1.5 !text-xs"
                      @click="router.push(adminPaths.content.articleEdit(post.id))"
                    >
                      {{ t('admin.articles.actions.edit') }}
                    </button>
                    <button
                      type="button"
                      class="admin-list-btn admin-list-btn--danger shrink-0 !min-h-[32px] !px-2.5 !py-1.5 !text-xs"
                      @click="openDelete(post)"
                    >
                      {{ t('admin.articles.actions.delete') }}
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="!isLoading && filteredArticles.length" variant="body" visibility="mobile">
        <AdminShellTablePanel :title="t('admin.articles.listTitle')" :count-text="listCountText">
          <template #below>
            <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack">
              <article v-for="post in paginatedArticles" :key="post.id" class="admin-shell-mobile-card">
                <div class="flex items-start justify-between gap-3">
                  <div class="min-w-0">
                    <h3 class="truncate font-black text-avocado-950">{{ post.title }}</h3>
                    <p class="mt-1 text-xs font-semibold text-slate-500">/{{ post.slug || post.id }}</p>
                  </div>
                  <span class="shrink-0 rounded-full border px-3 py-1 text-xs font-black" :class="getArticleStatusBadgeClass(post.status)">
                    {{ articleStatusLabel(post.status, t) }}
                  </span>
                </div>
                <div class="mt-4 grid gap-2 text-sm text-slate-700">
                  <p><span class="font-bold text-slate-900">{{ t('admin.articles.columns.category') }}:</span> {{ post.category }}</p>
                  <p><span class="font-bold text-slate-900">{{ t('admin.articles.columns.author') }}:</span> {{ post.author || 'ALOO Editorial' }}</p>
                  <p><span class="font-bold text-slate-900">{{ t('admin.articles.columns.publishedAt') }}:</span> {{ post.publishedAt || post.date || t('admin.articles.notScheduled') }}</p>
                  <p>
                    <span class="font-bold text-slate-900">{{ t('admin.articles.columns.seo') }}:</span>
                    <span class="font-black tabular-nums" :class="getSeoScore(post) >= 70 ? 'text-green-700' : 'text-orange-600'">{{ getSeoScore(post) }}</span>
                  </p>
                </div>
                <div class="mt-4 flex flex-wrap gap-2">
                  <button
                    type="button"
                    class="rounded-lg border border-avocado-200 px-3 py-2 text-xs font-bold text-avocado-700"
                    @click="router.push(adminPaths.content.articleEdit(post.id))"
                  >
                    {{ t('admin.articles.actions.edit') }}
                  </button>
                  <button
                    type="button"
                    class="rounded-lg border border-red-200 px-3 py-2 text-xs font-bold text-red-600"
                    @click="openDelete(post)"
                  >
                    {{ t('admin.articles.actions.delete') }}
                  </button>
                </div>
              </article>
            </div>
          </template>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="filteredArticles.length" variant="footer">
        <Pagination
          :page="page"
          :total-pages="totalPages"
          :visible-count="paginatedArticles.length"
          :total-count="filteredArticles.length"
          :label="t('admin.articles.paginationLabel')"
          @prev="page = Math.max(1, page - 1)"
          @next="page = Math.min(totalPages, page + 1)"
        />
      </AdminShellFrame>
    </AdminNestedShell>

    <ConfirmModal :show="!!pendingDelete" @cancel="pendingDelete = null" @confirm="deleteArticle" />
  </AdminListPage>
</template>
