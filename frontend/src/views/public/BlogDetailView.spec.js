import { mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import BlogDetailView from './BlogDetailView.vue'
import { useAppStore } from '../../stores/appStore'

const routeState = vi.hoisted(() => ({
  params: { id: 'aloo-post' },
}))

vi.mock('vue-router', () => ({
  useRoute: () => routeState,
  RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
}))

describe('BlogDetailView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    routeState.params.id = 'aloo-post'
    document.title = 'ALOO'
  })

  it('shows the matching published post by slug and updates the meta title', () => {
    const store = useAppStore()
    store.posts = [
      {
        id: 1,
        slug: 'aloo-post',
        title: 'Câu chuyện ALOO',
        seoTitle: 'SEO Câu chuyện ALOO',
        excerpt: 'Excerpt',
        content: '<h2>Điểm chính</h2><p>Nội dung</p>',
        category: 'ALOO',
        status: 'PUBLISHED',
        publishedAt: '2026-05-22T10:00:00',
        tags: ['aloo'],
      },
    ]
    vi.spyOn(store, 'fetchCategories').mockResolvedValue()
    vi.spyOn(store, 'fetchPosts').mockResolvedValue()

    const wrapper = mount(BlogDetailView)

    expect(wrapper.text()).toContain('Câu chuyện ALOO')
    expect(wrapper.text()).toContain('Điểm chính')
    expect(document.title).toBe('SEO Câu chuyện ALOO | ALOO')
  })

  it('renders a clear not-found state for an unknown post', () => {
    routeState.params.id = 'missing-post'
    const store = useAppStore()
    store.posts = []
    vi.spyOn(store, 'fetchCategories').mockResolvedValue()
    vi.spyOn(store, 'fetchPosts').mockResolvedValue()

    const wrapper = mount(BlogDetailView)

    expect(wrapper.text()).toContain('Không tìm thấy bài viết')
    expect(wrapper.text()).toContain('Quay lại Blog')
  })
})
