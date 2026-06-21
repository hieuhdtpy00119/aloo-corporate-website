<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useAppStore } from '../../stores/appStore'
import { setSeoMeta } from '../../services/seoService'
import { CalendarDays, Facebook, Link as LinkIcon, Printer, Twitter, UserRound } from 'lucide-vue-next'

const route = useRoute()
const store = useAppStore()
const copyFeedback = ref('')
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
  return stripAlooChainInfo(post.value.content).replace(/<h2([^>]*)>(.*?)<\/h2>/g, (match, attrs, title) => {
    if (attrs.includes('id=')) return match
    index += 1
    return `<h2${attrs} id="${slugify(title) || `section-${index}`}">${title}</h2>`
  })
})

const tocItems = computed(() => {
  if (!articleContent.value) return []
  return [...articleContent.value.matchAll(/<h2[^>]*id="([^"]+)"[^>]*>(.*?)<\/h2>/g)].map((match) => ({
    id: match[1],
    title: match[2].replace(/<[^>]+>/g, ''),
  }))
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
  post,
  (value) => {
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

onMounted(() => {
  Promise.allSettled([store.fetchCategories(), store.fetchPosts()])
})
</script>

<template>
  <section class="bg-brand-cream px-4 py-8 text-brand-dark sm:px-6 lg:px-8">
    <article v-if="post" class="mx-auto max-w-[1240px]">
      <div class="mx-auto max-w-[1100px] overflow-hidden rounded-3xl border border-brand-forest/10 bg-white shadow-sm">
        <div class="article-detail mx-auto max-w-[760px] px-5 py-8 lg:px-8">
          <div class="border-b border-brand-forest/10 pb-3">
            <RouterLink to="/blog" class="text-sm font-bold text-avocado-700 hover:text-brand-dark">
              ← Quay lại Blog
            </RouterLink>
            <p class="mt-2 inline-block rounded-full bg-avocado-50 px-3 py-1 text-xs font-bold text-avocado-700">
              {{ post.category || 'ALOO' }}
            </p>
          </div>

          <header class="mt-6">
            <h1 class="text-3xl font-black leading-tight text-brand-dark lg:text-5xl">{{ post.title }}</h1>
            <div class="mt-4 flex flex-wrap items-center gap-4 text-sm font-bold text-brand-muted">
              <span class="inline-flex items-center gap-1.5">
                <UserRound class="h-4 w-4" />
                {{ post.author || 'ALOO Editorial' }}
              </span>
              <time class="inline-flex items-center gap-1.5">
                <CalendarDays class="h-4 w-4" />
                {{ formatDate(post.publishedAt || post.createdAt) }}
              </time>
            </div>
          </header>

          <div class="mt-5 flex flex-wrap items-center gap-2 border-y border-brand-forest/10 py-3">
            <button
              type="button"
              class="inline-flex items-center gap-2 rounded-full bg-[#1877f2] px-4 py-2 text-sm font-bold text-white transition hover:opacity-90"
              aria-label="Chia sẻ Facebook"
              @click="shareFacebook"
            >
              <Facebook class="h-4 w-4" />
              Facebook
            </button>
            <button
              type="button"
              class="inline-flex items-center gap-2 rounded-full bg-brand-dark px-4 py-2 text-sm font-bold text-white transition hover:opacity-90"
              aria-label="Chia sẻ Twitter"
              @click="shareTwitter"
            >
              <Twitter class="h-4 w-4" />
              Twitter
            </button>
            <button
              type="button"
              class="inline-flex items-center gap-2 rounded-full bg-brand-cream px-4 py-2 text-sm font-bold text-brand-dark transition hover:bg-avocado-50"
              aria-label="Sao chép liên kết"
              @click="copyLink"
            >
              <LinkIcon class="h-4 w-4" />
              {{ copyFeedback || 'Copy link' }}
            </button>
            <button
              type="button"
              class="inline-flex items-center gap-2 rounded-full bg-brand-cream px-4 py-2 text-sm font-bold text-brand-dark transition hover:bg-avocado-50"
              aria-label="In bài viết"
              @click="printArticle"
            >
              <Printer class="h-4 w-4" />
              In
            </button>
          </div>

          <div v-if="post.excerpt" class="mt-6 rounded-2xl border-l-4 border-avocado-500 bg-avocado-50/60 p-5 text-lg font-bold leading-8 text-brand-dark">
            <p>{{ post.excerpt }}</p>
          </div>

          <div v-if="tocItems.length" class="mt-6 rounded-2xl border border-brand-forest/10 bg-brand-cream/40 p-5">
            <h2 class="text-sm font-black uppercase text-brand-dark">Nội dung chính</h2>
            <nav class="mt-3 grid gap-2">
              <a
                v-for="item in tocItems"
                :key="item.id"
                :href="`#${item.id}`"
                class="text-sm font-bold leading-6 text-brand-muted hover:text-avocado-700"
              >
                {{ item.title }}
              </a>
            </nav>
          </div>

          <div v-if="post.image" class="mt-6 overflow-hidden rounded-2xl border border-brand-forest/10 bg-brand-cream/40 p-4 sm:p-6">
            <img
              :src="post.image"
              :alt="post.title"
              class="mx-auto max-h-[480px] w-full max-w-full object-contain"
              loading="lazy"
              decoding="async"
            />
          </div>

          <div class="blog-content mt-6 leading-8 text-brand-dark" v-html="articleContent"></div>

          <footer class="mt-8 border-t border-brand-forest/10 pt-5">
            <p class="text-right text-sm font-bold text-brand-muted">
              {{ post.source || post.author || 'ALOO Editorial' }}
            </p>
            <div v-if="post.tags?.length" class="mt-5 flex flex-wrap gap-2">
              <span
                v-for="tag in post.tags"
                :key="tag"
                class="rounded-full bg-avocado-50 px-3 py-1 text-sm font-bold text-avocado-800"
              >
                {{ tag }}
              </span>
            </div>
          </footer>
        </div>

        <section v-if="relatedPosts.length" class="border-t border-brand-forest/10 bg-brand-cream/20 px-5 py-8 lg:px-8">
          <h2 class="text-xl font-black text-brand-dark">Cùng chuyên mục</h2>
          <div class="mt-6 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            <article v-for="item in relatedPosts" :key="item.id" class="group">
              <RouterLink :to="`/blog/${item.slug || item.id}`" class="block overflow-hidden rounded-2xl border border-brand-forest/10 bg-white shadow-sm transition hover:-translate-y-0.5 hover:shadow-md">
                <figure class="flex aspect-[5/3] items-center justify-center overflow-hidden bg-brand-cream/40 p-3">
                  <img
                    v-if="item.image"
                    :src="item.image"
                    :alt="item.title"
                    class="max-h-full max-w-full object-contain"
                    loading="lazy"
                    decoding="async"
                  />
                  <div v-else class="flex h-full w-full items-center justify-center text-xl font-black text-avocado-700">ALOO</div>
                </figure>
                <h3 class="line-clamp-3 p-4 text-base font-black leading-6 text-brand-dark group-hover:text-avocado-700">
                  {{ item.title }}
                </h3>
              </RouterLink>
            </article>
          </div>
        </section>
      </div>
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
