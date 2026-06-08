<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { Edit3, Eye, EyeOff, Plus, Trash2 } from 'lucide-vue-next'
import BaseModal from '../../components/admin/BaseModal.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import { feedbackService, resolveBackendAssetUrl } from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'

const toast = useToastStore()
const testimonials = ref([])
const isLoading = ref(false)
const errorMessage = ref('')
const searchQuery = ref('')
const visibleFilter = ref('ALL')
const showModal = ref(false)
const editingId = ref(null)
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
    errorMessage.value = error.response?.data?.message || 'Không tải được testimonial'
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
  if (!form.customerName.trim() || !form.content.trim()) {
    toast.error('Vui lòng nhập tên khách hàng và nội dung')
    return
  }
  try {
    const payload = buildPayload()
    const { data } = editingId.value
      ? await feedbackService.update(editingId.value, payload)
      : await feedbackService.create(payload)
    const index = testimonials.value.findIndex((item) => item.id === data.id)
    if (index === -1) testimonials.value.unshift(data)
    else testimonials.value.splice(index, 1, data)
    toast.success(editingId.value ? 'Đã cập nhật testimonial' : 'Đã tạo testimonial')
    closeModal()
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không lưu được testimonial')
  }
}

const toggleVisible = async (item) => {
  try {
    const { data } = await feedbackService.updateVisible(item.id, !item.visible)
    const index = testimonials.value.findIndex((entry) => entry.id === data.id)
    if (index !== -1) testimonials.value.splice(index, 1, data)
    toast.success(data.visible ? 'Đã bật hiển thị' : 'Đã ẩn testimonial')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không cập nhật được hiển thị')
  }
}

const confirmDelete = async () => {
  try {
    await feedbackService.remove(pendingDeleteId.value)
    testimonials.value = testimonials.value.filter((item) => item.id !== pendingDeleteId.value)
    toast.success('Đã xóa testimonial')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không xóa được testimonial')
  } finally {
    pendingDeleteId.value = null
  }
}

onMounted(loadTestimonials)
</script>

<template>
  <section>
    <div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
      <div>
        <h1 class="text-3xl font-black text-avocado-950">Testimonial CMS</h1>
        <p class="mt-2 text-slate-600">Quản lý cảm nhận khách hàng hiển thị trên website. Không cần tài khoản khách hàng.</p>
      </div>
      <button class="inline-flex items-center justify-center gap-2 rounded-xl bg-[#2D5A27] px-4 py-3 text-sm font-black text-white hover:bg-[#24491f]" @click="openCreateModal">
        <Plus class="h-4 w-4" />
        Thêm testimonial
      </button>
    </div>

    <div class="mb-6 grid gap-4 rounded-3xl border border-slate-100 bg-white p-4 shadow-sm md:grid-cols-[1fr_180px]">
      <input v-model="searchQuery" class="rounded-2xl border border-slate-100 bg-slate-50/50 px-4 py-3 text-sm font-semibold outline-none focus:border-avocado-500" placeholder="Tìm theo tên, chi nhánh, nội dung..." />
      <select v-model="visibleFilter" class="rounded-2xl border border-slate-100 bg-slate-50/50 px-4 py-3 text-sm font-semibold outline-none focus:border-avocado-500">
        <option value="ALL">Tất cả</option>
        <option value="VISIBLE">Đang hiển thị</option>
        <option value="HIDDEN">Đang ẩn</option>
      </select>
    </div>

    <p v-if="errorMessage" class="mb-4 rounded-lg bg-red-50 px-4 py-3 text-sm font-bold text-red-700">{{ errorMessage }}</p>

    <div class="hidden overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm lg:block">
      <EmptyState v-if="isLoading || filteredTestimonials.length === 0" :loading="isLoading" />
      <table v-else class="w-full divide-y divide-slate-200 text-left">
        <thead class="bg-slate-50">
          <tr>
            <th class="px-4 py-3 text-xs font-black uppercase text-slate-500">Khách hàng</th>
            <th class="px-4 py-3 text-xs font-black uppercase text-slate-500">Nội dung</th>
            <th class="px-4 py-3 text-xs font-black uppercase text-slate-500">Sao</th>
            <th class="px-4 py-3 text-xs font-black uppercase text-slate-500">Hiển thị</th>
            <th class="px-4 py-3 text-xs font-black uppercase text-slate-500">Thứ tự</th>
            <th class="px-4 py-3 text-xs font-black uppercase text-slate-500">Thao tác</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
          <tr v-for="item in paginatedTestimonials" :key="item.id">
            <td class="px-4 py-3">
              <div class="flex items-center gap-3">
                <img v-if="item.avatarUrl" :src="resolveBackendAssetUrl(item.avatarUrl)" :alt="item.customerName" class="h-11 w-11 rounded-full object-cover" />
                <div v-else class="grid h-11 w-11 place-items-center rounded-full bg-avocado-50 font-black text-avocado-800">{{ item.customerName?.charAt(0) || 'A' }}</div>
                <div>
                  <p class="font-black text-avocado-950">{{ item.customerName }}</p>
                  <p class="text-xs font-bold text-slate-500">{{ item.storeName || 'ALOO' }}</p>
                </div>
              </div>
            </td>
            <td class="max-w-lg truncate px-4 py-3 text-sm text-slate-700">{{ item.content }}</td>
            <td class="px-4 py-3 text-sm font-black text-amber-500">{{ item.rating }}/5</td>
            <td class="px-4 py-3">
              <span class="rounded-full border px-3 py-1 text-xs font-black" :class="item.visible ? 'border-emerald-200 bg-emerald-50 text-emerald-700' : 'border-slate-200 bg-slate-50 text-slate-500'">
                {{ item.visible ? 'Bật' : 'Ẩn' }}
              </span>
            </td>
            <td class="px-4 py-3 text-sm font-bold text-slate-600">{{ item.sortOrder }}</td>
            <td class="px-4 py-3">
              <div class="flex gap-2">
                <button class="rounded-lg border border-slate-200 p-2 text-slate-700 hover:bg-slate-50" title="Ẩn/hiện" @click="toggleVisible(item)">
                  <Eye v-if="!item.visible" class="h-4 w-4" />
                  <EyeOff v-else class="h-4 w-4" />
                </button>
                <button class="rounded-lg border border-avocado-200 p-2 text-avocado-700 hover:bg-avocado-50" title="Sửa" @click="openEditModal(item)"><Edit3 class="h-4 w-4" /></button>
                <button class="rounded-lg border border-red-200 p-2 text-red-600 hover:bg-red-50" title="Xóa" @click="pendingDeleteId = item.id"><Trash2 class="h-4 w-4" /></button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="grid gap-4 lg:hidden">
      <EmptyState v-if="isLoading || filteredTestimonials.length === 0" :loading="isLoading" />
      <article v-for="item in paginatedTestimonials" v-else :key="item.id" class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
        <div class="flex items-start justify-between gap-3">
          <div>
            <h2 class="font-black text-avocado-950">{{ item.customerName }}</h2>
            <p class="text-xs font-bold text-slate-500">{{ item.storeName || 'ALOO' }} · {{ item.rating }}/5</p>
          </div>
          <span class="rounded-full border px-3 py-1 text-xs font-black" :class="item.visible ? 'border-emerald-200 bg-emerald-50 text-emerald-700' : 'border-slate-200 bg-slate-50 text-slate-500'">{{ item.visible ? 'Bật' : 'Ẩn' }}</span>
        </div>
        <p class="mt-3 line-clamp-3 text-sm leading-6 text-slate-600">{{ item.content }}</p>
        <div class="mt-4 flex gap-2">
          <button class="rounded-lg border border-slate-200 px-3 py-2 text-xs font-bold text-slate-700" @click="toggleVisible(item)">Ẩn/hiện</button>
          <button class="rounded-lg border border-avocado-200 px-3 py-2 text-xs font-bold text-avocado-700" @click="openEditModal(item)">Sửa</button>
          <button class="rounded-lg border border-red-200 px-3 py-2 text-xs font-bold text-red-600" @click="pendingDeleteId = item.id">Xóa</button>
        </div>
      </article>
    </div>

    <Pagination :page="currentPage" :total-pages="totalPages" :visible-count="paginatedTestimonials.length" :total-count="filteredTestimonials.length" label="testimonial" @prev="currentPage--" @next="currentPage++" />

    <BaseModal :show="showModal" :title="editingId ? 'Cập nhật testimonial' : 'Thêm testimonial'" max-width="max-w-3xl" @close="closeModal">
      <form class="grid gap-4 md:grid-cols-2" @submit.prevent="saveTestimonial">
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">Tên khách hàng</span>
          <input v-model="form.customerName" required class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">Tên cửa hàng</span>
          <input v-model="form.storeName" class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">Avatar URL</span>
          <input v-model="form.avatarUrl" class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">Số sao</span>
          <input v-model.number="form.rating" type="number" min="1" max="5" required class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 md:col-span-2">
          <span class="text-xs font-black uppercase text-slate-500">Nội dung</span>
          <textarea v-model="form.content" required rows="5" class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
        </label>
        <label class="grid gap-2">
          <span class="text-xs font-black uppercase text-slate-500">Thứ tự</span>
          <input v-model.number="form.sortOrder" type="number" min="0" class="rounded-xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="flex items-center gap-3 rounded-xl border border-slate-200 px-4 py-3 text-sm font-bold text-slate-700">
          <input v-model="form.visible" type="checkbox" class="h-4 w-4 rounded border-slate-300" />
          Hiển thị public
        </label>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-xl border border-slate-200 px-5 py-3 text-sm font-bold text-slate-600" @click="closeModal">Hủy</button>
          <button class="rounded-xl bg-avocado-800 px-5 py-3 text-sm font-black text-white" @click="saveTestimonial">Lưu</button>
        </div>
      </template>
    </BaseModal>

    <ConfirmModal :show="Boolean(pendingDeleteId)" @cancel="pendingDeleteId = null" @confirm="confirmDelete" />
  </section>
</template>
