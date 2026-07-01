export const MIN_PASSWORD_LENGTH = 8

export const SPECIAL_CHAR_PATTERN = /[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?`~]/

export const hasMinLength = (password) => String(password || '').length >= MIN_PASSWORD_LENGTH

export const hasUpperCase = (password) => /[A-Z]/.test(String(password || ''))

export const hasLowerCase = (password) => /[a-z]/.test(String(password || ''))

export const hasNumber = (password) => /\d/.test(String(password || ''))

export const hasSpecialChar = (password) => SPECIAL_CHAR_PATTERN.test(String(password || ''))

export const getPasswordRequirements = (password) => ({
  minLength: hasMinLength(password),
  upperCase: hasUpperCase(password),
  lowerCase: hasLowerCase(password),
  number: hasNumber(password),
  special: hasSpecialChar(password),
})

export const isStrongPassword = (password) => {
  const requirements = getPasswordRequirements(password)
  return (
    requirements.minLength
    && requirements.upperCase
    && requirements.lowerCase
    && requirements.number
    && requirements.special
  )
}

export const getPasswordStrength = (password) => {
  if (!String(password || '').trim()) return 'empty'

  const requirements = getPasswordRequirements(password)
  const score = Object.values(requirements).filter(Boolean).length

  if (score <= 2) return 'weak'
  if (score <= 4) return 'medium'
  return 'strong'
}

export const isPasswordLongEnough = (password) => hasMinLength(password)

export const getNewPasswordErrorKey = (password) => {
  if (!String(password || '').trim()) return 'admin.password.errors.newRequired'
  if (!isStrongPassword(password)) return 'admin.password.errors.weak'
  return ''
}

export const getCurrentPasswordErrorKey = (password, { required = true } = {}) => {
  if (!required) return ''
  if (!String(password || '').trim()) return 'admin.password.errors.currentRequired'
  return ''
}

export const getConfirmPasswordErrorKey = (password, confirm, { touched = true } = {}) => {
  if (!touched && !String(confirm || '').trim()) return ''
  if (!String(confirm || '').trim()) return 'admin.password.errors.confirmRequired'
  if (confirm !== password) return 'admin.password.errors.mismatch'
  return ''
}

export const getSameAsCurrentPasswordErrorKey = (currentPassword, newPassword) => {
  if (currentPassword && newPassword && currentPassword === newPassword) {
    return 'admin.password.errors.sameAsCurrent'
  }
  return ''
}
