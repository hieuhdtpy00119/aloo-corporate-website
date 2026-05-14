<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAppStore } from '../../stores/appStore'

const route = useRoute()
const store = useAppStore()

const post = computed(() =>
  store.posts.find((item) => String(item.id) === String(route.params.id) && item.status === 'Đã đăng'),
)
</script>

<template>
  <section class="px-4 py-16 sm:px-6 lg:px-8">
    <article v-if="post" class="mx-auto max-w-3xl">
      <RouterLink to="/blog" class="text-sm font-black text-avocado-700 hover:text-avocado-900">
        ← Blog
      </RouterLink>
      <div class="mt-6 flex flex-wrap items-center gap-3">
        <span class="rounded-full bg-avocado-50 px-3 py-1 text-xs font-bold text-avocado-700">
          {{ post.category }}
        </span>
        <span class="text-sm font-semibold text-slate-500">{{ post.publishedAt }}</span>
      </div>
      <h1 class="mt-5 text-4xl font-black leading-tight text-avocado-950">{{ post.title }}</h1>
      <p class="mt-5 text-lg leading-8 text-slate-600">{{ post.excerpt }}</p>
      <img v-if="post.image" :src="post.image" :alt="post.title" class="mt-8 aspect-video w-full rounded-xl object-cover shadow-sm" />
      <div class="mt-8 rounded-xl border border-avocado-100 bg-white p-6 leading-8 text-slate-700 shadow-sm">
        {{ post.content }}
      </div>
    </article>

    <div v-else class="mx-auto max-w-xl rounded-xl border border-slate-200 bg-white p-8 text-center shadow-sm">
      <h1 class="text-2xl font-black text-avocado-950">Không tìm thấy bài viết</h1>
      <p class="mt-3 text-slate-600">Bài viết không tồn tại hoặc chưa được công khai.</p>
      <RouterLink to="/blog" class="mt-6 inline-flex rounded-full bg-avocado-700 px-5 py-3 font-black text-white hover:bg-avocado-800">
        Quay lại Blog
      </RouterLink>
    </div>
  </section>
</template>
