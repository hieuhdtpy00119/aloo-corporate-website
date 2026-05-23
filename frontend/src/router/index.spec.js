import { describe, expect, it } from 'vitest'
import { resolveAuthRedirect } from './authGuard'

const storageWith = (entries = []) => {
  const values = new Map(entries)
  return {
    getItem: (key) => values.get(key) ?? null,
  }
}

describe('router auth guards', () => {
  it('redirects unauthenticated admin users to admin login', async () => {
    const storage = storageWith()

    expect(resolveAuthRedirect({ path: '/admin/products', meta: {} }, storage)).toBe('/admin/login')
  })

  it('allows admin routes when admin token exists', async () => {
    const storage = storageWith([['admin_token', 'valid.jwt.token']])

    expect(resolveAuthRedirect({ path: '/admin/products', meta: {} }, storage)).toBe(true)
  })

  it('redirects unauthenticated user profile routes to user login', async () => {
    const storage = storageWith()

    expect(resolveAuthRedirect({ path: '/profile', meta: { requiresUser: true } }, storage)).toBe('/login')
  })

  it('redirects logged-in users away from user login', async () => {
    const storage = storageWith([['user_token', 'valid.user.jwt']])

    expect(resolveAuthRedirect({ path: '/login', meta: {} }, storage)).toBe('/profile')
  })

  it('redirects logged-in admins away from user login', async () => {
    const storage = storageWith([['admin_token', 'valid.admin.jwt']])

    expect(resolveAuthRedirect({ path: '/login', meta: {} }, storage)).toBe('/admin')
  })
})
