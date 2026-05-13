<script setup>
const links = [
  { label: 'Dashboard', to: '/admin', icon: '▦' },
  { label: 'Quản lý sản phẩm', to: '/admin/products', icon: '□' },
  { label: 'Quản lý banner', to: '/admin/banners', icon: '▣' },
  { label: 'Quản lý bài viết', to: '/admin/posts', icon: '☰' },
  { label: 'Quản lý địa điểm', to: '/admin/locations', icon: '⌖' },
  { label: 'Đăng ký tư vấn', to: '/admin/registrations', icon: '◇' },
  { label: 'Nội dung nhượng quyền', to: '/admin/franchise-content', icon: '✎' },
]
</script>

<template>
  <aside class="hidden min-h-screen w-72 bg-gradient-to-b from-avocado-950 via-avocado-900 to-avocado-800 p-6 text-white shadow-xl lg:block">
    <RouterLink to="/" class="block">
      <div class="text-2xl font-black">ALOO Admin</div>
      <p class="mt-1 text-sm text-avocado-100">Quản trị thương hiệu</p>
    </RouterLink>
    <nav class="mt-10 grid gap-2">
      <RouterLink
        v-for="link in links"
        :key="link.to"
        :to="link.to"
        class="flex items-center gap-3 rounded-xl px-4 py-3 font-semibold transition duration-200"
        :class="
          $route.path === link.to
            ? 'bg-avocado-600 text-white shadow-lg shadow-avocado-950/20'
            : 'text-avocado-100/85 hover:bg-avocado-700/50 hover:text-white'
        "
      >
        <span class="grid h-8 w-8 place-items-center rounded-lg bg-white/10 text-sm text-current">
          {{ link.icon }}
        </span>
        <span>{{ link.label }}</span>
      </RouterLink>
    </nav>
  </aside>
</template>
