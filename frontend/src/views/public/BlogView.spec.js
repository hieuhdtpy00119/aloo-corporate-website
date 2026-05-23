import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import BlogView from './BlogView.vue'
import { useAppStore } from '../../stores/appStore'

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

    expect(productFilter.classes()).toContain('bg-avocado-900')
    expect(wrapper.text()).toContain('Bài viết sản phẩm')
  })
})
