import { describe, expect, it } from 'vitest'
import { resolveAuthRedirect } from './authGuard'

const jwt = (payload) => `header.${btoa(JSON.stringify(payload)).replace(/=/g, '')}.signature`

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
    const storage = storageWith([['admin_token', jwt({ role: 'ADMIN', exp: Math.floor(Date.now() / 1000) + 3600 })]])

    expect(resolveAuthRedirect({ path: '/admin/products', meta: {} }, storage)).toBe(true)
  })

  it('redirects expired admin tokens to admin login', async () => {
    const storage = storageWith([['admin_token', jwt({ role: 'ADMIN', exp: Math.floor(Date.now() / 1000) - 10 })]])

    expect(resolveAuthRedirect({ path: '/admin/products', meta: {} }, storage)).toBe('/admin/login')
  })
})
