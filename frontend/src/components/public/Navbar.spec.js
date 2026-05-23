import { mount } from '@vue/test-utils'
import { createMemoryHistory, createRouter } from 'vue-router'
import { describe, expect, it, vi } from 'vitest'
import Navbar from './Navbar.vue'

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) =>
      ({
        'brand.name': 'ALOO',
        'brand.tagline': 'Kem Bơ Thuần Việt',
        'nav.home': 'Trang chủ',
        'nav.products': 'Sản phẩm',
        'nav.system': 'Hệ thống',
        'nav.franchise': 'Nhượng quyền',
        'nav.about': 'Về ALOO',
        'nav.blog': 'Blog',
        'nav.consultation': 'Đăng ký tư vấn',
        'nav.menu': 'Menu',
      })[key] || key,
  }),
}))

const router = createRouter({
  history: createMemoryHistory(),
  routes: [
    { path: '/', component: { template: '<div />' } },
    { path: '/products', component: { template: '<div />' } },
    { path: '/locations', component: { template: '<div />' } },
    { path: '/franchise', component: { template: '<div />' } },
    { path: '/about', component: { template: '<div />' } },
    { path: '/blog', component: { template: '<div />' } },
    { path: '/consultation', component: { template: '<div />' } },
  ],
})

describe('Navbar', () => {
  it('renders public navigation and highlights the active route', async () => {
    await router.push('/products')
    await router.isReady()

    const wrapper = mount(Navbar, {
      global: {
        plugins: [router],
        stubs: {
          LanguageSwitcher: { template: '<div />' },
          UserMenu: { template: '<div />' },
        },
      },
    })

    expect(wrapper.text()).toContain('Trang chủ')
    expect(wrapper.text()).toContain('Sản phẩm')
    expect(wrapper.text()).toContain('Nhượng quyền')
    expect(wrapper.text()).toContain('Đăng ký tư vấn')
    expect(wrapper.get('a[href="/products"]').classes()).toContain('bg-avocado-100')
  })
})
