<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ChevronDown, ChevronUp, Home, LogOut, Menu, UserRound } from 'lucide-vue-next'
import AdminBreadcrumb from './AdminBreadcrumb.vue'
import AdminLocaleSwitcher from './AdminLocaleSwitcher.vue'
import { clearAuthSession, getCurrentAdmin } from '../../services/authService'
import { resolveBackendAssetUrl } from '../../services/cmsService'
import { repairUtf8Mojibake } from '../../utils/textEncoding'

defineEmits(['toggle-sidebar'])

const router = useRouter()
const { t } = useI18n()
const adminInfo = ref(null)
const isAccountMenuOpen = ref(false)
const menuRef = ref(null)
const brokenAvatar = ref(false)

const readStoredAdmin = () => {
  try {
    return JSON.parse(localStorage.getItem('admin_user') || 'null')
  } catch {
    return null
  }
}

const accountInitials = computed(() => {
  const name = String(adminInfo.value?.fullName || '').trim()
  const parts = name.split(/\s+/).filter(Boolean)
  if (!parts.length) return 'A'
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase()
  return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase()
})

const accountAvatarUrl = computed(() => {
  if (brokenAvatar.value) return ''
  const raw = adminInfo.value?.avatarUrl || adminInfo.value?.avatar || ''
  return raw ? resolveBackendAssetUrl(raw) : ''
})

const accountDisplayName = computed(() => adminInfo.value?.fullName || t('admin.shell.adminFallbackName'))

const accountRoleLabel = computed(() => {
  const profile = String(adminInfo.value?.adminProfile || 'FULL').toUpperCase()
  if (t(`admin.roles.${profile}`) !== `admin.roles.${profile}`) {
    return t(`admin.roles.${profile}`)
  }
  return t('admin.shell.brandSubtitle')
})

const fetchAdminInfo = async () => {
  try {
    const { data } = await getCurrentAdmin()
    adminInfo.value = {
      ...data,
      fullName: repairUtf8Mojibake(data.fullName),
    }
    brokenAvatar.value = false
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
  adminInfo.value = readStoredAdmin()
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
  <header class="sticky top-0 z-30 flex items-center justify-between gap-3 border-b border-slate-100 bg-white/80 backdrop-blur-md px-4 py-3 sm:px-6">
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
        class="admin-account-trigger"
        aria-haspopup="menu"
        :aria-expanded="isAccountMenuOpen"
        :aria-label="accountDisplayName"
        @click="isAccountMenuOpen = !isAccountMenuOpen"
      >
        <span class="admin-account-trigger__ring">
          <span class="admin-account-trigger__avatar">
            <img
              v-if="accountAvatarUrl"
              :src="accountAvatarUrl"
              :alt="accountDisplayName"
              class="admin-account-trigger__avatar-img"
              @error="brokenAvatar = true"
            />
            <span v-else class="admin-account-trigger__avatar-fallback">{{ accountInitials }}</span>
          </span>
          <span class="admin-account-trigger__badge" aria-hidden="true">
            <ChevronUp v-if="isAccountMenuOpen" class="h-3 w-3" />
            <ChevronDown v-else class="h-3 w-3" />
          </span>
        </span>
      </button>

      <div
        v-if="isAccountMenuOpen"
        class="admin-account-menu"
        role="menu"
      >
        <div class="admin-account-menu__profile">
          <span class="admin-account-menu__avatar">
            <img
              v-if="accountAvatarUrl"
              :src="accountAvatarUrl"
              :alt="accountDisplayName"
              class="admin-account-menu__avatar-img"
            />
            <span v-else class="admin-account-menu__avatar-fallback">{{ accountInitials }}</span>
          </span>
          <div class="min-w-0">
            <p class="admin-account-menu__name">{{ accountDisplayName }}</p>
            <p class="admin-account-menu__role">{{ accountRoleLabel }}</p>
          </div>
        </div>

        <nav class="admin-account-menu__nav">
          <RouterLink
            to="/admin/profile"
            class="admin-account-menu__link"
            role="menuitem"
            @click="closeAccountMenu"
          >
            <span class="admin-account-menu__icon">
              <UserRound class="h-[18px] w-[18px]" />
            </span>
            {{ t('admin.shell.personalInfo') }}
          </RouterLink>
          <RouterLink
            to="/"
            class="admin-account-menu__link"
            role="menuitem"
            @click="closeAccountMenu"
          >
            <span class="admin-account-menu__icon">
              <Home class="h-[18px] w-[18px]" />
            </span>
            {{ t('admin.shell.viewWebsite') }}
          </RouterLink>
        </nav>

        <button
          type="button"
          class="admin-account-menu__logout"
          role="menuitem"
          @click="logout"
        >
          <LogOut class="h-[18px] w-[18px] shrink-0" />
          {{ t('admin.shell.logout') }}
        </button>
      </div>
    </div>
  </header>
</template>

<style scoped>
.admin-account-trigger {
  position: relative;
  display: inline-flex;
  border: 0;
  background: transparent;
  padding: 0;
  cursor: pointer;
}

.admin-account-trigger__ring {
  position: relative;
  display: grid;
  place-items: center;
  width: 44px;
  height: 44px;
  border-radius: 9999px;
  background: #eef6e4;
  box-shadow: inset 0 0 0 2px #d7ebc8;
}

.admin-account-trigger__avatar,
.admin-account-menu__avatar {
  display: grid;
  overflow: hidden;
  border-radius: 9999px;
}

.admin-account-trigger__avatar {
  width: 38px;
  height: 38px;
}

.admin-account-menu__avatar {
  width: 48px;
  height: 48px;
  flex-shrink: 0;
}

.admin-account-trigger__avatar-img,
.admin-account-menu__avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.admin-account-trigger__avatar-fallback,
.admin-account-menu__avatar-fallback {
  display: grid;
  width: 100%;
  height: 100%;
  place-items: center;
  background: linear-gradient(145deg, #f3fae8 0%, #e2f0d4 100%);
  color: #0d5f2c;
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.02em;
}

.admin-account-trigger__badge {
  position: absolute;
  right: -1px;
  bottom: -1px;
  display: grid;
  width: 18px;
  height: 18px;
  place-items: center;
  border-radius: 9999px;
  border: 2px solid #fff;
  background: #fff;
  color: #5f8f57;
  box-shadow: 0 2px 6px rgba(15, 23, 42, 0.12);
}

.admin-account-menu {
  position: absolute;
  right: 0;
  top: calc(100% + 0.65rem);
  z-index: 50;
  width: min(19rem, calc(100vw - 2rem));
  overflow: hidden;
  border-radius: 22px;
  border: 1px solid #edf2f7;
  background: #fff;
  padding: 14px;
  box-shadow: 0 18px 40px rgba(15, 23, 42, 0.12);
}

.admin-account-menu__profile {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 4px 4px 14px;
}

.admin-account-menu__name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  font-size: 15px;
  font-weight: 800;
  line-height: 1.25;
  color: #0d2f1b;
}

.admin-account-menu__role {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-top: 3px;
  font-size: 12px;
  font-weight: 600;
  color: #7b8798;
}

.admin-account-menu__nav {
  display: grid;
  gap: 4px;
  padding-bottom: 10px;
}

.admin-account-menu__link {
  display: flex;
  align-items: center;
  gap: 12px;
  border-radius: 14px;
  padding: 10px 12px;
  font-size: 14px;
  font-weight: 700;
  color: #243447;
  text-decoration: none;
  transition: background-color 0.15s ease;
}

.admin-account-menu__link:hover {
  background: #f7faf5;
}

.admin-account-menu__icon {
  display: grid;
  width: 34px;
  height: 34px;
  flex-shrink: 0;
  place-items: center;
  border-radius: 9999px;
  background: #f3fae8;
  color: #1f6b3b;
}

.admin-account-menu__logout {
  display: flex;
  width: 100%;
  align-items: center;
  justify-content: center;
  gap: 10px;
  border: 0;
  border-radius: 16px;
  background: #fff7f7;
  padding: 12px 14px;
  font-size: 14px;
  font-weight: 800;
  color: #d94848;
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.admin-account-menu__logout:hover {
  background: #feecec;
}
</style>
