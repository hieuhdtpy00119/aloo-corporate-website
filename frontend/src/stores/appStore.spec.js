import { beforeEach, describe, expect, it } from 'vitest'
import { createPinia, setActivePinia } from 'pinia'
import { useAppStore } from './appStore'

describe('appStore CRUD payloads', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('preserves product price when building an update payload', () => {
    const store = useAppStore()

    expect(store.buildProductPayload({ name: 'Kem bơ', slug: 'kem-bo', price: 49000 }).price).toBe(49000)
  })

  it('preserves category hierarchy, ordering and language', () => {
    const store = useAppStore()
    const payload = store.buildCategoryPayload({
      name: 'Tin tức',
      slug: 'tin-tuc',
      parentId: 7,
      sortOrder: 3,
      languageCode: 'en',
    })

    expect(payload).toMatchObject({ parentId: 7, sortOrder: 3, languageCode: 'en' })
  })

  it('keeps valid zero coordinates instead of converting them to null', () => {
    const store = useAppStore()
    const payload = store.buildLocationPayload({ name: 'Cửa hàng gốc', latitude: 0, longitude: 0 })

    expect(payload.latitude).toBe(0)
    expect(payload.longitude).toBe(0)
  })

  it('preserves article type in post payloads', () => {
    const store = useAppStore()
    const payload = store.buildPostPayload({ title: 'Bài mới', slug: 'bai-moi', articleType: 'NEWS' })

    expect(payload.articleType).toBe('NEWS')
  })
})
