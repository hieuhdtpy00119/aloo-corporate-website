<script setup>
import {
  FileText,
  FolderTree,
  Handshake,
  LayoutDashboard,
  MapPin,
  Package,
  Users,
} from 'lucide-vue-next'

const menuItems = [
  { label: 'Dashboard', path: '/admin', icon: LayoutDashboard },
  { label: 'Quản lý sản phẩm', path: '/admin/products', icon: Package },
  { label: 'Quản lý bài viết', path: '/admin/articles', icon: FileText },
  { label: 'Quản lý danh mục', path: '/admin/categories', icon: FolderTree },
  { label: 'Quản lý địa điểm', path: '/admin/locations', icon: MapPin },
  { label: 'Đăng ký tư vấn', path: '/admin/registrations', icon: Users },
  { label: 'Nội dung nhượng quyền', path: '/admin/franchise-content', icon: Handshake },
]

const isActive = (path, currentPath) => {
  if (path === '/admin') return currentPath === '/admin'
  return currentPath === path || currentPath.startsWith(`${path}/`)
}
</script>

<template>
  <aside class="fixed inset-y-0 left-0 z-40 hidden min-h-screen w-72 shrink-0 bg-gradient-to-b from-avocado-950 to-[#0e1b0d] p-6 text-white shadow-xl lg:block border-r border-white/5">
    <RouterLink to="/" class="block group">
      <div class="flex items-center gap-2">
        <div class="h-9 w-9 bg-cream-400 text-avocado-950 font-black rounded-xl grid place-items-center text-sm shadow-md">
          A
        </div>
        <div>
          <div class="text-xl font-bold tracking-tight text-white transition group-hover:text-cream-300">ALOO Admin</div>
          <p class="text-[10px] uppercase font-bold tracking-widest text-cream-400/80">Quản trị hệ thống</p>
        </div>
      </div>
    </RouterLink>
    
    <nav class="mt-12 space-y-1.5">
      <RouterLink
        v-for="item in menuItems"
        :key="item.path"
        :to="item.path"
        class="flex items-center gap-3.5 rounded-2xl px-4 py-3 text-sm font-semibold transition duration-200"
        :class="
          isActive(item.path, $route.path)
            ? 'bg-cream-400 text-avocado-950 shadow-lg shadow-cream-400/10'
            : 'text-avocado-100/80 hover:bg-white/5 hover:text-white'
        "
      >
        <span 
          class="grid h-8 w-8 shrink-0 place-items-center rounded-xl text-current transition duration-200"
          :class="isActive(item.path, $route.path) ? 'bg-avocado-950/10' : 'bg-white/5'"
        >
          <component :is="item.icon" class="h-4.5 w-4.5" aria-hidden="true" />
        </span>
        <span class="truncate text-current font-medium">{{ item.label }}</span>
      </RouterLink>
    </nav>
  </aside>
</template>
