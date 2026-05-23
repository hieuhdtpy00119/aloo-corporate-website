import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import UserProfileView from './UserProfileView.vue'
import { changeUserPassword, getCurrentUser, updateUserProfile } from '../../services/userAuthService'

const routerMock = vi.hoisted(() => ({
  replace: vi.fn(),
}))

vi.mock('vue-router', () => ({
  useRoute: () => ({ query: {} }),
  useRouter: () => routerMock,
}))

vi.mock('../../services/userAuthService', () => ({
  changeUserPassword: vi.fn(),
  getCurrentUser: vi.fn(),
  updateUserProfile: vi.fn(),
  uploadUserImage: vi.fn(),
}))

describe('UserProfileView', () => {
  beforeEach(() => {
    changeUserPassword.mockReset()
    getCurrentUser.mockReset()
    updateUserProfile.mockReset()
    routerMock.replace.mockReset()
  })

  it('loads current user from API and saves profile updates', async () => {
    getCurrentUser.mockResolvedValue({
      data: {
        fullName: 'ALOO User',
        email: 'user@aloo.vn',
        phone: '0901234567',
        avatarUrl: '/uploads/avatar.jpg',
        role: 'USER',
      },
    })
    updateUserProfile.mockResolvedValue({
      data: {
        fullName: 'ALOO Updated',
        email: 'user@aloo.vn',
        phone: '0901234567',
        avatarUrl: '/uploads/avatar.jpg',
        role: 'USER',
      },
    })

    const wrapper = mount(UserProfileView, {
      global: {
        plugins: [createPinia()],
      },
    })
    await flushPromises()

    expect(wrapper.text()).toContain('ALOO User')

    const editableInputs = wrapper
      .findAll('article input')
      .filter((input) => input.attributes('type') !== 'file')

    await editableInputs[0].setValue('ALOO Updated')
    await wrapper.find('form').trigger('submit')
    await flushPromises()

    expect(updateUserProfile).toHaveBeenCalledWith({
      fullName: 'ALOO Updated',
      email: 'user@aloo.vn',
      phone: '0901234567',
      avatarUrl: '/uploads/avatar.jpg',
    })
    expect(localStorage.getItem('user_user')).toContain('ALOO Updated')
  })

  it('switches to the security tab and changes password from profile', async () => {
    getCurrentUser.mockResolvedValue({
      data: {
        fullName: 'ALOO User',
        email: 'user@aloo.vn',
        phone: '0901234567',
        avatarUrl: '/uploads/avatar.jpg',
        role: 'USER',
      },
    })
    changeUserPassword.mockResolvedValue({})
    localStorage.setItem('user_token', 'user.jwt')

    const wrapper = mount(UserProfileView, {
      global: {
        plugins: [createPinia()],
      },
    })
    await flushPromises()

    await wrapper.get('button:nth-of-type(2)').trigger('click')
    const inputs = wrapper.findAll('input[type="password"]')
    await inputs[0].setValue('123456')
    await inputs[1].setValue('12345678')
    await inputs[2].setValue('12345678')
    await wrapper.find('form').trigger('submit')
    await flushPromises()

    expect(routerMock.replace).toHaveBeenCalledWith({ path: '/profile', query: { tab: 'security' } })
    expect(changeUserPassword).toHaveBeenCalledWith({
      currentPassword: '123456',
      newPassword: '12345678',
    })
    expect(localStorage.getItem('user_token')).toBeNull()
    expect(routerMock.replace).toHaveBeenCalledWith('/login')
  })
})
