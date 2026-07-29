<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import DOMPurify from 'dompurify'
import { useAppStore } from '../../stores/appStore'
import { setSeoMeta } from '../../services/seoService'
import { CalendarDays, Clock3, Facebook, Link as LinkIcon, Printer, Twitter, UserRound } from 'lucide-vue-next'

const route = useRoute()
const store = useAppStore()
const copyFeedback = ref('')
const initialLoading = ref(store.posts.length === 0)
const routeIdentifier = computed(() => String(route.params.slug || route.params.id || ''))

const post = computed(() =>
  store.posts.find(
    (item) =>
      (String(item.id) === routeIdentifier.value || item.slug === routeIdentifier.value) &&
      ['Đã đăng', 'Published', 'PUBLISHED'].includes(item.status),
  ),
)

const slugify = (value) =>
  value
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/<[^>]+>/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '')

const stripAlooChainInfo = (content) =>
  content.replace(/(?:<[^>]+>\s*)*HỆ\s*THỐNG\s*CHUỖI\s*ALOO\s*KEM\s*BƠ[\s\S]*?(?:<\/p>\s*)*$/i, '').trim()

const articleContent = computed(() => {
  if (!post.value?.content) return ''
  let index = 0
  const withAnchors = stripAlooChainInfo(post.value.content).replace(/<h2([^>]*)>(.*?)<\/h2>/g, (match, attrs, title) => {
    if (attrs.includes('id=')) return match
    index += 1
    return `<h2${attrs} id="${slugify(title) || `section-${index}`}">${title}</h2>`
  })
  return DOMPurify.sanitize(withAnchors, {
    ADD_ATTR: ['target', 'rel', 'loading', 'decoding', 'id', 'class'],
  })
})

const tocItems = computed(() => {
  if (!articleContent.value) return []
  return [...articleContent.value.matchAll(/<h2[^>]*id="([^"]+)"[^>]*>(.*?)<\/h2>/g)].map((match) => ({
    id: match[1],
    title: match[2].replace(/<[^>]+>/g, ''),
  }))
})

const readingTime = computed(() => {
  const plainText = articleContent.value.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim()
  if (!plainText) return 1
  return Math.max(1, Math.ceil(plainText.split(' ').length / 220))
})

const relatedPosts = computed(() => {
  if (!post.value) return []
  const relatedIds = post.value.relatedPostIds || []
  const publishedPosts = store.posts.filter((item) => ['Đã đăng', 'Published', 'PUBLISHED'].includes(item.status))
  const explicitRelated = publishedPosts.filter((item) => relatedIds.includes(item.id))
  if (explicitRelated.length) return explicitRelated.slice(0, 6)
  return publishedPosts
    .filter((item) => item.id !== post.value.id && item.category === post.value.category)
    .slice(0, 6)
})

const shareUrl = computed(() => (typeof window !== 'undefined' ? window.location.href : ''))

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

const shareFacebook = () => {
  window.open(`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareUrl.value)}`, '_blank', 'noopener,noreferrer')
}

const shareTwitter = () => {
  const text = post.value?.title || 'ALOO'
  window.open(
    `https://twitter.com/intent/tweet?url=${encodeURIComponent(shareUrl.value)}&text=${encodeURIComponent(text)}`,
    '_blank',
    'noopener,noreferrer',
  )
}

const copyLink = async () => {
  try {
    await navigator.clipboard.writeText(shareUrl.value)
    copyFeedback.value = 'Đã sao chép'
    setTimeout(() => {
      copyFeedback.value = ''
    }, 2000)
  } catch {
    copyFeedback.value = 'Không sao chép được'
  }
}

const printArticle = () => {
  window.print()
}

watch(
  [post, initialLoading],
  ([value, loading]) => {
    if (loading) return
    document.title = value ? `${value.seoTitle || value.title} | ALOO` : 'Không tìm thấy bài viết | ALOO'
    if (value) {
      setSeoMeta({
        title: `${value.seoTitle || value.title} | ALOO`,
        description: value.seoDescription || value.metaDescription || value.excerpt || 'Bài viết ALOO.',
        image: value.thumbnailUrl || value.image || '/logo-aloo.png',
        url: window.location.href,
        type: 'article',
      })
    }
  },
  { immediate: true },
)

onMounted(async () => {
  await Promise.allSettled([store.fetchCategories(), store.fetchPosts()])
  initialLoading.value = false
})
</script>

<template>
  <section class="min-h-[70vh] bg-[linear-gradient(180deg,#f7f2e3_0%,#fffdf7_45%,#ffffff_100%)] px-4 py-8 text-brand-dark sm:px-6 lg:px-8 lg:py-12">
    <div v-if="initialLoading" class="mx-auto max-w-[1240px] animate-pulse" aria-label="Đang tải bài viết">
      <div class="h-[430px] rounded-[2rem] bg-white/80 shadow-sm"></div>
      <div class="mx-auto mt-8 h-64 max-w-[920px] rounded-3xl bg-white/80"></div>
    </div>

    <article v-else-if="post" class="mx-auto max-w-[1240px]">
      <RouterLink to="/blog" class="mb-5 inline-flex items-center gap-2 text-sm font-black text-avocado-700 transition hover:-translate-x-1 hover:text-brand-dark">
        <span aria-hidden="true">←</span> Quay lại Blog
      </RouterLink>

      <header class="overflow-hidden rounded-[2rem] border border-brand-forest/10 bg-brand-dark shadow-[0_24px_70px_rgba(27,67,50,0.16)]">
        <div class="grid lg:grid-cols-[1.08fr_0.92fr]">
          <div class="flex flex-col justify-center px-6 py-9 text-white sm:px-10 lg:min-h-[470px] lg:px-14 lg:py-12">
            <p class="w-fit rounded-full bg-white/10 px-4 py-2 text-xs font-black uppercase tracking-[0.16em] text-avocado-100 ring-1 ring-white/15">
              {{ post.category || 'Câu chuyện ALOO' }}
            </p>
            <h1 class="mt-6 max-w-[720px] text-4xl font-black leading-[1.08] tracking-[-0.035em] sm:text-5xl lg:text-[3.5rem]">
              {{ post.title }}
            </h1>
            <p v-if="post.excerpt" class="mt-6 max-w-2xl text-lg font-medium leading-8 text-white/75">
              {{ post.excerpt }}
            </p>
            <div class="mt-7 flex flex-wrap items-center gap-x-5 gap-y-3 text-sm font-bold text-white/70">
              <span class="inline-flex items-center gap-2">
                <UserRound class="h-4 w-4" />
                {{ post.author || 'ALOO Editorial' }}
              </span>
              <time class="inline-flex items-center gap-2">
                <CalendarDays class="h-4 w-4" />
                {{ formatDate(post.publishedAt || post.createdAt) }}
              </time>
              <span class="inline-flex items-center gap-2">
                <Clock3 class="h-4 w-4" />
                {{ readingTime }} phút đọc
              </span>
            </div>
          </div>

          <figure class="relative min-h-[300px] overflow-hidden bg-avocado-100 lg:min-h-[470px]">
            <img
              v-if="post.image"
              :src="post.image"
              :alt="post.title"
              class="absolute inset-0 h-full w-full object-cover"
              decoding="async"
            />
            <div v-else class="absolute inset-0 flex items-center justify-center bg-[radial-gradient(circle_at_top_right,#9fce41,#1b4332_72%)] text-6xl font-black text-white/80">
              ALOO
            </div>
            <div class="absolute inset-0 bg-gradient-to-t from-brand-dark/30 via-transparent to-transparent"></div>
          </figure>
        </div>
      </header>

      <div class="mt-8 grid items-start gap-8 lg:grid-cols-[minmax(0,820px)_300px] lg:justify-center">
        <main class="overflow-hidden rounded-3xl border border-brand-forest/10 bg-white px-5 py-8 shadow-sm sm:px-9 lg:px-12 lg:py-12">
          <div class="blog-content leading-8 text-brand-dark" v-html="articleContent"></div>

          <footer class="mt-10 border-t border-brand-forest/10 pt-6">
            <div v-if="post.tags?.length" class="flex flex-wrap gap-2">
              <span
                v-for="tag in post.tags"
                :key="tag"
                class="rounded-full bg-avocado-50 px-3 py-1.5 text-sm font-bold text-avocado-800"
              >
                #{{ tag }}
              </span>
            </div>
            <p class="mt-5 text-sm font-bold text-brand-muted">
              Nguồn: {{ post.source || post.author || 'ALOO Editorial' }}
            </p>
          </footer>
        </main>

        <aside class="grid gap-5 lg:sticky lg:top-24">
          <section v-if="tocItems.length" class="rounded-3xl border border-brand-forest/10 bg-white p-6 shadow-sm">
            <p class="text-xs font-black uppercase tracking-[0.16em] text-avocado-700">Trong bài viết</p>
            <nav class="mt-4 grid gap-1">
              <a
                v-for="(item, index) in tocItems"
                :key="item.id"
                :href="`#${item.id}`"
                class="group flex gap-3 rounded-xl px-2 py-2.5 text-sm font-bold leading-5 text-brand-muted transition hover:bg-avocado-50 hover:text-avocado-800"
              >
                <span class="text-avocado-500">{{ String(index + 1).padStart(2, '0') }}</span>
                <span>{{ item.title }}</span>
              </a>
            </nav>
          </section>

          <section class="rounded-3xl border border-brand-forest/10 bg-white p-6 shadow-sm">
            <p class="text-xs font-black uppercase tracking-[0.16em] text-brand-dark">Chia sẻ bài viết</p>
            <div class="mt-4 grid grid-cols-2 gap-2">
              <button type="button" class="inline-flex items-center justify-center gap-2 rounded-xl bg-[#1877f2] px-3 py-2.5 text-sm font-bold text-white transition hover:opacity-90" aria-label="Chia sẻ Facebook" @click="shareFacebook">
                <Facebook class="h-4 w-4" /> Facebook
              </button>
              <button type="button" class="inline-flex items-center justify-center gap-2 rounded-xl bg-brand-dark px-3 py-2.5 text-sm font-bold text-white transition hover:opacity-90" aria-label="Chia sẻ Twitter" @click="shareTwitter">
                <Twitter class="h-4 w-4" /> Twitter
              </button>
              <button type="button" class="col-span-2 inline-flex items-center justify-center gap-2 rounded-xl bg-brand-cream px-3 py-2.5 text-sm font-bold text-brand-dark transition hover:bg-avocado-50" aria-label="Sao chép liên kết" @click="copyLink">
                <LinkIcon class="h-4 w-4" /> {{ copyFeedback || 'Sao chép liên kết' }}
              </button>
              <button type="button" class="col-span-2 inline-flex items-center justify-center gap-2 rounded-xl border border-brand-forest/10 px-3 py-2.5 text-sm font-bold text-brand-muted transition hover:border-avocado-300 hover:text-brand-dark" aria-label="In bài viết" @click="printArticle">
                <Printer class="h-4 w-4" /> In bài viết
              </button>
            </div>
          </section>

          <section class="overflow-hidden rounded-3xl bg-avocado-700 p-6 text-white shadow-sm">
            <p class="text-xs font-black uppercase tracking-[0.16em] text-avocado-100">Nhượng quyền ALOO</p>
            <h2 class="mt-3 text-2xl font-black leading-tight">Biến tình yêu kem bơ thành cửa hàng của bạn</h2>
            <RouterLink to="/consultation" class="mt-5 inline-flex rounded-full bg-white px-5 py-3 text-sm font-black text-avocado-800 transition hover:bg-brand-cream">
              Nhận tư vấn miễn phí
            </RouterLink>
          </section>
        </aside>
      </div>

      <section v-if="relatedPosts.length" class="mt-12">
        <div class="flex items-end justify-between gap-4">
          <div>
            <p class="text-xs font-black uppercase tracking-[0.16em] text-avocado-700">Đọc tiếp</p>
            <h2 class="mt-2 text-3xl font-black text-brand-dark">Cùng chuyên mục</h2>
          </div>
          <RouterLink to="/blog" class="text-sm font-black text-avocado-700 hover:text-brand-dark">Xem tất cả →</RouterLink>
        </div>
        <div class="mt-6 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
          <article v-for="item in relatedPosts" :key="item.id" class="group">
            <RouterLink :to="`/blog/${item.slug || item.id}`" class="block h-full overflow-hidden rounded-3xl border border-brand-forest/10 bg-white shadow-sm transition hover:-translate-y-1 hover:shadow-lg">
              <figure class="relative aspect-[16/10] overflow-hidden bg-brand-cream/40">
                <img v-if="item.image" :src="item.image" :alt="item.title" class="h-full w-full object-cover transition duration-500 group-hover:scale-105" loading="lazy" decoding="async" />
                <div v-else class="flex h-full w-full items-center justify-center text-xl font-black text-avocado-700">ALOO</div>
              </figure>
              <div class="p-5">
                <p class="text-xs font-black uppercase tracking-wider text-avocado-700">{{ item.category || 'ALOO' }}</p>
                <h3 class="mt-2 line-clamp-3 text-lg font-black leading-7 text-brand-dark group-hover:text-avocado-700">{{ item.title }}</h3>
              </div>
            </RouterLink>
          </article>
        </div>
      </section>
    </article>

    <div v-else class="mx-auto max-w-xl rounded-3xl border border-brand-forest/10 bg-white p-8 text-center shadow-sm">
      <h1 class="text-2xl font-black text-brand-dark">Không tìm thấy bài viết</h1>
      <p class="mt-3 text-brand-muted">Bài viết không tồn tại hoặc chưa được công khai.</p>
      <RouterLink
        to="/blog"
        class="mt-6 inline-flex rounded-full bg-avocado-700 px-5 py-3 font-black text-white transition hover:bg-avocado-800"
      >
        Quay lại Blog
      </RouterLink>
    </div>
  </section>
</template>

<style scoped>
.blog-content {
  overflow-wrap: anywhere;
}

.blog-content :deep(*) {
  max-width: 100%;
  box-sizing: border-box;
}

.blog-content :deep(div),
.blog-content :deep(section),
.blog-content :deep(article) {
  width: auto !important;
}

.blog-content :deep(h2) {
  margin-top: 1.75rem;
  margin-bottom: 0.75rem;
  font-size: 1.65rem;
  line-height: 1.25;
  font-weight: 900;
  color: var(--color-brand-dark);
}

.blog-content :deep(.article-contact) {
  margin-top: 2rem;
  background: var(--color-avocado-50);
  padding: 1.5rem;
  border-radius: 1rem;
  box-shadow: inset 0 0 0 1px rgb(181 211 153 / 0.5);
}

.blog-content :deep(h3) {
  margin-top: 1.25rem;
  margin-bottom: 0.5rem;
  font-size: 1.25rem;
  font-weight: 900;
  color: var(--color-brand-dark);
}

.blog-content :deep(p) {
  margin: 1rem 0;
  font-size: 1.08rem;
  line-height: 1.9;
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
  border-left: 4px solid var(--color-avocado-700);
  background: var(--color-avocado-50);
  padding: 1rem;
  border-radius: 0 0.75rem 0.75rem 0;
  font-weight: 700;
  color: var(--color-avocado-800);
}

.blog-content :deep(a) {
  font-weight: 800;
  color: var(--color-avocado-700);
  text-decoration: underline;
}

.blog-content :deep(img) {
  display: block;
  margin: 1.5rem auto;
  width: auto;
  max-width: 100%;
  height: auto;
  max-height: 720px;
  object-fit: contain;
  border-radius: 0.75rem;
  box-shadow: 0 12px 30px rgb(15 23 42 / 0.08);
}

.blog-content :deep(table) {
  width: 100%;
  border-collapse: collapse;
  margin: 1.5rem 0;
}

.blog-content :deep(th),
.blog-content :deep(td) {
  border: 1px solid rgb(203 213 225);
  padding: 0.75rem;
}

.blog-content :deep(th) {
  background: var(--color-brand-cream);
  color: var(--color-brand-dark);
}
</style>
