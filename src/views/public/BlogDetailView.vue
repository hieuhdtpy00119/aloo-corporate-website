<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAppStore } from '../../stores/appStore'

const route = useRoute()
const store = useAppStore()

const post = computed(() =>
  store.posts.find((item) => String(item.id) === String(route.params.id) && item.status === 'Đã đăng'),
)

const tocItems = computed(() => {
  if (!post.value?.content) return []
  return [...post.value.content.matchAll(/<h2[^>]*id="([^"]+)"[^>]*>(.*?)<\/h2>/g)].map((match) => ({
    id: match[1],
    title: match[2].replace(/<[^>]+>/g, ''),
  }))
})
</script>

<template>
  <section class="bg-avocado-50/60 px-4 py-10 sm:px-6 lg:px-8">
    <article v-if="post" class="mx-auto max-w-6xl">
      <RouterLink to="/blog" class="text-sm font-black text-avocado-700 hover:text-avocado-900">
        ← Blog
      </RouterLink>

      <header class="mt-6 overflow-hidden rounded-2xl bg-white shadow-sm">
        <img v-if="post.image" :src="post.image" :alt="post.title" class="aspect-[16/7] w-full object-cover" />
        <div class="p-6 lg:p-9">
          <div class="flex flex-wrap items-center gap-3">
            <span class="rounded-full bg-avocado-50 px-3 py-1 text-xs font-bold text-avocado-700">
              {{ post.category }}
            </span>
            <span class="text-sm font-semibold text-slate-500">{{ post.publishedAt }}</span>
          </div>
          <h1 class="mt-5 max-w-4xl text-4xl font-black leading-tight text-avocado-950 lg:text-5xl">{{ post.title }}</h1>
          <p class="mt-5 max-w-3xl text-lg leading-8 text-slate-600">{{ post.excerpt }}</p>
        </div>
      </header>

      <div class="mt-8 grid gap-8 lg:grid-cols-[260px_1fr]">
        <aside v-if="tocItems.length" class="h-fit rounded-xl border border-avocado-100 bg-white p-5 shadow-sm lg:sticky lg:top-24">
          <h2 class="text-sm font-black uppercase text-avocado-800">Mục lục</h2>
          <nav class="mt-4 grid gap-2">
            <a v-for="item in tocItems" :key="item.id" :href="`#${item.id}`" class="rounded-lg px-3 py-2 text-sm font-bold text-slate-600 hover:bg-avocado-50 hover:text-avocado-800">
              {{ item.title }}
            </a>
          </nav>
        </aside>

        <div>
          <div class="blog-content rounded-xl border border-avocado-100 bg-white p-6 leading-8 text-slate-700 shadow-sm lg:p-8" v-html="post.content"></div>

          <div class="mt-6 grid gap-3 rounded-2xl bg-avocado-800 p-6 text-white shadow-lg lg:grid-cols-3">
            <RouterLink to="/consultation" class="rounded-xl bg-cream-400 px-5 py-3 text-center font-black text-avocado-950 hover:bg-cream-300">
              Đăng ký tư vấn
            </RouterLink>
            <RouterLink to="/locations" class="rounded-xl bg-white/10 px-5 py-3 text-center font-black text-white ring-1 ring-white/20 hover:bg-white/15">
              Xem địa điểm
            </RouterLink>
            <RouterLink to="/products" class="rounded-xl bg-white/10 px-5 py-3 text-center font-black text-white ring-1 ring-white/20 hover:bg-white/15">
              Xem sản phẩm
            </RouterLink>
          </div>
        </div>
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

<style scoped>
.blog-content :deep(h2) {
  margin-top: 1.5rem;
  margin-bottom: 0.75rem;
  font-size: 1.5rem;
  font-weight: 900;
  color: rgb(15 43 20);
}

.blog-content :deep(h3) {
  margin-top: 1.25rem;
  margin-bottom: 0.5rem;
  font-size: 1.25rem;
  font-weight: 900;
  color: rgb(15 43 20);
}

.blog-content :deep(p) {
  margin: 0.85rem 0;
}

.blog-content :deep(ul),
.blog-content :deep(ol) {
  margin: 1rem 0;
  padding-left: 1.5rem;
}

.blog-content :deep(ul) {
  list-style: disc;
}

.blog-content :deep(ol) {
  list-style: decimal;
}

.blog-content :deep(blockquote) {
  margin: 1.25rem 0;
  border-left: 4px solid rgb(181 211 153);
  background: rgb(244 249 239);
  padding: 1rem;
  font-weight: 700;
  color: rgb(45 90 39);
}

.blog-content :deep(.article-contact) {
  margin-top: 2rem;
  border-radius: 1rem;
  background: rgb(244 249 239);
  padding: 1.5rem;
  box-shadow: inset 0 0 0 1px rgb(181 211 153 / 0.5);
}

.blog-content :deep(a) {
  font-weight: 800;
  color: rgb(45 90 39);
  text-decoration: underline;
}

.blog-content :deep(img) {
  margin: 1.5rem 0;
  width: 100%;
  border-radius: 1rem;
  object-fit: cover;
  box-shadow: 0 12px 30px rgb(15 23 42 / 0.08);
}
</style>
