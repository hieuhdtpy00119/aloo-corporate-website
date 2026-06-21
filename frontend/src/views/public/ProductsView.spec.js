import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import ProductsView from './ProductsView.vue'
import { useAppStore } from '../../stores/appStore'
import { useProductPageStore } from '../../stores/productPageStore'

const translations = {
  'common.all': 'Tất cả',
  'products.categories': 'Danh mục sản phẩm',
  'products.listEyebrow': 'Danh sách sản phẩm',
  'products.allProducts': 'Tất cả sản phẩm',
  'products.servingCount': '{count} sản phẩm đang phục vụ',
  'products.searchPlaceholder': 'Tìm sản phẩm...',
  'products.explore': 'Khám phá',
  'products.emptyNoMatch': 'Không tìm thấy sản phẩm phù hợp.',
  'products.emptyNoData': 'Chưa có dữ liệu. Vui lòng thêm sản phẩm trong trang quản trị.',
  'products.pageContentErrorHint': 'Không tải được banner/menu từ CMS. Trang vẫn hiển thị danh sách sản phẩm.',
  'products.prev': 'Trước',
  'products.next': 'Sau',
  'products.ctaEyebrow': 'Hợp tác cùng ALOO',
  'products.ctaTitle': 'Một menu tinh gọn, hấp dẫn chính là chìa khóa kinh doanh',
  'products.ctaDescription': 'Menu tập trung',
  'products.ctaButton': 'Đăng ký tư vấn nhượng quyền',
  'products.updatingImage': 'Đang cập nhật ảnh',
  'products.defaultCategory': 'Sản phẩm khác',
  'products.productLabel': 'Sản phẩm',
  'products.carouselPrev': 'Slide trước',
  'products.carouselNext': 'Slide sau',
  'products.carouselDot': 'Chuyển tới slide {index}',
  'products.defaultSlideTitle': 'Kem Bơ ALOO',
  'products.defaultSlideSubtitle': 'Năng lượng xanh',
  'products.defaultSlideDescription': 'Khám phá menu kem bơ.',
  'products.heroLoading': 'Đang tải banner sản phẩm...',
}

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key, params = {}) => {
      const value = translations[key] || key
      return String(value).replace('{count}', params.count ?? '').replace('{index}', params.index ?? '')
    },
  }),
}))

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
    expect(wrapper.text()).toContain('Chưa có dữ liệu')
  })

  it('shows hero skeleton while CMS banners are loading', () => {
    const productPageStore = useProductPageStore()
    productPageStore.loading = true
    productPageStore.heroSlides = []

    const wrapper = mountView()

    expect(wrapper.find('section[aria-busy="true"]').exists()).toBe(true)
  })
})
