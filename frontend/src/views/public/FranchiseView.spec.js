import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import FranchiseView from './FranchiseView.vue'
import { useFranchiseContentStore } from '../../stores/franchiseContentStore'
import { useAppStore } from '../../stores/appStore'

const translations = {
  'franchise.loading': 'Đang tải nội dung nhượng quyền...',
  'franchise.loadErrorHint': 'Không kết nối được CMS.',
  'franchise.heroDefaultTitle': 'Cùng Aloo kinh doanh kem bơ',
  'franchise.advantagesTitle': 'Lợi thế thương hiệu',
  'franchise.advantagesEyebrow': 'Tại sao chọn Aloo?',
  'franchise.advantagesDesc': 'Mô tả lợi thế',
  'franchise.viewStoreDetail': 'Xem chi tiết cửa hàng',
  'franchise.consultationTitle': 'Đăng ký nhận tư vấn miễn phí',
  'franchise.heroDefaultSubtitle': 'Nhượng quyền',
  'franchise.heroDefaultDescription': 'Mô tả hero',
  'franchise.heroDefaultPrimaryCta': 'Tư vấn',
  'franchise.heroDefaultSecondaryCta': 'Chi phí',
  'franchise.heroAlt': 'Franchise hero',
  'franchise.modelsEyebrow': 'Models',
  'franchise.modelsTitle': 'Models title',
  'franchise.modelsDesc': 'Models desc',
  'franchise.modelAreaLabel': 'Diện tích',
  'franchise.investmentEyebrow': 'Investment',
  'franchise.investmentTitle': 'Investment title',
  'franchise.investmentDesc': 'Investment desc',
  'franchise.investmentFootnote': 'Footnote',
  'franchise.investmentTableItem': 'Hạng mục',
  'franchise.investmentTableNote': 'Ghi chú',
  'franchise.investmentTypeKiosk': 'Kiosk',
  'franchise.investmentTypeStandard': 'Standard',
  'franchise.investmentTypeFlagship': 'Flagship',
  'franchise.revenueEyebrow': 'Revenue',
  'franchise.revenueTitle': 'Revenue title',
  'franchise.revenueDesc': 'Revenue desc',
  'franchise.processEyebrow': 'Process',
  'franchise.processTitle': 'Process title',
  'franchise.processDesc': 'Process desc',
  'franchise.storesEyebrow': 'Stores',
  'franchise.storesTitle': 'Stores title',
  'franchise.storesDesc': 'Stores desc',
  'franchise.viewAllStores': 'Xem tất cả',
  'franchise.partnersEyebrow': 'Partners',
  'franchise.partnersTitle': 'Partners title',
  'franchise.partnersDesc': 'Partners desc',
  'franchise.faqEyebrow': 'FAQ',
  'franchise.faqTitle': 'FAQ title',
  'franchise.faqDesc': 'FAQ desc',
  'franchise.ctaDefaultTitle': 'CTA title',
  'franchise.ctaDefaultDesc': 'CTA desc',
  'franchise.featuredModelBadge': 'Nổi bật',
}

const localeMessages = {
  'franchise.heroStats': [{ num: '10+', label: 'Năm kinh nghiệm' }],
  'franchise.revenuePoints': ['Điểm 1'],
  'franchise.ctaPoints': ['Điểm CTA'],
  'franchise.partnerProfiles': [{ title: 'Nhà đầu tư lần đầu', desc: 'Mô tả' }],
}

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => translations[key] || key,
    tm: (key) => localeMessages[key] || [],
  }),
}))

vi.mock('../../services/seoService', () => ({
  routeSeo: { '/franchise': { title: 'Franchise', description: 'Franchise page' } },
  setSeoMeta: vi.fn(),
}))

vi.mock('../../services/analyticsService', () => ({
  trackEvent: vi.fn(),
}))

vi.mock('../../components/public/ConsultationForm.vue', () => ({
  default: { template: '<div data-testid="consultation-form" />' },
}))

describe('FranchiseView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('renders hero, CMS error banner, and linked featured stores', async () => {
    const franchiseStore = useFranchiseContentStore()
    const appStore = useAppStore()

    franchiseStore.loading = false
    franchiseStore.error = 'CMS unavailable'
    franchiseStore.content.advantages = [
      { id: 99, title: 'Lợi thế kiểm thử', description: 'Mô tả kiểm thử', icon: 'brand', status: 'ACTIVE' },
    ]

    appStore.locations = [
      {
        id: 1,
        name: 'ALOO Quy Nhơn',
        slug: 'aloo-quy-nhon',
        addressText: 'Quy Nhơn',
        status: 'ACTIVE',
        featured: true,
      },
    ]

    vi.spyOn(franchiseStore, 'fetchContent').mockResolvedValue()
    vi.spyOn(appStore, 'fetchLocations').mockResolvedValue()

    const wrapper = mount(FranchiseView, {
      global: {
        stubs: {
          RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
        },
      },
    })

    expect(wrapper.text()).toContain('Cùng Aloo kinh doanh kem bơ')
    expect(wrapper.text()).toContain('CMS unavailable')
    expect(wrapper.text()).toContain('Lợi thế kiểm thử')
    expect(wrapper.find('a[href="/locations/aloo-quy-nhon"]').exists()).toBe(true)
  })
})
