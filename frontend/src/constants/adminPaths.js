export const adminPaths = {
  dashboard: '/admin',
  profile: '/admin/profile',
  content: {
    homeSections: '/admin/content/home-sections',
    products: '/admin/content/products',
    franchise: '/admin/content/franchise',
    articles: '/admin/content/articles',
    articleCategories: '/admin/content/articles/categories',
    articleNew: '/admin/content/articles/new',
    articleEdit: (id) => `/admin/content/articles/${id}/edit`,
  },
  stores: {
    locations: '/admin/stores/locations',
  },
  crm: {
    feedbacks: '/admin/crm/feedbacks',
    leads: '/admin/crm/leads',
    leadDetail: (id) => `/admin/crm/leads?lead=${encodeURIComponent(id)}`,
  },
  system: {
    accounts: '/admin/system/accounts',
    auditLogs: '/admin/system/audit-logs',
  },
}

export const adminLegacyRedirects = {
  '/admin/home-sections': adminPaths.content.homeSections,
  '/admin/products': adminPaths.content.products,
  '/admin/franchise-content': adminPaths.content.franchise,
  '/admin/articles': adminPaths.content.articles,
  '/admin/articles/categories': adminPaths.content.articleCategories,
  '/admin/articles/new': adminPaths.content.articleNew,
  '/admin/categories': adminPaths.content.articleCategories,
  '/admin/locations': adminPaths.stores.locations,
  '/admin/feedbacks': adminPaths.crm.feedbacks,
  '/admin/registrations': adminPaths.crm.leads,
  '/admin/accounts': adminPaths.system.accounts,
}
