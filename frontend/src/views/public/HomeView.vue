<script setup>
import { computed, onMounted, ref } from 'vue'
import { ChevronLeft, ChevronRight, MapPin, Award, Star, ArrowRight, Heart } from 'lucide-vue-next'
import { useAppStore } from '../../stores/appStore'

const store = useAppStore()
const productRail = ref(null)

const franchiseFeatureCard = {
    title: 'Mô hình nhượng quyền ALOO',
    description: 'Cửa hàng tinh gọn, nhận diện trẻ trung, quy trình dễ vận hành.',
    cta: 'Tìm hiểu ngay',
    to: '/franchise',
    image: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1400&q=85',
    badge: 'Cơ hội hợp tác'
}

const activeProducts = computed(() =>
  store.products
    .filter((product) => ['ACTIVE', 'Đang bán'].includes(product.status))
    .sort((a, b) => (a.sortOrder || a.id || 0) - (b.sortOrder || b.id || 0)),
)

const popularProducts = computed(() => activeProducts.value.slice(0, 8))

const featuredCards = computed(() => [
  ...activeProducts.value.slice(0, 1).map((product) => ({
    title: product.name,
    description: product.description || '',
    cta: 'Xem sản phẩm',
    to: '/products',
    image: product.imageUrl || 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1400&q=85',
    badge: product.category || 'Bán chạy nhất',
  })),
  franchiseFeatureCard,
])

const activeLocations = computed(() =>
  store.locations
    .filter((location) => ['ACTIVE', 'Đang hoạt động'].includes(location.status))
    .sort((a, b) => {
      if (a.featured !== b.featured) return a.featured ? -1 : 1
      return (a.displayOrder || a.id || 0) - (b.displayOrder || b.id || 0)
    })
    .slice(0, 3),
)

const scrollProducts = (direction) => {
  productRail.value?.scrollBy({
    left: direction * 340,
    behavior: 'smooth',
  })
}

const productMeta = (product) =>
  Number(product.price) > 0 ? product.priceDisplay : product.category || 'ALOO Signature'

onMounted(() => {
  Promise.allSettled([store.fetchProducts(), store.fetchLocations()])
})
</script>

<template>
  <section class="bg-avocado-50/20">
    <!-- Hero Banner with Glassmorphic Content Card Overlay -->
    <div class="relative h-[80vh] min-h-[580px] w-full overflow-hidden bg-avocado-950">
      <img
        class="absolute inset-0 h-full w-full object-cover opacity-60 mix-blend-luminosity"
        src="https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=2200&q=90"
        alt="ALOO Kem Bơ Thuần Việt"
      />
      
      <!-- Gradient overlay for readability -->
      <div class="absolute inset-0 bg-gradient-to-t from-avocado-950 via-avocado-950/40 to-transparent"></div>
      <div class="absolute inset-0 bg-gradient-to-r from-avocado-950/80 via-transparent to-transparent"></div>

      <!-- Hero Content -->
      <div class="absolute inset-0 flex items-center justify-start px-4 sm:px-6 lg:px-8">
        <div class="mx-auto w-full max-w-6xl">
          <div class="max-w-2xl glass-panel-dark text-white p-8 sm:p-10 rounded-3xl border border-white/10 shadow-2xl relative">
            <div class="absolute -top-3 left-8 bg-cream-400 text-avocado-950 text-xs font-black tracking-widest uppercase px-3 py-1 rounded-full shadow-md">
              Thương hiệu số 1 về Kem Bơ
            </div>
            <h1 class="text-4xl sm:text-5xl font-black leading-tight text-white mt-2">
              ALOO — Kem Bơ <br />
              <span class="text-transparent bg-clip-text bg-gradient-to-r from-cream-300 to-cream-200">Thuần Việt</span>
            </h1>
            <p class="mt-4 text-base leading-relaxed text-white/80">
              Sự kết hợp hoàn hảo giữa những quả bơ chín sáp xay mịn, kem dừa ngọt thanh mát lạnh cùng topping dừa khô giòn rụm. Hương vị truyền thống, diện mạo trẻ trung!
            </p>
            <div class="mt-8 flex flex-wrap gap-4">
              <RouterLink to="/products" class="rounded-full bg-cream-400 text-avocado-950 font-bold px-6 py-3 hover:bg-cream-300 transition duration-300 transform hover:-translate-y-0.5 shadow-lg shadow-cream-400/20">
                Khám phá Menu
              </RouterLink>
              <RouterLink to="/consultation" class="rounded-full border border-white/20 bg-white/5 backdrop-blur-sm text-white font-bold px-6 py-3 hover:bg-white/10 transition duration-300 transform hover:-translate-y-0.5">
                Nhượng quyền ngay
              </RouterLink>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Featured Section -->
    <section class="mx-auto max-w-6xl px-4 py-16 sm:px-6 lg:px-8">
      <div class="mb-10 text-center sm:text-left">
        <span class="text-xs font-bold uppercase tracking-[0.2em] text-avocado-600">Tuyển chọn</span>
        <h2 class="mt-2 text-3xl font-black text-avocado-950 lg:text-4xl">Nổi bật hôm nay</h2>
        <div class="mt-2 h-1 w-12 bg-cream-400 rounded-full mx-auto sm:mx-0"></div>
      </div>
      <div class="grid gap-8 lg:grid-cols-2">
        <RouterLink
          v-for="card in featuredCards"
          :key="card.title"
          :to="card.to"
          class="group overflow-hidden rounded-3xl bg-white shadow-md hover-lift flex flex-col border border-avocado-100/30"
        >
          <div class="aspect-[16/9] overflow-hidden relative">
            <div class="absolute top-4 left-4 z-10 rounded-full bg-avocado-900/80 backdrop-blur-md px-3.5 py-1 text-xs font-bold text-cream-300">
              {{ card.badge }}
            </div>
            <img :src="card.image" :alt="card.title" class="h-full w-full object-cover transition duration-500 group-hover:scale-105" />
          </div>
          <div class="p-6 flex-1 flex flex-col justify-between">
            <div>
              <h3 class="text-xl font-bold text-avocado-950 transition group-hover:text-avocado-700">{{ card.title }}</h3>
              <p class="mt-2 text-sm leading-relaxed text-slate-500">{{ card.description }}</p>
            </div>
            <div class="mt-5 flex items-center justify-between">
              <span class="inline-flex items-center gap-1.5 text-sm font-bold text-avocado-800 group-hover:text-avocado-600">
                {{ card.cta }} <ArrowRight class="h-4 w-4 transition transform group-hover:translate-x-1" />
              </span>
            </div>
          </div>
        </RouterLink>
      </div>
    </section>

    <!-- Trending Products Slider Section -->
    <section class="mx-auto max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
      <div class="mb-10 flex items-end justify-between gap-4">
        <div>
          <span class="text-xs font-bold uppercase tracking-[0.2em] text-avocado-600">Món ngon nước tiếng</span>
          <h2 class="mt-2 text-3xl font-black text-avocado-950 lg:text-4xl">Sản phẩm được yêu thích</h2>
        </div>
        <div class="hidden gap-2.5 sm:flex">
          <button class="grid h-10 w-10 place-items-center rounded-full border border-avocado-200/80 bg-white text-avocado-950 hover:bg-avocado-50 hover:border-avocado-300 shadow-sm transition" aria-label="Cuộn trái" @click="scrollProducts(-1)">
            <ChevronLeft class="h-5 w-5" />
          </button>
          <button class="grid h-10 w-10 place-items-center rounded-full border border-avocado-200/80 bg-white text-avocado-950 hover:bg-avocado-50 hover:border-avocado-300 shadow-sm transition" aria-label="Cuộn phải" @click="scrollProducts(1)">
            <ChevronRight class="h-5 w-5" />
          </button>
        </div>
      </div>

      <p v-if="store.errors.products" class="rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-center text-sm font-bold text-red-700">
        {{ store.errors.products }}
      </p>
      <div v-else-if="store.loading.products" class="product-scrollbar flex snap-x gap-6 overflow-x-auto pb-8">
        <article v-for="i in 4" :key="i" class="min-w-[75vw] snap-start rounded-3xl border border-avocado-100/30 bg-white p-4 shadow-sm sm:min-w-[280px] lg:min-w-[290px]">
          <div class="aspect-square animate-pulse rounded-2xl bg-slate-100"></div>
          <div class="mt-4 space-y-3">
            <div class="h-3 w-20 animate-pulse rounded bg-slate-100"></div>
            <div class="h-5 w-4/5 animate-pulse rounded bg-slate-100"></div>
            <div class="h-4 w-full animate-pulse rounded bg-slate-100"></div>
          </div>
        </article>
      </div>
      <div v-else-if="popularProducts.length" ref="productRail" class="product-scrollbar flex snap-x gap-6 overflow-x-auto pb-8">
        <article v-for="product in popularProducts" :key="product.id" class="min-w-[75vw] snap-start sm:min-w-[280px] lg:min-w-[290px] bg-white rounded-3xl p-4 shadow-sm border border-avocado-100/30 hover-lift group">
          <div class="aspect-square overflow-hidden rounded-2xl bg-avocado-50/50 relative">
            <button class="absolute top-3 right-3 h-8 w-8 rounded-full bg-white/80 backdrop-blur-sm grid place-items-center text-slate-400 hover:text-red-500 transition shadow-sm" aria-label="Yêu thích">
              <Heart class="h-4 w-4 fill-transparent" />
            </button>
            <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="h-full w-full object-cover transition-all duration-300 group-hover:scale-105" />
            <div v-else class="grid h-full place-items-center text-xl font-black text-avocado-700">ALOO</div>
          </div>
          <div class="mt-4 space-y-1">
            <div class="flex items-center gap-1">
              <Star v-for="i in 5" :key="i" class="h-3 w-3 fill-cream-400 text-cream-400" />
              <span class="text-xs text-slate-400 ml-1 font-semibold">5.0</span>
            </div>
            <h3 class="text-base font-bold text-avocado-950 transition group-hover:text-avocado-800">{{ product.name }}</h3>
            <p class="text-xs leading-relaxed text-slate-400 h-8 line-clamp-2">{{ product.description }}</p>
          </div>
          <div class="mt-4 flex items-center justify-between border-t border-slate-50 pt-3">
            <p class="text-base font-black text-avocado-800">{{ productMeta(product) }}</p>
            <RouterLink to="/products" class="rounded-full bg-avocado-50 border border-avocado-100 hover:bg-avocado-100 px-3.5 py-1.5 text-xs font-bold text-avocado-800 transition">
              Xem chi tiết
            </RouterLink>
          </div>
        </article>
      </div>
      <p v-else class="rounded-3xl border border-slate-200 bg-white px-6 py-12 text-center text-sm font-bold text-slate-400">
        Chưa có sản phẩm đang bán. Vào admin để thêm hoặc bật trạng thái sản phẩm.
      </p>
    </section>


    <!-- Brand Story Section (Asymmetrical Layout) -->
    <section class="mx-auto max-w-6xl px-4 py-16 sm:px-6 lg:px-8">
      <div class="grid items-center gap-10 lg:grid-cols-2">
        <div class="space-y-6 max-w-lg">
          <div class="flex items-center gap-2">
            <Award class="h-5 w-5 text-cream-600" />
            <span class="text-xs font-bold uppercase tracking-[0.2em] text-avocado-600">Câu chuyện thương hiệu</span>
          </div>
          <h2 class="text-3xl font-black leading-tight text-avocado-950 lg:text-4xl">
            Từ tinh hoa trái bơ chín sáp đến ly kem mát lành
          </h2>
          <p class="text-base leading-relaxed text-slate-600">
            Hành trình của ALOO bắt đầu từ tình yêu cháy bỏng với nguồn nông sản tươi tốt của dải đất hình chữ S. Chúng tôi lựa chọn kỹ càng từng quả bơ chín sáp Đắk Lắk béo bùi dẻo mịn nhất để xay cùng chút cốt sữa ngọt thơm.
          </p>
          <p class="text-sm leading-relaxed text-slate-500">
            Chúng tôi tự hào xây dựng một mô hình cửa hàng trẻ trung, quy trình vận hành đồng bộ hóa từ quầy pha chế đến phong cách đón khách. Giúp mỗi ly kem bơ khi đến tay bạn luôn giữ nguyên được hương vị tự nhiên tinh tế nhất.
          </p>
          <div class="pt-2">
            <RouterLink to="/about" class="inline-flex items-center gap-2 rounded-full bg-cream-400 px-6 py-3 text-xs font-bold uppercase tracking-wider text-avocado-950 hover:bg-cream-300 transition shadow-md">
              Đọc tiếp câu chuyện <ArrowRight class="h-4 w-4" />
            </RouterLink>
          </div>
        </div>
        <div class="relative">
          <div class="absolute -top-4 -left-4 w-24 h-24 bg-cream-200/50 rounded-full blur-2xl z-0"></div>
          <div class="absolute -bottom-4 -right-4 w-32 h-32 bg-avocado-300/30 rounded-full blur-2xl z-0"></div>
          <div class="overflow-hidden rounded-3xl bg-white p-3 shadow-xl border border-avocado-100/30 relative z-10">
            <img
              src="https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2?auto=format&fit=crop&w=1500&q=85"
              alt="Nguyên liệu bơ tươi"
              class="aspect-[4/3] w-full object-cover rounded-2xl"
            />
          </div>
        </div>
      </div>
    </section>

    <!-- Location Finder Section -->
    <section class="mx-auto max-w-6xl px-4 py-16 sm:px-6 lg:px-8 border-t border-avocado-100/50">
      <div class="mb-10 flex flex-col justify-between gap-4 sm:flex-row sm:items-end text-center sm:text-left">
        <div>
          <span class="text-xs font-bold uppercase tracking-[0.2em] text-avocado-600">Trải nghiệm trực tiếp</span>
          <h2 class="mt-2 text-3xl font-black text-avocado-950 lg:text-4xl">Tìm cửa hàng ALOO gần nhất</h2>
        </div>
        <RouterLink to="/locations" class="inline-flex items-center justify-center gap-1.5 text-sm font-bold text-avocado-700 hover:text-avocado-950 transition">
          Xem tất cả hệ thống cửa hàng <ArrowRight class="h-4 w-4" />
        </RouterLink>
      </div>
      <p v-if="store.errors.locations" class="rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-center text-sm font-bold text-red-700">
        {{ store.errors.locations }}
      </p>
      <div v-else-if="store.loading.locations" class="grid gap-6 md:grid-cols-3">
        <article v-for="i in 3" :key="i" class="rounded-3xl border border-avocado-100/40 bg-white p-6 shadow-sm">
          <div class="h-10 w-10 animate-pulse rounded-2xl bg-slate-100"></div>
          <div class="mt-5 h-5 w-3/4 animate-pulse rounded bg-slate-100"></div>
          <div class="mt-3 h-4 w-full animate-pulse rounded bg-slate-100"></div>
          <div class="mt-3 h-4 w-2/3 animate-pulse rounded bg-slate-100"></div>
        </article>
      </div>
      <div v-else-if="activeLocations.length" class="grid gap-6 md:grid-cols-3">
        <article v-for="location in activeLocations" :key="location.id" class="rounded-3xl border border-avocado-100/40 bg-white p-6 shadow-sm hover-lift flex flex-col justify-between">
          <div>
            <div class="grid h-10 w-10 place-items-center rounded-2xl bg-avocado-50 text-avocado-700 shadow-inner">
              <MapPin class="h-5 w-5" />
            </div>
            <h3 class="mt-5 text-lg font-bold text-avocado-950">{{ location.name }}</h3>
            <p class="mt-2 text-sm leading-relaxed text-slate-500">{{ location.addressText }}</p>
            <p class="mt-2 text-xs font-semibold text-slate-400 bg-slate-50 inline-block px-2.5 py-1 rounded-md">Giờ hoạt động: {{ location.openingHours || 'Đang cập nhật' }}</p>
          </div>
          <div class="mt-6 border-t border-slate-50 pt-4">
            <a :href="location.mapUrl || '/locations'" target="_blank" rel="noreferrer" class="inline-flex w-full justify-center rounded-full border border-avocado-200 hover:border-avocado-300 hover:bg-avocado-50 px-4 py-2.5 text-xs font-bold text-avocado-800 transition">
              Chỉ đường chi tiết
            </a>
          </div>
        </article>
      </div>
      <p v-else class="rounded-3xl border border-slate-200 bg-white px-6 py-12 text-center text-sm font-bold text-slate-400">
        Chưa có cửa hàng đang hoạt động. Vào admin để thêm hoặc bật trạng thái địa điểm.
      </p>
    </section>

    <!-- Premium Call-to-action Franchise Section -->
    <section class="mx-auto max-w-6xl px-4 py-10 sm:px-6 lg:px-8">
      <div class="overflow-hidden rounded-3xl bg-gradient-to-br from-avocado-950 via-avocado-900 to-[#122310] px-8 py-12 text-white sm:px-12 lg:px-16 shadow-2xl relative">
        <!-- Floating decorative glowing circle -->
        <div class="absolute -right-10 -top-10 w-44 h-44 bg-cream-400/10 rounded-full blur-2xl pointer-events-none"></div>

        <div class="max-w-2xl relative z-10">
          <span class="text-xs font-bold uppercase tracking-[0.25em] text-cream-300 bg-white/5 border border-white/10 px-3 py-1 rounded-full">Kế hoạch nhượng quyền</span>
          <h2 class="mt-5 text-3xl font-black leading-tight text-white lg:text-4xl">Đồng hành kinh doanh cùng ALOO</h2>
          <p class="mt-3 text-base leading-relaxed text-white/80">
            Mô hình đầu tư kem bơ tinh gọn, chi phí tối giản, vận hành bài bản và tệp khách hàng trẻ đầy tiềm năng. Hỗ trợ trọn gói từ định vị mặt bằng đến marketing và đào tạo pha chế.
          </p>
          <div class="mt-8 flex flex-wrap gap-4">
            <RouterLink to="/consultation" class="rounded-full bg-cream-400 text-avocado-950 font-bold px-6 py-3.5 hover:bg-cream-300 transition duration-300 shadow-lg shadow-cream-400/25 uppercase tracking-wider text-xs">
              Đăng ký tư vấn miễn phí
            </RouterLink>
            <RouterLink to="/franchise" class="rounded-full border border-white/20 bg-white/5 text-white font-bold px-6 py-3.5 hover:bg-white/10 transition duration-300 text-xs uppercase tracking-wider">
              Khảo sát chi phí đầu tư
            </RouterLink>
          </div>
        </div>
      </div>
    </section>
  </section>
</template>

<style scoped>
.product-scrollbar {
  scrollbar-color: #58b030 #faf8f2;
  scrollbar-width: thin;
}

.product-scrollbar::-webkit-scrollbar {
  height: 8px;
}

.product-scrollbar::-webkit-scrollbar-track {
  border-radius: 999px;
  background: #faf8f2;
}

.product-scrollbar::-webkit-scrollbar-thumb {
  border-radius: 999px;
  background: #c9ebb6;
}

.product-scrollbar::-webkit-scrollbar-thumb:hover {
  background: #a2dd85;
}
</style>
