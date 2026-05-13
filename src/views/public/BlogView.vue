<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
import { posts } from '../../data/mockData'
</script>

<template>
  <section class="px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      eyebrow="Blog"
      title="Tin tuc va cau chuyen ALOO"
      description="Cap nhat noi dung ve san pham, van hanh cua hang va hanh trinh phat trien thuong hieu kem bo thuan Viet."
    />

    <div class="mx-auto grid max-w-7xl gap-6 md:grid-cols-2 xl:grid-cols-4">
      <article
        v-for="post in posts"
        :key="post.id"
        class="rounded-lg border border-avocado-100 bg-white p-6 shadow-sm transition hover:-translate-y-1 hover:shadow-lg"
      >
        <div class="mb-5 flex items-center justify-between gap-3">
          <span class="rounded-full bg-avocado-50 px-3 py-1 text-xs font-bold text-avocado-700">
            {{ post.category }}
          </span>
          <span
            class="rounded-full px-3 py-1 text-xs font-bold"
            :class="{
              'bg-emerald-50 text-emerald-700': post.status === 'Đã đăng',
              'bg-amber-50 text-amber-700': post.status === 'Bản nháp' || post.status === 'Lên lịch',
              'bg-slate-100 text-slate-600': post.status === 'Ẩn',
            }"
          >
            {{ post.status }}
          </span>
        </div>
        <h3 class="text-xl font-black leading-7 text-avocado-950">{{ post.title }}</h3>
        <p class="mt-4 text-sm font-semibold text-slate-500">Ngay dang: {{ post.publishedAt }}</p>
        <p class="mt-4 leading-7 text-slate-600">
          Bai viet mau cho website ALOO, phuc vu trinh bay noi dung thuong hieu va nhuong quyen.
        </p>
      </article>
    </div>
  </section>
</template>
