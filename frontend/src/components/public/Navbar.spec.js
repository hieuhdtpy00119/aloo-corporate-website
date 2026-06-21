import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import { createMemoryHistory, createRouter } from 'vue-router'
import { beforeEach, describe, expect, it, vi } from 'vitest'
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
        'userMenu.login': 'Đăng nhập',
        'userMenu.profile': 'Hồ sơ',
        'userMenu.cms': 'CMS',
        'userMenu.logout': 'Đăng xuất',
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
    { path: '/login', component: { template: '<div />' } },
    { path: '/admin/login', redirect: '/login' },
    { path: '/admin/profile', component: { template: '<div />' } },
    { path: '/admin', component: { template: '<div />' } },
  ],
})

describe('Navbar', () => {
  const jwt = (payload) => `header.${btoa(JSON.stringify(payload)).replace(/=/g, '')}.signature`

  beforeEach(() => {
    localStorage.clear()
  })

  it('renders public navigation and highlights the active route', async () => {
    await router.push('/products')
    await router.isReady()

    const wrapper = mount(Navbar, {
      global: {
        plugins: [router],
        stubs: {
          LanguageSwitcher: { template: '<div />' },
        },
      },
    })

    expect(wrapper.text()).toContain('Trang chủ')
    expect(wrapper.text()).toContain('Sản phẩm')
    expect(wrapper.text()).toContain('Nhượng quyền')
    expect(wrapper.text()).toContain('Đăng ký tư vấn')
    expect(wrapper.get('a[href="/products"]').classes()).toContain('bg-avocado-100')

    const publicNavLabels = ['Trang chủ', 'Hệ thống', 'Nhượng quyền', 'Sản phẩm', 'Về ALOO', 'Blog']
    const renderedNavLabels = wrapper
      .findAll('a')
      .map((link) => link.text().trim())
      .filter((label) => publicNavLabels.includes(label))

    expect(renderedNavLabels).toEqual(publicNavLabels)
  })

  it('opens the account menu from the public navbar', async () => {
    await router.push('/')
    await router.isReady()

    const wrapper = mount(Navbar, {
      global: {
        plugins: [router],
        stubs: {
          LanguageSwitcher: { template: '<div />' },
        },
      },
    })

    await wrapper.get('button[aria-haspopup="menu"]').trigger('click')

    expect(wrapper.find('[role="menu"]').exists()).toBe(true)
    expect(wrapper.get('a[href="/login"]').text()).toContain('Đăng nhập')
  })

  it('uses the admin avatar identity when authenticated', async () => {
    localStorage.setItem('admin_token', jwt({ role: 'ADMIN', exp: Math.floor(Date.now() / 1000) + 3600 }))
    localStorage.setItem('admin_user', JSON.stringify({ fullName: 'Nguyễn Admin', email: 'admin@aloo.vn' }))

    await router.push('/')
    await router.isReady()

    const wrapper = mount(Navbar, {
      global: {
        plugins: [router],
        stubs: {
          LanguageSwitcher: { template: '<div />' },
        },
      },
    })

    await nextTick()

    await wrapper.get('button[aria-haspopup="menu"]').trigger('click')

    expect(wrapper.find('[role="menu"]').text()).toContain('Nguyễn Admin')
    expect(wrapper.get('a[href="/admin/profile"]').text()).toContain('Hồ sơ')
    expect(wrapper.get('a[href="/admin"]').text()).toContain('CMS')
  })
})
