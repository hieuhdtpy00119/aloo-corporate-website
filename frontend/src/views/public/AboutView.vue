<script setup>
import { computed, onMounted, ref } from 'vue'
import SectionTitle from '../../components/public/SectionTitle.vue'
import { useI18n } from 'vue-i18n'
import { Heart, Sparkles, Smile, Award, Leaf, Store, Newspaper, ArrowRight, CheckCircle2 } from 'lucide-vue-next'
import { useAppStore } from '../../stores/appStore'
import { brandTimelineService } from '../../services/cmsService'

const { t, tm } = useI18n()
const store = useAppStore()
const timeline = ref([])
const timelineLoading = ref(false)
const timelineError = ref('')

const activeProducts = computed(() =>
  store.products.filter((product) => ['ACTIVE', 'Đang bán'].includes(product.status)),
)

const activeLocations = computed(() =>
  store.locations.filter((location) => ['ACTIVE', 'Đang hoạt động'].includes(location.status)),
)

const publishedPosts = computed(() =>
  store.posts.filter((post) => ['PUBLISHED', 'Đã đăng', 'Đã xuất bản'].includes(post.status)),
)

const metrics = computed(() => [
  { label: 'Sản phẩm đang bán', value: activeProducts.value.length, icon: Leaf },
  { label: 'Cửa hàng hoạt động', value: activeLocations.value.length, icon: Store },
  { label: 'Bài viết thương hiệu', value: publishedPosts.value.length, icon: Newspaper },
])




const fetchTimeline = async () => {
  timelineLoading.value = true
  timelineError.value = ''
  try {
    const { data } = await brandTimelineService.list(true)
    timeline.value = Array.isArray(data) ? data : []
  } catch (error) {
    timelineError.value = error.response?.data?.message || error.message || 'Không tải được lộ trình thương hiệu'
  } finally {
    timelineLoading.value = false
  }
}
onMounted(() => {
  Promise.allSettled([store.fetchProducts(), store.fetchLocations(), store.fetchCategories().then(() => store.fetchPosts()), fetchTimeline()])
})
</script>

<template>
  <main class="bg-[#faf8f2] text-avocado-950 pb-20">
    <!-- Header Hero block -->
    <div class="relative bg-avocado-950 text-white overflow-hidden py-24 px-4 sm:px-6 lg:px-8 text-center">
      <div class="absolute inset-0 opacity-15">
        <img
          src="https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2?auto=format&fit=crop&w=1600&q=80"
          alt="ALOO Brand Background"
          class="h-full w-full object-cover"
        />
      </div>
      <div class="absolute inset-0 bg-gradient-to-b from-transparent to-avocado-950/90"></div>
      <div class="relative max-w-3xl mx-auto space-y-4">
        <span class="inline-block text-xs font-bold uppercase tracking-[0.25em] text-cream-300 bg-white/5 border border-white/10 px-3.5 py-1 rounded-full">
          Về chúng tôi
        </span>
        <h1 class="text-4xl sm:text-5xl font-black tracking-tight text-white mt-3">Về ALOO Kem Bơ</h1>
        <p class="text-base sm:text-lg leading-relaxed text-avocado-100 max-w-2xl mx-auto mt-4">
          Thương hiệu kem bơ thuần Việt tập trung vào nguyên liệu tươi, công thức ổn định và trải nghiệm cửa hàng dễ nhân rộng.
        </p>
      </div>
    </div>

    <!-- Main Content -->
    <section class="max-w-6xl mx-auto px-4 py-16 sm:px-6 lg:px-8">
      <SectionTitle
        :eyebrow="t('about.eyebrow')"
        :title="t('about.title')"
        :description="t('about.description')"
      />

      <div class="mt-12 grid gap-4 md:grid-cols-3">
        <article
          v-for="metric in metrics"
          :key="metric.label"
          class="rounded-3xl border border-avocado-100/40 bg-white p-6 text-center shadow-sm"
        >
          <div class="mx-auto grid h-12 w-12 place-items-center rounded-2xl bg-avocado-50 text-avocado-700">
            <component :is="metric.icon" class="h-6 w-6" />
          </div>
          <p class="mt-4 text-3xl font-black text-avocado-950">{{ metric.value }}</p>
          <p class="mt-1 text-xs font-bold uppercase tracking-wider text-slate-400">{{ metric.label }}</p>
        </article>
      </div>

      <div class="mt-16 grid items-center gap-10 lg:grid-cols-[1.05fr_0.95fr]">
        <div class="overflow-hidden rounded-[2rem] border border-avocado-100/40 bg-white p-3 shadow-xl">
          <img
            src="https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=1500&q=85"
            alt="Ly kem bơ ALOO"
            class="aspect-[4/3] w-full rounded-[1.45rem] object-cover"
          />
        </div>
        <div class="space-y-5">
          <span class="inline-flex rounded-full bg-avocado-50 px-4 py-2 text-xs font-black uppercase tracking-[0.18em] text-avocado-700">
            Câu chuyện thương hiệu
          </span>
          <h2 class="text-3xl font-black leading-tight text-avocado-950 lg:text-4xl">
            ALOO không bán một món tráng miệng rời rạc, mà xây một trải nghiệm kem bơ có thể nhân rộng.
          </h2>
          <p class="leading-8 text-slate-600">
            Từ một món quen thuộc của người Việt, ALOO chuẩn hóa lại cách chọn nguyên liệu, phối vị, trình bày menu và vận hành điểm bán. Mục tiêu là tạo ra một thương hiệu vừa gần gũi, vừa đủ hiện đại để phát triển thành hệ thống.
          </p>
          <div class="grid gap-3">
            <p class="flex gap-3 text-sm font-bold text-slate-700">
              <CheckCircle2 class="mt-0.5 h-5 w-5 shrink-0 text-avocado-600" />
              Menu tinh gọn giúp kiểm soát chất lượng và tốc độ phục vụ.
            </p>
            <p class="flex gap-3 text-sm font-bold text-slate-700">
              <CheckCircle2 class="mt-0.5 h-5 w-5 shrink-0 text-avocado-600" />
              Nhận diện xanh bơ, vàng kem tạo cảm giác tươi, sạch và dễ nhớ.
            </p>
            <p class="flex gap-3 text-sm font-bold text-slate-700">
              <CheckCircle2 class="mt-0.5 h-5 w-5 shrink-0 text-avocado-600" />
              CMS kết nối sản phẩm, địa điểm, bài viết và nội dung nhượng quyền.
            </p>
          </div>
        </div>
      </div>
      
      <div class="grid gap-8 md:grid-cols-3 mt-12">
        <div 
          v-for="(card, index) in tm('about.cards')" 
          :key="card.title" 
          class="rounded-3xl border border-avocado-100/35 bg-white p-8 shadow-sm hover-lift flex flex-col justify-between"
        >
          <div>
            <div class="grid h-12 w-12 place-items-center rounded-2xl bg-avocado-50 text-avocado-700 shadow-inner mb-6">
              <Heart v-if="index === 0" class="h-6 w-6" />
              <Sparkles v-else-if="index === 1" class="h-6 w-6" />
              <Smile v-else class="h-6 w-6" />
            </div>
            <h3 class="text-xl font-bold text-avocado-950">{{ card.title }}</h3>
            <p class="mt-4 text-sm leading-relaxed text-slate-500">{{ card.description }}</p>
          </div>
        </div>
      </div>

      <div class="mt-20">
        <div class="mb-10 max-w-2xl">
          <span class="text-xs font-bold uppercase tracking-[0.2em] text-avocado-600">Lộ trình phát triển</span>
          <h2 class="mt-3 text-3xl font-black text-avocado-950 lg:text-4xl">Từ công thức chủ lực đến mô hình hệ thống</h2>
        </div>
        <p v-if="timelineError" class="rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-sm font-bold text-red-700">{{ timelineError }}</p>
        <div v-else-if="timelineLoading" class="grid gap-5 lg:grid-cols-3">
          <article v-for="i in 3" :key="i" class="rounded-3xl border border-avocado-100/40 bg-white p-6 shadow-sm">
            <div class="h-4 w-20 animate-pulse rounded bg-slate-100"></div>
            <div class="mt-3 h-6 w-4/5 animate-pulse rounded bg-slate-100"></div>
            <div class="mt-3 h-16 animate-pulse rounded bg-slate-100"></div>
          </article>
        </div>
        <p v-else-if="!timeline.length" class="rounded-2xl border border-slate-200 bg-white px-5 py-10 text-center text-sm font-bold text-slate-400">Chưa có dữ liệu. Vui lòng thêm lộ trình thương hiệu trong API/CMS.</p>
        <div v-else class="grid gap-5 lg:grid-cols-3">
          <article v-for="item in timeline" :key="item.id || item.title" class="rounded-3xl border border-avocado-100/40 bg-white p-6 shadow-sm">
            <p class="text-xs font-black uppercase tracking-[0.18em] text-cream-700">{{ item.year }}</p>
            <h3 class="mt-3 text-xl font-black text-avocado-950">{{ item.title }}</h3>
            <p class="mt-3 text-sm leading-7 text-slate-500">{{ item.description }}</p>
          </article>
        </div>
      </div>

      <!-- Asymmetrical highlight segment -->
      <div class="mt-20 overflow-hidden rounded-[2.5rem] bg-gradient-to-r from-avocado-900 to-avocado-950 p-8 sm:p-12 text-white relative shadow-xl">
        <div class="absolute -right-20 -top-20 w-80 h-80 bg-cream-400/5 rounded-full blur-3xl pointer-events-none"></div>
        <div class="grid gap-10 md:grid-cols-[1fr_auto] md:items-center">
          <div class="space-y-4">
            <span class="text-xs font-bold uppercase tracking-[0.2em] text-cream-300">Tầm nhìn</span>
            <h2 class="text-2xl sm:text-3xl font-black">Xây dựng chuỗi kem bơ bền vững hàng đầu Việt Nam</h2>
            <p class="text-sm leading-relaxed text-avocado-100/90 max-w-3xl">
              ALOO hướng tới việc đồng hành cùng người nông dân vùng cao Đắk Lắk, chuẩn hóa quy trình chuỗi cung ứng khép kín và mang đến cho thực khách những sản phẩm từ bơ tươi ngon, bổ dưỡng nhất dưới một nhận diện trẻ trung, hiện đại.
            </p>
          </div>
          <RouterLink to="/franchise" class="rounded-full bg-cream-400 text-avocado-950 font-bold px-6 py-3.5 hover:bg-cream-300 transition duration-300 text-center shadow-lg shadow-cream-400/20 text-xs uppercase tracking-wider">
            Xem cơ hội nhượng quyền
          </RouterLink>
        </div>
      </div>

      <div class="mt-8 grid gap-4 sm:grid-cols-2">
        <RouterLink to="/products" class="group rounded-3xl border border-avocado-100/40 bg-white p-6 shadow-sm transition hover:-translate-y-1 hover:shadow-md">
          <p class="text-xs font-black uppercase tracking-[0.18em] text-avocado-600">Menu</p>
          <h3 class="mt-3 text-xl font-black text-avocado-950">Khám phá sản phẩm ALOO</h3>
          <p class="mt-2 text-sm leading-6 text-slate-500">Xem các món đang được quản lý từ CMS.</p>
          <span class="mt-5 inline-flex items-center gap-2 text-sm font-black text-avocado-700">
            Xem menu <ArrowRight class="h-4 w-4 transition group-hover:translate-x-1" />
          </span>
        </RouterLink>
        <RouterLink to="/locations" class="group rounded-3xl border border-avocado-100/40 bg-white p-6 shadow-sm transition hover:-translate-y-1 hover:shadow-md">
          <p class="text-xs font-black uppercase tracking-[0.18em] text-avocado-600">Hệ thống</p>
          <h3 class="mt-3 text-xl font-black text-avocado-950">Tìm cửa hàng gần bạn</h3>
          <p class="mt-2 text-sm leading-6 text-slate-500">Dữ liệu chi nhánh được đồng bộ từ trang quản trị.</p>
          <span class="mt-5 inline-flex items-center gap-2 text-sm font-black text-avocado-700">
            Xem địa điểm <ArrowRight class="h-4 w-4 transition group-hover:translate-x-1" />
          </span>
        </RouterLink>
      </div>
    </section>
  </main>
</template>


