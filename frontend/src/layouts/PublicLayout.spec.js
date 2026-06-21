import { mount } from '@vue/test-utils'
import { ref } from 'vue'
import { describe, expect, it, vi } from 'vitest'
import PublicLayout from './PublicLayout.vue'

vi.mock('vue-router', () => ({
  useRoute: () => ({ path: '/products', fullPath: '/products' }),
}))

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    locale: ref('vi'),
    t: (key) => key,
  }),
}))

vi.mock('../services/seoService', () => ({
  applyRouteSeo: vi.fn(),
}))

describe('PublicLayout', () => {
  it('renders header, route content and footer consistently', () => {
    const wrapper = mount(PublicLayout, {
      global: {
        stubs: {
          Navbar: { template: '<header data-test="public-header">Header</header>' },
          Footer: { template: '<footer data-test="public-footer">Footer</footer>' },
          RouterView: { template: '<section data-test="route-content">Route page</section>' },
        },
      },
    })

    expect(wrapper.get('[data-test="public-header"]').exists()).toBe(true)
    expect(wrapper.get('[data-test="route-content"]').text()).toBe('Route page')
    expect(wrapper.get('[data-test="public-footer"]').exists()).toBe(true)
  })
})
