<script setup>
import { computed, onMounted, ref } from 'vue'
import { ChevronLeft, ChevronRight, MapPin, Award, Star, ArrowRight, Heart } from 'lucide-vue-next'
import { useAppStore } from '../../stores/appStore'
import { homeSectionService, resolveBackendAssetUrl } from '../../services/cmsService'

const store = useAppStore()
const productRail = ref(null)

const homeSections = ref([])
const homeSectionsLoading = ref(false)
const homeSectionsError = ref('')

const activeProducts = computed(() =>
  store.products
    .filter((product) => ['ACTIVE', 'Đang bán'].includes(product.status))
    .sort((a, b) => (a.sortOrder || a.id || 0) - (b.sortOrder || b.id || 0)),
)

const popularProducts = computed(() => activeProducts.value.slice(0, 8))

const featuredCards = computed(() =>
  homeSections.value
    .filter((section) => section.status === 'ACTIVE')
    .sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0))
    .slice(0, 4)
    .map((section) => ({
      title: section.title,
      description: section.description || section.subtitle || '',
      cta: section.buttonText || 'Xem thêm',
      to: section.buttonLink || '/',
      image: resolveBackendAssetUrl(section.imageUrl || ''),
      badge: section.badge || section.subtitle || 'Nổi bật',
    }))
)

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

const productMeta = (product) => product.category || 'ALOO Signature'

const fetchHomeSections = async () => {
  homeSectionsLoading.value = true
  homeSectionsError.value = ''
  try {
    const { data } = await homeSectionService.list(true)
    homeSections.value = Array.isArray(data) ? data : []
  } catch (error) {
    homeSectionsError.value = error.response?.data?.message || 'Không tải được nội dung nổi bật trang chủ'
  } finally {
    homeSectionsLoading.value = false
  }
}

onMounted(() => {
  Promise.allSettled([store.fetchProducts(), store.fetchLocations(), fetchHomeSections()])
})
</script>

<template>
  <section class="bg-brand-cream/10">
    <!-- Hero Banner with Glassmorphic Content Card Overlay -->
    <div class="relative h-[85vh] min-h-[600px] w-full overflow-hidden bg-brand-dark">
      <img
        class="absolute inset-0 h-full w-full object-cover opacity-50 mix-blend-luminosity scale-[1.01]"
        src="https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=2200&q=90"
        alt="ALOO Kem Bơ Thuần Việt"
      />
      
      <!-- Gradient overlay for readability -->
      <div class="absolute inset-0 bg-gradient-to-t from-brand-dark via-brand-dark/40 to-transparent"></div>
      <div class="absolute inset-0 bg-gradient-to-r from-brand-dark/80 via-transparent to-transparent"></div>

      <!-- Hero Content -->
      <div class="absolute inset-0 flex items-center justify-start px-4 sm:px-6 lg:px-8">
        <div class="mx-auto w-full max-w-[1280px]">
          <div class="max-w-2xl glass-panel-dark text-white p-8 sm:p-10 rounded-3xl border border-white/10 shadow-2xl relative">
            <div class="absolute -top-3 left-8 bg-brand-lime text-brand-dark text-xs font-black tracking-widest uppercase px-3 py-1 rounded-full shadow-md">
              Thương hiệu số 1 về Kem Bơ
            </div>
            <h1 class="text-4xl sm:text-5xl font-black leading-tight text-white mt-2 font-display">
              ALOO — Kem Bơ <br />
              <span class="text-transparent bg-clip-text bg-gradient-to-r from-brand-lime to-brand-sand">Thuần Việt</span>
            </h1>
            <p class="mt-4 text-base leading-relaxed text-white/80">
              Sự kết hợp hoàn hảo giữa những quả bơ chín sáp xay mịn, kem dừa ngọt thanh mát lạnh cùng topping dừa khô giòn rụm. Hương vị truyền thống, diện mạo trẻ trung!
            </p>
            <div class="mt-8 flex flex-wrap gap-4">
              <RouterLink to="/products" class="rounded-full bg-brand-lime text-brand-dark font-black px-6 py-3.5 hover:bg-brand-lime/90 transition duration-300 transform hover:-translate-y-0.5 shadow-lg shadow-brand-lime/20 text-sm">
                Khám phá Menu
              </RouterLink>
              <RouterLink to="/consultation" class="rounded-full border border-white/20 bg-white/5 backdrop-blur-sm text-white font-bold px-6 py-3.5 hover:bg-white/10 transition duration-300 transform hover:-translate-y-0.5 text-sm">
                Nhượng quyền ngay
              </RouterLink>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Featured Section -->
    <section class="mx-auto max-w-[1280px] px-4 py-20 sm:px-6 lg:px-8">
      <div class="mb-12 text-center sm:text-left flex flex-col sm:flex-row sm:items-end justify-between border-b border-brand-forest/5 pb-4">
        <div>
          <span class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">Tuyển chọn</span>
          <h2 class="mt-2 text-3xl font-black text-brand-dark lg:text-4xl">Nổi bật hôm nay</h2>
        </div>
        <p class="text-sm text-brand-muted mt-2 sm:mt-0 font-medium">Bí quyết tự nhiên từ nguyên liệu vườn sạch</p>
      </div>

      <p v-if="homeSectionsError" class="rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-center text-sm font-bold text-red-700">{{ homeSectionsError }}</p>
      <div v-else-if="homeSectionsLoading" class="grid gap-8 lg:grid-cols-2">
        <div v-for="i in 2" :key="i" class="overflow-hidden rounded-3xl border border-brand-forest/5 bg-white shadow-sm">
          <div class="aspect-[16/9] animate-pulse bg-slate-100"></div>
          <div class="space-y-3 p-6">
            <div class="h-5 w-2/3 animate-pulse rounded bg-slate-100"></div>
            <div class="h-4 w-full animate-pulse rounded bg-slate-100"></div>
          </div>
        </div>
      </div>
      <p v-else-if="!featuredCards.length" class="rounded-3xl border border-slate-200 bg-white px-6 py-12 text-center text-sm font-bold text-slate-400">
        Chưa có nội dung nổi bật. Vào admin để thêm block trang chủ.
      </p>
      <div v-else class="grid gap-8 lg:grid-cols-2">
        <RouterLink
          v-for="card in featuredCards"
          :key="card.title"
          :to="card.to"
          class="group overflow-hidden rounded-3xl bg-white shadow-sm hover-lift flex flex-col border border-brand-forest/5"
        >
          <div class="aspect-[16/9] overflow-hidden relative">
            <div class="absolute top-4 left-4 z-10 rounded-full bg-brand-dark/80 backdrop-blur-md px-3.5 py-1.5 text-xs font-bold text-brand-lime">
              {{ card.badge }}
            </div>
            <img v-if="card.image" :src="card.image" :alt="card.title" class="h-full w-full object-cover transition duration-500 group-hover:scale-103" />
            <div v-else class="grid h-full place-items-center bg-brand-lime/10 text-2xl font-black text-brand-forest">ALOO</div>
          </div>
          <div class="p-6 flex-1 flex flex-col justify-between">
            <div>
              <h3 class="text-xl font-bold text-brand-dark transition group-hover:text-brand-forest">{{ card.title }}</h3>
              <p class="mt-2.5 text-sm leading-relaxed text-brand-muted font-medium">{{ card.description }}</p>
            </div>
            <div class="mt-6 flex items-center justify-between border-t border-slate-50 pt-4">
              <span class="inline-flex items-center gap-1.5 text-xs font-black uppercase tracking-wider text-brand-forest group-hover:text-brand-lime transition">
                {{ card.cta }} <ArrowRight class="h-4 w-4 transition transform group-hover:translate-x-1" />
              </span>
            </div>
          </div>
        </RouterLink>
      </div>
    </section>

    <!-- Trending Products Slider Section -->
    <section class="mx-auto max-w-[1280px] px-4 py-12 sm:px-6 lg:px-8">
      <div class="mb-12 flex items-end justify-between gap-4 border-b border-brand-forest/5 pb-4">
        <div>
          <span class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">Món ngon nước tiếng</span>
          <h2 class="mt-2 text-3xl font-black text-brand-dark lg:text-4xl">Sản phẩm được yêu thích</h2>
        </div>
        <div class="hidden gap-2.5 sm:flex">
          <button class="grid h-10 w-10 place-items-center rounded-full border border-brand-forest/10 bg-white text-brand-dark hover:bg-brand-cream hover:border-brand-forest/20 shadow-sm transition cursor-pointer active:scale-95" aria-label="Cuộn trái" @click="scrollProducts(-1)">
            <ChevronLeft class="h-5 w-5" />
          </button>
          <button class="grid h-10 w-10 place-items-center rounded-full border border-brand-forest/10 bg-white text-brand-dark hover:bg-brand-cream hover:border-brand-forest/20 shadow-sm transition cursor-pointer active:scale-95" aria-label="Cuộn phải" @click="scrollProducts(1)">
            <ChevronRight class="h-5 w-5" />
          </button>
        </div>
      </div>

      <p v-if="store.errors.products" class="rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-center text-sm font-bold text-red-700">
        {{ store.errors.products }}
      </p>
      <div v-else-if="store.loading.products" class="product-scrollbar flex snap-x gap-6 overflow-x-auto pb-8">
        <article v-for="i in 4" :key="i" class="min-w-[75vw] snap-start rounded-3xl border border-brand-forest/5 bg-white p-4 shadow-sm sm:min-w-[280px] lg:min-w-[290px]">
          <div class="aspect-square animate-pulse rounded-2xl bg-slate-100"></div>
          <div class="mt-4 space-y-3">
            <div class="h-3 w-20 animate-pulse rounded bg-slate-100"></div>
            <div class="h-5 w-4/5 animate-pulse rounded bg-slate-100"></div>
            <div class="h-4 w-full animate-pulse rounded bg-slate-100"></div>
          </div>
        </article>
      </div>
      <div v-else-if="popularProducts.length" ref="productRail" class="product-scrollbar flex snap-x gap-6 overflow-x-auto pb-8">
        <article v-for="product in popularProducts" :key="product.id" class="min-w-[75vw] snap-start sm:min-w-[280px] lg:min-w-[290px] bg-white rounded-3xl p-4 shadow-sm border border-brand-forest/5 hover-lift group">
          <div class="aspect-square overflow-hidden rounded-2xl bg-brand-cream/30 relative">
            <button class="absolute top-3 right-3 h-8 w-8 rounded-full bg-white/80 backdrop-blur-sm grid place-items-center text-slate-400 hover:text-red-500 transition shadow-sm cursor-pointer" aria-label="Yêu thích">
              <Heart class="h-4 w-4 fill-transparent" />
            </button>
            <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="h-full w-full object-cover transition-all duration-300 group-hover:scale-105" />
            <div v-else class="grid h-full place-items-center text-xl font-black text-brand-forest bg-brand-lime/10">ALOO</div>
          </div>
          <div class="mt-4 space-y-1.5">
            <div class="flex items-center gap-1">
              <Star v-for="i in 5" :key="i" class="h-3 w-3 fill-brand-sand text-brand-sand" />
              <span class="text-xs text-brand-muted ml-1 font-bold">5.0</span>
            </div>
            <h3 class="text-base font-bold text-brand-dark transition group-hover:text-brand-forest">{{ product.name }}</h3>
            <p class="text-xs leading-relaxed text-brand-muted font-medium h-8 line-clamp-2">{{ product.description }}</p>
          </div>
          <div class="mt-4 flex items-center justify-between border-t border-slate-50 pt-3">
            <p class="text-sm font-black text-brand-forest font-display">{{ productMeta(product) }}</p>
            <RouterLink :to="product.slug ? `/products/${product.slug}` : '/products'" class="rounded-full bg-brand-lime/15 hover:bg-brand-lime/30 px-3.5 py-1.5 text-xs font-black text-brand-forest transition">
              Xem chi tiết
            </RouterLink>
          </div>
        </article>
      </div>
      <p v-else class="rounded-3xl border border-slate-200 bg-white px-6 py-12 text-center text-sm font-bold text-slate-400">
        Chưa có sản phẩm đang bán. Vào admin để thêm hoặc bật trạng thái sản phẩm.
      </p>
    </section>

    <!-- Brand Story Section (Asymmetrical Layout with warm beige background details) -->
    <section class="bg-brand-cream/50 py-20">
      <div class="mx-auto max-w-[1280px] px-4 sm:px-6 lg:px-8">
        <div class="grid items-center gap-12 lg:grid-cols-2">
          <div class="space-y-6 max-w-lg">
            <div class="flex items-center gap-2">
              <Award class="h-5 w-5 text-brand-brown" />
              <span class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">Câu chuyện thương hiệu</span>
            </div>
            <h2 class="text-3xl font-black leading-tight text-brand-dark lg:text-4xl">
              Từ tinh hoa trái bơ chín sáp đến ly kem mát lành
            </h2>
            <p class="text-base leading-relaxed text-brand-muted font-medium">
              Hành trình của ALOO bắt đầu từ tình yêu cháy bỏng với nguồn nông sản tươi tốt của dải đất hình chữ S. Chúng tôi lựa chọn kỹ càng từng quả bơ chín sáp Đắk Lắk béo bùi dẻo mịn nhất để xay cùng chút cốt sữa ngọt thơm.
            </p>
            <p class="text-sm leading-relaxed text-brand-muted">
              Chúng tôi tự hào xây dựng một mô hình cửa hàng trẻ trung, quy trình vận hành đồng bộ hóa từ quầy pha chế đến phong cách đón khách. Giúp mỗi ly kem bơ khi đến tay bạn luôn giữ nguyên được hương vị tự nhiên tinh tế nhất.
            </p>
            <div class="pt-2">
              <RouterLink to="/about" class="inline-flex items-center gap-2 rounded-full bg-brand-lime text-brand-dark px-6 py-3.5 text-xs font-black uppercase tracking-wider hover:bg-brand-lime/90 transition shadow-md">
                Đọc tiếp câu chuyện <ArrowRight class="h-4 w-4" />
              </RouterLink>
            </div>
          </div>
          <div class="relative">
            <div class="absolute -top-4 -left-4 w-24 h-24 bg-brand-lime/10 rounded-full blur-2xl z-0"></div>
            <div class="absolute -bottom-4 -right-4 w-32 h-32 bg-brand-sand/15 rounded-full blur-2xl z-0"></div>
            <div class="overflow-hidden rounded-3xl bg-white p-3 shadow-xl border border-brand-forest/5 relative z-10">
              <img
                src="https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2?auto=format&fit=crop&w=1500&q=85"
                alt="Nguyên liệu bơ tươi"
                class="aspect-[4/3] w-full object-cover rounded-2xl"
              />
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Location Finder Section -->
    <section class="mx-auto max-w-[1280px] px-4 py-20 sm:px-6 lg:px-8">
      <div class="mb-12 flex flex-col justify-between gap-4 sm:flex-row sm:items-end text-center sm:text-left border-b border-brand-forest/5 pb-4">
        <div>
          <span class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">Trải nghiệm trực tiếp</span>
          <h2 class="mt-2 text-3xl font-black text-brand-dark lg:text-4xl">Tìm cửa hàng ALOO gần nhất</h2>
        </div>
        <RouterLink to="/locations" class="inline-flex items-center justify-center gap-1.5 text-sm font-bold text-brand-forest hover:text-brand-dark transition">
          Xem tất cả hệ thống cửa hàng <ArrowRight class="h-4 w-4" />
        </RouterLink>
      </div>
      <p v-if="store.errors.locations" class="rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-center text-sm font-bold text-red-700">
        {{ store.errors.locations }}
      </p>
      <div v-else-if="store.loading.locations" class="grid gap-6 md:grid-cols-3">
        <article v-for="i in 3" :key="i" class="rounded-3xl border border-brand-forest/5 bg-white p-6 shadow-sm">
          <div class="h-10 w-10 animate-pulse rounded-2xl bg-slate-100"></div>
          <div class="mt-5 h-5 w-3/4 animate-pulse rounded bg-slate-100"></div>
          <div class="mt-3 h-4 w-full animate-pulse rounded bg-slate-100"></div>
          <div class="mt-3 h-4 w-2/3 animate-pulse rounded bg-slate-100"></div>
        </article>
      </div>
      <div v-else-if="activeLocations.length" class="grid gap-6 md:grid-cols-3">
        <article v-for="location in activeLocations" :key="location.id" class="rounded-3xl border border-brand-forest/5 bg-white p-6 shadow-sm hover-lift flex flex-col justify-between">
          <div>
            <div class="grid h-10 w-10 place-items-center rounded-2xl bg-brand-lime/10 text-brand-forest shadow-inner">
              <MapPin class="h-5 w-5" />
            </div>
            <h3 class="mt-5 text-lg font-bold text-brand-dark">{{ location.name }}</h3>
            <p class="mt-2 text-sm leading-relaxed text-brand-muted font-medium">{{ location.addressText }}</p>
            <p class="mt-2 text-xs font-bold text-brand-forest bg-brand-lime/10 inline-block px-3 py-1 rounded-full">Giờ hoạt động: {{ location.openingHours || 'Đang cập nhật' }}</p>
          </div>
          <div class="mt-6 border-t border-slate-100 pt-4">
            <a :href="location.mapUrl || '/locations'" target="_blank" rel="noreferrer" class="inline-flex w-full justify-center rounded-full border border-brand-forest/10 hover:border-brand-forest hover:bg-brand-lime/10 px-4 py-2.5 text-xs font-black text-brand-forest transition">
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
    <section class="mx-auto max-w-[1280px] px-4 py-12 sm:px-6 lg:px-8">
      <div class="overflow-hidden rounded-3xl bg-gradient-to-br from-brand-dark via-brand-dark/95 to-brand-forest px-8 py-16 text-white sm:px-12 lg:px-16 shadow-2xl relative border border-white/5">
        <!-- Floating decorative glowing circle -->
        <div class="absolute -right-10 -top-10 w-44 h-44 bg-brand-lime/10 rounded-full blur-2xl pointer-events-none"></div>

        <div class="max-w-2xl relative z-10">
          <span class="text-xs font-black uppercase tracking-[0.25em] text-brand-lime bg-white/5 border border-white/10 px-3 py-1.5 rounded-full">Kế hoạch nhượng quyền</span>
          <h2 class="mt-6 text-3xl font-black leading-tight text-white lg:text-4xl">Đồng hành kinh doanh cùng ALOO</h2>
          <p class="mt-3 text-base leading-relaxed text-white/80">
            Mô hình đầu tư kem bơ tinh gọn, chi phí tối giản, vận hành bài bản và tệp khách hàng trẻ đầy tiềm năng. Hỗ trợ trọn gói từ định vị mặt bằng đến marketing và đào tạo pha chế.
          </p>
          <div class="mt-8 flex flex-wrap gap-4">
            <RouterLink to="/consultation" class="rounded-full bg-brand-lime text-brand-dark font-black px-6 py-4 hover:bg-brand-lime/90 transition duration-300 shadow-lg shadow-brand-lime/25 uppercase tracking-wider text-xs">
              Đăng ký tư vấn miễn phí
            </RouterLink>
            <RouterLink to="/franchise" class="rounded-full border border-white/20 bg-white/5 text-white font-bold px-6 py-4 hover:bg-white/10 transition duration-300 text-xs uppercase tracking-wider">
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
  scrollbar-color: #5BBD2F #F7F4EE;
  scrollbar-width: thin;
}

.product-scrollbar::-webkit-scrollbar {
  height: 8px;
}

.product-scrollbar::-webkit-scrollbar-track {
  border-radius: 999px;
  background: #F7F4EE;
}

.product-scrollbar::-webkit-scrollbar-thumb {
  border-radius: 999px;
  background: #c1f0ab;
}

.product-scrollbar::-webkit-scrollbar-thumb:hover {
  background: #5BBD2F;
}
</style>

