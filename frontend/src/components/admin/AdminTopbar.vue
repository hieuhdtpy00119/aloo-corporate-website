<script setup>
import { onMounted, onUnmounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ChevronDown, ExternalLink, KeyRound, LogOut, Menu, ShieldCheck, UserRound } from 'lucide-vue-next'
import AdminBreadcrumb from './AdminBreadcrumb.vue'
import AdminLocaleSwitcher from './AdminLocaleSwitcher.vue'
import { clearAuthSession, getCurrentAdmin } from '../../services/authService'
import { repairUtf8Mojibake } from '../../utils/textEncoding'

defineEmits(['toggle-sidebar'])

const router = useRouter()
const { t } = useI18n()
const adminInfo = ref(null)
const isAccountMenuOpen = ref(false)
const menuRef = ref(null)

const fetchAdminInfo = async () => {
  try {
    const { data } = await getCurrentAdmin()
    adminInfo.value = {
      ...data,
      fullName: repairUtf8Mojibake(data.fullName),
    }
    localStorage.setItem('admin_user', JSON.stringify(adminInfo.value))
    window.dispatchEvent(new Event('aloo-auth-change'))
  } catch (error) {
    console.error('Failed to fetch admin info', error)
  }
}

const closeAccountMenu = () => {
  isAccountMenuOpen.value = false
}

const handlePointerDown = (event) => {
  if (!isAccountMenuOpen.value) return
  if (menuRef.value && !menuRef.value.contains(event.target)) {
    closeAccountMenu()
  }
}

const handleEscape = (event) => {
  if (event.key === 'Escape') closeAccountMenu()
}

onMounted(() => {
  fetchAdminInfo()
  document.addEventListener('pointerdown', handlePointerDown)
  document.addEventListener('keydown', handleEscape)
})

onUnmounted(() => {
  document.removeEventListener('pointerdown', handlePointerDown)
  document.removeEventListener('keydown', handleEscape)
})

const logout = () => {
  clearAuthSession()
  window.dispatchEvent(new Event('aloo-auth-change'))
  closeAccountMenu()
  router.push('/')
}
</script>

<template>
  <header class="sticky top-0 z-30 flex items-center justify-between gap-4 border-b border-slate-100 bg-white/80 backdrop-blur-md px-6 py-4">
    <div class="flex min-w-0 items-center gap-3">
      <button
        type="button"
        class="grid h-10 w-10 shrink-0 place-items-center rounded-xl border border-slate-200 bg-white text-avocado-900 shadow-sm transition hover:bg-avocado-50 lg:hidden"
        :aria-label="t('admin.shell.openMenu')"
        @click="$emit('toggle-sidebar')"
      >
        <Menu class="h-5 w-5" />
      </button>
      <div class="min-w-0">
        <p class="text-[10px] font-bold uppercase tracking-wider text-slate-400">{{ t('admin.shell.systemLabel') }}</p>
        <AdminBreadcrumb class="mt-0.5" />
      </div>
    </div>
    <div ref="menuRef" class="relative flex shrink-0 items-center gap-3">
      <AdminLocaleSwitcher />
      <button
        type="button"
        class="inline-flex items-center gap-2 rounded-full border border-avocado-200 bg-white px-2 py-2 text-avocado-950 shadow-sm transition hover:border-avocado-300 hover:bg-avocado-50 sm:gap-3 sm:px-3"
        aria-haspopup="menu"
        :aria-expanded="isAccountMenuOpen"
        @click="isAccountMenuOpen = !isAccountMenuOpen"
      >
        <span class="grid h-9 w-9 shrink-0 place-items-center rounded-full bg-brand-dark text-brand-lime">
          <ShieldCheck class="h-4.5 w-4.5" />
        </span>
        <span class="hidden min-w-0 text-left sm:block">
          <span class="block max-w-32 truncate text-xs font-black">{{ adminInfo?.fullName || t('admin.shell.adminFallbackName') }}</span>
          <span class="block max-w-32 truncate text-[11px] font-semibold text-slate-500">{{ adminInfo?.email || t('admin.shell.adminFallbackEmail') }}</span>
        </span>
        <ChevronDown class="hidden h-4 w-4 text-slate-400 transition sm:block" :class="isAccountMenuOpen ? 'rotate-180' : ''" />
      </button>

      <div
        v-if="isAccountMenuOpen"
        class="absolute right-0 top-[calc(100%+0.75rem)] z-50 w-72 overflow-hidden rounded-2xl border border-slate-200 bg-white text-slate-700 shadow-xl"
        role="menu"
      >
        <div class="border-b border-slate-100 bg-slate-50 px-4 py-3">
          <p class="truncate text-sm font-black text-avocado-950">{{ adminInfo?.fullName || t('admin.shell.adminFallbackName') }}</p>
          <p class="truncate text-xs font-semibold text-slate-500">{{ adminInfo?.email || t('admin.shell.adminFallbackEmail') }}</p>
        </div>
        <div class="p-2">
          <RouterLink
            to="/admin/profile"
            class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-bold hover:bg-avocado-50 hover:text-avocado-900"
            role="menuitem"
            @click="closeAccountMenu"
          >
            <UserRound class="h-4.5 w-4.5 text-avocado-700" />
            {{ t('admin.shell.profile') }}
          </RouterLink>
          <RouterLink
            to="/admin/profile?tab=security"
            class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-bold hover:bg-avocado-50 hover:text-avocado-900"
            role="menuitem"
            @click="closeAccountMenu"
          >
            <KeyRound class="h-4.5 w-4.5 text-avocado-700" />
            {{ t('admin.shell.security') }}
          </RouterLink>
          <RouterLink
            to="/"
            class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-bold hover:bg-avocado-50 hover:text-avocado-900"
            role="menuitem"
            @click="closeAccountMenu"
          >
            <ExternalLink class="h-4.5 w-4.5 text-avocado-700" />
            {{ t('admin.shell.viewWebsite') }}
          </RouterLink>
          <button
            type="button"
            class="mt-1 flex w-full items-center gap-3 rounded-xl border-t border-slate-100 px-3 py-2.5 text-left text-sm font-bold text-red-600 hover:bg-red-50"
            role="menuitem"
            @click="logout"
          >
            <LogOut class="h-4.5 w-4.5" />
            {{ t('admin.shell.logout') }}
          </button>
        </div>
      </div>
    </div>
  </header>
</template>
