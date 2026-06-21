import { defineStore } from 'pinia'
import { canAccessAdminSession, ADMIN_SCOPES } from '../utils/adminAccess'
import {
  categoryService,
  locationService,
  postService,
  productService,
  registrationService,
  normalizeStorageAssetUrl,
  resolveBackendAssetUrl,
} from '../services/cmsService'

import { normalizeLeadStatusCode } from '../utils/leadStatus'

const normalizeDate = (value) => {
  if (!value) return ''
  return String(value).replace('T', ' ').slice(0, 16)
}

const slugify = (value) =>
  String(value || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '')

const toDateTime = (value) => {
  if (!value) return null
  const normalized = String(value).trim().replace(' ', 'T')
  return normalized.includes('T') ? normalized : `${normalized}T00:00:00`
}

const isRequestCanceled = (error) =>
  error?.code === 'ERR_CANCELED' ||
  error?.name === 'CanceledError' ||
  ['canceled', 'cancelled', 'request aborted'].includes(String(error?.message || '').toLowerCase())

export const useAppStore = defineStore('app', {
  state: () => ({
    products: [],
    registrations: [],
    posts: [],
    locations: [],
    categories: [],
    loading: {
      products: false,
      registrations: false,
      posts: false,
      locations: false,
      categories: false,
    },
    errors: {
      products: '',
      registrations: '',
      posts: '',
      locations: '',
      categories: '',
    },
  }),
  getters: {
    totalProducts: (state) => state.products.length,
    totalRegistrations: (state) => state.registrations.length,
    newRegistrations: (state) => state.registrations.filter((item) => normalizeLeadStatusCode(item.status) === 'NEW').length,
    contactedRegistrations: (state) =>
      state.registrations.filter((item) => normalizeLeadStatusCode(item.status) === 'CONTACTED').length,
    categoryNameById: (state) => (id) =>
      state.categories.find((category) => Number(category.id) === Number(id))?.name || '',
    categoryIdByName: (state) => (name) =>
      state.categories.find((category) => category.name === name)?.id || null,
  },
  actions: {
    normalizeProduct(product) {
      const imageUrl = resolveBackendAssetUrl(product.imageUrl || product.image || '')
      return {
        ...product,
        image: imageUrl,
        imageUrl,
        price: product.price ?? 0,
        shortDescription: product.shortDescription || '',
        detailContent: product.detailContent || '',
        ingredients: product.ingredients || '',
        tasteProfile: product.tasteProfile || '',
        servingSuggestion: product.servingSuggestion || '',
        gallery: product.gallery || '',
        faqs: product.faqs || '',
        featured: Boolean(product.featured),
        seoTitle: product.seoTitle || '',
        seoDescription: product.seoDescription || '',
        category: product.category || '',
        categoryId: product.categoryId || null,
        sortOrder: Number(product.sortOrder || product.id || 0),
        status: product.status || 'ACTIVE',
        createdAt: normalizeDate(product.createdAt),
        updatedAt: normalizeDate(product.updatedAt),
      }
    },
    normalizeCategory(category) {
      return {
        ...category,
        type: category.type || 'ARTICLE',
        sortOrder: Number(category.sortOrder || category.id || 1),
        parentId: category.parentId || null,
        languageCode: category.languageCode || 'vi',
        status: category.status || 'ACTIVE',
      }
    },
    normalizePost(post) {
      const thumbnailUrl = resolveBackendAssetUrl(post.thumbnailUrl || post.image || '')
      const categoryName =
        post.category ||
        this.categoryNameById(post.categoryId) ||
        ''

      return {
        ...post,
        image: thumbnailUrl,
        thumbnailUrl,
        category: categoryName,
        categoryId: post.categoryId || null,
        author: post.author || 'ALOO Editorial',
        source: post.source || '',
        sourceLink: post.sourceLink || '',
        articleType: post.articleType || 'Bài SEO',
        status: post.status || 'DRAFT',
        publishedAt: normalizeDate(post.publishedAt),
        date: normalizeDate(post.publishedAt),
        tags: Array.isArray(post.tags) ? post.tags : [],
        gallery: Array.isArray(post.gallery) ? post.gallery : [],
        relatedPostIds: Array.isArray(post.relatedPostIds) ? post.relatedPostIds : [],
        metaKeywords: post.metaKeywords || '',
        metaDescription: post.metaDescription || post.seoDescription || '',
        canonicalUrl: post.canonicalUrl || '',
        seoDescription: post.seoDescription || post.metaDescription || '',
      }
    },
    normalizeRegistration(registration) {
      const status = normalizeLeadStatusCode(registration.status)
      return {
        ...registration,
        name: registration.fullName || registration.name || '',
        fullName: registration.fullName || registration.name || '',
        area: registration.province || registration.area || '',
        province: registration.province || registration.area || '',
        capital: registration.expectedBudget ?? registration.capital ?? 0,
        expectedBudget: registration.expectedBudget ?? registration.capital ?? 0,
        createdAt: normalizeDate(registration.createdAt),
        updatedAt: normalizeDate(registration.updatedAt),
        lastContactedAt: normalizeDate(registration.lastContactedAt),
        assignedTo: registration.assignedTo || '',
        status,
      }
    },
    normalizeLocation(location) {
      const imageUrl = resolveBackendAssetUrl(location.coverImageUrl || location.imageUrl || '')
      return {
        ...location,
        storeCode: location.storeCode || '',
        slug: location.slug || '',
        addressText: location.address || location.addressText || '',
        city: location.province || location.city || '',
        province: location.province || location.city || '',
        district: location.district || '',
        ward: location.ward || '',
        latitude: location.latitude ?? null,
        longitude: location.longitude ?? null,
        email: location.email || '',
        storeType: location.storeType || 'STANDARD',
        description: location.description || '',
        coverImageUrl: imageUrl,
        imageUrl,
        galleryJson: location.galleryJson || '[]',
        amenitiesJson: location.amenitiesJson || '[]',
        menuPostersJson: location.menuPostersJson || '[]',
        linksJson: location.linksJson || '[]',
        links: Array.isArray(location.links) ? location.links : [],
        mapUrl: location.mapUrl || location.links?.find?.((link) => link.type === 'GOOGLE_MAPS')?.url || '',
        amenities: Array.isArray(location.amenities) ? location.amenities : [],
        displayOrder: Number(location.displayOrder || location.id || 1),
        featured: Boolean(location.featured),
        status: location.status || 'ACTIVE',
        createdAt: normalizeDate(location.createdAt),
        updatedAt: normalizeDate(location.updatedAt),
      }
    },
    async runLoad(key, request, assign) {
      this.loading[key] = true
      this.errors[key] = ''
      try {
        const { data } = await request()
        assign(Array.isArray(data) ? data : [])
      } catch (error) {
        if (isRequestCanceled(error)) return
        this.errors[key] = error.response?.data?.message || error.message || 'Không tải được dữ liệu'
        throw error
      } finally {
        this.loading[key] = false
      }
    },
    async fetchProducts() {
      await this.runLoad('products', productService.list, (data) => {
        this.products = data.map(this.normalizeProduct)
      })
    },
    async fetchCategories() {
      await this.runLoad('categories', categoryService.list, (data) => {
        this.categories = data.map(this.normalizeCategory)
      })
    },
    async fetchPosts() {
      await this.runLoad('posts', postService.list, (data) => {
        this.posts = data.map((post) => this.normalizePost(post))
      })
    },
    async fetchLocations() {
      await this.runLoad('locations', locationService.list, (data) => {
        this.locations = data.map(this.normalizeLocation)
      })
    },
    async fetchRegistrations() {
      await this.runLoad('registrations', registrationService.list, (data) => {
        this.registrations = data.map(this.normalizeRegistration)
      })
    },
    async fetchPublicData() {
      await Promise.allSettled([
        this.fetchProducts(),
        this.fetchCategories().then(() => this.fetchPosts()),
        this.fetchLocations(),
      ])
    },
    async fetchAdminData() {
      const permissions = canAccessAdminSession()
      const tasks = []

      if (permissions[ADMIN_SCOPES.content]) {
        tasks.push(this.fetchProducts(), this.fetchCategories(), this.fetchPosts())
      }
      if (permissions[ADMIN_SCOPES.stores]) {
        tasks.push(this.fetchLocations())
      }
      if (permissions[ADMIN_SCOPES.crm]) {
        tasks.push(this.fetchRegistrations())
      }

      await Promise.allSettled(tasks)
    },
    buildProductPayload(product) {
      const normalizeGalleryStorage = (gallery) =>
        String(gallery || '')
          .split(/\r?\n/)
          .map((line) => normalizeStorageAssetUrl(line.trim()))
          .filter(Boolean)
          .join('\n')

      return {
        name: product.name?.trim(),
        slug: product.slug?.trim() || slugify(product.name),
        description: product.description?.trim() || '',
        shortDescription: product.shortDescription?.trim() || '',
        detailContent: product.detailContent || '',
        ingredients: product.ingredients || '',
        tasteProfile: product.tasteProfile || '',
        servingSuggestion: product.servingSuggestion || '',
        gallery: normalizeGalleryStorage(product.gallery || ''),
        faqs: product.faqs || '',
        price: 0,
        imageUrl: normalizeStorageAssetUrl(product.imageUrl || product.image || ''),
        categoryId: product.categoryId || null,
        category: product.category || '',
        sortOrder: Number(product.sortOrder || 0),
        featured: Boolean(product.featured),
        seoTitle: product.seoTitle?.trim() || '',
        seoDescription: product.seoDescription?.trim() || '',
        status: product.status || 'ACTIVE',
      }
    },
    async saveProduct(product) {
      const payload = this.buildProductPayload(product)
      const request = product.id ? productService.update(product.id, payload) : productService.create(payload)
      const { data } = await request
      const normalized = this.normalizeProduct(data)
      const index = this.products.findIndex((item) => item.id === normalized.id)
      if (index === -1) this.products.unshift(normalized)
      else this.products.splice(index, 1, normalized)
      return normalized
    },
    async deleteProduct(id) {
      await productService.remove(id)
      this.products = this.products.filter((item) => item.id !== id)
    },
    buildCategoryPayload(category) {
      return {
        name: category.name?.trim(),
        slug: category.slug?.trim() || slugify(category.name),
        type: category.type || 'ARTICLE',
        description: category.description?.trim() || '',
        parentId: category.parentId || null,
        sortOrder: Number(category.sortOrder || 0),
        status: category.status || 'ACTIVE',
        languageCode: category.languageCode || 'vi',
      }
    },
    async saveCategory(category) {
      const payload = this.buildCategoryPayload(category)
      const request = category.id ? categoryService.update(category.id, payload) : categoryService.create(payload)
      const { data } = await request
      const normalized = this.normalizeCategory(data)
      const index = this.categories.findIndex((item) => item.id === normalized.id)
      if (index === -1) this.categories.push(normalized)
      else this.categories.splice(index, 1, normalized)
      return normalized
    },
    async deleteCategory(id) {
      await categoryService.remove(id)
      this.categories = this.categories.filter((item) => item.id !== id)
    },
    buildPostPayload(post) {
      return {
        title: post.title?.trim(),
        slug: post.slug?.trim() || slugify(post.title),
        excerpt: post.excerpt?.trim() || '',
        content: post.content || '',
        thumbnailUrl: post.thumbnailUrl || post.image || '',
        categoryId: post.categoryId || this.categoryIdByName(post.category) || null,
        category: post.category || '',
        author: post.author?.trim() || 'ALOO Editorial',
        source: post.source?.trim() || '',
        sourceLink: post.sourceLink?.trim() || '',
        articleType: post.articleType || '',
        status: post.status || 'DRAFT',
        publishedAt: toDateTime(post.publishedAt),
        seoTitle: post.seoTitle?.trim() || post.title?.trim(),
        seoDescription: post.seoDescription?.trim() || post.metaDescription?.trim() || post.excerpt?.trim() || '',
        metaDescription: post.metaDescription?.trim() || post.seoDescription?.trim() || post.excerpt?.trim() || '',
        metaKeywords: post.metaKeywords?.trim() || '',
        canonicalUrl: post.canonicalUrl?.trim() || '',
        tags: Array.isArray(post.tags) ? post.tags : [],
        gallery: Array.isArray(post.gallery) ? post.gallery : [],
        relatedPostIds: Array.isArray(post.relatedPostIds) ? post.relatedPostIds : [],
      }
    },
    async savePost(post) {
      const payload = this.buildPostPayload(post)
      const request = post.id ? postService.update(post.id, payload) : postService.create(payload)
      const { data } = await request
      const normalized = this.normalizePost(data)
      const index = this.posts.findIndex((item) => item.id === normalized.id)
      if (index === -1) this.posts.unshift(normalized)
      else this.posts.splice(index, 1, normalized)
      return normalized
    },
    async deletePost(id) {
      await postService.remove(id)
      this.posts = this.posts.filter((item) => item.id !== id)
    },
    buildLocationPayload(location) {
      return {
        storeCode: location.storeCode?.trim() || `ALOO-${Date.now()}`,
        name: location.name?.trim(),
        slug: location.slug?.trim() || slugify(location.name),
        address: location.address || location.addressText || '',
        province: location.province || location.city || '',
        district: location.district || '',
        ward: location.ward || '',
        latitude: location.latitude || null,
        longitude: location.longitude || null,
        phone: location.phone || '',
        email: location.email || '',
        openingHours: location.openingHours || '',
        storeType: location.storeType || 'STANDARD',
        description: location.description || '',
        coverImageUrl: location.coverImageUrl || location.imageUrl || '',
        galleryJson: location.galleryJson || '[]',
        amenitiesJson:
          location.amenitiesJson ||
          (Array.isArray(location.amenities) ? JSON.stringify(location.amenities) : '[]'),
        menuPostersJson: location.menuPostersJson || '[]',
        linksJson:
          location.linksJson ||
          (location.mapUrl ? JSON.stringify([{ type: 'GOOGLE_MAPS', title: 'Xem bản đồ', url: location.mapUrl }]) : '[]'),
        displayOrder: Number(location.displayOrder || 0),
        featured: Boolean(location.featured),
        status: location.status || 'ACTIVE',
      }
    },
    async saveLocation(location) {
      const payload = this.buildLocationPayload(location)
      const request = location.id ? locationService.update(location.id, payload) : locationService.create(payload)
      const { data } = await request
      const normalized = this.normalizeLocation(data)
      const index = this.locations.findIndex((item) => item.id === normalized.id)
      if (index === -1) this.locations.push(normalized)
      else this.locations.splice(index, 1, normalized)
      return normalized
    },
    async deleteLocation(id) {
      await locationService.remove(id)
      this.locations = this.locations.filter((item) => item.id !== id)
    },
    async updateRegistrationStatus(registration, status, extra = {}) {
      const apiStatus = normalizeLeadStatusCode(status)
      const { data } = await registrationService.updateStatus(registration.id, apiStatus, extra)
      const normalized = this.normalizeRegistration(data)
      const index = this.registrations.findIndex((item) => item.id === normalized.id)
      if (index !== -1) this.registrations.splice(index, 1, normalized)
      return normalized
    },
    async deleteRegistration(id) {
      await registrationService.remove(id)
      this.registrations = this.registrations.filter((item) => item.id !== id)
    },
    addRegistration(registration) {
      this.registrations.unshift(this.normalizeRegistration(registration))
    },
  },
})



