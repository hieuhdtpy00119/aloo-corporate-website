<script setup>
import { computed, ref, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
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

watch([search, statusFilter, categoryFilter], () => {
  page.value = 1
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
  <section>
    <AdminPageHeader
      :eyebrow="t('admin.articles.eyebrow')"
      :title="t('admin.articles.title')"
      :description="t('admin.articles.description')"
    >
      <template #actions>
        <RouterLink
          :to="adminPaths.content.articleCategories"
          class="aloo-btn aloo-btn--secondary"
        >
          {{ t('admin.nav.categories') }}
        </RouterLink>
        <button
          type="button"
          class="aloo-btn aloo-btn--primary"
          @click="router.push(adminPaths.content.articleNew)"
        >
          {{ t('admin.articles.add') }}
        </button>
      </template>
    </AdminPageHeader>

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

    <p v-if="postsError" class="rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-xs font-bold text-red-700" role="alert">
      {{ postsError }}
    </p>

    <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
      <div class="overflow-x-auto">
        <table v-if="!isLoading && filteredArticles.length" class="w-full min-w-[980px] table-fixed whitespace-nowrap">
          <colgroup>
            <col class="w-[26%]" />
            <col class="w-[15%]" />
            <col class="w-[13%]" />
            <col class="w-[12%]" />
            <col class="w-[12%]" />
            <col class="w-[9%]" />
            <col class="w-[13%]" />
          </colgroup>
          <thead class="bg-slate-50 text-left text-sm font-black text-slate-600">
            <tr>
              <th class="px-5 py-4">{{ t('admin.articles.columns.title') }}</th>
              <th class="px-5 py-4">{{ t('admin.articles.columns.category') }}</th>
              <th class="px-5 py-4">{{ t('admin.articles.columns.author') }}</th>
              <th class="px-5 py-4">{{ t('admin.articles.columns.publishedAt') }}</th>
              <th class="px-5 py-4">{{ t('admin.articles.columns.status') }}</th>
              <th class="px-4 py-4 text-center">{{ t('admin.articles.columns.seo') }}</th>
              <th class="px-4 py-4 text-center">{{ t('admin.articles.columns.actions') }}</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100 text-sm">
            <tr v-for="post in paginatedArticles" :key="post.id" class="align-middle hover:bg-slate-50/60">
              <td class="px-5 py-4">
                <p class="truncate font-black text-avocado-950">{{ post.title }}</p>
                <p class="mt-1 truncate text-xs font-semibold text-slate-500">/{{ post.slug || post.id }}</p>
              </td>
              <td class="truncate px-5 py-4 font-semibold text-slate-700">{{ post.category }}</td>
              <td class="truncate px-5 py-4 text-slate-600">{{ post.author || 'ALOO Editorial' }}</td>
              <td class="truncate px-5 py-4 text-slate-600">{{ post.publishedAt || post.date || t('admin.articles.notScheduled') }}</td>
              <td class="px-5 py-4">
                <span class="inline-flex rounded-full border px-3 py-1 text-xs font-black" :class="getArticleStatusBadgeClass(post.status)">
                  {{ articleStatusLabel(post.status, t) }}
                </span>
              </td>
              <td class="px-4 py-4 text-center">
                <span class="inline-flex min-w-10 justify-center font-black tabular-nums" :class="getSeoScore(post) >= 70 ? 'text-green-700' : 'text-orange-600'">
                  {{ getSeoScore(post) }}
                </span>
              </td>
              <td class="px-4 py-4">
                <div class="flex justify-center gap-2">
                  <button
                    type="button"
                    class="rounded-lg border border-avocado-200 px-3 py-2 font-bold text-avocado-700 hover:bg-avocado-50"
                    @click="router.push(adminPaths.content.articleEdit(post.id))"
                  >
                    {{ t('admin.articles.actions.edit') }}
                  </button>
                  <button
                    type="button"
                    class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600 hover:bg-red-50"
                    @click="openDelete(post)"
                  >
                    {{ t('admin.articles.actions.delete') }}
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <EmptyState v-if="isLoading || !filteredArticles.length" :loading="isLoading" :message="t('admin.articles.empty')" />
      <div class="px-5 pb-5">
        <Pagination
          :page="page"
          :total-pages="totalPages"
          :visible-count="paginatedArticles.length"
          :total-count="filteredArticles.length"
          :label="t('admin.articles.paginationLabel')"
          @prev="page = Math.max(1, page - 1)"
          @next="page = Math.min(totalPages, page + 1)"
        />
      </div>
    </div>

    <ConfirmModal :show="!!pendingDelete" @cancel="pendingDelete = null" @confirm="deleteArticle" />
  </section>
</template>
