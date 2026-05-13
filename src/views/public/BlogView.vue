<script setup>
import SectionTitle from '../../components/public/SectionTitle.vue'
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const { t, tm } = useI18n()
const posts = computed(() => tm('blog.items'))
</script>

<template>
  <section class="px-4 py-16 sm:px-6 lg:px-8">
    <SectionTitle
      :eyebrow="t('blog.eyebrow')"
      :title="t('blog.title')"
      :description="t('blog.description')"
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
              'bg-emerald-50 text-emerald-700': post.status === 'Đã đăng' || post.status === 'Published',
              'bg-amber-50 text-amber-700': ['Bản nháp', 'Lên lịch', 'Draft', 'Scheduled'].includes(post.status),
              'bg-slate-100 text-slate-600': post.status === 'Ẩn' || post.status === 'Hidden',
            }"
          >
            {{ post.status }}
          </span>
        </div>
        <h3 class="text-xl font-black leading-7 text-avocado-950">{{ post.title }}</h3>
        <p class="mt-4 text-sm font-semibold text-slate-500">{{ t('common.publishedAt') }}: {{ post.publishedAt }}</p>
        <p class="mt-4 leading-7 text-slate-600">
          {{ t('blog.sampleDescription') }}
        </p>
      </article>
    </div>
  </section>
</template>
