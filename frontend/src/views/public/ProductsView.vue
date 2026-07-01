<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { Search, Award, ChevronLeft, ChevronRight } from 'lucide-vue-next'
import { useAppStore } from '../../stores/appStore'
import { useProductPageStore } from '../../stores/productPageStore'

const { t } = useI18n()
const store = useAppStore()
const productPageStore = useProductPageStore()

const allCategoryLabel = computed(() => t('common.all'))
const activeCategory = ref('')
const searchQuery = ref('')
const currentPage = ref(1)
const productSectionRef = ref(null)
const pageSize = 12

const activeSlideIndex = ref(0)
let autoplayInterval = null

const startAutoplay = () => {
  stopAutoplay()
  if (slides.value.length > 1) {
    autoplayInterval = setInterval(() => {
      nextSlide()
    }, 5000)
  }
}

const stopAutoplay = () => {
  if (autoplayInterval) {
    clearInterval(autoplayInterval)
    autoplayInterval = null
  }
}

const nextSlide = () => {
  if (slides.value.length > 0) {
    activeSlideIndex.value = (activeSlideIndex.value + 1) % slides.value.length
  }
}

const prevSlide = () => {
  if (slides.value.length > 0) {
    activeSlideIndex.value = (activeSlideIndex.value - 1 + slides.value.length) % slides.value.length
  }
}

const setSlide = (index) => {
  activeSlideIndex.value = index
  startAutoplay()
}

// Compute slides (fallback to a default Aloo brand banner if empty)
const defaultSlide = computed(() => ({
  id: 'default-1',
  title: t('products.defaultSlideTitle'),
  subtitle: t('products.defaultSlideSubtitle'),
  description: t('products.defaultSlideDescription'),
  backgroundImage: '/about/aloo-quality-ingredients.png',
  tone: 'light',
}))

const slides = computed(() => {
  const activeBanners = productPageStore.visibleHeroSlides
  if (activeBanners.length > 0) {
    return activeBanners
  }
  if (productPageStore.loading) {
    return []
  }
  return [defaultSlide.value]
})

const showHeroSkeleton = computed(
  () => productPageStore.loading && productPageStore.visibleHeroSlides.length === 0,
)

watch(
  allCategoryLabel,
  (label) => {
    if (!activeCategory.value || activeCategory.value === 'Tất cả' || activeCategory.value === 'All') {
      activeCategory.value = label
    }
  },
  { immediate: true },
)

watch(
  () => slides.value.length,
  (newLength) => {
    activeSlideIndex.value = 0
    if (newLength > 1) {
      startAutoplay()
    } else {
      stopAutoplay()
    }
  },
  { immediate: true }
)

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

const defaultCategoryLabel = computed(() => t('products.defaultCategory'))

const products = computed(() =>
  store.products
    .filter((product) => ['ACTIVE', 'Đang bán'].includes(product.status))
    .sort((a, b) => (a.sortOrder || a.id) - (b.sortOrder || b.id)),
)

const categories = computed(() => {
  const cats = new Set(products.value.map((p) => p.category || defaultCategoryLabel.value))
  return [allCategoryLabel.value, ...Array.from(cats)]
})

const categoryIcon = (category) => {
  if (category === allCategoryLabel.value) return '✨'
  const normalized = String(category || '').toLowerCase()
  return categoryIconMap.find((item) => item.match.some((keyword) => normalized.includes(keyword)))?.icon || '🍦'
}

const categoryCount = (category) =>
  category === allCategoryLabel.value
    ? products.value.length
    : products.value.filter((product) => (product.category || defaultCategoryLabel.value) === category).length

const filteredProducts = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return products.value.filter((product) => {
    const category = product.category || defaultCategoryLabel.value
    const matchesCategory = activeCategory.value === allCategoryLabel.value || category === activeCategory.value
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
  productPageStore.fetchProductPageContent()
})

onBeforeUnmount(() => {
  stopAutoplay()
})
</script>

<template>
  <div class="overflow-hidden bg-brand-cream text-brand-dark">
    <section
      v-if="showHeroSkeleton"
      class="relative w-full h-[calc(100vh-4rem)] overflow-hidden bg-brand-dark"
      :aria-busy="true"
      :aria-label="t('products.heroLoading')"
    >
      <div class="absolute inset-0 animate-pulse bg-slate-800"></div>
      <div class="relative mx-auto flex h-full max-w-[1240px] items-center px-4 sm:px-8 lg:px-12">
        <div class="max-w-2xl space-y-4">
          <div class="h-6 w-32 animate-pulse rounded-full bg-white/20"></div>
          <div class="h-12 w-4/5 animate-pulse rounded bg-white/20"></div>
          <div class="h-20 max-w-xl animate-pulse rounded bg-white/10"></div>
        </div>
      </div>
    </section>
    <section 
      v-else-if="slides.length" 
      class="relative w-full h-[calc(100vh-4rem)] bg-black overflow-hidden group/carousel animate-fade-in"
      @mouseenter="stopAutoplay"
      @mouseleave="startAutoplay"
    >
      <!-- Slides wrapper -->
      <div class="relative w-full h-full">
        <div 
          v-for="(slide, index) in slides" 
          :key="slide.id" 
          class="absolute inset-0 w-full h-full transition-all duration-700 ease-in-out"
          :class="index === activeSlideIndex ? 'opacity-100 translate-x-0 pointer-events-auto z-10' : 'opacity-0 translate-x-8 pointer-events-none z-0'"
        >
          <!-- Background Image -->
          <img
            :src="slide.backgroundImage"
            :alt="slide.title || t('products.defaultSlideTitle')"
            class="absolute inset-0 h-full w-full object-cover object-center"
            loading="lazy"
            decoding="async"
          />
          <div class="absolute inset-0 bg-gradient-to-r from-black/55 via-black/30 to-transparent"></div>
          <div class="relative z-10 mx-auto flex h-full max-w-[1240px] items-center px-4 sm:px-8 lg:px-12">
            <div class="max-w-2xl text-white">
              <span
                v-if="slide.subtitle"
                class="inline-flex rounded-full border border-white/15 bg-white/10 px-4 py-1.5 text-xs font-black uppercase tracking-[0.2em] text-brand-lime"
              >
                {{ slide.subtitle }}
              </span>
              <h1 class="mt-4 text-3xl font-black leading-tight sm:text-4xl lg:text-5xl">
                {{ slide.title }}
              </h1>
              <p v-if="slide.description" class="mt-4 max-w-xl text-sm leading-7 text-white/80 sm:text-base">
                {{ slide.description }}
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Navigation Arrows -->
      <button
        v-if="slides.length > 1"
        type="button"
        class="absolute left-4 top-1/2 z-20 flex h-11 w-11 -translate-y-1/2 items-center justify-center rounded-full border border-white/10 bg-white/10 text-white opacity-0 backdrop-blur-md transition-all duration-300 hover:scale-105 hover:bg-brand-lime hover:text-brand-dark group-hover/carousel:opacity-100"
        :aria-label="t('products.carouselPrev')"
        @click="prevSlide"
      >
        <ChevronLeft class="h-6 w-6" />
      </button>
      <button
        v-if="slides.length > 1"
        type="button"
        class="absolute right-4 top-1/2 z-20 flex h-11 w-11 -translate-y-1/2 items-center justify-center rounded-full border border-white/10 bg-white/10 text-white opacity-0 backdrop-blur-md transition-all duration-300 hover:scale-105 hover:bg-brand-lime hover:text-brand-dark group-hover/carousel:opacity-100"
        :aria-label="t('products.carouselNext')"
        @click="nextSlide"
      >
        <ChevronRight class="h-6 w-6" />
      </button>

      <!-- Dot Indicators -->
      <div v-if="slides.length > 1" class="absolute bottom-6 left-1/2 -translate-x-1/2 z-20 flex gap-2">
        <button
          v-for="(_, index) in slides"
          :key="index"
          type="button"
          class="h-2 rounded-full transition-all duration-300"
          :class="index === activeSlideIndex ? 'w-8 bg-brand-lime shadow-md shadow-brand-lime/20' : 'w-2 bg-white/40 hover:bg-white/70'"
          :aria-label="t('products.carouselDot', { index: index + 1 })"
          :aria-current="index === activeSlideIndex ? 'true' : undefined"
          @click="setSlide(index)"
        ></button>
      </div>
    </section>

    <!-- Product List / Order Section -->
    <section id="product-list" ref="productSectionRef" class="relative scroll-mt-24 bg-cream-50 px-4 pt-10 pb-16 sm:pt-12 lg:pt-14 sm:px-6 lg:px-8">
      <div class="relative z-10 mx-auto max-w-[1240px]">
        <p
          v-if="productPageStore.error"
          class="mb-6 rounded-2xl border border-amber-200 bg-amber-50 px-5 py-4 text-center text-sm font-bold text-amber-800 shadow-sm"
        >
          {{ productPageStore.error }}
          <span class="mt-1 block text-xs font-semibold text-amber-700/80">{{ t('products.pageContentErrorHint') }}</span>
        </p>

        <p v-if="store.errors.products" class="mx-auto max-w-lg rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-center text-sm font-semibold text-red-700 shadow-sm">
          {{ store.errors.products }}
        </p>

        <div v-else-if="store.loading.products" class="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
          <div v-for="i in 8" :key="i" class="animate-pulse space-y-4 rounded-3xl border border-slate-100 bg-slate-50 p-4">
            <div class="aspect-square bg-slate-200 rounded-2xl"></div>
            <div class="h-4 bg-slate-200 rounded w-1/3"></div>
            <div class="h-6 bg-slate-200 rounded w-3/4"></div>
            <div class="h-4 bg-slate-200 rounded w-1/2"></div>
          </div>
        </div>

        <div v-else-if="products.length" class="filter-panel grid gap-8 lg:grid-cols-[260px_minmax(0,1fr)] lg:items-start">
          <aside class="lg:sticky lg:top-28">
            <div class="rounded-[24px] bg-white/90 p-4 shadow-[0_16px_42px_rgba(13,47,27,0.06)] ring-1 ring-cream-200">
              <p class="px-2 text-xs font-black uppercase tracking-[0.18em] text-brand-sand">{{ t('products.categories') }}</p>
              <div class="mt-4 flex gap-2 overflow-x-auto pb-1 lg:block lg:space-y-2 lg:overflow-visible lg:pb-0">
                <button
                  v-for="cat in categories"
                  :key="cat"
                  type="button"
                  class="flex min-w-max items-center gap-3 rounded-2xl px-4 py-3 text-left text-sm font-black transition duration-200 lg:w-full lg:min-w-0"
                  :class="
                    activeCategory === cat
                      ? 'border-transparent bg-brand-forest text-white shadow-[0_12px_28px_rgba(0,122,53,0.18)]'
                      : 'border border-cream-200 bg-transparent text-brand-forest hover:bg-brand-lime/10'
                  "
                  :aria-pressed="activeCategory === cat"
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
                <p class="text-xs font-black uppercase tracking-[0.22em] text-brand-sand">{{ t('products.listEyebrow') }}</p>
                <h3 class="mt-1.5 font-display text-2xl font-black leading-tight tracking-tight text-brand-dark sm:text-3xl">
                  {{ activeCategory === allCategoryLabel ? t('products.allProducts') : activeCategory }}
                </h3>
                <p class="mt-1 text-sm font-semibold text-brand-muted">{{ t('products.servingCount', { count: filteredProducts.length }) }}</p>
              </div>
              <label class="relative block w-full sm:max-w-[390px]">
                <Search class="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-brand-forest/65 transition" />
                <input
                  :value="searchQuery"
                  type="search"
                  class="h-12 w-full rounded-full border border-cream-200 bg-white py-0 pl-11 pr-5 text-sm font-semibold text-brand-dark outline-none transition duration-300 placeholder:text-brand-muted/70 focus:border-brand-forest focus:shadow-[0_12px_28px_rgba(0,122,53,0.1)] focus:ring-4 focus:ring-brand-lime/15"
                  :placeholder="t('products.searchPlaceholder')"
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
                  <div v-else class="relative grid h-full place-items-center overflow-hidden bg-[radial-gradient(circle_at_30%_20%,rgba(205,236,166,0.62),transparent_36%),linear-gradient(135deg,#FFF7E6,#F5FBEA)] px-5 text-center">
                    <div class="absolute -right-8 -top-8 h-32 w-32 rounded-full border border-brand-forest/8"></div>
                    <div class="absolute -bottom-10 -left-8 h-36 w-36 rounded-full bg-brand-lime/20 blur-2xl"></div>
                    <span class="absolute right-5 top-5 rounded-full bg-white/70 px-3 py-1 text-[10px] font-black uppercase tracking-[0.16em] text-brand-forest shadow-sm">
                      ALOO
                    </span>
                    <div class="relative z-10">
                      <div class="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-white/80 text-2xl shadow-sm shadow-brand-forest/8 ring-1 ring-brand-forest/5">
                        {{ categoryIcon(product.category || defaultCategoryLabel) }}
                      </div>
                      <p class="mt-3 text-[11px] font-black uppercase tracking-[0.18em] text-brand-forest/70">{{ t('products.updatingImage') }}</p>
                    </div>
                  </div>
                </div>

                <div class="flex flex-col px-2 pb-2 pt-3.5">
                  <div>
                    <span class="inline-flex rounded-full bg-brand-lime/15 px-3 py-1 text-[10px] font-black uppercase tracking-wide text-brand-forest">
                      {{ product.category || t('products.productLabel') }}
                    </span>
                    <h4 class="mt-3 text-xl font-black leading-tight text-brand-dark transition group-hover:text-brand-forest">{{ product.name }}</h4>
                  </div>

                  <div class="pt-4">
                    <RouterLink :to="product.slug ? `/products/${product.slug}` : '/products'" class="inline-flex w-full items-center justify-center rounded-full bg-brand-forest px-4 py-2.5 text-xs font-black uppercase tracking-wider text-white shadow-lg shadow-brand-forest/12 transition hover:bg-brand-dark">
                      {{ t('products.explore') }}
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
                {{ t('products.prev') }}
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
                {{ t('products.next') }}
              </button>
            </div>

            <div v-if="!filteredProducts.length" class="rounded-2xl border border-slate-200 bg-white px-5 py-16 text-center text-sm font-bold text-slate-400 shadow-sm">
              {{ t('products.emptyNoMatch') }}
            </div>
          </div>
        </div>

        <p v-else class="mx-auto max-w-lg rounded-2xl border border-slate-200 bg-white px-5 py-16 text-center text-sm font-bold text-slate-400 shadow-sm">
          {{ t('products.emptyNoData') }}
        </p>
      </div>
    </section>

    <!-- Premium call-to-action nhượng quyền -->
    <section class="relative isolate flex min-h-[60vh] items-center bg-brand-dark px-4 py-20 text-white sm:px-6 lg:px-8 overflow-hidden">
      <!-- Glowing mesh background pattern -->
      <div class="absolute inset-0 -z-10 bg-[linear-gradient(115deg,rgba(229,184,93,0.2),transparent_35%),linear-gradient(180deg,#0D2F1B,#082414)] border-t border-white/5"></div>
      <div class="absolute -right-20 -bottom-20 w-80 h-80 bg-brand-lime/5 rounded-full blur-3xl pointer-events-none"></div>

      <div class="mx-auto max-w-4xl text-center relative z-10 space-y-6">
        <div class="inline-flex items-center gap-2 text-xs font-black uppercase tracking-[0.25em] text-brand-lime bg-white/5 border border-white/10 px-3.5 py-1.5 rounded-full">
          <Award class="h-4 w-4" />
          {{ t('products.ctaEyebrow') }}
        </div>
        <h2 class="mx-auto max-w-3xl font-display text-3xl font-black leading-tight tracking-tight text-white sm:text-5xl">
          {{ t('products.ctaTitle') }}
        </h2>
        <p class="mx-auto max-w-2xl text-base leading-relaxed text-white/80">
          {{ t('products.ctaDescription') }}
        </p>
        <div class="pt-4">
          <RouterLink to="/consultation" class="inline-flex transform rounded-full bg-brand-lime px-8 py-4 text-xs font-black uppercase tracking-wider text-brand-dark shadow-xl shadow-brand-lime/20 transition duration-300 hover:-translate-y-0.5 hover:bg-brand-lime/90">
            {{ t('products.ctaButton') }}
          </RouterLink>
        </div>
      </div>
    </section>
  </div>
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
