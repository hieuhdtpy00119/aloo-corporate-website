import { describe, expect, it } from 'vitest'
import { adminLegacyRedirects, adminPaths } from './adminPaths'

describe('adminPaths', () => {
  it('defines canonical enterprise admin routes', () => {
    expect(adminPaths.content.products).toBe('/admin/content/products')
    expect(adminPaths.crm.leads).toBe('/admin/crm/leads')
    expect(adminPaths.system.accounts).toBe('/admin/system/accounts')
  })

  it('maps legacy routes to canonical paths', () => {
    expect(adminLegacyRedirects['/admin/products']).toBe(adminPaths.content.products)
    expect(adminLegacyRedirects['/admin/registrations']).toBe(adminPaths.crm.leads)
    expect(adminLegacyRedirects['/admin/franchise-content']).toBe(adminPaths.content.franchise)
  })
})
