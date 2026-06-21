import { adminPaths } from '../constants/adminPaths'
import { getTokenRole, getTokenScopes, isAdminToken } from './authToken'

export const ADMIN_SCOPES = {
  dashboard: 'dashboard',
  content: 'content',
  stores: 'stores',
  crm: 'crm',
  system: 'system',
}

export const PROFILE_SCOPE_MAP = {
  FULL: ['dashboard', 'content', 'stores', 'crm', 'system'],
  CONTENT: ['dashboard', 'content'],
  STORES: ['dashboard', 'stores', 'crm'],
  CRM: ['dashboard', 'crm'],
  SYSTEM: ['dashboard', 'system'],
}

const scopeListToPermissions = (scopes) => ({
  [ADMIN_SCOPES.dashboard]: scopes.includes(ADMIN_SCOPES.dashboard),
  [ADMIN_SCOPES.content]: scopes.includes(ADMIN_SCOPES.content),
  [ADMIN_SCOPES.stores]: scopes.includes(ADMIN_SCOPES.stores),
  [ADMIN_SCOPES.crm]: scopes.includes(ADMIN_SCOPES.crm),
  [ADMIN_SCOPES.system]: scopes.includes(ADMIN_SCOPES.system),
})

const noPermissions = () => ({
  [ADMIN_SCOPES.dashboard]: false,
  [ADMIN_SCOPES.content]: false,
  [ADMIN_SCOPES.stores]: false,
  [ADMIN_SCOPES.crm]: false,
  [ADMIN_SCOPES.system]: false,
})

const readStoredUser = (storage = localStorage) => {
  try {
    return JSON.parse(storage.getItem('admin_user') || 'null')
  } catch {
    return null
  }
}

export const getStoredAdminRole = (storage = localStorage) => {
  const tokenRole = getTokenRole(storage.getItem('admin_token'))
  if (tokenRole) return tokenRole

  const user = readStoredUser(storage)
  return String(user?.role || '').toUpperCase()
}

export const getStoredAdminScopes = (storage = localStorage) => {
  const tokenScopes = getTokenScopes(storage.getItem('admin_token'))
  if (tokenScopes.length) return tokenScopes

  const user = readStoredUser(storage)
  if (Array.isArray(user?.scopes) && user.scopes.length) return user.scopes

  const profile = String(user?.adminProfile || 'FULL').toUpperCase()
  return PROFILE_SCOPE_MAP[profile] || PROFILE_SCOPE_MAP.FULL
}

export const getAdminPermissions = (role, adminProfile = 'FULL', scopes = null) => {
  const normalized = String(role || '').toUpperCase()
  if (!normalized.includes('ADMIN')) return noPermissions()

  if (Array.isArray(scopes) && scopes.length) {
    return scopeListToPermissions(scopes)
  }

  const profile = String(adminProfile || 'FULL').toUpperCase()
  return scopeListToPermissions(PROFILE_SCOPE_MAP[profile] || PROFILE_SCOPE_MAP.FULL)
}

export const resolveAdminScopeForPath = (path) => {
  if (path === adminPaths.dashboard || path === '/admin') return ADMIN_SCOPES.dashboard
  if (path.startsWith('/admin/content')) return ADMIN_SCOPES.content
  if (path.startsWith('/admin/stores')) return ADMIN_SCOPES.stores
  if (path.startsWith('/admin/crm')) return ADMIN_SCOPES.crm
  if (path.startsWith('/admin/system')) return ADMIN_SCOPES.system
  if (path.startsWith('/admin/profile')) return null
  return null
}

export const canAccessAdminPath = (path, permissions) => {
  const scope = resolveAdminScopeForPath(path)
  if (!scope) return true
  return Boolean(permissions?.[scope])
}

export const canAccessAdminSession = (storage = localStorage) => {
  const token = storage.getItem('admin_token')
  if (!isAdminToken(token)) return noPermissions()
  const user = readStoredUser(storage)
  return getAdminPermissions(getStoredAdminRole(storage), user?.adminProfile, getStoredAdminScopes(storage))
}
