<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'

const emit = defineEmits(['navigate'])
const router = useRouter()
const { t } = useI18n()
const menuRef = ref(null)
const isOpen = ref(false)
const token = ref(localStorage.getItem('admin_token'))

const isLoggedIn = computed(() => Boolean(token.value))
const avatarLabel = computed(() => (isLoggedIn.value ? 'A' : ''))

const toggleMenu = () => {
  token.value = localStorage.getItem('admin_token')
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
  token.value = null
  closeMenu()
  emit('navigate')
  router.push('/')
}

onMounted(() => {
  document.addEventListener('click', handleDocumentClick)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleDocumentClick)
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
      <svg
        v-else
        class="h-5 w-5"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="2"
        stroke-linecap="round"
        stroke-linejoin="round"
        aria-hidden="true"
      >
        <path d="M20 21a8 8 0 0 0-16 0" />
        <circle cx="12" cy="7" r="4" />
      </svg>
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
          <button class="block w-full px-4 py-3 text-left text-sm font-bold text-slate-700 transition hover:bg-avocado-50 hover:text-avocado-800">
            {{ t('userMenu.profile') }}
          </button>
          <button
            class="block w-full px-4 py-3 text-left text-sm font-bold text-slate-700 transition hover:bg-avocado-50 hover:text-avocado-800"
            @click="navigateTo('/admin')"
          >
            {{ t('userMenu.cms') }}
          </button>
          <button class="block w-full px-4 py-3 text-left text-sm font-bold text-slate-700 transition hover:bg-avocado-50 hover:text-avocado-800">
            {{ t('userMenu.changePassword') }}
          </button>
          <div class="my-1 border-t border-slate-100"></div>
          <button
            class="block w-full px-4 py-3 text-left text-sm font-black text-red-600 transition hover:bg-red-50"
            @click="logout"
          >
            {{ t('userMenu.logout') }}
          </button>
        </template>

        <button
          v-else
          class="block w-full px-4 py-3 text-left text-sm font-black text-avocado-800 transition hover:bg-avocado-50"
          @click="navigateTo('/admin/login')"
        >
          {{ t('userMenu.login') }}
        </button>
      </div>
    </Transition>
  </div>
</template>
