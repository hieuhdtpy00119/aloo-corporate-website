import { adminPaths } from '../constants/adminPaths'

const rules = [
  { match: (path) => path === adminPaths.dashboard, groupKey: null, labelKey: 'admin.nav.dashboard' },
  { match: (path) => path === adminPaths.content.homeSections, groupKey: 'admin.nav.groups.content', labelKey: 'admin.nav.homeSections' },
  { match: (path) => path === adminPaths.content.products, groupKey: 'admin.nav.groups.content', labelKey: 'admin.nav.products' },
  { match: (path) => path === adminPaths.content.franchise, groupKey: 'admin.nav.groups.content', labelKey: 'admin.nav.franchise' },
  { match: (path) => path === adminPaths.content.articles, groupKey: 'admin.nav.groups.content', labelKey: 'admin.nav.articles' },
  { match: (path) => path === adminPaths.content.articleCategories, groupKey: 'admin.nav.groups.content', labelKey: 'admin.nav.categories' },
  { match: (path) => path === adminPaths.content.articleNew, groupKey: 'admin.nav.groups.content', labelKey: 'admin.breadcrumb.articleNew' },
  { match: (path) => /^\/admin\/content\/articles\/\d+\/edit$/.test(path), groupKey: 'admin.nav.groups.content', labelKey: 'admin.breadcrumb.articleEdit' },
  { match: (path) => path === adminPaths.stores.locations, groupKey: 'admin.nav.groups.stores', labelKey: 'admin.nav.locations' },
  { match: (path) => path === adminPaths.crm.feedbacks, groupKey: 'admin.nav.groups.stores', labelKey: 'admin.nav.feedbacks' },
  { match: (path) => path === adminPaths.crm.productReviews, groupKey: 'admin.nav.groups.stores', labelKey: 'admin.nav.productReviews' },
  { match: (path) => path === adminPaths.crm.leads, groupKey: 'admin.nav.groups.business', labelKey: 'admin.nav.registrations' },
  { match: (path) => path === adminPaths.crm.liveChat, groupKey: 'admin.nav.groups.business', labelKey: 'admin.nav.liveChat' },
  { match: (path) => path === adminPaths.system.accounts, groupKey: 'admin.nav.groups.system', labelKey: 'admin.nav.accounts' },
  { match: (path) => path === adminPaths.system.auditLogs, groupKey: 'admin.nav.groups.system', labelKey: 'admin.nav.auditLogs' },
  { match: (path) => path === adminPaths.profile, groupKey: 'admin.nav.groups.system', labelKey: 'admin.shell.profile' },
]

export const resolveAdminBreadcrumb = (path) => {
  const matched = rules.find((rule) => rule.match(path))
  return matched || { groupKey: null, labelKey: 'admin.nav.dashboard' }
}

export const buildAdminBreadcrumbItems = (path, t) => {
  const current = resolveAdminBreadcrumb(path)
  const items = [{ label: t('admin.nav.dashboard'), to: adminPaths.dashboard }]

  if (current.groupKey) {
    items.push({ label: t(current.groupKey), to: null })
  }

  if (path !== adminPaths.dashboard) {
    items.push({ label: t(current.labelKey), to: path, current: true })
  }

  return items
}
