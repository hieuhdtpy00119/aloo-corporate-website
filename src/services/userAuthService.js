import api from './api'
import { resolveBackendAssetUrl } from './cmsService'

const authHeader = () => ({
  Authorization: `Bearer ${localStorage.getItem('user_token') || ''}`,
})

export const loginUser = (payload) => api.post('/user-auth/login', payload)

export const getCurrentUser = () => api.get('/user-auth/me', { headers: authHeader() })

export const updateUserProfile = (payload) => api.put('/user-auth/profile', payload, { headers: authHeader() })

export const changeUserPassword = (payload) => api.put('/user-auth/change-password', payload, { headers: authHeader() })

export const uploadUserImage = async (file) => {
  const formData = new FormData()
  formData.append('file', file)
  const response = await api.post('/user-auth/uploads/images', formData, {
    headers: {
      ...authHeader(),
      'Content-Type': 'multipart/form-data',
    },
  })

  return {
    ...response,
    data: {
      ...response.data,
      url: resolveBackendAssetUrl(response.data?.url),
    },
  }
}
