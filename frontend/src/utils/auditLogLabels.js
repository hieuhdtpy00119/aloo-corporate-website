const ENTITY_TYPE_KEYS = {
  ADMIN_USER: 'admin.auditLogs.entityTypes.adminUser',
  CUSTOMER_USER: 'admin.auditLogs.entityTypes.customerUser',
  ADMIN_PROFILE: 'admin.auditLogs.entityTypes.adminProfile',
  PRODUCT: 'admin.auditLogs.entityTypes.product',
  POST: 'admin.auditLogs.entityTypes.post',
  CATEGORY: 'admin.auditLogs.entityTypes.category',
  STORE: 'admin.auditLogs.entityTypes.store',
  HOME_SECTION: 'admin.auditLogs.entityTypes.homeSection',
  HERO_BANNER: 'admin.auditLogs.entityTypes.heroBanner',
  MENU_POSTER: 'admin.auditLogs.entityTypes.menuPoster',
  BRAND_TIMELINE: 'admin.auditLogs.entityTypes.brandTimeline',
  FRANCHISE_CONTENT: 'admin.auditLogs.entityTypes.franchiseContent',
  FEEDBACK: 'admin.auditLogs.entityTypes.feedback',
  PRODUCT_REVIEW: 'admin.auditLogs.entityTypes.productReview',
  CONTACT_MESSAGE: 'admin.auditLogs.entityTypes.contactMessage',
  FRANCHISE_REGISTRATION: 'admin.auditLogs.entityTypes.franchiseRegistration',
  FILE: 'admin.auditLogs.entityTypes.file',
}

const KIND_KEYS = {
  product: 'admin.auditLogs.kinds.product',
  post: 'admin.auditLogs.kinds.post',
  category: 'admin.auditLogs.kinds.category',
  store: 'admin.auditLogs.kinds.store',
  'home section': 'admin.auditLogs.kinds.homeSection',
  'hero banner': 'admin.auditLogs.kinds.heroBanner',
  'menu poster': 'admin.auditLogs.kinds.menuPoster',
  'brand timeline': 'admin.auditLogs.kinds.brandTimeline',
  'franchise content': 'admin.auditLogs.kinds.franchiseContent',
  feedback: 'admin.auditLogs.kinds.feedback',
  'product review': 'admin.auditLogs.kinds.productReview',
  'contact message': 'admin.auditLogs.kinds.contactMessage',
  'franchise registration': 'admin.auditLogs.kinds.franchiseRegistration',
  'admin profile': 'admin.auditLogs.kinds.adminProfile',
  file: 'admin.auditLogs.kinds.file',
}

const ACTION_KEYS = {
  CREATE_ADMIN: 'admin.auditLogs.actions.createAdmin',
  UPDATE_ADMIN: 'admin.auditLogs.actions.updateAdmin',
  UPDATE_ADMIN_STATUS: 'admin.auditLogs.actions.updateAdminStatus',
  CHANGE_ADMIN_PASSWORD: 'admin.auditLogs.actions.changeAdminPassword',
  CHANGE_CUSTOMER_PASSWORD: 'admin.auditLogs.actions.changeCustomerPassword',
  CHANGE_OWN_PASSWORD: 'admin.auditLogs.actions.changeOwnPassword',
  DELETE_ADMIN: 'admin.auditLogs.actions.deleteAdmin',
  CREATE_CUSTOMER: 'admin.auditLogs.actions.createCustomer',
  UPDATE_CUSTOMER: 'admin.auditLogs.actions.updateCustomer',
  UPDATE_CUSTOMER_STATUS: 'admin.auditLogs.actions.updateCustomerStatus',
  DELETE_CUSTOMER: 'admin.auditLogs.actions.deleteCustomer',
  PROMOTE_CUSTOMER: 'admin.auditLogs.actions.promoteCustomer',
  DEMOTE_ADMIN: 'admin.auditLogs.actions.demoteAdmin',
  UPLOAD_FILE: 'admin.auditLogs.actions.uploadFile',
}

const LEGACY_DETAIL_PARSERS = {
  CREATE_ADMIN: (details) => {
    const match = details.match(/^Created admin account (.+) with profile (.+)$/i)
    return match ? { key: 'createAdmin', email: match[1], profile: match[2] } : null
  },
  UPDATE_ADMIN: (details) => {
    const match = details.match(/^Updated admin account (.+)$/i)
    return match ? { key: 'updateAdmin', email: match[1] } : null
  },
  UPDATE_ADMIN_STATUS: (details) => {
    const match = details.match(/^Changed status to (.+)$/i)
    return match ? { key: 'updateStatus', status: match[1] } : null
  },
  UPDATE_CUSTOMER_STATUS: (details) => {
    const match = details.match(/^Changed status to (.+)$/i)
    return match ? { key: 'updateStatus', status: match[1] } : null
  },
  CHANGE_ADMIN_PASSWORD: (details) => {
    const match = details.match(/^Password reset for (.+)$/i)
    return match ? { key: 'changeAdminPassword', email: match[1] } : null
  },
  CHANGE_CUSTOMER_PASSWORD: (details) => {
    const match = details.match(/^Password reset for (.+)$/i)
    return match ? { key: 'changeAdminPassword', email: match[1] } : null
  },
  CHANGE_OWN_PASSWORD: (details) => {
    const match = details.match(/^Changed own password for (.+)$/i)
    return match ? { key: 'changeOwnPassword', email: match[1] } : null
  },
  DELETE_ADMIN: (details) => {
    const match = details.match(/^Deleted admin account (.+)$/i)
    return match ? { key: 'deleteAdmin', email: match[1] } : null
  },
  CREATE_CUSTOMER: (details) => {
    const match = details.match(/^Created customer account (.+)$/i)
    return match ? { key: 'createCustomer', email: match[1] } : null
  },
  UPDATE_CUSTOMER: (details) => {
    const match = details.match(/^Updated customer account (.+)$/i)
    return match ? { key: 'updateCustomer', email: match[1] } : null
  },
  DELETE_CUSTOMER: (details) => {
    const match = details.match(/^Deleted customer account (.+)$/i)
    return match ? { key: 'deleteCustomer', email: match[1] } : null
  },
  PROMOTE_CUSTOMER: (details) => {
    const match = details.match(/^Promoted customer (.+) to admin with profile (.+)$/i)
    return match ? { key: 'promoteCustomer', email: match[1], profile: match[2] } : null
  },
  DEMOTE_ADMIN: (details) => {
    const match = details.match(/^Demoted admin (.+) to customer$/i)
    return match ? { key: 'demoteAdmin', email: match[1] } : null
  },
}

const EMAIL_PATTERNS = [
  /account\s+([^\s]+@[^\s]+)/i,
  /customer\s+([^\s]+@[^\s]+)/i,
  /for\s+([^\s]+@[^\s]+)/i,
  /to\s+([^\s]+@[^\s]+)/i,
]

function kindLabel(kind, t) {
  const key = KIND_KEYS[kind.toLowerCase()]
  return key ? t(key) : kind
}

function entityTypeLabel(entityType, t) {
  const key = ENTITY_TYPE_KEYS[entityType]
  return key ? t(key) : entityType || ''
}

function profileLabel(profile, t) {
  const key = `admin.roles.${profile}`
  const label = t(key)
  return label !== key ? label : profile
}

function statusLabel(status, t) {
  const registrationKey = `admin.registrations.status.${status}`
  const registrationLabel = t(registrationKey)
  if (registrationLabel !== registrationKey) return registrationLabel

  const accountKey = `admin.accounts.status.${status}`
  const accountLabel = t(accountKey)
  return accountLabel !== accountKey ? accountLabel : status
}

function parseGenericDetails(details) {
  let match = details.match(/^Created ([a-z ]+) "([^"]*)" \(([^)]*)\)$/i)
  if (match) return { key: 'genericCreate', kind: match[1], name: match[2], ref: match[3] }

  match = details.match(/^Updated ([a-z ]+) "([^"]*)" \(([^)]*)\)$/i)
  if (match) return { key: 'genericUpdate', kind: match[1], name: match[2], ref: match[3] }

  match = details.match(/^Deleted ([a-z ]+) "([^"]*)" \(([^)]*)\)$/i)
  if (match) return { key: 'genericDelete', kind: match[1], name: match[2], ref: match[3] }

  match = details.match(/^Changed status of ([a-z ]+) "([^"]*)" to (.+)$/i)
  if (match) return { key: 'genericStatus', kind: match[1], name: match[2], status: match[3] }

  match = details.match(/^Changed featured flag of ([a-z ]+) "([^"]*)" to (true|false)$/i)
  if (match) return { key: 'genericFeatured', kind: match[1], name: match[2], featured: match[3] === 'true' }

  match = details.match(/^Uploaded file "([^"]*)"$/i)
  if (match) return { key: 'genericUpload', name: match[1] }

  match = details.match(/^Created product (.+) \((.+)\)$/i)
  if (match) return { key: 'genericCreate', kind: 'product', name: match[1], ref: match[2] }

  match = details.match(/^Updated product (.+) \((.+)\)$/i)
  if (match) return { key: 'genericUpdate', kind: 'product', name: match[1], ref: match[2] }

  match = details.match(/^Deleted product (.+) \((.+)\)$/i)
  if (match) return { key: 'genericDelete', kind: 'product', name: match[1], ref: match[2] }

  return null
}

function resolveGenericAction(action, t) {
  const statusMatch = action.match(/^UPDATE_(.+)_STATUS$/)
  if (statusMatch) {
    return t('admin.auditLogs.actions.genericUpdateStatus', {
      entity: entityTypeLabel(statusMatch[1], t),
    })
  }

  const featuredMatch = action.match(/^UPDATE_(.+)_FEATURED$/)
  if (featuredMatch) {
    return t('admin.auditLogs.actions.genericUpdateFeatured', {
      entity: entityTypeLabel(featuredMatch[1], t),
    })
  }

  const crudMatch = action.match(/^(CREATE|UPDATE|DELETE)_(.+)$/)
  if (crudMatch) {
    const verb = crudMatch[1].toLowerCase()
    return t(`admin.auditLogs.actions.generic.${verb}`, {
      entity: entityTypeLabel(crudMatch[2], t),
    })
  }

  return action || '-'
}

export function extractAuditTargetEmail(details) {
  if (!details) return ''
  for (const pattern of EMAIL_PATTERNS) {
    const match = details.match(pattern)
    if (match?.[1]) return match[1]
  }
  return ''
}

export function extractAuditEntityName(details) {
  if (!details) return ''
  const quoted = details.match(/"([^"]+)"/)
  if (quoted?.[1]) return quoted[1]
  const legacyProduct = details.match(/^(?:Created|Updated|Deleted) product (.+) \(/i)
  if (legacyProduct?.[1]) return legacyProduct[1]
  return extractAuditTargetEmail(details)
}

export function formatAuditAction(action, t) {
  const key = ACTION_KEYS[action]
  if (key) return t(key)
  return resolveGenericAction(action, t)
}

export function formatAuditDetails(log, t) {
  const details = log.details || ''
  if (!details) return '-'

  const legacy = LEGACY_DETAIL_PARSERS[log.action]?.(details)
  if (legacy) {
    const params = { ...legacy }
    delete params.key
    if (params.profile) params.profile = profileLabel(params.profile, t)
    if (params.status) params.status = statusLabel(params.status, t)
    return t(`admin.auditLogs.details.${legacy.key}`, params)
  }

  const generic = parseGenericDetails(details)
  if (generic) {
    const params = { ...generic }
    delete params.key
    if (params.kind) params.kind = kindLabel(params.kind, t)
    if (params.status) params.status = statusLabel(params.status, t)
    if (typeof params.featured === 'boolean') {
      params.featured = params.featured
        ? t('admin.auditLogs.featured.on')
        : t('admin.auditLogs.featured.off')
    }
    return t(`admin.auditLogs.details.${generic.key}`, params)
  }

  return details
}

export function formatAuditEntity(log, t) {
  const name = extractAuditEntityName(log.details)
  if (name) return name

  const typeLabel = entityTypeLabel(log.entityType, t)
  return typeLabel || '-'
}
