export const FRANCHISE_ADVANTAGE_ICONS = ['product', 'operation', 'cost', 'support', 'marketing', 'brand']

export const FRANCHISE_SINGLETON_SECTIONS = ['hero', 'founder_story', 'cta']

export const FRANCHISE_ADMIN_SECTION_KEYS = [
  'hero',
  'advantages',
  'models',
  'investment',
  'profit',
  'process',
  'founder_story',
  'faq',
  'cta',
]

const CONTENT_PRIMARY_TITLE_KEY = {
  models: 'modelName',
  investment: 'itemName',
  profit: 'metric',
  faq: 'question',
}

export const contentPrimaryTitleKey = (sectionKey) => {
  const schema = FRANCHISE_SECTION_SCHEMAS[sectionKey] || []
  if (schema.some((field) => field.key === 'title')) return 'title'
  return CONTENT_PRIMARY_TITLE_KEY[sectionKey] || null
}

export const isValidFranchiseLinkUrl = (value) => {
  const text = String(value || '').trim()
  if (!text) return true
  if (text.startsWith('#')) return text.length > 1
  if (text.startsWith('/')) return true
  try {
    const url = new URL(text)
    return ['http:', 'https:'].includes(url.protocol)
  } catch {
    return false
  }
}

export const isValidFranchiseAssetUrl = (value) => {
  const text = String(value || '').trim()
  if (!text) return true
  if (text.startsWith('/') || text.startsWith('./')) return true
  if (/^uploads\//i.test(text)) return true
  try {
    const url = new URL(text)
    return ['http:', 'https:'].includes(url.protocol)
  } catch {
    return false
  }
}

export const FRANCHISE_SECTION_SCHEMAS = {
  hero: [
    { key: 'title', type: 'text', required: true },
    { key: 'subtitle', type: 'text' },
    { key: 'description', type: 'textarea', rows: 3 },
    { key: 'image', type: 'image' },
    { key: 'buttonText', type: 'text' },
    { key: 'buttonLink', type: 'url' },
    { key: 'secondaryButtonText', type: 'text' },
    { key: 'secondaryButtonLink', type: 'url' },
  ],
  advantages: [
    { key: 'icon', type: 'select', options: FRANCHISE_ADVANTAGE_ICONS },
    { key: 'title', type: 'text', required: true },
    { key: 'description', type: 'textarea', rows: 3 },
  ],
  models: [
    { key: 'modelName', type: 'text', required: true },
    { key: 'area', type: 'text' },
    { key: 'investment', type: 'text' },
    { key: 'description', type: 'textarea', rows: 3 },
    { key: 'image', type: 'image' },
    { key: 'featured', type: 'checkbox' },
  ],
  investment: [
    { key: 'itemName', type: 'text', required: true },
    { key: 'kioskValue', type: 'text' },
    { key: 'standardValue', type: 'text' },
    { key: 'flagshipValue', type: 'text' },
    { key: 'note', type: 'textarea', rows: 2 },
  ],
  profit: [
    { key: 'metric', type: 'text', required: true },
    { key: 'value', type: 'text' },
    { key: 'description', type: 'textarea', rows: 2 },
  ],
  process: [
    { key: 'stepNumber', type: 'number', min: 1 },
    { key: 'title', type: 'text', required: true },
    { key: 'description', type: 'textarea', rows: 3 },
  ],
  founder_story: [
    { key: 'founderName', type: 'text' },
    { key: 'image', type: 'image' },
    { key: 'title', type: 'text', required: true },
    { key: 'storyContent', type: 'textarea', rows: 5 },
  ],
  faq: [
    { key: 'question', type: 'text', required: true },
    { key: 'answer', type: 'textarea', rows: 4, required: true },
  ],
  cta: [
    { key: 'title', type: 'text', required: true },
    { key: 'description', type: 'textarea', rows: 3 },
    { key: 'buttonText', type: 'text' },
    { key: 'buttonLink', type: 'url' },
  ],
  costs: [
    { key: 'title', type: 'text', required: true },
    { key: 'description', type: 'textarea', rows: 3 },
    { key: 'amount', type: 'text' },
  ],
  benefits: [
    { key: 'title', type: 'text', required: true },
    { key: 'description', type: 'textarea', rows: 3 },
  ],
}

export const defaultFranchiseContentFields = (sectionKey) => {
  const schema = FRANCHISE_SECTION_SCHEMAS[sectionKey] || [{ key: 'body', type: 'textarea', rows: 6 }]
  return Object.fromEntries(
    schema.map((field) => {
      if (field.type === 'checkbox') return [field.key, false]
      if (field.type === 'number') return [field.key, field.key === 'stepNumber' ? 1 : 0]
      if (field.type === 'select' && field.options?.length) return [field.key, field.options[0]]
      return [field.key, '']
    }),
  )
}

export const parseFranchiseContent = (sectionKey, rawContent) => {
  const defaults = defaultFranchiseContentFields(sectionKey)
  if (!rawContent?.trim()) return defaults
  try {
    const parsed = JSON.parse(rawContent)
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) return defaults
    return { ...defaults, ...parsed }
  } catch {
    return defaults
  }
}

export const serializeFranchiseContent = (sectionKey, fields) => {
  const schema = FRANCHISE_SECTION_SCHEMAS[sectionKey] || [{ key: 'body', type: 'textarea' }]
  const payload = {}
  schema.forEach((field) => {
    const value = fields[field.key]
    if (field.type === 'checkbox') {
      payload[field.key] = Boolean(value)
      return
    }
    if (field.type === 'number') {
      payload[field.key] = Number(value || 0)
      return
    }
    payload[field.key] = String(value ?? '').trim()
  })
  return JSON.stringify(payload)
}

export const validateFranchiseContent = (sectionKey, fields) => {
  const schema = FRANCHISE_SECTION_SCHEMAS[sectionKey] || []
  const errors = {}

  schema.forEach((field) => {
    const value = fields[field.key]
    if (field.required && !String(value ?? '').trim()) {
      errors[field.key] = 'required'
      return
    }
    if (field.type === 'url' && String(value ?? '').trim() && !isValidFranchiseLinkUrl(value)) {
      errors[field.key] = 'invalidUrl'
      return
    }
    if (field.type === 'image' && String(value ?? '').trim() && !isValidFranchiseAssetUrl(value)) {
      errors[field.key] = 'invalidImage'
    }
  })

  return errors
}
