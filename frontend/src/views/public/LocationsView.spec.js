import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import LocationsView from './LocationsView.vue'
import { useAppStore } from '../../stores/appStore'

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) =>
      ({
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
      })[key] || key,
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
          SectionTitle: { template: '<div />' },
        },
      },
    })

    expect(wrapper.text()).toContain('ALOO Nguyễn Trãi')
    expect(wrapper.text()).toContain('ALOO Hải Châu')

    await wrapper.find('input[type="search"]').setValue('Hải')

    expect(wrapper.text()).not.toContain('ALOO Nguyễn Trãi')
    expect(wrapper.text()).toContain('ALOO Hải Châu')
  })
})
