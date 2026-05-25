<script setup>
import { computed, onMounted, ref } from 'vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import { useFranchiseContentStore } from '../../stores/franchiseContentStore'
import { useToastStore } from '../../stores/toastStore'

const franchiseStore = useFranchiseContentStore()
const toast = useToastStore()
const statuses = ['ACTIVE', 'INACTIVE', 'HIDDEN']
const statusLabels = {
  ACTIVE: 'Đang hiển thị',
  INACTIVE: 'Tạm ẩn',
  HIDDEN: 'Đã ẩn',
}

const sectionMeta = {
  benefits: { title: 'Lợi ích', description: 'Các lợi ích nhượng quyền dành cho đối tác.' },
  conditions: { title: 'Điều kiện', description: 'Các điều kiện hợp tác cơ bản.' },
  process: { title: 'Quy trình', description: 'Các bước mở cửa hàng ALOO.' },
  costs: { title: 'Chi phí', description: 'Các gói chi phí đầu tư dự kiến.' },
}

const editingSection = ref(null)
const editingItems = ref([])

const sections = computed(() =>
  Object.entries(sectionMeta).map(([key, meta]) => ({
    key,
    ...meta,
    items: franchiseStore.content[key],
  })),
)

const openEditModal = (sectionKey) => {
  editingSection.value = sectionKey
  editingItems.value = franchiseStore.content[sectionKey].map((item) => ({
    status: 'ACTIVE',
    ...item,
  }))
}

const closeModal = () => {
  editingSection.value = null
  editingItems.value = []
}

const saveSection = async () => {
  if (editingSection.value) {
    try {
      await franchiseStore.updateSection(editingSection.value, editingItems.value)
      toast.success('Đã lưu nội dung nhượng quyền')
    } catch (error) {
      toast.error(error.response?.data?.message || 'Không lưu được nội dung nhượng quyền')
      return
    }
  }
  closeModal()
}

const modalTitle = computed(() =>
  editingSection.value ? `Chỉnh sửa ${sectionMeta[editingSection.value].title.toLowerCase()}` : '',
)

const statusClass = (status) => ({
  'bg-green-50 text-green-700 border-green-200': status === 'ACTIVE',
  'bg-gray-50 text-gray-700 border-gray-200': status === 'INACTIVE',
  'bg-red-50 text-red-700 border-red-200': status === 'HIDDEN',
})

onMounted(() => {
  franchiseStore.fetchContent().catch(() => {
    toast.error('Không tải được nội dung nhượng quyền')
  })
})
</script>

<template>
  <section>
    <div class="mb-6">
      <h2 class="text-3xl font-black text-avocado-950">Nội dung nhượng quyền</h2>
      <p class="mt-2 text-slate-600">Quản lý nội dung dài bằng các section gọn, chỉnh sửa trong modal chung.</p>
    </div>
    <p v-if="franchiseStore.error" class="mb-4 rounded-lg bg-red-50 px-4 py-3 text-sm font-bold text-red-700">
      {{ franchiseStore.error }}
    </p>
    <p v-if="franchiseStore.loading" class="mb-4 rounded-lg border border-slate-200 bg-white px-4 py-8 text-center text-sm font-bold text-slate-500">
      Đang tải nội dung nhượng quyền...
    </p>

    <div v-if="!franchiseStore.loading" class="grid gap-6 xl:grid-cols-2">
      <article v-for="section in sections" :key="section.key" class="rounded-lg border border-slate-200 bg-white p-6 shadow-sm">
        <div class="mb-5 flex items-start justify-between gap-4">
          <div>
            <h3 class="text-xl font-black text-avocado-950">{{ section.title }}</h3>
            <p class="mt-1 text-sm text-slate-600">{{ section.description }}</p>
          </div>
          <button class="rounded-lg bg-[#2D5A27] px-4 py-2 text-sm font-black text-white hover:bg-[#24491f]" @click="openEditModal(section.key)">
            Chỉnh sửa
          </button>
        </div>
        <div class="grid gap-3">
          <div v-for="item in section.items" :key="item.id" class="rounded-lg bg-slate-50 p-4">
            <div class="flex items-start justify-between gap-3">
              <h4 class="font-black text-avocado-950">{{ item.title }}</h4>
              <span class="rounded-full border px-3 py-1 text-xs font-black" :class="statusClass(item.status || 'ACTIVE')">
                {{ statusLabels[item.status || 'ACTIVE'] || item.status }}
              </span>
            </div>
            <p class="mt-2 text-sm leading-6 text-slate-600">
              {{ section.key === 'costs' ? `${item.amount} - ${item.note}` : item.description }}
            </p>
          </div>
        </div>
      </article>
    </div>

    <BaseModal :show="Boolean(editingSection)" :title="modalTitle" max-width="max-w-3xl" @close="closeModal">
      <form id="franchise-section-form" class="grid gap-4" @submit.prevent="saveSection">
        <div v-for="item in editingItems" :key="item.id" class="grid gap-3 rounded-lg bg-slate-50 p-4">
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            Tiêu đề
            <input v-model="item.title" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            Trạng thái
            <select v-model="item.status" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500">
              <option v-for="status in statuses" :key="status" :value="status">{{ statusLabels[status] }}</option>
            </select>
          </label>
          <template v-if="editingSection === 'costs'">
            <label class="grid gap-2 text-sm font-bold text-slate-700">
              Chi phí
              <input v-model="item.amount" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
            </label>
            <label class="grid gap-2 text-sm font-bold text-slate-700">
              Ghi chú
              <textarea v-model="item.note" required rows="2" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
            </label>
          </template>
          <label v-else class="grid gap-2 text-sm font-bold text-slate-700">
            Mô tả
            <textarea v-model="item.description" required rows="2" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
          </label>
        </div>
      </form>
      <template #footer>
        <div class="flex justify-end gap-3">
          <button class="rounded-lg border border-slate-200 px-4 py-3 font-bold text-slate-600 hover:bg-slate-50" @click="closeModal">Hủy</button>
          <button class="rounded-lg bg-[#2D5A27] px-4 py-3 font-black text-white hover:bg-[#24491f]" form="franchise-section-form" type="submit">
            Lưu thay đổi
          </button>
        </div>
      </template>
    </BaseModal>
  </section>
</template>
