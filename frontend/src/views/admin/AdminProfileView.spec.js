import { mount, flushPromises } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import AdminProfileView from './AdminProfileView.vue'
import { getCurrentAdmin } from '../../services/authService'

const translations = {
  'admin.profile.loading': 'Đang tải thông tin tài khoản...',
  'admin.profile.loadError': 'Không tải được thông tin tài khoản',
  'admin.profile.uploadingAvatar': 'Đang tải ảnh lên...',
}

vi.mock('vue-i18n', () => ({
  useI18n: () => ({
    t: (key) => translations[key] || key,
  }),
}))

vi.mock('vue-router', () => ({
  useRoute: () => ({ query: {} }),
  useRouter: () => ({ replace: vi.fn() }),
}))

vi.mock('../../services/authService', () => ({
  getCurrentAdmin: vi.fn(),
  updateAdminProfile: vi.fn(),
  changeAdminPassword: vi.fn(),
  requestPasswordChangeOtp: vi.fn(),
  refreshAuthProfile: vi.fn(),
  uploadProfileAvatar: vi.fn(),
  usesGoogleSignIn: () => false,
}))

vi.mock('../../services/cmsService', () => ({
  resolveBackendAssetUrl: (url) => url || '',
}))

describe('AdminProfileView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    getCurrentAdmin.mockReset()
  })

  it('shows loading state before profile data arrives', () => {
    getCurrentAdmin.mockReturnValue(new Promise(() => {}))

    const wrapper = mount(AdminProfileView, {
      global: {
        stubs: {
          AvatarCropModal: true,
        },
      },
    })

    expect(wrapper.text()).toContain('Đang tải thông tin tài khoản...')
  })

  it('renders profile after load without default admin flash', async () => {
    getCurrentAdmin.mockResolvedValue({
      data: {
        fullName: 'Nguyen Van A',
        email: 'a@aloo.vn',
        phone: '0900111222',
        role: 'ADMIN',
        avatarUrl: '/avatar.png',
      },
    })

    const wrapper = mount(AdminProfileView, {
      global: {
        stubs: {
          AvatarCropModal: true,
        },
      },
    })

    await flushPromises()

    expect(wrapper.text()).toContain('Nguyen Van A')
    expect(wrapper.text()).not.toContain('admin@aloo.vn')
  })
})
