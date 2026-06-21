<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import RichTextEditor from '../../components/admin/RichTextEditor.vue'
import { useAdminModuleI18n } from '../../composables/useAdminModuleI18n'
import { uploadService } from '../../services/cmsService'
import { useAppStore } from '../../stores/appStore'
import { useToastStore } from '../../stores/toastStore'
import { adminPaths } from '../../constants/adminPaths'

const route = useRoute()
const router = useRouter()
const store = useAppStore()
const toast = useToastStore()
const { m } = useAdminModuleI18n('articleEditor')

const articleId = computed(() => Number(route.params.id))
const isEdit = computed(() => Number.isFinite(articleId.value) && articleId.value > 0)

const statusValues = ['DRAFT', 'PENDING', 'REVIEWING', 'APPROVED', 'PUBLISHED', 'ARCHIVED']
const statuses = computed(() =>
  statusValues.map((value) => ({
    value,
    label: m(`statuses.${value}`),
  })),
)
const articleCategories = computed(() =>
  store.categories
    .filter((category) => category.type === 'ARTICLE' && category.status === 'ACTIVE')
    .sort((a, b) => a.sortOrder - b.sortOrder),
)

const normalizeStatus = (status) => {
  if (status === 'Đã đăng') return 'PUBLISHED'
  if (status === 'Bản nháp') return 'DRAFT'
  if (status === 'Lên lịch') return 'PENDING'
  if (status === 'Ẩn') return 'ARCHIVED'
  return status || 'DRAFT'
}

const existingArticle = computed(() => store.posts.find((post) => post.id === articleId.value))
const draftKey = computed(() => `aloo_article_draft_${isEdit.value ? articleId.value : 'new'}`)

const createDefaultForm = () => ({
  id: null,
  title: '',
  slug: '',
  author: 'ALOO Editorial',
  source: '',
  sourceLink: '',
  category: articleCategories.value[0]?.name || 'Review',
  status: 'DRAFT',
  publishedAt: new Date().toISOString().slice(0, 10),
  image: '',
  gallery: [],
  excerpt: '',
  tagsText: '',
  relatedPostIds: [],
  seoTitle: '',
  metaKeywords: '',
  metaDescription: '',
  canonicalUrl: '',
  content: '<h2>Giới thiệu</h2><p>Nhập nội dung bài viết tại đây.</p>',
})

const form = reactive(createDefaultForm())
const galleryInput = ref(null)
const initialized = ref(false)
const isUploadingImages = ref(false)

const hydrateForm = () => {
  const storedDraft = localStorage.getItem(draftKey.value)
  const source = storedDraft ? JSON.parse(storedDraft) : existingArticle.value

  Object.assign(form, createDefaultForm())

  if (source) {
    form.id = source.id || null
    form.title = source.title || ''
    form.slug = source.slug || ''
    form.author = source.author || 'ALOO Editorial'
    form.source = source.source || ''
    form.sourceLink = source.sourceLink || ''
    form.category = source.category || 'Review'
    form.status = normalizeStatus(source.status)
    form.publishedAt = String(source.publishedAt || source.date || new Date().toISOString()).slice(0, 10)
    form.image = source.image || source.thumbnailUrl || ''
    form.gallery = Array.isArray(source.gallery) ? [...source.gallery] : []
    form.excerpt = source.excerpt || ''
    form.tagsText = Array.isArray(source.tags) ? source.tags.join(', ') : source.tagsText || ''
    form.relatedPostIds = Array.isArray(source.relatedPostIds) ? [...source.relatedPostIds] : []
    form.seoTitle = source.seoTitle || source.title || ''
    form.metaKeywords = source.metaKeywords || ''
    form.metaDescription = source.metaDescription || source.excerpt || ''
    form.canonicalUrl = source.canonicalUrl || ''
    form.content = source.content || createDefaultForm().content
  }

  initialized.value = true
}

watch(
  () => form.title,
  (title) => {
    if (!form.slug) {
      form.slug = title
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/(^-|-$)/g, '')
    }
    if (!form.seoTitle) form.seoTitle = title
  },
)

watch(
  form,
  () => {
    if (initialized.value) {
      localStorage.setItem(draftKey.value, JSON.stringify(form))
    }
  },
  { deep: true },
)

const relatedArticles = computed(() => store.posts.filter((post) => post.id !== form.id))

const tags = computed(() =>
  form.tagsText
    .split(',')
    .map((tag) => tag.trim())
    .filter(Boolean),
)

const seoScore = computed(() => {
  let score = 0
  if (form.seoTitle.length >= 35 && form.seoTitle.length <= 70) score += 25
  if (form.metaDescription.length >= 120 && form.metaDescription.length <= 160) score += 25
  if (form.slug) score += 15
  if (form.image) score += 15
  if (form.content.length >= 700) score += 15
  if (tags.value.length) score += 5
  return Math.min(score, 100)
})

const toDateInputValue = (date) => {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

const publishedAtDisplay = computed(() => {
  if (!form.publishedAt) return 'Chưa chọn ngày đăng'

  const date = new Date(`${form.publishedAt}T00:00:00`)
  if (Number.isNaN(date.getTime())) return 'Ngày đăng chưa hợp lệ'

  return new Intl.DateTimeFormat('vi-VN', {
    weekday: 'long',
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(date)
})

const setPublishedDate = (daysFromToday) => {
  const date = new Date()
  date.setDate(date.getDate() + daysFromToday)
  form.publishedAt = toDateInputValue(date)
}

const handleThumbnailUpload = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  isUploadingImages.value = true
  try {
    const { data } = await uploadService.image(file)
    form.image = data.url
    toast.success(m('toasts.coverUploaded'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.coverError'))
  } finally {
    isUploadingImages.value = false
    event.target.value = ''
  }
}

const handleGalleryUpload = async (event) => {
  const files = Array.from(event.target.files || [])
  if (!files.length) return

  isUploadingImages.value = true
  try {
    const uploaded = await Promise.all(files.map((file) => uploadService.image(file)))
    form.gallery.push(...uploaded.map((result) => result.data.url))
    toast.success(m('toasts.galleryUploaded'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.galleryError'))
  } finally {
    isUploadingImages.value = false
    event.target.value = ''
  }
}

const removeGalleryImage = (image) => {
  form.gallery = form.gallery.filter((item) => item !== image)
}

const removeThumbnailImage = () => {
  form.image = ''
}

const validateForm = () => {
  if (!form.title.trim()) {
    toast.error(m('toasts.titleRequired'))
    return false
  }
  if (!form.slug.trim()) {
    toast.error(m('toasts.slugRequired'))
    return false
  }
  return true
}

const buildPayload = (status) => ({
  id: form.id,
  title: form.title.trim(),
  slug: form.slug.trim(),
  author: form.author.trim(),
  source: form.source.trim(),
  sourceLink: form.sourceLink.trim(),
  category: form.category,
  status,
  publishedAt: form.publishedAt,
  image: form.image,
  thumbnailUrl: form.image,
  gallery: [...form.gallery],
  excerpt: form.excerpt.trim(),
  tags: tags.value,
  relatedPostIds: [...form.relatedPostIds],
  seoTitle: form.seoTitle.trim(),
  seoDescription: form.metaDescription.trim() || form.excerpt.trim(),
  metaKeywords: form.metaKeywords.trim(),
  metaDescription: form.metaDescription.trim(),
  canonicalUrl: form.canonicalUrl.trim(),
  content: form.content,
})

const saveArticle = async (status) => {
  if (!validateForm()) return
  form.status = status
  const payload = buildPayload(status)

  try {
    await store.savePost(payload)
    toast.success(status === 'PUBLISHED' ? m('toasts.published') : m('toasts.draftSaved'))
    localStorage.removeItem(draftKey.value)
    router.push(adminPaths.content.articles)
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.saveError'))
  }
}

onMounted(async () => {
  await Promise.allSettled([store.fetchCategories(), store.fetchPosts()])
  hydrateForm()
})
</script>

<template>
  <section class="space-y-6">
    <div class="sticky top-16 z-20 -mx-4 border-b border-slate-200 bg-slate-50/95 px-4 py-4 backdrop-blur md:-mx-8 md:px-8">
      <div class="flex flex-col justify-between gap-4 lg:flex-row lg:items-center">
        <div>
          <RouterLink :to="adminPaths.content.articles" class="text-sm font-black text-avocado-700 hover:text-avocado-900">
            {{ m('backToList') }}
          </RouterLink>
          <h1 class="mt-2 text-3xl font-black text-avocado-950">
            {{ isEdit ? m('editTitle') : m('createTitle') }}
          </h1>
        </div>
        <div class="flex flex-wrap gap-3">
          <button type="button" class="rounded-xl border border-slate-200 bg-white px-5 py-3 font-black text-slate-700 hover:bg-slate-50" @click="router.push(adminPaths.content.articles)">
            {{ m('exit') }}
          </button>
          <button type="button" class="rounded-xl border border-avocado-200 bg-white px-5 py-3 font-black text-avocado-700 hover:bg-avocado-50 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isUploadingImages" @click="saveArticle('DRAFT')">
            {{ m('saveDraft') }}
          </button>
          <button type="button" class="rounded-xl bg-brand-forest px-5 py-3 font-black text-white shadow-sm hover:bg-avocado-800 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isUploadingImages" @click="saveArticle('PUBLISHED')">
            {{ m('saveAndPublish') }}
          </button>
        </div>
      </div>
    </div>

    <div class="grid gap-6 xl:grid-cols-[minmax(0,1fr)_360px]">
      <div class="space-y-6">
        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 class="text-xl font-black text-avocado-950">Thông tin bài viết</h2>
          <div class="mt-5 grid gap-4 md:grid-cols-2">
            <label class="space-y-2 md:col-span-2">
              <span class="text-sm font-black text-slate-700">{{ m('fields.title') }}</span>
              <input v-model="form.title" class="admin-input" :placeholder="m('placeholders.title')" />
            </label>
            <label class="space-y-2">
              <span class="text-sm font-black text-slate-700">{{ m('fields.slug') }}</span>
              <input v-model="form.slug" class="admin-input" :placeholder="m('placeholders.slug')" />
            </label>
            <label class="space-y-2">
              <span class="text-sm font-black text-slate-700">{{ m('fields.category') }}</span>
              <select v-model="form.category" class="admin-input">
                <option v-for="category in articleCategories" :key="category.id" :value="category.name">{{ category.name }}</option>
              </select>
            </label>
            <label class="space-y-2">
              <span class="text-sm font-black text-slate-700">{{ m('fields.author') }}</span>
              <input v-model="form.author" class="admin-input" />
            </label>
            <label class="space-y-2">
              <span class="text-sm font-black text-slate-700">{{ m('fields.source') }}</span>
              <input v-model="form.source" class="admin-input" :placeholder="m('placeholders.source')" />
            </label>
            <label class="space-y-2">
              <span class="text-sm font-black text-slate-700">{{ m('fields.sourceLink') }}</span>
              <input v-model="form.sourceLink" class="admin-input" :placeholder="m('placeholders.sourceLink')" />
            </label>
            <label class="space-y-2 md:col-span-2">
              <span class="text-sm font-black text-slate-700">{{ m('fields.excerpt') }}</span>
              <textarea v-model="form.excerpt" rows="3" class="admin-input resize-none" :placeholder="m('placeholders.excerpt')" />
            </label>
          </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div class="grid gap-4 md:grid-cols-[minmax(0,1fr)_220px] md:items-start">
            <div class="max-w-xl">
              <h2 class="text-xl font-black text-avocado-950">{{ m('upload.title') }}</h2>
              <p class="mt-1 text-sm text-slate-500">Ảnh upload được lưu vào backend và dùng lại ở public blog.</p>
            </div>
            <div class="grid gap-2 sm:grid-cols-2 md:grid-cols-1">
              <label class="inline-flex min-h-12 cursor-pointer items-center justify-center rounded-xl border border-avocado-200 px-4 py-3 text-center text-sm font-black text-avocado-700 transition hover:bg-avocado-50">
                {{ isUploadingImages ? m('upload.uploading') : m('upload.cover') }}
                <input type="file" accept="image/*" class="hidden" :disabled="isUploadingImages" @change="handleThumbnailUpload" />
              </label>
              <label class="inline-flex min-h-12 cursor-pointer items-center justify-center rounded-xl border border-slate-200 px-4 py-3 text-center text-sm font-black text-slate-700 transition hover:bg-slate-50">
                {{ isUploadingImages ? m('upload.uploading') : m('upload.gallery') }}
                <input ref="galleryInput" type="file" accept="image/*" multiple class="hidden" :disabled="isUploadingImages" @change="handleGalleryUpload" />
              </label>
            </div>
          </div>

          <div class="mt-5 grid gap-4 lg:grid-cols-[280px_1fr]">
            <div class="group relative overflow-hidden rounded-xl border border-slate-200 bg-slate-50">
              <img v-if="form.image" :src="form.image" alt="Article thumbnail" class="h-48 w-full object-cover" />
              <div v-else class="flex h-48 items-center justify-center text-sm font-bold text-slate-400">Chưa có ảnh đại diện</div>
              <button
                v-if="form.image"
                type="button"
                class="absolute right-3 top-3 rounded-xl bg-white/95 px-3 py-2 text-xs font-black text-red-600 shadow-sm ring-1 ring-red-100 transition hover:bg-red-50"
                @click="removeThumbnailImage"
              >
                {{ m('upload.removeImage') }}
              </button>
            </div>
            <div>
              <label class="space-y-2">
                <span class="text-sm font-black text-slate-700">{{ m('fields.coverImage') }}</span>
                <input v-model="form.image" class="admin-input" :placeholder="m('placeholders.image')" />
              </label>
              <div class="mt-4 grid grid-cols-2 gap-3 md:grid-cols-4">
                <div v-for="image in form.gallery" :key="image" class="group relative overflow-hidden rounded-xl border border-slate-200">
                  <img :src="image" alt="Gallery" class="h-24 w-full object-cover" />
                  <button type="button" class="absolute right-2 top-2 rounded-full bg-white/90 px-2 py-1 text-xs font-black text-red-600 shadow sm:opacity-0 sm:group-hover:opacity-100" @click="removeGalleryImage(image)">
                    Xóa
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div class="mb-5 flex flex-col justify-between gap-2 md:flex-row md:items-end">
            <div>
              <h2 class="text-xl font-black text-avocado-950">Nội dung bài viết</h2>
              <p class="mt-1 text-sm text-slate-500">Hỗ trợ heading, bảng, link, ảnh, quote, list và kéo thả ảnh vào editor.</p>
            </div>
          </div>
          <RichTextEditor v-model="form.content" />
        </div>
      </div>

      <aside class="space-y-6">
        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 class="text-xl font-black text-avocado-950">Bảng xuất bản</h2>
          <div class="mt-5 space-y-4">
            <label class="space-y-2">
              <span class="text-sm font-black text-slate-700">{{ m('fields.status') }}</span>
              <select v-model="form.status" class="admin-input">
                <option v-for="status in statuses" :key="status.value" :value="status.value">{{ status.label }}</option>
              </select>
            </label>
            <label class="space-y-2">
              <span class="text-sm font-black text-slate-700">{{ m('fields.publishedAt') }}</span>
              <input v-model="form.publishedAt" type="date" class="admin-input" />
              <p class="rounded-xl bg-slate-50 px-3 py-2 text-xs font-bold text-slate-600">
                {{ publishedAtDisplay }}
              </p>
              <div class="grid grid-cols-3 gap-2">
                <button
                  type="button"
                  class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-xs font-black text-slate-700 transition hover:border-avocado-200 hover:bg-avocado-50 hover:text-avocado-800"
                  @click="setPublishedDate(0)"
                >
                  Hôm nay
                </button>
                <button
                  type="button"
                  class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-xs font-black text-slate-700 transition hover:border-avocado-200 hover:bg-avocado-50 hover:text-avocado-800"
                  @click="setPublishedDate(1)"
                >
                  Ngày mai
                </button>
                <button
                  type="button"
                  class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-xs font-black text-slate-700 transition hover:border-avocado-200 hover:bg-avocado-50 hover:text-avocado-800"
                  @click="setPublishedDate(7)"
                >
                  Tuần sau
                </button>
              </div>
            </label>
            <div class="rounded-xl bg-avocado-50 p-4">
              <p class="text-sm font-black text-avocado-900">Tự lưu bản nháp</p>
              <p class="mt-1 text-sm text-avocado-800">Bản nháp được lưu vào localStorage trong lúc soạn.</p>
            </div>
          </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <div class="flex items-center justify-between gap-3">
            <h2 class="text-xl font-black text-avocado-950">SEO panel</h2>
            <span class="rounded-full px-3 py-1 text-sm font-black" :class="seoScore >= 70 ? 'bg-green-50 text-green-700' : 'bg-orange-50 text-orange-700'">
              {{ seoScore }}/100
            </span>
          </div>
          <div class="mt-5 space-y-4">
            <label class="space-y-2">
              <span class="flex justify-between text-sm font-black text-slate-700">
                {{ m('fields.metaTitle') }}
                <small class="text-slate-500">{{ form.seoTitle.length }}/70</small>
              </span>
              <input v-model="form.seoTitle" class="admin-input" />
            </label>
            <label class="space-y-2">
              <span class="text-sm font-black text-slate-700">{{ m('fields.metaKeywords') }}</span>
              <input v-model="form.metaKeywords" class="admin-input" :placeholder="m('placeholders.metaKeywords')" />
            </label>
            <label class="space-y-2">
              <span class="flex justify-between text-sm font-black text-slate-700">
                {{ m('fields.metaDescription') }}
                <small class="text-slate-500">{{ form.metaDescription.length }}/160</small>
              </span>
              <textarea v-model="form.metaDescription" rows="4" class="admin-input resize-none" />
            </label>
            <label class="space-y-2">
              <span class="text-sm font-black text-slate-700">Canonical URL</span>
              <input v-model="form.canonicalUrl" class="admin-input" placeholder="https://aloo.vn/blog/..." />
            </label>
          </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 class="text-xl font-black text-avocado-950">Tags</h2>
          <label class="mt-4 block space-y-2">
            <span class="text-sm font-black text-slate-700">Tags, cách nhau bằng dấu phẩy</span>
            <textarea v-model="form.tagsText" rows="3" class="admin-input resize-none" placeholder="kem bơ, review, Quy Nhơn" />
          </label>
          <div v-if="tags.length" class="mt-4 flex flex-wrap gap-2">
            <span v-for="tag in tags" :key="tag" class="rounded-full bg-cream-100 px-3 py-1 text-xs font-black text-avocado-800">#{{ tag }}</span>
          </div>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
          <h2 class="text-xl font-black text-avocado-950">Tin liên quan</h2>
          <div class="mt-4 max-h-72 space-y-3 overflow-y-auto pr-1">
            <label v-for="post in relatedArticles" :key="post.id" class="flex items-start gap-3 rounded-xl border border-slate-100 p-3 text-sm hover:bg-slate-50">
              <input v-model="form.relatedPostIds" type="checkbox" :value="post.id" class="mt-1 h-4 w-4 rounded border-slate-300 text-avocado-700" />
              <span>
                <span class="line-clamp-2 font-bold text-slate-800">{{ post.title }}</span>
                <span class="mt-1 block text-xs text-slate-500">{{ post.category }}</span>
              </span>
            </label>
          </div>
        </div>
      </aside>
    </div>
  </section>
</template>

<style scoped>
.admin-input {
  width: 100%;
  border-radius: 0.8rem;
  border: 1px solid rgb(226 232 240);
  background: white;
  padding: 0.85rem 1rem;
  color: rgb(15 23 42);
  outline: none;
  transition: border-color 150ms ease, box-shadow 150ms ease;
}

.admin-input:focus {
  border-color: rgb(45 90 39);
  box-shadow: 0 0 0 3px rgb(45 90 39 / 0.1);
}
</style>
