import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:8080/api',
  timeout: 15000,
})

api.interceptors.request.use((config) => {
  if (config.headers.Authorization) {
    return config
  }

  const url = String(config.url || '')
  const token = url.startsWith('/user-auth')
    ? localStorage.getItem('user_token')
    : localStorage.getItem('admin_token')

  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      const path = window.location.pathname
      const requestUrl = String(error.config?.url || '')

      if (requestUrl.startsWith('/user-auth')) {
        localStorage.removeItem('user_token')
        localStorage.removeItem('user_user')
      } else {
        localStorage.removeItem('admin_token')
        localStorage.removeItem('admin_user')
      }

      window.dispatchEvent(new Event('aloo-auth-change'))

      if (path.startsWith('/admin') && path !== '/admin/login') {
        window.location.assign('/admin/login')
      } else if ((path === '/profile' || path === '/change-password') && path !== '/login') {
        window.location.assign('/login')
      }
    }

    return Promise.reject(error)
  },
)

export default api
