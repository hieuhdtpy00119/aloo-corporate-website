import { Client } from '@stomp/stompjs'
import api from './api'

const CHAT_TOKEN_KEY = 'aloo_chat_session_token'
const CHAT_OWNER_KEY = 'aloo_chat_session_owner'

export const getStoredChatToken = () => localStorage.getItem(CHAT_TOKEN_KEY) || ''

export const getStoredChatOwner = () => localStorage.getItem(CHAT_OWNER_KEY) || ''

export const storeChatToken = (token, owner = 'guest') => {
  if (token) {
    localStorage.setItem(CHAT_TOKEN_KEY, token)
    localStorage.setItem(CHAT_OWNER_KEY, owner)
  } else {
    localStorage.removeItem(CHAT_TOKEN_KEY)
    localStorage.removeItem(CHAT_OWNER_KEY)
  }
}

export const getWsBaseUrl = () => {
  const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:8080/api'
  return apiUrl.replace(/\/api\/?$/, '')
}

export const getChatWsUrl = (chatToken = '') => {
  const base = getWsBaseUrl().replace(/^http/i, 'ws')
  const query = chatToken ? `?chatToken=${encodeURIComponent(chatToken)}` : ''
  return `${base}/ws${query}`
}

export const chatSessionTopic = (sessionId) => `/topic/chat/session.${sessionId}`

export const chatAdminInboxTopic = '/topic/admin/chat/inbox'

export const createChatClient = ({ chatToken = '', adminToken = '', onConnect, onError } = {}) => {
  const client = new Client({
    brokerURL: getChatWsUrl(chatToken),
    reconnectDelay: 4000,
    connectHeaders: adminToken ? { Authorization: `Bearer ${adminToken}` } : {},
    onConnect: (frame) => onConnect?.(client, frame),
    onStompError: (frame) => onError?.(frame),
    onWebSocketError: (event) => onError?.(event),
  })

  client.activate()
  return client
}

export const createChatSession = async (payload) => {
  const { data } = await api.post('/chat/sessions', payload)
  storeChatToken(data.sessionToken, 'guest')
  return data
}

export const createAccountChatSession = async () => {
  const { data } = await api.post('/chat/sessions/account')
  storeChatToken(data.sessionToken, 'account')
  return data
}

export const fetchVisitorChatSession = async (sessionToken = getStoredChatToken()) => {
  const { data } = await api.get('/chat/sessions/mine', {
    headers: { 'X-Chat-Token': sessionToken },
  })
  return data
}

export const fetchAdminChatSessions = async () => {
  const { data } = await api.get('/admin/chat/sessions')
  return data
}

export const fetchAdminChatSession = async (sessionId) => {
  const { data } = await api.get(`/admin/chat/sessions/${sessionId}`)
  return data
}

export const updateAdminChatSessionStatus = async (sessionId, status) => {
  const { data } = await api.patch(`/admin/chat/sessions/${sessionId}/status`, { status })
  return data
}

export const markAdminChatSessionRead = async (sessionId) => {
  await api.post(`/admin/chat/sessions/${sessionId}/read`)
}

export const sendVisitorChatMessage = (client, sessionToken, body) => {
  client.publish({
    destination: '/app/chat.visitor.send',
    body: JSON.stringify({ sessionToken, body }),
    headers: { 'content-type': 'application/json' },
  })
}

export const sendAdminChatMessage = (client, sessionId, body) => {
  client.publish({
    destination: '/app/chat.admin.send',
    body: JSON.stringify({ sessionId, body }),
    headers: { 'content-type': 'application/json' },
  })
}
