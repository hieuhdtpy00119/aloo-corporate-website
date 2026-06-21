import { mount, flushPromises } from '@vue/test-utils'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import AdminLoginView from './AdminLoginView.vue'
import { loginAdmin, setAuthProvider } from '../../services/authService'

const translations = {
  'admin.login.title': 'Đăng nhập',
  'admin.login.brandTitle': 'ALOO Account',
  'admin.login.brandSubtitle': 'Đăng nhập tài khoản',
  'admin.login.description': 'Mô tả đăng nhập',
  'admin.login.google': 'Đăng nhập bằng Google',
  'admin.login.divider': 'hoặc',
  'admin.login.email': 'Email',
  'admin.login.password': 'Mật khẩu',
  'admin.login.submit': 'Xác thực tài khoản',
  'admin.login.submitting': 'Đang xác thực...',
  'admin.login.invalidCredentials': 'Sai tài khoản hoặc mật khẩu',
}

const pushMock = vi.fn()

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => translations[key] || key,
  }),
}))

vi.mock('vue-router', () => ({
  useRouter: () => ({ push: pushMock }),
  useRoute: () => ({ query: { redirect: '/admin/content/articles' } }),
}))

vi.mock('../../services/authService', () => ({
  loginAdmin: vi.fn(),
  setAuthProvider: vi.fn(),
}))

vi.mock('../../services/oauthService', () => ({
  googleLoginUrl: () => 'https://oauth.example',
}))

describe('AdminLoginView', () => {
  beforeEach(() => {
    pushMock.mockReset()
    loginAdmin.mockReset()
    setAuthProvider.mockReset()
    localStorage.clear()
  })

  const mountView = () =>
    mount(AdminLoginView, {
      global: {
        stubs: {
          Navbar: true,
          Footer: true,
        },
      },
    })

  it('renders localized login title', () => {
    const wrapper = mountView()

    expect(wrapper.text()).toContain('Đăng nhập')
  })

  it('shows alert panel when login fails', async () => {
    loginAdmin.mockRejectedValue({ response: { data: { message: 'Invalid' } } })
    const wrapper = mountView()

    await wrapper.find('form').trigger('submit.prevent')
    await flushPromises()

    expect(wrapper.find('[role="alert"]').exists()).toBe(true)
    expect(wrapper.text()).toContain('Invalid')
  })

  it('redirects admin users to the saved redirect path', async () => {
    loginAdmin.mockResolvedValue({
      data: {
        token: 'token',
        user: { role: 'ADMIN', email: 'admin@aloo.vn' },
      },
    })

    const wrapper = mountView()
    await wrapper.find('form').trigger('submit.prevent')
    await flushPromises()

    expect(pushMock).toHaveBeenCalledWith('/admin/content/articles')
  })
})
