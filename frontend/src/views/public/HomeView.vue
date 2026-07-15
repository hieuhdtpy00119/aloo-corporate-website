<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ChevronLeft, ChevronRight, MapPin, Award, ArrowRight, ShoppingBag } from 'lucide-vue-next'
import { useAppStore } from '../../stores/appStore'
import { homeSectionService, resolveBackendAssetUrl } from '../../services/cmsService'

const { t } = useI18n()
const store = useAppStore()
const productRail = ref(null)
const featuredRail = ref(null)

const homeSections = ref([])
const homeSectionsLoading = ref(false)
const homeSectionsError = ref('')

const activeProducts = computed(() =>
  store.products
    .filter((product) => ['ACTIVE', 'Đang bán'].includes(product.status))
    .sort((a, b) => (a.sortOrder || a.id || 0) - (b.sortOrder || b.id || 0)),
)

const popularProducts = computed(() => activeProducts.value.slice(0, 8))

const isExternalLink = (url) => /^https?:\/\//i.test(String(url || '').trim())

const normalizeSectionType = (type) => {
  const value = String(type || 'FEATURED_CARD').toUpperCase()
  return ['FEATURED_CARD', 'CTA_CARD', 'PRODUCT_CARD', 'LOCATION_CARD'].includes(value) ? value : 'FEATURED_CARD'
}

const mapFeaturedSection = (section) => {
  const buttonLink = String(section.buttonLink || '').trim()
  const buttonText = String(section.buttonText || '').trim()
  const hasLink = Boolean(buttonLink)
  const cardType = normalizeSectionType(section.type)

  return {
    id: section.id,
    type: cardType,
    title: section.title,
    subtitle: section.subtitle || '',
    description: section.description || section.subtitle || '',
    cta: buttonText || (hasLink ? t('home.featuredDefaultCta') : ''),
    href: buttonLink,
    hasLink,
    isExternal: hasLink && isExternalLink(buttonLink),
    image: resolveBackendAssetUrl(section.imageUrl || ''),
    badge: section.badge || section.subtitle || t('home.featuredDefaultBadge'),
  }
}

const featuredCards = computed(() =>
  homeSections.value
    .filter((section) => section.status === 'ACTIVE')
    .sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0))
    .map(mapFeaturedSection),
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

const scrollFeatured = (direction) => {
  featuredRail.value?.scrollBy({
    left: direction * 420,
    behavior: 'smooth',
  })
}

const productMeta = (product) => product.category || t('home.productMetaFallback')

const fetchHomeSections = async () => {
  homeSectionsLoading.value = true
  homeSectionsError.value = ''
  try {
    const { data } = await homeSectionService.list(true)
    homeSections.value = Array.isArray(data) ? data : []
  } catch (error) {
    homeSectionsError.value = error.response?.data?.message || t('home.featuredLoadError')
  } finally {
    homeSectionsLoading.value = false
  }
}

onMounted(() => {
  Promise.allSettled([store.fetchProducts(), store.fetchLocations(), fetchHomeSections()])
})
</script>

<template>
  <section class="bg-brand-cream">
    <div class="relative h-[calc(64vh+10rem)] max-h-[800px] min-h-[560px] w-full overflow-hidden bg-brand-dark sm:min-h-[600px]">
      <video
        class="absolute inset-0 h-full w-full object-cover object-center [transform:translateZ(0)]"
        autoplay
        muted
        loop
        playsinline
        preload="auto"
        poster="/about/aloo-origin-story.png"
        :aria-label="t('home.heroVideoLabel')"
      >
        <source src="/videos/aloo-home-hero.mp4" type="video/mp4" />
      </video>
    </div>

    <!-- Featured Section -->
    <section class="mx-auto max-w-[1240px] px-4 py-10 sm:px-6 lg:px-8">
      <div class="mb-10 flex flex-col justify-between gap-4 border-b border-brand-forest/5 pb-4 text-center sm:flex-row sm:items-end sm:text-left">
        <div>
          <span class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">{{ t('home.featuredEyebrow') }}</span>
          <h2 class="mt-2 text-3xl font-black text-brand-dark lg:text-4xl">{{ t('home.featuredTitle') }}</h2>
        </div>
        <div class="flex items-center justify-center gap-3 sm:justify-end">
          <p class="text-sm font-medium text-brand-muted">{{ t('home.featuredSubtitle') }}</p>
          <div v-if="featuredCards.length > 1" class="hidden gap-2.5 sm:flex">
            <button type="button" class="grid h-10 w-10 place-items-center rounded-full border border-brand-forest/10 bg-white text-brand-dark shadow-sm transition hover:border-brand-forest/20 hover:bg-brand-cream active:scale-95" :aria-label="t('home.featuredScrollLeft')" @click="scrollFeatured(-1)">
              <ChevronLeft class="h-5 w-5" />
            </button>
            <button type="button" class="grid h-10 w-10 place-items-center rounded-full border border-brand-forest/10 bg-white text-brand-dark shadow-sm transition hover:border-brand-forest/20 hover:bg-brand-cream active:scale-95" :aria-label="t('home.featuredScrollRight')" @click="scrollFeatured(1)">
              <ChevronRight class="h-5 w-5" />
            </button>
          </div>
        </div>
      </div>

      <p v-if="homeSectionsError" class="rounded-2xl border border-amber-200 bg-amber-50 px-5 py-4 text-center text-sm font-bold text-amber-800 shadow-sm">
        {{ homeSectionsError }}
        <span class="mt-1 block text-xs font-semibold text-amber-700/80">{{ t('home.featuredErrorHint') }}</span>
      </p>
      <div v-else-if="homeSectionsLoading" class="featured-scrollbar flex snap-x gap-5 overflow-x-auto pb-6">
        <div v-for="i in 3" :key="i" class="min-w-[82vw] snap-start overflow-hidden rounded-3xl border border-brand-forest/5 bg-white shadow-sm sm:min-w-[360px] lg:min-w-[400px]">
          <div class="aspect-[5/3] animate-pulse bg-slate-100"></div>
          <div class="space-y-3 p-5">
            <div class="h-5 w-2/3 animate-pulse rounded bg-slate-100"></div>
            <div class="h-4 w-full animate-pulse rounded bg-slate-100"></div>
          </div>
        </div>
      </div>
      <p v-else-if="!featuredCards.length" class="rounded-3xl border border-slate-200 bg-white px-6 py-12 text-center text-sm font-bold text-slate-400">
        {{ t('home.featuredEmpty') }}
      </p>
      <div v-else ref="featuredRail" class="featured-scrollbar flex snap-x gap-5 overflow-x-auto pb-6">
        <component
          :is="card.hasLink ? (card.isExternal ? 'a' : RouterLink) : 'article'"
          v-for="card in featuredCards"
          :key="card.id ?? card.title"
          v-bind="
            card.hasLink
              ? card.isExternal
                ? { href: card.href, target: '_blank', rel: 'noreferrer' }
                : { to: card.href }
              : {}
          "
          :class="[
            'group flex min-w-[82vw] shrink-0 grow basis-0 snap-start flex-col overflow-hidden rounded-3xl border bg-white shadow-sm transition sm:min-w-[360px] lg:min-w-[400px]',
            card.type === 'LOCATION_CARD' ? 'border-brand-forest/15' : 'border-brand-forest/5',
            card.hasLink ? 'hover:-translate-y-1 hover:shadow-xl' : '',
          ]"
        >
          <div class="relative aspect-[5/3] overflow-hidden">
            <div
              v-if="card.type === 'CTA_CARD'"
              class="pointer-events-none absolute inset-0 z-[1] bg-gradient-to-t from-brand-dark/75 via-brand-dark/20 to-transparent"
            />
            <div
              :class="[
                'absolute top-4 left-4 z-10 inline-flex items-center gap-1.5 rounded-full px-3.5 py-1.5 text-xs font-bold backdrop-blur-md',
                card.type === 'LOCATION_CARD' ? 'bg-brand-forest/90 text-brand-lime' : 'bg-brand-dark/80 text-brand-lime',
              ]"
            >
              <MapPin v-if="card.type === 'LOCATION_CARD'" class="h-3.5 w-3.5" />
              <ShoppingBag v-else-if="card.type === 'PRODUCT_CARD'" class="h-3.5 w-3.5" />
              {{ card.badge }}
            </div>
            <img v-if="card.image" :src="card.image" :alt="card.title" class="h-full w-full object-cover transition duration-500 group-hover:scale-105" />
            <div v-else class="grid h-full place-items-center bg-brand-lime/10 text-2xl font-black text-brand-forest">ALOO</div>
          </div>
          <div
            :class="[
              'flex flex-1 flex-col justify-between p-5',
              card.type === 'CTA_CARD' ? 'bg-gradient-to-b from-white to-brand-cream/40' : '',
            ]"
          >
            <div>
              <p
                v-if="card.type === 'PRODUCT_CARD' && card.subtitle"
                class="text-[11px] font-black uppercase tracking-[0.18em] text-brand-forest"
              >
                {{ card.subtitle }}
              </p>
              <h3 class="text-xl font-bold text-brand-dark transition group-hover:text-brand-forest">{{ card.title }}</h3>
              <p class="mt-2.5 line-clamp-2 min-h-11 text-sm font-medium leading-relaxed text-brand-muted">{{ card.description }}</p>
            </div>
            <div v-if="card.cta" class="mt-5 flex items-center justify-between border-t border-slate-50 pt-4">
              <span
                v-if="card.type === 'CTA_CARD'"
                class="inline-flex items-center gap-1.5 rounded-full bg-brand-lime px-4 py-2 text-xs font-black uppercase tracking-wider text-brand-dark shadow-sm transition group-hover:bg-brand-lime/90"
              >
                {{ card.cta }} <ArrowRight class="h-4 w-4 transition transform group-hover:translate-x-1" />
              </span>
              <span
                v-else-if="card.type === 'PRODUCT_CARD'"
                class="inline-flex items-center gap-1.5 rounded-full bg-brand-lime/15 px-3.5 py-1.5 text-xs font-black uppercase tracking-wider text-brand-forest transition group-hover:bg-brand-lime/25"
              >
                {{ card.cta }} <ArrowRight class="h-4 w-4 transition transform group-hover:translate-x-1" />
              </span>
              <span
                v-else
                class="inline-flex items-center gap-1.5 text-xs font-black uppercase tracking-wider text-brand-forest group-hover:text-brand-lime transition"
              >
                {{ card.cta }} <ArrowRight class="h-4 w-4 transition transform group-hover:translate-x-1" />
              </span>
            </div>
          </div>
        </component>
      </div>
    </section>

    <!-- Trending Products Slider Section -->
    <section class="mx-auto max-w-[1240px] px-4 py-12 sm:px-6 lg:px-8">
      <div class="mb-12 flex items-end justify-between gap-4 border-b border-brand-forest/5 pb-4">
        <div>
          <span class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">{{ t('home.popularEyebrow') }}</span>
          <h2 class="mt-2 text-3xl font-black text-brand-dark lg:text-4xl">{{ t('home.popularTitle') }}</h2>
        </div>
        <div class="hidden gap-2.5 sm:flex">
          <button type="button" class="grid h-10 w-10 place-items-center rounded-full border border-brand-forest/10 bg-white text-brand-dark hover:bg-brand-cream hover:border-brand-forest/20 shadow-sm transition cursor-pointer active:scale-95" :aria-label="t('home.scrollLeft')" @click="scrollProducts(-1)">
            <ChevronLeft class="h-5 w-5" />
          </button>
          <button type="button" class="grid h-10 w-10 place-items-center rounded-full border border-brand-forest/10 bg-white text-brand-dark hover:bg-brand-cream hover:border-brand-forest/20 shadow-sm transition cursor-pointer active:scale-95" :aria-label="t('home.scrollRight')" @click="scrollProducts(1)">
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
            <img v-if="product.imageUrl" :src="product.imageUrl" :alt="product.name" class="h-full w-full object-cover transition-all duration-300 group-hover:scale-105" />
            <div v-else class="grid h-full place-items-center text-xl font-black text-brand-forest bg-brand-lime/10">ALOO</div>
          </div>
          <div class="mt-4 space-y-1.5">
            <h3 class="text-base font-bold text-brand-dark transition group-hover:text-brand-forest">{{ product.name }}</h3>
            <p class="text-xs leading-relaxed text-brand-muted font-medium h-8 line-clamp-2">{{ product.description }}</p>
          </div>
          <div class="mt-4 flex items-center justify-between border-t border-slate-50 pt-3">
            <p class="text-sm font-black text-brand-forest font-display">{{ productMeta(product) }}</p>
            <RouterLink :to="product.slug ? `/products/${product.slug}` : '/products'" class="rounded-full bg-brand-lime/15 hover:bg-brand-lime/30 px-3.5 py-1.5 text-xs font-black text-brand-forest transition">
              {{ t('home.viewDetail') }}
            </RouterLink>
          </div>
        </article>
      </div>
      <p v-else class="rounded-3xl border border-slate-200 bg-white px-6 py-12 text-center text-sm font-bold text-slate-400">
        {{ t('home.productsEmpty') }}
      </p>
    </section>

    <!-- Brand Story Section (Asymmetrical Layout with warm beige background details) -->
    <section class="bg-brand-cream/50 py-20">
      <div class="mx-auto max-w-[1240px] px-4 sm:px-6 lg:px-8">
        <div class="grid items-center gap-12 lg:grid-cols-2">
          <div class="space-y-6 max-w-lg">
            <div class="flex items-center gap-2">
              <Award class="h-5 w-5 text-brand-brown" />
              <span class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">{{ t('home.brandStoryEyebrow') }}</span>
            </div>
            <h2 class="text-3xl font-black leading-tight text-brand-dark lg:text-4xl">
              {{ t('home.brandStoryTitle') }}
            </h2>
            <p class="text-base leading-relaxed text-brand-muted font-medium">
              {{ t('home.brandStoryP1') }}
            </p>
            <p class="text-sm leading-relaxed text-brand-muted">
              {{ t('home.brandStoryP2') }}
            </p>
            <div class="pt-2">
              <RouterLink to="/about" class="inline-flex items-center gap-2 rounded-full bg-brand-lime text-brand-dark px-6 py-3.5 text-xs font-black uppercase tracking-wider hover:bg-brand-lime/90 transition shadow-md">
                {{ t('home.brandStoryCta') }} <ArrowRight class="h-4 w-4" />
              </RouterLink>
            </div>
          </div>
          <div class="relative">
            <div class="absolute -top-4 -left-4 w-24 h-24 bg-brand-lime/10 rounded-full blur-2xl z-0"></div>
            <div class="absolute -bottom-4 -right-4 w-32 h-32 bg-brand-sand/15 rounded-full blur-2xl z-0"></div>
            <div class="overflow-hidden rounded-3xl bg-white p-3 shadow-xl border border-brand-forest/5 relative z-10">
              <img
                src="/about/aloo-quality-ingredients.png"
                :alt="t('home.brandStoryImageAlt')"
                class="aspect-[4/3] w-full object-cover rounded-2xl"
              />
            </div>
          </div>
        </div>
      </div>
    </section>


    <!-- Location Finder Section -->
    <section class="mx-auto max-w-[1240px] px-4 py-20 sm:px-6 lg:px-8">
      <div class="mb-12 flex flex-col justify-between gap-4 sm:flex-row sm:items-end text-center sm:text-left border-b border-brand-forest/5 pb-4">
        <div>
          <span class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">{{ t('home.locationsEyebrow') }}</span>
          <h2 class="mt-2 text-3xl font-black text-brand-dark lg:text-4xl">{{ t('home.locationsTitle') }}</h2>
        </div>
        <RouterLink to="/locations" class="inline-flex items-center justify-center gap-1.5 text-sm font-bold text-brand-forest hover:text-brand-dark transition">
          {{ t('home.locationsViewAll') }} <ArrowRight class="h-4 w-4" />
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
            <p class="mt-2 text-xs font-bold text-brand-forest bg-brand-lime/10 inline-block px-3 py-1 rounded-full">{{ t('home.locationHours') }} {{ location.openingHours || t('home.locationHoursUpdating') }}</p>
          </div>
          <div class="mt-6 border-t border-slate-100 pt-4">
            <RouterLink
              v-if="!location.mapUrl"
              to="/locations"
              class="inline-flex w-full justify-center rounded-full border border-brand-forest/10 hover:border-brand-forest hover:bg-brand-lime/10 px-4 py-2.5 text-xs font-black text-brand-forest transition"
            >
              {{ t('home.locationDirections') }}
            </RouterLink>
            <a
              v-else
              :href="location.mapUrl"
              target="_blank"
              rel="noreferrer"
              class="inline-flex w-full justify-center rounded-full border border-brand-forest/10 hover:border-brand-forest hover:bg-brand-lime/10 px-4 py-2.5 text-xs font-black text-brand-forest transition"
            >
              {{ t('home.locationDirections') }}
            </a>
          </div>
        </article>
      </div>
      <p v-else class="rounded-3xl border border-slate-200 bg-white px-6 py-12 text-center text-sm font-bold text-slate-400">
        {{ t('home.locationsEmpty') }}
      </p>
    </section>

    <!-- Premium Call-to-action Franchise Section -->
    <section class="mx-auto max-w-[1240px] px-4 py-12 sm:px-6 lg:px-8">
      <div class="overflow-hidden rounded-3xl bg-gradient-to-br from-brand-dark via-brand-dark/95 to-brand-forest px-8 py-16 text-white sm:px-12 lg:px-16 shadow-2xl relative border border-white/5">
        <!-- Floating decorative glowing circle -->
        <div class="absolute -right-10 -top-10 w-44 h-44 bg-brand-lime/10 rounded-full blur-2xl pointer-events-none"></div>

        <div class="max-w-2xl relative z-10">
          <span class="text-xs font-black uppercase tracking-[0.25em] text-brand-lime bg-white/5 border border-white/10 px-3 py-1.5 rounded-full">{{ t('home.bottomCtaEyebrow') }}</span>
          <h2 class="mt-6 text-3xl font-black leading-tight text-white lg:text-4xl">{{ t('home.bottomCtaTitle') }}</h2>
          <p class="mt-3 text-base leading-relaxed text-white/80">
            {{ t('home.bottomCtaDescription') }}
          </p>
          <div class="mt-8 flex flex-wrap gap-4">
            <RouterLink to="/consultation" class="rounded-full bg-brand-lime text-brand-dark font-black px-6 py-4 hover:bg-brand-lime/90 transition duration-300 shadow-lg shadow-brand-lime/25 uppercase tracking-wider text-xs">
              {{ t('home.bottomCtaConsult') }}
            </RouterLink>
            <RouterLink to="/franchise" class="rounded-full border border-white/20 bg-white/5 text-white font-bold px-6 py-4 hover:bg-white/10 transition duration-300 text-xs uppercase tracking-wider">
              {{ t('home.bottomCtaSurvey') }}
            </RouterLink>
          </div>
        </div>
      </div>
    </section>
  </section>
</template>

<style scoped>
.featured-scrollbar,
.product-scrollbar {
  scrollbar-color: #8CC63F #FFF7E6;
  scrollbar-width: thin;
}

.featured-scrollbar::-webkit-scrollbar,
.product-scrollbar::-webkit-scrollbar {
  height: 8px;
}

.featured-scrollbar::-webkit-scrollbar-track,
.product-scrollbar::-webkit-scrollbar-track {
  border-radius: 999px;
  background: #FFF7E6;
}

.featured-scrollbar::-webkit-scrollbar-thumb,
.product-scrollbar::-webkit-scrollbar-thumb {
  border-radius: 999px;
  background: #CDECA6;
}

.featured-scrollbar::-webkit-scrollbar-thumb:hover,
.product-scrollbar::-webkit-scrollbar-thumb:hover {
  background: #8CC63F;
}
</style>

