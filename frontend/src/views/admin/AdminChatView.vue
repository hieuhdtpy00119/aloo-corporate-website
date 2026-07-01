<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { MessageSquare, Phone, Search, Send } from 'lucide-vue-next'
import AdminListPage from '../../components/admin/AdminListPage.vue'
import AdminNestedShell from '../../components/admin/shell/AdminNestedShell.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import AlooStatusBadge from '../../components/ui/AlooStatusBadge.vue'
import { useAdminModuleI18n } from '../../composables/useAdminModuleI18n'
import { useToastStore } from '../../stores/toastStore'
import { repairUtf8Mojibake } from '../../utils/textEncoding'
import {
  chatAdminInboxTopic,
  chatSessionTopic,
  createChatClient,
  fetchAdminChatSession,
  fetchAdminChatSessions,
  markAdminChatSessionRead,
  sendAdminChatMessage,
  updateAdminChatSessionStatus,
} from '../../services/chatService'
import '../../styles/admin-shell-page.css'

const { m, t } = useAdminModuleI18n('chat')
const toast = useToastStore()
const route = useRoute()
const router = useRouter()

const sessions = ref([])
const selectedSession = ref(null)
const messages = ref([])
const draft = ref('')
const searchQuery = ref('')
const isLoading = ref(false)
const isSending = ref(false)
const messagesEl = ref(null)
const clientRef = ref(null)
const inboxSubscriptionRef = ref(null)
const sessionSubscriptionRef = ref(null)

const statusOptions = ['OPEN', 'ACTIVE', 'CLOSED']

const selectedSessionId = computed(() => selectedSession.value?.id || null)
const isClosed = computed(() => selectedSession.value?.status === 'CLOSED')
const canSend = computed(() => selectedSessionId.value && !isClosed.value && draft.value.trim() && !isSending.value)

const filteredSessions = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  if (!keyword) return sessions.value
  return sessions.value.filter((session) =>
    [session.visitorName, session.visitorPhone, String(session.id)]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
      .includes(keyword),
  )
})

const statusLabel = (status) => {
  const key = `statuses.${String(status || 'OPEN').toLowerCase()}`
  const translated = m(key)
  return translated === key ? status : translated
}

const statusHint = (status) => {
  const key = `statusHints.${String(status || 'OPEN').toLowerCase()}`
  const translated = m(key)
  return translated === key ? '' : translated
}

const formatListTime = (value) => {
  if (!value) return ''
  return new Date(value).toLocaleString('vi-VN', {
    hour: '2-digit',
    minute: '2-digit',
    day: '2-digit',
    month: '2-digit',
  })
}

const formatMessageTime = (value) => {
  if (!value) return ''
  return new Date(value).toLocaleTimeString('vi-VN', {
    hour: '2-digit',
    minute: '2-digit',
  })
}

const visitorInitials = (name) => {
  const parts = String(name || 'K').trim().split(/\s+/).filter(Boolean)
  if (!parts.length) return 'K'
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase()
  return `${parts[0][0]}${parts[parts.length - 1][0]}`.toUpperCase()
}

const messageLabel = (message) => {
  if (message.senderType === 'ADMIN') {
    if (!message.senderAdminId) return m('messageAuto')
    return m('messageAdmin')
  }
  return m('messageVisitor', { name: message.senderName || m('messageVisitorFallback') })
}

const normalizeMessage = (message) => ({
  ...message,
  body: repairUtf8Mojibake(message.body),
  senderName: repairUtf8Mojibake(message.senderName),
})

const scrollToBottom = async () => {
  await nextTick()
  if (messagesEl.value) {
    messagesEl.value.scrollTop = messagesEl.value.scrollHeight
  }
}

const upsertSession = (session) => {
  const index = sessions.value.findIndex((item) => item.id === session.id)
  if (index === -1) {
    sessions.value.unshift(session)
    return
  }
  sessions.value[index] = { ...sessions.value[index], ...session }
  sessions.value.sort((left, right) => new Date(right.updatedAt) - new Date(left.updatedAt))
}

const loadSessions = async () => {
  isLoading.value = true
  try {
    sessions.value = await fetchAdminChatSessions()
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.loadFailed'))
  } finally {
    isLoading.value = false
  }
}

const subscribeSessionTopic = (sessionId) => {
  sessionSubscriptionRef.value?.unsubscribe()
  if (!clientRef.value?.connected || !sessionId) return

  sessionSubscriptionRef.value = clientRef.value.subscribe(chatSessionTopic(sessionId), (frame) => {
    const message = JSON.parse(frame.body)
    if (selectedSessionId.value === message.sessionId && !messages.value.some((item) => item.id === message.id)) {
      messages.value.push(normalizeMessage(message))
      scrollToBottom()
    }
  })
}

const openSession = async (session) => {
  try {
    const data = await fetchAdminChatSession(session.id)
    selectedSession.value = data
    messages.value = (data.messages || []).map(normalizeMessage)
    upsertSession(data)
    subscribeSessionTopic(data.id)
    scrollToBottom()
    if (String(route.query.session || '') !== String(data.id)) {
      router.replace({ query: { ...route.query, session: data.id } })
    }
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.loadFailed'))
  }
}

const connectRealtime = () => {
  const token = localStorage.getItem('admin_token')
  if (!token) return

  clientRef.value?.deactivate()
  clientRef.value = createChatClient({
    adminToken: token,
    onConnect: (client) => {
      inboxSubscriptionRef.value = client.subscribe(chatAdminInboxTopic, (frame) => {
        const event = JSON.parse(frame.body)
        if (event?.session) {
          upsertSession(event.session)
        }
      })
      if (selectedSessionId.value) {
        subscribeSessionTopic(selectedSessionId.value)
      }
    },
  })
}

const submitMessage = async () => {
  if (!canSend.value || !clientRef.value?.connected) return
  const body = draft.value.trim()
  draft.value = ''
  isSending.value = true
  try {
    sendAdminChatMessage(clientRef.value, selectedSessionId.value, body)
  } catch {
    toast.error(m('toasts.sendFailed'))
    draft.value = body
  } finally {
    isSending.value = false
  }
}

const changeStatus = async (status) => {
  if (!selectedSessionId.value || selectedSession.value?.status === status) return
  try {
    const updated = await updateAdminChatSessionStatus(selectedSessionId.value, status)
    selectedSession.value = { ...selectedSession.value, ...updated }
    upsertSession(updated)
    toast.success(m('toasts.statusUpdated'))
  } catch (error) {
    toast.error(error.response?.data?.message || m('toasts.statusFailed'))
  }
}

const markRead = async () => {
  if (!selectedSessionId.value) return
  try {
    await markAdminChatSessionRead(selectedSessionId.value)
    upsertSession({ ...selectedSession.value, unreadCount: 0 })
  } catch {
    // no-op
  }
}

watch(selectedSessionId, (sessionId) => {
  if (sessionId) {
    markRead()
    subscribeSessionTopic(sessionId)
  }
})

onMounted(async () => {
  await loadSessions()
  connectRealtime()

  const querySessionId = Number(route.query.session)
  if (querySessionId) {
    const match = sessions.value.find((item) => item.id === querySessionId)
    if (match) {
      await openSession(match)
    } else {
      await openSession({ id: querySessionId })
    }
  }
})

onBeforeUnmount(() => {
  inboxSubscriptionRef.value?.unsubscribe()
  sessionSubscriptionRef.value?.unsubscribe()
  clientRef.value?.deactivate()
})
</script>

<template>
  <AdminListPage>
    <div class="admin-chat-page">
      <AdminPageHeader :title="m('title')" />

      <AdminNestedShell class="admin-shell admin-chat-shell">
        <div class="admin-chat-workspace">
          <aside class="admin-chat-sidebar">
            <div class="admin-chat-sidebar__head">
              <h2>{{ m('sessionsTitle') }} · {{ filteredSessions.length }}</h2>
            </div>

            <label class="admin-chat-search">
              <Search class="h-3.5 w-3.5" />
              <input
                v-model="searchQuery"
                type="search"
                class="aloo-input"
                :placeholder="m('searchPlaceholder')"
              />
            </label>

            <div class="admin-chat-session-list">
              <p v-if="isLoading" class="admin-chat-muted">{{ t('admin.shared.loading') }}</p>

              <div v-else-if="!filteredSessions.length" class="admin-chat-empty-wrap">
                <EmptyState :title="m('emptyTitle')" :description="m('emptyDescription')" />
              </div>

              <button
                v-for="session in filteredSessions"
                :key="session.id"
                type="button"
                class="admin-chat-session"
                :class="{ 'is-active': selectedSessionId === session.id }"
                @click="openSession(session)"
              >
                <div class="admin-chat-session__avatar">{{ visitorInitials(session.visitorName) }}</div>
                <div class="admin-chat-session__body">
                  <div class="admin-chat-session__top">
                    <strong>{{ session.visitorName }}</strong>
                    <span v-if="session.unreadCount" class="admin-chat-badge">{{ session.unreadCount }}</span>
                  </div>
                  <div class="admin-chat-session__meta">
                    <AlooStatusBadge :status="session.status" :label="statusLabel(session.status)" />
                    <time>{{ formatListTime(session.lastMessageAt || session.updatedAt) }}</time>
                  </div>
                </div>
              </button>
            </div>
          </aside>

          <section class="admin-chat-panel">
            <template v-if="selectedSession">
              <header class="admin-chat-panel__head">
                <div class="admin-chat-panel__identity">
                  <div class="admin-chat-panel__avatar">{{ visitorInitials(selectedSession.visitorName) }}</div>
                  <div>
                    <h2>{{ selectedSession.visitorName }}</h2>
                    <p>
                      <Phone class="h-3.5 w-3.5" />
                      {{ selectedSession.visitorPhone }}
                    </p>
                  </div>
                </div>

                <div class="admin-chat-status-wrap">
                  <div class="admin-chat-status-group" role="tablist" :aria-label="m('statusLabel')">
                    <button
                      v-for="status in statusOptions"
                      :key="status"
                      type="button"
                      class="admin-chat-status-group__btn"
                      :class="{ 'is-active': selectedSession.status === status }"
                      :title="statusHint(status)"
                      @click="changeStatus(status)"
                    >
                      {{ statusLabel(status) }}
                    </button>
                  </div>
                </div>
              </header>

              <div ref="messagesEl" class="admin-chat-messages">
                <p v-if="!messages.length" class="admin-chat-muted admin-chat-muted--center">
                  {{ m('noMessages') }}
                </p>

                <article
                  v-for="message in messages"
                  :key="message.id"
                  :class="['admin-chat-message', message.senderType === 'ADMIN' ? 'is-admin' : 'is-visitor']"
                >
                  <div class="admin-chat-message__bubble">
                    <p class="admin-chat-message__body">{{ message.body }}</p>
                    <time>{{ formatMessageTime(message.createdAt) }}</time>
                  </div>
                </article>
              </div>

              <form class="admin-chat-composer" @submit.prevent="submitMessage">
                <textarea
                  v-model="draft"
                  rows="1"
                  class="aloo-input admin-chat-composer__input"
                  :disabled="isClosed"
                  :placeholder="isClosed ? m('closedPlaceholder') : m('composerPlaceholder')"
                  @keydown.enter.exact.prevent="submitMessage"
                />
                <button type="submit" class="admin-chat-composer__send" :disabled="!canSend" :title="m('send')">
                  <Send class="h-4 w-4" />
                </button>
              </form>
            </template>

            <div v-else class="admin-chat-panel__empty">
              <div class="admin-chat-panel__empty-icon">
                <MessageSquare class="h-6 w-6" />
              </div>
              <h3>{{ m('selectTitle') }}</h3>
              <p>{{ m('selectDescription') }}</p>
            </div>
          </section>
        </div>
      </AdminNestedShell>
    </div>
  </AdminListPage>
</template>

<style scoped>
.admin-chat-page {
  display: grid;
  gap: 6px;
}

.admin-chat-page :deep(.aloo-admin-header) {
  margin-bottom: 0;
}

.admin-chat-page :deep(.aloo-title--admin) {
  font-size: 1.15rem;
  line-height: 1.3;
}

.admin-chat-shell {
  overflow: hidden;
}

.admin-chat-workspace {
  display: grid;
  grid-template-columns: minmax(168px, 200px) minmax(0, 1fr);
  height: min(400px, calc(100vh - 240px));
  max-height: 400px;
}

.admin-chat-sidebar,
.admin-chat-panel {
  min-height: 0;
  display: flex;
  flex-direction: column;
  background: #fff;
}

.admin-chat-sidebar {
  border-right: 1px solid #e2e8f0;
}

.admin-chat-sidebar__head {
  padding: 8px 10px;
  border-bottom: 1px solid #f1f5f9;
}

.admin-chat-sidebar__head h2 {
  margin: 0;
  font-size: 12px;
  font-weight: 800;
  color: #0f172a;
}

.admin-chat-search {
  display: flex;
  align-items: center;
  gap: 6px;
  margin: 6px 8px;
  padding: 0 8px;
  border: 1px solid #e2e8f0;
  border-radius: 7px;
  background: #f8fafc;
  color: #94a3b8;
}

.admin-chat-search .aloo-input {
  border: 0;
  background: transparent;
  box-shadow: none;
  padding: 5px 0;
  font-size: 12px;
}

.admin-chat-session-list {
  flex: 1;
  overflow-y: auto;
  padding: 0 4px 6px;
}

.admin-chat-session {
  width: 100%;
  display: grid;
  grid-template-columns: 28px minmax(0, 1fr);
  gap: 6px;
  text-align: left;
  border: 1px solid transparent;
  border-radius: 8px;
  background: transparent;
  padding: 6px;
  cursor: pointer;
  transition: background 0.15s ease, border-color 0.15s ease;
}

.admin-chat-session:hover {
  background: #f8fafc;
}

.admin-chat-session.is-active {
  background: #f0fdf4;
  border-color: #bbf7d0;
}

.admin-chat-session__avatar,
.admin-chat-panel__avatar {
  width: 28px;
  height: 28px;
  border-radius: 8px;
  display: grid;
  place-items: center;
  background: linear-gradient(135deg, #0b4a22, #007a35);
  color: #fff;
  font-size: 10px;
  font-weight: 800;
}

.admin-chat-session__top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 4px;
}

.admin-chat-session__top strong {
  font-size: 12px;
  color: #0f172a;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.admin-chat-session__meta {
  margin-top: 4px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 4px;
  font-size: 10px;
  color: #94a3b8;
}

.admin-chat-session__meta :deep(.aloo-status) {
  font-size: 10px;
  padding: 2px 6px;
}

.admin-chat-badge {
  min-width: 16px;
  height: 16px;
  border-radius: 999px;
  background: #dc2626;
  color: #fff;
  display: grid;
  place-items: center;
  font-size: 9px;
  font-weight: 700;
  padding: 0 4px;
  flex-shrink: 0;
}

.admin-chat-panel__head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 8px 10px;
  border-bottom: 1px solid #e2e8f0;
  background: #fcfcfd;
}

.admin-chat-panel__identity {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}

.admin-chat-panel__identity h2 {
  margin: 0;
  font-size: 13px;
  font-weight: 800;
  color: #0f172a;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.admin-chat-panel__identity p {
  margin: 1px 0 0;
  display: flex;
  align-items: center;
  gap: 4px;
  color: #64748b;
  font-size: 11px;
}

.admin-chat-status-wrap {
  flex-shrink: 0;
}

.admin-chat-status-group {
  display: inline-flex;
  padding: 3px;
  border-radius: 9px;
  background: #f1f5f9;
  gap: 3px;
  flex-shrink: 0;
}

.admin-chat-status-group__btn {
  border: 0;
  background: transparent;
  color: #64748b;
  border-radius: 6px;
  padding: 4px 7px;
  font-size: 10px;
  font-weight: 700;
  cursor: pointer;
  white-space: nowrap;
}

.admin-chat-status-group__btn.is-active {
  background: #0b4a22;
  color: #fff;
}

.admin-chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 8px 10px;
  display: flex;
  flex-direction: column;
  gap: 6px;
  background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
}

.admin-chat-message {
  display: flex;
}

.admin-chat-message.is-visitor {
  justify-content: flex-start;
}

.admin-chat-message.is-admin {
  justify-content: flex-end;
}

.admin-chat-message__bubble {
  max-width: min(88%, 360px);
  border-radius: 10px;
  padding: 6px 8px;
  box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
}

.admin-chat-message.is-visitor .admin-chat-message__bubble {
  background: #fff;
  border: 1px solid #e2e8f0;
  border-bottom-left-radius: 4px;
}

.admin-chat-message.is-admin .admin-chat-message__bubble {
  background: linear-gradient(135deg, #0b4a22, #007a35);
  color: #fff;
  border-bottom-right-radius: 4px;
}

.admin-chat-message__body {
  margin: 0;
  white-space: pre-wrap;
  word-break: break-word;
  line-height: 1.4;
  font-size: 12px;
}

.admin-chat-message__bubble time {
  display: block;
  margin-top: 2px;
  font-size: 9px;
  opacity: 0.7;
  text-align: right;
}

.admin-chat-composer {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 6px;
  padding: 8px 10px;
  border-top: 1px solid #e2e8f0;
  background: #fff;
}

.admin-chat-composer__input {
  resize: none;
  min-height: 32px;
  font-size: 12px;
  padding-top: 7px;
  padding-bottom: 7px;
}

.admin-chat-composer__send {
  display: inline-grid;
  place-items: center;
  border: 0;
  border-radius: 8px;
  width: 34px;
  height: 34px;
  min-width: 34px;
  padding: 0;
  background: #0b4a22;
  color: #fff;
  cursor: pointer;
}

.admin-chat-composer__send:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.admin-chat-panel__empty,
.admin-chat-empty-wrap {
  flex: 1;
  display: grid;
  place-items: center;
  padding: 20px 16px;
  text-align: center;
}

.admin-chat-panel__empty-icon {
  width: 52px;
  height: 52px;
  border-radius: 14px;
  display: grid;
  place-items: center;
  margin: 0 auto 10px;
  background: #f0fdf4;
  color: #0b4a22;
}

.admin-chat-panel__empty h3 {
  margin: 0;
  font-size: 15px;
  font-weight: 800;
  color: #0f172a;
}

.admin-chat-panel__empty p,
.admin-chat-muted {
  margin: 6px 0 0;
  color: #64748b;
  font-size: 13px;
  line-height: 1.5;
}

.admin-chat-muted--center {
  text-align: center;
  width: 100%;
}

@media (max-width: 1100px) {
  .admin-chat-workspace {
    grid-template-columns: 1fr;
    height: auto;
    max-height: none;
  }

  .admin-chat-sidebar {
    max-height: 160px;
    border-right: 0;
    border-bottom: 1px solid #e2e8f0;
  }

  .admin-chat-panel__head {
    flex-direction: column;
    align-items: stretch;
  }

  .admin-chat-status-group {
    width: 100%;
    justify-content: space-between;
  }
}
</style>
