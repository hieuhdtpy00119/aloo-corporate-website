<script setup>
import { computed, reactive, ref, watch } from 'vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'

const store = useAppStore()
const toast = useToastStore()
const showModal = ref(false)
const mode = ref('create')
const editingId = ref(null)
const pendingDeleteId = ref(null)
const searchQuery = ref('')
const statusFilter = ref('Tất cả')
const isLoading = ref(false)
const currentPage = ref(1)
const pageSize = 5
const postStatuses = ['Đã đăng', 'Bản nháp', 'Lên lịch', 'Ẩn']
const statusFilters = ['Tất cả', ...postStatuses]

const form = reactive({
  title: '',
  excerpt: '',
  content: '',
  image: '',
  category: '',
  publishedAt: '',
  status: 'Bản nháp',
})

const resetForm = () => {
  form.title = ''
  form.excerpt = ''
  form.content = ''
  form.image = ''
  form.category = ''
  form.publishedAt = ''
  form.status = 'Bản nháp'
  delete form.id
  editingId.value = null
}

const openCreateModal = () => {
  mode.value = 'create'
  resetForm()
  showModal.value = true
}

const openEditModal = (post) => {
  mode.value = 'edit'
  editingId.value = post.id
  Object.assign(form, { ...post })
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const savePost = () => {
  if (mode.value === 'create') {
    store.posts.push({ id: Date.now(), ...form })
    toast.success('Đã thêm bài viết thành công')
  } else {
    const post = store.posts.find((item) => item.id === editingId.value)
    if (post) Object.assign(post, { ...form })
    toast.success('Đã cập nhật bài viết thành công')
  }
  closeModal()
}

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

const notifyStatusChange = () => {
  toast.success('Đã cập nhật trạng thái bài viết')
}

const statusClass = (status) => ({
  'bg-green-50 text-green-700 border-green-200': status === 'Đã đăng',
  'bg-yellow-50 text-yellow-700 border-yellow-200': status === 'Bản nháp' || status === 'Lên lịch',
  'bg-gray-50 text-gray-700 border-gray-200': status === 'Ẩn',
})

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

watch([searchQuery, statusFilter], () => {
  currentPage.value = 1
})
</script>

<template>
  <section>
    <div class="mb-6 flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
      <div>
        <h2 class="text-3xl font-black text-avocado-950">Quản lý bài viết</h2>
        <p class="mt-2 text-slate-600">Tin tức, câu chuyện thương hiệu và nội dung hỗ trợ nhượng quyền.</p>
      </div>
      <button class="rounded-xl bg-[#2D5A27] px-5 py-3 font-black text-white hover:bg-[#24491f]" @click="openCreateModal">
        Thêm bài viết
      </button>
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
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 font-bold text-avocado-700 hover:bg-avocado-50" @click="openEditModal(post)">Sửa</button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600 hover:bg-red-50" @click="deletePost(post.id)">Xóa</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <Pagination :page="currentPage" :total-pages="totalPages" :visible-count="paginatedPosts.length" :total-count="filteredPosts.length" label="bài viết" @prev="currentPage--" @next="currentPage++" />

    <BaseModal :show="showModal" :title="mode === 'create' ? 'Thêm bài viết' : 'Sửa bài viết'" max-width="max-w-3xl" @close="closeModal">
      <form id="post-form" class="grid gap-5 md:grid-cols-2" @submit.prevent="savePost">
        <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
          Tiêu đề
          <input v-model="form.title" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Danh mục
          <input v-model="form.category" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Trạng thái
          <select v-model="form.status" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500">
            <option v-for="status in postStatuses" :key="status" :value="status">{{ status }}</option>
          </select>
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Ngày đăng
          <input v-model="form.publishedAt" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Ảnh
          <input v-model="form.image" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
          Mô tả ngắn
          <textarea v-model="form.excerpt" required rows="2" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
          Nội dung
          <textarea v-model="form.content" required rows="5" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
        </label>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-lg border border-slate-200 px-4 py-3 font-bold text-slate-600 hover:bg-slate-50" @click="closeModal">Hủy</button>
          <button class="rounded-lg bg-[#2D5A27] px-4 py-3 font-black text-white hover:bg-[#24491f]" form="post-form" type="submit">
            {{ mode === 'create' ? 'Thêm mới' : 'Lưu thay đổi' }}
          </button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal
      :show="Boolean(pendingDeleteId)"
      @cancel="pendingDeleteId = null"
      @confirm="confirmDeletePost"
    />
  </section>
</template>
