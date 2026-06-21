import api from './api'

export const AUTH_PROVIDER_KEY = 'auth_provider'

export const setAuthProvider = (provider) => {
  localStorage.setItem(AUTH_PROVIDER_KEY, provider)
}

export const getAuthProvider = () => localStorage.getItem(AUTH_PROVIDER_KEY) || ''

export const usesGoogleSignIn = () => {
  const provider = getAuthProvider()
  if (provider === 'google') return true
  if (provider === 'local') return false

  try {
    const user = JSON.parse(localStorage.getItem('admin_user') || 'null')
    const avatar = String(user?.avatarUrl || user?.avatar || '')
    return avatar.includes('googleusercontent.com')
  } catch {
    return false
  }
}

export const clearAuthSession = () => {
  localStorage.removeItem('admin_token')
  localStorage.removeItem('admin_user')
  localStorage.removeItem(AUTH_PROVIDER_KEY)
}

export const loginAdmin = (payload) => api.post('/auth/login', payload)

export const getCurrentAdmin = () => api.get('/auth/me')

export const refreshAuthProfile = async () => {
  const { data } = await getCurrentAdmin()
  localStorage.setItem('admin_user', JSON.stringify(data))
  window.dispatchEvent(new Event('aloo-auth-change'))
  return data
}

export const uploadProfileAvatar = async (file) => {
  const formData = new FormData()
  formData.append('file', file)
  const response = await api.post('/auth/profile/avatar', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  })

  return response
}

export const updateAdminProfile = (payload) => api.put('/auth/profile', payload)

export const changeAdminPassword = (payload) => api.put('/auth/change-password', payload)
