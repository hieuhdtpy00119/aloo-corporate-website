import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import UserChangePasswordView from './UserChangePasswordView.vue'
import { changeUserPassword } from '../../services/userAuthService'

const routerMock = vi.hoisted(() => ({
  replace: vi.fn(),
}))

vi.mock('vue-router', () => ({
  useRouter: () => routerMock,
}))

vi.mock('../../services/userAuthService', () => ({
  changeUserPassword: vi.fn(),
}))

describe('UserChangePasswordView', () => {
  beforeEach(() => {
    changeUserPassword.mockReset()
    routerMock.replace.mockReset()
  })

  it('validates password length and confirmation before calling API', async () => {
    const wrapper = mount(UserChangePasswordView, {
      global: {
        plugins: [createPinia()],
      },
    })
    const inputs = wrapper.findAll('input')

    await inputs[0].setValue('123456')
    await inputs[1].setValue('1234567')
    await inputs[2].setValue('12345678')
    await wrapper.find('form').trigger('submit')

    expect(wrapper.text()).toContain('Mật khẩu mới tối thiểu 8 ký tự')
    expect(changeUserPassword).not.toHaveBeenCalled()

    await inputs[1].setValue('12345678')
    await inputs[2].setValue('87654321')
    await wrapper.find('form').trigger('submit')

    expect(wrapper.text()).toContain('Mật khẩu nhập lại không khớp')
    expect(changeUserPassword).not.toHaveBeenCalled()
  })

  it('changes password, clears token and redirects to login', async () => {
    changeUserPassword.mockResolvedValue({})
    localStorage.setItem('user_token', 'user.jwt')
    localStorage.setItem('user_user', '{"email":"user@aloo.vn"}')
    localStorage.setItem('user_role', 'USER')

    const wrapper = mount(UserChangePasswordView, {
      global: {
        plugins: [createPinia()],
      },
    })
    const inputs = wrapper.findAll('input')

    await inputs[0].setValue('123456')
    await inputs[1].setValue('12345678')
    await inputs[2].setValue('12345678')
    await wrapper.find('form').trigger('submit')
    await flushPromises()

    expect(changeUserPassword).toHaveBeenCalledWith({
      currentPassword: '123456',
      newPassword: '12345678',
    })
    expect(localStorage.getItem('user_token')).toBeNull()
    expect(routerMock.replace).toHaveBeenCalledWith('/login')
  })
})
