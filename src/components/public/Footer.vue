<template>
  <footer class="bg-avocado-950 text-white">
    <div class="mx-auto grid max-w-7xl gap-8 px-4 py-12 sm:px-6 lg:grid-cols-[1.4fr_1fr_1fr_1fr] lg:px-8">
      <div>
        <div class="text-2xl font-black">ALOO</div>
        <p class="mt-3 max-w-sm text-sm leading-6 text-avocado-100">
          Thương hiệu kem bơ thuần Việt, phát triển mô hình cửa hàng hiện đại, tinh gọn và phù hợp nhượng quyền.
        </p>
        <div class="mt-5 flex gap-3">
          <a href="#" class="grid h-9 w-9 place-items-center rounded-full bg-white/10 text-sm font-black hover:bg-cream-400 hover:text-avocado-950">f</a>
          <a href="#" class="grid h-9 w-9 place-items-center rounded-full bg-white/10 text-sm font-black hover:bg-cream-400 hover:text-avocado-950">ig</a>
          <a href="#" class="grid h-9 w-9 place-items-center rounded-full bg-white/10 text-sm font-black hover:bg-cream-400 hover:text-avocado-950">yt</a>
        </div>
      </div>
      <div>
        <h3 class="font-bold text-cream-300">Thương hiệu</h3>
        <div class="mt-4 grid gap-2 text-sm text-avocado-100">
          <RouterLink to="/about">Về ALOO</RouterLink>
          <RouterLink to="/products">Sản phẩm</RouterLink>
          <RouterLink to="/blog">Blog</RouterLink>
          <RouterLink to="/contact">Liên hệ</RouterLink>
        </div>
      </div>
      <div>
        <h3 class="font-bold text-cream-300">Hệ thống</h3>
        <div class="mt-4 grid gap-2 text-sm text-avocado-100">
          <RouterLink to="/locations">Địa điểm cửa hàng</RouterLink>
          <RouterLink to="/franchise">Nhượng quyền</RouterLink>
          <RouterLink to="/consultation">Đăng ký tư vấn</RouterLink>
        </div>
      </div>
      <div>
        <h3 class="font-bold text-cream-300">Liên hệ</h3>
        <div class="mt-4 space-y-2 text-sm text-avocado-100">
          <p>Hotline: 0900 888 168</p>
          <p>Email: franchise@aloo.vn</p>
          <p>Địa chỉ: TP.HCM, Việt Nam</p>
        </div>
      </div>
    </div>
    <div class="border-t border-white/10 py-4 text-center text-sm text-avocado-100">
      © 2026 ALOO. All rights reserved.
    </div>
  </footer>
</template>
