export const resolveAuthRedirect = (to, storage = localStorage) => {
  const adminToken = storage.getItem('admin_token')
  const isAdminLogin = to.path === '/admin/login'
  const isAdminRoute = to.path.startsWith('/admin') && !isAdminLogin

  if (isAdminLogin) {
    return true
  }

  if (isAdminRoute && !isValidAdminToken(adminToken)) {
    return '/admin/login'
  }

  return true
}

const decodeJwtPayload = (token) => {
  try {
    const payload = String(token || '').split('.')[1]
    if (!payload) return null
    const normalized = payload.replace(/-/g, '+').replace(/_/g, '/')
    const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, '=')
    return JSON.parse(atob(padded))
  } catch {
    return null
  }
}

export const isValidAdminToken = (token) => {
  const payload = decodeJwtPayload(token)
  if (!payload) return false
  if (payload.exp && payload.exp * 1000 <= Date.now()) return false
  const role = String(payload.role || payload.authorities || payload.scope || '').toUpperCase()
  return !role || role.includes('ADMIN')
}
