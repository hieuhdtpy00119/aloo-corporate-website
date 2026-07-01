<script setup>
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import {
  ArrowRight,
  BadgeCheck,
  BarChart3,
  ChevronDown,
  Handshake,
  MapPin,
  Megaphone,
  ShieldCheck,
  Sparkles,
  Store,
  Timer,
  Wallet,
  Bike,
  Leaf,
  CheckCircle2,
  Users,
  Phone,
  Star,
} from 'lucide-vue-next'
import ConsultationForm from '../../components/public/ConsultationForm.vue'
import { useFranchiseContentStore } from '../../stores/franchiseContentStore'
import { useAppStore } from '../../stores/appStore'
import { trackEvent } from '../../services/analyticsService'
import { useI18n } from 'vue-i18n'

const { t, tm } = useI18n()
const franchiseStore = useFranchiseContentStore()
const appStore = useAppStore()
const openFaq = ref(null)

const iconMap = {
  product: Sparkles,
  operation: Timer,
  cost: Wallet,
  support: Handshake,
  marketing: Megaphone,
  brand: BadgeCheck,
  default: ShieldCheck,
}

const modelIconMap = {
  AlooBike: Bike,
  Kiosk: Store,
  Standard: Store,
  Flagship: Star,
}

const hero = computed(() => franchiseStore.visibleHero[0] || null)
const founder = computed(() => franchiseStore.visibleFounderStory[0] || null)
const cta = computed(() => franchiseStore.visibleCta[0] || null)

const featuredStores = computed(() =>
  [...appStore.locations]
    .filter((store) => ['ACTIVE', 'Đang hoạt động'].includes(store.status))
    .sort((a, b) => {
      if (a.featured !== b.featured) return a.featured ? -1 : 1
      return (a.displayOrder || a.id || 0) - (b.displayOrder || b.id || 0)
    })
    .slice(0, 4),
)

const scrollToSection = (sectionId) => {
  if (sectionId) {
    window.history.replaceState(null, '', `#${sectionId}`)
  }
  document.getElementById(sectionId)?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

const faqToggle = (id) => {
  openFaq.value = openFaq.value === id ? null : id
}

const heroStats = computed(() => {
  const items = tm('franchise.heroStats')
  return Array.isArray(items) ? items : []
})

const resolveFranchiseLinkAction = (link, fallbackTarget = 'investment') => {
  const text = String(link || '').trim()
  if (!text) return { type: 'scroll', target: fallbackTarget }
  if (text.startsWith('#')) return { type: 'scroll', target: text.slice(1) || fallbackTarget }
  if (/^https?:\/\//i.test(text)) return { type: 'external', href: text }
  if (text.startsWith('/')) return { type: 'route', to: text }
  return { type: 'scroll', target: fallbackTarget }
}

const secondaryHeroAction = computed(() =>
  resolveFranchiseLinkAction(hero.value?.secondaryButtonLink, 'investment'),
)

const revenuePoints = computed(() => {
  const items = tm('franchise.revenuePoints')
  return Array.isArray(items) ? items : []
})

const ctaPoints = computed(() => {
  const items = tm('franchise.ctaPoints')
  return Array.isArray(items) ? items : []
})

const partnerProfiles = computed(() => {
  const items = tm('franchise.partnerProfiles')
  const icons = [Users, Store, Handshake, Bike]
  if (!Array.isArray(items)) return []
  return items.map((item, index) => ({ ...item, icon: icons[index] || Store }))
})

const storeLink = (store) => `/locations/${store.slug || store.id}`

onMounted(async () => {
  await Promise.allSettled([franchiseStore.fetchContent(), appStore.fetchLocations()])
  const hash = window.location.hash.replace('#', '')
  if (hash) {
    requestAnimationFrame(() => scrollToSection(hash))
  }
})
</script>

<template>
  <div class="bg-brand-cream text-avocado-950">

    <!-- ===== HERO ===== -->
    <section class="relative min-h-[calc(100vh-80px)] overflow-hidden bg-black text-white">
      <img
        :src="hero?.image || '/about/aloo-franchise-banner.png'"
        :alt="hero?.title || t('franchise.heroAlt')"
        class="absolute inset-0 h-full w-full object-cover"
        loading="eager"
      />
      <div class="absolute inset-0 bg-gradient-to-r from-black/55 via-black/30 to-transparent"></div>
      <!-- Decorative glow -->
      <div class="pointer-events-none absolute top-1/3 left-1/2 w-[500px] h-[500px] rounded-full bg-green-400/8 blur-3xl"></div>

      <div class="relative mx-auto grid min-h-[calc(100vh-80px)] max-w-[1240px] content-center px-4 py-20 sm:px-6 lg:px-8">
        <div class="max-w-3xl">
          <span class="inline-flex items-center gap-2 rounded-full border border-white/15 bg-white/10 px-4 py-2 text-xs font-black uppercase tracking-[0.22em] text-green-300">
            <Leaf class="h-3.5 w-3.5" />
            {{ hero?.subtitle || t('franchise.heroDefaultSubtitle') }}
          </span>
          <h1 class="mt-6 text-4xl font-black leading-tight sm:text-5xl lg:text-6xl">
            {{ hero?.title || t('franchise.heroDefaultTitle') }}
          </h1>
          <p class="mt-6 max-w-2xl text-base leading-8 text-white/80 sm:text-lg">
            {{ hero?.description || t('franchise.heroDefaultDescription') }}
          </p>

          <!-- Stats row -->
          <div class="mt-8 flex flex-wrap gap-5">
            <div v-for="stat in heroStats" :key="stat.label" class="text-center">
              <p class="text-2xl font-black text-green-300">{{ stat.num }}</p>
              <p class="text-xs text-white/60 font-bold mt-0.5">{{ stat.label }}</p>
            </div>
          </div>

          <div class="mt-8 flex flex-col gap-3 sm:flex-row">
            <RouterLink
              :to="hero?.buttonLink || '/consultation'"
              class="inline-flex items-center justify-center gap-2 rounded-full bg-green-400 px-7 py-4 text-sm font-black uppercase tracking-wider text-avocado-950 shadow-xl shadow-green-400/25 transition hover:-translate-y-0.5 hover:bg-green-300"
              @click="trackEvent('click_franchise_cta', { location: 'hero_primary' })"
            >
              {{ hero?.buttonText || t('franchise.heroDefaultPrimaryCta') }}
              <ArrowRight class="h-4 w-4" />
            </RouterLink>
            <RouterLink
              v-if="secondaryHeroAction.type === 'route'"
              :to="secondaryHeroAction.to"
              class="inline-flex items-center justify-center rounded-full border border-white/20 bg-white/10 px-7 py-4 text-sm font-black uppercase tracking-wider text-white transition hover:bg-white/15"
              @click="trackEvent('click_franchise_cta', { location: 'hero_secondary' })"
            >
              {{ hero?.secondaryButtonText || t('franchise.heroDefaultSecondaryCta') }}
            </RouterLink>
            <a
              v-else-if="secondaryHeroAction.type === 'external'"
              :href="secondaryHeroAction.href"
              target="_blank"
              rel="noopener noreferrer"
              class="inline-flex items-center justify-center rounded-full border border-white/20 bg-white/10 px-7 py-4 text-sm font-black uppercase tracking-wider text-white transition hover:bg-white/15"
              @click="trackEvent('click_franchise_cta', { location: 'hero_secondary' })"
            >
              {{ hero?.secondaryButtonText || t('franchise.heroDefaultSecondaryCta') }}
            </a>
            <button
              v-else
              type="button"
              class="inline-flex items-center justify-center rounded-full border border-white/20 bg-white/10 px-7 py-4 text-sm font-black uppercase tracking-wider text-white transition hover:bg-white/15"
              @click="scrollToSection(secondaryHeroAction.target)"
            >
              {{ hero?.secondaryButtonText || t('franchise.heroDefaultSecondaryCta') }}
            </button>
          </div>
        </div>
      </div>
    </section>

    <!-- ===== LOADING STATE ===== -->
    <section v-if="franchiseStore.loading" class="mx-auto max-w-[1240px] space-y-8 px-4 py-16 sm:px-6 lg:px-8">
      <div class="inline-flex items-center gap-3 text-sm font-bold text-slate-500">
        <div class="h-4 w-4 animate-spin rounded-full border-2 border-avocado-400 border-t-transparent"></div>
        {{ t('franchise.loading') }}
      </div>
      <div class="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
        <div v-for="i in 6" :key="i" class="rounded-3xl border border-avocado-100/60 bg-white p-7 shadow-sm">
          <div class="h-12 w-12 animate-pulse rounded-2xl bg-slate-100"></div>
          <div class="mt-6 h-5 w-2/3 animate-pulse rounded bg-slate-100"></div>
          <div class="mt-3 h-4 w-full animate-pulse rounded bg-slate-100"></div>
          <div class="mt-2 h-4 w-5/6 animate-pulse rounded bg-slate-100"></div>
        </div>
      </div>
    </section>

    <template v-else>
      <section
        v-if="franchiseStore.error"
        class="mx-auto max-w-[1240px] px-4 pt-8 sm:px-6 lg:px-8"
      >
        <p class="rounded-2xl border border-amber-200 bg-amber-50 px-5 py-4 text-center text-sm font-bold text-amber-800">
          {{ franchiseStore.error }}
          <span class="mt-1 block text-xs font-semibold text-amber-700/80">{{ t('franchise.loadErrorHint') }}</span>
        </p>
      </section>

      <!-- ===== LỢI THẾ THƯƠNG HIỆU ===== -->
      <section class="mx-auto max-w-[1240px] px-4 py-20 sm:px-6 lg:px-8">
        <div class="max-w-3xl mb-12">
          <p class="text-xs font-black uppercase tracking-[0.22em] text-avocado-600">{{ t('franchise.advantagesEyebrow') }}</p>
          <h2 class="mt-3 text-3xl font-black leading-tight lg:text-4xl">{{ t('franchise.advantagesTitle') }}</h2>
          <p class="mt-3 text-sm leading-7 text-slate-500 max-w-2xl">{{ t('franchise.advantagesDesc') }}</p>
        </div>
        <div class="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
          <article
            v-for="item in franchiseStore.visibleAdvantages"
            :key="item.id"
            class="group rounded-3xl border border-avocado-100/60 bg-white p-7 shadow-sm transition hover:-translate-y-1 hover:shadow-xl hover:border-avocado-300/50"
          >
            <div class="grid h-12 w-12 place-items-center rounded-2xl bg-avocado-50 text-avocado-700 group-hover:bg-avocado-100 transition duration-300">
              <component :is="iconMap[item.icon] || iconMap.default" class="h-6 w-6" />
            </div>
            <h3 class="mt-6 text-xl font-black text-avocado-950">{{ item.title }}</h3>
            <p class="mt-3 text-sm leading-7 text-slate-500">{{ item.description }}</p>
          </article>
        </div>
      </section>

      <!-- ===== CÁC MÔ HÌNH ===== -->
      <section class="bg-white py-20">
        <div class="mx-auto max-w-[1240px] px-4 sm:px-6 lg:px-8">
          <div class="max-w-3xl mb-12">
            <p class="text-xs font-black uppercase tracking-[0.22em] text-avocado-600">{{ t('franchise.modelsEyebrow') }}</p>
            <h2 class="mt-3 text-3xl font-black lg:text-4xl">{{ t('franchise.modelsTitle') }}</h2>
            <p class="mt-3 text-sm leading-7 text-slate-500">{{ t('franchise.modelsDesc') }}</p>
          </div>
          <div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            <article
              v-for="model in franchiseStore.visibleModels"
              :key="model.id"
              class="overflow-hidden rounded-3xl border bg-cream-50 shadow-sm transition hover:-translate-y-1 hover:shadow-xl"
              :class="model.featured ? 'border-avocado-500 ring-2 ring-avocado-400/30' : 'border-slate-200'"
            >
              <div class="relative h-48 overflow-hidden">
                <img
                  :src="model.image"
                  :alt="model.modelName"
                  class="h-full w-full object-cover transition duration-500 hover:scale-105"
                  loading="lazy"
                />
                <div class="absolute inset-0 bg-gradient-to-t from-avocado-950/60 to-transparent"></div>
                <span
                  v-if="model.featured"
                  class="absolute top-3 right-3 rounded-full bg-avocado-600 text-white px-3 py-1 text-xs font-black"
                >{{ t('franchise.featuredModelBadge') }}</span>
                <span class="absolute bottom-3 left-3 rounded-xl bg-white/90 backdrop-blur-sm px-3 py-1 text-xs font-black text-avocado-800">
                  {{ model.investment }}
                </span>
              </div>
              <div class="p-6">
                <div class="flex items-center gap-2 mb-3">
                  <component :is="modelIconMap[model.modelName] || Store" class="h-5 w-5 text-avocado-600" />
                  <h3 class="text-xl font-black text-avocado-950">{{ model.modelName }}</h3>
                </div>
                <div class="mb-4 rounded-xl bg-white border border-avocado-100 p-3">
                  <p class="text-xs font-black uppercase text-slate-400 mb-1">{{ t('franchise.modelAreaLabel') }}</p>
                  <p class="font-black text-avocado-700 text-sm">{{ model.area }}</p>
                </div>
                <p class="text-sm leading-6 text-slate-500">{{ model.description }}</p>
              </div>
            </article>
          </div>
        </div>
      </section>

      <!-- ===== BẢNG CHI PHÍ ===== -->
      <section id="investment" class="mx-auto max-w-[1240px] px-4 py-20 sm:px-6 lg:px-8 scroll-mt-24">
        <div class="max-w-3xl mb-12">
          <p class="text-xs font-black uppercase tracking-[0.22em] text-avocado-600">{{ t('franchise.investmentEyebrow') }}</p>
          <h2 class="mt-3 text-3xl font-black lg:text-4xl">{{ t('franchise.investmentTitle') }}</h2>
          <p class="mt-3 text-sm leading-7 text-slate-500">{{ t('franchise.investmentDesc') }}</p>
        </div>

        <!-- Mobile cards view -->
        <div class="sm:hidden space-y-4 mb-8">
          <div v-for="item in franchiseStore.visibleInvestment" :key="item.id"
            class="rounded-2xl border border-avocado-100 bg-white p-5 shadow-sm"
          >
            <p class="font-black text-avocado-900 mb-3">{{ item.itemName }}</p>
            <div class="grid grid-cols-2 gap-3 text-sm">
              <div class="rounded-xl bg-slate-50 p-3">
                <p class="text-xs font-bold text-slate-400 mb-1">{{ t('franchise.investmentTypeKiosk') }}</p>
                <p class="font-black text-slate-700">{{ item.kioskValue }}</p>
              </div>
              <div class="rounded-xl bg-avocado-50 p-3">
                <p class="text-xs font-bold text-avocado-500 mb-1">{{ t('franchise.investmentTypeStandard') }}</p>
                <p class="font-black text-avocado-700">{{ item.standardValue }}</p>
              </div>
              <div class="rounded-xl bg-slate-50 p-3 col-span-2">
                <p class="text-xs font-bold text-slate-400 mb-1">{{ t('franchise.investmentTypeFlagship') }}</p>
                <p class="font-black text-slate-700">{{ item.flagshipValue }}</p>
              </div>
            </div>
            <p class="mt-3 text-xs text-slate-400 italic">{{ item.note }}</p>
          </div>
        </div>

        <!-- Desktop table -->
        <div class="hidden sm:block overflow-x-auto rounded-3xl border border-avocado-100 bg-white shadow-sm">
          <table class="min-w-[700px] w-full text-left text-sm">
            <thead class="bg-avocado-950 text-white">
              <tr>
                <th scope="col" class="px-6 py-5 font-black rounded-tl-3xl">{{ t('franchise.investmentTableItem') }}</th>
                <th scope="col" class="px-6 py-5 font-black text-green-300">{{ t('franchise.investmentTypeKiosk') }}</th>
                <th scope="col" class="px-6 py-5 font-black text-green-300">{{ t('franchise.investmentTypeStandard') }} ★</th>
                <th scope="col" class="px-6 py-5 font-black text-green-300">{{ t('franchise.investmentTypeFlagship') }}</th>
                <th scope="col" class="px-6 py-5 font-black text-white/60 rounded-tr-3xl">{{ t('franchise.investmentTableNote') }}</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr
                v-for="item in franchiseStore.visibleInvestment"
                :key="item.id"
                class="hover:bg-avocado-50/50 transition"
              >
                <td class="px-6 py-4 font-black text-avocado-900">{{ item.itemName }}</td>
                <td class="px-6 py-4 text-slate-600">{{ item.kioskValue }}</td>
                <td class="px-6 py-4 font-bold text-avocado-700 bg-avocado-50/60">{{ item.standardValue }}</td>
                <td class="px-6 py-4 text-slate-600">{{ item.flagshipValue }}</td>
                <td class="px-6 py-4 text-xs text-slate-400 max-w-xs">{{ item.note }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <p class="mt-4 text-xs text-slate-400 text-center">{{ t('franchise.investmentFootnote') }}</p>
      </section>

      <!-- ===== DOANH THU THAM KHẢO ===== -->
      <section class="bg-avocado-950 py-20 text-white">
        <div class="mx-auto max-w-[1240px] px-4 sm:px-6 lg:px-8">
          <div class="grid gap-10 lg:grid-cols-[0.8fr_1.2fr] lg:items-center">
            <div>
              <p class="text-xs font-black uppercase tracking-[0.22em] text-green-300">{{ t('franchise.revenueEyebrow') }}</p>
              <h2 class="mt-3 text-3xl font-black lg:text-4xl">{{ t('franchise.revenueTitle') }}</h2>
              <p class="mt-4 text-sm leading-7 text-white/70">
                {{ t('franchise.revenueDesc') }}
              </p>
              <div class="mt-6 flex flex-col gap-3">
                <div
                  v-for="point in revenuePoints"
                  :key="point"
                  class="flex items-center gap-2 text-sm text-green-200/80"
                >
                  <CheckCircle2 class="h-4 w-4 shrink-0 text-green-400" />
                  {{ point }}
                </div>
              </div>
            </div>
            <div class="grid gap-4 sm:grid-cols-3">
              <article
                v-for="item in franchiseStore.visibleProfit"
                :key="item.id"
                class="rounded-3xl border border-white/10 bg-white/5 p-6 hover:bg-white/10 transition duration-300"
              >
                <BarChart3 class="h-7 w-7 text-green-400" />
                <p class="mt-5 text-sm font-bold text-white/60">{{ item.metric }}</p>
                <p class="mt-2 text-2xl font-black text-green-300">{{ item.value }}</p>
                <p class="mt-3 text-xs leading-6 text-white/60">{{ item.description }}</p>
              </article>
            </div>
          </div>
        </div>
      </section>

      <!-- ===== QUY TRÌNH 6 BƯỚC ===== -->
      <section id="process" class="mx-auto max-w-[1240px] px-4 py-20 sm:px-6 lg:px-8 scroll-mt-24">
        <div class="max-w-3xl mb-12">
          <p class="text-xs font-black uppercase tracking-[0.22em] text-avocado-600">{{ t('franchise.processEyebrow') }}</p>
          <h2 class="mt-3 text-3xl font-black lg:text-4xl">{{ t('franchise.processTitle') }}</h2>
          <p class="mt-3 text-sm leading-7 text-slate-500">{{ t('franchise.processDesc') }}</p>
        </div>
        <div class="relative">
          <!-- Connection line (desktop) -->
          <div class="hidden lg:block absolute top-10 left-10 right-10 h-0.5 bg-gradient-to-r from-avocado-200 via-avocado-400 to-avocado-200 z-0"></div>
          <div class="relative z-10 grid gap-5 lg:grid-cols-6">
            <article
              v-for="step in franchiseStore.visibleProcess"
              :key="step.id"
              class="rounded-3xl border border-avocado-100 bg-white p-5 shadow-sm hover:-translate-y-1 hover:shadow-lg transition duration-300 text-center lg:text-left"
            >
              <span class="inline-grid h-12 w-12 place-items-center rounded-2xl bg-avocado-600 text-white text-lg font-black shadow-lg shadow-avocado-400/30">
                {{ step.stepNumber }}
              </span>
              <h3 class="mt-4 text-base font-black text-avocado-950">{{ step.title }}</h3>
              <p class="mt-2 text-xs leading-5 text-slate-500">{{ step.description }}</p>
            </article>
          </div>
        </div>
      </section>

      <!-- ===== CÂU CHUYỆN SÁNG LẬP ===== -->
      <section v-if="founder" class="bg-white py-20">
        <div class="mx-auto grid max-w-[1240px] gap-12 px-4 sm:px-6 lg:grid-cols-[400px_1fr] lg:px-8 lg:items-center">
          <div class="relative group">
            <div class="absolute -inset-2 rounded-3xl bg-gradient-to-br from-avocado-300/30 to-green-300/20 blur-xl opacity-60 group-hover:opacity-80 transition duration-500"></div>
            <img
              :src="founder.image"
              :alt="founder.founderName"
              class="relative aspect-[4/5] w-full rounded-3xl object-cover shadow-xl"
              loading="lazy"
            />
          </div>
          <div class="space-y-5">
            <span class="inline-flex items-center gap-2 text-xs font-black uppercase tracking-[0.22em] text-avocado-600 bg-avocado-50 rounded-full px-4 py-2">
              <Leaf class="h-3.5 w-3.5" /> {{ founder.founderName }}
            </span>
            <h2 class="text-3xl font-black lg:text-4xl text-avocado-950">{{ founder.title }}</h2>
            <div class="space-y-4 text-slate-600 leading-8 whitespace-pre-line text-sm sm:text-base">
              {{ founder.storyContent }}
            </div>
            <RouterLink
              to="/about"
              class="inline-flex items-center gap-2 text-sm font-black text-avocado-700 hover:text-avocado-900 transition"
            >
              {{ t('franchise.readBrandStory') }} <ArrowRight class="h-4 w-4" />
            </RouterLink>
          </div>
        </div>
      </section>

      <!-- ===== CỬA HÀNG ĐANG VẬN HÀNH ===== -->
      <section v-if="featuredStores.length" class="mx-auto max-w-[1240px] px-4 py-20 sm:px-6 lg:px-8">
        <div class="max-w-3xl mb-12">
          <p class="text-xs font-black uppercase tracking-[0.22em] text-avocado-600">{{ t('franchise.storesEyebrow') }}</p>
          <h2 class="mt-3 text-3xl font-black lg:text-4xl">{{ t('franchise.storesTitle') }}</h2>
          <p class="mt-3 text-sm leading-7 text-slate-500">{{ t('franchise.storesDesc') }}</p>
        </div>
        <div class="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          <RouterLink
            v-for="store in featuredStores"
            :key="store.id"
            :to="storeLink(store)"
            class="group overflow-hidden rounded-3xl border border-avocado-100 bg-white shadow-sm transition duration-300 hover:-translate-y-1 hover:shadow-xl"
          >
            <div class="relative h-44 overflow-hidden">
              <img
                :src="store.coverImageUrl || store.imageUrl"
                :alt="store.name"
                class="h-full w-full object-cover transition duration-500 group-hover:scale-105"
                loading="lazy"
              />
              <div class="absolute inset-0 bg-gradient-to-t from-avocado-950/40 to-transparent"></div>
            </div>
            <div class="p-5">
              <h3 class="font-black text-avocado-950 group-hover:text-avocado-700">{{ store.name }}</h3>
              <p class="mt-2 flex gap-2 text-sm leading-6 text-slate-500">
                <MapPin class="mt-1 h-4 w-4 shrink-0 text-avocado-500" />
                {{ store.addressText || store.address }}
              </p>
              <p v-if="store.phone" class="mt-2 flex gap-2 text-sm font-bold text-avocado-700">
                <Phone class="h-4 w-4 shrink-0 mt-0.5" />{{ store.phone }}
              </p>
              <p class="mt-4 inline-flex items-center gap-1 text-xs font-black uppercase tracking-wider text-avocado-700">
                {{ t('franchise.viewStoreDetail') }}
                <ArrowRight class="h-3.5 w-3.5 transition group-hover:translate-x-0.5" />
              </p>
            </div>
          </RouterLink>
        </div>
        <div class="mt-8 text-center">
          <RouterLink
            to="/locations"
            class="inline-flex items-center gap-2 rounded-full border border-avocado-300 bg-white px-6 py-3 text-sm font-black text-avocado-700 hover:bg-avocado-50 transition"
          >
            {{ t('franchise.viewAllStores') }} <ArrowRight class="h-4 w-4" />
          </RouterLink>
        </div>
      </section>

      <!-- ===== ĐỐI TÁC LÝ TƯỞNG ===== -->
      <section class="bg-avocado-50 py-20">
        <div class="mx-auto max-w-[1240px] px-4 sm:px-6 lg:px-8">
          <div class="text-center max-w-2xl mx-auto mb-12">
            <p class="text-xs font-black uppercase tracking-[0.22em] text-avocado-600">{{ t('franchise.partnersEyebrow') }}</p>
            <h2 class="mt-3 text-3xl font-black lg:text-4xl text-avocado-950">{{ t('franchise.partnersTitle') }}</h2>
            <p class="mt-3 text-sm leading-7 text-slate-500">{{ t('franchise.partnersDesc') }}</p>
          </div>
          <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <div v-for="partner in partnerProfiles" :key="partner.title"
              class="rounded-3xl border border-avocado-100 bg-white p-7 shadow-sm hover:-translate-y-1 hover:shadow-lg transition duration-300 text-center"
            >
              <div class="mx-auto grid h-12 w-12 place-items-center rounded-2xl bg-avocado-100 text-avocado-700 mb-4">
                <component :is="partner.icon" class="h-6 w-6" />
              </div>
              <h3 class="font-black text-avocado-950 text-lg">{{ partner.title }}</h3>
              <p class="mt-2 text-sm text-slate-500 leading-6">{{ partner.desc }}</p>
            </div>
          </div>
        </div>
      </section>

      <!-- ===== FAQ ===== -->
      <section v-if="franchiseStore.visibleFaq.length" class="bg-white py-20">
        <div class="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          <div class="text-center mb-12">
            <p class="text-xs font-black uppercase tracking-[0.22em] text-avocado-600">{{ t('franchise.faqEyebrow') }}</p>
            <h2 class="mt-3 text-3xl font-black lg:text-4xl">{{ t('franchise.faqTitle') }}</h2>
            <p class="mt-3 text-sm text-slate-500">{{ t('franchise.faqDesc') }}</p>
          </div>
          <div class="divide-y divide-slate-100 rounded-3xl border border-avocado-100 bg-cream-50 overflow-hidden">
            <div v-for="item in franchiseStore.visibleFaq" :key="item.id">
              <button
                :id="`faq-question-${item.id}`"
                type="button"
                class="block w-full px-6 py-5 text-left hover:bg-avocado-50/60 transition"
                :aria-expanded="openFaq === item.id"
                :aria-controls="`faq-answer-${item.id}`"
                @click="faqToggle(item.id)"
              >
                <span class="flex items-center justify-between gap-4">
                  <span class="font-black text-avocado-950">{{ item.question }}</span>
                  <span
                    class="grid h-8 w-8 shrink-0 place-items-center rounded-full bg-avocado-100 text-avocado-700 transition duration-300"
                    :class="openFaq === item.id ? 'rotate-180 bg-avocado-600 text-white' : ''"
                    aria-hidden="true"
                  >
                    <ChevronDown class="h-4 w-4" />
                  </span>
                </span>
              </button>
              <div
                v-if="openFaq === item.id"
                :id="`faq-answer-${item.id}`"
                role="region"
                :aria-labelledby="`faq-question-${item.id}`"
                class="px-6 pb-5 text-sm leading-7 text-slate-600"
              >
                {{ item.answer }}
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- ===== CTA + FORM ===== -->
      <section class="mx-auto max-w-[1240px] px-4 py-20 sm:px-6 lg:px-8">
        <div class="overflow-hidden rounded-[2rem] bg-avocado-950 text-white shadow-2xl lg:grid lg:grid-cols-[0.95fr_1.05fr]">
          <!-- Left side -->
          <div class="p-8 lg:p-12 flex flex-col justify-between">
            <div>
              <div class="grid h-14 w-14 place-items-center rounded-2xl bg-green-400/20 text-green-300 mb-6">
                <Store class="h-8 w-8" />
              </div>
              <h2 class="text-3xl font-black lg:text-4xl leading-tight">
                {{ cta?.title || t('franchise.ctaDefaultTitle') }}
              </h2>
              <p class="mt-4 text-sm leading-7 text-white/70">
                {{ cta?.description || t('franchise.ctaDefaultDesc') }}
              </p>
            </div>
            <div class="mt-8 space-y-3">
              <div
                v-for="point in ctaPoints"
                :key="point"
                class="text-sm text-green-200/80 font-medium"
              >{{ point }}</div>
            </div>
          </div>
          <!-- Right side: form -->
          <div class="bg-white p-6 text-avocado-950 lg:p-10">
            <p class="text-lg font-black text-avocado-950 mb-6">{{ t('franchise.consultationTitle') }}</p>
            <ConsultationForm />
          </div>
        </div>
      </section>

    </template>
  </div>
</template>
