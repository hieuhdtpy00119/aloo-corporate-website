import { flushPromises, mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import UserProfileView from './UserProfileView.vue'
import { getCurrentUser, updateUserProfile } from '../../services/userAuthService'

vi.mock('../../services/userAuthService', () => ({
  getCurrentUser: vi.fn(),
  updateUserProfile: vi.fn(),
  uploadUserImage: vi.fn(),
}))

describe('UserProfileView', () => {
  beforeEach(() => {
    getCurrentUser.mockReset()
    updateUserProfile.mockReset()
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
})
