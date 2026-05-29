<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { ArrowLeft, ArrowRight, CheckCircle2, Leaf, MessageCircle, Sparkles, Star } from 'lucide-vue-next'
import { productService, resolveBackendAssetUrl } from '../../services/cmsService'
import { useAppStore } from '../../stores/appStore'

const route = useRoute()
const store = useAppStore()
const product = ref(null)
const isLoading = ref(false)
const errorMessage = ref('')
const activeImageIndex = ref(0)

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

const loadProduct = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const { data } = await productService.getBySlug(route.params.slug)
    product.value = store.normalizeProduct(data)
    activeImageIndex.value = 0 // Reset active image to primary image
    document.title = `${product.value.seoTitle || product.value.name} | ALOO`
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
  <main class="bg-brand-cream/20 text-brand-dark min-h-screen pb-20">
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
      <section class="relative overflow-hidden bg-white">
        <div class="absolute inset-x-0 top-0 h-40 bg-gradient-to-b from-brand-lime/10 to-transparent"></div>
        
        <div class="mx-auto grid max-w-[1280px] gap-10 px-4 py-14 sm:px-6 lg:grid-cols-[1.05fr_0.95fr] lg:px-8 lg:py-20 relative z-10 animate-fade-in">
          <!-- Left side: Gallery with Click-to-Switch interaction -->
          <div class="relative order-2 lg:order-1 space-y-4">
            <div class="overflow-hidden rounded-[2rem] border border-brand-forest/5 bg-brand-cream/30 p-3 shadow-xl">
              <img
                v-if="galleryImages[activeImageIndex]"
                :src="galleryImages[activeImageIndex]"
                :alt="product.name"
                class="aspect-[4/3] w-full rounded-[1.5rem] object-cover transition-all duration-300 hover:scale-[1.01]"
              />
              <div v-else class="grid aspect-[4/3] place-items-center rounded-[1.5rem] bg-brand-lime/10 text-3xl font-black text-brand-forest">ALOO</div>
            </div>
            
            <!-- Thumbnail list -->
            <div v-if="galleryImages.length > 1" class="mt-4 flex flex-wrap gap-3">
              <button
                v-for="(image, index) in galleryImages"
                :key="image"
                @click="activeImageIndex = index"
                class="aspect-[4/3] w-20 sm:w-24 rounded-2xl overflow-hidden border-2 transition duration-250 cursor-pointer hover:scale-[1.04] focus:outline-none shrink-0"
                :class="activeImageIndex === index ? 'border-brand-forest ring-3 ring-brand-lime/30 shadow-md' : 'border-transparent opacity-75 hover:opacity-100'"
              >
                <img
                  :src="image"
                  :alt="product.name"
                  class="h-full w-full object-cover"
                />
              </button>
            </div>
          </div>

          <!-- Right side: Info details -->
          <div class="relative order-1 flex flex-col justify-center lg:order-2">
            <RouterLink to="/products" class="mb-8 inline-flex w-fit items-center gap-2 rounded-full border border-brand-forest/10 bg-white px-4.5 py-2.5 text-xs font-black uppercase tracking-wider text-brand-forest hover:bg-brand-lime/10 transition active:scale-95 shadow-sm">
              <ArrowLeft class="h-3.5 w-3.5" /> Menu ALOO
            </RouterLink>
            
            <div class="flex items-center gap-3">
              <span class="inline-flex items-center gap-2 rounded-full bg-brand-lime/15 px-3.5 py-1.5 text-xs font-black uppercase tracking-[0.2em] text-brand-forest">
                <Sparkles class="h-3.5 w-3.5" /> {{ product.category || 'Signature ALOO' }}
              </span>
              <div class="flex items-center text-brand-sand gap-0.5 text-xs font-bold">
                <Star class="h-3.5 w-3.5 fill-brand-sand" />
                <span class="text-brand-muted">5.0 (Cực phẩm)</span>
              </div>
            </div>
            
            <h1 class="mt-5 text-4xl font-black leading-tight text-brand-dark sm:text-5xl lg:text-6xl font-display">{{ product.name }}</h1>

            <p class="mt-5 max-w-2xl text-base leading-8 text-brand-muted font-medium">
              {{ product.shortDescription || product.description || 'Nội dung chi tiết sản phẩm đang được cập nhật trong Admin CMS.' }}
            </p>
            
            <div class="mt-8 flex flex-wrap gap-4">
              <RouterLink to="/consultation" class="inline-flex items-center gap-2 rounded-full bg-brand-forest hover:bg-brand-dark transition px-7 py-4 text-xs font-black uppercase tracking-wider text-white shadow-lg shadow-brand-forest/15 active:scale-98">
                Đăng ký hợp tác nhượng quyền <ArrowRight class="h-4 w-4" />
              </RouterLink>
              <RouterLink to="/locations" class="inline-flex items-center gap-2 rounded-full border border-brand-forest/15 bg-white px-7 py-4 text-xs font-black uppercase tracking-wider text-brand-forest hover:bg-brand-cream transition active:scale-98">
                Tìm cửa hàng gần nhất
              </RouterLink>
            </div>
          </div>
        </div>
      </section>

      <!-- Three Pillars info cards (using final computed lists) -->
      <section class="mx-auto grid max-w-[1280px] gap-8 px-4 py-16 sm:px-6 lg:grid-cols-3 lg:px-8">
        <article class="rounded-[2.5rem] border border-brand-forest/5 bg-white p-8 shadow-sm hover-lift">
          <div class="grid h-12 w-12 place-items-center rounded-2xl bg-brand-lime/10 text-brand-forest shadow-inner">
            <Leaf class="h-6 w-6" />
          </div>
          <h2 class="mt-5 text-xl font-black text-brand-dark font-display">Nguyên liệu chính</h2>
          <ul class="mt-5 space-y-3.5 text-sm font-semibold text-brand-muted">
            <li v-for="item in finalIngredients" :key="item" class="flex gap-3">
              <CheckCircle2 class="h-5 w-5 shrink-0 text-brand-forest" />
              <span>{{ item }}</span>
            </li>
          </ul>
        </article>

        <article class="rounded-[2.5rem] border border-brand-forest/5 bg-white p-8 shadow-sm hover-lift">
          <div class="grid h-12 w-12 place-items-center rounded-2xl bg-brand-sand/10 text-brand-brown shadow-inner">
            <Star class="h-6 w-6" />
          </div>
          <h2 class="mt-5 text-xl font-black text-brand-dark font-display">Hồ sơ hương vị</h2>
          <ul class="mt-5 space-y-3.5 text-sm font-semibold text-brand-muted">
            <li v-for="item in finalTasteProfile" :key="item" class="flex gap-3">
              <CheckCircle2 class="h-5 w-5 shrink-0 text-brand-forest" />
              <span>{{ item }}</span>
            </li>
          </ul>
        </article>

        <article class="rounded-[2.5rem] border border-brand-forest/5 bg-white p-8 shadow-sm hover-lift">
          <div class="grid h-12 w-12 place-items-center rounded-2xl bg-brand-lime/10 text-brand-forest shadow-inner">
            <MessageCircle class="h-6 w-6" />
          </div>
          <h2 class="mt-5 text-xl font-black text-brand-dark font-display">Gợi ý thưởng thức</h2>
          <ul class="mt-5 space-y-3.5 text-sm font-semibold text-brand-muted">
            <li v-for="item in finalServingSuggestion" :key="item" class="flex gap-3">
              <CheckCircle2 class="h-5 w-5 shrink-0 text-brand-forest" />
              <span>{{ item }}</span>
            </li>
          </ul>
        </article>
      </section>

      <!-- Details Story text -->
      <section class="bg-white px-4 py-20 sm:px-6 lg:px-8 border-y border-brand-forest/5">
        <div class="mx-auto grid max-w-[1280px] gap-10 lg:grid-cols-[0.85fr_1.15fr] lg:items-start">
          <div>
            <span class="text-xs font-black uppercase tracking-[0.25em] text-brand-forest">Câu chuyện sản phẩm</span>
            <h2 class="mt-3 text-3xl font-black text-brand-dark lg:text-4xl font-display">Điểm khác biệt của {{ product.name }}</h2>
          </div>
          <div class="rounded-[2.5rem] bg-brand-cream/30 p-8 text-base leading-8 text-brand-muted font-medium border border-brand-forest/5 shadow-inner">
            <p class="whitespace-pre-line">{{ product.detailContent || product.description || 'Hương vị bơ chín mịn cao cấp được làm mới hoàn toàn bằng công thức độc quyền từ ALOO.' }}</p>
          </div>
        </div>
      </section>

      <!-- FAQ Section if available -->
      <section v-if="faqs.length" class="bg-white px-4 py-20 sm:px-6 lg:px-8">
        <div class="mx-auto max-w-4xl animate-fade-in">
          <span class="text-xs font-black uppercase tracking-[0.25em] text-brand-forest">FAQ</span>
          <h2 class="mt-3 text-3xl font-black text-brand-dark font-display text-center">Câu hỏi thường gặp</h2>
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
      <section v-if="relatedProducts.length" class="mx-auto max-w-[1280px] px-4 py-20 sm:px-6 lg:px-8">
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
