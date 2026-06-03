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

const latestPosts = computed(() => publishedPosts.value.slice(0, 5))

const filteredPosts = computed(() =>
  publishedPosts.value.filter(
    (post) =>
      (selectedCategory.value === 'Tất cả' || post.category === selectedCategory.value),
  ),
)

const leadPost = computed(() => filteredPosts.value[0] || null)
const spotlightPosts = computed(() => filteredPosts.value.slice(1, 5))
const listPosts = computed(() => filteredPosts.value.slice(5))
const visiblePosts = computed(() => listPosts.value.slice(0, visibleCount.value))
const hasMore = computed(() => visibleCount.value < listPosts.value.length)
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
    <section class="mx-auto max-w-7xl px-4 pt-6 sm:px-6 lg:px-8">
      <p v-if="store.loading.posts" class="border border-slate-100 bg-white px-5 py-4 text-center font-bold text-slate-600 shadow-sm">
        Đang tải bài viết...
      </p>
      <p v-else-if="store.errors.posts" class="bg-red-50 px-5 py-4 text-center font-bold text-red-700">
        {{ store.errors.posts }}
      </p>
    </section>

    <section class="mx-auto grid max-w-7xl gap-6 px-4 pb-14 sm:px-6 lg:grid-cols-[minmax(0,1fr)_300px] lg:px-8">
      <div>
        <nav class="flex gap-1 overflow-x-auto border-y border-avocado-100 bg-white py-2">
          <button
            v-for="category in categoryOptions"
            :key="category"
            type="button"
            class="shrink-0 px-4 py-2 text-sm font-black transition"
            :class="selectedCategory === category ? 'bg-avocado-900 text-white' : 'text-avocado-800 hover:bg-avocado-50'"
            @click="selectedCategory = category"
          >
            {{ category }}
          </button>
        </nav>

        <div v-if="leadPost" class="mt-5 grid gap-5 border-b border-slate-100 pb-6 lg:grid-cols-[minmax(0,1.25fr)_minmax(260px,0.75fr)]">
          <RouterLink
            :to="postLink(leadPost)"
            class="group block"
          >
            <div class="relative aspect-[16/9] overflow-hidden bg-avocado-900">
              <img v-if="leadPost.image" :src="leadPost.image" :alt="leadPost.title" class="h-full w-full object-cover transition duration-500 group-hover:scale-105" />
              <div v-else class="flex h-full w-full items-center justify-center text-2xl font-black text-white">ALOO</div>
            </div>
            <div class="mt-4">
              <div class="flex flex-wrap items-center gap-3">
                <span class="text-xs font-black uppercase tracking-wide text-avocado-700">{{ leadPost.category || 'ALOO' }}</span>
                <span class="inline-flex items-center gap-1.5 text-xs font-bold text-slate-400">
                  <CalendarDays class="h-4 w-4" />
                  {{ formatDate(leadPost.publishedAt || leadPost.createdAt) }}
                </span>
              </div>
              <h2 class="mt-2 text-3xl font-black leading-tight text-avocado-950 group-hover:text-avocado-700 lg:text-4xl">{{ leadPost.title }}</h2>
              <p class="mt-3 line-clamp-3 text-base leading-8 text-slate-600">{{ leadPost.excerpt || 'Nội dung bài viết đang được cập nhật.' }}</p>
            </div>
          </RouterLink>

          <div class="divide-y divide-slate-100 border-t border-slate-100 lg:border-t-0">
            <RouterLink
              v-for="post in spotlightPosts"
              :key="post.id"
              :to="postLink(post)"
              class="grid gap-3 py-4 sm:grid-cols-[120px_1fr] lg:block"
            >
              <div class="overflow-hidden bg-avocado-900 sm:aspect-[4/3] lg:hidden">
                <img v-if="post.image" :src="post.image" :alt="post.title" class="h-full w-full object-cover" />
                <div v-else class="flex h-full min-h-24 items-center justify-center text-lg font-black text-white">ALOO</div>
              </div>
              <div>
                <p class="text-xs font-black uppercase tracking-wide text-avocado-700">{{ post.category || 'ALOO' }}</p>
                <h3 class="mt-1 line-clamp-2 text-lg font-black leading-6 hover:text-avocado-700">{{ post.title }}</h3>
                <p class="mt-2 text-xs font-bold text-slate-400">{{ formatDate(post.publishedAt || post.createdAt) }}</p>
              </div>
            </RouterLink>
          </div>
        </div>

        <div v-if="visiblePosts.length" class="divide-y divide-slate-100">
          <article v-for="post in visiblePosts" :key="post.id" class="py-5">
            <RouterLink :to="postLink(post)" class="group grid gap-4 sm:grid-cols-[180px_1fr]">
              <div class="aspect-[4/3] overflow-hidden bg-avocado-900">
                <img v-if="post.image" :src="post.image" :alt="post.title" class="h-full w-full object-cover transition duration-500 group-hover:scale-105" />
                <div v-else class="flex h-full w-full items-center justify-center text-xl font-black text-white">ALOO</div>
              </div>
              <div>
                <div class="flex flex-wrap items-center gap-3">
                  <span class="text-xs font-black uppercase tracking-wide text-avocado-700">{{ post.category || 'ALOO' }}</span>
                  <span class="inline-flex items-center gap-1.5 text-xs font-bold text-slate-400">
                <CalendarDays class="h-4 w-4" />
                {{ formatDate(post.publishedAt || post.createdAt) }}
              </span>
                </div>
                <h2 class="mt-2 line-clamp-2 text-2xl font-black leading-8 text-avocado-950 group-hover:text-avocado-700">{{ post.title }}</h2>
                <p class="mt-2 line-clamp-2 text-sm leading-7 text-slate-600">{{ post.excerpt || 'Nội dung bài viết đang được cập nhật.' }}</p>
              </div>
            </RouterLink>
          </article>
        </div>

        <div v-else-if="!leadPost && !store.loading.posts && !store.errors.posts" class="mt-8 border border-slate-100 bg-slate-50 p-10 text-center">
          <h2 class="text-2xl font-black">Chưa có bài viết phù hợp</h2>
          <p class="mt-2 text-slate-600">Danh mục này chưa có bài viết công khai.</p>
        </div>

        <button
          v-if="hasMore"
          type="button"
          class="mt-8 border border-avocado-200 bg-white px-6 py-3 font-black text-avocado-900 hover:bg-avocado-50"
          @click="visibleCount += 8"
        >
          Xem thêm bài viết
        </button>
      </div>

      <aside class="grid h-fit gap-5 lg:sticky lg:top-24">
        <section class="border-t-4 border-avocado-800 bg-slate-50 p-5">
          <h2 class="text-lg font-black uppercase tracking-wide text-avocado-950">Bài mới</h2>
          <div class="mt-3 divide-y divide-slate-200">
            <RouterLink v-for="post in latestPosts" :key="post.id" :to="postLink(post)" class="block py-4">
              <p class="line-clamp-2 font-black leading-6 hover:text-avocado-700">{{ post.title }}</p>
              <p class="mt-1 text-xs font-bold text-slate-400">{{ formatDate(post.publishedAt || post.createdAt) }}</p>
            </RouterLink>
          </div>
        </section>

        <section class="bg-avocado-950 p-6 text-white shadow-xl">
          <p class="text-xs font-black uppercase tracking-[0.2em] text-avocado-200">Nhượng quyền</p>
          <h2 class="mt-3 text-2xl font-black leading-tight">Muốn mở cửa hàng ALOO?</h2>
          <p class="mt-3 text-sm leading-7 text-white/75">Đăng ký để đội ngũ tư vấn mô hình, mặt bằng và chi phí phù hợp.</p>
          <RouterLink to="/consultation" class="mt-5 inline-flex w-full items-center justify-center gap-2 bg-avocado-500 px-4 py-3 font-black text-avocado-950 hover:bg-avocado-400">
            Tư vấn nhượng quyền
            <ArrowRight class="h-4 w-4" />
          </RouterLink>
        </section>
      </aside>
    </section>
  </main>
</template>
