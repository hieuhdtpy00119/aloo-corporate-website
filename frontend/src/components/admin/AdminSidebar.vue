<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  FileText,
  FolderTree,
  Handshake,
  LayoutDashboard,
  Images,
  MapPin,
  Package,
  Star,
  Users,
  UserCog,
  LogOut,
} from 'lucide-vue-next'
import { getCurrentAdmin } from '../../services/authService'

const router = useRouter()
const adminInfo = ref(null)

const menuItems = [
  { label: 'Dashboard', path: '/admin', icon: LayoutDashboard },
  { label: 'Quản lý sản phẩm', path: '/admin/products', icon: Package },
  { label: 'Cảm nhận khách hàng', path: '/admin/feedbacks', icon: Star },
  { label: 'Trang chủ CMS', path: '/admin/home-sections', icon: Images },
  { label: 'Quản lý bài viết', path: '/admin/articles', icon: FileText },
  { label: 'Quản lý danh mục', path: '/admin/categories', icon: FolderTree },
  { label: 'Hệ thống cửa hàng', path: '/admin/locations', icon: MapPin },
  { label: 'Đăng ký tư vấn', path: '/admin/registrations', icon: Users },
  { label: 'Quản lý tài khoản', path: '/admin/accounts', icon: UserCog },
  { label: 'Nội dung nhượng quyền', path: '/admin/franchise-content', icon: Handshake },
]

const isActive = (path, currentPath) => {
  if (path === '/admin') return currentPath === '/admin'
  return currentPath === path || currentPath.startsWith(`${path}/`)
}

const fetchAdminInfo = async () => {
  try {
    const { data } = await getCurrentAdmin()
    adminInfo.value = data
  } catch (error) {
    console.error('Failed to fetch admin info', error)
  }
}

const logout = () => {
  localStorage.removeItem('admin_token')
  localStorage.removeItem('admin_user')
  window.dispatchEvent(new Event('aloo-auth-change'))
  router.push('/')
}

onMounted(() => {
  fetchAdminInfo()
})
</script>

<template>
  <aside class="fixed inset-y-0 left-0 z-40 hidden h-screen w-72 bg-gradient-to-b from-brand-dark to-[#06160d] p-6 text-white shadow-2xl lg:flex flex-col justify-between border-r border-white/5 overflow-y-auto">
    <div>
      <RouterLink to="/" class="block group">
        <div class="flex items-center gap-3">
          <div class="h-9 w-9 bg-brand-lime text-brand-dark font-black rounded-xl grid place-items-center text-sm shadow-md transition group-hover:scale-105">
            A
          </div>
          <div>
            <div class="text-lg font-black tracking-tight text-white transition group-hover:text-brand-lime">ALOO Admin</div>
            <p class="text-[10px] uppercase font-bold tracking-widest text-brand-lime/85">Quản trị hệ thống</p>
          </div>
        </div>
      </RouterLink>
      
      <nav class="mt-10 space-y-1">
        <RouterLink
          v-for="item in menuItems"
          :key="item.path"
          :to="item.path"
          class="flex items-center gap-3.5 rounded-xl py-3 pr-4 transition duration-200"
          :class="
            isActive(item.path, $route.path)
              ? 'bg-white/5 text-brand-lime border-l-[3px] border-brand-lime pl-3.5 font-bold shadow-sm'
              : 'text-slate-400 hover:bg-white/5 hover:text-white border-l-[3px] border-transparent pl-3.5'
          "
        >
          <span 
            class="grid h-8 w-8 shrink-0 place-items-center rounded-lg text-current transition duration-200"
            :class="isActive(item.path, $route.path) ? 'bg-brand-lime/10 text-brand-lime' : 'bg-white/5'"
          >
            <component :is="item.icon" class="h-4.5 w-4.5" aria-hidden="true" />
          </span>
          <span class="truncate text-current text-xs font-semibold tracking-wide">{{ item.label }}</span>
        </RouterLink>
      </nav>
    </div>
  </aside>
</template>

