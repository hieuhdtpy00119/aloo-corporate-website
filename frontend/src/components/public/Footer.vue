<script setup>
import { MessageCircle, Phone } from 'lucide-vue-next'
import { trackEvent } from '../../services/analyticsService'

const navigationGroups = [
  {
    title: 'Điều hướng',
    links: [
      { label: 'Trang chủ', to: '/' },
      { label: 'Hệ thống cửa hàng', to: '/locations' },
      { label: 'Sản phẩm & Menu', to: '/products' },
      { label: 'Về ALOO', to: '/about' },
      { label: 'Blog', to: '/blog' },
    ],
  },
  {
    title: 'Hợp tác',
    links: [
      { label: 'Nhượng quyền', to: '/franchise' },
      { label: 'Đăng ký tư vấn', to: '/consultation', highlight: true },
      { label: 'Liên hệ trực tiếp', to: '/contact' },
    ],
  },
]


const contactLinks = [
  {
    label: 'Hotline/Zalo',
    value: '093 511 3589',
    href: 'tel:0935113589',
    icon: Phone,
  },
  {
    label: 'Zalo tư vấn',
    value: '0984 666 077',
    href: 'tel:0984 666 077',
    icon: MessageCircle,
  },
]

const socialLinks = [
  {
    label: 'Facebook',
    channel: 'facebook',
    href: 'https://www.facebook.com/alooquynhon',
  },
  {
    label: 'Fanpage',
    channel: 'facebook_page',
    href: 'https://www.facebook.com/alookembongonquynhon',
  },
  {
    label: 'TikTok',
    channel: 'tiktok',
    href: 'https://www.tiktok.com/@alookemboxinchao',
  },
]
</script>

<template>
  <footer class="relative overflow-hidden border-t border-brand-forest/10 bg-brand-dark text-white/90">
    <div class="absolute top-0 left-0 right-0 h-[2px] bg-gradient-to-r from-transparent via-brand-lime/30 to-transparent"></div>

    <div class="relative z-10 mx-auto grid max-w-[1240px] gap-10 px-4 py-12 sm:px-6 md:grid-cols-2 lg:grid-cols-[1.35fr_0.7fr_0.7fr_0.95fr] lg:px-8">
      <div class="max-w-md space-y-5">
        <RouterLink to="/" class="inline-block transition transform hover:scale-[1.02]">
          <img
            src="/logo-aloo.png"
            alt="ALOO"
            class="h-11 w-auto max-w-[150px] object-contain object-left"
            width="180"
            height="56"
          />
        </RouterLink>
        <p class="text-sm leading-7 text-white/70">
          Kem bơ thuần Việt với nguyên liệu chọn lọc, quy trình vận hành gọn và trải nghiệm nhất quán tại từng điểm bán.
        </p>
        <div class="flex flex-wrap gap-2.5">
          <a
            v-for="link in socialLinks"
            :key="link.href"
            :href="link.href"
            target="_blank"
            rel="noreferrer"
            class="inline-flex min-h-10 items-center justify-center rounded-full border border-white/10 bg-white/5 px-4 text-xs font-bold transition duration-300 hover:border-brand-lime hover:bg-brand-lime hover:text-brand-dark hover:shadow-lg hover:shadow-brand-lime/20"
            @click="trackEvent('click_social_link', { channel: link.channel })"
          >
            {{ link.label }}
          </a>
        </div>
      </div>

      <div v-for="group in navigationGroups" :key="group.title">
        <h3 class="text-xs font-black uppercase tracking-[0.15em] text-brand-sand">{{ group.title }}</h3>
        <div class="mt-5 grid gap-3 text-sm">
          <RouterLink
            v-for="link in group.links"
            :key="link.to"
            :to="link.to"
            :class="[
              'transition-all duration-300 hover:translate-x-1 hover:text-brand-lime',
              link.highlight ? 'font-black text-brand-lime' : 'text-white/70',
            ]"
          >
            {{ link.label }}
          </RouterLink>
        </div>
      </div>

      <div>
        <h3 class="text-xs font-black uppercase tracking-[0.15em] text-brand-sand">Liên hệ</h3>
        <div class="mt-5 grid gap-3 text-sm">
          <a
            v-for="contact in contactLinks"
            :key="contact.href"
            :href="contact.href"
            class="flex items-center gap-3 text-white transition hover:text-brand-lime"
          >
            <span class="grid h-9 w-9 shrink-0 place-items-center rounded-full bg-white/5 text-brand-lime">
              <component :is="contact.icon" class="h-4 w-4" aria-hidden="true" />
            </span>
            <span>
              <span class="block text-xs font-bold uppercase tracking-[0.12em] text-white/40">{{ contact.label }}</span>
              <span class="font-black">{{ contact.value }}</span>
            </span>
          </a>
        </div>
      </div>
    </div>

    <div class="border-t border-white/5 py-6 text-center text-xs text-white/40 bg-black/10 relative z-10">
      <div class="mx-auto max-w-[1240px] px-4 flex flex-col gap-3 sm:flex-row sm:justify-between items-center">
        <p>© 2026 ALOO. Bảo lưu mọi quyền.</p>
        <p class="text-white/30 tracking-wider">Kem Bơ Thuần Việt - Sạch, Lành & Đậm Vị</p>
      </div>
    </div>
  </footer>
</template>
