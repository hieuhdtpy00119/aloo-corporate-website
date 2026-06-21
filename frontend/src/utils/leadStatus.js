export const LEAD_STATUS_CODES = ['NEW', 'CONTACTED', 'CONSULTING', 'POTENTIAL', 'SIGNED', 'REJECTED']

const LEGACY_STATUS_TO_CODE = {
  NEW: 'NEW',
  CONTACTED: 'CONTACTED',
  CONSULTING: 'CONSULTING',
  POTENTIAL: 'POTENTIAL',
  SIGNED: 'SIGNED',
  REJECTED: 'REJECTED',
  DONE: 'SIGNED',
  COMPLETED: 'SIGNED',
  CANCELED: 'REJECTED',
  CANCELLED: 'REJECTED',
  Mới: 'NEW',
  'Đã liên hệ': 'CONTACTED',
  'Đang tư vấn': 'CONSULTING',
  'Tiềm năng': 'POTENTIAL',
  'Đã ký': 'SIGNED',
  'Từ chối': 'REJECTED',
}

export const normalizeLeadStatusCode = (status) => {
  if (!status) return 'NEW'
  const value = String(status).trim()
  if (LEGACY_STATUS_TO_CODE[value]) return LEGACY_STATUS_TO_CODE[value]
  const upper = value.toUpperCase()
  if (LEAD_STATUS_CODES.includes(upper)) return upper
  return 'NEW'
}

export const leadStatusLabelKey = (status) => `admin.leads.status.${normalizeLeadStatusCode(status)}`

export const leadStatusLabel = (status, translate) => translate(leadStatusLabelKey(status))

/** @deprecated Use leadStatusLabel with i18n */
export const normalizeLeadStatus = (status) => normalizeLeadStatusCode(status)

export const isLeadNeedingAction = (status) => {
  const code = normalizeLeadStatusCode(status)
  return code === 'NEW' || code === 'CONSULTING'
}

export const leadStatusPriority = {
  NEW: 0,
  CONSULTING: 1,
  CONTACTED: 2,
  POTENTIAL: 3,
  SIGNED: 4,
  REJECTED: 5,
}

export const getLeadStatusPriority = (status) => leadStatusPriority[normalizeLeadStatusCode(status)] ?? 9

export const getLeadStatusBadgeClass = (status) => {
  switch (normalizeLeadStatusCode(status)) {
    case 'NEW':
      return 'bg-blue-50 text-blue-700 ring-1 ring-blue-100'
    case 'CONTACTED':
      return 'bg-emerald-50 text-emerald-700 ring-1 ring-emerald-100'
    case 'CONSULTING':
      return 'bg-amber-50 text-amber-700 ring-1 ring-amber-100'
    case 'POTENTIAL':
      return 'bg-orange-50 text-orange-700 ring-1 ring-orange-100'
    case 'SIGNED':
      return 'bg-purple-50 text-purple-700 ring-1 ring-purple-100'
    case 'REJECTED':
      return 'bg-slate-100 text-slate-600 ring-1 ring-slate-200'
    default:
      return 'bg-slate-100 text-slate-600 ring-1 ring-slate-200'
  }
}

export const getLeadStatusSelectClass = (status) => {
  switch (normalizeLeadStatusCode(status)) {
    case 'NEW':
      return 'bg-blue-50 text-blue-700 border-blue-200'
    case 'CONTACTED':
      return 'bg-emerald-50 text-emerald-700 border-emerald-200'
    case 'CONSULTING':
      return 'bg-amber-50 text-amber-700 border-amber-200'
    case 'POTENTIAL':
      return 'bg-orange-50 text-orange-700 border-orange-200'
    case 'SIGNED':
      return 'bg-purple-50 text-purple-700 border-purple-200'
    case 'REJECTED':
      return 'bg-red-50 text-red-700 border-red-200'
    default:
      return 'bg-slate-50 text-slate-700 border-slate-200'
  }
}
