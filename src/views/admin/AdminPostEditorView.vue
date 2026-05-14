<script setup>
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'

const route = useRoute()
const router = useRouter()
const store = useAppStore()
const toast = useToastStore()

const categories = ['Giới thiệu thương hiệu', 'Review', 'Địa điểm ăn uống', 'Sản phẩm', 'Nhượng quyền', 'Tin tức']
const statuses = ['Đã đăng', 'Bản nháp', 'Lên lịch', 'Ẩn']
const mode = computed(() => (route.params.id ? 'edit' : 'create'))
const editingPost = computed(() => store.posts.find((post) => String(post.id) === String(route.params.id)))

const createDefaultBlocks = () => [
  { id: Date.now() + 1, type: 'heading', text: 'ALOO Kem Bơ có gì đặc biệt?' },
  { id: Date.now() + 2, type: 'paragraph', text: 'ALOO tập trung vào kem bơ thuần Việt, hương vị dễ ăn và phù hợp nhiều nhóm khách hàng.' },
]

const form = reactive({
  title: editingPost.value?.title || '',
  slug: editingPost.value?.slug || '',
  excerpt: editingPost.value?.excerpt || '',
  category: editingPost.value?.category || 'Review',
  status: editingPost.value?.status || 'Bản nháp',
  publishedAt: editingPost.value?.publishedAt || new Date().toLocaleDateString('vi-VN'),
  image: editingPost.value?.image || '',
  seoTitle: editingPost.value?.seoTitle || '',
  seoDescription: editingPost.value?.seoDescription || '',
  contactName: editingPost.value?.contactName || 'ALOO Kem Bơ',
  contactAddress: editingPost.value?.contactAddress || 'Quy Nhơn, Bình Định',
  contactPhone: editingPost.value?.contactPhone || '0900 888 168',
  openingHours: editingPost.value?.openingHours || '09:00 - 22:00',
  fanpage: editingPost.value?.fanpage || 'https://facebook.com/aloo.vn',
  blocks: editingPost.value?.blocks?.length ? editingPost.value.blocks.map((block) => ({ ...block })) : createDefaultBlocks(),
})

const toSlug = (value) =>
  value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')

const escapeHtml = (value = '') =>
  value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;')

const blockId = (block) => `section-${block.id}`

const buildHtml = () => {
  const body = form.blocks
    .map((block) => {
      if (block.type === 'heading') return `<h2 id="${blockId(block)}">${escapeHtml(block.text)}</h2>`
      if (block.type === 'paragraph') return `<p>${escapeHtml(block.text)}</p>`
      if (block.type === 'quote') return `<blockquote>${escapeHtml(block.text)}</blockquote>`
      if (block.type === 'image') return `<img src="${escapeHtml(block.src)}" alt="${escapeHtml(block.alt || form.title)}" />`
      if (block.type === 'list') {
        const items = String(block.text || '')
          .split('\n')
          .filter(Boolean)
          .map((item) => `<li>${escapeHtml(item)}</li>`)
          .join('')
        return `<ul>${items}</ul>`
      }
      return ''
    })
    .join('')

  const contact = `
    <div class="article-contact">
      <h2 id="contact-info">Thông tin liên hệ ALOO</h2>
      <p><strong>${escapeHtml(form.contactName)}</strong></p>
      <p>Địa chỉ: ${escapeHtml(form.contactAddress)}</p>
      <p>Hotline: ${escapeHtml(form.contactPhone)}</p>
      <p>Giờ mở cửa: ${escapeHtml(form.openingHours)}</p>
      <p>Fanpage: <a href="${escapeHtml(form.fanpage)}" target="_blank" rel="noreferrer">${escapeHtml(form.fanpage)}</a></p>
    </div>`

  return `${body}${contact}`
}

const applyTemplate = (type) => {
  if (type === 'review') {
    form.category = 'Review'
    form.title ||= 'Review ALOO Kem Bơ Quy Nhơn: món kem bơ đáng thử'
    form.slug ||= toSlug(form.title)
    form.excerpt = 'Review trải nghiệm ALOO Kem Bơ Quy Nhơn, từ hương vị, không gian đến thông tin liên hệ.'
    form.blocks = [
      { id: Date.now() + 1, type: 'heading', text: 'Ấn tượng đầu tiên' },
      { id: Date.now() + 2, type: 'paragraph', text: 'ALOO Kem Bơ Quy Nhơn phù hợp cho khách muốn tìm món tráng miệng mát, dễ ăn và có nhận diện thương hiệu rõ ràng.' },
      { id: Date.now() + 3, type: 'heading', text: 'Hương vị và menu' },
      { id: Date.now() + 4, type: 'list', text: 'Kem bơ truyền thống\nKem bơ sầu riêng\nSinh tố bơ kem' },
      { id: Date.now() + 5, type: 'quote', text: 'Vị bơ béo nhẹ, kem mịn và topping tạo cảm giác dễ ăn.' },
    ]
  }

  if (type === 'brand') {
    form.category = 'Giới thiệu thương hiệu'
    form.title ||= 'ALOO - thương hiệu kem bơ thuần Việt'
    form.slug ||= toSlug(form.title)
    form.excerpt = 'Câu chuyện thương hiệu ALOO và định hướng phát triển mô hình kem bơ hiện đại.'
    form.blocks = [
      { id: Date.now() + 1, type: 'heading', text: 'Câu chuyện thương hiệu' },
      { id: Date.now() + 2, type: 'paragraph', text: 'ALOO phát triển từ món kem bơ quen thuộc, được chuẩn hóa thành mô hình cửa hàng gọn và dễ nhân rộng.' },
      { id: Date.now() + 3, type: 'heading', text: 'Giá trị cốt lõi' },
      { id: Date.now() + 4, type: 'list', text: 'Sản phẩm tập trung\nNhận diện sạch\nVận hành dễ triển khai' },
    ]
  }

  if (type === 'seo') {
    form.category = 'Địa điểm ăn uống'
    form.title ||= 'Địa chỉ kem bơ ngon tại Quy Nhơn nên thử'
    form.slug ||= toSlug(form.title)
    form.excerpt = 'Gợi ý địa chỉ kem bơ ngon tại Quy Nhơn cho khách địa phương và du khách.'
    form.blocks = [
      { id: Date.now() + 1, type: 'heading', text: 'Kem bơ ngon tại Quy Nhơn nên chọn thế nào?' },
      { id: Date.now() + 2, type: 'paragraph', text: 'Một địa chỉ kem bơ ngon cần có vị bơ rõ, kem mịn, topping hợp vị và thông tin cửa hàng dễ tìm.' },
      { id: Date.now() + 3, type: 'heading', text: 'Vì sao nên thử ALOO Kem Bơ?' },
      { id: Date.now() + 4, type: 'list', text: 'Menu dễ chọn\nHương vị phù hợp người Việt\nCó thông tin địa chỉ và giờ mở cửa rõ ràng' },
    ]
  }
}

const addBlock = (type) => {
  const defaults = {
    heading: { type, text: 'Tiêu đề section mới' },
    paragraph: { type, text: 'Nhập đoạn văn mới...' },
    list: { type, text: 'Ý chính thứ nhất\nÝ chính thứ hai' },
    quote: { type, text: 'Nhận xét/review khách hàng...' },
    image: { type, src: '', alt: '' },
  }
  form.blocks.push({ id: Date.now(), ...defaults[type] })
}

const removeBlock = (blockIdValue) => {
  form.blocks = form.blocks.filter((block) => block.id !== blockIdValue)
}

const uploadImage = (event, target = 'thumbnail', block = null) => {
  const file = event.target.files?.[0]
  if (!file) return
  const src = URL.createObjectURL(file)
  if (target === 'thumbnail') form.image = src
  if (target === 'block' && block) block.src = src
  event.target.value = ''
}

const savePost = () => {
  if (!form.slug) form.slug = toSlug(form.title)
  if (!form.seoTitle) form.seoTitle = form.title
  if (!form.seoDescription) form.seoDescription = form.excerpt

  const payload = {
    ...form,
    blocks: form.blocks.map((block) => ({ ...block })),
    content: buildHtml(),
  }

  if (mode.value === 'create') {
    store.posts.unshift({ id: Date.now(), ...payload })
    toast.success('Đã thêm bài viết thành công')
  } else if (editingPost.value) {
    Object.assign(editingPost.value, payload)
    toast.success('Đã cập nhật bài viết thành công')
  }

  router.push('/admin/posts')
}
</script>

<template>
  <section class="grid gap-6">
    <div class="flex flex-col justify-between gap-4 lg:flex-row lg:items-center">
      <div>
        <RouterLink to="/admin/posts" class="text-sm font-black text-avocado-700 hover:text-avocado-900">← Quay lại danh sách</RouterLink>
        <h2 class="mt-3 text-3xl font-black text-avocado-950">
          {{ mode === 'create' ? 'Soạn bài viết mới' : 'Chỉnh sửa bài viết' }}
        </h2>
        <p class="mt-2 text-slate-600">Tối ưu cho bài SEO, review địa điểm ăn uống và nội dung thương hiệu ALOO.</p>
      </div>
      <button class="rounded-xl bg-[#2D5A27] px-5 py-3 font-black text-white hover:bg-[#24491f]" @click="savePost">
        Lưu bài viết
      </button>
    </div>

    <div class="grid gap-3 rounded-xl border border-avocado-100 bg-avocado-50 p-5 lg:grid-cols-3">
      <button class="rounded-lg bg-white px-4 py-3 text-sm font-black text-avocado-800 shadow-sm hover:bg-cream-100" @click="applyTemplate('review')">Template Review quán</button>
      <button class="rounded-lg bg-white px-4 py-3 text-sm font-black text-avocado-800 shadow-sm hover:bg-cream-100" @click="applyTemplate('brand')">Template Giới thiệu thương hiệu</button>
      <button class="rounded-lg bg-white px-4 py-3 text-sm font-black text-avocado-800 shadow-sm hover:bg-cream-100" @click="applyTemplate('seo')">Template SEO địa điểm</button>
    </div>

    <div class="grid gap-6 xl:grid-cols-[1fr_360px]">
      <div class="grid gap-6">
        <section class="grid gap-4 rounded-xl border border-slate-200 bg-white p-5 md:grid-cols-2">
          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">Thông tin bài viết</h3>
          <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            Tiêu đề bài viết
            <input v-model="form.title" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" @blur="form.slug ||= toSlug(form.title)" />
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            Slug SEO
            <input v-model="form.slug" required class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            Danh mục
            <select v-model="form.category" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500">
              <option v-for="category in categories" :key="category" :value="category">{{ category }}</option>
            </select>
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            Trạng thái
            <select v-model="form.status" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500">
              <option v-for="status in statuses" :key="status" :value="status">{{ status }}</option>
            </select>
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            Ngày đăng
            <input v-model="form.publishedAt" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
            Mô tả ngắn
            <textarea v-model="form.excerpt" rows="3" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
          </label>
        </section>

        <section class="grid gap-4 rounded-xl border border-slate-200 bg-white p-5 md:grid-cols-[1fr_240px]">
          <div>
            <h3 class="text-lg font-black text-avocado-950">Ảnh đại diện</h3>
            <p class="mt-1 text-sm text-slate-500">Có thể nhập URL hoặc upload file local để preview.</p>
            <div class="mt-4 grid gap-3">
              <input v-model="form.image" placeholder="https://..." class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
              <input type="file" accept="image/*" class="rounded-lg border border-slate-200 px-4 py-3 text-sm font-semibold text-slate-600" @change="uploadImage($event, 'thumbnail')" />
            </div>
          </div>
          <div class="overflow-hidden rounded-xl border border-slate-200 bg-slate-50">
            <img v-if="form.image" :src="form.image" alt="" class="h-full min-h-44 w-full object-cover" />
            <div v-else class="grid min-h-44 place-items-center text-sm font-semibold text-slate-400">Chưa có ảnh</div>
          </div>
        </section>

        <section class="grid gap-4 rounded-xl border border-slate-200 bg-white p-5">
          <div class="flex flex-col justify-between gap-4 lg:flex-row lg:items-center">
            <div>
              <h3 class="text-lg font-black text-avocado-950">Nội dung chính</h3>
              <p class="mt-1 text-sm text-slate-500">Thêm từng block, không cần nhập markdown hoặc URL ảnh thủ công.</p>
            </div>
            <div class="flex flex-wrap gap-2">
              <button class="rounded-lg border border-slate-200 px-3 py-2 text-sm font-black text-slate-700 hover:bg-slate-50" @click="addBlock('heading')">+ Heading</button>
              <button class="rounded-lg border border-slate-200 px-3 py-2 text-sm font-black text-slate-700 hover:bg-slate-50" @click="addBlock('paragraph')">+ Đoạn văn</button>
              <button class="rounded-lg border border-slate-200 px-3 py-2 text-sm font-black text-slate-700 hover:bg-slate-50" @click="addBlock('list')">+ Bullet list</button>
              <button class="rounded-lg border border-slate-200 px-3 py-2 text-sm font-black text-slate-700 hover:bg-slate-50" @click="addBlock('image')">+ Ảnh</button>
              <button class="rounded-lg border border-slate-200 px-3 py-2 text-sm font-black text-slate-700 hover:bg-slate-50" @click="addBlock('quote')">+ Quote</button>
            </div>
          </div>

          <div class="grid gap-4">
            <article v-for="block in form.blocks" :key="block.id" class="rounded-xl border border-slate-200 bg-slate-50 p-4">
              <div class="mb-3 flex items-center justify-between gap-3">
                <span class="text-xs font-black uppercase text-avocado-700">{{ block.type }}</span>
                <button class="rounded-lg px-3 py-1 text-sm font-bold text-red-600 hover:bg-red-50" @click="removeBlock(block.id)">Xóa</button>
              </div>
              <input v-if="block.type === 'heading'" v-model="block.text" class="w-full rounded-lg border border-slate-200 px-4 py-3 text-lg font-black outline-none focus:border-avocado-500" />
              <textarea v-if="block.type === 'paragraph' || block.type === 'quote'" v-model="block.text" rows="4" class="w-full rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
              <textarea v-if="block.type === 'list'" v-model="block.text" rows="4" class="w-full rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" placeholder="Mỗi dòng là một bullet"></textarea>
              <div v-if="block.type === 'image'" class="grid gap-3">
                <input type="file" accept="image/*" class="rounded-lg border border-slate-200 bg-white px-4 py-3 text-sm font-semibold text-slate-600" @change="uploadImage($event, 'block', block)" />
                <input v-model="block.alt" placeholder="Mô tả ảnh" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
                <img v-if="block.src" :src="block.src" alt="" class="max-h-80 w-full rounded-xl object-cover" />
              </div>
            </article>
          </div>
        </section>

        <section class="grid gap-4 rounded-xl border border-slate-200 bg-white p-5 md:grid-cols-2">
          <h3 class="text-lg font-black text-avocado-950 md:col-span-2">Thông tin liên hệ cuối bài</h3>
          <input v-model="form.contactName" placeholder="Tên địa điểm/thương hiệu" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
          <input v-model="form.contactPhone" placeholder="Hotline" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
          <input v-model="form.contactAddress" placeholder="Địa chỉ" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500 md:col-span-2" />
          <input v-model="form.openingHours" placeholder="Giờ mở cửa" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
          <input v-model="form.fanpage" placeholder="Fanpage" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </section>

        <section class="grid gap-4 rounded-xl border border-slate-200 bg-white p-5">
          <h3 class="text-lg font-black text-avocado-950">SEO</h3>
          <input v-model="form.seoTitle" placeholder="SEO title" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
          <textarea v-model="form.seoDescription" rows="3" placeholder="SEO description" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500"></textarea>
        </section>
      </div>

      <aside class="h-fit rounded-xl border border-avocado-100 bg-white p-5 shadow-sm xl:sticky xl:top-6">
        <h3 class="text-lg font-black text-avocado-950">Preview nhanh</h3>
        <img v-if="form.image" :src="form.image" alt="" class="mt-4 aspect-video w-full rounded-xl object-cover" />
        <div class="mt-4 text-xs font-black uppercase text-avocado-700">{{ form.category }}</div>
        <h1 class="mt-2 text-2xl font-black text-avocado-950">{{ form.title || 'Tiêu đề bài viết' }}</h1>
        <p class="mt-3 text-sm leading-6 text-slate-600">{{ form.excerpt || 'Mô tả ngắn của bài viết.' }}</p>
        <div class="mt-5 border-t border-slate-100 pt-4 text-sm text-slate-600">
          <p class="font-black text-avocado-950">{{ form.contactName }}</p>
          <p>{{ form.contactAddress }}</p>
          <p>{{ form.contactPhone }}</p>
          <p>{{ form.openingHours }}</p>
        </div>
      </aside>
    </div>
  </section>
</template>
