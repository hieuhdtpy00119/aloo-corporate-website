import { describe, expect, it } from 'vitest'
import {
  MIN_PASSWORD_LENGTH,
  getConfirmPasswordErrorKey,
  getCurrentPasswordErrorKey,
  getNewPasswordErrorKey,
  isPasswordLongEnough,
} from './passwordPolicy'

describe('passwordPolicy', () => {
  it('requires at least eight characters', () => {
    expect(isPasswordLongEnough('1234567')).toBe(false)
    expect(isPasswordLongEnough('12345678')).toBe(true)
    expect(MIN_PASSWORD_LENGTH).toBe(8)
  })

  it('returns validation keys for new passwords', () => {
    expect(getNewPasswordErrorKey('')).toBe('admin.password.errors.newRequired')
    expect(getNewPasswordErrorKey('short')).toBe('admin.password.errors.minLength')
    expect(getNewPasswordErrorKey('long-enough')).toBe('')
  })

  it('returns validation keys for confirm passwords', () => {
    expect(getConfirmPasswordErrorKey('secret123', '')).toBe('admin.password.errors.confirmRequired')
    expect(getConfirmPasswordErrorKey('secret123', 'different')).toBe('admin.password.errors.mismatch')
    expect(getConfirmPasswordErrorKey('secret123', 'secret123')).toBe('')
  })

  it('returns validation key for missing current password', () => {
    expect(getCurrentPasswordErrorKey('')).toBe('admin.password.errors.currentRequired')
    expect(getCurrentPasswordErrorKey('current')).toBe('')
  })
})
