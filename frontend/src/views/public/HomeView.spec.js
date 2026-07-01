import { mount, flushPromises } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import HomeView from './HomeView.vue'
import { useAppStore } from '../../stores/appStore'

const translations = {
  'home.heroHeadline': 'Vị béo tự nhiên, mát lành từng ly',
  'home.heroBadge': 'Kem bơ thuần Việt',
  'home.heroDescription': 'Khám phá thực đơn signature hoặc tìm hiểu mô hình nhượng quyền ALOO gần bạn.',
  'home.heroCtaProducts': 'Xem sản phẩm',
  'home.heroCtaFranchise': 'Nhượng quyền',
  'home.heroVideoLabel': 'ALOO Kem Bơ Thuần Việt',
  'home.featuredEyebrow': 'Tuyển chọn',
  'home.featuredTitle': 'Nổi bật hôm nay',
  'home.featuredSubtitle': 'Bí quyết tự nhiên từ nguyên liệu vườn sạch',
  'home.featuredScrollLeft': 'Cuộn nổi bật sang trái',
  'home.featuredScrollRight': 'Cuộn nổi bật sang phải',
  'home.featuredEmpty': 'Chưa có nội dung nổi bật. Vào admin để thêm block trang chủ.',
  'home.featuredErrorHint': 'Không tải được nội dung nổi bật. Trang vẫn hiển thị sản phẩm và cửa hàng.',
  'home.featuredDefaultCta': 'Xem thêm',
  'home.featuredDefaultBadge': 'Nổi bật',
  'home.popularEyebrow': 'Món ngon nước tiếng',
  'home.popularTitle': 'Sản phẩm được yêu thích',
  'home.scrollLeft': 'Cuộn trái',
  'home.scrollRight': 'Cuộn phải',
  'home.viewDetail': 'Xem chi tiết',
  'home.productsEmpty': 'Chưa có sản phẩm đang bán. Vào admin để thêm hoặc bật trạng thái sản phẩm.',
  'home.productMetaFallback': 'ALOO Signature',
}

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => translations[key] || key,
  }),
}))

const homeSectionListMock = vi.fn()

vi.mock('../../services/cmsService', () => ({
  homeSectionService: {
    list: (...args) => homeSectionListMock(...args),
  },
  resolveBackendAssetUrl: (url) => url || '',
}))

describe('HomeView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    homeSectionListMock.mockReset()
    homeSectionListMock.mockResolvedValue({ data: [] })
  })

  const mountView = () => {
    const store = useAppStore()
    vi.spyOn(store, 'fetchProducts').mockResolvedValue()
    vi.spyOn(store, 'fetchLocations').mockResolvedValue()

    return mount(HomeView, {
      global: {
        stubs: {
          RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
        },
      },
    })
  }

  it('renders hero video', () => {
    const wrapper = mountView()

    expect(wrapper.find('video').exists()).toBe(true)
  })

  it('shows skeleton when loading products', () => {
    const store = useAppStore()
    store.loading.products = true

    const wrapper = mountView()

    expect(wrapper.find('.product-scrollbar .animate-pulse').exists()).toBe(true)
  })

  it('shows featured empty state', async () => {
    const wrapper = mountView()

    await flushPromises()

    expect(wrapper.text()).toContain('Chưa có nội dung nổi bật. Vào admin để thêm block trang chủ.')
  })

  it('hides featured CTA when block has no button link', async () => {
    homeSectionListMock.mockResolvedValue({
      data: [
        {
          id: 1,
          status: 'ACTIVE',
          sortOrder: 0,
          title: 'Block không nút',
          description: 'Mô tả block',
          buttonText: '',
          buttonLink: '',
        },
      ],
    })

    const wrapper = mountView()
    await flushPromises()

    expect(wrapper.text()).toContain('Block không nút')
    expect(wrapper.text()).not.toContain('Xem thêm')
  })

  it('renders external featured links as anchors', async () => {
    homeSectionListMock.mockResolvedValue({
      data: [
        {
          id: 2,
          status: 'ACTIVE',
          sortOrder: 0,
          title: 'Block ngoài',
          description: 'Mô tả',
          buttonText: 'Mở Maps',
          buttonLink: 'https://maps.google.com/example',
        },
      ],
    })

    const wrapper = mountView()
    await flushPromises()

    const externalLink = wrapper.find('a[href="https://maps.google.com/example"]')
    expect(externalLink.exists()).toBe(true)
    expect(externalLink.attributes('target')).toBe('_blank')
  })

  it('renders CTA card layout with lime button', async () => {
    homeSectionListMock.mockResolvedValue({
      data: [
        {
          id: 3,
          status: 'ACTIVE',
          sortOrder: 0,
          type: 'CTA_CARD',
          title: 'Nhượng quyền',
          description: 'Mô tả CTA',
          buttonText: 'Tìm hiểu',
          buttonLink: '/franchise',
        },
      ],
    })

    const wrapper = mountView()
    await flushPromises()

    expect(wrapper.find('.bg-brand-lime').exists()).toBe(true)
    expect(wrapper.text()).toContain('Tìm hiểu')
  })
})
