<script setup>
import { computed, nextTick, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { Search, Award } from 'lucide-vue-next'
import { useAppStore } from '../../stores/appStore'

const store = useAppStore()
const activeCategory = ref('Tất cả')
const searchQuery = ref('')
const currentPage = ref(1)
const productSectionRef = ref(null)
const pageSize = 12
const categoryIconMap = [
  { match: ['kem bơ', 'bơ'], icon: '🥑' },
  { match: ['cà phê', 'coffee'], icon: '☕' },
  { match: ['sinh tố', 'smoothie'], icon: '🥤' },
  { match: ['nước ép', 'juice'], icon: '🧃' },
  { match: ['trà trái cây', 'fruit tea', 'trà'], icon: '🍹' },
  { match: ['topping'], icon: '✨' },
  { match: ['ăn vặt', 'snack'], icon: '🍿' },
  { match: ['kem'], icon: '🍦' },
]

const products = computed(() =>
  store.products
    .filter((product) => ['ACTIVE', 'Đang bán'].includes(product.status))
    .sort((a, b) => (a.sortOrder || a.id) - (b.sortOrder || b.id)),
)

const categories = computed(() => {
  const cats = new Set(products.value.map((p) => p.category || 'Sản phẩm khác'))
  return ['Tất cả', ...Array.from(cats)]
})

const categoryIcon = (category) => {
  if (category === 'Tất cả') return '✨'
  const normalized = String(category || '').toLowerCase()
  return categoryIconMap.find((item) => item.match.some((keyword) => normalized.includes(keyword)))?.icon || '🍦'
}

const categoryCount = (category) =>
  category === 'Tất cả'
    ? products.value.length
    : products.value.filter((product) => (product.category || 'Sản phẩm khác') === category).length

const filteredProducts = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return products.value.filter((product) => {
    const category = product.category || 'Sản phẩm khác'
    const matchesCategory = activeCategory.value === 'Tất cả' || category === activeCategory.value
    const haystack = [product.name, product.category, product.description, product.shortDescription]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
    const matchesSearch = !keyword || haystack.includes(keyword)
    return matchesCategory && matchesSearch
  })
})

const totalPages = computed(() => Math.max(1, Math.ceil(filteredProducts.value.length / pageSize)))
const paginatedProducts = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  return filteredProducts.value.slice(start, start + pageSize)
})

const selectCategory = (category) => {
  activeCategory.value = category
  currentPage.value = 1
}

const setSearchQuery = (event) => {
  searchQuery.value = event.target.value
  currentPage.value = 1
}

const scrollToProductSection = async () => {
  await nextTick()
  productSectionRef.value?.scrollIntoView({
    behavior: 'smooth',
    block: 'start',
  })
}

const goToPage = async (page) => {
  const nextPage = Math.min(totalPages.value, Math.max(1, page))
  if (nextPage === currentPage.value) return
  currentPage.value = nextPage
  await scrollToProductSection()
}

onMounted(() => {
  store.fetchProducts()
})
</script>

<template>
  <main class="overflow-hidden bg-brand-cream/20 text-brand-dark">
    <!-- Product List / Order Section -->
    <section id="product-list" ref="productSectionRef" class="relative scroll-mt-24 bg-[#F8FAF7] px-4 py-16 sm:px-6 lg:px-8">
      <div class="relative z-10 mx-auto max-w-[1320px]">
        <p v-if="store.errors.products" class="rounded-2xl bg-red-50 border border-red-200 px-5 py-4 text-sm font-semibold text-red-700 max-w-lg mx-auto text-center shadow-sm">
          {{ store.errors.products }}
        </p>
        
        <div v-else-if="store.loading.products" class="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
          <div v-for="i in 4" :key="i" class="animate-pulse rounded-3xl bg-slate-50 border border-slate-100 p-4 space-y-4">
            <div class="aspect-square bg-slate-200 rounded-2xl"></div>
            <div class="h-4 bg-slate-200 rounded w-1/3"></div>
            <div class="h-6 bg-slate-200 rounded w-3/4"></div>
            <div class="h-4 bg-slate-200 rounded w-1/2"></div>
          </div>
        </div>

        <div v-else-if="products.length" class="filter-panel grid gap-8 lg:grid-cols-[260px_minmax(0,1fr)] lg:items-start">
          <aside class="lg:sticky lg:top-28">
            <div class="rounded-[24px] bg-white/90 p-4 shadow-[0_16px_42px_rgba(13,43,26,0.05)] ring-1 ring-[#E8EEE8]">
              <p class="px-2 text-xs font-black uppercase tracking-[0.18em] text-brand-sand">Danh mục sản phẩm</p>
              <div class="mt-4 flex gap-2 overflow-x-auto pb-1 lg:block lg:space-y-2 lg:overflow-visible lg:pb-0">
                <button
                  v-for="cat in categories"
                  :key="cat"
                  type="button"
                  class="flex min-w-max items-center gap-3 rounded-2xl px-4 py-3 text-left text-sm font-black transition duration-200 lg:w-full lg:min-w-0"
                  :class="
                    activeCategory === cat
                      ? 'border-transparent bg-[#0D7A43] text-white shadow-[0_12px_28px_rgba(13,122,67,0.18)]'
                      : 'border border-[#E8EEE8] bg-transparent text-brand-forest hover:bg-brand-lime/10'
                  "
                  @click="selectCategory(cat)"
                >
                  <span class="min-w-0 flex-1 truncate">{{ cat }}</span>
                  <span
                    class="shrink-0 rounded-full px-2 py-0.5 text-[10px] font-black"
                    :class="activeCategory === cat ? 'bg-white/18 text-white' : 'bg-brand-lime/14 text-brand-muted'"
                  >
                    {{ categoryCount(cat) }}
                  </span>
                </button>
              </div>
            </div>
          </aside>

          <div class="min-w-0">
            <div class="mb-7 flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
              <div>
                <p class="text-xs font-black uppercase tracking-[0.22em] text-brand-sand">Danh sách sản phẩm</p>
                <h3 class="mt-1.5 text-2xl font-black leading-tight tracking-tight text-brand-dark font-display sm:text-3xl">
                  {{ activeCategory === 'Tất cả' ? 'Tất cả sản phẩm' : activeCategory }}
                </h3>
                <p class="mt-1 text-sm font-semibold text-brand-muted">{{ filteredProducts.length }} sản phẩm đang phục vụ</p>
              </div>
              <label class="relative block w-full sm:max-w-[390px]">
                <Search class="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-brand-forest/65 transition" />
                <input
                  :value="searchQuery"
                  type="search"
                  class="h-12 w-full rounded-full border border-[#E8EEE8] bg-white py-0 pl-11 pr-5 text-sm font-semibold text-brand-dark outline-none transition duration-300 placeholder:text-brand-muted/70 focus:border-[#0D7A43] focus:shadow-[0_12px_28px_rgba(13,122,67,0.1)] focus:ring-4 focus:ring-brand-lime/15"
                  placeholder="Tìm sản phẩm..."
                  @input="setSearchQuery"
                />
              </label>
            </div>

            <div v-if="filteredProducts.length" class="grid gap-6 sm:grid-cols-2 xl:grid-cols-3">
              <article
                v-for="product in paginatedProducts"
                :key="product.id"
                class="product-card group flex flex-col overflow-hidden rounded-[28px] border border-brand-forest/7 bg-white p-3 shadow-sm shadow-brand-forest/5 transition duration-500 hover:-translate-y-2 hover:border-brand-forest/14 hover:shadow-xl hover:shadow-brand-forest/10"
              >
                <div class="relative aspect-[4/3] overflow-hidden rounded-[24px] bg-brand-cream/50">
                  <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="h-full w-full object-cover transition duration-500 group-hover:scale-105" />
                  <div v-else class="relative grid h-full place-items-center overflow-hidden bg-[radial-gradient(circle_at_30%_20%,rgba(198,240,171,0.58),transparent_36%),linear-gradient(135deg,#FAF8F2,#EEF7EA)] px-5 text-center">
                    <div class="absolute -right-8 -top-8 h-32 w-32 rounded-full border border-brand-forest/8"></div>
                    <div class="absolute -bottom-10 -left-8 h-36 w-36 rounded-full bg-brand-lime/20 blur-2xl"></div>
                    <span class="absolute right-5 top-5 rounded-full bg-white/70 px-3 py-1 text-[10px] font-black uppercase tracking-[0.16em] text-brand-forest shadow-sm">
                      ALOO
                    </span>
                    <div class="relative z-10">
                      <div class="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-white/80 text-2xl shadow-sm shadow-brand-forest/8 ring-1 ring-brand-forest/5">
                        {{ categoryIcon(product.category || 'Sản phẩm') }}
                      </div>
                      <p class="mt-3 text-[11px] font-black uppercase tracking-[0.18em] text-brand-forest/70">Đang cập nhật ảnh</p>
                    </div>
                  </div>
                </div>

                <div class="flex flex-col px-2 pb-2 pt-3.5">
                  <div>
                    <span class="inline-flex rounded-full bg-brand-lime/15 px-3 py-1 text-[10px] font-black uppercase tracking-wide text-brand-forest">
                      {{ product.category || 'Sản phẩm' }}
                    </span>
                    <h4 class="mt-3 text-xl font-black leading-tight text-brand-dark transition group-hover:text-brand-forest">{{ product.name }}</h4>
                    <div class="mt-2.5 inline-flex rounded-full bg-brand-cream/70 px-3 py-1 text-[11px] font-black text-brand-muted">
                      Chưa có đánh giá
                    </div>
                  </div>

                  <div class="pt-4">
                    <RouterLink :to="product.slug ? `/products/${product.slug}` : '/products'" class="inline-flex w-full items-center justify-center rounded-full bg-brand-forest px-4 py-2.5 text-xs font-black uppercase tracking-wider text-white shadow-lg shadow-brand-forest/12 transition hover:bg-brand-dark">
                      Khám phá
                    </RouterLink>
                  </div>
                </div>
              </article>
            </div>

            <div v-if="filteredProducts.length && totalPages > 1" class="mt-10 flex flex-wrap items-center justify-center gap-2">
              <button
                type="button"
                class="rounded-full border border-brand-forest/10 bg-white px-5 py-2.5 text-xs font-black text-brand-forest transition hover:bg-brand-lime/12 disabled:cursor-not-allowed disabled:opacity-40"
                :disabled="currentPage === 1"
                @click="goToPage(currentPage - 1)"
              >
                Trước
              </button>
              <button
                v-for="page in totalPages"
                :key="page"
                type="button"
                class="grid h-10 w-10 place-items-center rounded-full border text-xs font-black transition hover:-translate-y-0.5"
                :class="currentPage === page ? 'border-brand-forest bg-brand-forest text-white shadow-lg shadow-brand-forest/15' : 'border-brand-forest/10 bg-white text-brand-forest hover:bg-brand-lime/15'"
                @click="goToPage(page)"
              >
                {{ page }}
              </button>
              <button
                type="button"
                class="rounded-full border border-brand-forest/10 bg-white px-5 py-2.5 text-xs font-black text-brand-forest transition hover:bg-brand-lime/12 disabled:cursor-not-allowed disabled:opacity-40"
                :disabled="currentPage === totalPages"
                @click="goToPage(currentPage + 1)"
              >
                Sau
              </button>
            </div>

            <div v-if="!filteredProducts.length" class="rounded-2xl border border-slate-200 bg-white px-5 py-16 text-center text-sm font-bold text-slate-400 shadow-sm">
              Không tìm thấy sản phẩm phù hợp.
            </div>
          </div>
        </div>

        <p v-else class="rounded-2xl border border-slate-200 bg-white px-5 py-16 text-center text-sm font-bold text-slate-400 max-w-lg mx-auto shadow-sm">
          Chưa có dữ liệu. Vui lòng thêm sản phẩm trong trang quản trị.
        </p>
      </div>
    </section>

    <!-- Premium call-to-action nhượng quyền -->
    <section class="relative isolate flex min-h-[60vh] items-center bg-brand-dark px-4 py-20 text-white sm:px-6 lg:px-8 overflow-hidden">
      <!-- Glowing mesh background pattern -->
      <div class="absolute inset-0 -z-10 bg-[linear-gradient(115deg,rgba(200,168,90,0.18),transparent_35%),linear-gradient(180deg,#0D2B1A,#06160d)] border-t border-white/5"></div>
      <div class="absolute -right-20 -bottom-20 w-80 h-80 bg-brand-lime/5 rounded-full blur-3xl pointer-events-none"></div>

      <div class="mx-auto max-w-4xl text-center relative z-10 space-y-6">
        <div class="inline-flex items-center gap-2 text-xs font-black uppercase tracking-[0.25em] text-brand-lime bg-white/5 border border-white/10 px-3.5 py-1.5 rounded-full">
          <Award class="h-4 w-4" />
          Hợp tác cùng ALOO
        </div>
        <h2 class="text-3xl sm:text-5xl font-black leading-tight tracking-tight text-white max-w-3xl mx-auto font-display">
          Một menu tinh gọn, hấp dẫn chính là chìa khóa kinh doanh
        </h2>
        <p class="mx-auto max-w-2xl text-base leading-relaxed text-white/80">
          Menu tập trung, nguyên liệu sạch mang câu chuyện thương hiệu và quy trình pha chế chuẩn hóa giúp điểm bán nhượng quyền vận hành nhẹ nhàng, tối ưu chi phí và bứt phá doanh thu.
        </p>
        <div class="pt-4">
          <RouterLink to="/consultation" class="inline-flex rounded-full bg-brand-lime text-brand-dark font-black uppercase tracking-wider text-xs px-8 py-4 hover:bg-brand-lime/90 transition duration-300 shadow-xl shadow-brand-lime/20 transform hover:-translate-y-0.5">
            Đăng ký tư vấn nhượng quyền
          </RouterLink>
        </div>
      </div>
    </section>
  </main>
</template>

<style scoped>
.product-card {
  animation: productFadeUp 420ms ease-out both;
}

.filter-panel {
  animation: filterFadeIn 360ms ease-out both;
}

@keyframes productFadeUp {
  from {
    opacity: 0;
    transform: translateY(18px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes filterFadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
