<template>
  <section class="grid min-h-[70vh] place-items-center bg-avocado-50 px-4 py-16">
    <div class="w-full max-w-xl rounded-2xl border border-avocado-100 bg-white p-8 text-center shadow-sm">
      <p class="text-sm font-black uppercase tracking-[0.2em] text-avocado-600">404</p>
      <h1 class="mt-3 text-3xl font-black text-avocado-950">Không tìm thấy trang</h1>
      <p class="mt-3 text-slate-600">
        Đường dẫn này chưa có nội dung hoặc đã được chuyển sang vị trí khác.
      </p>
      <div class="mt-7 flex flex-col justify-center gap-3 sm:flex-row">
        <RouterLink
          to="/"
          class="rounded-xl border border-avocado-200 px-5 py-3 text-sm font-black text-avocado-800 transition hover:bg-avocado-50"
        >
          Về trang chủ
        </RouterLink>
        <RouterLink
          to="/admin"
          class="rounded-xl bg-avocado-800 px-5 py-3 text-sm font-black text-white transition hover:bg-avocado-900"
        >
          Về trang quản trị
        </RouterLink>
      </div>
    </div>
  </section>
</template>
