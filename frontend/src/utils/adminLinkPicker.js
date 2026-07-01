export const ADMIN_STATIC_PAGE_KEYS = [
  'home',
  'products',
  'locations',
  'franchise',
  'about',
  'blog',
  'consultation',
  'contact',
]

export const ADMIN_STATIC_PAGES = [
  { value: '/', key: 'home' },
  { value: '/products', key: 'products' },
  { value: '/locations', key: 'locations' },
  { value: '/franchise', key: 'franchise' },
  { value: '/about', key: 'about' },
  { value: '/blog', key: 'blog' },
  { value: '/consultation', key: 'consultation' },
  { value: '/contact', key: 'contact' },
]

export const FRANCHISE_HASH_ANCHORS = [
  { value: '#investment', key: 'investment' },
  { value: '#process', key: 'process' },
]

export const inferAdminLinkState = (link, { allowHash = true } = {}) => {
  const normalized = String(link || '').trim()
  const staticValues = ADMIN_STATIC_PAGES.map((item) => item.value)
  const hashValues = FRANCHISE_HASH_ANCHORS.map((item) => item.value)

  if (!normalized) {
    return { type: 'NONE', target: '', custom: '' }
  }

  if (allowHash && hashValues.includes(normalized)) {
    return { type: 'HASH', target: normalized, custom: '' }
  }

  if (staticValues.includes(normalized)) {
    return { type: 'STATIC', target: normalized, custom: '' }
  }

  if (normalized.startsWith('/products/')) {
    return { type: 'PRODUCT', target: normalized.replace('/products/', ''), custom: '' }
  }

  if (normalized.startsWith('/blog/')) {
    return { type: 'POST', target: normalized.replace('/blog/', ''), custom: '' }
  }

  if (allowHash && normalized.startsWith('#')) {
    return { type: 'CUSTOM', target: '', custom: normalized }
  }

  return { type: 'CUSTOM', target: '', custom: normalized }
}

export const resolveAdminLink = ({ type, target, custom }) => {
  if (type === 'NONE') return ''
  if (type === 'STATIC' || type === 'HASH') return String(target || '').trim()
  if (type === 'PRODUCT') return target ? `/products/${target}` : ''
  if (type === 'POST') return target ? `/blog/${target}` : ''
  return String(custom || '').trim()
}

export const isValidAdminLinkUrl = (value) => {
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

export const isActiveProduct = (product) => ['ACTIVE', 'Đang bán'].includes(product?.status)

const publishedPostStatuses = new Set(['Đã đăng', 'Đã xuất bản', 'Published', 'PUBLISHED'])

export const isPublishedPost = (post) => publishedPostStatuses.has(post?.status)
