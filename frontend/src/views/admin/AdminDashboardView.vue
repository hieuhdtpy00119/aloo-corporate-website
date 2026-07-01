<script setup>
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { useI18n } from 'vue-i18n'
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
  RefreshCw,
  Users,
  TrendingUp
} from 'lucide-vue-next'
import { useAppStore } from '../../stores/appStore'
import AdminListPage from '../../components/admin/AdminListPage.vue'
import AdminNestedShell from '../../components/admin/shell/AdminNestedShell.vue'
import AdminShellFrame from '../../components/admin/shell/AdminShellFrame.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import {
  articleStatusLabel,
  getArticleStatusBadgeClass,
  normalizeArticleStatus,
  pendingArticleStatuses,
} from '../../utils/articleStatus'
import { ADMIN_SCOPES, canAccessAdminSession } from '../../utils/adminAccess'
import { getLeadStatusPriority, getLeadStatusBadgeClass, isLeadNeedingAction, leadStatusLabel, normalizeLeadStatusCode } from '../../utils/leadStatus'
import { adminPaths } from '../../constants/adminPaths'

const store = useAppStore()
const { t, locale } = useI18n()
const permissions = computed(() => canAccessAdminSession())
const lastUpdatedAt = ref(null)
const isRefreshing = ref(false)

const RANGE = {
  TODAY: 'today',
  WEEK: 'week',
  MONTH30: 'month30',
  THIS_MONTH: 'thisMonth',
}
const selectedRange = ref(RANGE.WEEK)

const timeRangeOptions = computed(() => [
  { key: RANGE.TODAY, label: t('admin.dashboard.ranges.today') },
  { key: RANGE.WEEK, label: t('admin.dashboard.ranges.week') },
  { key: RANGE.MONTH30, label: t('admin.dashboard.ranges.month30') },
  { key: RANGE.THIS_MONTH, label: t('admin.dashboard.ranges.thisMonth') },
])

const selectedRangeLabel = computed(() => {
  const match = timeRangeOptions.value.find((item) => item.key === selectedRange.value)
  return match?.label || ''
})

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

  if (selectedRange.value === RANGE.TODAY) {
    start.setHours(0, 0, 0, 0)
    return start
  }

  if (selectedRange.value === RANGE.MONTH30) {
    start.setDate(now.getDate() - 29)
    start.setHours(0, 0, 0, 0)
    return start
  }

  if (selectedRange.value === RANGE.THIS_MONTH) {
    return new Date(now.getFullYear(), now.getMonth(), 1)
  }

  start.setDate(now.getDate() - 6)
  start.setHours(0, 0, 0, 0)
  return start
})

const isInsideSelectedRange = (item) => {
  const itemDate = getItemDate(item)
  if (!itemDate) return false
  return itemDate >= rangeStart.value
}

const isLoading = computed(() => {
  const access = permissions.value
  return (
    (access[ADMIN_SCOPES.crm] && store.loading.registrations) ||
    (access[ADMIN_SCOPES.content] && (store.loading.posts || store.loading.products)) ||
    (access[ADMIN_SCOPES.stores] && store.loading.locations)
  )
})

const loadErrors = computed(() => {
  const access = permissions.value
  return [
    access[ADMIN_SCOPES.crm] ? store.errors.registrations : '',
    access[ADMIN_SCOPES.content] ? store.errors.posts : '',
    access[ADMIN_SCOPES.content] ? store.errors.products : '',
    access[ADMIN_SCOPES.stores] ? store.errors.locations : '',
  ].filter(Boolean)
})

const hasLoadError = computed(() => loadErrors.value.length > 0)

const scopedRegistrations = computed(() => store.registrations.filter(isInsideSelectedRange))
const scopedPosts = computed(() => store.posts.filter(isInsideSelectedRange))

const postStatusLabel = articleStatusLabel

const countBy = (items, keyFn) =>
  items.reduce((result, item) => {
    const label = keyFn(item) || t('admin.dashboard.misc.other')
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
  scopedRegistrations.value.filter((item) => isLeadNeedingAction(item.status)).length,
)

const postsNeedingAction = computed(() =>
  scopedPosts.value.filter((post) => pendingArticleStatuses.has(normalizeArticleStatus(post.status))).length,
)

const productsOnSale = computed(() =>
  store.products.filter((product) => ['ACTIVE', 'Đang bán'].includes(product.status)).length,
)

const activeLocations = computed(() =>
  store.locations.filter((location) => location.status === 'ACTIVE').length,
)

const kpiCards = computed(() => [
  {
    label: t('admin.dashboard.kpi.leadsLabel'),
    value: leadsNeedingAction.value,
    description: t('admin.dashboard.kpi.leadsDescription'),
    note: t('admin.dashboard.kpi.leadsNote', {
      scoped: scopedRegistrations.value.length,
      total: store.registrations.length,
    }),
    icon: AlertCircle,
    tone: 'warning',
    to: adminPaths.crm.leads,
    scope: ADMIN_SCOPES.crm,
  },
  {
    label: t('admin.dashboard.kpi.postsLabel'),
    value: postsNeedingAction.value,
    description: t('admin.dashboard.kpi.postsDescription'),
    note: t('admin.dashboard.kpi.postsNote', {
      scoped: scopedPosts.value.length,
      total: store.posts.length,
    }),
    icon: FileClock,
    tone: 'info',
    to: adminPaths.content.articles,
    scope: ADMIN_SCOPES.content,
  },
  {
    label: t('admin.dashboard.kpi.productsLabel'),
    value: productsOnSale.value,
    description: t('admin.dashboard.kpi.productsDescription'),
    note: t('admin.dashboard.kpi.productsNote', { total: store.products.length }),
    snapshot: t('admin.dashboard.kpi.snapshotHint'),
    icon: Package,
    tone: 'success',
    to: adminPaths.content.products,
    scope: ADMIN_SCOPES.content,
  },
  {
    label: t('admin.dashboard.kpi.locationsLabel'),
    value: activeLocations.value,
    description: t('admin.dashboard.kpi.locationsDescription'),
    note: t('admin.dashboard.kpi.locationsNote', { total: store.locations.length }),
    snapshot: t('admin.dashboard.kpi.snapshotHint'),
    icon: MapPin,
    tone: 'success',
    to: adminPaths.stores.locations,
    scope: ADMIN_SCOPES.stores,
  },
])

const visibleKpiCards = computed(() =>
  kpiCards.value.filter((card) => permissions.value[card.scope]),
)

const actionCards = computed(() => [
  {
    title: t('admin.dashboard.actions.leadsTitle', { count: leadsNeedingAction.value }),
    description: t('admin.dashboard.actions.leadsDescription'),
    to: adminPaths.crm.leads,
    action: t('admin.dashboard.actions.leadsAction'),
    icon: Users,
    tone: 'warning',
    scope: ADMIN_SCOPES.crm,
  },
  {
    title: t('admin.dashboard.actions.postsTitle', { count: postsNeedingAction.value }),
    description: t('admin.dashboard.actions.postsDescription'),
    to: adminPaths.content.articles,
    action: t('admin.dashboard.actions.postsAction'),
    icon: FileText,
    tone: 'info',
    scope: ADMIN_SCOPES.content,
  },
])

const visibleActionCards = computed(() =>
  actionCards.value.filter((card) => permissions.value[card.scope]),
)

const leadStatusBars = computed(() =>
  toProgressItems(countBy(scopedRegistrations.value, (item) => leadStatusLabel(item.status, t)), [
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
  toProgressItems(countBy(store.products, (item) => item.category), [
    'bg-gradient-to-r from-brand-forest to-brand-lime',
    'bg-gradient-to-r from-brand-brown to-brand-sand',
    'bg-gradient-to-r from-blue-600 to-cyan-400',
  ]),
)

const analysisCards = computed(() => [
  {
    title: t('admin.dashboard.analysis.leadsTitle'),
    subtitle: t('admin.dashboard.analysis.leadsSubtitle'),
    items: leadStatusBars.value,
    scope: ADMIN_SCOPES.crm,
  },
  {
    title: t('admin.dashboard.analysis.postsTitle'),
    subtitle: t('admin.dashboard.analysis.postsSubtitle'),
    items: postStatusBars.value,
    scope: ADMIN_SCOPES.content,
  },
  {
    title: t('admin.dashboard.analysis.productsTitle'),
    subtitle: t('admin.dashboard.analysis.productsSubtitle'),
    items: productCategoryBars.value,
    scope: ADMIN_SCOPES.content,
  },
])

const visibleAnalysisCards = computed(() =>
  analysisCards.value.filter((card) => permissions.value[card.scope]),
)

const recentRegistrations = computed(() =>
  [...scopedRegistrations.value]
    .sort((a, b) => getLeadStatusPriority(a.status) - getLeadStatusPriority(b.status))
    .slice(0, 5),
)

const recentPosts = computed(() =>
  [...scopedPosts.value]
    .sort((a, b) => {
      const pendingA = pendingArticleStatuses.has(normalizeArticleStatus(a.status)) ? 0 : 1
      const pendingB = pendingArticleStatuses.has(normalizeArticleStatus(b.status)) ? 0 : 1
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

const leadStatusClass = (status) => getLeadStatusBadgeClass(status)

const postStatusClass = getArticleStatusBadgeClass

const formattedLastUpdated = computed(() => {
  if (!lastUpdatedAt.value) return ''
  const currentLocale = typeof locale === 'string' ? locale : locale?.value || 'vi'
  return new Intl.DateTimeFormat(currentLocale === 'en' ? 'en-GB' : 'vi-VN', {
    dateStyle: 'short',
    timeStyle: 'short',
  }).format(lastUpdatedAt.value)
})

const refreshDashboard = async () => {
  if (isRefreshing.value) return
  isRefreshing.value = true
  try {
    await store.fetchAdminData()
    lastUpdatedAt.value = new Date()
  } finally {
    isRefreshing.value = false
  }
}

watch(isLoading, (loading) => {
  if (!loading) lastUpdatedAt.value = new Date()
})

onMounted(() => {
  if (!isLoading.value) lastUpdatedAt.value = new Date()
})
</script>

<template>
  <AdminListPage>
    <AdminNestedShell>
      <AdminShellFrame variant="header" inner="header">
        <div class="aloo-admin-header max-xl:!grid-cols-1">
          <div class="min-w-0">
            <p class="aloo-eyebrow inline-flex items-center gap-1">
              <TrendingUp class="h-3 w-3" />
              {{ t('admin.dashboard.badge') }}
            </p>
            <h1 class="aloo-title aloo-title--admin mt-2">{{ t('admin.dashboard.title') }}</h1>
            <p v-if="formattedLastUpdated" class="mt-2 text-xs font-semibold text-slate-500">
              {{ t('admin.dashboard.lastUpdated', { time: formattedLastUpdated }) }}
            </p>
          </div>

          <div class="flex flex-col gap-3 sm:flex-row sm:items-center max-xl:pt-2">
            <button
              type="button"
              class="admin-list-btn admin-list-btn--outline inline-flex items-center justify-center gap-2 disabled:cursor-not-allowed disabled:opacity-60"
              :disabled="isRefreshing || isLoading"
              @click="refreshDashboard"
            >
              <RefreshCw class="h-3.5 w-3.5" :class="isRefreshing ? 'animate-spin' : ''" />
              {{ isRefreshing ? t('admin.dashboard.refreshing') : t('admin.dashboard.refresh') }}
            </button>
          </div>
        </div>
      </AdminShellFrame>

      <AdminShellFrame variant="toolbar" inner="toolbar">
        <div class="admin-shell-toolbar">
          <div class="flex flex-wrap gap-1 rounded-xl border border-slate-200 bg-slate-50 p-1">
            <button
              v-for="range in timeRangeOptions"
              :key="range.key"
              type="button"
              class="rounded-lg px-4 py-2 text-xs font-bold transition"
              :class="selectedRange === range.key ? 'border border-slate-200 bg-white text-avocado-800 shadow-sm' : 'text-slate-500 hover:text-avocado-800'"
              @click="selectedRange = range.key"
            >
              {{ range.label }}
            </button>
          </div>
        </div>
      </AdminShellFrame>

      <AdminShellFrame v-if="hasLoadError" as="div" variant="alert" class="admin-dashboard-alert" role="alert">
        <p>{{ t('admin.dashboard.loadErrorTitle') }}</p>
        <ul class="mt-2 list-disc pl-5 text-xs font-medium">
          <li v-for="error in loadErrors" :key="error">{{ error }}</li>
        </ul>
      </AdminShellFrame>

      <AdminShellFrame variant="body" inner="pad">
        <div class="admin-dashboard-body">
          <div
            v-if="isLoading"
            class="grid gap-5 sm:grid-cols-2 xl:grid-cols-4"
            aria-busy="true"
            :aria-label="t('admin.dashboard.loading')"
          >
            <div v-for="index in 4" :key="index" class="admin-dashboard-kpi-skeleton" />
          </div>

          <section v-if="visibleKpiCards.length" class="space-y-4">
            <div>
              <h2 class="text-base font-bold text-avocado-950">{{ t('admin.dashboard.kpi.sectionTitle') }}</h2>
              <p class="text-xs text-slate-400">{{ t('admin.dashboard.kpi.sectionSubtitle', { range: selectedRangeLabel }) }}</p>
            </div>

            <div class="grid gap-5 sm:grid-cols-2 xl:grid-cols-4">
              <RouterLink
                v-for="card in visibleKpiCards"
                :key="card.label"
                :to="card.to"
                class="block rounded-3xl border p-6 shadow-sm transition hover-lift focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-avocado-500"
                :class="toneClasses[card.tone].card"
              >
                <div class="flex items-start justify-between gap-4">
                  <div class="min-w-0">
                    <p class="text-xs font-bold uppercase tracking-wider text-slate-400">{{ card.label }}</p>
                    <p class="mt-3.5 text-4xl font-black leading-none tracking-tight text-avocado-950">{{ card.value }}</p>
                  </div>
                  <div class="grid h-11 w-11 shrink-0 place-items-center rounded-xl shadow-sm" :class="toneClasses[card.tone].icon">
                    <component :is="card.icon" class="h-5 w-5" aria-hidden="true" />
                  </div>
                </div>
                <div class="mt-5 h-px bg-slate-50"></div>
                <div class="mt-4 flex items-center justify-between gap-2 text-xs">
                  <span class="text-slate-400">{{ card.description }}</span>
                  <span class="text-right font-bold uppercase tracking-wider" :class="toneClasses[card.tone].note">
                    <span v-if="card.snapshot" class="mr-1 normal-case">{{ card.snapshot }} ·</span>
                    {{ card.note }}
                  </span>
                </div>
              </RouterLink>
            </div>
          </section>

          <section v-if="visibleActionCards.length" class="space-y-4">
            <div>
              <h2 class="text-base font-bold text-avocado-950">{{ t('admin.dashboard.actions.sectionTitle') }}</h2>
              <p class="text-xs text-slate-400">{{ t('admin.dashboard.actions.sectionSubtitle') }}</p>
            </div>

            <div class="grid gap-5 lg:grid-cols-2">
              <RouterLink
                v-for="item in visibleActionCards"
                :key="item.title"
                :to="item.to"
                class="group rounded-3xl border border-slate-100 bg-white p-6 shadow-sm transition hover-lift hover:border-avocado-100"
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

          <section v-if="visibleAnalysisCards.length" class="space-y-4">
            <div>
              <h2 class="text-base font-bold text-avocado-950">{{ t('admin.dashboard.analysis.sectionTitle') }}</h2>
              <p class="text-xs text-slate-400">{{ t('admin.dashboard.analysis.sectionSubtitle', { range: selectedRangeLabel }) }}</p>
            </div>

            <div class="grid gap-5 md:grid-cols-2 lg:grid-cols-3">
              <article
                v-for="card in visibleAnalysisCards"
                :key="card.title"
                class="rounded-3xl border border-slate-100 bg-white p-6 shadow-sm"
              >
                <div class="border-b border-slate-50 pb-4">
                  <h3 class="text-sm font-bold text-avocado-950">{{ card.title }}</h3>
                  <p class="mt-1 text-xs text-slate-400">{{ card.subtitle }}</p>
                </div>

                <div class="mt-5 space-y-4.5">
                  <div v-for="item in card.items" :key="item.label">
                    <div class="mb-2 flex items-center justify-between gap-3 text-xs">
                      <span class="min-w-0 truncate font-semibold text-slate-700">{{ item.label }}</span>
                      <span class="shrink-0 font-bold text-slate-400">{{ item.value }} · {{ item.percent }}%</span>
                    </div>
                    <div class="h-2 overflow-hidden rounded-full border border-slate-100/50 bg-slate-50">
                      <div class="h-full rounded-full transition-all" :class="item.color" :style="{ width: `${item.percent}%` }"></div>
                    </div>
                  </div>
                </div>
              </article>
            </div>
          </section>

          <section v-if="permissions[ADMIN_SCOPES.crm] || permissions[ADMIN_SCOPES.content]" class="space-y-4">
            <div>
              <h2 class="text-base font-bold text-avocado-950">{{ t('admin.dashboard.recent.sectionTitle') }}</h2>
              <p class="text-xs text-slate-400">{{ t('admin.dashboard.recent.sectionSubtitle', { range: selectedRangeLabel }) }}</p>
            </div>

            <div class="grid gap-5 xl:grid-cols-2">
              <article v-if="permissions[ADMIN_SCOPES.crm]" class="flex flex-col justify-between overflow-hidden rounded-3xl border border-slate-100 bg-white shadow-sm">
                <div>
                  <div class="flex items-center justify-between gap-4 border-b border-slate-50 px-6 py-5">
                    <div>
                      <h3 class="text-sm font-bold text-avocado-950">{{ t('admin.dashboard.recent.leadsTitle') }}</h3>
                      <p class="mt-1 text-xs text-slate-400">{{ t('admin.dashboard.recent.leadsSubtitle') }}</p>
                    </div>
                    <RouterLink :to="adminPaths.crm.leads" class="text-xs font-bold text-avocado-700 transition hover:text-avocado-900">
                      {{ t('admin.dashboard.recent.leadsViewAll') }}
                    </RouterLink>
                  </div>

                  <div class="divide-y divide-slate-50">
                    <EmptyState
                      v-if="!isLoading && !recentRegistrations.length"
                      :message="t('admin.dashboard.emptyLeads')"
                    />
                    <div
                      v-for="lead in recentRegistrations"
                      :key="lead.id"
                      class="grid gap-3 px-6 py-4 transition hover:bg-slate-50/50 md:grid-cols-[minmax(0,1fr)_auto] md:items-center"
                    >
                      <div class="min-w-0">
                        <p class="truncate text-xs font-bold text-avocado-950">{{ lead.name }}</p>
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
                          {{ leadStatusLabel(lead.status, t) }}
                        </span>
                        <RouterLink
                          :to="adminPaths.crm.leadDetail(lead.id)"
                          class="grid h-8 w-8 place-items-center rounded-xl border border-avocado-100 text-avocado-700 transition hover:bg-avocado-50"
                          :aria-label="t('admin.dashboard.recent.leadsDetailAria')"
                        >
                          <ChevronRight class="h-4 w-4" />
                        </RouterLink>
                      </div>
                    </div>
                  </div>
                </div>
              </article>

              <article v-if="permissions[ADMIN_SCOPES.content]" class="flex flex-col justify-between overflow-hidden rounded-3xl border border-slate-100 bg-white shadow-sm">
                <div>
                  <div class="flex items-center justify-between gap-4 border-b border-slate-50 px-6 py-5">
                    <div>
                      <h3 class="text-sm font-bold text-avocado-950">{{ t('admin.dashboard.recent.postsTitle') }}</h3>
                      <p class="mt-1 text-xs text-slate-400">{{ t('admin.dashboard.recent.postsSubtitle') }}</p>
                    </div>
                    <RouterLink :to="adminPaths.content.articles" class="text-xs font-bold text-avocado-700 transition hover:text-avocado-900">
                      {{ t('admin.dashboard.recent.postsManage') }}
                    </RouterLink>
                  </div>

                  <div class="divide-y divide-slate-50">
                    <EmptyState
                      v-if="!isLoading && !recentPosts.length"
                      :message="t('admin.dashboard.emptyPosts')"
                    />
                    <div
                      v-for="post in recentPosts"
                      :key="post.id"
                      class="grid gap-3 px-6 py-4 transition hover:bg-slate-50/50 md:grid-cols-[minmax(0,1fr)_auto] md:items-center"
                    >
                      <div class="min-w-0">
                        <h4 class="line-clamp-1 text-xs font-bold text-avocado-950">{{ post.title }}</h4>
                        <div class="mt-2 flex flex-wrap items-center gap-2 text-[10px] font-bold text-slate-400">
                          <span class="rounded-full border border-avocado-100/30 bg-avocado-50 px-2 py-0.5 text-avocado-700">{{ post.category }}</span>
                          <span class="inline-flex items-center gap-1">
                            <Clock3 class="h-3 w-3" />
                            {{ post.updatedAt || post.publishedAt || post.date || t('admin.dashboard.misc.notScheduled') }}
                          </span>
                        </div>
                      </div>
                      <div class="flex items-center justify-between gap-3 md:justify-end">
                        <span class="rounded-full border px-2.5 py-1 text-[10px] font-bold uppercase tracking-wider" :class="postStatusClass(post.status)">
                          {{ postStatusLabel(post.status) }}
                        </span>
                        <RouterLink
                          :to="adminPaths.content.articleEdit(post.id)"
                          class="grid h-8 w-8 place-items-center rounded-xl border border-avocado-100 text-avocado-700 transition hover:bg-avocado-50"
                          :aria-label="t('admin.dashboard.recent.postsManageAria')"
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
        </div>
      </AdminShellFrame>
    </AdminNestedShell>
  </AdminListPage>
</template>

<style scoped>
.admin-dashboard-body {
  display: grid;
  gap: 1.25rem;
}

.admin-dashboard-alert {
  margin: 0;
  border-bottom: 1px solid #fecaca;
  background: #fef2f2;
  padding: 1rem 1.25rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: #b91c1c;
}

.admin-dashboard-kpi-skeleton {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
  border-radius: 1.5rem;
  border: 1px solid #f1f5f9;
  background: #ffffff;
  padding: 1.5rem;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.admin-dashboard-kpi-skeleton::before {
  content: '';
  display: block;
  height: 0.75rem;
  width: 6rem;
  border-radius: 0.25rem;
  background: #f1f5f9;
}

.admin-dashboard-kpi-skeleton::after {
  content: '';
  display: block;
  margin-top: 1.5rem;
  height: 2.5rem;
  width: 4rem;
  border-radius: 0.25rem;
  background: #f1f5f9;
}
</style>
