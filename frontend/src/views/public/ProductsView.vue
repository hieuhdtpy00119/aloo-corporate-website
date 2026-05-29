<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { Sparkles, Star, Award, Heart } from 'lucide-vue-next'
import AlooMenuPoster from '../../components/public/AlooMenuPoster.vue'
import ProductHeroSlider from '../../components/public/ProductHeroSlider.vue'
import { useAppStore } from '../../stores/appStore'
import { useProductPageStore } from '../../stores/productPageStore'

const store = useAppStore()
const productPageStore = useProductPageStore()
const activeCategory = ref('Tất cả')

const products = computed(() =>
  store.products
    .filter((product) => ['ACTIVE', 'Đang bán'].includes(product.status))
    .sort((a, b) => (a.sortOrder || a.id) - (b.sortOrder || b.id)),
)

const categories = computed(() => {
  const cats = new Set(products.value.map((p) => p.category).filter(Boolean))
  return ['Tất cả', ...Array.from(cats)]
})

const filteredProducts = computed(() => {
  if (activeCategory.value === 'Tất cả') return products.value
  return products.value.filter((p) => p.category === activeCategory.value)
})

const featuredProducts = computed(() =>
  products.value.slice(0, 4),
)

onMounted(() => {
  Promise.allSettled([store.fetchProducts(), productPageStore.fetchProductPageContent()])
})
</script>

<template>
  <main class="overflow-hidden bg-brand-cream/20 text-brand-dark">
    <!-- Hero Slider -->
    <ProductHeroSlider :featured-products="featuredProducts" />

    <!-- Interactive Menu Posters -->
    <AlooMenuPoster :poster="productPageStore.menuPoster" :posters-by-branch="productPageStore.menuPosterByBranch" />

    <!-- Product List / Order Section -->
    <section class="bg-white px-4 py-20 sm:px-6 lg:px-8 relative">
      <!-- Top decorative smooth background fade -->
      <div class="absolute inset-x-0 top-0 h-24 bg-gradient-to-b from-brand-cream/10 to-transparent"></div>

      <div class="mx-auto max-w-[1280px] relative z-10">
        <div class="mb-14 text-center">
          <span class="text-xs font-black uppercase tracking-[0.25em] text-brand-forest bg-brand-lime/10 border border-brand-lime/20 px-3.5 py-1.5 rounded-full inline-flex items-center gap-1.5">
            <Sparkles class="h-3.5 w-3.5 text-brand-sand fill-brand-sand/50" />
            Khám phá trọn bộ menu
          </span>
          <h2 class="mt-4 text-3xl font-black tracking-tight text-brand-dark md:text-4xl font-display">Menu signature độc quyền ALOO</h2>
          <p class="mx-auto mt-3 max-w-xl text-sm leading-relaxed text-brand-muted">
            Dữ liệu sản phẩm được lấy trực tiếp từ hệ thống. Chọn danh mục phía dưới để lọc nhanh các món ngon của chúng tôi.
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

        <div v-else-if="products.length">
          <!-- Category Tabs -->
          <div class="mb-12 flex flex-wrap justify-center gap-2 border-b border-slate-100 pb-8">
            <button
              v-for="cat in categories"
              :key="cat"
              @click="activeCategory = cat"
              class="rounded-full px-6 py-2.5 text-xs font-black uppercase tracking-wider transition-all duration-300 cursor-pointer active:scale-95 shadow-sm border animate-fade-in"
              :class="
                activeCategory === cat
                  ? 'bg-brand-forest border-brand-forest text-white shadow-brand-forest/15'
                  : 'bg-white border-slate-100 text-brand-muted hover:text-brand-forest hover:border-brand-forest/20'
              "
            >
              {{ cat }}
            </button>
          </div>

          <!-- Product Grid -->
          <div v-if="filteredProducts.length" class="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
            <article
              v-for="product in filteredProducts"
              :key="product.id"
              class="overflow-hidden rounded-3xl bg-white border border-brand-forest/5 p-4 shadow-sm hover-lift group flex flex-col justify-between animate-fade-in"
            >
              <div>
                <div class="aspect-square overflow-hidden rounded-2xl bg-brand-cream/30 relative">
                  <button class="absolute top-3 right-3 h-8 w-8 rounded-full bg-white/80 backdrop-blur-sm grid place-items-center text-slate-400 hover:text-red-500 transition shadow-sm cursor-pointer" aria-label="Yêu thích">
                    <Heart class="h-4 w-4 fill-transparent" />
                  </button>
                  <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="h-full w-full object-cover transition-all duration-300 group-hover:scale-105" />
                  <div v-else class="grid h-full place-items-center bg-brand-lime/10 text-base font-black text-brand-forest tracking-wider">ALOO</div>
                </div>
                
                <div class="mt-4 space-y-1.5">
                  <div class="flex items-center gap-1.5">
                    <span class="rounded-full bg-brand-lime/15 px-2.5 py-0.5 text-[11px] font-black text-brand-forest">
                      {{ product.category || 'Sản phẩm' }}
                    </span>
                    <div class="flex items-center text-brand-sand gap-0.5">
                      <Star class="h-3 w-3 fill-brand-sand text-brand-sand" />
                      <span class="text-[10px] font-black text-brand-muted">5.0</span>
                    </div>
                  </div>
                  <h3 class="text-base font-bold text-brand-dark transition group-hover:text-brand-forest leading-tight">{{ product.name }}</h3>
                  <p class="text-xs leading-relaxed text-brand-muted font-medium line-clamp-2 h-8">{{ product.description }}</p>
                </div>
              </div>
              <div class="mt-4 pt-3 border-t border-slate-50 flex justify-end">
                <RouterLink :to="product.slug ? `/products/${product.slug}` : '/products'" class="rounded-full bg-brand-cream hover:bg-brand-lime/20 text-brand-forest font-bold px-3.5 py-1.5 text-xs transition border border-brand-forest/10 text-center shadow-inner">
                  Xem chi tiết
                </RouterLink>
              </div>
            </article>
          </div>
          
          <div v-else class="rounded-2xl border border-slate-200 bg-white px-5 py-16 text-center text-sm font-bold text-slate-400 max-w-lg mx-auto shadow-sm">
            Không tìm thấy sản phẩm trong danh mục này.
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




