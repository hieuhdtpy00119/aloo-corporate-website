<script setup>
import { trackEvent } from '../../services/analyticsService'
</script>

<template>
  <footer class="bg-gradient-to-br from-brand-dark via-brand-dark/95 to-brand-dark/90 text-white/90 border-t border-brand-forest/10 relative overflow-hidden">
    <!-- Subtle top decorative glowing border -->
    <div class="absolute top-0 left-0 right-0 h-[2px] bg-gradient-to-r from-transparent via-brand-lime/30 to-transparent"></div>

    <div class="mx-auto grid max-w-[1280px] gap-12 px-4 py-20 sm:px-6 lg:grid-cols-[1.6fr_1fr_1fr_1fr] lg:px-8 relative z-10">
      <div class="space-y-6">
        <RouterLink to="/" class="inline-block transition transform hover:scale-[1.02]">
          <img src="/logo-aloo.png" alt="ALOO Kem Bơ" class="h-12 w-auto max-w-[190px] object-contain object-left brightness-110" width="220" height="56" />
        </RouterLink>
        <p class="max-w-sm text-sm leading-7 text-white/70">
          Thương hiệu kem bơ thuần Việt, kết hợp nguồn nông sản sạch với công nghệ hiện đại. Mang trải nghiệm kem tươi ngon lành và cơ hội nhượng quyền phát triển tới mọi miền.
        </p>
        <div class="flex gap-3">
          <a href="#" class="grid h-10 w-10 place-items-center rounded-full bg-white/5 border border-white/10 text-sm font-semibold transition duration-300 hover:bg-brand-lime hover:text-brand-dark hover:border-brand-lime hover:shadow-lg hover:shadow-brand-lime/20" @click.prevent="trackEvent('click_social_link', { channel: 'facebook' })">f</a>
          <a href="#" class="grid h-10 w-10 place-items-center rounded-full bg-white/5 border border-white/10 text-sm font-semibold transition duration-300 hover:bg-brand-lime hover:text-brand-dark hover:border-brand-lime hover:shadow-lg hover:shadow-brand-lime/20" @click.prevent="trackEvent('click_social_link', { channel: 'instagram' })">ig</a>
          <a href="#" class="grid h-10 w-10 place-items-center rounded-full bg-white/5 border border-white/10 text-sm font-semibold transition duration-300 hover:bg-brand-lime hover:text-brand-dark hover:border-brand-lime hover:shadow-lg hover:shadow-brand-lime/20" @click.prevent="trackEvent('click_social_link', { channel: 'youtube' })">yt</a>
        </div>
      </div>

      <div>
        <h3 class="font-black text-xs uppercase tracking-[0.15em] text-brand-sand">Thương hiệu</h3>
        <div class="mt-6 grid gap-3.5 text-sm">
          <RouterLink to="/products" class="text-white/70 transition-all duration-300 hover:text-brand-lime hover:translate-x-1">Sản phẩm & Menu</RouterLink>
          <RouterLink to="/about" class="text-white/70 transition-all duration-300 hover:text-brand-lime hover:translate-x-1">Câu chuyện của chúng tôi</RouterLink>
          <RouterLink to="/locations" class="text-white/70 transition-all duration-300 hover:text-brand-lime hover:translate-x-1">Tìm cửa hàng</RouterLink>
          <RouterLink to="/franchise" class="text-white/70 transition-all duration-300 hover:text-brand-lime hover:translate-x-1">Nhượng quyền</RouterLink>
        </div>
      </div>

      <div>
        <h3 class="font-black text-xs uppercase tracking-[0.15em] text-brand-sand">Đồng hành</h3>
        <div class="mt-6 grid gap-3.5 text-sm">
          <RouterLink to="/consultation" class="text-white/70 transition-all duration-300 hover:text-brand-lime hover:translate-x-1 font-semibold text-brand-lime">Đăng ký tư vấn</RouterLink>
          <RouterLink to="/contact" class="text-white/70 transition-all duration-300 hover:text-brand-lime hover:translate-x-1">Liên hệ trực tiếp</RouterLink>
          <RouterLink to="/blog" class="text-white/70 transition-all duration-300 hover:text-brand-lime hover:translate-x-1">Tin tức & Khuyến mãi</RouterLink>
        </div>
      </div>

      <div>
        <h3 class="font-black text-xs uppercase tracking-[0.15em] text-brand-sand">Thông tin liên hệ</h3>
        <div class="mt-6 space-y-4 text-sm text-white/70">
          <p class="flex items-center gap-2">
            <span class="text-brand-sand font-semibold">Hotline:</span> 0900 888 168
          </p>
          <p class="flex items-center gap-2">
            <span class="text-brand-sand font-semibold">Email:</span> franchise@aloo.vn
          </p>
          <p class="flex items-center gap-2 flex-wrap">
            <span class="text-brand-sand font-semibold">Địa chỉ:</span> TP. Hồ Chí Minh, Việt Nam
          </p>
        </div>
      </div>
    </div>

    <div class="border-t border-white/5 py-6 text-center text-xs text-white/40 bg-black/10 relative z-10">
      <div class="mx-auto max-w-[1280px] px-4 flex flex-col gap-3 sm:flex-row sm:justify-between items-center">
        <p>© 2026 ALOO. Bảo lưu mọi quyền.</p>
        <p class="text-white/30 tracking-wider">Kem Bơ Thuần Việt — Sạch, Lành & Đậm Vị</p>
      </div>
    </div>
  </footer>
</template>
