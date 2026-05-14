<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { LayoutDashboard, LogOut, Settings, User, UserCircle } from 'lucide-vue-next'

const emit = defineEmits(['navigate'])
const router = useRouter()
const { t } = useI18n()
const menuRef = ref(null)
const isOpen = ref(false)
const token = ref(localStorage.getItem('admin_token'))

const isLoggedIn = computed(() => Boolean(token.value))
const avatarLabel = computed(() => (isLoggedIn.value ? 'A' : ''))

const syncAuthState = () => {
  token.value = localStorage.getItem('admin_token')
}

const toggleMenu = () => {
  syncAuthState()
  isOpen.value = !isOpen.value
}

const closeMenu = () => {
  isOpen.value = false
}

const handleDocumentClick = (event) => {
  if (!menuRef.value?.contains(event.target)) {
    closeMenu()
  }
}

const navigateTo = (path) => {
  closeMenu()
  emit('navigate')
  router.push(path)
}

const logout = () => {
  localStorage.removeItem('admin_token')
  syncAuthState()
  window.dispatchEvent(new Event('aloo-auth-change'))
  closeMenu()
  emit('navigate')
  router.push('/')
}

onMounted(() => {
  document.addEventListener('click', handleDocumentClick)
  window.addEventListener('storage', syncAuthState)
  window.addEventListener('focus', syncAuthState)
  window.addEventListener('aloo-auth-change', syncAuthState)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleDocumentClick)
  window.removeEventListener('storage', syncAuthState)
  window.removeEventListener('focus', syncAuthState)
  window.removeEventListener('aloo-auth-change', syncAuthState)
})
</script>

<template>
  <div ref="menuRef" class="relative">
    <button
      type="button"
      class="flex h-11 w-11 items-center justify-center rounded-full border border-avocado-200 bg-avocado-700 text-sm font-black text-white shadow-sm transition hover:bg-avocado-800 focus:outline-none focus:ring-4 focus:ring-avocado-100"
      :aria-expanded="isOpen"
      aria-label="User menu"
      @click.stop="toggleMenu"
    >
      <span v-if="isLoggedIn">{{ avatarLabel }}</span>
      <User
        v-else
        class="h-5 w-5"
        aria-hidden="true"
      />
    </button>

    <Transition
      enter-active-class="transition duration-150 ease-out"
      enter-from-class="-translate-y-2 opacity-0"
      enter-to-class="translate-y-0 opacity-100"
      leave-active-class="transition duration-100 ease-in"
      leave-from-class="translate-y-0 opacity-100"
      leave-to-class="-translate-y-2 opacity-0"
    >
      <div
        v-if="isOpen"
        class="absolute right-0 z-[80] mt-3 w-56 overflow-hidden rounded-xl border border-avocado-100 bg-white py-2 shadow-2xl shadow-avocado-950/10"
      >
        <template v-if="isLoggedIn">
          <button class="flex w-full items-center gap-3 px-4 py-3 text-left text-sm font-bold text-slate-700 transition hover:bg-avocado-50 hover:text-avocado-800">
            <UserCircle class="h-4 w-4 text-avocado-700" />
            <span>{{ t('userMenu.profile') }}</span>
          </button>
          <button
            class="flex w-full items-center gap-3 px-4 py-3 text-left text-sm font-bold text-slate-700 transition hover:bg-avocado-50 hover:text-avocado-800"
            @click="navigateTo('/admin')"
          >
            <LayoutDashboard class="h-4 w-4 text-avocado-700" />
            <span>{{ t('userMenu.cms') }}</span>
          </button>
          <button class="flex w-full items-center gap-3 px-4 py-3 text-left text-sm font-bold text-slate-700 transition hover:bg-avocado-50 hover:text-avocado-800">
            <Settings class="h-4 w-4 text-avocado-700" />
            <span>{{ t('userMenu.changePassword') }}</span>
          </button>
          <div class="my-1 border-t border-slate-100"></div>
          <button
            class="flex w-full items-center gap-3 px-4 py-3 text-left text-sm font-black text-red-600 transition hover:bg-red-50"
            @click="logout"
          >
            <LogOut class="h-4 w-4" />
            <span>{{ t('userMenu.logout') }}</span>
          </button>
        </template>

        <button
          v-else
          class="flex w-full items-center gap-3 px-4 py-3 text-left text-sm font-black text-avocado-800 transition hover:bg-avocado-50"
          @click="navigateTo('/admin/login')"
        >
          <User class="h-4 w-4" />
          <span>{{ t('userMenu.login') }}</span>
        </button>
      </div>
    </Transition>
  </div>
</template>
