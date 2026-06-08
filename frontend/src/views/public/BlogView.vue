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
  <main class="bg-[#FAFCF7] text-avocado-950">
    <section class="border-b border-avocado-100 bg-white">
      <div class="mx-auto grid max-w-7xl gap-8 px-4 py-10 sm:px-6 lg:grid-cols-[minmax(0,0.9fr)_minmax(280px,0.55fr)] lg:px-8">
        <div>
          <p class="text-sm font-black uppercase text-avocado-700">Blog ALOO</p>
          <h1 class="mt-3 max-w-3xl text-4xl font-black leading-tight text-avocado-950 sm:text-5xl">
            Câu chuyện thương hiệu, menu và vận hành cửa hàng
          </h1>
          <p class="mt-5 max-w-2xl text-base leading-8 text-slate-600">
            Cập nhật góc nhìn về kem bơ, nhượng quyền và kinh nghiệm xây dựng điểm bán ALOO.
          </p>
        </div>
        <div class="hidden border-l border-avocado-100 pl-8 lg:block">
          <p class="text-sm font-bold text-slate-500">Chuyên mục nổi bật</p>
          <div class="mt-4 flex flex-wrap gap-2">
            <button
              v-for="category in categoryOptions.slice(0, 5)"
              :key="`hero-${category}`"
              type="button"
              class="border px-3.5 py-2 text-sm font-black transition"
              :class="selectedCategory === category ? 'border-avocado-900 bg-avocado-900 text-white' : 'border-avocado-100 bg-avocado-50 text-avocado-900 hover:border-avocado-300 hover:bg-white'"
              @click="selectedCategory = category"
            >
              {{ category }}
            </button>
          </div>
        </div>
      </div>
    </section>

    <section class="mx-auto max-w-7xl px-4 pt-6 sm:px-6 lg:px-8">
      <p v-if="store.loading.posts" class="border border-slate-100 bg-white px-5 py-4 text-center font-bold text-slate-600 shadow-sm">
        Đang tải bài viết...
      </p>
      <p v-else-if="store.errors.posts" class="bg-red-50 px-5 py-4 text-center font-bold text-red-700">
        {{ store.errors.posts }}
      </p>
    </section>

    <section class="mx-auto grid max-w-7xl gap-8 px-4 pb-16 sm:px-6 lg:grid-cols-[minmax(0,1fr)_320px] lg:px-8">
      <div>
        <nav class="mb-6 flex gap-2 overflow-x-auto border-b border-avocado-100 bg-transparent pb-3">
          <button
            v-for="category in categoryOptions"
            :key="category"
            type="button"
            class="shrink-0 border px-4 py-2 text-sm font-black transition"
            :class="selectedCategory === category ? 'border-avocado-900 bg-avocado-900 text-white shadow-sm' : 'border-avocado-100 bg-white text-avocado-800 hover:border-avocado-200 hover:bg-avocado-50'"
            @click="selectedCategory = category"
          >
            {{ category }}
          </button>
        </nav>

        <div v-if="leadPost" class="grid gap-6">
          <RouterLink
            :to="postLink(leadPost)"
            class="group grid overflow-hidden border border-avocado-100 bg-white shadow-sm transition hover:-translate-y-0.5 hover:shadow-md lg:grid-cols-[minmax(0,1.1fr)_minmax(320px,0.9fr)]"
          >
            <div class="relative aspect-[16/10] overflow-hidden bg-avocado-900 lg:aspect-auto">
              <img v-if="leadPost.image" :src="leadPost.image" :alt="leadPost.title" class="h-full w-full object-cover transition duration-500 group-hover:scale-105" />
              <div v-else class="flex h-full w-full items-center justify-center text-2xl font-black text-white">ALOO</div>
            </div>
            <div class="flex flex-col justify-center p-6 sm:p-8">
              <div class="flex flex-wrap items-center gap-3">
                <span class="text-xs font-black uppercase tracking-wide text-avocado-700">{{ leadPost.category || 'ALOO' }}</span>
                <span class="inline-flex items-center gap-1.5 text-xs font-bold text-slate-400">
                  <CalendarDays class="h-4 w-4" />
                  {{ formatDate(leadPost.publishedAt || leadPost.createdAt) }}
                </span>
              </div>
              <h2 class="mt-3 text-3xl font-black leading-tight text-avocado-950 group-hover:text-avocado-700 lg:text-4xl">{{ leadPost.title }}</h2>
              <p class="mt-3 line-clamp-3 text-base leading-8 text-slate-600">{{ leadPost.excerpt || 'Nội dung bài viết đang được cập nhật.' }}</p>
              <span class="mt-6 inline-flex w-fit items-center gap-2 bg-avocado-50 px-4 py-2 text-sm font-black text-avocado-900 group-hover:bg-avocado-100">
                Đọc bài viết
                <ArrowRight class="h-4 w-4" />
              </span>
            </div>
          </RouterLink>

          <div v-if="spotlightPosts.length" class="grid gap-4 sm:grid-cols-2">
            <RouterLink
              v-for="post in spotlightPosts"
              :key="post.id"
              :to="postLink(post)"
              class="group grid gap-3 border border-avocado-100 bg-white p-3 shadow-sm transition hover:-translate-y-0.5 hover:shadow-md sm:grid-cols-[120px_1fr]"
            >
              <div class="aspect-[4/3] overflow-hidden bg-avocado-900">
                <img v-if="post.image" :src="post.image" :alt="post.title" class="h-full w-full object-cover transition duration-500 group-hover:scale-105" />
                <div v-else class="flex h-full min-h-24 items-center justify-center text-lg font-black text-white">ALOO</div>
              </div>
              <div class="self-center">
                <p class="text-xs font-black uppercase tracking-wide text-avocado-700">{{ post.category || 'ALOO' }}</p>
                <h3 class="mt-1 line-clamp-2 text-lg font-black leading-6 group-hover:text-avocado-700">{{ post.title }}</h3>
                <p class="mt-2 text-xs font-bold text-slate-400">{{ formatDate(post.publishedAt || post.createdAt) }}</p>
              </div>
            </RouterLink>
          </div>
        </div>

        <div v-if="visiblePosts.length" class="mt-8">
          <div class="mb-4 flex items-end justify-between gap-4 border-b border-avocado-100 pb-3">
            <div>
              <p class="text-sm font-black uppercase text-avocado-700">Tất cả bài viết</p>
              <h2 class="mt-1 text-2xl font-black text-avocado-950">{{ selectedCategory }}</h2>
            </div>
          </div>
          <div class="grid gap-5 sm:grid-cols-2">
            <article v-for="post in visiblePosts" :key="post.id">
              <RouterLink :to="postLink(post)" class="group flex h-full flex-col overflow-hidden border border-avocado-100 bg-white shadow-sm transition hover:-translate-y-0.5 hover:shadow-md">
                <div class="aspect-[16/10] overflow-hidden bg-avocado-900">
                <img v-if="post.image" :src="post.image" :alt="post.title" class="h-full w-full object-cover transition duration-500 group-hover:scale-105" />
                <div v-else class="flex h-full w-full items-center justify-center text-xl font-black text-white">ALOO</div>
              </div>
              <div class="flex flex-1 flex-col p-4">
                <div class="flex flex-wrap items-center gap-3">
                  <span class="text-xs font-black uppercase tracking-wide text-avocado-700">{{ post.category || 'ALOO' }}</span>
                  <span class="inline-flex items-center gap-1.5 text-xs font-bold text-slate-400">
                <CalendarDays class="h-4 w-4" />
                {{ formatDate(post.publishedAt || post.createdAt) }}
              </span>
                </div>
                <h2 class="mt-2 line-clamp-2 text-xl font-black leading-7 text-avocado-950 group-hover:text-avocado-700">{{ post.title }}</h2>
                <p class="mt-2 line-clamp-3 text-sm leading-7 text-slate-600">{{ post.excerpt || 'Nội dung bài viết đang được cập nhật.' }}</p>
              </div>
            </RouterLink>
          </article>
          </div>
        </div>

        <div v-else-if="!leadPost && !store.loading.posts && !store.errors.posts" class="mt-8 border border-slate-100 bg-slate-50 p-10 text-center">
          <h2 class="text-2xl font-black">Chưa có bài viết phù hợp</h2>
          <p class="mt-2 text-slate-600">Danh mục này chưa có bài viết công khai.</p>
        </div>

        <button
          v-if="hasMore"
          type="button"
          class="mt-8 border border-avocado-200 bg-white px-6 py-3 font-black text-avocado-900 shadow-sm hover:bg-avocado-50"
          @click="visibleCount += 8"
        >
          Xem thêm bài viết
        </button>
      </div>

      <aside class="grid h-fit gap-5 lg:sticky lg:top-24">
        <section class="border border-avocado-100 bg-white p-5 shadow-sm">
          <h2 class="text-lg font-black uppercase tracking-wide text-avocado-950">Bài mới</h2>
          <div class="mt-3 divide-y divide-slate-200">
            <RouterLink v-for="post in latestPosts" :key="post.id" :to="postLink(post)" class="block py-4 group">
              <p class="line-clamp-2 font-black leading-6 group-hover:text-avocado-700">{{ post.title }}</p>
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
