import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import PublicLayout from './PublicLayout.vue'

describe('PublicLayout', () => {
  it('renders header, route content and footer consistently', () => {
    const wrapper = mount(PublicLayout, {
      global: {
        mocks: {
          $route: { fullPath: '/products' },
        },
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
