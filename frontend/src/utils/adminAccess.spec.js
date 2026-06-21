import { describe, expect, it } from 'vitest'
import { adminPaths } from '../constants/adminPaths'
import {
  ADMIN_SCOPES,
  canAccessAdminPath,
  getAdminPermissions,
  resolveAdminScopeForPath,
} from './adminAccess'

describe('adminAccess', () => {
  it('grants full cms permissions to admin role', () => {
    const permissions = getAdminPermissions('ADMIN', 'FULL')

    expect(permissions[ADMIN_SCOPES.system]).toBe(true)
    expect(permissions[ADMIN_SCOPES.content]).toBe(true)
  })

  it('limits permissions for content profile', () => {
    const permissions = getAdminPermissions('ADMIN', 'CONTENT')

    expect(permissions[ADMIN_SCOPES.content]).toBe(true)
    expect(permissions[ADMIN_SCOPES.system]).toBe(false)
  })

  it('maps canonical paths to scopes', () => {
    expect(resolveAdminScopeForPath(adminPaths.content.articles)).toBe(ADMIN_SCOPES.content)
    expect(resolveAdminScopeForPath(adminPaths.crm.leads)).toBe(ADMIN_SCOPES.crm)
    expect(resolveAdminScopeForPath(adminPaths.system.accounts)).toBe(ADMIN_SCOPES.system)
    expect(resolveAdminScopeForPath(adminPaths.profile)).toBeNull()
  })

  it('blocks system routes when system scope is disabled', () => {
    const permissions = {
      ...getAdminPermissions('ADMIN', 'FULL'),
      [ADMIN_SCOPES.system]: false,
    }

    expect(canAccessAdminPath(adminPaths.system.accounts, permissions)).toBe(false)
    expect(canAccessAdminPath(adminPaths.content.products, permissions)).toBe(true)
  })
})
