<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { Heart, Sparkles, Smile, Award, Leaf, Store, Newspaper, ArrowRight, CheckCircle2, Star, MapPin, Users } from 'lucide-vue-next'
import { useAppStore } from '../../stores/appStore'
import { brandTimelineService } from '../../services/cmsService'

const { t, tm } = useI18n()
const store = useAppStore()
const timeline = ref([])
const timelineLoading = ref(false)
const timelineError = ref('')

const CORE_VALUE_ICONS = [Heart, Smile, Sparkles, Award, Star]

const pageDataLoading = computed(
  () => store.loading.products || store.loading.locations || store.loading.posts,
)

const pageDataError = computed(
  () => store.errors.products || store.errors.locations || store.errors.posts,
)

const activeProducts = computed(() =>
  store.products.filter((product) => ['ACTIVE', 'Đang bán'].includes(product.status)),
)

const activeLocations = computed(() =>
  store.locations.filter((location) => ['ACTIVE', 'Đang hoạt động'].includes(location.status)),
)

const publishedPosts = computed(() =>
  store.posts.filter((post) => ['PUBLISHED', 'Đã đăng', 'Đã xuất bản'].includes(post.status)),
)

const metricValue = (count) => {
  if (pageDataLoading.value) return null
  if (pageDataError.value) return '—'
  return count
}

const metrics = computed(() => [
  { label: t('about.metricsProducts'), value: metricValue(activeProducts.value.length), icon: Leaf },
  { label: t('about.metricsLocations'), value: metricValue(activeLocations.value.length), icon: Store },
  { label: t('about.metricsPosts'), value: metricValue(publishedPosts.value.length), icon: Newspaper },
])

const coreValues = computed(() => {
  const items = tm('about.coreValues')
  if (!Array.isArray(items)) return []
  return items.map((item, index) => ({ ...item, icon: CORE_VALUE_ICONS[index] }))
})

const defaultTimeline = computed(() => {
  const items = tm('about.defaultTimeline')
  return Array.isArray(items) ? items : []
})

const timelineItems = computed(() => (timeline.value.length ? timeline.value : defaultTimeline.value))

const menuItems = computed(() => {
  const items = tm('about.menuItems')
  return Array.isArray(items) ? items : []
})

const section1Milestones = computed(() => {
  const items = tm('about.section1Milestones')
  return Array.isArray(items) ? items : []
})

const qualityPoints = computed(() => {
  const items = tm('about.qualityPoints')
  return Array.isArray(items) ? items : []
})

const fetchTimeline = async () => {
  timelineLoading.value = true
  timelineError.value = ''
  try {
    const { data } = await brandTimelineService.list(true)
    timeline.value = Array.isArray(data) ? data : []
  } catch (error) {
    timelineError.value = error.response?.data?.message || error.message || t('about.timelineLoadError')
  } finally {
    timelineLoading.value = false
  }
}

onMounted(() => {
  Promise.allSettled([store.fetchProducts(), store.fetchLocations(), store.fetchCategories().then(() => store.fetchPosts()), fetchTimeline()])
})
</script>

<template>
  <div class="bg-brand-cream text-avocado-950 pb-20">

    <!-- ===== HERO ===== -->
    <div class="relative overflow-hidden bg-avocado-950 text-white">
      <div class="absolute inset-0">
        <img
          src="/about/aloo-about-hero.png"
          alt=""
          aria-hidden="true"
          class="h-full w-full object-cover object-center"
        />
      </div>
      <div class="absolute inset-0 bg-gradient-to-b from-black/45 via-black/35 to-black/45"></div>

      <!-- Decorative circles -->
      <div class="pointer-events-none absolute -top-24 -left-24 w-96 h-96 rounded-full bg-green-400/10 blur-3xl"></div>
      <div class="pointer-events-none absolute -bottom-24 -right-24 w-96 h-96 rounded-full bg-cream-400/10 blur-3xl"></div>

      <div class="relative px-4 py-28 sm:px-6 lg:px-8 text-center max-w-4xl mx-auto">
        <span class="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-4 py-1.5 text-xs font-bold uppercase tracking-[0.25em] text-cream-300 mb-6">
          <Leaf class="h-3.5 w-3.5" /> {{ t('about.heroEyebrow') }}
        </span>
        <h1 class="text-4xl sm:text-5xl lg:text-6xl font-black tracking-tight text-white leading-tight">
          {{ t('about.heroTitleLine1') }}<br />
          <span class="text-transparent bg-clip-text bg-gradient-to-r from-green-300 to-cream-300">{{ t('about.heroTitleHighlight') }}</span>
        </h1>
        <p class="mt-6 text-base sm:text-lg leading-relaxed text-avocado-100/90 max-w-2xl mx-auto">
          {{ t('about.heroDescription') }}
        </p>
        <p class="mt-3 text-sm font-bold tracking-widest text-green-300/80 uppercase">
          🍃 {{ t('about.heroTagline') }}
        </p>
      </div>
    </div>

    <!-- ===== METRICS ===== -->
    <section class="max-w-[1240px] mx-auto px-4 sm:px-6 lg:px-8 -mt-10 relative z-10">
      <p
        v-if="pageDataError && !pageDataLoading"
        class="mb-4 rounded-2xl border border-red-200 bg-red-50 px-5 py-3 text-center text-sm font-semibold text-red-700 shadow-sm"
      >
        {{ pageDataError }}
        <span class="mt-1 block text-xs font-semibold text-red-600/80">{{ t('about.metricsErrorHint') }}</span>
      </p>
      <div class="grid gap-4 sm:grid-cols-3">
        <article
          v-for="metric in metrics"
          :key="metric.label"
          class="rounded-3xl border border-avocado-100/40 bg-white p-6 text-center shadow-xl shadow-avocado-200/30"
        >
          <div class="mx-auto grid h-12 w-12 place-items-center rounded-2xl bg-avocado-50 text-avocado-700 mb-3">
            <component :is="metric.icon" class="h-6 w-6" />
          </div>
          <p v-if="metric.value === null" class="mx-auto h-10 w-16 animate-pulse rounded bg-slate-100"></p>
          <p v-else class="text-4xl font-black text-avocado-950">{{ metric.value }}</p>
          <p class="mt-1 text-xs font-bold uppercase tracking-wider text-slate-400">{{ metric.label }}</p>
        </article>
      </div>
    </section>

    <!-- ===== SECTION 1: Khởi nguồn ===== -->
    <section class="max-w-[1240px] mx-auto px-4 py-20 sm:px-6 lg:px-8">
      <div class="grid items-center gap-12 lg:grid-cols-2">
        <!-- Image -->
        <div class="relative group">
          <div class="absolute -inset-1 rounded-[2.5rem] bg-gradient-to-br from-green-400/30 to-cream-400/20 blur-xl opacity-60 group-hover:opacity-80 transition duration-500"></div>
          <div class="relative overflow-hidden rounded-[2rem] border border-avocado-100/40 bg-white p-3 shadow-2xl">
            <img
              src="/about/aloo-origin-story.png"
              :alt="t('about.section1Title')"
              loading="lazy"
              decoding="async"
              class="aspect-[4/3] w-full rounded-[1.45rem] object-cover transition duration-500 group-hover:scale-[1.02]"
            />
            <div class="absolute bottom-6 left-6 right-6">
              <div class="rounded-2xl bg-avocado-950/90 backdrop-blur-sm px-4 py-3 text-white text-sm font-bold flex items-center gap-2">
                <span class="h-2 w-2 rounded-full bg-green-400 animate-pulse"></span>
                {{ t('about.section1Caption') }}
              </div>
            </div>
          </div>
        </div>

        <!-- Text -->
        <div class="space-y-6">
          <div>
            <span class="inline-flex items-center gap-2 rounded-full bg-avocado-50 px-4 py-2 text-xs font-black uppercase tracking-[0.18em] text-avocado-700">
              <span class="text-lg">1️⃣</span> {{ t('about.section1Eyebrow') }}
            </span>
          </div>
          <h2 class="text-3xl font-black leading-tight text-avocado-950 lg:text-4xl">
            {{ t('about.section1Title') }}
          </h2>
          <div class="space-y-4 text-slate-600 leading-8">
            <p>{{ t('about.section1P1') }}</p>
            <p>{{ t('about.section1P2') }}</p>
          </div>

          <!-- Mini timeline -->
          <div class="grid grid-cols-2 gap-3 pt-2">
            <div
              v-for="milestone in section1Milestones"
              :key="milestone"
              class="flex items-center gap-2 text-sm font-bold text-avocado-700 bg-avocado-50 rounded-xl px-3 py-2"
            >
              <CheckCircle2 class="h-4 w-4 shrink-0 text-avocado-500" />
              <span>{{ milestone }}</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ===== DIVIDER ===== -->
    <div class="max-w-[1240px] mx-auto px-4 sm:px-6 lg:px-8">
      <div class="h-px bg-gradient-to-r from-transparent via-avocado-200 to-transparent"></div>
    </div>

    <!-- ===== SECTION 2: Vượt thách thức ===== -->
    <section class="max-w-[1240px] mx-auto px-4 py-20 sm:px-6 lg:px-8">
      <div class="grid items-center gap-12 lg:grid-cols-2">
        <!-- Text (left on desktop) -->
        <div class="space-y-6 order-2 lg:order-1">
          <div>
            <span class="inline-flex items-center gap-2 rounded-full bg-amber-50 px-4 py-2 text-xs font-black uppercase tracking-[0.18em] text-amber-700">
              <span class="text-lg">2️⃣</span> {{ t('about.section2Eyebrow') }}
            </span>
          </div>
          <h2 class="text-3xl font-black leading-tight text-avocado-950 lg:text-4xl">
            {{ t('about.section2Title') }}
          </h2>
          <p class="text-sm font-semibold text-amber-600 italic">{{ t('about.section2Subtitle') }}</p>
          <div class="space-y-4 text-slate-600 leading-8">
            <p>{{ t('about.section2P1') }}</p>
            <p>{{ t('about.section2P2') }}</p>
          </div>

          <div class="rounded-2xl border border-green-100 bg-green-50 p-5">
            <p class="text-sm font-black text-avocado-700 mb-2">{{ t('about.qualityTitle') }}</p>
            <ul class="space-y-2">
              <li
                v-for="point in qualityPoints"
                :key="point"
                class="flex items-center gap-2 text-sm font-medium text-avocado-800"
              >
                <CheckCircle2 class="h-4 w-4 shrink-0 text-green-500" />
                {{ point }}
              </li>
            </ul>
          </div>
        </div>

        <!-- Image (right on desktop) -->
        <div class="relative group order-1 lg:order-2">
          <div class="absolute -inset-1 rounded-[2.5rem] bg-gradient-to-br from-amber-400/20 to-green-400/20 blur-xl opacity-60 group-hover:opacity-80 transition duration-500"></div>
          <div class="relative overflow-hidden rounded-[2rem] border border-avocado-100/40 bg-white p-3 shadow-2xl">
            <img
              src="/about/aloo-quality-ingredients.png"
              :alt="t('about.section2Subtitle')"
              loading="lazy"
              decoding="async"
              class="aspect-[4/3] w-full rounded-[1.45rem] object-cover transition duration-500 group-hover:scale-[1.02]"
            />
            <div class="absolute bottom-6 left-6 right-6">
              <div class="rounded-2xl bg-white/90 backdrop-blur-sm px-4 py-3 text-avocado-900 text-sm font-bold flex items-center gap-2 border border-avocado-100">
                <Leaf class="h-4 w-4 text-green-600" />
                {{ t('about.section2ImageCaption') }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- ===== DIVIDER ===== -->
    <div class="max-w-[1240px] mx-auto px-4 sm:px-6 lg:px-8">
      <div class="h-px bg-gradient-to-r from-transparent via-avocado-200 to-transparent"></div>
    </div>

    <!-- ===== SECTION 3: Hệ sinh thái ===== -->
    <section class="max-w-[1240px] mx-auto px-4 py-20 sm:px-6 lg:px-8">
      <div class="grid items-start gap-12 lg:grid-cols-2">
        <!-- Image -->
        <div class="relative group">
          <div class="absolute -inset-1 rounded-[2.5rem] bg-gradient-to-br from-blue-400/20 to-green-400/20 blur-xl opacity-60 group-hover:opacity-80 transition duration-500"></div>
          <div class="relative overflow-hidden rounded-[2rem] border border-avocado-100/40 bg-white p-3 shadow-2xl">
            <img
              src="/about/aloo-ecosystem-vision.png"
              :alt="t('about.section3Title')"
              loading="lazy"
              decoding="async"
              class="aspect-[4/3] w-full rounded-[1.45rem] object-cover transition duration-500 group-hover:scale-[1.02]"
            />
            <div class="absolute bottom-6 left-6 right-6">
              <div class="rounded-2xl bg-avocado-950/90 backdrop-blur-sm px-4 py-3 text-white text-sm font-bold flex items-center justify-between">
                <span class="flex items-center gap-2"><MapPin class="h-4 w-4 text-cream-300" /> {{ t('about.section3ImageCaptionLeft') }}</span>
                <span class="text-cream-300">{{ t('about.section3ImageCaptionRight') }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Text -->
        <div class="space-y-6">
          <div>
            <span class="inline-flex items-center gap-2 rounded-full bg-blue-50 px-4 py-2 text-xs font-black uppercase tracking-[0.18em] text-blue-700">
              <span class="text-lg">3️⃣</span> {{ t('about.section3Eyebrow') }}
            </span>
          </div>
          <h2 class="text-3xl font-black leading-tight text-avocado-950 lg:text-4xl">
            {{ t('about.section3Title') }}
          </h2>
          <div class="space-y-4 text-slate-600 leading-8">
            <p>{{ t('about.section3P1') }}</p>
          </div>

          <!-- Menu items -->
          <div class="space-y-2">
            <p class="text-xs font-black uppercase tracking-wider text-slate-400 mb-3">{{ t('about.section3MenuLabel') }}</p>
            <div class="flex flex-wrap gap-2">
              <span
                v-for="item in menuItems"
                :key="item.name"
                class="inline-flex items-center gap-1.5 rounded-full border px-3 py-1.5 text-xs font-bold"
                :style="{ borderColor: item.color + '40', color: item.color, backgroundColor: item.color + '12' }"
              >
                🥑 {{ item.name }}
                <span class="opacity-60">· {{ item.tag }}</span>
              </span>
            </div>
          </div>

          <!-- Price & audience -->
          <div class="rounded-2xl bg-gradient-to-br from-avocado-50 to-cream-50 border border-avocado-100 p-5">
            <div class="flex items-center gap-3 mb-3">
              <Users class="h-5 w-5 text-avocado-600" />
              <p class="text-sm font-black text-avocado-800">{{ t('about.section3AudienceTitle') }}</p>
            </div>
            <p class="text-sm text-slate-600 leading-7 whitespace-pre-line">
              {{ t('about.section3AudienceText') }}
            </p>
          </div>

          <!-- Vision 2030 -->
          <div class="rounded-2xl bg-avocado-950 text-white p-5">
            <p class="text-xs font-black uppercase tracking-widest text-cream-300 mb-2">{{ t('about.section3VisionLabel') }}</p>
            <p class="text-xl font-black">{{ t('about.section3VisionTitle') }}</p>
            <p class="mt-1 text-sm text-avocado-100/80">{{ t('about.section3VisionDesc') }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- ===== 5 GIÁ TRỊ CỐT LÕI ===== -->
    <section class="bg-avocado-950 text-white py-20 px-4 sm:px-6 lg:px-8 relative overflow-hidden">
      <div class="pointer-events-none absolute -top-32 left-1/2 -translate-x-1/2 w-[600px] h-[600px] rounded-full bg-green-500/10 blur-3xl"></div>
      <div class="relative max-w-[1240px] mx-auto">
        <div class="text-center mb-12">
          <span class="text-xs font-bold uppercase tracking-[0.2em] text-cream-300">{{ t('about.valuesEyebrow') }}</span>
          <h2 class="mt-3 text-3xl sm:text-4xl font-black">{{ t('about.valuesTitle') }}</h2>
          <p class="mt-3 text-sm text-avocado-100/70 max-w-xl mx-auto">
            {{ t('about.valuesDesc') }}
          </p>
        </div>
        <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
          <div
            v-for="val in coreValues"
            :key="val.label"
            class="rounded-3xl border border-white/10 bg-white/5 hover:bg-white/10 transition duration-300 p-6 text-center group cursor-default"
          >
            <div class="mx-auto grid h-12 w-12 place-items-center rounded-2xl bg-avocado-700/60 text-cream-200 mb-4 group-hover:scale-110 transition duration-300">
              <component :is="val.icon" class="h-6 w-6" />
            </div>
            <p class="text-lg font-black text-white">{{ val.label }}</p>
            <p class="mt-2 text-xs text-avocado-200/70 leading-relaxed">{{ val.desc }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- ===== TIMELINE (từ CMS) ===== -->
    <section class="max-w-[1240px] mx-auto px-4 py-20 sm:px-6 lg:px-8">
      <div class="mb-10">
        <span class="text-xs font-bold uppercase tracking-[0.2em] text-avocado-600">{{ t('about.timelineEyebrow') }}</span>
        <h2 class="mt-3 text-3xl font-black text-avocado-950 lg:text-4xl">
          {{ t('about.timelineTitle') }}
        </h2>
      </div>

      <p v-if="timelineError" class="mb-6 rounded-2xl border border-amber-200 bg-amber-50 px-5 py-4 text-sm font-bold text-amber-800">
        {{ timelineError }}
        <span class="mt-1 block text-xs font-semibold text-amber-700/80">{{ t('about.timelineErrorHint') }}</span>
      </p>
      <div v-if="timelineLoading" class="grid gap-5 lg:grid-cols-3">
        <article v-for="i in 3" :key="i" class="rounded-3xl border border-avocado-100/40 bg-white p-6 shadow-sm">
          <div class="h-4 w-20 animate-pulse rounded bg-slate-100"></div>
          <div class="mt-3 h-6 w-4/5 animate-pulse rounded bg-slate-100"></div>
          <div class="mt-3 h-16 animate-pulse rounded bg-slate-100"></div>
        </article>
      </div>
      <div v-else class="grid gap-5" :class="timeline.length ? 'lg:grid-cols-3' : 'lg:grid-cols-4'">
        <article
          v-for="item in timelineItems"
          :key="item.id || item.year || item.title"
          class="rounded-3xl border border-avocado-100/40 bg-white p-6 shadow-sm transition duration-300 hover:-translate-y-1 hover:shadow-lg"
        >
          <p class="text-xs font-black uppercase tracking-[0.18em] text-cream-700">{{ item.year }}</p>
          <h3 class="mt-3 text-lg font-black text-avocado-950">{{ item.title }}</h3>
          <p class="mt-3 text-sm leading-7 text-slate-500">{{ item.description || item.desc }}</p>
        </article>
      </div>
    </section>

    <!-- ===== KẾT LUẬN / CTA ===== -->
    <section class="max-w-[1240px] mx-auto px-4 sm:px-6 lg:px-8">
      <div class="overflow-hidden rounded-[2.5rem] bg-gradient-to-br from-avocado-900 via-avocado-950 to-[#082414] p-8 sm:p-14 text-white relative shadow-2xl">
        <!-- Glow blobs -->
        <div class="pointer-events-none absolute -right-20 -top-20 w-80 h-80 bg-green-400/10 rounded-full blur-3xl"></div>
        <div class="pointer-events-none absolute -left-20 -bottom-20 w-80 h-80 bg-cream-400/10 rounded-full blur-3xl"></div>

        <div class="relative text-center max-w-2xl mx-auto space-y-5">
          <span class="text-xs font-bold uppercase tracking-[0.2em] text-cream-300">{{ t('about.ctaConclusionEyebrow') }}</span>
          <h2 class="text-2xl sm:text-4xl font-black leading-tight">
            {{ t('about.ctaConclusionTitle') }}<br />
            <span class="text-transparent bg-clip-text bg-gradient-to-r from-green-300 to-cream-200">{{ t('about.ctaConclusionHighlight') }}</span>
          </h2>
          <p class="text-sm sm:text-base leading-relaxed text-avocado-100/80 max-w-xl mx-auto">
            {{ t('about.ctaConclusionBody') }}
          </p>
          <p class="text-base font-black text-cream-300">
            🍃 Bạn đã sẵn sàng nạp "{{ t('about.heroTagline') }}" cùng Aloo chưa?
          </p>
          <div class="flex flex-col sm:flex-row gap-3 justify-center pt-2">
            <RouterLink
              to="/locations"
              class="inline-flex items-center justify-center gap-2 rounded-full bg-cream-400 text-avocado-950 font-black px-7 py-3.5 hover:bg-cream-300 transition duration-300 shadow-lg shadow-cream-400/20 text-sm"
            >
              <MapPin class="h-4 w-4" /> {{ t('about.ctaVisitStore') }}
            </RouterLink>
            <RouterLink
              to="/products"
              class="inline-flex items-center justify-center gap-2 rounded-full border border-white/20 bg-white/10 px-7 py-3.5 text-sm font-bold text-white transition duration-300 hover:bg-white/20"
            >
              <Leaf class="h-4 w-4" /> {{ t('about.ctaViewMenu') }} <ArrowRight class="h-4 w-4" />
            </RouterLink>
          </div>
          <p class="pt-2 text-xs text-avocado-200/60">📍 {{ t('about.ctaFootnote') }}</p>
        </div>
      </div>
    </section>

    <!-- ===== QUICK LINKS ===== -->
    <section class="max-w-[1240px] mx-auto px-4 sm:px-6 lg:px-8 mt-8 grid gap-4 sm:grid-cols-2">
      <RouterLink to="/products" class="group rounded-3xl border border-avocado-100/40 bg-white p-6 shadow-sm transition hover:-translate-y-1 hover:shadow-md">
        <p class="text-xs font-black uppercase tracking-[0.18em] text-avocado-600">{{ t('about.quickMenuEyebrow') }}</p>
        <h3 class="mt-3 text-xl font-black text-avocado-950">{{ t('about.quickMenuTitle') }}</h3>
        <p class="mt-2 text-sm leading-6 text-slate-500">{{ t('about.quickMenuDescription') }}</p>
        <span class="mt-5 inline-flex items-center gap-2 text-sm font-black text-avocado-700">
          {{ t('about.quickMenuLink') }} <ArrowRight class="h-4 w-4 transition group-hover:translate-x-1" />
        </span>
      </RouterLink>
      <RouterLink to="/franchise" class="group rounded-3xl border border-avocado-100/40 bg-white p-6 shadow-sm transition hover:-translate-y-1 hover:shadow-md">
        <p class="text-xs font-black uppercase tracking-[0.18em] text-avocado-600">{{ t('about.quickFranchiseEyebrow') }}</p>
        <h3 class="mt-3 text-xl font-black text-avocado-950">{{ t('about.quickFranchiseTitle') }}</h3>
        <p class="mt-2 text-sm leading-6 text-slate-500">{{ t('about.quickFranchiseDescription') }}</p>
        <span class="mt-5 inline-flex items-center gap-2 text-sm font-black text-avocado-700">
          {{ t('about.quickFranchiseLink') }} <ArrowRight class="h-4 w-4 transition group-hover:translate-x-1" />
        </span>
      </RouterLink>
    </section>

  </div>
</template>
