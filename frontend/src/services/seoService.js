const DEFAULT_TITLE = 'ALOO - Kem Bơ Thuần Việt'
const DEFAULT_DESCRIPTION = 'Website thương hiệu, nhượng quyền và hệ thống cửa hàng ALOO Kem Bơ Thuần Việt.'
const DEFAULT_IMAGE = '/logo-aloo.png'

export const ROUTE_SEO_KEYS = {
  '/': 'home',
  '/products': 'products',
  '/blog': 'blog',
  '/franchise': 'franchise',
  '/locations': 'locations',
  '/contact': 'contact',
  '/about': 'about',
}

const ensureMeta = (selector, createAttributes) => {
  let element = document.head.querySelector(selector)
  if (!element) {
    element = document.createElement('meta')
    Object.entries(createAttributes).forEach(([key, value]) => element.setAttribute(key, value))
    document.head.appendChild(element)
  }
  return element
}

export const setSeoMeta = ({
  title = DEFAULT_TITLE,
  description = DEFAULT_DESCRIPTION,
  image = DEFAULT_IMAGE,
  url = window.location.href,
  type = 'website',
} = {}) => {
  document.title = title
  ensureMeta('meta[name="description"]', { name: 'description' }).setAttribute('content', description)
  ensureMeta('meta[property="og:title"]', { property: 'og:title' }).setAttribute('content', title)
  ensureMeta('meta[property="og:description"]', { property: 'og:description' }).setAttribute('content', description)
  ensureMeta('meta[property="og:image"]', { property: 'og:image' }).setAttribute('content', image)
  ensureMeta('meta[property="og:url"]', { property: 'og:url' }).setAttribute('content', url)
  ensureMeta('meta[property="og:type"]', { property: 'og:type' }).setAttribute('content', type)
}

export const resolveRouteSeoMeta = (path, t) => {
  const routeKey = ROUTE_SEO_KEYS[path]
  if (!routeKey) return null

  return {
    title: t(`seo.routes.${routeKey}.title`),
    description: t(`seo.routes.${routeKey}.description`),
  }
}

export const applyRouteSeo = (path, t) => {
  const meta = resolveRouteSeoMeta(path, t)
  if (meta) setSeoMeta(meta)
}

/** @deprecated Use locale keys under seo.routes.* with applyRouteSeo instead */
export const routeSeo = {
  '/': {
    title: 'ALOO - Kem Bơ Thuần Việt',
    description: 'Thương hiệu kem bơ thuần Việt, phát triển nhượng quyền và hệ thống cửa hàng hiện đại.',
  },
  '/products': {
    title: 'Menu ALOO - Sản phẩm kem bơ',
    description: 'Khám phá menu sản phẩm ALOO dùng để giới thiệu hương vị tại cửa hàng.',
  },
  '/blog': {
    title: 'Blog ALOO - Tin tức thương hiệu và nhượng quyền',
    description: 'Cập nhật câu chuyện thương hiệu, vận hành cửa hàng và kinh nghiệm nhượng quyền ALOO.',
  },
  '/franchise': {
    title: 'Nhượng quyền ALOO',
    description: 'Thông tin mô hình nhượng quyền ALOO cho nhà đầu tư địa phương.',
  },
  '/locations': {
    title: 'Hệ thống cửa hàng ALOO',
    description: 'Tìm cửa hàng ALOO, địa chỉ, hotline, giờ mở cửa và Google Maps.',
  },
  '/contact': {
    title: 'Liên hệ ALOO',
    description: 'Kết nối với ALOO để được tư vấn thương hiệu, cửa hàng và nhượng quyền.',
  },
  '/about': {
    title: 'Về ALOO - Câu chuyện thương hiệu kem bơ',
    description: 'Hành trình ALOO từ 2013, giá trị cốt lõi, lộ trình phát triển và hệ sinh thái kem bơ thuần Việt.',
  },
}
