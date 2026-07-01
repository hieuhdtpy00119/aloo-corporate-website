<script setup>
import { computed, ref, onMounted, onBeforeUnmount } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ChevronDown, LayoutDashboard, LogOut, Menu, ShieldCheck, UserRound, X } from 'lucide-vue-next'
import LanguageSwitcher from './LanguageSwitcher.vue'
import { trackEvent } from '../../services/analyticsService'
import { clearAuthSession, refreshAuthProfile } from '../../services/authService'
import { repairUtf8Mojibake } from '../../utils/textEncoding'
import { isAdminToken, isAuthenticatedToken } from '../../router/authGuard'

const route = useRoute()
const router = useRouter()
const { t } = useI18n()
const isDrawerOpen = ref(false)
const isAccountMenuOpen = ref(false)
const isScrolled = ref(false)
const isLoggedIn = ref(false)
const hasAdminAccess = ref(false)
const adminInfo = ref(null)

const navItems = [
  { labelKey: 'nav.home', to: '/' },
  { labelKey: 'nav.system', to: '/locations' },
  { labelKey: 'nav.franchise', to: '/franchise', featured: true },
  { labelKey: 'nav.products', to: '/products' },
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

const closeAccountMenu = () => {
  isAccountMenuOpen.value = false
}

const parseAdminInfo = () => {
  try {
    return JSON.parse(localStorage.getItem('admin_user') || 'null')
  } catch {
    return null
  }
}

const syncAuthState = () => {
  const token = localStorage.getItem('admin_token')

  if (token && !isAuthenticatedToken(token)) {
    clearAuthSession()
  }

  isLoggedIn.value = isAuthenticatedToken(localStorage.getItem('admin_token'))
  hasAdminAccess.value = isAdminToken(localStorage.getItem('admin_token'))
  adminInfo.value = isLoggedIn.value ? parseAdminInfo() : null
}

const accountName = computed(() => {
  const raw = adminInfo.value?.fullName || adminInfo.value?.email || 'ALOO Admin'
  return repairUtf8Mojibake(raw)
})
const accountSubtitle = computed(() => {
  if (!isLoggedIn.value) return 'Tài khoản ALOO'
  return hasAdminAccess.value ? 'Quản trị hệ thống' : 'Tài khoản ALOO'
})
const profilePath = computed(() => {
  if (!isLoggedIn.value) return '/login'
  return hasAdminAccess.value ? '/admin/profile' : '/account'
})
const accountAvatarUrl = computed(() => adminInfo.value?.avatarUrl || adminInfo.value?.avatar || '')
const accountInitial = computed(() => {
  const source = isLoggedIn.value ? accountName.value : 'A'
  return source.trim().charAt(0).toUpperCase() || 'A'
})

const logout = () => {
  clearAuthSession()
  window.dispatchEvent(new Event('aloo-auth-change'))
  syncAuthState()
  closeAccountMenu()
  closeDrawer()
  if (route.path === '/account' || route.path.startsWith('/admin')) {
    router.push('/login')
  }
}

const handleScroll = () => {
  isScrolled.value = window.scrollY > 20
}

onMounted(async () => {
  window.addEventListener('scroll', handleScroll)
  window.addEventListener('storage', syncAuthState)
  window.addEventListener('aloo-auth-change', syncAuthState)
  syncAuthState()
  handleScroll()

  if (localStorage.getItem('admin_token')) {
    try {
      await refreshAuthProfile()
      syncAuthState()
    } catch {
      // Token expired or backend unavailable — keep cached profile.
    }
  }
})

onBeforeUnmount(() => {
  window.removeEventListener('scroll', handleScroll)
  window.removeEventListener('storage', syncAuthState)
  window.removeEventListener('aloo-auth-change', syncAuthState)
})
</script>

<template>
  <header
    :class="[
      'sticky top-0 z-50 h-16 border-b transition-colors duration-300',
      isScrolled
        ? 'glass-navbar border-brand-forest/5 shadow-md shadow-brand-forest/5'
        : 'bg-white border-brand-forest/5 shadow-sm shadow-brand-forest/5'
    ]"
  >
    <nav class="mx-auto flex h-full w-full max-w-[1240px] items-center justify-between px-4 sm:px-6 lg:px-8">
      <RouterLink
        to="/"
        class="nav-brand flex shrink-0 items-center outline-none ring-brand-lime focus-visible:rounded-xl focus-visible:ring-2 focus-visible:ring-offset-4 transition transform hover:scale-[1.02]"
      >
        <img
          src="/logo-aloo-nav.png"
          :alt="`${t('brand.name')} — ${t('brand.tagline')}`"
          class="nav-brand__logo"
          width="148"
          height="40"
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
        <div class="relative">
          <button
            type="button"
            class="group relative grid h-10 w-10 place-items-center rounded-full border border-avocado-200/70 bg-white text-avocado-800 shadow-sm transition hover:border-avocado-300 hover:bg-avocado-50 focus:outline-none focus:ring-4 focus:ring-avocado-100"
            :aria-label="isLoggedIn ? t('userMenu.profile') : t('userMenu.login')"
            aria-haspopup="menu"
            :aria-expanded="isAccountMenuOpen"
            @click="isAccountMenuOpen = !isAccountMenuOpen"
          >
            <span class="grid h-8 w-8 place-items-center overflow-hidden rounded-full bg-gradient-to-br from-avocado-100 to-cream-100 text-xs font-black text-avocado-900 ring-1 ring-white">
              <img
                v-if="isLoggedIn && accountAvatarUrl"
                :src="accountAvatarUrl"
                :alt="accountName"
                class="h-full w-full object-cover"
              />
              <span v-else-if="isLoggedIn">{{ accountInitial }}</span>
              <UserRound v-else class="h-4.5 w-4.5" />
            </span>
            <span
              class="absolute -bottom-0.5 -right-0.5 grid h-4 w-4 place-items-center rounded-full border border-white bg-white text-slate-400 shadow-sm transition group-hover:text-avocado-700"
              :class="isAccountMenuOpen ? 'text-avocado-700' : ''"
            >
              <ChevronDown class="h-3 w-3 transition" :class="isAccountMenuOpen ? 'rotate-180' : ''" />
            </span>
          </button>

          <div
            v-if="isAccountMenuOpen"
            class="absolute right-0 top-[calc(100%+0.75rem)] z-50 w-64 overflow-hidden rounded-2xl border border-slate-200 bg-white text-slate-700 shadow-xl"
            role="menu"
          >
            <div class="border-b border-slate-100 bg-slate-50 px-4 py-3">
              <div class="flex items-center gap-3">
                <span class="grid h-10 w-10 shrink-0 place-items-center overflow-hidden rounded-full bg-gradient-to-br from-avocado-100 to-cream-100 text-sm font-black text-avocado-900">
                  <img
                    v-if="isLoggedIn && accountAvatarUrl"
                    :src="accountAvatarUrl"
                    :alt="accountName"
                    class="h-full w-full object-cover"
                  />
                  <span v-else-if="isLoggedIn">{{ accountInitial }}</span>
                  <UserRound v-else class="h-5 w-5" />
                </span>
                <span class="min-w-0">
                  <span class="block truncate text-sm font-black text-avocado-950">
                    {{ isLoggedIn ? accountName : t('userMenu.login') }}
                  </span>
                  <span class="mt-0.5 block truncate text-xs font-semibold text-slate-500">
                    {{ accountSubtitle }}
                  </span>
                </span>
              </div>
            </div>
            <div class="p-2">
              <RouterLink
                :to="profilePath"
                class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-bold hover:bg-avocado-50 hover:text-avocado-900"
                role="menuitem"
                @click="closeAccountMenu"
              >
                <UserRound class="h-4.5 w-4.5 text-avocado-700" />
                {{ isLoggedIn ? t('userMenu.profile') : t('userMenu.login') }}
              </RouterLink>
              <RouterLink
                v-if="hasAdminAccess"
                to="/admin"
                class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-bold hover:bg-avocado-50 hover:text-avocado-900"
                role="menuitem"
                @click="closeAccountMenu"
              >
                <LayoutDashboard class="h-4.5 w-4.5 text-avocado-700" />
                {{ t('userMenu.cms') }}
              </RouterLink>
              <button
                v-if="isLoggedIn"
                type="button"
                class="mt-1 flex w-full items-center gap-3 rounded-xl border-t border-slate-100 px-3 py-2.5 text-left text-sm font-bold text-red-600 hover:bg-red-50"
                role="menuitem"
                @click="logout"
              >
                <LogOut class="h-4.5 w-4.5" />
                {{ t('userMenu.logout') }}
              </button>
            </div>
          </div>
        </div>
        <RouterLink
          to="/consultation"
          class="rounded-full bg-avocado-700 px-6 py-2.5 text-xs font-black uppercase tracking-wider text-white shadow-lg shadow-brand-forest/15 transition-all duration-300 transform hover:-translate-y-0.5 hover:bg-avocado-800 hover:shadow-xl hover:shadow-brand-forest/25"
          @click="trackEvent('click_franchise_cta', { location: 'navbar' })"
        >
          {{ t('nav.consultation') }}
        </RouterLink>
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
              src="/logo-aloo-nav.png"
              :alt="`${t('brand.name')} — ${t('brand.tagline')}`"
              class="nav-brand__logo nav-brand__logo--drawer"
              width="148"
              height="40"
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
            <div class="mb-3 rounded-2xl border border-slate-200 bg-white p-2 shadow-sm">
              <div class="mb-2 flex items-center gap-3 rounded-xl bg-avocado-50/70 px-3 py-3">
                <span class="grid h-11 w-11 shrink-0 place-items-center overflow-hidden rounded-full bg-gradient-to-br from-avocado-100 to-cream-100 text-sm font-black text-avocado-900">
                  <img
                    v-if="isLoggedIn && accountAvatarUrl"
                    :src="accountAvatarUrl"
                    :alt="accountName"
                    class="h-full w-full object-cover"
                  />
                  <span v-else-if="isLoggedIn">{{ accountInitial }}</span>
                  <UserRound v-else class="h-5 w-5" />
                </span>
                <span class="min-w-0">
                  <span class="block truncate text-sm font-black text-avocado-950">
                    {{ isLoggedIn ? accountName : t('userMenu.login') }}
                  </span>
                  <span class="block truncate text-xs font-bold text-slate-500">{{ accountSubtitle }}</span>
                </span>
              </div>
              <RouterLink
                :to="profilePath"
                class="flex w-full items-center gap-3 rounded-xl px-3 py-3 text-sm font-black text-avocado-900 transition hover:bg-avocado-50"
                @click="closeDrawer"
              >
                <UserRound v-if="!isLoggedIn" class="h-4.5 w-4.5" />
                <ShieldCheck v-else class="h-4.5 w-4.5" />
                {{ isLoggedIn ? t('userMenu.profile') : t('userMenu.login') }}
              </RouterLink>
              <RouterLink
                v-if="hasAdminAccess"
                to="/admin"
                class="flex w-full items-center gap-3 rounded-xl px-3 py-3 text-sm font-black text-avocado-900 transition hover:bg-avocado-50"
                @click="closeDrawer"
              >
                <LayoutDashboard class="h-4.5 w-4.5" />
                {{ t('userMenu.cms') }}
              </RouterLink>
              <button
                v-if="isLoggedIn"
                type="button"
                class="flex w-full items-center gap-3 rounded-xl px-3 py-3 text-left text-sm font-black text-red-600 transition hover:bg-red-50"
                @click="logout"
              >
                <LogOut class="h-4.5 w-4.5" />
                {{ t('userMenu.logout') }}
              </button>
            </div>
            <RouterLink
              to="/consultation"
              class="block w-full rounded-full bg-brand-forest px-4 py-3.5 text-center text-xs font-black uppercase tracking-wider text-white shadow-lg shadow-brand-forest/15 hover:bg-brand-dark transition active:scale-98"
              @click="trackEvent('click_franchise_cta', { location: 'mobile_nav' }); closeDrawer()"
            >
              {{ t('nav.consultation') }}
            </RouterLink>
          </div>

        </div>
      </aside>
    </div>
  </header>
</template>

<style scoped>
.nav-brand__logo {
  display: block;
  height: 2rem;
  width: auto;
  max-width: min(7rem, 36vw);
  object-fit: contain;
  object-position: left center;
}

.nav-brand__logo--drawer {
  height: 2.125rem;
  max-width: 62%;
}

@media (min-width: 640px) {
  .nav-brand__logo {
    height: 2.25rem;
    max-width: 7.75rem;
  }
}

@media (min-width: 1024px) {
  .nav-brand__logo {
    height: 2.375rem;
    max-width: 8.25rem;
  }
}
</style>
