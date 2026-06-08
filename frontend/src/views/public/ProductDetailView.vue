<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { ArrowLeft, ArrowRight, CheckCircle2, Leaf, MessageCircle, Sparkles, Star } from 'lucide-vue-next'
import { feedbackService, productService, resolveBackendAssetUrl } from '../../services/cmsService'
import { setSeoMeta } from '../../services/seoService'
import { useAppStore } from '../../stores/appStore'

const route = useRoute()
const store = useAppStore()
const product = ref(null)
const isLoading = ref(false)
const errorMessage = ref('')
const activeImageIndex = ref(0)
const feedbacks = ref([])

const splitLines = (value) =>
  String(value || '')
    .split(/\r?\n|;/)
    .map((item) => item.trim())
    .filter(Boolean)

const parseFaqs = (value) =>
  String(value || '')
    .split(/\r?\n/)
    .map((line) => {
      const [question, ...answerParts] = line.split('|')
      return {
        question: question?.trim(),
        answer: answerParts.join('|').trim(),
      }
    })
    .filter((item) => item.question && item.answer)

const galleryImages = computed(() => {
  const images = splitLines(product.value?.gallery).map(resolveBackendAssetUrl)
  const primary = resolveBackendAssetUrl(product.value?.imageUrl || product.value?.image || '')
  return [primary, ...images].filter(Boolean).filter((item, index, array) => array.indexOf(item) === index)
})

const ingredients = computed(() => splitLines(product.value?.ingredients))
const tasteItems = computed(() => splitLines(product.value?.tasteProfile))
const servingItems = computed(() => splitLines(product.value?.servingSuggestion))
const faqs = computed(() => parseFaqs(product.value?.faqs))
const averageFeedbackRating = computed(() => {
  if (!feedbacks.value.length) return null
  const total = feedbacks.value.reduce((sum, feedback) => sum + Number(feedback.rating || 0), 0)
  return Math.round((total / feedbacks.value.length) * 10) / 10
})
const feedbackCountLabel = computed(() =>
  feedbacks.value.length ? `${feedbacks.value.length} cảm nhận` : 'Chưa có cảm nhận',
)

const formatFeedbackDate = (value) => {
  if (!value) return ''
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return String(value).slice(0, 16)
  const pad = (number) => String(number).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}`
}

const customerInitial = (name) => String(name || '?').trim().charAt(0).toUpperCase() || '?'

const feedbackContext = (feedback) => {
  const parts = []
  if (feedback.storeName) parts.push(feedback.storeName)
  return parts.join(' | ')
}

// Premium dynamic fallback properties when details are not set in the CMS database
const finalIngredients = computed(() => {
  if (ingredients.value.length) return ingredients.value
  const slug = product.value?.slug || ''
  if (slug.includes('sau-rieng')) {
    return [
      'Bơ sáp chín tự nhiên từ Đắk Lắk',
      'Sầu riêng tươi nguyên hạt loại 1',
      'Kem dừa ALOO premium',
      'Topping dừa khô sấy giòn độc quyền'
    ]
  }
  if (slug.includes('dua')) {
    return [
      'Bơ sáp chín tự nhiên từ Đắk Lắk',
      'Kem dừa ALOO premium ngọt mát',
      'Cùi dừa tươi nạo sợi mỏng',
      'Topping dừa khô sấy giòn độc quyền'
    ]
  }
  if (slug.includes('ca-phe') || slug.includes('coffee')) {
    return [
      'Bơ sáp chín tự nhiên từ Đắk Lắk',
      'Cà phê espresso Robusta đậm đà',
      'Sữa đặc organic chất lượng cao',
      'Topping dừa khô sấy giòn'
    ]
  }
  return [
    'Bơ sáp nguyên chất tuyển lựa kỹ càng',
    'Kem tươi cốt dừa béo mịn thơm dịu',
    'Sữa đặc béo thơm hảo hạng',
    'Topping dừa sấy khô thơm giòn rụm'
  ]
})

const finalTasteProfile = computed(() => {
  if (tasteItems.value.length) return tasteItems.value
  const slug = product.value?.slug || ''
  if (slug.includes('sau-rieng')) {
    return [
      'Hương sầu riêng nồng nàn quyến rũ',
      'Vị bơ sáp béo ngậy đặc trưng Đắk Lắk',
      'Vị ngọt thanh của kem cốt dừa lạnh mát',
      'Độ giòn tan của dừa khô sấy phủ bên trên'
    ]
  }
  return [
    'Béo ngậy tự nhiên từ bơ sáp Tây Nguyên',
    'Ngọt thanh sảng khoái từ kem tươi dừa',
    'Thơm nhẹ dịu của nông sản tươi tự nhiên',
    'Vị giòn giòn vui miệng từ topping dừa sấy'
  ]
})

const finalServingSuggestion = computed(() => {
  if (servingItems.value.length) return servingItems.value
  return [
    'Trộn đều nhẹ nhàng kem dừa và nền bơ trước khi ăn',
    'Thưởng thức ngay khi kem vừa được dọn ra để giữ độ mát lạnh',
    'Dùng kèm một ly nước lọc ấm để làm sạch vòm họng sau khi thưởng thức'
  ]
})

const relatedProducts = computed(() =>
  store.products
    .filter((item) => item.id !== product.value?.id)
    .filter((item) => ['ACTIVE', 'Đang bán'].includes(item.status))
    .filter((item) => !product.value?.category || item.category === product.value.category)
    .slice(0, 3),
)

const loadFeedbacks = async () => {
  try {
    if (!product.value?.id) {
      feedbacks.value = []
      return
    }
    const { data } = await feedbackService.listVisible()
    feedbacks.value = Array.isArray(data) ? data : []
  } catch {
    feedbacks.value = []
  }
}

const loadProduct = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const { data } = await productService.getBySlug(route.params.slug)
    product.value = store.normalizeProduct(data)
    activeImageIndex.value = 0 // Reset active image to primary image
    await loadFeedbacks()
    document.title = `${product.value.seoTitle || product.value.name} | ALOO`
    setSeoMeta({
      title: `${product.value.seoTitle || product.value.name} | ALOO`,
      description: product.value.seoDescription || product.value.shortDescription || product.value.description || 'Sản phẩm hiển thị trong menu ALOO.',
      image: product.value.imageUrl || '/logo-aloo.png',
      url: window.location.href,
      type: 'article',
    })
    if (!store.products.length) await store.fetchProducts()
  } catch (error) {
    errorMessage.value = error.response?.data?.message || 'Không tìm thấy sản phẩm hoặc sản phẩm chưa được công khai.'
    document.title = 'Không tìm thấy sản phẩm | ALOO'
  } finally {
    isLoading.value = false
  }
}

onMounted(loadProduct)
watch(() => route.params.slug, loadProduct)
</script>

<template>
  <main class="min-h-screen bg-[#F8FAF7] pb-20 text-brand-dark">
    <section v-if="isLoading" class="mx-auto max-w-[1280px] px-4 py-20 sm:px-6 lg:px-8">
      <div class="grid gap-10 lg:grid-cols-2">
        <div class="aspect-[4/3] animate-pulse rounded-[2rem] bg-white border border-brand-forest/5 shadow-sm"></div>
        <div class="space-y-5 py-8">
          <div class="h-4 w-32 animate-pulse rounded bg-white"></div>
          <div class="h-14 w-4/5 animate-pulse rounded bg-white"></div>
          <div class="h-5 w-full animate-pulse rounded bg-white"></div>
          <div class="h-5 w-3/4 animate-pulse rounded bg-white"></div>
        </div>
      </div>
    </section>

    <section v-else-if="errorMessage" class="mx-auto max-w-3xl px-4 py-24 text-center sm:px-6 lg:px-8 animate-fade-in">
      <div class="rounded-[2.5rem] border border-brand-forest/5 bg-white p-12 shadow-md">
        <p class="text-xs font-black uppercase tracking-[0.25em] text-brand-forest">Sản phẩm</p>
        <h1 class="mt-4 text-3xl font-black text-brand-dark font-display">Không tìm thấy sản phẩm</h1>
        <p class="mt-3 text-sm leading-relaxed text-brand-muted">{{ errorMessage }}</p>
        <RouterLink to="/products" class="mt-8 inline-flex items-center gap-2 rounded-full bg-brand-lime hover:bg-brand-lime/90 transition px-7 py-3.5 text-xs font-black uppercase tracking-wider text-brand-dark shadow-md active:scale-98">
          <ArrowLeft class="h-4 w-4" /> Quay lại menu
        </RouterLink>
      </div>
    </section>

    <template v-else-if="product">
      <section class="bg-white px-4 py-12 sm:px-6 lg:px-8 lg:py-16">
        <div class="mx-auto max-w-[1280px]">
          <RouterLink to="/products" class="inline-flex w-fit items-center gap-2 rounded-full border border-brand-forest/10 bg-white px-4.5 py-2.5 text-xs font-black uppercase tracking-wider text-brand-forest shadow-sm transition hover:bg-brand-lime/10 active:scale-95">
            <ArrowLeft class="h-3.5 w-3.5" /> Menu ALOO
          </RouterLink>

          <div class="mt-8 grid gap-10 lg:grid-cols-[0.98fr_1.02fr] lg:items-center">
            <div class="space-y-4">
              <div class="overflow-hidden rounded-[2rem] border border-brand-forest/5 bg-brand-cream/30 p-3 shadow-xl">
                <img
                  v-if="galleryImages[activeImageIndex]"
                  :src="galleryImages[activeImageIndex]"
                  :alt="product.name"
                  class="aspect-[4/3] w-full rounded-[1.5rem] object-cover transition-all duration-300 hover:scale-[1.01]"
                />
                <div v-else class="grid aspect-[4/3] place-items-center rounded-[1.5rem] bg-brand-lime/10 text-3xl font-black text-brand-forest">ALOO</div>
              </div>

              <div v-if="galleryImages.length > 1" class="flex flex-wrap gap-3">
                <button
                  v-for="(image, index) in galleryImages"
                  :key="image"
                  type="button"
                  class="aspect-[4/3] w-20 shrink-0 overflow-hidden rounded-2xl border-2 transition duration-250 hover:scale-[1.04] focus:outline-none sm:w-24"
                  :class="activeImageIndex === index ? 'border-brand-forest ring-3 ring-brand-lime/30 shadow-md' : 'border-transparent opacity-75 hover:opacity-100'"
                  @click="activeImageIndex = index"
                >
                  <img :src="image" :alt="product.name" class="h-full w-full object-cover" />
                </button>
              </div>
            </div>

            <div>
              <div class="flex flex-wrap items-center gap-3">
                <span class="inline-flex items-center gap-2 rounded-full bg-brand-lime/15 px-3.5 py-1.5 text-xs font-black uppercase tracking-[0.2em] text-brand-forest">
                  <Sparkles class="h-3.5 w-3.5" /> {{ product.category || 'Signature ALOO' }}
                </span>
                <span v-if="averageFeedbackRating" class="inline-flex items-center gap-1 rounded-full bg-brand-cream/70 px-3 py-1.5 text-xs font-black text-brand-muted">
                  <Star class="h-3.5 w-3.5 fill-brand-sand text-brand-sand" />
                  {{ averageFeedbackRating.toFixed(1) }} ({{ feedbackCountLabel }})
                </span>
                <span v-else class="rounded-full bg-brand-cream/70 px-3 py-1.5 text-xs font-black text-brand-muted">
                  Chưa có cảm nhận
                </span>
              </div>

              <h1 class="mt-5 max-w-3xl text-4xl font-black leading-tight text-brand-dark font-display sm:text-5xl lg:text-6xl">{{ product.name }}</h1>

              <p class="mt-5 max-w-2xl text-base font-medium leading-8 text-brand-muted">
                {{ product.shortDescription || product.description || 'Nội dung chi tiết sản phẩm đang được cập nhật trong Admin CMS.' }}
              </p>

              <div class="mt-7 grid gap-3 sm:grid-cols-3">
                <div class="rounded-2xl border border-brand-forest/5 bg-[#F8FAF7] p-4">
                  <p class="text-[10px] font-black uppercase tracking-[0.18em] text-brand-sand">Danh mục</p>
                  <p class="mt-1 text-sm font-black text-brand-forest">{{ product.category || 'Sản phẩm' }}</p>
                </div>
                <div class="rounded-2xl border border-brand-forest/5 bg-[#F8FAF7] p-4">
                  <p class="text-[10px] font-black uppercase tracking-[0.18em] text-brand-sand">Trạng thái</p>
                  <p class="mt-1 text-sm font-black text-brand-forest">Đang phục vụ</p>
                </div>
                <div class="rounded-2xl border border-brand-forest/5 bg-[#F8FAF7] p-4">
                  <p class="text-[10px] font-black uppercase tracking-[0.18em] text-brand-sand">Cảm nhận</p>
                  <p class="mt-1 text-sm font-black text-brand-forest">{{ feedbackCountLabel }}</p>
                </div>
              </div>

              <div class="mt-8 flex flex-wrap gap-4">
                <RouterLink to="/consultation" class="inline-flex items-center gap-2 rounded-full bg-brand-forest px-7 py-4 text-xs font-black uppercase tracking-wider text-white shadow-lg shadow-brand-forest/15 transition hover:bg-brand-dark active:scale-98">
                  Đăng ký hợp tác nhượng quyền <ArrowRight class="h-4 w-4" />
                </RouterLink>
                <RouterLink to="/locations" class="inline-flex items-center gap-2 rounded-full border border-brand-forest/15 bg-white px-7 py-4 text-xs font-black uppercase tracking-wider text-brand-forest transition hover:bg-brand-cream active:scale-98">
                  Tìm cửa hàng gần nhất
                </RouterLink>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="px-4 py-14 sm:px-6 lg:px-8 lg:py-18">
        <div class="mx-auto grid max-w-[1280px] gap-8 lg:grid-cols-[0.92fr_1.08fr]">
          <div class="lg:sticky lg:top-28 lg:self-start">
            <span class="text-xs font-black uppercase tracking-[0.25em] text-brand-forest">Câu chuyện sản phẩm</span>
            <h2 class="mt-3 text-3xl font-black text-brand-dark font-display lg:text-4xl">Điểm khác biệt của {{ product.name }}</h2>
            <p class="mt-5 whitespace-pre-line text-base font-medium leading-8 text-brand-muted">
              {{ product.detailContent || product.description || 'Hương vị bơ chín mịn cao cấp được làm mới hoàn toàn bằng công thức độc quyền từ ALOO.' }}
            </p>

            <div class="mt-8 flex flex-wrap gap-3">
              <RouterLink to="/products" class="inline-flex items-center gap-2 rounded-full border border-brand-forest/10 bg-white px-5 py-3 text-xs font-black uppercase tracking-wider text-brand-forest shadow-sm transition hover:bg-brand-lime/10">
                <ArrowLeft class="h-3.5 w-3.5" /> Menu ALOO
              </RouterLink>
            </div>
          </div>

          <div class="grid gap-5">
            <article class="rounded-[2rem] border border-brand-forest/5 bg-white p-7 shadow-sm">
              <div class="flex items-start gap-4">
                <div class="grid h-12 w-12 shrink-0 place-items-center rounded-2xl bg-brand-lime/10 text-brand-forest shadow-inner">
                  <Leaf class="h-6 w-6" />
                </div>
                <div>
                  <h3 class="text-xl font-black text-brand-dark font-display">Nguyên liệu chính</h3>
                  <ul class="mt-4 grid gap-3 text-sm font-semibold text-brand-muted">
                    <li v-for="item in finalIngredients" :key="item" class="flex gap-3">
                      <CheckCircle2 class="mt-0.5 h-5 w-5 shrink-0 text-brand-forest" />
                      <span>{{ item }}</span>
                    </li>
                  </ul>
                </div>
              </div>
            </article>

            <div class="grid gap-5 md:grid-cols-2">
              <article class="rounded-[2rem] border border-brand-forest/5 bg-white p-7 shadow-sm">
                <div class="grid h-12 w-12 place-items-center rounded-2xl bg-brand-sand/10 text-brand-brown shadow-inner">
                  <Star class="h-6 w-6" />
                </div>
                <h3 class="mt-5 text-xl font-black text-brand-dark font-display">Hồ sơ hương vị</h3>
                <ul class="mt-4 grid gap-3 text-sm font-semibold text-brand-muted">
                  <li v-for="item in finalTasteProfile" :key="item" class="flex gap-3">
                    <CheckCircle2 class="mt-0.5 h-5 w-5 shrink-0 text-brand-forest" />
                    <span>{{ item }}</span>
                  </li>
                </ul>
              </article>

              <article class="rounded-[2rem] border border-brand-forest/5 bg-white p-7 shadow-sm">
                <div class="grid h-12 w-12 place-items-center rounded-2xl bg-brand-lime/10 text-brand-forest shadow-inner">
                  <MessageCircle class="h-6 w-6" />
                </div>
                <h3 class="mt-5 text-xl font-black text-brand-dark font-display">Gợi ý thưởng thức</h3>
                <ul class="mt-4 grid gap-3 text-sm font-semibold text-brand-muted">
                  <li v-for="item in finalServingSuggestion" :key="item" class="flex gap-3">
                    <CheckCircle2 class="mt-0.5 h-5 w-5 shrink-0 text-brand-forest" />
                    <span>{{ item }}</span>
                  </li>
                </ul>
              </article>
            </div>
          </div>
        </div>
      </section>

      <section class="bg-white px-4 py-16 sm:px-6 lg:px-8">
        <div class="mx-auto max-w-[1280px]">
          <div class="border-b border-slate-100 pb-8">
            <span class="text-xs font-black uppercase tracking-[0.25em] text-brand-forest">Đánh giá trải nghiệm</span>
            <div class="mt-3 flex flex-col gap-5 lg:flex-row lg:items-end lg:justify-between">
              <div class="max-w-3xl">
                <h2 class="text-3xl font-black text-brand-dark font-display lg:text-4xl">Cảm nhận về {{ product.name }}</h2>
                <p class="mt-3 text-sm font-semibold leading-6 text-brand-muted">
                  Các cảm nhận đã được duyệt từ khách hàng sau khi trải nghiệm sản phẩm hoặc ghé chi nhánh ALOO.
                </p>
              </div>

              <div class="flex w-full max-w-sm items-center justify-between rounded-2xl border border-slate-100 bg-[#F8FAF7] px-5 py-4 lg:w-auto lg:min-w-[300px]">
                <div>
                  <p class="text-xs font-black uppercase tracking-[0.18em] text-slate-500">Tổng quan</p>
                  <p class="mt-1 text-sm font-bold text-brand-muted">{{ feedbackCountLabel }}</p>
                </div>
                <div class="text-right">
                  <div class="flex items-center justify-end gap-0.5 text-[#ee4d2d]">
                    <Star
                      v-for="star in 5"
                      :key="star"
                      class="h-4 w-4"
                      :class="averageFeedbackRating && star <= Math.round(averageFeedbackRating) ? 'fill-[#ee4d2d]' : 'fill-transparent text-slate-200'"
                    />
                  </div>
                  <p class="mt-1 text-2xl font-black text-brand-dark">{{ averageFeedbackRating ? averageFeedbackRating.toFixed(1) : '--' }}</p>
                </div>
              </div>
            </div>
          </div>

          <div class="mt-8 grid gap-10 lg:grid-cols-[minmax(0,1fr)_420px] lg:items-start">
            <div class="min-w-0">
              <div class="mb-4 flex items-center justify-between gap-4">
                <h3 class="text-lg font-black text-brand-dark">Danh sách cảm nhận</h3>
                <span class="text-sm font-semibold text-brand-muted">{{ feedbackCountLabel }}</span>
              </div>

              <div class="border-y border-slate-100 bg-white">
                <div v-if="feedbacks.length" class="divide-y divide-slate-100">
                  <article v-for="feedback in feedbacks" :key="feedback.id" class="flex gap-4 py-6 sm:gap-5 sm:py-7">
                    <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-full border border-slate-200 bg-slate-50 text-base font-semibold text-slate-500">
                      {{ customerInitial(feedback.customerName) }}
                    </div>

                    <div class="min-w-0 flex-1">
                      <div class="flex items-start justify-between gap-4">
                        <div class="min-w-0">
                          <h3 class="truncate text-sm font-semibold text-slate-950">{{ feedback.customerName }}</h3>
                          <div class="mt-1 flex items-center gap-0.5 text-[#ee4d2d]">
                            <Star
                              v-for="star in 5"
                              :key="star"
                              class="h-4 w-4"
                              :class="star <= feedback.rating ? 'fill-[#ee4d2d]' : 'fill-transparent text-slate-200'"
                            />
                          </div>
                          <p class="mt-2 text-sm font-medium text-slate-500">
                            {{ formatFeedbackDate(feedback.createdAt) }}
                            <template v-if="feedbackContext(feedback)"> | {{ feedbackContext(feedback) }}</template>
                          </p>
                        </div>
                      </div>

                      <p class="mt-5 text-[15px] font-medium leading-7 text-slate-950">{{ feedback.content }}</p>

                      <div v-if="feedback.avatarUrl" class="mt-5 flex flex-wrap gap-3">
                        <img
                          :src="resolveBackendAssetUrl(feedback.avatarUrl)"
                          :alt="`Ảnh cảm nhận của ${feedback.customerName}`"
                          class="h-24 w-24 rounded-sm object-cover ring-1 ring-slate-100"
                        />
                      </div>
                    </div>
                  </article>
                </div>
                <div v-else class="py-10 text-sm font-semibold text-brand-muted">
                  Chưa có cảm nhận được duyệt cho sản phẩm này.
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- FAQ Section if available -->
      <section v-if="faqs.length" class="px-4 py-16 sm:px-6 lg:px-8">
        <div class="mx-auto max-w-4xl animate-fade-in">
          <span class="text-xs font-black uppercase tracking-[0.25em] text-brand-forest">FAQ</span>
          <h2 class="mt-3 text-3xl font-black text-brand-dark font-display">Câu hỏi thường gặp</h2>
          <div class="mt-8 divide-y divide-slate-100 rounded-[2.5rem] border border-slate-100 bg-white shadow-sm overflow-hidden">
            <details v-for="item in faqs" :key="item.question" class="group p-6 hover:bg-slate-50/40 transition">
              <summary class="cursor-pointer list-none text-base font-black text-brand-dark focus:outline-none flex justify-between items-center select-none">
                <span>{{ item.question }}</span>
                <span class="text-slate-400 group-open:rotate-185 transition-transform duration-200">▼</span>
              </summary>
              <p class="mt-3 text-sm leading-relaxed text-brand-muted font-medium">{{ item.answer }}</p>
            </details>
          </div>
        </div>
      </section>

      <!-- Related products list -->
      <section v-if="relatedProducts.length" class="mx-auto max-w-[1280px] px-4 py-16 sm:px-6 lg:px-8">
        <div class="mb-10 text-center sm:text-left flex flex-col sm:flex-row sm:items-end justify-between border-b border-brand-forest/5 pb-4">
          <div>
            <span class="text-xs font-black uppercase tracking-[0.25em] text-brand-forest">Gợi ý thêm</span>
            <h2 class="mt-2 text-3xl font-black text-brand-dark font-display">Sản phẩm cùng danh mục</h2>
          </div>
          <RouterLink to="/products" class="inline-flex items-center justify-center gap-1.5 text-xs font-black uppercase tracking-wider text-brand-forest hover:text-brand-dark transition mt-2 sm:mt-0">
            Xem toàn bộ thực đơn <ArrowRight class="h-4 w-4" />
          </RouterLink>
        </div>
        
        <div class="grid gap-6 md:grid-cols-3">
          <RouterLink v-for="item in relatedProducts" :key="item.id" :to="`/products/${item.slug}`" class="group rounded-[2.5rem] border border-brand-forest/5 bg-white p-5 shadow-sm hover-lift flex flex-col justify-between">
            <div class="aspect-[4/3] overflow-hidden rounded-[1.8rem] bg-brand-cream/30">
              <img v-if="item.imageUrl" :src="item.imageUrl" :alt="item.name" class="w-full h-full object-cover transition-all duration-300 group-hover:scale-103" />
              <div v-else class="grid h-full place-items-center bg-brand-lime/10 text-lg font-black text-brand-forest">ALOO</div>
            </div>
            <div>
              <h3 class="mt-4 text-lg font-black text-brand-dark group-hover:text-brand-forest transition">{{ item.name }}</h3>
              <p class="mt-2 line-clamp-2 text-xs leading-relaxed text-brand-muted font-medium h-8">{{ item.description }}</p>
            </div>
            <div class="mt-4 pt-3 border-t border-slate-50 flex items-center justify-between">
              <span class="text-xs font-black uppercase tracking-wider text-brand-forest">{{ item.category || 'Món ngon' }}</span>
              <span class="text-[10px] font-black uppercase text-brand-lime group-hover:underline">Chi tiết →</span>
            </div>
          </RouterLink>
        </div>
      </section>
    </template>
  </main>
</template>
