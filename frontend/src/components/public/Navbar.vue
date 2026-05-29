<script setup>
import { computed, ref, onMounted, onBeforeUnmount } from 'vue'
import { useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { Menu, X } from 'lucide-vue-next'
import LanguageSwitcher from './LanguageSwitcher.vue'
import UserMenu from './UserMenu.vue'

const route = useRoute()
const { t } = useI18n()
const isDrawerOpen = ref(false)
const isScrolled = ref(false)

const navItems = [
  { labelKey: 'nav.home', to: '/' },
  { labelKey: 'nav.products', to: '/products' },
  { labelKey: 'nav.system', to: '/locations' },
  { labelKey: 'nav.franchise', to: '/franchise', featured: true },
  { labelKey: 'nav.about', to: '/about' },
  { labelKey: 'nav.blog', to: '/blog' },
]

const isActive = (path) => (path === '/' ? route.path === '/' : route.path.startsWith(path))
const drawerClasses = computed(() =>
  isDrawerOpen.value
    ? 'translate-x-0 opacity-100'
    : 'translate-x-full opacity-0 pointer-events-none',
)

const closeDrawer = () => {
  isDrawerOpen.value = false
}

const handleScroll = () => {
  isScrolled.value = window.scrollY > 20
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
  handleScroll() // Initialize on load
})

onBeforeUnmount(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>

<template>
  <header
    :class="[
      'sticky top-0 z-50 transition-all duration-300',
      isScrolled
        ? 'glass-navbar py-2 shadow-md shadow-brand-forest/5 border-b border-brand-forest/5'
        : 'bg-transparent py-4 border-b border-transparent'
    ]"
  >
    <nav class="mx-auto flex w-full max-w-[1280px] items-center justify-between px-4 sm:px-6 lg:px-8">
      <RouterLink
        to="/"
        class="flex shrink-0 items-center outline-none ring-brand-lime focus-visible:rounded-xl focus-visible:ring-2 focus-visible:ring-offset-4 transition transform hover:scale-[1.03]"
      >
        <img
          src="/logo-aloo.png"
          :alt="`${t('brand.name')} — ${t('brand.tagline')}`"
          class="h-9 w-auto max-w-[min(160px,48vw)] object-contain object-left sm:h-10 transition-all duration-300"
          width="200"
          height="48"
        />
      </RouterLink>

      <div class="hidden items-center gap-2 lg:flex">
        <RouterLink
          v-for="item in navItems"
          :key="item.to"
          :to="item.to"
          class="rounded-full px-4 py-2 text-sm font-semibold tracking-wide transition-all duration-300 hover-scale"
          :class="[
            isActive(item.to)
              ? 'bg-avocado-100 text-avocado-800 shadow-sm font-bold'
              : 'text-slate-600 hover:bg-avocado-50 hover:text-avocado-700',
            item.featured ? 'font-extrabold text-brand-forest border border-brand-lime/20 bg-brand-lime/10 shadow-sm shadow-brand-lime/5' : '',
          ]"
        >
          {{ t(item.labelKey) }}
        </RouterLink>
      </div>

      <div class="hidden items-center gap-4 lg:flex">
        <LanguageSwitcher />
        <RouterLink
          to="/consultation"
          class="rounded-full bg-avocado-700 px-6 py-2.5 text-xs font-black uppercase tracking-wider text-white shadow-lg shadow-brand-forest/15 transition-all duration-300 transform hover:-translate-y-0.5 hover:bg-avocado-800 hover:shadow-xl hover:shadow-brand-forest/25"
        >
          {{ t('nav.consultation') }}
        </RouterLink>
        <UserMenu />
      </div>

      <button
        class="grid h-10 w-10 place-items-center rounded-full border border-brand-forest/10 bg-white text-brand-dark shadow-sm transition hover:bg-brand-cream lg:hidden active:scale-95"
        :aria-label="t('nav.menu')"
        @click="isDrawerOpen = true"
      >
        <Menu class="h-5 w-5" />
      </button>
    </nav>

    <!-- Mobile menu drawer -->
    <div
      v-if="isDrawerOpen"
      class="fixed inset-0 z-50 bg-slate-950/40 backdrop-blur-sm lg:hidden transition-all duration-300"
      @click.self="closeDrawer"
    >
      <aside
        :class="[
          'ml-auto h-full w-[min(320px,85vw)] bg-white/98 backdrop-blur-xl p-6 shadow-2xl transition-all duration-300 border-l border-brand-lime/15 flex flex-col justify-between',
          drawerClasses,
        ]"
      >
        <div>
          <div class="mb-8 flex items-center justify-between gap-3">
            <img
              src="/logo-aloo.png"
              :alt="`${t('brand.name')} — ${t('brand.tagline')}`"
              class="h-9 w-auto max-w-[70%] object-contain object-left"
              width="180"
              height="44"
            />
            <button
              class="grid h-10 w-10 place-items-center rounded-full border border-slate-200 text-slate-600 transition hover:bg-slate-50"
              aria-label="Close menu"
              @click="closeDrawer"
            >
              <X class="h-5 w-5" />
            </button>
          </div>

          <div class="grid gap-2">
            <RouterLink
              v-for="item in navItems"
              :key="item.to"
              :to="item.to"
              class="rounded-xl px-4 py-3 text-sm font-semibold transition-all duration-200"
              :class="[
                isActive(item.to)
                  ? 'bg-avocado-100 text-avocado-800 font-bold'
                  : 'text-slate-700 hover:bg-avocado-50/60 hover:text-avocado-700',
                item.featured ? 'text-brand-forest font-extrabold border border-brand-lime/15 bg-brand-lime/5' : '',
              ]"
              @click="closeDrawer"
            >
              {{ t(item.labelKey) }}
            </RouterLink>
          </div>
        </div>

        <div class="mt-auto pt-6 border-t border-slate-100/80">
          <div class="flex items-center justify-between mb-4">
            <span class="text-xs text-slate-400 uppercase tracking-widest font-black">Ngôn ngữ</span>
            <LanguageSwitcher />
          </div>

          <div class="mt-4">
            <RouterLink
              to="/consultation"
              class="block w-full rounded-full bg-brand-forest px-4 py-3.5 text-center text-xs font-black uppercase tracking-wider text-white shadow-lg shadow-brand-forest/15 hover:bg-brand-dark transition active:scale-98"
              @click="closeDrawer"
            >
              {{ t('nav.consultation') }}
            </RouterLink>
          </div>

          <div class="mt-4 flex justify-center border-t border-slate-100/80 pt-4">
            <UserMenu @navigate="closeDrawer" />
          </div>
        </div>
      </aside>
    </div>
  </header>
</template>

