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
const productStatuses = ['Đang bán', 'Tạm ẩn', 'Hết hàng']
const statusFilters = ['Tất cả', ...productStatuses]

const form = reactive({
  name: '',
  description: '',
  price: '',
  image: '',
  category: '',
  status: 'Đang bán',
})

const resetForm = () => {
  form.name = ''
  form.description = ''
  form.price = ''
  form.image = ''
  form.category = ''
  form.status = 'Đang bán'
  delete form.id
  editingId.value = null
}

const openCreateModal = () => {
  mode.value = 'create'
  resetForm()
  showModal.value = true
}

const openEditModal = (product) => {
  mode.value = 'edit'
  editingId.value = product.id
  Object.assign(form, { ...product })
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  resetForm()
}

const saveProduct = () => {
  if (mode.value === 'create') {
    store.products.push({ id: Date.now(), ...form })
    toast.success('Đã thêm sản phẩm thành công')
  } else {
    const product = store.products.find((item) => item.id === editingId.value)
    if (product) Object.assign(product, { ...form })
    toast.success('Đã cập nhật sản phẩm thành công')
  }
  closeModal()
}

const deleteProduct = (productId) => {
  pendingDeleteId.value = productId
}

const confirmDeleteProduct = () => {
  const index = store.products.findIndex((item) => item.id === pendingDeleteId.value)
  if (index !== -1) {
    store.products.splice(index, 1)
    toast.success('Đã xóa sản phẩm thành công')
  }
  pendingDeleteId.value = null
}

const notifyStatusChange = () => {
  toast.success('Đã cập nhật trạng thái sản phẩm')
}

const statusClass = (status) => ({
  'bg-green-50 text-green-700 border-green-200': status === 'Đang bán',
  'bg-gray-50 text-gray-700 border-gray-200': status === 'Tạm ẩn',
  'bg-red-50 text-red-700 border-red-200': status === 'Hết hàng',
})

const filteredProducts = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return store.products.filter((product) => {
    const matchesSearch =
      !keyword ||
      product.name.toLowerCase().includes(keyword) ||
      product.category.toLowerCase().includes(keyword) ||
      product.description.toLowerCase().includes(keyword)
    const matchesStatus = statusFilter.value === 'Tất cả' || product.status === statusFilter.value
    return matchesSearch && matchesStatus
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredProducts.value.length / pageSize)))
const paginatedProducts = computed(() =>
  filteredProducts.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)

watch([searchQuery, statusFilter], () => {
  currentPage.value = 1
})
</script>

<template>
  <section>
    <div class="mb-6 flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
      <div>
        <h2 class="text-3xl font-black text-avocado-950">Quản lý sản phẩm</h2>
        <p class="mt-2 text-slate-600">Quản lý menu sản phẩm ALOO bằng dữ liệu mock.</p>
      </div>
      <button class="rounded-xl bg-[#2D5A27] px-5 py-3 font-black text-white hover:bg-[#24491f]" @click="openCreateModal">
        Thêm sản phẩm
      </button>
    </div>

    <SearchFilterBar v-model:search="searchQuery" v-model:status="statusFilter" search-placeholder="Tìm sản phẩm, danh mục, mô tả" :status-options="statusFilters" />

    <div class="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
      <EmptyState v-if="isLoading || filteredProducts.length === 0" :loading="isLoading" />
      <div class="overflow-x-auto">
        <table v-if="!isLoading && filteredProducts.length > 0" class="min-w-full divide-y divide-slate-200 text-left">
          <thead class="bg-slate-50">
            <tr>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Tên sản phẩm</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Danh mục</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Giá</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Ảnh</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Trạng thái</th>
              <th class="px-5 py-4 text-sm font-black text-slate-600">Hành động</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr v-for="product in paginatedProducts" :key="product.id" class="hover:bg-avocado-50/60">
              <td class="min-w-56 px-5 py-4 text-sm font-bold text-avocado-950">{{ product.name }}</td>
              <td class="whitespace-nowrap px-5 py-4 text-sm text-slate-700">{{ product.category }}</td>
              <td class="whitespace-nowrap px-5 py-4 text-sm font-bold text-slate-800">{{ product.price }}</td>
              <td class="whitespace-nowrap px-5 py-4">
                <img :src="product.image" :alt="product.name" class="h-14 w-24 rounded-md object-cover" />
              </td>
              <td class="whitespace-nowrap px-5 py-4 text-sm">
                <select v-model="product.status" class="rounded-full border px-3 py-1.5 text-sm font-bold outline-none" :class="statusClass(product.status)" @change="notifyStatusChange">
                  <option v-for="status in productStatuses" :key="status" :value="status">{{ status }}</option>
                </select>
              </td>
              <td class="whitespace-nowrap px-5 py-4 text-sm">
                <div class="flex gap-2">
                  <button class="rounded-lg border border-avocado-200 px-3 py-2 font-bold text-avocado-700 hover:bg-avocado-50" @click="openEditModal(product)">Sửa</button>
                  <button class="rounded-lg border border-red-200 px-3 py-2 font-bold text-red-600 hover:bg-red-50" @click="deleteProduct(product.id)">Xóa</button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <Pagination :page="currentPage" :total-pages="totalPages" :visible-count="paginatedProducts.length" :total-count="filteredProducts.length" label="sản phẩm" @prev="currentPage--" @next="currentPage++" />

    <BaseModal :show="showModal" :title="mode === 'create' ? 'Thêm sản phẩm' : 'Sửa sản phẩm'" @close="closeModal">
      <form id="product-form" class="grid gap-5 md:grid-cols-2" @submit.prevent="saveProduct">
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Tên sản phẩm
          <input v-model="form.name" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Giá
          <input v-model="form.price" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Danh mục
          <input v-model="form.category" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Trạng thái
          <select v-model="form.status" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500">
            <option v-for="status in productStatuses" :key="status" :value="status">{{ status }}</option>
          </select>
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
          Ảnh
          <input v-model="form.image" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
          Mô tả
          <textarea v-model="form.description" required rows="3" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
        </label>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-lg border border-slate-200 px-4 py-3 font-bold text-slate-600 hover:bg-slate-50" @click="closeModal">Hủy</button>
          <button class="rounded-lg bg-[#2D5A27] px-4 py-3 font-black text-white hover:bg-[#24491f]" form="product-form" type="submit">
            {{ mode === 'create' ? 'Thêm mới' : 'Lưu thay đổi' }}
          </button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal
      :show="Boolean(pendingDeleteId)"
      @cancel="pendingDeleteId = null"
      @confirm="confirmDeleteProduct"
    />
  </section>
</template>
