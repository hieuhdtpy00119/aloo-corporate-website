<script setup>
import { computed, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { Sparkles, Star, Award, Heart } from 'lucide-vue-next'
import AlooMenuPoster from '../../components/public/AlooMenuPoster.vue'
import IngredientStrengthCards from '../../components/public/IngredientStrengthCards.vue'
import ProductHeroSlider from '../../components/public/ProductHeroSlider.vue'
import TasteSecretAccordion from '../../components/public/TasteSecretAccordion.vue'
import { useAppStore } from '../../stores/appStore'
import { useProductPageStore } from '../../stores/productPageStore'

const store = useAppStore()
const productPageStore = useProductPageStore()
const products = computed(() =>
  store.products
    .filter((product) => ['ACTIVE', 'Đang bán'].includes(product.status))
    .sort((a, b) => (a.sortOrder || a.id) - (b.sortOrder || b.id)),
)
const featuredProducts = computed(() =>
  products.value.slice(0, 4),
)

onMounted(() => {
  Promise.allSettled([store.fetchProducts(), productPageStore.fetchProductPageContent()])
})
</script>

<template>
  <main class="overflow-hidden bg-[#faf8f2] text-avocado-950">
    <!-- Hero Slider -->
    <ProductHeroSlider :featured-products="featuredProducts" />

    <!-- Strength Points -->
    <IngredientStrengthCards />

    <!-- Interactive Menu Posters -->
    <AlooMenuPoster :poster="productPageStore.menuPoster" :posters-by-branch="productPageStore.menuPosterByBranch" />

    <!-- Product List / Order Section -->
    <section class="bg-white px-4 py-20 sm:px-6 lg:px-8 relative">
      <!-- Top decorative smooth background fade -->
      <div class="absolute inset-x-0 top-0 h-24 bg-gradient-to-b from-[#faf8f2]/60 to-transparent"></div>

      <div class="mx-auto max-w-6xl relative z-10">
        <div class="mb-14 text-center">
          <span class="text-xs font-bold uppercase tracking-[0.25em] text-avocado-600 bg-avocado-50 border border-avocado-100/50 px-3.5 py-1.5 rounded-full inline-flex items-center gap-1.5">
            <Sparkles class="h-3.5 w-3.5 text-cream-600 fill-cream-500" />
            Khám phá trọn bộ menu
          </span>
          <h2 class="mt-4 text-3xl font-black tracking-tight text-avocado-950 md:text-4xl">Menu signature độc quyền ALOO</h2>
          <p class="mx-auto mt-3 max-w-xl text-sm leading-relaxed text-slate-500">
            Mỗi món uống đều được định lượng chuẩn chỉnh, pha chế tươi mới hàng ngày để đảm bảo vị thanh sạch tự nhiên nhất.
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

        <div v-else-if="products.length" class="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
          <article
            v-for="product in products"
            :key="product.id"
            class="overflow-hidden rounded-3xl bg-white border border-avocado-100/30 p-4 shadow-sm hover-lift group flex flex-col justify-between"
          >
            <div>
              <div class="aspect-square overflow-hidden rounded-2xl bg-avocado-50/50 relative">
                <button class="absolute top-3 right-3 h-8 w-8 rounded-full bg-white/80 backdrop-blur-sm grid place-items-center text-slate-400 hover:text-red-500 transition shadow-sm" aria-label="Yêu thích">
                  <Heart class="h-4 w-4 fill-transparent" />
                </button>
                <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="h-full w-full object-cover transition-all duration-300 group-hover:scale-105" />
                <div v-else class="grid h-full place-items-center bg-avocado-100/50 text-base font-bold text-avocado-700 tracking-wider">ALOO</div>
              </div>
              
              <div class="mt-4 space-y-1.5">
                <div class="flex items-center gap-1.5">
                  <span class="rounded-full bg-avocado-50 px-2.5 py-0.5 text-[11px] font-bold text-avocado-700">
                    {{ product.category || 'Sản phẩm' }}
                  </span>
                  <div class="flex items-center text-cream-600 gap-0.5">
                    <Star class="h-3 w-3 fill-cream-400 text-cream-400" />
                    <span class="text-[10px] font-bold text-slate-400">5.0</span>
                  </div>
                </div>
                <h3 class="text-base font-bold text-avocado-950 transition group-hover:text-avocado-800 leading-tight">{{ product.name }}</h3>
                <p class="text-xs leading-relaxed text-slate-500 line-clamp-2 h-8">{{ product.description }}</p>
              </div>
            </div>

            <div class="mt-4 pt-3 border-t border-slate-50 flex items-center justify-between">
              <span class="text-base font-black text-avocado-800">{{ product.price || 'Đang cập nhật' }}</span>
              <RouterLink to="/consultation" class="rounded-full bg-avocado-50 hover:bg-avocado-100 text-avocado-800 font-bold px-3.5 py-1.5 text-xs transition border border-avocado-100/60 shadow-inner text-center">
                Tìm hiểu thêm
              </RouterLink>
            </div>
          </article>
        </div>

        <p v-else class="rounded-2xl border border-slate-200 bg-white px-5 py-16 text-center text-sm font-bold text-slate-400 max-w-lg mx-auto shadow-sm">
          Chưa có sản phẩm nào được hiển thị. Vui lòng quay lại sau.
        </p>
      </div>
    </section>

    <!-- Accordion secrets -->
    <TasteSecretAccordion />

    <!-- Premium call-to-action nhượng quyền -->
    <section class="relative isolate flex min-h-[60vh] items-center bg-avocado-950 px-4 py-20 text-white sm:px-6 lg:px-8 overflow-hidden">
      <!-- Glowing mesh background pattern -->
      <div class="absolute inset-0 -z-10 bg-[linear-gradient(115deg,rgba(249,228,155,0.18),transparent_35%),linear-gradient(180deg,#1e3c1b,#0e1a0b)]"></div>
      <div class="absolute -right-20 -bottom-20 w-80 h-80 bg-cream-400/5 rounded-full blur-3xl pointer-events-none"></div>

      <div class="mx-auto max-w-4xl text-center relative z-10 space-y-6">
        <div class="inline-flex items-center gap-2 text-xs font-bold uppercase tracking-[0.25em] text-cream-300 bg-white/5 border border-white/10 px-3.5 py-1 rounded-full">
          <Award class="h-4 w-4" />
          Hợp tác cùng ALOO
        </div>
        <h2 class="text-3xl sm:text-5xl font-black leading-tight tracking-tight text-white max-w-3xl mx-auto">
          Một menu tinh gọn, hấp dẫn chính là chìa khóa kinh doanh
        </h2>
        <p class="mx-auto max-w-2xl text-base leading-relaxed text-white/80">
          Menu tập trung, nguyên liệu sạch mang câu chuyện thương hiệu và quy trình pha chế chuẩn hóa giúp điểm bán nhượng quyền vận hành nhẹ nhàng, tối ưu chi phí và bứt phá doanh thu.
        </p>
        <div class="pt-4">
          <RouterLink to="/consultation" class="inline-flex rounded-full bg-cream-400 text-avocado-950 font-bold uppercase tracking-wider text-xs px-8 py-4 hover:bg-cream-300 transition duration-300 shadow-xl shadow-cream-400/20 transform hover:-translate-y-0.5">
            Đăng ký tư vấn nhượng quyền
          </RouterLink>
        </div>
      </div>
    </section>
  </main>
</template>

