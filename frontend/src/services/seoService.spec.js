import { describe, expect, it } from 'vitest'
import { resolveRouteSeoMeta, ROUTE_SEO_KEYS } from './seoService'

describe('seoService', () => {
  it('maps known public routes to locale keys', () => {
    expect(ROUTE_SEO_KEYS['/products']).toBe('products')
    expect(ROUTE_SEO_KEYS['/about']).toBe('about')
  })

  it('resolves localized route meta from translate function', () => {
    const translations = {
      'seo.routes.products.title': 'ALOO Menu EN',
      'seo.routes.products.description': 'Explore ALOO products',
    }
    const t = (key) => translations[key] || key

    expect(resolveRouteSeoMeta('/products', t)).toEqual({
      title: 'ALOO Menu EN',
      description: 'Explore ALOO products',
    })
  })

  it('returns null for unknown routes', () => {
    const t = (key) => key
    expect(resolveRouteSeoMeta('/unknown', t)).toBeNull()
  })
})
