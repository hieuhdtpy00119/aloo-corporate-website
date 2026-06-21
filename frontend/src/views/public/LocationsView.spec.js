import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import LocationsView from './LocationsView.vue'
import { useAppStore } from '../../stores/appStore'

const translations = {
  'common.all': 'Tất cả',
  'common.address': 'Địa chỉ',
  'common.phone': 'Số điện thoại',
  'common.openingHours': 'Giờ mở cửa',
  'common.viewMap': 'Xem bản đồ',
  'locations.eyebrow': 'Địa điểm',
  'locations.title': 'Hệ thống cửa hàng ALOO',
  'locations.description': 'Tìm chi nhánh',
  'locations.searchPlaceholder': 'Tìm theo tên chi nhánh hoặc địa chỉ',
  'locations.active': 'Đang hoạt động',
  'locations.comingSoon': 'Sắp khai trương',
  'locations.maintenance': 'Đang sửa chữa',
  'locations.statsTotal': 'Tổng chi nhánh',
  'locations.statsActive': 'Đang hoạt động',
  'locations.statsFeatured': 'Nổi bật',
  'locations.featured': 'Nổi bật',
  'locations.loading': 'Đang tải hệ thống cửa hàng...',
  'locations.emptyNoData': 'Chưa có cửa hàng nào.',
  'locations.emptyNoMatch': 'Không tìm thấy cửa hàng nào khớp với tìm kiếm.',
  'locations.detail': 'Chi tiết',
  'locations.order': 'Đặt món',
  'locations.callNow': 'Gọi ngay',
  'locations.provinceFilter': 'Lọc theo tỉnh',
}

vi.mock('../../services/seoService', () => ({
  routeSeo: { '/locations': { title: 'Locations', description: 'Stores' } },
  setSeoMeta: vi.fn(),
}))

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => translations[key] || key,
  }),
}))

describe('LocationsView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('loads API-backed locations and filters by search keyword', async () => {
    const store = useAppStore()
    store.locations = [
      {
        id: 1,
        name: 'ALOO Nguyễn Trãi',
        addressText: '128 Nguyễn Trãi',
        city: 'TP.HCM',
        phone: '0900 888 168',
        openingHours: '09:00 - 22:00',
        mapUrl: 'https://maps.google.com',
        status: 'ACTIVE',
      },
      {
        id: 2,
        name: 'ALOO Hải Châu',
        addressText: '82 Bạch Đằng',
        city: 'Đà Nẵng',
        phone: '0902 333 168',
        openingHours: '09:30 - 22:00',
        mapUrl: 'https://maps.google.com',
        status: 'COMING_SOON',
      },
    ]
    vi.spyOn(store, 'fetchLocations').mockResolvedValue()

    const wrapper = mount(LocationsView, {
      global: {
        stubs: {
          RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
        },
      },
    })

    expect(wrapper.text()).toContain('ALOO Nguyễn Trãi')
    expect(wrapper.text()).toContain('ALOO Hải Châu')

    await wrapper.find('input[type="search"]').setValue('Hải')

    expect(wrapper.text()).not.toContain('ALOO Nguyễn Trãi')
    expect(wrapper.text()).toContain('ALOO Hải Châu')
  })

  it('shows a dedicated empty state when there are no locations', async () => {
    const store = useAppStore()
    store.locations = []
    vi.spyOn(store, 'fetchLocations').mockResolvedValue()

    const wrapper = mount(LocationsView, {
      global: {
        stubs: {
          RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
        },
      },
    })

    expect(wrapper.text()).toContain('Chưa có cửa hàng nào.')
  })

  it('shows loading skeleton while locations are loading', () => {
    const store = useAppStore()
    store.loading.locations = true
    vi.spyOn(store, 'fetchLocations').mockResolvedValue()

    const wrapper = mount(LocationsView, {
      global: {
        stubs: {
          RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
        },
      },
    })

    expect(wrapper.find('.animate-pulse').exists()).toBe(true)
  })

  it('shows error banner when locations API fails', () => {
    const store = useAppStore()
    store.errors.locations = 'Không tải được cửa hàng'
    vi.spyOn(store, 'fetchLocations').mockResolvedValue()

    const wrapper = mount(LocationsView, {
      global: {
        stubs: {
          RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
        },
      },
    })

    expect(wrapper.text()).toContain('Không tải được cửa hàng')
  })

  it('shows no-match empty state when search has no results', async () => {
    const store = useAppStore()
    store.locations = [
      {
        id: 1,
        name: 'ALOO Nguyễn Trãi',
        addressText: '128 Nguyễn Trãi',
        city: 'TP.HCM',
        status: 'ACTIVE',
      },
    ]
    vi.spyOn(store, 'fetchLocations').mockResolvedValue()

    const wrapper = mount(LocationsView, {
      global: {
        stubs: {
          RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
        },
      },
    })

    await wrapper.find('input[type="search"]').setValue('Không tồn tại')

    expect(wrapper.text()).toContain('Không tìm thấy cửa hàng nào khớp với tìm kiếm.')
  })
})
