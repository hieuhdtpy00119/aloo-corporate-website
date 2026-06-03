<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { Search, Sparkles, Award } from 'lucide-vue-next'
import ProductHeroSlider from '../../components/public/ProductHeroSlider.vue'
import { useAppStore } from '../../stores/appStore'
import { useProductPageStore } from '../../stores/productPageStore'

const store = useAppStore()
const productPageStore = useProductPageStore()
const activeCategory = ref('Tất cả')
const searchQuery = ref('')
const currentPage = ref(1)
const pageSize = 12

const products = computed(() =>
  store.products
    .filter((product) => ['ACTIVE', 'Đang bán'].includes(product.status))
    .sort((a, b) => (a.sortOrder || a.id) - (b.sortOrder || b.id)),
)

const categories = computed(() => {
  const cats = new Set(products.value.map((p) => p.category || 'Sản phẩm khác'))
  return ['Tất cả', ...Array.from(cats)]
})

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

const featuredProducts = computed(() =>
  products.value.slice(0, 4),
)

const heroSlides = computed(() =>
  productPageStore.visibleHeroSlides.length ? productPageStore.visibleHeroSlides : featuredProducts.value,
)

const selectCategory = (category) => {
  activeCategory.value = category
  currentPage.value = 1
}

const setSearchQuery = (event) => {
  searchQuery.value = event.target.value
  currentPage.value = 1
}

onMounted(() => {
  Promise.allSettled([store.fetchProducts(), productPageStore.fetchProductPageContent()])
})
</script>

<template>
  <main class="overflow-hidden bg-brand-cream/20 text-brand-dark">
    <!-- Hero Slider -->
    <ProductHeroSlider :featured-products="heroSlides" />

    <!-- Product List / Order Section -->
    <section id="product-list" class="bg-white px-4 py-20 sm:px-6 lg:px-8 relative">
      <!-- Top decorative smooth background fade -->
      <div class="absolute inset-x-0 top-0 h-24 bg-gradient-to-b from-brand-cream/10 to-transparent"></div>

      <div class="mx-auto max-w-[1280px] relative z-10">
        <div class="mb-14 text-center">
          <span class="text-xs font-black uppercase tracking-[0.25em] text-brand-forest bg-brand-lime/10 border border-brand-lime/20 px-3.5 py-1.5 rounded-full inline-flex items-center gap-1.5">
            <Sparkles class="h-3.5 w-3.5 text-brand-sand fill-brand-sand/50" />
            Khám phá sản phẩm
          </span>
          <h2 class="mt-4 text-3xl font-black tracking-tight text-brand-dark md:text-4xl font-display">Sản phẩm đặc trưng của ALOO</h2>
          <p class="mx-auto mt-3 max-w-xl text-sm leading-relaxed text-brand-muted">
            Tìm nhanh các món nổi bật, nguyên liệu và hương vị đặc trưng đang được ALOO phục vụ.
          </p>
        </div>

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

        <div v-else-if="products.length" class="grid gap-8 lg:grid-cols-[260px_minmax(0,1fr)]">
          <aside class="lg:sticky lg:top-28 lg:self-start">
            <div class="rounded-3xl border border-brand-forest/5 bg-brand-cream/30 p-4">
              <label class="grid gap-2 text-xs font-black uppercase tracking-wider text-brand-muted lg:hidden">
                Danh mục
                <select
                  class="rounded-2xl border border-brand-forest/10 bg-white px-4 py-3 text-sm font-bold normal-case tracking-normal text-brand-dark outline-none focus:border-brand-forest"
                  :value="activeCategory"
                  @change="selectCategory($event.target.value)"
                >
                  <option v-for="cat in categories" :key="cat" :value="cat">{{ cat }}</option>
                </select>
              </label>

              <div class="hidden lg:block">
                <p class="px-3 text-xs font-black uppercase tracking-[0.2em] text-brand-sand">Danh mục</p>
                <div class="mt-3 max-h-[430px] space-y-1 overflow-y-auto pr-1">
                  <button
                    v-for="cat in categories"
                    :key="cat"
                    type="button"
                    class="flex w-full items-center justify-between rounded-2xl px-3 py-2.5 text-left text-sm font-bold transition"
                    :class="
                      activeCategory === cat
                        ? 'bg-brand-forest text-white shadow-sm'
                        : 'text-brand-muted hover:bg-white hover:text-brand-forest'
                    "
                    @click="selectCategory(cat)"
                  >
                    <span class="truncate">{{ cat }}</span>
                    <span class="ml-3 rounded-full bg-white/15 px-2 py-0.5 text-[10px] font-black">
                      {{ cat === 'Tất cả' ? products.length : products.filter((product) => (product.category || 'Sản phẩm khác') === cat).length }}
                    </span>
                  </button>
                </div>
              </div>
            </div>
          </aside>

          <div>
            <div class="mb-6 flex flex-col gap-4 rounded-3xl border border-brand-forest/5 bg-brand-cream/20 p-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <p class="text-xs font-black uppercase tracking-[0.2em] text-brand-sand">Danh sách sản phẩm</p>
                <h3 class="mt-1 text-2xl font-black text-brand-dark font-display">{{ activeCategory }}</h3>
                <p class="mt-1 text-sm font-semibold text-brand-muted">{{ filteredProducts.length }} món phù hợp</p>
              </div>
              <label class="relative block w-full sm:max-w-sm">
                <Search class="absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-brand-muted" />
                <input
                  :value="searchQuery"
                  type="search"
                  class="w-full rounded-2xl border border-brand-forest/10 bg-white py-3 pl-11 pr-4 text-sm font-semibold text-brand-dark outline-none transition focus:border-brand-forest focus:ring-4 focus:ring-brand-lime/10"
                  placeholder="Tìm sản phẩm..."
                  @input="setSearchQuery"
                />
              </label>
            </div>

            <div v-if="filteredProducts.length" class="grid gap-3 xl:grid-cols-2">
              <article
                v-for="product in paginatedProducts"
                :key="product.id"
                class="group grid min-h-[112px] grid-cols-[88px_minmax(0,1fr)] gap-4 rounded-2xl border border-brand-forest/5 bg-white p-3 shadow-sm transition hover:border-brand-forest/15 hover:shadow-md"
              >
                <div class="h-[88px] overflow-hidden rounded-xl bg-brand-cream/40">
                  <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="h-full w-full object-cover transition duration-300 group-hover:scale-105" />
                  <div v-else class="grid h-full place-items-center bg-brand-lime/10 text-xs font-black tracking-wider text-brand-forest">ALOO</div>
                </div>

                <div class="flex min-w-0 flex-col justify-between gap-3">
                  <div class="min-w-0">
                    <span class="inline-flex rounded-full bg-brand-lime/15 px-2.5 py-0.5 text-[10px] font-black uppercase tracking-wide text-brand-forest">
                      {{ product.category || 'Sản phẩm' }}
                    </span>
                    <h4 class="mt-1 truncate text-base font-black leading-tight text-brand-dark transition group-hover:text-brand-forest">{{ product.name }}</h4>
                    <p class="mt-1 line-clamp-1 text-xs font-medium leading-relaxed text-brand-muted">
                      {{ product.shortDescription || product.description }}
                    </p>
                  </div>

                  <div class="flex items-center justify-between gap-3">
                    <span class="text-[11px] font-black uppercase tracking-wider text-brand-sand">ALOO</span>
                    <RouterLink :to="product.slug ? `/products/${product.slug}` : '/products'" class="shrink-0 rounded-full border border-brand-forest/10 bg-brand-cream px-3 py-1.5 text-center text-xs font-bold text-brand-forest shadow-inner transition hover:bg-brand-lime/20">
                      Chi tiết
                    </RouterLink>
                  </div>
                </div>
              </article>
            </div>

            <div v-if="filteredProducts.length && totalPages > 1" class="mt-8 flex flex-wrap items-center justify-center gap-2">
              <button
                type="button"
                class="rounded-full border border-brand-forest/10 bg-white px-4 py-2 text-xs font-black text-brand-forest transition disabled:cursor-not-allowed disabled:opacity-40"
                :disabled="currentPage === 1"
                @click="currentPage = Math.max(1, currentPage - 1)"
              >
                Trước
              </button>
              <button
                v-for="page in totalPages"
                :key="page"
                type="button"
                class="grid h-9 w-9 place-items-center rounded-full border text-xs font-black transition"
                :class="currentPage === page ? 'border-brand-forest bg-brand-forest text-white' : 'border-brand-forest/10 bg-white text-brand-forest hover:bg-brand-lime/15'"
                @click="currentPage = page"
              >
                {{ page }}
              </button>
              <button
                type="button"
                class="rounded-full border border-brand-forest/10 bg-white px-4 py-2 text-xs font-black text-brand-forest transition disabled:cursor-not-allowed disabled:opacity-40"
                :disabled="currentPage === totalPages"
                @click="currentPage = Math.min(totalPages, currentPage + 1)"
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
