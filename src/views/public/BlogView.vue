<script setup>
import { ArrowRight, CalendarDays } from 'lucide-vue-next'
import { computed, onMounted, ref, watch } from 'vue'
import { useAppStore } from '../../stores/appStore'

const store = useAppStore()
const selectedCategory = ref('Tất cả')
const visibleCount = ref(8)
const publishedStatuses = new Set(['Đã đăng', 'Published', 'PUBLISHED'])

const publishedPosts = computed(() =>
  store.posts
    .filter((post) => publishedStatuses.has(post.status))
    .sort((a, b) => String(b.publishedAt || b.createdAt || '').localeCompare(String(a.publishedAt || a.createdAt || ''))),
)

const categoryOptions = computed(() => [
  'Tất cả',
  ...store.categories
    .filter((category) => category.type === 'ARTICLE' && category.status === 'ACTIVE')
    .sort((a, b) => a.sortOrder - b.sortOrder)
    .map((category) => category.name),
])

const leadPost = computed(() => publishedPosts.value[0] || null)
const editorPicks = computed(() => publishedPosts.value.slice(1, 4))
const latestPosts = computed(() => publishedPosts.value.slice(0, 5))

const filteredPosts = computed(() =>
  publishedPosts.value.filter(
    (post) =>
      post.id !== leadPost.value?.id &&
      (selectedCategory.value === 'Tất cả' || post.category === selectedCategory.value),
  ),
)

const visiblePosts = computed(() => filteredPosts.value.slice(0, visibleCount.value))
const hasMore = computed(() => visibleCount.value < filteredPosts.value.length)
const postLink = (post) => `/blog/${post.slug || post.id}`

const formatDate = (value) => {
  if (!value) return 'Chưa đặt ngày'
  const date = new Date(String(value).replace(' ', 'T'))
  if (Number.isNaN(date.getTime())) return value
  return new Intl.DateTimeFormat('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(date)
}

watch(selectedCategory, () => {
  visibleCount.value = 8
})

onMounted(() => {
  Promise.allSettled([store.fetchCategories(), store.fetchPosts()])
})
</script>

<template>
  <main class="bg-white text-avocado-950">
    <section class="border-b border-slate-100 px-4 py-10 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-7xl">
        <p class="text-xs font-black uppercase tracking-[0.24em] text-avocado-700">ALOO Magazine</p>
        <div class="mt-3 grid gap-5 lg:grid-cols-[1fr_360px] lg:items-end">
          <div>
            <h1 class="max-w-4xl text-4xl font-black leading-tight md:text-6xl">Tạp chí ALOO</h1>
            <p class="mt-4 max-w-2xl text-base leading-7 text-slate-600">
              Bài viết mới về sản phẩm, điểm bán, vận hành và cơ hội nhượng quyền.
            </p>
          </div>
          <div class="rounded-lg bg-[#f5f7ef] p-5">
            <p class="text-sm font-black text-avocado-900">{{ publishedPosts.length }} bài viết công khai</p>
            <p class="mt-1 text-sm leading-6 text-slate-600">Dữ liệu lấy trực tiếp từ CMS và tự cập nhật khi admin xuất bản bài mới.</p>
          </div>
        </div>
      </div>
    </section>

    <section class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
      <p v-if="store.loading.posts" class="rounded-lg border border-slate-100 bg-slate-50 px-5 py-4 text-center font-bold text-slate-600">
        Đang tải bài viết...
      </p>
      <p v-else-if="store.errors.posts" class="rounded-lg bg-red-50 px-5 py-4 text-center font-bold text-red-700">
        {{ store.errors.posts }}
      </p>

      <div v-if="leadPost && !store.loading.posts" class="grid gap-6 lg:grid-cols-[1.25fr_0.75fr]">
        <RouterLink :to="postLink(leadPost)" class="group grid overflow-hidden rounded-lg border border-slate-100 bg-white shadow-sm md:grid-cols-[0.95fr_1.05fr]">
          <img
            v-if="leadPost.image"
            :src="leadPost.image"
            :alt="leadPost.title"
            class="h-full min-h-[340px] w-full object-cover transition duration-500 group-hover:scale-[1.02]"
          />
          <div v-else class="flex min-h-[340px] items-center justify-center bg-avocado-900 text-3xl font-black text-white">ALOO</div>
          <div class="flex flex-col justify-between p-6 lg:p-8">
            <div>
              <div class="flex flex-wrap items-center gap-3">
                <span class="rounded-full bg-avocado-50 px-3 py-1 text-xs font-black text-avocado-700">{{ leadPost.category || 'ALOO' }}</span>
                <span class="inline-flex items-center gap-2 text-sm font-bold text-slate-500">
                  <CalendarDays class="h-4 w-4" />
                  {{ formatDate(leadPost.publishedAt || leadPost.createdAt) }}
                </span>
              </div>
              <h2 class="mt-5 text-3xl font-black leading-tight text-avocado-950 md:text-5xl">{{ leadPost.title }}</h2>
              <p class="mt-5 line-clamp-3 leading-8 text-slate-600">{{ leadPost.excerpt || 'Nội dung mới nhất từ ALOO Franchise CMS.' }}</p>
            </div>
            <span class="mt-8 inline-flex items-center gap-2 font-black text-avocado-800">
              Đọc bài nổi bật
              <ArrowRight class="h-4 w-4" />
            </span>
          </div>
        </RouterLink>

        <div class="rounded-lg border border-slate-100 bg-[#fbfcf7] p-5">
          <h2 class="text-lg font-black">Đáng chú ý</h2>
          <div class="mt-3 divide-y divide-slate-200/70">
            <RouterLink
              v-for="post in editorPicks"
              :key="post.id"
              :to="postLink(post)"
              class="block py-4"
            >
              <p class="text-xs font-black uppercase tracking-wide text-avocado-700">{{ post.category || 'ALOO' }}</p>
              <h3 class="mt-1 line-clamp-2 text-xl font-black leading-7 hover:text-avocado-700">{{ post.title }}</h3>
              <p class="mt-2 text-sm font-bold text-slate-400">{{ formatDate(post.publishedAt || post.createdAt) }}</p>
            </RouterLink>
          </div>
        </div>
      </div>
    </section>

    <section class="mx-auto grid max-w-7xl gap-8 px-4 pb-14 sm:px-6 lg:grid-cols-[1fr_300px] lg:px-8">
      <div>
        <nav class="flex gap-2 overflow-x-auto border-y border-slate-100 py-3">
          <button
            v-for="category in categoryOptions"
            :key="category"
            type="button"
            class="shrink-0 rounded-full px-4 py-2 text-sm font-black transition"
            :class="selectedCategory === category ? 'bg-avocado-900 text-white' : 'bg-slate-50 text-avocado-800 hover:bg-avocado-50'"
            @click="selectedCategory = category"
          >
            {{ category }}
          </button>
        </nav>

        <div v-if="visiblePosts.length" class="mt-6 divide-y divide-slate-100">
          <article v-for="post in visiblePosts" :key="post.id" class="py-6">
            <RouterLink :to="postLink(post)" class="group grid gap-5 md:grid-cols-[220px_1fr] md:items-center">
              <img v-if="post.image" :src="post.image" :alt="post.title" class="h-44 w-full rounded-lg object-cover md:h-36" />
              <div v-else class="flex h-44 w-full items-center justify-center rounded-lg bg-avocado-900 text-2xl font-black text-white md:h-36">ALOO</div>
              <div>
                <div class="flex flex-wrap items-center gap-3">
                  <span class="rounded-full bg-avocado-50 px-3 py-1 text-xs font-black text-avocado-700">{{ post.category || 'ALOO' }}</span>
                  <span class="text-sm font-bold text-slate-400">{{ formatDate(post.publishedAt || post.createdAt) }}</span>
                </div>
                <h2 class="mt-3 text-2xl font-black leading-8 group-hover:text-avocado-700">{{ post.title }}</h2>
                <p class="mt-2 line-clamp-2 leading-7 text-slate-600">{{ post.excerpt || 'Nội dung bài viết đang được cập nhật.' }}</p>
              </div>
            </RouterLink>
          </article>
        </div>

        <div v-else-if="!store.loading.posts && !store.errors.posts" class="mt-8 rounded-lg border border-slate-100 bg-slate-50 p-10 text-center">
          <h2 class="text-2xl font-black">Chưa có bài viết phù hợp</h2>
          <p class="mt-2 text-slate-600">Danh mục này chưa có bài viết công khai.</p>
        </div>

        <button
          v-if="hasMore"
          type="button"
          class="mt-8 rounded-lg border border-avocado-200 bg-white px-6 py-3 font-black text-avocado-900 hover:bg-avocado-50"
          @click="visibleCount += 8"
        >
          Xem thêm bài viết
        </button>
      </div>

      <aside class="h-fit rounded-lg border border-slate-100 bg-[#fbfcf7] p-5 lg:sticky lg:top-24">
        <h2 class="text-lg font-black">Bài mới</h2>
        <div class="mt-3 divide-y divide-slate-200/70">
          <RouterLink v-for="post in latestPosts" :key="post.id" :to="postLink(post)" class="block py-3">
            <p class="line-clamp-2 font-black leading-6 hover:text-avocado-700">{{ post.title }}</p>
            <p class="mt-1 text-xs font-bold text-slate-400">{{ formatDate(post.publishedAt || post.createdAt) }}</p>
          </RouterLink>
        </div>
        <RouterLink to="/consultation" class="mt-5 inline-flex w-full items-center justify-center gap-2 rounded-lg bg-avocado-900 px-4 py-3 font-black text-white hover:bg-avocado-800">
          Tư vấn nhượng quyền
          <ArrowRight class="h-4 w-4" />
        </RouterLink>
      </aside>
    </section>
  </main>
</template>
