import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import ProductsView from './ProductsView.vue'
import { useAppStore } from '../../stores/appStore'
import { useProductPageStore } from '../../stores/productPageStore'

describe('ProductsView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  const mountView = () => {
    const store = useAppStore()
    const productPageStore = useProductPageStore()
    vi.spyOn(store, 'fetchProducts').mockResolvedValue()
    vi.spyOn(productPageStore, 'fetchProductPageContent').mockResolvedValue()

    return mount(ProductsView, {
      global: {
        stubs: {
          RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
          ProductHeroSlider: { template: '<section data-test="product-hero" />' },
          IngredientStrengthCards: { template: '<section />' },
          AlooMenuPoster: { template: '<section />' },
          TasteSecretAccordion: { template: '<section />' },
        },
      },
    })
  }

  it('renders active products from the API-backed store', () => {
    const store = useAppStore()
    store.products = [
      {
        id: 1,
        name: 'Kem bơ test',
        slug: 'kem-bo-test',
        description: 'Bơ xay mịn',
        imageUrl: '/uploads/kem-bo.jpg',
        category: 'Kem bơ',
        status: 'ACTIVE',
        sortOrder: 1,
      },
      {
        id: 2,
        name: 'Sản phẩm ẩn',
        status: 'INACTIVE',
      },
    ]

    const wrapper = mountView()

    expect(wrapper.text()).toContain('Kem bơ test')
    expect(wrapper.text()).not.toContain('Sản phẩm ẩn')
  })

  it('renders loading, error and empty states', () => {
    const store = useAppStore()
    store.loading.products = true
    let wrapper = mountView()
    expect(wrapper.find('.animate-pulse').exists()).toBe(true)

    store.loading.products = false
    store.errors.products = 'Không tải được sản phẩm'
    wrapper = mountView()
    expect(wrapper.text()).toContain('Không tải được sản phẩm')

    store.errors.products = ''
    store.products = []
    wrapper = mountView()
    expect(wrapper.text()).toContain('Chưa có sản phẩm nào được hiển thị')
  })
})
