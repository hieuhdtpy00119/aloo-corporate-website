import {
  decodeJwtPayload,
  getTokenRole,
  isAdminToken,
  isAuthenticatedToken,
} from '../utils/authToken'

export { decodeJwtPayload, getTokenRole, isAdminToken, isAuthenticatedToken }

const buildLoginRedirect = (to) => {
  const targetPath = to.fullPath || to.path
  if (to.path.startsWith('/admin') && to.path !== '/admin/login') {
    return `/login?redirect=${encodeURIComponent(targetPath)}`
  }
  return '/login'
}

const resolveAdminLoginTarget = (to) => {
  const redirect = to.query?.redirect
  if (typeof redirect === 'string' && redirect.startsWith('/admin')) {
    return redirect
  }
  return '/admin'
}

/** @deprecated Use isAdminToken instead */
export const isValidAdminToken = isAdminToken

export const resolveAuthRedirect = (to, storage = localStorage) => {
  const adminToken = storage.getItem('admin_token')
  const isLogin = to.path === '/login' || to.path === '/admin/login'
  const isOAuthCallback = to.path === '/oauth/callback'
  const isAccountRoute = to.path === '/account'
  const isAdminRoute = to.path.startsWith('/admin') && !isLogin

  if (isOAuthCallback) {
    return true
  }

  if (isLogin) {
    if (isAdminToken(adminToken)) {
      return resolveAdminLoginTarget(to)
    }
    if (isAuthenticatedToken(adminToken)) {
      return '/account'
    }
    return true
  }

  if (isAccountRoute) {
    if (!isAuthenticatedToken(adminToken)) {
      return '/login'
    }
    if (isAdminToken(adminToken)) {
      return '/admin/profile'
    }
    return true
  }

  if (isAdminRoute && !isAdminToken(adminToken)) {
    if (isAuthenticatedToken(adminToken) && to.path === '/admin/profile') {
      return '/account'
    }
    return buildLoginRedirect(to)
  }

  return true
}
