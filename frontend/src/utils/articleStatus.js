export const ARTICLE_STATUS_CODES = ['DRAFT', 'PENDING', 'REVIEWING', 'APPROVED', 'PUBLISHED', 'ARCHIVED']

export const ARTICLE_STATUS_LABELS = {
  DRAFT: 'Nháp',
  PENDING: 'Chờ duyệt',
  REVIEWING: 'Đang rà soát',
  APPROVED: 'Đã duyệt',
  PUBLISHED: 'Đã xuất bản',
  ARCHIVED: 'Lưu trữ',
  'Bản nháp': 'Nháp',
  'Lên lịch': 'Chờ duyệt',
  'Đã đăng': 'Đã xuất bản',
  Ẩn: 'Lưu trữ',
}

export const ARTICLE_STATUS_FILTER_VALUES = {
  Nháp: 'DRAFT',
  'Chờ duyệt': 'PENDING',
  'Đang rà soát': 'REVIEWING',
  'Đang review': 'REVIEWING',
  'Đã duyệt': 'APPROVED',
  'Đã xuất bản': 'PUBLISHED',
  'Lưu trữ': 'ARCHIVED',
}

export const pendingArticleStatuses = new Set(['DRAFT', 'PENDING', 'REVIEWING'])

export const normalizeArticleStatus = (status) => {
  if (status === 'Đã đăng') return 'PUBLISHED'
  if (status === 'Bản nháp') return 'DRAFT'
  if (status === 'Lên lịch') return 'PENDING'
  if (status === 'Ẩn') return 'ARCHIVED'
  return status || 'DRAFT'
}

export const articleStatusLabelKey = (status) => {
  const code = normalizeArticleStatus(status)
  return `admin.articleEditor.statuses.${code}`
}

export const articleStatusLabel = (status, translate) => {
  if (typeof translate === 'function') {
    const key = articleStatusLabelKey(status)
    const translated = translate(key)
    if (translated !== key) return translated
  }
  return ARTICLE_STATUS_LABELS[status] || ARTICLE_STATUS_LABELS[normalizeArticleStatus(status)] || status
}

export const articleStatusFilterOptions = (translate) => [
  translate('admin.shared.all'),
  ...ARTICLE_STATUS_CODES.map((code) => translate(`admin.articleEditor.statuses.${code}`)),
]

export const articleStatusFilterValue = (label, translate) => {
  if (label === translate('admin.shared.all')) return 'ALL'
  const match = ARTICLE_STATUS_CODES.find(
    (code) => translate(`admin.articleEditor.statuses.${code}`) === label,
  )
  return match || label
}

export const getArticleStatusBadgeClass = (status) => {
  switch (normalizeArticleStatus(status)) {
    case 'PUBLISHED':
      return 'border-avocado-200 bg-avocado-50 text-avocado-700'
    case 'APPROVED':
      return 'border-emerald-200 bg-emerald-50 text-emerald-700'
    case 'REVIEWING':
      return 'border-orange-200 bg-orange-50 text-orange-700'
    case 'PENDING':
      return 'border-blue-200 bg-blue-50 text-blue-700'
    case 'ARCHIVED':
      return 'border-slate-200 bg-slate-100 text-slate-600'
    default:
      return 'border-amber-200 bg-amber-50 text-amber-700'
  }
}
