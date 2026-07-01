export function isGoogleManagedAccount(user) {
  if (!user) return false
  if (user.authProvider === 'GOOGLE') return true
  return String(user.avatarUrl || '').includes('googleusercontent.com')
}

export function getStoredSessionUser() {
  try {
    return JSON.parse(localStorage.getItem('admin_user') || 'null')
  } catch {
    return null
  }
}

export function isCurrentSessionUser(user) {
  if (!user) return false
  const current = getStoredSessionUser()
  if (!current) return false
  if (user.id != null && current.id != null) {
    return Number(user.id) === Number(current.id)
  }
  const userEmail = String(user.email || '').trim().toLowerCase()
  const currentEmail = String(current.email || '').trim().toLowerCase()
  return Boolean(userEmail) && userEmail === currentEmail
}
