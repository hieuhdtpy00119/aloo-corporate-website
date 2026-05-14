<script setup>
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'

const store = useAppStore()
const toast = useToastStore()
const router = useRouter()
const pendingDeleteId = ref(null)
const searchQuery = ref('')
const statusFilter = ref('Tất cả')
const isLoading = ref(false)
const currentPage = ref(1)
const pageSize = 5
const postStatuses = ['Đã đăng', 'Bản nháp', 'Lên lịch', 'Ẩn']
const statusFilters = ['Tất cả', ...postStatuses]

const statusClass = (status) => ({
  'bg-green-50 text-green-700 border-green-200': status === 'Đã đăng',
  'bg-yellow-50 text-yellow-700 border-yellow-200': status === 'Bản nháp' || status === 'Lên lịch',
  'bg-gray-50 text-gray-700 border-gray-200': status === 'Ẩn',
})

const notifyStatusChange = () => {
  toast.success('Đã cập nhật trạng thái bài viết')
}

const filteredPosts = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return store.posts.filter((post) => {
    const matchesSearch =
      !keyword ||
      post.title.toLowerCase().includes(keyword) ||
      post.category.toLowerCase().includes(keyword) ||
      String(post.excerpt || '').toLowerCase().includes(keyword)
    const matchesStatus = statusFilter.value === 'Tất cả' || post.status === statusFilter.value
    return matchesSearch && matchesStatus
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredPosts.value.length / pageSize)))
const paginatedPosts = computed(() =>
  filteredPosts.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)

const deletePost = (postId) => {
  pendingDeleteId.value = postId
}

const confirmDeletePost = () => {
  const index = store.posts.findIndex((item) => item.id === pendingDeleteId.value)
  if (index !== -1) {
    store.posts.splice(index, 1)
    toast.success('Đã xóa bài viết thành công')
  }
  pendingDeleteId.value = null
}

watch([searchQuery, statusFilter], () => {
  currentPage.value = 1
})
</script>

<template>
  <section>
    <div class="mb-6 flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
      <div>
        <h2 class="text-3xl font-black text-avocado-950">Quản lý bài viết</h2>
        <p class="mt-2 text-slate-600">Bài SEO, review địa điểm ăn uống và câu chuyện thương hiệu ALOO.</p>
      </div>
      <RouterLink to="/admin/posts/new" class="rounded-xl bg-[#2D5A27] px-5 py-3 text-center font-black text-white hover:bg-[#24491f]">
        Thêm bài viết
      </RouterLink>
    </div>

    <SearchFilterBar v-model:search="searchQuery" v-model:status="statusFilter" search-placeholder="Tìm bài viết, danh mục, mô tả" :status-options="statusFilters" />

    <div class="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
      <EmptyState v-if="isLoading || filteredPosts.length === 0" :loading="isLoading" />
      <div class="overflow-x-auto">
        <table v-if="!isLoading && filteredPosts.length > 0" class="min-w-full divide-y divide-slate-200 text-left">
          <thead class="bg-slate-50">
            <tr>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Tiêu đề</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Danh mục</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Ngày đăng</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Trạng thái</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Hành động</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr v-for="post in paginatedPosts" :key="post.id" class="hover:bg-avocado-50/60">
              <td class="min-w-80 px-5 py-4 text-sm font-bold text-avocado-950">{{ post.title }}</td>
              <td class="whitespace-nowrap px-5 py-4 text-sm text-slate-700">{{ post.category }}</td>
              <td class="whitespace-nowrap px-5 py-4 text-sm text-slate-700">{{ post.publishedAt }}</td>
              <td class="whitespace-nowrap px-5 py-4 text-sm">
                <select v-model="post.status" class="rounded-full border px-3 py-1.5 text-sm font-bold outline-none" :class="statusClass(post.status)" @change="notifyStatusChange">
                  <option v-for="status in postStatuses" :key="status" :value="status">{{ status }}</option>
                </select>
              </td>
              <td class="whitespace-nowrap px-5 py-4 text-sm">
                <div class="flex gap-2">
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 font-bold text-avocado-700 hover:bg-avocado-50" @click="router.push(`/admin/posts/${post.id}/edit`)">Sửa</button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600 hover:bg-red-50" @click="deletePost(post.id)">Xóa</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <Pagination :page="currentPage" :total-pages="totalPages" :visible-count="paginatedPosts.length" :total-count="filteredPosts.length" label="bài viết" @prev="currentPage--" @next="currentPage++" />

    <ConfirmModal
      :show="Boolean(pendingDeleteId)"
      @cancel="pendingDeleteId = null"
      @confirm="confirmDeletePost"
    />
  </section>
</template>
