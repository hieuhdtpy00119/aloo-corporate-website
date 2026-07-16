import { describe, expect, it } from 'vitest'
import { isAdminToken, resolveAuthRedirect } from './authGuard'

const jwt = (payload) => `header.${btoa(JSON.stringify(payload)).replace(/=/g, '')}.signature`

const storageWith = (entries = []) => {
  const values = new Map(entries)
  return {
    getItem: (key) => values.get(key) ?? null,
  }
}

describe('router auth guards', () => {
  it('redirects unauthenticated admin users to the shared login', async () => {
    const storage = storageWith()

    expect(resolveAuthRedirect({ path: '/admin/products', meta: {} }, storage)).toBe('/login?redirect=%2Fadmin%2Fproducts')
  })

  it('allows admin routes when admin token exists', async () => {
    const storage = storageWith([['admin_token', jwt({ role: 'ADMIN', exp: Math.floor(Date.now() / 1000) + 3600 })]])

    expect(resolveAuthRedirect({ path: '/admin/products', meta: {} }, storage)).toBe(true)
  })

  it('redirects expired admin tokens to the shared login', async () => {
    const storage = storageWith([['admin_token', jwt({ role: 'ADMIN', exp: Math.floor(Date.now() / 1000) - 10 })]])

    expect(resolveAuthRedirect({ path: '/admin/products', meta: {} }, storage)).toBe('/login?redirect=%2Fadmin%2Fproducts')
  })

  it('allows authenticated users to open profile without admin role', async () => {
    const storage = storageWith([['admin_token', jwt({ role: 'USER', exp: Math.floor(Date.now() / 1000) + 3600 })]])

    expect(resolveAuthRedirect({ path: '/account', meta: {} }, storage)).toBe(true)
  })

  it('redirects user profile requests away from admin shell', async () => {
    const storage = storageWith([['admin_token', jwt({ role: 'USER', exp: Math.floor(Date.now() / 1000) + 3600 })]])

    expect(resolveAuthRedirect({ path: '/admin/profile', meta: {} }, storage)).toBe('/account')
  })

  it('redirects admin users away from public account page', async () => {
    const storage = storageWith([['admin_token', jwt({ role: 'ADMIN', exp: Math.floor(Date.now() / 1000) + 3600 })]])

    expect(resolveAuthRedirect({ path: '/account', meta: {} }, storage)).toBe('/admin/profile')
  })

  it('redirects authenticated customers away from login', () => {
    const storage = storageWith([['admin_token', jwt({ role: 'USER', exp: Math.floor(Date.now() / 1000) + 3600 })]])

    expect(resolveAuthRedirect({ path: '/login', query: {}, meta: {} }, storage)).toBe('/account')
  })

  it('redirects non-admin users away from cms routes', async () => {
    const storage = storageWith([['admin_token', jwt({ role: 'USER', exp: Math.floor(Date.now() / 1000) + 3600 })]])

    expect(resolveAuthRedirect({ path: '/admin/products', meta: {} }, storage)).toBe('/login?redirect=%2Fadmin%2Fproducts')
  })

  it('rejects tokens without an explicit admin role', () => {
    const token = jwt({ exp: Math.floor(Date.now() / 1000) + 3600 })

    expect(isAdminToken(token)).toBe(false)
  })

  it('restores admin redirect query after login when already authenticated', () => {
    const storage = storageWith([['admin_token', jwt({ role: 'ADMIN', exp: Math.floor(Date.now() / 1000) + 3600 })]])

    expect(
      resolveAuthRedirect({ path: '/login', query: { redirect: '/admin/articles' }, meta: {} }, storage),
    ).toBe('/admin/articles')
  })
})
