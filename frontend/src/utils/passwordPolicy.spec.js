import { describe, expect, it } from 'vitest'
import {
  MIN_PASSWORD_LENGTH,
  getConfirmPasswordErrorKey,
  getCurrentPasswordErrorKey,
  getNewPasswordErrorKey,
  getPasswordStrength,
  getSameAsCurrentPasswordErrorKey,
  isPasswordLongEnough,
  isStrongPassword,
} from './passwordPolicy'

const STRONG_PASSWORD = 'Aloo@123'

describe('passwordPolicy', () => {
  it('requires at least eight characters', () => {
    expect(isPasswordLongEnough('1234567')).toBe(false)
    expect(isPasswordLongEnough('12345678')).toBe(true)
    expect(MIN_PASSWORD_LENGTH).toBe(8)
  })

  it('validates strong password requirements', () => {
    expect(isStrongPassword('password')).toBe(false)
    expect(isStrongPassword(STRONG_PASSWORD)).toBe(true)
  })

  it('returns password strength levels', () => {
    expect(getPasswordStrength('')).toBe('empty')
    expect(getPasswordStrength('abc')).toBe('weak')
    expect(getPasswordStrength('Abcdef1')).toBe('medium')
    expect(getPasswordStrength(STRONG_PASSWORD)).toBe('strong')
  })

  it('returns validation keys for new passwords', () => {
    expect(getNewPasswordErrorKey('')).toBe('admin.password.errors.newRequired')
    expect(getNewPasswordErrorKey('short')).toBe('admin.password.errors.weak')
    expect(getNewPasswordErrorKey(STRONG_PASSWORD)).toBe('')
  })

  it('returns validation keys for confirm passwords', () => {
    expect(getConfirmPasswordErrorKey('secret123', '')).toBe('admin.password.errors.confirmRequired')
    expect(getConfirmPasswordErrorKey('secret123', 'different')).toBe('admin.password.errors.mismatch')
    expect(getConfirmPasswordErrorKey(STRONG_PASSWORD, STRONG_PASSWORD)).toBe('')
  })

  it('returns validation key for missing current password when required', () => {
    expect(getCurrentPasswordErrorKey('', { required: true })).toBe('admin.password.errors.currentRequired')
    expect(getCurrentPasswordErrorKey('', { required: false })).toBe('')
    expect(getCurrentPasswordErrorKey('current')).toBe('')
  })

  it('detects new password same as current password', () => {
    expect(getSameAsCurrentPasswordErrorKey('same', 'same')).toBe('admin.password.errors.sameAsCurrent')
    expect(getSameAsCurrentPasswordErrorKey('old', STRONG_PASSWORD)).toBe('')
  })
})
