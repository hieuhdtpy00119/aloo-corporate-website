import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import AdminDashboardView from './AdminDashboardView.vue'
import { useAppStore } from '../../stores/appStore'

const translations = {
  'admin.dashboard.title': 'Dashboard tổng quan',
  'admin.dashboard.loading': 'Đang tải dữ liệu dashboard...',
  'admin.dashboard.loadErrorTitle': 'Không tải được một phần dữ liệu dashboard.',
  'admin.dashboard.emptyLeads': 'Chưa có lead trong phạm vi thời gian đã chọn',
  'admin.dashboard.emptyPosts': 'Chưa có bài viết trong phạm vi thời gian đã chọn',
}

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => translations[key] || key,
    locale: { value: 'vi' },
  }),
}))

vi.mock('../../utils/adminAccess', () => ({
  ADMIN_SCOPES: {
    dashboard: 'dashboard',
    content: 'content',
    stores: 'stores',
    crm: 'crm',
    system: 'system',
  },
  canAccessAdminSession: () => ({
    dashboard: true,
    content: true,
    stores: true,
    crm: true,
    system: true,
  }),
}))

describe('AdminDashboardView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  const mountView = () =>
    mount(AdminDashboardView, {
      global: {
        stubs: {
          RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
        },
      },
    })

  it('renders dashboard title', () => {
    const wrapper = mountView()

    expect(wrapper.text()).toContain('Dashboard tổng quan')
  })

  it('shows loading skeleton while store data is loading', () => {
    const store = useAppStore()
    store.loading.posts = true

    const wrapper = mountView()

    expect(wrapper.find('[aria-busy="true"]').exists()).toBe(true)
  })

  it('shows error banner when store requests fail', () => {
    const store = useAppStore()
    store.errors.posts = 'Không tải được bài viết'

    const wrapper = mountView()

    expect(wrapper.text()).toContain('Không tải được một phần dữ liệu dashboard.')
    expect(wrapper.text()).toContain('Không tải được bài viết')
  })

  it('shows empty states for recent lead and post lists', () => {
    const wrapper = mountView()

    expect(wrapper.text()).toContain('Chưa có lead trong phạm vi thời gian đã chọn')
    expect(wrapper.text()).toContain('Chưa có bài viết trong phạm vi thời gian đã chọn')
  })
})
