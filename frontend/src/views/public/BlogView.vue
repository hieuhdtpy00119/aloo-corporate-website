<script setup>
import { ArrowRight, CalendarDays, Clock3 } from 'lucide-vue-next'
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { useI18n } from 'vue-i18n'
import SectionTitle from '../../components/public/SectionTitle.vue'
import { useAppStore } from '../../stores/appStore'

const { t, locale } = useI18n()
const store = useAppStore()
const allCategoryLabel = computed(() => t('common.all'))
const selectedCategory = ref('')
const visibleCount = ref(9)
const publishedStatuses = new Set(['Đã đăng', 'Đã xuất bản', 'Published', 'PUBLISHED'])

const publishedPosts = computed(() =>
  store.posts
    .filter((post) => publishedStatuses.has(post.status))
    .sort((a, b) => String(b.publishedAt || b.createdAt || '').localeCompare(String(a.publishedAt || a.createdAt || ''))),
)

const publishedCategoryNames = computed(() => new Set(publishedPosts.value.map((post) => post.category).filter(Boolean)))

const categoryOptions = computed(() => [
  allCategoryLabel.value,
  ...store.categories
    .filter((category) => category.type === 'ARTICLE' && category.status === 'ACTIVE')
    .filter((category) => publishedCategoryNames.value.has(category.name))
    .sort((a, b) => a.sortOrder - b.sortOrder)
    .map((category) => category.name),
])

const latestPosts = computed(() => publishedPosts.value.slice(0, 5))
const suggestedPosts = computed(() => publishedPosts.value.slice(5, 11))

const filteredPosts = computed(() =>
  publishedPosts.value.filter(
    (post) => selectedCategory.value === allCategoryLabel.value || post.category === selectedCategory.value,
  ),
)

const leadPost = computed(() => filteredPosts.value[0] || null)
const gridPosts = computed(() => filteredPosts.value.slice(1))
const visiblePosts = computed(() => gridPosts.value.slice(0, visibleCount.value))
const hasMore = computed(() => visibleCount.value < gridPosts.value.length)
const hasLoadError = computed(() => !store.loading.posts && Boolean(store.errors.posts))
const hasNoPublishedPosts = computed(
  () => !store.loading.posts && !store.errors.posts && publishedPosts.value.length === 0,
)
const hasNoMatch = computed(
  () =>
    !store.loading.posts &&
    !store.errors.posts &&
    publishedPosts.value.length > 0 &&
    filteredPosts.value.length === 0 &&
    selectedCategory.value !== allCategoryLabel.value,
)
const showSidebar = computed(
  () => !store.loading.posts && !hasLoadError.value && !hasNoPublishedPosts.value,
)
const postLink = (post) => `/blog/${post.slug || post.id}`

const resetCategoryFilter = () => {
  selectedCategory.value = allCategoryLabel.value
}

const formatDate = (value) => {
  if (!value) return t('blog.dateUnset')
  const date = new Date(String(value).replace(' ', 'T'))
  if (Number.isNaN(date.getTime())) return value
  return new Intl.DateTimeFormat(locale.value === 'en' ? 'en-US' : 'vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
  }).format(date)
}

watch(
  allCategoryLabel,
  (label) => {
    if (!selectedCategory.value || selectedCategory.value === 'Tất cả' || selectedCategory.value === 'All') {
      selectedCategory.value = label
    }
  },
  { immediate: true },
)

watch(selectedCategory, () => {
  visibleCount.value = 9
})

onMounted(() => {
  Promise.allSettled([store.fetchCategories(), store.fetchPosts()])
})
</script>

<template>
  <div class="bg-brand-cream text-brand-dark pb-16">
    <section class="border-b border-brand-forest/10 bg-white">
      <div class="mx-auto max-w-[1240px] px-4 py-12 sm:px-6 lg:px-8 lg:py-14">
        <SectionTitle
          heading-level="h1"
          :eyebrow="t('blog.eyebrow')"
          :title="t('blog.title')"
          :description="t('blog.description')"
        />
      </div>
    </section>

    <section
      v-if="!store.loading.posts && !hasLoadError && categoryOptions.length > 1"
      class="border-b border-brand-forest/10 bg-white shadow-sm"
    >
      <div class="mx-auto flex max-w-[1240px] gap-2 overflow-x-auto px-4 py-3 sm:px-6 lg:px-8">
        <button
          v-for="category in categoryOptions"
          :key="category"
          type="button"
          class="shrink-0 rounded-full px-4 py-2 text-sm font-bold transition"
          :class="
            selectedCategory === category
              ? 'bg-avocado-700 text-white shadow-sm'
              : 'bg-brand-cream/60 text-brand-muted hover:bg-avocado-50 hover:text-avocado-700'
          "
          :aria-pressed="selectedCategory === category"
          @click="selectedCategory = category"
        >
          {{ category }}
        </button>
      </div>
    </section>

    <section class="mx-auto grid max-w-[1240px] gap-8 px-4 pt-6 sm:grid-cols-[minmax(0,1fr)_300px] sm:px-6 lg:px-8">
      <div>
        <div
          v-if="store.loading.posts"
          class="space-y-8"
          :aria-busy="true"
          :aria-label="t('blog.loading')"
        >
          <div class="overflow-hidden rounded-3xl border border-brand-forest/10 bg-white shadow-sm">
            <div class="aspect-[16/9] animate-pulse bg-slate-100"></div>
            <div class="space-y-3 p-6 lg:p-8">
              <div class="h-4 w-24 animate-pulse rounded bg-slate-100"></div>
              <div class="h-10 w-4/5 animate-pulse rounded bg-slate-100"></div>
              <div class="h-20 animate-pulse rounded bg-slate-100"></div>
            </div>
          </div>
          <div class="grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
            <div v-for="i in 6" :key="i" class="animate-pulse overflow-hidden rounded-2xl border border-brand-forest/10 bg-white shadow-sm">
              <div class="aspect-[4/3] bg-slate-100"></div>
              <div class="space-y-3 p-4">
                <div class="h-3 w-20 rounded bg-slate-100"></div>
                <div class="h-6 w-full rounded bg-slate-100"></div>
                <div class="h-4 w-24 rounded bg-slate-100"></div>
              </div>
            </div>
          </div>
        </div>

        <div
          v-else-if="hasLoadError"
          class="rounded-2xl border border-red-200 bg-red-50 p-10 text-center shadow-sm"
        >
          <h2 class="text-2xl font-black text-red-800">{{ store.errors.posts }}</h2>
          <p class="mt-2 text-sm font-semibold text-red-700/80">{{ t('blog.loadErrorHint') }}</p>
        </div>

        <div
          v-else-if="hasNoPublishedPosts"
          class="rounded-2xl border border-brand-forest/10 bg-white p-10 text-center shadow-sm"
        >
          <h2 class="text-2xl font-black text-brand-dark">{{ t('blog.emptyNoData') }}</h2>
          <p class="mt-2 text-brand-muted">{{ t('blog.emptyNoDataDesc') }}</p>
        </div>

        <div
          v-else-if="hasNoMatch"
          class="rounded-2xl border border-brand-forest/10 bg-white p-10 text-center shadow-sm"
        >
          <h2 class="text-2xl font-black text-brand-dark">{{ t('blog.emptyNoMatch') }}</h2>
          <p class="mt-2 text-brand-muted">{{ t('blog.emptyNoMatchDesc') }}</p>
          <button
            type="button"
            class="mt-6 rounded-full border border-brand-forest/20 bg-white px-6 py-3 font-black text-brand-dark shadow-sm transition hover:border-avocado-700 hover:text-avocado-700"
            @click="resetCategoryFilter"
          >
            {{ t('blog.clearFilter') }}
          </button>
        </div>

        <template v-else>
          <RouterLink
            v-if="leadPost"
            :to="postLink(leadPost)"
            class="group block overflow-hidden rounded-3xl border border-brand-forest/10 bg-white shadow-sm transition hover:-translate-y-0.5 hover:shadow-lg"
          >
            <div class="aspect-[16/9] overflow-hidden border-b border-brand-forest/10 bg-brand-cream/40">
              <img
                v-if="leadPost.image"
                :src="leadPost.image"
                :alt="leadPost.title"
                class="h-full w-full object-cover transition duration-500 group-hover:scale-105"
                loading="lazy"
                decoding="async"
              />
              <div v-else class="flex h-full w-full items-center justify-center text-3xl font-black text-avocado-700">ALOO</div>
            </div>
            <div class="p-6 lg:p-8">
              <span class="inline-block rounded-full bg-avocado-50 px-3 py-1 text-xs font-bold text-avocado-700">
                {{ leadPost.category || 'ALOO' }}
              </span>
              <h2 class="mt-3 text-2xl font-black leading-tight text-brand-dark transition group-hover:text-avocado-700 lg:text-4xl">
                {{ leadPost.title }}
              </h2>
              <p class="mt-3 line-clamp-3 text-base leading-7 text-brand-muted">
                {{ leadPost.excerpt || t('blog.excerptFallback') }}
              </p>
              <p class="mt-4 inline-flex items-center gap-2 text-xs font-bold text-brand-muted">
                <CalendarDays class="h-4 w-4" />
                {{ formatDate(leadPost.publishedAt || leadPost.createdAt) }}
              </p>
            </div>
          </RouterLink>

          <div v-if="visiblePosts.length" class="mt-8">
            <div class="mb-5 flex items-end justify-between gap-4 border-b border-brand-forest/10 pb-3">
              <div>
                <p class="text-xs font-black uppercase tracking-[0.2em] text-brand-forest">{{ t('blog.latestSection') }}</p>
                <h2 class="mt-1 text-2xl font-black text-brand-dark">{{ selectedCategory }}</h2>
              </div>
            </div>
            <div class="grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
              <RouterLink
                v-for="post in visiblePosts"
                :key="post.id"
                :to="postLink(post)"
                class="group flex flex-col overflow-hidden rounded-2xl border border-brand-forest/10 bg-white shadow-sm transition hover:-translate-y-0.5 hover:shadow-md"
              >
                <div class="aspect-[4/3] overflow-hidden bg-brand-cream/40">
                  <img
                    v-if="post.image"
                    :src="post.image"
                    :alt="post.title"
                    class="h-full w-full object-cover transition duration-500 group-hover:scale-105"
                    loading="lazy"
                    decoding="async"
                  />
                  <div v-else class="flex h-full w-full items-center justify-center text-lg font-black text-avocado-700">ALOO</div>
                </div>
                <div class="flex flex-1 flex-col p-4">
                  <span class="text-xs font-bold text-avocado-700">{{ post.category || 'ALOO' }}</span>
                  <h3 class="mt-2 line-clamp-3 flex-1 text-lg font-black leading-6 text-brand-dark group-hover:text-avocado-700">
                    {{ post.title }}
                  </h3>
                  <p class="mt-2 inline-flex items-center gap-1.5 text-xs font-bold text-brand-muted">
                    <Clock3 class="h-3.5 w-3.5" />
                    {{ formatDate(post.publishedAt || post.createdAt) }}
                  </p>
                </div>
              </RouterLink>
            </div>
          </div>

          <button
            v-if="hasMore"
            type="button"
            class="mt-8 rounded-full border border-brand-forest/20 bg-white px-6 py-3 font-black text-brand-dark shadow-sm transition hover:border-avocado-700 hover:text-avocado-700"
            @click="visibleCount += 9"
          >
            {{ t('blog.loadMore') }}
          </button>
        </template>
      </div>

      <aside v-if="showSidebar" class="grid h-fit gap-5 lg:sticky lg:top-24">
        <section v-if="suggestedPosts.length" class="overflow-hidden rounded-2xl border border-brand-forest/10 bg-white shadow-sm">
          <div class="border-b border-brand-forest/10 bg-avocado-50 px-5 py-3">
            <h2 class="text-sm font-black uppercase tracking-wide text-brand-dark">{{ t('blog.sidebarSuggested') }}</h2>
          </div>
          <div class="divide-y divide-brand-forest/5 px-5">
            <RouterLink
              v-for="(post, index) in suggestedPosts"
              :key="post.id"
              :to="postLink(post)"
              class="group grid grid-cols-[28px_1fr] gap-3 py-4"
            >
              <span class="text-xl font-black text-avocado-200">{{ index + 1 }}</span>
              <p class="line-clamp-3 font-bold leading-6 text-brand-dark group-hover:text-avocado-700">{{ post.title }}</p>
            </RouterLink>
          </div>
        </section>

        <section v-if="latestPosts.length" class="overflow-hidden rounded-2xl border border-brand-forest/10 bg-white shadow-sm">
          <div class="border-b border-brand-forest/10 bg-avocado-50 px-5 py-3">
            <h2 class="text-sm font-black uppercase tracking-wide text-brand-dark">{{ t('blog.sidebarLatest') }}</h2>
          </div>
          <div class="divide-y divide-brand-forest/5 px-5">
            <RouterLink v-for="post in latestPosts" :key="post.id" :to="postLink(post)" class="block py-4 group">
              <p class="line-clamp-2 font-bold leading-6 text-brand-dark group-hover:text-avocado-700">{{ post.title }}</p>
              <p class="mt-1 text-xs font-bold text-brand-muted">{{ formatDate(post.publishedAt || post.createdAt) }}</p>
            </RouterLink>
          </div>
        </section>

        <section class="rounded-2xl bg-avocado-950 p-6 text-white shadow-lg">
          <p class="text-xs font-black uppercase tracking-[0.2em] text-avocado-200">{{ t('blog.franchiseCtaEyebrow') }}</p>
          <h2 class="mt-3 text-2xl font-black leading-tight">{{ t('blog.franchiseCtaTitle') }}</h2>
          <p class="mt-3 text-sm leading-7 text-white/75">{{ t('blog.franchiseCtaDesc') }}</p>
          <RouterLink
            to="/consultation"
            class="mt-5 inline-flex w-full items-center justify-center gap-2 rounded-full bg-avocado-500 px-4 py-3 font-black text-avocado-950 transition hover:bg-avocado-400"
          >
            {{ t('blog.franchiseCtaButton') }}
            <ArrowRight class="h-4 w-4" />
          </RouterLink>
        </section>
      </aside>
    </section>
  </div>
</template>
