export const MIN_PASSWORD_LENGTH = 8

export const isPasswordLongEnough = (password) =>
  String(password || '').trim().length >= MIN_PASSWORD_LENGTH

export const getNewPasswordErrorKey = (password) => {
  if (!String(password || '').trim()) return 'admin.password.errors.newRequired'
  if (!isPasswordLongEnough(password)) return 'admin.password.errors.minLength'
  return ''
}

export const getCurrentPasswordErrorKey = (password) => {
  if (!String(password || '').trim()) return 'admin.password.errors.currentRequired'
  return ''
}

export const getConfirmPasswordErrorKey = (password, confirm) => {
  if (!String(confirm || '').trim()) return 'admin.password.errors.confirmRequired'
  if (confirm !== password) return 'admin.password.errors.mismatch'
  return ''
}
