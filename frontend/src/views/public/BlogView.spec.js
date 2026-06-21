import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import BlogView from './BlogView.vue'
import { useAppStore } from '../../stores/appStore'

const translations = {
  'common.all': 'Tất cả',
  'blog.eyebrow': 'Blog',
  'blog.title': 'Tin tức và câu chuyện ALOO',
  'blog.description': 'Mô tả blog',
  'blog.latestSection': 'Tin mới cập nhật',
  'blog.loadMore': 'Xem thêm bài viết',
  'blog.excerptFallback': 'Nội dung bài viết đang được cập nhật.',
  'blog.dateUnset': 'Chưa đặt ngày',
  'blog.emptyNoData': 'Chưa có bài viết công khai',
  'blog.emptyNoDataDesc': 'Nội dung blog sẽ được cập nhật sớm.',
  'blog.emptyNoMatch': 'Chưa có bài viết phù hợp',
  'blog.emptyNoMatchDesc': 'Danh mục này chưa có bài viết công khai.',
  'blog.sidebarSuggested': 'Gợi ý đọc',
  'blog.sidebarLatest': 'Bài mới',
  'blog.franchiseCtaEyebrow': 'Nhượng quyền',
  'blog.franchiseCtaTitle': 'Muốn mở cửa hàng ALOO?',
  'blog.franchiseCtaDesc': 'Đăng ký tư vấn',
  'blog.franchiseCtaButton': 'Tư vấn nhượng quyền',
  'blog.loadErrorHint': 'Không tải được danh sách bài viết.',
  'blog.clearFilter': 'Xem tất cả bài viết',
  'blog.loading': 'Đang tải bài viết...',
}

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => translations[key] || key,
    locale: { value: 'vi' },
  }),
}))

vi.mock('../../services/seoService', () => ({
  routeSeo: {
    '/blog': {
      title: 'Blog ALOO',
      description: 'Blog description',
    },
  },
  setSeoMeta: vi.fn(),
}))

describe('BlogView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('renders only published posts and filters by article category', async () => {
    const store = useAppStore()
    store.categories = [
      { id: 1, name: 'Nhượng quyền', type: 'ARTICLE', status: 'ACTIVE', sortOrder: 1 },
      { id: 2, name: 'Sản phẩm', type: 'ARTICLE', status: 'ACTIVE', sortOrder: 2 },
    ]
    store.posts = [
      {
        id: 1,
        title: 'Bài viết nhượng quyền',
        slug: 'bai-viet-nhuong-quyen',
        category: 'Nhượng quyền',
        status: 'PUBLISHED',
        publishedAt: '2026-05-22T10:00:00',
      },
      {
        id: 2,
        title: 'Bài viết sản phẩm',
        slug: 'bai-viet-san-pham',
        category: 'Sản phẩm',
        status: 'PUBLISHED',
        publishedAt: '2026-05-21T10:00:00',
      },
      {
        id: 3,
        title: 'Bài nháp không public',
        category: 'Nhượng quyền',
        status: 'DRAFT',
      },
    ]
    vi.spyOn(store, 'fetchCategories').mockResolvedValue()
    vi.spyOn(store, 'fetchPosts').mockResolvedValue()

    const wrapper = mount(BlogView, {
      global: {
        stubs: {
          RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
        },
      },
    })

    expect(wrapper.text()).toContain('Bài viết nhượng quyền')
    expect(wrapper.text()).toContain('Bài viết sản phẩm')
    expect(wrapper.text()).not.toContain('Bài nháp không public')

    const productFilter = wrapper.findAll('button').find((button) => button.text() === 'Sản phẩm')
    await productFilter.trigger('click')

    expect(productFilter.classes()).toContain('bg-avocado-700')
    expect(wrapper.text()).toContain('Bài viết sản phẩm')
  })
})
