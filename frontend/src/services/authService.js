import api from './api'

export const loginAdmin = (payload) => api.post('/auth/login', payload)

export const getCurrentAdmin = () => api.get('/auth/me')

export const updateAdminProfile = (payload) => api.put('/auth/profile', payload)

export const changeAdminPassword = (payload) => api.put('/auth/change-password', payload)
