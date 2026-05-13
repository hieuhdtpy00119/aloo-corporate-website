<script setup>
import { computed, reactive, ref } from 'vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import { costItems, franchiseBenefits, franchiseConditions, franchiseProcess } from '../../data/mockData'

const content = reactive({
  benefits: franchiseBenefits.map((item) => ({ ...item })),
  conditions: franchiseConditions.map((item) => ({ ...item })),
  process: franchiseProcess.map((item) => ({ ...item })),
  costs: costItems.map((item) => ({ ...item })),
})

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
    items: content[key],
  })),
)

const openEditModal = (sectionKey) => {
  editingSection.value = sectionKey
  editingItems.value = content[sectionKey].map((item) => ({ ...item }))
}

const closeModal = () => {
  editingSection.value = null
  editingItems.value = []
}

const saveSection = () => {
  if (editingSection.value) {
    content[editingSection.value] = editingItems.value.map((item) => ({ ...item }))
  }
  closeModal()
}

const modalTitle = computed(() =>
  editingSection.value ? `Chỉnh sửa ${sectionMeta[editingSection.value].title.toLowerCase()}` : '',
)
</script>

<template>
  <section>
    <div class="mb-6">
      <h2 class="text-3xl font-black text-avocado-950">Nội dung nhượng quyền</h2>
      <p class="mt-2 text-slate-600">Quản lý nội dung dài bằng các section gọn, chỉnh sửa trong modal chung.</p>
    </div>

    <div class="grid gap-6 xl:grid-cols-2">
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
            <h4 class="font-black text-avocado-950">{{ item.title }}</h4>
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
