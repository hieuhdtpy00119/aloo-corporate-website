<script setup>
import { computed, ref } from 'vue'
import { RouterLink } from 'vue-router'
import {
  AlertCircle,
  ArrowUpRight,
  ChevronRight,
  Clock3,
  FileClock,
  FileText,
  MapPin,
  Package,
  Phone,
  Users,
  TrendingUp
} from 'lucide-vue-next'
import { useAppStore } from '../../stores/appStore'

const store = useAppStore()
const selectedRange = ref('7 ngày qua')

const timeRanges = ['Hôm nay', '7 ngày qua', '30 ngày qua', 'Tháng này']

const parseDate = (value) => {
  if (!value) return null
  const date = new Date(String(value).replace(' ', 'T'))
  return Number.isNaN(date.getTime()) ? null : date
}

const getItemDate = (item) =>
  parseDate(item.updatedAt || item.createdAt || item.publishedAt || item.date || item.lastContactedAt)

const rangeStart = computed(() => {
  const now = new Date()
  const start = new Date(now)

  if (selectedRange.value === 'Hôm nay') {
    start.setHours(0, 0, 0, 0)
    return start
  }

  if (selectedRange.value === '30 ngày qua') {
    start.setDate(now.getDate() - 29)
    start.setHours(0, 0, 0, 0)
    return start
  }

  if (selectedRange.value === 'Tháng này') {
    return new Date(now.getFullYear(), now.getMonth(), 1)
  }

  start.setDate(now.getDate() - 6)
  start.setHours(0, 0, 0, 0)
  return start
})

const isInsideSelectedRange = (item) => {
  const itemDate = getItemDate(item)
  if (!itemDate) return true
  return itemDate >= rangeStart.value
}

const scopedRegistrations = computed(() => store.registrations.filter(isInsideSelectedRange))
const scopedPosts = computed(() => store.posts.filter(isInsideSelectedRange))
const scopedProducts = computed(() => store.products.filter(isInsideSelectedRange))
const scopedLocations = computed(() => store.locations.filter(isInsideSelectedRange))

const scopedRecordCount = computed(
  () =>
    scopedRegistrations.value.length +
    scopedPosts.value.length +
    scopedProducts.value.length +
    scopedLocations.value.length,
)

const totalRecordCount = computed(
  () => store.registrations.length + store.posts.length + store.products.length + store.locations.length,
)

const articleStatusLabels = {
  DRAFT: 'Nháp',
  PENDING: 'Chờ duyệt',
  REVIEWING: 'Đang review',
  APPROVED: 'Đã duyệt',
  PUBLISHED: 'Đã xuất bản',
  ARCHIVED: 'Lưu trữ',
  'Bản nháp': 'Nháp',
  'Lên lịch': 'Chờ duyệt',
  'Đã đăng': 'Đã xuất bản',
  Ẩn: 'Lưu trữ',
}

const normalizePostStatus = (status) => {
  if (status === 'Đã đăng') return 'PUBLISHED'
  if (status === 'Bản nháp') return 'DRAFT'
  if (status === 'Lên lịch') return 'PENDING'
  if (status === 'Ẩn') return 'ARCHIVED'
  return status || 'DRAFT'
}

const postStatusLabel = (status) =>
  articleStatusLabels[status] || articleStatusLabels[normalizePostStatus(status)] || status

const pendingPostStatuses = new Set(['DRAFT', 'PENDING', 'REVIEWING'])

const countBy = (items, keyFn) =>
  items.reduce((result, item) => {
    const label = keyFn(item) || 'Khác'
    result[label] = (result[label] || 0) + 1
    return result
  }, {})

const toProgressItems = (record, colors = []) => {
  const entries = Object.entries(record)
  const total = entries.reduce((sum, [, value]) => sum + value, 0) || 1

  return entries.map(([label, value], index) => ({
    label,
    value,
    percent: Math.round((value / total) * 100),
    color: colors[index] || 'bg-avocado-600',
  }))
}

const leadsNeedingAction = computed(() =>
  scopedRegistrations.value.filter((item) => ['Mới', 'NEW', 'Đang tư vấn', 'CONSULTING'].includes(item.status)).length,
)

const postsNeedingAction = computed(() =>
  scopedPosts.value.filter((post) => pendingPostStatuses.has(normalizePostStatus(post.status))).length,
)

const productsOnSale = computed(() =>
  scopedProducts.value.filter((product) => ['ACTIVE', 'Đang bán'].includes(product.status)).length,
)

const activeLocations = computed(() =>
  scopedLocations.value.filter((location) => location.status === 'ACTIVE').length,
)

const kpiCards = computed(() => [
  {
    label: 'Lead cần xử lý',
    value: leadsNeedingAction.value,
    description: 'Lead mới hoặc đang tư vấn',
    note: `${scopedRegistrations.value.length}/${store.registrations.length} lead`,
    icon: AlertCircle,
    tone: 'warning',
  },
  {
    label: 'Bài viết chờ duyệt',
    value: postsNeedingAction.value,
    description: 'Nội dung chưa xuất bản',
    note: `${scopedPosts.value.length}/${store.posts.length} bài`,
    icon: FileClock,
    tone: 'info',
  },
  {
    label: 'Sản phẩm đang bán',
    value: productsOnSale.value,
    description: 'Sản phẩm public đang bật',
    note: `${scopedProducts.value.length}/${store.products.length} sản phẩm`,
    icon: Package,
    tone: 'success',
  },
  {
    label: 'Địa điểm hoạt động',
    value: activeLocations.value,
    description: 'Cửa hàng đang hoạt động',
    note: `${scopedLocations.value.length}/${store.locations.length} địa điểm`,
    icon: MapPin,
    tone: 'success',
  },
])

const actionCards = computed(() => [
  {
    title: `${leadsNeedingAction.value} lead đang chờ phản hồi`,
    description: 'Ưu tiên liên hệ khách hàng mới và lead đang trong giai đoạn tư vấn.',
    to: '/admin/registrations',
    action: 'Xem danh sách lead',
    icon: Users,
    tone: 'warning',
  },
  {
    title: `${postsNeedingAction.value} bài viết chưa xuất bản`,
    description: 'Kiểm tra bản nháp, bài lên lịch và các nội dung đang chờ duyệt.',
    to: '/admin/articles',
    action: 'Xem danh sách bài viết',
    icon: FileText,
    tone: 'info',
  },
])

const leadStatusBars = computed(() =>
  toProgressItems(countBy(scopedRegistrations.value, (item) => item.status), [
    'bg-gradient-to-r from-blue-600 to-cyan-400',
    'bg-gradient-to-r from-brand-forest to-brand-lime',
    'bg-gradient-to-r from-brand-brown to-brand-sand',
    'bg-gradient-to-r from-emerald-600 to-teal-400',
    'bg-gradient-to-r from-slate-400 to-slate-300',
  ]),
)

const postStatusBars = computed(() =>
  toProgressItems(countBy(scopedPosts.value, (item) => postStatusLabel(item.status)), [
    'bg-gradient-to-r from-brand-forest to-brand-lime',
    'bg-gradient-to-r from-brand-brown to-brand-sand',
    'bg-gradient-to-r from-blue-600 to-cyan-400',
    'bg-gradient-to-r from-slate-400 to-slate-300',
  ]),
)

const productCategoryBars = computed(() =>
  toProgressItems(countBy(scopedProducts.value, (item) => item.category), [
    'bg-gradient-to-r from-brand-forest to-brand-lime',
    'bg-gradient-to-r from-brand-brown to-brand-sand',
    'bg-gradient-to-r from-blue-600 to-cyan-450',
  ]),
)

const analysisCards = computed(() => [
  {
    title: 'Lead theo trạng thái',
    subtitle: 'Tỷ trọng lead theo pipeline tư vấn',
    items: leadStatusBars.value,
  },
  {
    title: 'Bài viết theo trạng thái',
    subtitle: 'Tình trạng nội dung trong CMS',
    items: postStatusBars.value,
  },
  {
    title: 'Sản phẩm theo danh mục',
    subtitle: 'Cơ cấu danh mục sản phẩm',
    items: productCategoryBars.value,
  },
])

const leadPriority = {
  Mới: 0,
  NEW: 0,
  'Đang tư vấn': 1,
  CONSULTING: 1,
  'Đã liên hệ': 2,
  CONTACTED: 2,
  'Tiềm năng': 3,
  POTENTIAL: 3,
  'Đã ký': 4,
  SIGNED: 4,
  'Từ chối': 5,
  REJECTED: 5,
}

const recentRegistrations = computed(() =>
  [...scopedRegistrations.value]
    .sort((a, b) => (leadPriority[a.status] ?? 9) - (leadPriority[b.status] ?? 9))
    .slice(0, 5),
)

const recentPosts = computed(() =>
  [...scopedPosts.value]
    .sort((a, b) => {
      const pendingA = pendingPostStatuses.has(normalizePostStatus(a.status)) ? 0 : 1
      const pendingB = pendingPostStatuses.has(normalizePostStatus(b.status)) ? 0 : 1
      return pendingA - pendingB
    })
    .slice(0, 5),
)

const toneClasses = {
  success: {
    card: 'border-brand-lime/20 bg-white hover:border-brand-lime/40',
    icon: 'bg-brand-lime/10 text-brand-forest',
    note: 'text-brand-forest',
  },
  warning: {
    card: 'border-brand-sand/20 bg-white hover:border-brand-sand/40',
    icon: 'bg-brand-sand/10 text-brand-brown',
    note: 'text-brand-brown',
  },
  info: {
    card: 'border-blue-100 bg-white hover:border-blue-200',
    icon: 'bg-blue-50 text-blue-700',
    note: 'text-blue-700',
  },
}

const leadStatusClass = (status) => ({
  'border-blue-200 bg-blue-50 text-blue-700': ['Mới', 'NEW'].includes(status),
  'border-avocado-200 bg-avocado-50 text-avocado-700': ['Đã liên hệ', 'CONTACTED'].includes(status),
  'border-amber-200 bg-amber-50 text-amber-700': ['Đang tư vấn', 'CONSULTING', 'Tiềm năng', 'POTENTIAL'].includes(status),
  'border-emerald-200 bg-emerald-50 text-emerald-700': ['Đã ký', 'SIGNED'].includes(status),
  'border-slate-200 bg-slate-100 text-slate-600': ['Từ chối', 'REJECTED'].includes(status),
})

const postStatusClass = (status) => {
  switch (normalizePostStatus(status)) {
    case 'PUBLISHED':
      return 'border-avocado-200 bg-avocado-50 text-avocado-700'
    case 'PENDING':
    case 'REVIEWING':
      return 'border-blue-200 bg-blue-50 text-blue-700'
    case 'ARCHIVED':
      return 'border-slate-200 bg-slate-100 text-slate-600'
    default:
      return 'border-amber-200 bg-amber-50 text-amber-700'
  }
}
</script>

<template>
  <section class="space-y-8 pb-10">
    <!-- Dashboard Header -->
    <div class="rounded-3xl border border-avocado-100/30 bg-white p-6 sm:p-8 shadow-sm">
      <div class="flex flex-col justify-between gap-5 xl:flex-row xl:items-center">
        <div>
          <span class="inline-flex items-center gap-1 text-[10px] font-bold uppercase tracking-wider text-avocado-600">
            <TrendingUp class="h-3 w-3" />
            ALOO Franchise CMS
          </span>
          <h1 class="mt-2 text-2xl sm:text-3xl font-black text-avocado-950">Dashboard tổng quan</h1>
          <p class="mt-1 text-sm text-slate-400">
            Đang xem {{ scopedRecordCount }}/{{ totalRecordCount }} bản ghi trong phạm vi {{ selectedRange.toLowerCase() }}.
          </p>
        </div>

        <div class="flex flex-wrap gap-1 rounded-2xl bg-slate-50 border border-slate-100 p-1">
          <button
            v-for="range in timeRanges"
            :key="range"
            type="button"
            class="rounded-xl px-4 py-2 text-xs font-bold transition"
            :class="selectedRange === range ? 'bg-white text-avocado-800 shadow-sm border border-slate-100' : 'text-slate-500 hover:text-avocado-800'"
            @click="selectedRange = range"
          >
            {{ range }}
          </button>
        </div>
      </div>
    </div>

    <!-- KPIs Grid -->
    <section class="space-y-4">
      <div>
        <h2 class="text-base font-bold text-avocado-950">Chỉ số vận hành chính</h2>
        <p class="text-xs text-slate-400">Các chỉ số thống kê theo phạm vi {{ selectedRange.toLowerCase() }}.</p>
      </div>

      <div class="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
        <article
          v-for="card in kpiCards"
          :key="card.label"
          class="rounded-3xl border p-6 shadow-sm hover-lift transition"
          :class="toneClasses[card.tone].card"
        >
          <div class="flex items-start justify-between gap-4">
            <div class="min-w-0">
              <p class="text-xs font-bold text-slate-400 uppercase tracking-wider">{{ card.label }}</p>
              <p class="mt-3.5 text-4xl font-black leading-none text-avocado-950 tracking-tight">{{ card.value }}</p>
            </div>
            <div class="grid h-11 w-11 shrink-0 place-items-center rounded-xl shadow-sm" :class="toneClasses[card.tone].icon">
              <component :is="card.icon" class="h-5 w-5" aria-hidden="true" />
            </div>
          </div>
          <div class="mt-5 h-px bg-slate-50"></div>
          <div class="mt-4 flex items-center justify-between text-xs">
            <span class="text-slate-400">{{ card.description }}</span>
            <span class="font-bold uppercase tracking-wider" :class="toneClasses[card.tone].note">{{ card.note }}</span>
          </div>
        </article>
      </div>
    </section>

    <!-- Action Cards -->
    <section class="space-y-4">
      <div>
        <h2 class="text-base font-bold text-avocado-950">Đầu việc cần ưu tiên</h2>
        <p class="text-xs text-slate-400">Các thông báo cần xử lý nhanh chóng trong ca làm việc.</p>
      </div>

      <div class="grid gap-5 lg:grid-cols-2">
        <RouterLink
          v-for="item in actionCards"
          :key="item.title"
          :to="item.to"
          class="group rounded-3xl border bg-white p-6 shadow-sm hover-lift transition border-slate-100 hover:border-avocado-100"
        >
          <div class="flex items-start justify-between gap-4">
            <div class="flex min-w-0 gap-4">
              <div class="grid h-12 w-12 shrink-0 place-items-center rounded-2xl bg-avocado-50 text-avocado-700 shadow-sm">
                <component :is="item.icon" class="h-5.5 w-5.5" aria-hidden="true" />
              </div>
              <div class="min-w-0">
                <h3 class="text-base font-bold text-avocado-950">{{ item.title }}</h3>
                <p class="mt-1.5 text-xs leading-relaxed text-slate-400">{{ item.description }}</p>
                <span class="mt-4 inline-flex items-center gap-1 text-xs font-bold text-avocado-700">
                  {{ item.action }}
                  <ArrowUpRight class="h-3.5 w-3.5 transition group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
                </span>
              </div>
            </div>
            <ChevronRight class="mt-1 h-5 w-5 shrink-0 text-slate-300" />
          </div>
        </RouterLink>
      </div>
    </section>

    <!-- Visual Analysis Grid -->
    <section class="space-y-4">
      <div>
        <h2 class="text-base font-bold text-avocado-950">Cơ cấu & Phân bổ dữ liệu</h2>
        <p class="text-xs text-slate-400">Tỷ trọng các nhóm đối tượng trong phạm vi {{ selectedRange.toLowerCase() }}.</p>
      </div>

      <div class="grid gap-5 md:grid-cols-2 lg:grid-cols-3">
        <article
          v-for="card in analysisCards"
          :key="card.title"
          class="rounded-3xl border border-slate-100 bg-white p-6 shadow-sm"
        >
          <div class="border-b border-slate-50 pb-4">
            <h3 class="font-bold text-sm text-avocado-950">{{ card.title }}</h3>
            <p class="text-xs text-slate-400 mt-1">{{ card.subtitle }}</p>
          </div>

          <div class="mt-5 space-y-4.5">
            <div v-for="item in card.items" :key="item.label">
              <div class="mb-2 flex items-center justify-between gap-3 text-xs">
                <span class="min-w-0 truncate font-semibold text-slate-700">{{ item.label }}</span>
                <span class="shrink-0 font-bold text-slate-400">{{ item.value }} · {{ item.percent }}%</span>
              </div>
              <div class="h-2 overflow-hidden rounded-full bg-slate-50 border border-slate-100/50">
                <div class="h-full rounded-full transition-all" :class="item.color" :style="{ width: `${item.percent}%` }"></div>
              </div>
            </div>
          </div>
        </article>
      </div>
    </section>

    <!-- Recent Data Table views -->
    <section class="space-y-4">
      <div>
        <h2 class="text-base font-bold text-avocado-950">Dữ liệu cập nhật mới nhất</h2>
        <p class="text-xs text-slate-400">Danh sách lead và bài viết trong phạm vi {{ selectedRange.toLowerCase() }}.</p>
      </div>

      <div class="grid gap-5 xl:grid-cols-2">
        <!-- New Leads -->
        <article class="overflow-hidden rounded-3xl border border-slate-100 bg-white shadow-sm flex flex-col justify-between">
          <div>
            <div class="flex items-center justify-between gap-4 border-b border-slate-50 px-6 py-5">
              <div>
                <h3 class="font-bold text-sm text-avocado-950">Lead Đăng Ký Tư Vấn</h3>
                <p class="text-xs text-slate-400 mt-1">Các yêu cầu nhượng quyền vừa nhận.</p>
              </div>
              <RouterLink to="/admin/registrations" class="text-xs font-bold text-avocado-700 hover:text-avocado-900 transition">
                Xem tất cả
              </RouterLink>
            </div>

            <div class="divide-y divide-slate-50">
              <div
                v-for="lead in recentRegistrations"
                :key="lead.id"
                class="grid gap-3 px-6 py-4 hover:bg-slate-50/50 md:grid-cols-[minmax(0,1fr)_auto] md:items-center transition"
              >
                <div class="min-w-0">
                  <p class="truncate font-bold text-xs text-avocado-950">{{ lead.name }}</p>
                  <div class="mt-1.5 flex flex-wrap gap-x-3.5 gap-y-1 text-xs text-slate-400">
                    <span class="inline-flex items-center gap-1">
                      <Phone class="h-3 w-3" />
                      {{ lead.phone }}
                    </span>
                    <span>{{ lead.area }}</span>
                    <span class="inline-flex items-center gap-1">
                      <Clock3 class="h-3 w-3" />
                      {{ lead.createdAt }}
                    </span>
                  </div>
                </div>
                <div class="flex items-center justify-between gap-3 md:justify-end">
                  <span class="rounded-full border px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider" :class="leadStatusClass(lead.status)">
                    {{ lead.status }}
                  </span>
                  <RouterLink
                    to="/admin/registrations"
                    class="grid h-8 w-8 place-items-center rounded-xl border border-avocado-100 text-avocado-700 hover:bg-avocado-50 transition"
                    aria-label="Xem chi tiết lead"
                  >
                    <ChevronRight class="h-4 w-4" />
                  </RouterLink>
                </div>
              </div>
            </div>
          </div>
        </article>

        <!-- New Posts -->
        <article class="overflow-hidden rounded-3xl border border-slate-100 bg-white shadow-sm flex flex-col justify-between">
          <div>
            <div class="flex items-center justify-between gap-4 border-b border-slate-50 px-6 py-5">
              <div>
                <h3 class="font-bold text-sm text-avocado-950">Bài Viết & Tin Tức</h3>
                <p class="text-xs text-slate-400 mt-1">Cập nhật tiến trình viết bài.</p>
              </div>
              <RouterLink to="/admin/articles" class="text-xs font-bold text-avocado-700 hover:text-avocado-900 transition">
                Quản lý bài viết
              </RouterLink>
            </div>

            <div class="divide-y divide-slate-50">
              <div
                v-for="post in recentPosts"
                :key="post.id"
                class="grid gap-3 px-6 py-4 hover:bg-slate-50/50 md:grid-cols-[minmax(0,1fr)_auto] md:items-center transition"
              >
                <div class="min-w-0">
                  <h4 class="line-clamp-1 font-bold text-xs text-avocado-950">{{ post.title }}</h4>
                  <div class="mt-2 flex flex-wrap items-center gap-2 text-[10px] font-bold text-slate-400">
                    <span class="rounded-full bg-avocado-50 border border-avocado-100/30 px-2 py-0.5 text-avocado-700">{{ post.category }}</span>
                    <span class="inline-flex items-center gap-1">
                      <Clock3 class="h-3 w-3" />
                      {{ post.updatedAt || post.publishedAt || post.date || 'Chưa đặt lịch' }}
                    </span>
                  </div>
                </div>
                <div class="flex items-center justify-between gap-3 md:justify-end">
                  <span class="rounded-full border px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider" :class="postStatusClass(post.status)">
                    {{ postStatusLabel(post.status) }}
                  </span>
                  <RouterLink
                    to="/admin/articles"
                    class="grid h-8 w-8 place-items-center rounded-xl border border-avocado-100 text-avocado-700 hover:bg-avocado-50 transition"
                    aria-label="Quản lý bài viết"
                  >
                    <ChevronRight class="h-4 w-4" />
                  </RouterLink>
                </div>
              </div>
            </div>
          </div>
        </article>
      </div>
    </section>
  </section>
</template>
