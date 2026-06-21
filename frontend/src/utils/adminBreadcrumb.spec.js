import { describe, expect, it } from 'vitest'
import { adminPaths } from '../constants/adminPaths'
import { resolveAdminBreadcrumb } from './adminBreadcrumb'

describe('adminBreadcrumb', () => {
  it('resolves article editor routes', () => {
    expect(resolveAdminBreadcrumb(adminPaths.content.articleNew).labelKey).toBe('admin.breadcrumb.articleNew')
    expect(resolveAdminBreadcrumb(adminPaths.content.articleEdit(12)).labelKey).toBe('admin.breadcrumb.articleEdit')
  })

  it('resolves audit log route', () => {
    expect(resolveAdminBreadcrumb(adminPaths.system.auditLogs).labelKey).toBe('admin.nav.auditLogs')
  })
})
