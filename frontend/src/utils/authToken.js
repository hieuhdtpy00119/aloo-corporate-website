export const decodeJwtPayload = (token) => {
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

export const getTokenRole = (token) => {
  const payload = decodeJwtPayload(token)
  if (!payload) return ''
  return String(payload.role || payload.authorities || payload.scope || '').toUpperCase()
}

export const getTokenScopes = (token) => {
  const payload = decodeJwtPayload(token)
  if (!payload) return []
  return Array.isArray(payload.scopes) ? payload.scopes : []
}

export const isAuthenticatedToken = (token) => {
  const payload = decodeJwtPayload(token)
  if (!payload) return false
  if (payload.exp && payload.exp * 1000 <= Date.now()) return false
  return true
}

export const isAdminToken = (token) => {
  if (!isAuthenticatedToken(token)) return false
  const role = getTokenRole(token)
  return Boolean(role && role.includes('ADMIN'))
}
