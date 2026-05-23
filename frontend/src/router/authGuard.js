export const resolveAuthRedirect = (to, storage = localStorage) => {
  const adminToken = storage.getItem('admin_token')
  const userToken = storage.getItem('user_token')
  const isUserLogin = to.path === '/login'
  const isAdminLogin = to.path === '/admin/login'
  const isAdminRoute = to.path.startsWith('/admin') && !isAdminLogin

  if (isUserLogin && userToken) {
    return '/profile'
  }

  if (isUserLogin && adminToken) {
    return '/admin'
  }

  if (isAdminLogin) {
    return true
  }

  if (isAdminRoute && !adminToken) {
    return '/admin/login'
  }

  if (to.meta?.requiresUser && !userToken) {
    return '/login'
  }

  return true
}
