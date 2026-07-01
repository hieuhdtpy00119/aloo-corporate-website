<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
import { MessageCircle, Send, X } from 'lucide-vue-next'
import {
  chatSessionTopic,
  createAccountChatSession,
  createChatClient,
  createChatSession,
  fetchVisitorChatSession,
  getStoredChatOwner,
  getStoredChatToken,
  sendVisitorChatMessage,
  storeChatToken,
} from '../../services/chatService'
import { getStoredSessionUser } from '../../utils/accountAuth'
import { isAuthenticatedToken } from '../../utils/authToken'
import { repairUtf8Mojibake } from '../../utils/textEncoding'
import { refreshAuthProfile } from '../../services/authService'
import { ZALO_CHAT_URL } from '../../config/contact'

const zaloChatUrl = ZALO_CHAT_URL
const isOpen = ref(false)
const isConnecting = ref(false)
const isSending = ref(false)
const isAutoStarting = ref(false)
const errorMessage = ref('')
const session = ref(null)
const messages = ref([])
const draft = ref('')
const messagesEl = ref(null)
const clientRef = ref(null)
const subscriptionRef = ref(null)
const loggedInUser = ref(null)

const intakeForm = reactive({
  fullName: '',
  phone: '',
})

const visitorProfile = computed(() => {
  const user = loggedInUser.value
  if (!user) return null
  return {
    fullName: String(user.fullName || '').trim(),
    phone: String(user.phone || '').trim(),
  }
})

const isLoggedIn = computed(() => Boolean(visitorProfile.value))
const showIntake = computed(() => !isLoggedIn.value && !hasSession.value && !isAutoStarting.value)
const hasSession = computed(() => Boolean(session.value?.id))
const isClosed = computed(() => session.value?.status === 'CLOSED')
const canSend = computed(() => hasSession.value && !isClosed.value && draft.value.trim() && !isSending.value)

const intakeCopy = computed(() => 'Nhập thông tin để bắt đầu trò chuyện với đội ngũ tư vấn ALOO.')

const refreshLoggedInUser = () => {
  const token = localStorage.getItem('admin_token')
  loggedInUser.value = isAuthenticatedToken(token) ? getStoredSessionUser() : null
}

const primeIntakeFromUser = () => {
  const profile = visitorProfile.value
  if (!profile) return
  if (profile.fullName) intakeForm.fullName = profile.fullName
  if (profile.phone) intakeForm.phone = profile.phone
}

const resetIntakeForm = () => {
  intakeForm.fullName = ''
  intakeForm.phone = ''
}

const formatTime = (value) => {
  if (!value) return ''
  const date = new Date(value)
  return date.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' })
}

const scrollToBottom = async () => {
  await nextTick()
  if (messagesEl.value) {
    messagesEl.value.scrollTop = messagesEl.value.scrollHeight
  }
}

const normalizeMessage = (message) => ({
  ...message,
  body: repairUtf8Mojibake(message.body),
  senderName: repairUtf8Mojibake(message.senderName),
})

const applySession = (data) => {
  session.value = data
  messages.value = Array.isArray(data.messages) ? data.messages.map(normalizeMessage) : []
  scrollToBottom()
}

const disconnectClient = () => {
  subscriptionRef.value?.unsubscribe()
  subscriptionRef.value = null
  clientRef.value?.deactivate()
  clientRef.value = null
}

const connectRealtime = (chatToken) => {
  disconnectClient()
  isConnecting.value = true
  errorMessage.value = ''

  const client = createChatClient({
    chatToken,
    onConnect: (connectedClient) => {
      clientRef.value = connectedClient
      isConnecting.value = false
      subscriptionRef.value = connectedClient.subscribe(chatSessionTopic(session.value.id), (frame) => {
        const message = JSON.parse(frame.body)
        if (!messages.value.some((item) => item.id === message.id)) {
          messages.value.push(normalizeMessage(message))
          scrollToBottom()
        }
      })
    },
    onError: () => {
      isConnecting.value = false
      errorMessage.value = 'Không kết nối được chat realtime. Vui lòng thử lại sau.'
    },
  })
}

const bootstrapSession = async () => {
  const token = getStoredChatToken()
  if (!token) return

  // Only restore sessions explicitly created by a guest. Account sessions (or
  // legacy tokens) must not leak when the visitor is not logged in.
  if (!isLoggedIn.value && getStoredChatOwner() !== 'guest') {
    storeChatToken('')
    return
  }

  try {
    const data = await fetchVisitorChatSession(token)
    applySession(data)
    connectRealtime(token)
  } catch {
    storeChatToken('')
  }
}

const startSession = async ({ skipValidation = false } = {}) => {
  if (!skipValidation && (!intakeForm.fullName.trim() || !intakeForm.phone.trim())) {
    errorMessage.value = 'Vui lòng nhập họ tên và số điện thoại.'
    return false
  }

  isSending.value = true
  errorMessage.value = ''

  try {
    const data = await createChatSession({
      fullName: intakeForm.fullName.trim(),
      phone: intakeForm.phone.trim(),
    })
    applySession(data)
    connectRealtime(data.sessionToken)
    return true
  } catch (error) {
    errorMessage.value = error.response?.data?.message || 'Không tạo được phiên chat. Vui lòng thử lại.'
    return false
  } finally {
    isSending.value = false
  }
}

const syncVisitorProfile = async () => {
  refreshLoggedInUser()
  const token = localStorage.getItem('admin_token')
  if (!isAuthenticatedToken(token)) return

  try {
    await refreshAuthProfile()
  } catch {
    // Keep cached profile when refresh fails.
  }

  refreshLoggedInUser()
  primeIntakeFromUser()
}

const startAccountSession = async () => {
  isSending.value = true
  errorMessage.value = ''

  try {
    const data = await createAccountChatSession()
    applySession(data)
    connectRealtime(data.sessionToken)
    return true
  } catch (error) {
    errorMessage.value = error.response?.data?.message || 'Không tạo được phiên chat. Vui lòng thử lại.'
    return false
  } finally {
    isSending.value = false
  }
}

const tryAutoStart = async () => {
  if (hasSession.value || isAutoStarting.value || isSending.value) return

  await syncVisitorProfile()

  if (!isLoggedIn.value) return

  isAutoStarting.value = true
  try {
    await startAccountSession()
  } finally {
    isAutoStarting.value = false
  }
}

const clearActiveSession = () => {
  storeChatToken('')
  session.value = null
  messages.value = []
  disconnectClient()
}

const handleAuthChange = async () => {
  const wasLoggedIn = Boolean(loggedInUser.value)
  refreshLoggedInUser()
  primeIntakeFromUser()

  if (!isLoggedIn.value) {
    // Logging out must not keep the account chat or its prefilled details
    // visible to the next visitor.
    if (wasLoggedIn) {
      resetIntakeForm()
      if (getStoredChatOwner() === 'account') {
        clearActiveSession()
      }
    }
    return
  }

  if (!wasLoggedIn) {
    clearActiveSession()
  }

  if (!hasSession.value) {
    await tryAutoStart()
  }
}

const submitMessage = async () => {
  if (!canSend.value || !clientRef.value?.connected) return

  const body = draft.value.trim()
  draft.value = ''
  isSending.value = true
  errorMessage.value = ''

  try {
    sendVisitorChatMessage(clientRef.value, session.value.sessionToken, body)
  } catch {
    errorMessage.value = 'Không gửi được tin nhắn.'
    draft.value = body
  } finally {
    isSending.value = false
  }
}

const toggleOpen = () => {
  isOpen.value = !isOpen.value
}

watch(isOpen, async (open) => {
  if (open && hasSession.value && !clientRef.value?.connected) {
    connectRealtime(session.value.sessionToken)
    return
  }
  if (open && !hasSession.value) {
    await tryAutoStart()
  }
})

onMounted(async () => {
  await syncVisitorProfile()
  if (isLoggedIn.value) {
    await tryAutoStart()
  } else {
    await bootstrapSession()
  }
  window.addEventListener('aloo-auth-change', handleAuthChange)
})

onBeforeUnmount(() => {
  window.removeEventListener('aloo-auth-change', handleAuthChange)
  disconnectClient()
})
</script>

<template>
  <div class="chat-widget-root" :class="{ 'is-open': isOpen }">
    <div v-if="!isOpen" class="chat-widget-launchers">
      <a
        :href="zaloChatUrl"
        target="_blank"
        rel="noopener noreferrer"
        class="chat-widget-launcher chat-widget-zalo"
        aria-label="Mở Zalo để tư vấn nhanh"
      >
        <span class="chat-widget-zalo-mark" aria-hidden="true">Z</span>
        <span>Chat Zalo</span>
      </a>
      <button
        type="button"
        class="chat-widget-launcher chat-widget-toggle"
        :aria-expanded="isOpen"
        aria-label="Mở chat tư vấn"
        @click="toggleOpen"
      >
        <MessageCircle class="h-6 w-6" />
        <span>Chat ALOO</span>
      </button>
    </div>

    <section v-if="isOpen" class="chat-widget-panel" aria-label="Hộp chat ALOO">
      <header class="chat-widget-header">
        <div>
          <p class="chat-widget-eyebrow">Hỗ trợ trực tuyến</p>
          <h2 class="chat-widget-title">Chat với ALOO</h2>
        </div>
        <button type="button" class="chat-widget-close" aria-label="Đóng chat" @click="toggleOpen">
          <X class="h-5 w-5" />
        </button>
      </header>

      <div v-if="isAutoStarting" class="chat-widget-intake">
        <p class="chat-widget-copy">
          Đang kết nối chat cho {{ visitorProfile?.fullName || loggedInUser?.email || 'bạn' }}...
        </p>
      </div>

      <div v-else-if="showIntake" class="chat-widget-intake">
        <p class="chat-widget-copy">{{ intakeCopy }}</p>
        <label class="chat-widget-field">
          <span>Họ tên</span>
          <input v-model="intakeForm.fullName" type="text" placeholder="Nguyễn Văn A" />
        </label>
        <label class="chat-widget-field">
          <span>Số điện thoại</span>
          <input v-model="intakeForm.phone" type="tel" placeholder="09xx xxx xxx" />
        </label>
        <button type="button" class="chat-widget-primary" :disabled="isSending" @click="startSession">
          Bắt đầu chat
        </button>
      </div>

      <template v-else>
        <div ref="messagesEl" class="chat-widget-messages">
          <p v-if="isConnecting" class="chat-widget-status">Đang kết nối...</p>
          <p v-else-if="isClosed" class="chat-widget-status">Phiên chat đã kết thúc. Cảm ơn bạn đã liên hệ ALOO.</p>
          <article
            v-for="message in messages"
            :key="message.id"
            :class="['chat-widget-message', message.senderType === 'VISITOR' ? 'is-visitor' : 'is-admin']"
          >
            <p class="chat-widget-message-meta">
              {{ message.senderType === 'ADMIN' && !message.senderAdminId ? 'ALOO Tư vấn' : message.senderName }}
              <span>{{ formatTime(message.createdAt) }}</span>
            </p>
            <p class="chat-widget-message-body">{{ message.body }}</p>
          </article>
        </div>

        <form class="chat-widget-composer" @submit.prevent="submitMessage">
          <input
            v-model="draft"
            type="text"
            :disabled="isClosed || isConnecting"
            placeholder="Nhập tin nhắn..."
          />
          <button type="submit" :disabled="!canSend || isConnecting" aria-label="Gửi tin nhắn">
            <Send class="h-4 w-4" />
          </button>
        </form>
      </template>

      <p v-if="errorMessage" class="chat-widget-error">{{ errorMessage }}</p>

      <footer class="chat-widget-footer">
        <a
          :href="zaloChatUrl"
          target="_blank"
          rel="noopener noreferrer"
          class="chat-widget-zalo-inline"
        >
          Mở Zalo để tư vấn nhanh
        </a>
      </footer>
    </section>
  </div>
</template>

<style scoped>
.chat-widget-root {
  position: fixed;
  right: 20px;
  bottom: 20px;
  z-index: 70;
}

.chat-widget-launchers {
  display: grid;
  gap: 10px;
  justify-items: stretch;
}

.chat-widget-launcher {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;
  height: 44px;
  padding: 0 16px;
  border: 0;
  border-radius: 999px;
  color: #fff;
  font-size: 13px;
  font-weight: 700;
  text-decoration: none;
  cursor: pointer;
}

.chat-widget-launcher :deep(svg) {
  width: 18px;
  height: 18px;
}

.chat-widget-zalo {
  background: #0068ff;
  box-shadow: 0 12px 28px rgba(0, 104, 255, 0.24);
}

.chat-widget-zalo-mark {
  display: grid;
  place-items: center;
  width: 18px;
  height: 18px;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.2);
  font-size: 11px;
  font-weight: 900;
  line-height: 1;
}

.chat-widget-toggle {
  background: linear-gradient(135deg, #007a35, #0b4a22);
  box-shadow: 0 12px 28px rgba(0, 122, 53, 0.24);
}

.chat-widget-panel {
  position: absolute;
  right: 0;
  bottom: calc(100% + 12px);
  width: min(300px, calc(100vw - 24px));
  height: 400px;
  display: flex;
  flex-direction: column;
  border-radius: 18px;
  overflow: hidden;
  background: #fff;
  border: 1px solid #e9dfc8;
  box-shadow: 0 18px 44px rgba(13, 47, 27, 0.16);
  font-size: 12px;
}

.chat-widget-root.is-open .chat-widget-panel {
  bottom: 0;
}

.chat-widget-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 8px;
  padding: 12px 12px 10px;
  background: linear-gradient(135deg, #0b4a22, #007a35);
  color: #fff;
}

.chat-widget-eyebrow {
  margin: 0;
  font-size: 9px;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  opacity: 0.8;
}

.chat-widget-title {
  margin: 2px 0 0;
  font-size: 15px;
  font-weight: 800;
  line-height: 1.25;
}

.chat-widget-close {
  border: 0;
  background: rgba(255, 255, 255, 0.14);
  color: #fff;
  width: 28px;
  height: 28px;
  border-radius: 8px;
  display: grid;
  place-items: center;
  cursor: pointer;
}

.chat-widget-close :deep(svg) {
  width: 16px;
  height: 16px;
}

.chat-widget-intake,
.chat-widget-messages,
.chat-widget-composer {
  padding: 10px;
}

.chat-widget-intake {
  display: grid;
  gap: 8px;
}

.chat-widget-copy {
  margin: 0;
  color: #607d62;
  font-size: 12px;
  line-height: 1.4;
}

.chat-widget-field {
  display: grid;
  gap: 4px;
  font-size: 11px;
  font-weight: 600;
  color: #0d2f1b;
}

.chat-widget-field input,
.chat-widget-composer input {
  width: 100%;
  border: 1px solid #e9dfc8;
  border-radius: 10px;
  padding: 8px 10px;
  font-size: 12px;
  outline: none;
}

.chat-widget-field input[readonly] {
  background: #f8faf8;
  color: #607d62;
}

.chat-widget-field input:focus,
.chat-widget-composer input:focus {
  box-shadow: 0 0 0 4px rgba(0, 122, 53, 0.12);
  border-color: #007a35;
}

.chat-widget-primary {
  border: 0;
  border-radius: 10px;
  padding: 8px 12px;
  background: #007a35;
  color: #fff;
  font-size: 12px;
  font-weight: 700;
  cursor: pointer;
}

.chat-widget-messages {
  flex: 1;
  overflow-y: auto;
  display: grid;
  gap: 8px;
  align-content: start;
  background: #fff7e6;
}

.chat-widget-status {
  margin: 0;
  text-align: center;
  color: #607d62;
  font-size: 11px;
}

.chat-widget-message {
  max-width: 88%;
  border-radius: 12px;
  padding: 7px 9px;
  background: #fff;
  border: 1px solid #f4e7c7;
}

.chat-widget-message.is-visitor {
  margin-left: auto;
  background: #e7f6d2;
  border-color: #cde8b0;
}

.chat-widget-message-meta {
  margin: 0 0 3px;
  font-size: 9px;
  font-weight: 700;
  color: #0d2f1b;
  display: flex;
  justify-content: space-between;
  gap: 6px;
}

.chat-widget-message-meta span {
  font-weight: 500;
  color: #8ea28f;
}

.chat-widget-message-body {
  margin: 0;
  white-space: pre-wrap;
  word-break: break-word;
  color: #0d2f1b;
  font-size: 12px;
  line-height: 1.4;
}

.chat-widget-composer {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 8px;
  border-top: 1px solid #f4e7c7;
  background: #fff;
}

.chat-widget-composer button {
  width: 34px;
  height: 34px;
  border: 0;
  border-radius: 10px;
  background: #007a35;
  color: #fff;
  display: grid;
  place-items: center;
  cursor: pointer;
}

.chat-widget-composer button :deep(svg) {
  width: 14px;
  height: 14px;
}

.chat-widget-composer button:disabled,
.chat-widget-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.chat-widget-error {
  margin: 0;
  padding: 0 10px 10px;
  color: #dc2626;
  font-size: 11px;
}

.chat-widget-footer {
  padding: 0 10px 10px;
  border-top: 1px solid #f4e7c7;
  background: #fff;
}

.chat-widget-zalo-inline {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  width: 100%;
  margin-top: 8px;
  padding: 8px 10px;
  border-radius: 10px;
  border: 1px solid #b8d4ff;
  background: #f0f6ff;
  color: #0068ff;
  font-size: 12px;
  font-weight: 700;
  text-decoration: none;
  transition: background-color 0.2s ease;
}

.chat-widget-zalo-inline:hover {
  background: #e3efff;
}
</style>
