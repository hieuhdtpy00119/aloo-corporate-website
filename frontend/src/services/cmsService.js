import api from './api'

const backendOrigin = () => (api.defaults.baseURL || '').replace(/\/api\/?$/, '')

export const resolveBackendAssetUrl = (url) => {
  if (!url || String(url).startsWith('data:') || /^https?:\/\//i.test(String(url))) return url || ''
  if (String(url).startsWith('/uploads/')) return `${backendOrigin()}${url}`
  return url
}

export const uploadService = {
  image: async (file) => {
    const formData = new FormData()
    formData.append('file', file)
    const response = await api.post('/uploads/images', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    })

    return {
      ...response,
      data: {
        ...response.data,
        url: resolveBackendAssetUrl(response.data?.url),
      },
    }
  },
}

export const productService = {
  list: () => api.get('/products'),
  get: (id) => api.get(`/products/${id}`),
  getBySlug: (slug) => api.get(`/products/slug/${slug}`),
  create: (payload) => api.post('/products', payload),
  update: (id, payload) => api.put(`/products/${id}`, payload),
  remove: (id) => api.delete(`/products/${id}`),
}

export const postService = {
  list: () => api.get('/posts'),
  get: (id) => api.get(`/posts/${id}`),
  getBySlug: (slug) => api.get(`/posts/slug/${slug}`),
  create: (payload) => api.post('/posts', payload),
  update: (id, payload) => api.put(`/posts/${id}`, payload),
  remove: (id) => api.delete(`/posts/${id}`),
}

export const categoryService = {
  list: () => api.get('/categories'),
  create: (payload) => api.post('/categories', payload),
  update: (id, payload) => api.put(`/categories/${id}`, payload),
  remove: (id) => api.delete(`/categories/${id}`),
}

export const registrationService = {
  list: () => api.get('/franchise-registrations'),
  get: (id) => api.get(`/franchise-registrations/${id}`),
  create: (payload) => api.post('/franchise-registrations', payload),
  updateStatus: (id, status) => api.patch(`/franchise-registrations/${id}/status`, { status }),
  remove: (id) => api.delete(`/franchise-registrations/${id}`),
}

export const locationService = {
  list: () => api.get('/locations'),
  create: (payload) => api.post('/locations', payload),
  update: (id, payload) => api.put(`/locations/${id}`, payload),
  remove: (id) => api.delete(`/locations/${id}`),
}

export const franchiseContentService = {
  list: () => api.get('/franchise-contents'),
  update: (id, payload) => api.put(`/franchise-contents/${id}`, payload),
}

export const homeSectionService = {
  list: (activeOnly = false) => api.get('/home-sections', { params: { activeOnly } }),
  get: (id) => api.get(`/home-sections/${id}`),
  create: (payload) => api.post('/home-sections', payload),
  update: (id, payload) => api.put(`/home-sections/${id}`, payload),
  remove: (id) => api.delete(`/home-sections/${id}`),
}
export const heroBannerService = {
  list: () => api.get('/hero-banners'),
  get: (id) => api.get(`/hero-banners/${id}`),
  create: (payload) => api.post('/hero-banners', payload),
  update: (id, payload) => api.put(`/hero-banners/${id}`, payload),
  remove: (id) => api.delete(`/hero-banners/${id}`),
}

export const menuPosterService = {
  list: () => api.get('/menu-posters'),
  get: (id) => api.get(`/menu-posters/${id}`),
  create: (payload) => api.post('/menu-posters', payload),
  update: (id, payload) => api.put(`/menu-posters/${id}`, payload),
  remove: (id) => api.delete(`/menu-posters/${id}`),
}

export const accountService = {
  listAdmins: () => api.get('/accounts/admins'),
  createAdmin: (payload) => api.post('/accounts/admins', payload),
  updateAdmin: (id, payload) => api.put(`/accounts/admins/${id}`, payload),
  updateAdminStatus: (id, status) => api.patch(`/accounts/admins/${id}/status`, { status }),
  changeAdminPassword: (id, password) => api.put(`/accounts/admins/${id}/password`, { password }),
  removeAdmin: (id) => api.delete(`/accounts/admins/${id}`),
  listCustomers: () => api.get('/accounts/customers'),
  createCustomer: (payload) => api.post('/accounts/customers', payload),
  updateCustomer: (id, payload) => api.put(`/accounts/customers/${id}`, payload),
  updateCustomerStatus: (id, status) => api.patch(`/accounts/customers/${id}/status`, { status }),
  changeCustomerPassword: (id, password) => api.put(`/accounts/customers/${id}/password`, { password }),
  removeCustomer: (id) => api.delete(`/accounts/customers/${id}`),
}

export const contactMessageService = {
  list: () => api.get('/contact-messages'),
  get: (id) => api.get(`/contact-messages/${id}`),
  create: (payload) => api.post('/contact-messages', payload),
  updateStatus: (id, status) => api.patch(`/contact-messages/${id}/status`, { status }),
  remove: (id) => api.delete(`/contact-messages/${id}`),
}

export const brandTimelineService = {
  list: (activeOnly = false) => api.get('/brand-timelines', { params: { activeOnly } }),
  get: (id) => api.get(`/brand-timelines/${id}`),
  create: (payload) => api.post('/brand-timelines', payload),
  update: (id, payload) => api.put(`/brand-timelines/${id}`, payload),
  remove: (id) => api.delete(`/brand-timelines/${id}`),
}

