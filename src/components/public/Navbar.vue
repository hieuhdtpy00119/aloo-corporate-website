<script setup>
import { computed, ref } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const isDrawerOpen = ref(false)

const navItems = [
  { label: 'Trang chủ', to: '/' },
  { label: 'Sản phẩm', to: '/products' },
  { label: 'Hệ thống', to: '/locations' },
  { label: 'Nhượng quyền', to: '/franchise', featured: true },
  { label: 'Về ALOO', to: '/about' },
  { label: 'Blog', to: '/blog' },
]

const isActive = (path) => route.path === path
const drawerClasses = computed(() =>
  isDrawerOpen.value ? 'translate-x-0 opacity-100' : 'translate-x-full opacity-0 pointer-events-none',
)

const closeDrawer = () => {
  isDrawerOpen.value = false
}
</script>

<template>
  <header class="sticky top-0 z-50 border-b border-avocado-100/80 bg-white/90 backdrop-blur-xl">
    <nav class="mx-auto flex max-w-7xl items-center justify-between px-4 py-3 sm:px-6 lg:px-8">
      <RouterLink to="/" class="flex items-center gap-3">
        <span class="grid h-11 w-11 place-items-center rounded-full bg-avocado-700 text-lg font-black text-white shadow-sm">A</span>
        <span>
          <span class="block text-lg font-black tracking-wide text-avocado-950">ALOO</span>
          <span class="block text-xs font-semibold text-avocado-600">Kem Bơ Thuần Việt</span>
        </span>
      </RouterLink>

      <div class="hidden items-center gap-2 lg:flex">
        <RouterLink
          v-for="item in navItems"
          :key="item.to"
          :to="item.to"
          class="rounded-full px-4 py-2 text-sm font-bold transition"
          :class="[
            isActive(item.to) ? 'bg-avocado-100 text-avocado-800' : 'text-slate-700 hover:bg-avocado-50 hover:text-avocado-700',
            item.featured && !isActive(item.to) ? 'text-avocado-800 ring-1 ring-avocado-200' : '',
          ]"
        >
          {{ item.label }}
        </RouterLink>
      </div>

      <div class="hidden items-center lg:flex">
        <RouterLink to="/consultation" class="rounded-xl bg-cream-400 px-5 py-2.5 text-sm font-black text-avocado-950 shadow-sm transition hover:bg-cream-300">
          Đăng ký tư vấn
        </RouterLink>
      </div>

      <button class="rounded-xl border border-avocado-200 px-4 py-2 text-sm font-black text-avocado-800 lg:hidden" @click="isDrawerOpen = true">
        Menu
      </button>
    </nav>

    <div v-if="isDrawerOpen" class="fixed inset-0 z-50 bg-slate-950/40 lg:hidden" @click.self="closeDrawer">
      <aside :class="['ml-auto h-full w-[min(380px,88vw)] bg-white p-5 shadow-2xl transition duration-300', drawerClasses]">
        <div class="mb-6 flex items-center justify-between">
          <div>
            <div class="text-xl font-black text-avocado-950">ALOO</div>
            <div class="text-sm font-semibold text-avocado-600">Kem Bơ Thuần Việt</div>
          </div>
          <button class="rounded-lg border border-slate-200 px-3 py-2 font-black text-slate-600" @click="closeDrawer">×</button>
        </div>

        <div class="grid gap-2">
          <RouterLink
            v-for="item in navItems"
            :key="item.to"
            :to="item.to"
            class="rounded-lg px-4 py-3 font-bold transition"
            :class="[
              isActive(item.to) ? 'bg-avocado-100 text-avocado-800' : 'text-slate-700 hover:bg-avocado-50',
              item.featured && !isActive(item.to) ? 'border border-avocado-200 text-avocado-800' : '',
            ]"
            @click="closeDrawer"
          >
            {{ item.label }}
          </RouterLink>
        </div>

        <div class="mt-6 border-t border-slate-100 pt-5">
          <RouterLink to="/consultation" class="block rounded-xl bg-cream-400 px-4 py-3 text-center font-black text-avocado-950" @click="closeDrawer">
            Đăng ký tư vấn
          </RouterLink>
        </div>
      </aside>
    </div>
  </header>
</template>
