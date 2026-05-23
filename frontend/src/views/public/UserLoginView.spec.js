import { flushPromises, mount } from '@vue/test-utils'
import { describe, expect, it, vi, beforeEach } from 'vitest'
import UserLoginView from './UserLoginView.vue'
import { loginUser } from '../../services/userAuthService'
import { loginAdmin } from '../../services/authService'

const routerMock = vi.hoisted(() => ({
  push: vi.fn(),
}))

vi.mock('vue-router', () => ({
  useRouter: () => routerMock,
  RouterLink: { props: ['to'], template: '<a :href="to"><slot /></a>' },
}))

vi.mock('../../services/userAuthService', () => ({
  loginUser: vi.fn(),
}))

vi.mock('../../services/authService', () => ({
  loginAdmin: vi.fn(),
}))

describe('UserLoginView', () => {
  beforeEach(() => {
    routerMock.push.mockReset()
    loginUser.mockReset()
    loginAdmin.mockReset()
  })

  it('validates email and password before calling API', async () => {
    const wrapper = mount(UserLoginView)
    const inputs = wrapper.findAll('input')

    await inputs[0].setValue('bad-email')
    await inputs[1].setValue('123456')
    await wrapper.find('form').trigger('submit')

    expect(wrapper.text()).toContain('Email không đúng định dạng')
    expect(loginUser).not.toHaveBeenCalled()
  })

  it('logs in a normal user, stores JWT and redirects to profile', async () => {
    loginUser.mockResolvedValue({
      data: {
        token: 'user.jwt',
        user: {
          email: 'user@aloo.vn',
          role: 'USER',
        },
      },
    })

    const wrapper = mount(UserLoginView)
    await wrapper.find('form').trigger('submit')
    await flushPromises()

    expect(loginUser).toHaveBeenCalledWith({
      email: 'user@aloo.vn',
      password: '123456',
    })
    expect(localStorage.getItem('user_token')).toBe('user.jwt')
    expect(routerMock.push).toHaveBeenCalledWith('/profile')
  })

  it('routes admin credentials to CMS login flow', async () => {
    loginAdmin.mockResolvedValue({
      data: {
        token: 'admin.jwt',
        user: {
          email: 'admin@aloo.vn',
          role: 'ADMIN',
        },
      },
    })

    const wrapper = mount(UserLoginView)
    const inputs = wrapper.findAll('input')
    await inputs[0].setValue('admin@aloo.vn')
    await inputs[1].setValue('123456')
    await wrapper.find('form').trigger('submit')
    await flushPromises()

    expect(loginAdmin).toHaveBeenCalled()
    expect(localStorage.getItem('admin_token')).toBe('admin.jwt')
    expect(routerMock.push).toHaveBeenCalledWith('/admin')
  })
})
