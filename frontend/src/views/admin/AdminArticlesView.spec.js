import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import AdminArticlesView from './AdminArticlesView.vue'
import { useAppStore } from '../../stores/appStore'

const translations = {
  'admin.articles.title': 'Quản lý tin tức',
  'admin.articles.eyebrow': 'Article Management System',
  'admin.articles.description': 'Quản lý bài SEO',
  'admin.articles.add': 'Thêm bài viết',
  'admin.articles.empty': 'Không có dữ liệu phù hợp',
  'admin.nav.categories': 'Danh mục bài viết',
  'admin.common.loading': 'Đang tải dữ liệu...',
}

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => translations[key] || key,
  }),
}))

vi.mock('vue-router', () => ({
  useRouter: () => ({ push: vi.fn() }),
  RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
}))

describe('AdminArticlesView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  const mountView = () =>
    mount(AdminArticlesView, {
      global: {
        stubs: {
          SearchFilterBar: true,
          Pagination: true,
          ConfirmModal: true,
        },
      },
    })

  it('renders localized page title', () => {
    const wrapper = mountView()

    expect(wrapper.text()).toContain('Quản lý tin tức')
  })

  it('shows loading empty state while posts are loading', () => {
    const store = useAppStore()
    store.loading.posts = true

    const wrapper = mountView()

    expect(wrapper.text()).toContain('Đang tải dữ liệu...')
  })

  it('shows posts error banner', () => {
    const store = useAppStore()
    store.errors.posts = 'Không tải được bài viết'

    const wrapper = mountView()

    expect(wrapper.text()).toContain('Không tải được bài viết')
  })

})
