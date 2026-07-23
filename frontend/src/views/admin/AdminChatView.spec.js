import { flushPromises, mount } from '@vue/test-utils'
import { createPinia, setActivePinia } from 'pinia'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import AdminChatView from './AdminChatView.vue'

const chatMocks = vi.hoisted(() => ({
  fetchAdminChatSessions: vi.fn(),
}))

const translations = {
  'admin.chat.title': 'Chat trực tuyến',
  'admin.chat.sessionsTitle': 'Hội thoại',
  'admin.chat.emptyTitle': 'Chưa có hội thoại',
  'admin.chat.emptyDescription': 'Các phiên chat mới sẽ hiển thị tại đây.',
  'admin.chat.loadErrorTitle': 'Không tải được hội thoại',
  'admin.chat.loadErrorDescription': 'Máy chủ chưa trả về dữ liệu chat. Vui lòng thử lại.',
  'admin.chat.retry': 'Thử lại',
  'admin.chat.selectTitle': 'Chọn một hội thoại',
  'admin.chat.selectDescription': 'Chọn khách để xem tin nhắn.',
  'admin.chat.searchPlaceholder': 'Tìm kiếm',
  'admin.chat.statusLabel': 'Trạng thái',
  'admin.chat.toasts.loadFailed': 'Không tải được dữ liệu chat',
  'admin.shared.loading': 'Đang tải dữ liệu...',
}

vi.mock('vue-i18n', () => ({
  useI18n: () => ({ t: (key) => translations[key] || key }),
}))

vi.mock('vue-router', () => ({
  useRoute: () => ({ query: {} }),
  useRouter: () => ({ replace: vi.fn() }),
}))

vi.mock('../../services/chatService', () => ({
  chatAdminInboxTopic: '/topic/admin/chat/inbox',
  chatSessionTopic: vi.fn(),
  createChatClient: vi.fn(),
  fetchAdminChatSession: vi.fn(),
  fetchAdminChatSessions: chatMocks.fetchAdminChatSessions,
  markAdminChatSessionRead: vi.fn(),
  sendAdminChatMessage: vi.fn(),
  updateAdminChatSessionStatus: vi.fn(),
}))

describe('AdminChatView', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    chatMocks.fetchAdminChatSessions.mockReset()
  })

  const mountView = () => mount(AdminChatView)

  it('distinguishes an API failure from an empty inbox and retries', async () => {
    chatMocks.fetchAdminChatSessions
      .mockRejectedValueOnce(new Error('network unavailable'))
      .mockResolvedValueOnce([])

    const wrapper = mountView()
    await flushPromises()

    expect(wrapper.find('.admin-chat-load-error').exists()).toBe(true)
    expect(wrapper.text()).toContain('Không tải được hội thoại')
    expect(wrapper.text()).not.toContain('Chưa có hội thoại')

    await wrapper.get('.admin-chat-retry').trigger('click')
    await flushPromises()

    expect(chatMocks.fetchAdminChatSessions).toHaveBeenCalledTimes(2)
    expect(wrapper.find('.admin-chat-load-error').exists()).toBe(false)
    expect(wrapper.text()).toContain('Chưa có hội thoại')
  })
})
