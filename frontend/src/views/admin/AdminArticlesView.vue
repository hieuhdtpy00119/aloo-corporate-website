<script setup>
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'

const router = useRouter()
const store = useAppStore()
const toast = useToastStore()

const search = ref('')
const statusFilter = ref('Tất cả')
const categoryFilter = ref('')
const page = ref(1)
const perPage = 5
const pendingDelete = ref(null)

const categoryOptions = computed(() => [
  '',
  ...store.categories
    .filter((category) => category.type === 'ARTICLE' && category.status === 'ACTIVE')
    .sort((a, b) => a.sortOrder - b.sortOrder)
    .map((category) => category.name),
])

const statusLabels = {
  DRAFT: 'Nháp',
  PENDING: 'Chờ duyệt',
  REVIEWING: 'Đang rà soát',
  APPROVED: 'Đã duyệt',
  PUBLISHED: 'Đã xuất bản',
  ARCHIVED: 'Lưu trữ',
  'Bản nháp': 'Nháp',
  'Lên lịch': 'Chờ duyệt',
  'Đã đăng': 'Đã xuất bản',
  Ẩn: 'Lưu trữ',
}

const statusValues = {
  Nháp: 'DRAFT',
  'Chờ duyệt': 'PENDING',
  'Đang rà soát': 'REVIEWING',
  'Đang review': 'REVIEWING',
  'Đã duyệt': 'APPROVED',
  'Đã xuất bản': 'PUBLISHED',
  'Lưu trữ': 'ARCHIVED',
}

const articleStatuses = ['Tất cả', 'Nháp', 'Chờ duyệt', 'Đang rà soát', 'Đã duyệt', 'Đã xuất bản', 'Lưu trữ']

const normalizeStatus = (status) => {
  if (status === 'Đã đăng') return 'PUBLISHED'
  if (status === 'Bản nháp') return 'DRAFT'
  if (status === 'Lên lịch') return 'PENDING'
  if (status === 'Ẩn') return 'ARCHIVED'
  return status || 'DRAFT'
}

const getStatusClass = (status) => {
  switch (normalizeStatus(status)) {
    case 'PUBLISHED':
      return 'bg-green-50 text-green-700 border-green-200'
    case 'APPROVED':
      return 'bg-emerald-50 text-emerald-700 border-emerald-200'
    case 'REVIEWING':
      return 'bg-orange-50 text-orange-700 border-orange-200'
    case 'PENDING':
      return 'bg-blue-50 text-blue-700 border-blue-200'
    case 'ARCHIVED':
      return 'bg-slate-100 text-slate-600 border-slate-200'
    default:
      return 'bg-yellow-50 text-yellow-700 border-yellow-200'
  }
}

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
  return store.posts.filter((post) => {
    const haystack = [post.title, post.category, post.author, post.excerpt, ...(post.tags || [])]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
    const status = normalizeStatus(post.status)
    const matchesSearch = !keyword || haystack.includes(keyword)
    const selectedStatus = statusValues[statusFilter.value] || statusFilter.value
    const matchesStatus = statusFilter.value === 'Tất cả' || status === selectedStatus
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

const deleteArticle = () => {
  if (!pendingDelete.value) return
  store.posts = store.posts.filter((post) => post.id !== pendingDelete.value.id)
  pendingDelete.value = null
  toast.success('Đã xóa bài viết')
}
</script>

<template>
  <section class="space-y-6">
    <div class="flex flex-col justify-between gap-4 rounded-2xl border border-slate-200 bg-white p-6 shadow-sm lg:flex-row lg:items-center">
      <div>
        <p class="text-sm font-bold uppercase tracking-[0.18em] text-avocado-600">Article Management System</p>
        <h1 class="mt-2 text-3xl font-black text-avocado-950">Quản lý tin tức</h1>
        <p class="mt-2 max-w-2xl text-slate-600">
          Quản lý bài SEO, review địa điểm ăn uống, tin thương hiệu và nội dung nhượng quyền của ALOO.
        </p>
      </div>
      <button
        type="button"
        class="rounded-xl bg-[#2D5A27] px-5 py-3 text-center font-black text-white shadow-sm transition hover:bg-[#24491f]"
        @click="router.push('/admin/articles/new')"
      >
        Thêm bài viết
      </button>
    </div>

    <SearchFilterBar
      v-model:search="search"
      v-model:status="statusFilter"
      v-model:extra-filter="categoryFilter"
      search-label="Tìm bài viết"
      search-placeholder="Tìm theo tiêu đề, tác giả, tag..."
      status-label="Trạng thái bài"
      :status-options="articleStatuses"
      :extra-options="categoryOptions"
      extra-label="Danh mục"
      extra-placeholder="Tất cả danh mục"
    />

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
              <th class="px-5 py-4">Tiêu đề</th>
              <th class="px-5 py-4">Danh mục</th>
              <th class="px-5 py-4">Tác giả</th>
              <th class="px-5 py-4">Ngày đăng</th>
              <th class="px-5 py-4">Trạng thái</th>
              <th class="px-4 py-4 text-center">SEO</th>
              <th class="px-4 py-4 text-center">Hành động</th>
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
              <td class="truncate px-5 py-4 text-slate-600">{{ post.publishedAt || post.date || 'Chưa đặt' }}</td>
              <td class="px-5 py-4">
                <span class="inline-flex rounded-full border px-3 py-1 text-xs font-black" :class="getStatusClass(post.status)">
                  {{ statusLabels[post.status] || statusLabels[normalizeStatus(post.status)] || post.status }}
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
                    @click="router.push(`/admin/articles/${post.id}/edit`)"
                  >
                    Sửa
                  </button>
                  <button
                    type="button"
                    class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600 hover:bg-red-50"
                    @click="openDelete(post)"
                  >
                    Xóa
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <EmptyState v-if="!filteredArticles.length" message="Không có dữ liệu phù hợp" />
      <div class="px-5 pb-5">
        <Pagination
          :page="page"
          :total-pages="totalPages"
          :visible-count="paginatedArticles.length"
          :total-count="filteredArticles.length"
          label="bài viết"
          @prev="page = Math.max(1, page - 1)"
          @next="page = Math.min(totalPages, page + 1)"
        />
      </div>
    </div>

    <ConfirmModal :show="!!pendingDelete" @cancel="pendingDelete = null" @confirm="deleteArticle" />
  </section>
</template>
