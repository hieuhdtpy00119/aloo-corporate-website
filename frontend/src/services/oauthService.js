import api from './api'

export const googleLoginUrl = () => {
  const apiUrl = api.defaults.baseURL || 'http://localhost:8080/api'
  return apiUrl.replace(/\/api\/?$/, '') + '/oauth2/authorization/google'
}
