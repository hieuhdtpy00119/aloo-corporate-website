<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { Camera, KeyRound, MoreVertical, Plus, UserRound, UserCog } from 'lucide-vue-next'
import AccountsRowActions from '../../components/admin/accounts/AccountsRowActions.vue'
import BaseModal from '../../components/admin/BaseModal.vue'
import AdminListPage from '../../components/admin/AdminListPage.vue'
import AdminNestedShell from '../../components/admin/shell/AdminNestedShell.vue'
import AdminShellFrame from '../../components/admin/shell/AdminShellFrame.vue'
import AdminShellTablePanel from '../../components/admin/shell/AdminShellTablePanel.vue'
import AdminShellTabs from '../../components/admin/shell/AdminShellTabs.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import Pagination from '../../components/admin/Pagination.vue'
import SearchFilterBar from '../../components/admin/SearchFilterBar.vue'
import {
  accountService,
  normalizeStorageAssetUrl,
  resolveBackendAssetUrl,
  uploadService,
} from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'
import { MIN_PASSWORD_LENGTH, getNewPasswordErrorKey } from '../../utils/passwordPolicy'
import { isGoogleManagedAccount, isCurrentSessionUser } from '../../utils/accountAuth'

const toast = useToastStore()
const { t } = useI18n()
const activeTab = ref('admins')
const searchQuery = ref('')
const statusFilter = ref(t('admin.accounts.allStatuses'))
const openMenuUserId = ref(null)
const brokenAvatars = ref({})
const currentPage = ref(1)
const pageSize = 8
const isLoading = ref(false)
const errorMessage = ref('')
const adminUsers = ref([])
const customerUsers = ref([])
const showUserModal = ref(false)
const showPasswordModal = ref(false)
const editingUser = ref(null)
const pendingDelete = ref(null)
const pendingStatusChange = ref(null)
const pendingPromote = ref(null)
const pendingDemote = ref(null)
const promoteProfile = ref('FULL')
const adminEmailWhitelist = ref({ enabled: false, emails: [] })
const isUploadingAvatar = ref(false)

const accountTypes = [
  { key: 'admins', labelKey: 'admin.accounts.tabAdmins' },
  { key: 'customers', labelKey: 'admin.accounts.tabCustomers' },
]
const adminProfileOptions = ['FULL', 'CONTENT', 'STORES', 'CRM', 'SYSTEM']
const statusOptions = ['ACTIVE', 'INACTIVE', 'LOCKED']
const statusLabels = computed(() => ({
  ACTIVE: t('admin.accounts.status.ACTIVE'),
  INACTIVE: t('admin.accounts.status.INACTIVE'),
  LOCKED: t('admin.accounts.status.LOCKED'),
}))
const statusShortLabels = computed(() => ({
  ACTIVE: t('admin.accounts.statusShort.ACTIVE'),
  INACTIVE: t('admin.accounts.statusShort.INACTIVE'),
  LOCKED: t('admin.accounts.statusShort.LOCKED'),
}))
const statusFilters = computed(() => [
  t('admin.accounts.allStatuses'),
  ...statusOptions.map((status) => statusLabels.value[status]),
])
const resolveStatusFilter = (label) => {
  if (!label || label === t('admin.accounts.allStatuses')) return 'ALL'
  return statusOptions.find((status) => statusLabels.value[status] === label) || 'ALL'
}

const form = reactive({
  email: '',
  fullName: '',
  phone: '',
  avatarUrl: '',
  status: 'ACTIVE',
  adminProfile: 'FULL',
  password: '',
})
const passwordForm = reactive({ password: '' })

const currentUsers = computed(() => (activeTab.value === 'admins' ? adminUsers.value : customerUsers.value))
const filteredUsers = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return currentUsers.value.filter((user) => {
    const matchesKeyword = !keyword || [user.email, user.fullName, user.phone, roleLabel(user)]
      .filter(Boolean)
      .some((value) => String(value).toLowerCase().includes(keyword))
    const matchesStatus = resolveStatusFilter(statusFilter.value) === 'ALL'
      || user.status === resolveStatusFilter(statusFilter.value)
    return matchesKeyword && matchesStatus
  })
})
const totalPages = computed(() => Math.max(1, Math.ceil(filteredUsers.value.length / pageSize)))
const paginatedUsers = computed(() =>
  filteredUsers.value.slice((currentPage.value - 1) * pageSize, currentPage.value * pageSize),
)
const accountTabItems = computed(() =>
  accountTypes.map((type) => ({
    key: type.key,
    label: tabLabel(type),
  })),
)
const avatarPreviewUrl = computed(() => resolveBackendAssetUrl(form.avatarUrl || ''))

const statusTextClass = (status) => ({
  'accounts-status--inactive': status === 'INACTIVE',
  'accounts-status--locked': status === 'LOCKED',
})

const menuLabels = computed(() => ({
  actions: t('admin.accounts.columns.actions'),
  promote: t('admin.accounts.actions.promote'),
  demote: t('admin.accounts.actions.demote'),
  password: t('admin.accounts.actions.password'),
  edit: t('admin.accounts.actions.edit'),
  delete: t('admin.accounts.actions.delete'),
  lockAccount: t('admin.accounts.actions.lockAccount'),
  activateAccount: t('admin.accounts.actions.activateAccount'),
}))

const formatDate = (value) => (value ? String(value).replace('T', ' ').slice(0, 16) : '-')

const roleLabel = (user) => {
  if (activeTab.value === 'admins') {
    return t(`admin.roles.${user.adminProfile || 'FULL'}`)
  }
  return t('admin.accounts.customerRoleLabel')
}

const isGoogleAccount = isGoogleManagedAccount
const isSessionUser = isCurrentSessionUser

const editFormAccess = computed(() => {
  const isCreate = !editingUser.value
  const user = editingUser.value
  const self = Boolean(user && isSessionUser(user))
  const google = Boolean(user && isGoogleAccount(user))
  const isAdminTab = activeTab.value === 'admins'

  return {
    fullName: true,
    phone: true,
    avatar: true,
    email: isCreate || (!self && !google),
    adminProfile: isAdminTab && (isCreate || !self),
    status: isCreate || !self,
    password: isCreate,
  }
})

const fieldLockHint = (field) => {
  const user = editingUser.value
  if (!user) return ''
  if (field === 'email' && isGoogleAccount(user)) return t('admin.accounts.modals.lockHints.googleEmail')
  if (field === 'email' && isSessionUser(user)) return t('admin.accounts.modals.lockHints.selfEmail')
  if (field === 'status' && isSessionUser(user)) return t('admin.accounts.modals.lockHints.selfStatus')
  if (field === 'adminProfile' && isSessionUser(user)) return t('admin.accounts.modals.lockHints.selfProfile')
  return ''
}

const lockedFieldClass = (locked) => (
  locked
    ? 'accounts-field-input accounts-field-input--locked'
    : 'accounts-field-input'
)

const avatarUrlFor = (user) => resolveBackendAssetUrl(user.avatarUrl || '')

const showAvatar = (user) => Boolean(user.avatarUrl) && !brokenAvatars.value[user.id]

const onAvatarError = (userId) => {
  brokenAvatars.value = { ...brokenAvatars.value, [userId]: true }
}

watch([activeTab, searchQuery, statusFilter], () => {
  currentPage.value = 1
})

watch(totalPages, (pages) => {
  if (currentPage.value > pages) currentPage.value = pages
})

const loadAccounts = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const [admins, customers, whitelist] = await Promise.all([
      accountService.listAdmins(),
      accountService.listCustomers(),
      accountService.getAdminEmailWhitelist(),
    ])
    adminUsers.value = Array.isArray(admins.data) ? admins.data : []
    customerUsers.value = Array.isArray(customers.data) ? customers.data : []
    adminEmailWhitelist.value = whitelist.data || { enabled: false, emails: [] }
  } catch (error) {
    errorMessage.value = error.response?.data?.message || t('admin.accounts.loadError')
  } finally {
    isLoading.value = false
  }
}

const resetForm = () => {
  Object.assign(form, {
    email: '',
    fullName: '',
    phone: '',
    avatarUrl: '',
    status: 'ACTIVE',
    adminProfile: 'FULL',
    password: '',
  })
  editingUser.value = null
}

const openCreateModal = () => {
  resetForm()
  showUserModal.value = true
}

const openEditModal = (user) => {
  editingUser.value = user
  Object.assign(form, {
    email: user.email || '',
    fullName: user.fullName || '',
    phone: user.phone || '',
    avatarUrl: user.avatarUrl || '',
    status: user.status || 'ACTIVE',
    adminProfile: user.adminProfile || 'FULL',
    password: '',
  })
  showUserModal.value = true
}

const closeUserModal = () => {
  showUserModal.value = false
  resetForm()
}

const handleAvatarUpload = async (event) => {
  const file = event.target.files?.[0]
  event.target.value = ''
  if (!file) return

  if (!file.type.startsWith('image/')) {
    toast.error(t('admin.profile.toasts.invalidImageType'))
    return
  }
  if (file.size > 5 * 1024 * 1024) {
    toast.error(t('admin.profile.toasts.imageTooLarge'))
    return
  }

  isUploadingAvatar.value = true
  try {
    const { data } = await uploadService.image(file)
    form.avatarUrl = normalizeStorageAssetUrl(data.url)
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.profile.toasts.avatarUploadError'))
  } finally {
    isUploadingAvatar.value = false
  }
}

const buildPayload = () => {
  const user = editingUser.value
  const access = editFormAccess.value

  return {
    email: access.email ? form.email.trim() : (user?.email || form.email.trim()),
    fullName: form.fullName.trim(),
    phone: form.phone.trim(),
    avatarUrl: normalizeStorageAssetUrl(form.avatarUrl.trim()),
    status: access.status ? form.status : (user?.status || form.status),
    adminProfile: activeTab.value === 'admins'
      ? (access.adminProfile ? form.adminProfile : (user?.adminProfile || form.adminProfile))
      : null,
    password: form.password || null,
  }
}

const saveUser = async () => {
  if (!editingUser.value) {
    const errorKey = getNewPasswordErrorKey(form.password)
    if (errorKey) {
      toast.error(t(errorKey))
      return
    }
  }

  if (activeTab.value === 'admins' && editFormAccess.value.email && !isEmailWhitelisted(form.email)) {
    toast.error(t('admin.accounts.whitelistBlocked'))
    return
  }

  try {
    const payload = buildPayload()
    if (activeTab.value === 'admins') {
      editingUser.value
        ? await accountService.updateAdmin(editingUser.value.id, payload)
        : await accountService.createAdmin(payload)
    } else {
      editingUser.value
        ? await accountService.updateCustomer(editingUser.value.id, payload)
        : await accountService.createCustomer(payload)
    }
    toast.success(editingUser.value ? t('admin.accounts.saveSuccessUpdate') : t('admin.accounts.saveSuccessCreate'))
    closeUserModal()
    await loadAccounts()
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.accounts.saveError'))
  }
}

const updateStatus = async (user, status) => {
  try {
    activeTab.value === 'admins'
      ? await accountService.updateAdminStatus(user.id, status)
      : await accountService.updateCustomerStatus(user.id, status)
    toast.success(t('admin.accounts.statusUpdated'))
    await loadAccounts()
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.accounts.statusError'))
  }
}

const requestStatusChange = (user, event) => {
  const nextStatus = event?.target?.value ?? event
  if (nextStatus === user.status) return
  if (event?.target) event.target.value = user.status
  pendingStatusChange.value = { user, status: nextStatus }
}

const confirmStatusChange = async () => {
  if (!pendingStatusChange.value) return
  const { user, status } = pendingStatusChange.value
  pendingStatusChange.value = null
  await updateStatus(user, status)
}

const openPasswordModal = (user) => {
  if (isGoogleAccount(user)) {
    toast.error(t('admin.accounts.googlePasswordBlocked'))
    return
  }
  editingUser.value = user
  passwordForm.password = ''
  showPasswordModal.value = true
}

const savePassword = async () => {
  const errorKey = getNewPasswordErrorKey(passwordForm.password)
  if (errorKey) {
    toast.error(t(errorKey))
    return
  }

  try {
    if (activeTab.value === 'admins') {
      await accountService.changeAdminPassword(editingUser.value.id, passwordForm.password)
    } else {
      await accountService.changeCustomerPassword(editingUser.value.id, passwordForm.password)
    }
    toast.success(t('admin.accounts.passwordUpdated'))
    showPasswordModal.value = false
    passwordForm.password = ''
    editingUser.value = null
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.accounts.passwordError'))
  }
}

const confirmDelete = async () => {
  try {
    activeTab.value === 'admins'
      ? await accountService.removeAdmin(pendingDelete.value.id)
      : await accountService.removeCustomer(pendingDelete.value.id)
    toast.success(t('admin.accounts.deleteSuccess'))
    await loadAccounts()
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.accounts.deleteError'))
  } finally {
    pendingDelete.value = null
  }
}

const isEmailWhitelisted = (email) => {
  if (!adminEmailWhitelist.value.enabled) return true
  const normalized = String(email || '').trim().toLowerCase()
  return adminEmailWhitelist.value.emails.includes(normalized)
}

const openPromoteModal = (user) => {
  if (!isEmailWhitelisted(user.email)) {
    toast.error(t('admin.accounts.whitelistBlocked'))
    return
  }
  pendingPromote.value = user
  promoteProfile.value = 'FULL'
}

const confirmPromote = async () => {
  if (!pendingPromote.value) return
  try {
    await accountService.promoteCustomer(pendingPromote.value.id, promoteProfile.value)
    toast.success(t('admin.accounts.promoteSuccess'))
    pendingPromote.value = null
    await loadAccounts()
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.accounts.promoteError'))
  }
}

const openDemoteModal = (user) => {
  if (isSessionUser(user)) {
    toast.error(t('admin.accounts.selfDemoteBlocked'))
    return
  }
  pendingDemote.value = user
}

const confirmDemote = async () => {
  if (!pendingDemote.value) return
  try {
    await accountService.demoteAdmin(pendingDemote.value.id)
    toast.success(t('admin.accounts.demoteSuccess'))
    pendingDemote.value = null
    await loadAccounts()
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.accounts.demoteError'))
  }
}

const tabLabel = (type) => {
  const count = type.key === 'admins' ? adminUsers.value.length : customerUsers.value.length
  return `${t(type.labelKey)} (${count})`
}

const closeActionMenu = () => {
  openMenuUserId.value = null
}

const toggleActionMenu = (userId) => {
  openMenuUserId.value = openMenuUserId.value === userId ? null : userId
}

const runMenuAction = (action, user, payload) => {
  closeActionMenu()
  if (action === 'delete' && isSessionUser(user)) {
    toast.error(t('admin.accounts.selfDeleteBlocked'))
    return
  }
  if (action === 'status' && isSessionUser(user)) {
    toast.error(t('admin.accounts.selfStatusBlocked'))
    return
  }
  if (action === 'promote') openPromoteModal(user)
  else if (action === 'demote') openDemoteModal(user)
  else if (action === 'password') openPasswordModal(user)
  else if (action === 'edit') openEditModal(user)
  else if (action === 'delete') pendingDelete.value = user
  else if (action === 'status') requestStatusChange(user, payload)
}

const onRowAction = (user, action, payload) => {
  runMenuAction(action, user, payload)
}

onMounted(loadAccounts)
</script>

<template>
  <AdminListPage @click="closeActionMenu">
    <AdminNestedShell>
      <AdminShellFrame variant="header" inner="header">
        <AdminPageHeader :title="t('admin.accounts.title')">
          <template #actions>
            <button type="button" class="admin-list-btn admin-list-btn--primary" @click="openCreateModal">
              <Plus class="h-4 w-4" />
              {{ t('admin.accounts.addNew') }}
            </button>
          </template>
        </AdminPageHeader>
        <template #after>
          <AdminShellTabs
            v-model="activeTab"
            :items="accountTabItems"
            :aria-label="t('admin.accounts.title')"
          />
        </template>
      </AdminShellFrame>

      <AdminShellFrame variant="toolbar" inner="toolbar">
        <SearchFilterBar
          embedded
          v-model:search="searchQuery"
          v-model:status="statusFilter"
          :search-placeholder="t('admin.accounts.searchPlaceholder')"
          :status-label="t('admin.accounts.columns.status')"
          :status-options="statusFilters"
        />
      </AdminShellFrame>

      <AdminShellFrame
        v-if="errorMessage"
        as="p"
        variant="alert"
        class="admin-list-alert"
      >
        {{ errorMessage }}
      </AdminShellFrame>

      <AdminShellFrame v-if="isLoading" variant="body" inner="pad">
        <div v-for="i in 5" :key="i" class="admin-shell-skeleton" />
      </AdminShellFrame>

      <AdminShellFrame v-else-if="!filteredUsers.length" variant="body" inner="pad">
        <EmptyState
          :title="t('admin.accounts.emptyTitle')"
          :description="t('admin.accounts.emptyDescription')"
        />
      </AdminShellFrame>

      <AdminShellFrame v-else variant="body" visibility="desktop">
        <AdminShellTablePanel
          :title="t('admin.accounts.listTitle')"
          :count-text="t('admin.shared.totalCount', { count: filteredUsers.length })"
        >
          <table class="admin-shell-table accounts-table">
            <colgroup>
              <col class="accounts-col-name" />
              <col class="accounts-col-email" />
              <col class="accounts-col-status" />
              <col class="accounts-col-login" />
              <col class="accounts-col-actions" />
            </colgroup>
            <thead>
              <tr>
                <th class="accounts-col-name">
                  <span class="admin-shell-th-name">
                    <span class="admin-shell-th-name__spacer" aria-hidden="true" />
                    <span>{{ t('admin.accounts.columns.accountName') }}</span>
                  </span>
                </th>
                <th class="accounts-col-email">{{ t('admin.accounts.columns.email') }}</th>
                <th class="accounts-col-status">{{ t('admin.accounts.columns.status') }}</th>
                <th class="accounts-col-login">{{ t('admin.accounts.columns.lastLoginAt') }}</th>
                <th class="accounts-col-actions">{{ t('admin.accounts.columns.actions') }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="user in paginatedUsers" :key="user.id">
                <td class="accounts-col-name">
                  <div class="accounts-cell-name">
                    <img
                      v-if="showAvatar(user)"
                      :src="avatarUrlFor(user)"
                      alt=""
                      class="accounts-avatar"
                      @error="onAvatarError(user.id)"
                    />
                    <div v-else class="accounts-avatar-fallback">
                      {{ (user.fullName || user.email || 'A').charAt(0).toUpperCase() }}
                    </div>
                    <p class="accounts-name">
                      {{ user.fullName }}
                      <span v-if="isGoogleAccount(user)" class="accounts-badge">{{ t('admin.accounts.googleAccountBadge') }}</span>
                      <span v-if="isSessionUser(user)" class="accounts-badge accounts-badge--session">{{ t('admin.accounts.sessionAccountBadge') }}</span>
                    </p>
                  </div>
                </td>
                <td class="accounts-col-email accounts-email">{{ user.email }}</td>
                <td class="accounts-col-status">
                  <span class="accounts-status" :class="statusTextClass(user.status)">
                    {{ statusShortLabels[user.status] }}
                  </span>
                </td>
                <td class="accounts-col-login accounts-login">{{ formatDate(user.lastLoginAt) }}</td>
                <td class="accounts-col-actions">
                  <div class="accounts-row-actions">
                    <button
                      v-if="activeTab === 'customers'"
                      type="button"
                      class="accounts-promote-btn"
                      @click="openPromoteModal(user)"
                    >
                      {{ menuLabels.promote }}
                    </button>
                    <button
                      v-if="activeTab === 'admins' && !isSessionUser(user)"
                      type="button"
                      class="accounts-demote-btn"
                      @click="openDemoteModal(user)"
                    >
                      {{ menuLabels.demote }}
                    </button>
                    <AccountsRowActions
                      :user="user"
                      layout="desktop"
                      :open="openMenuUserId === user.id"
                      :show-promote="false"
                      :show-demote="activeTab === 'admins' && !isSessionUser(user)"
                      :actions-label="menuLabels.actions"
                      :promote-label="menuLabels.promote"
                      :demote-label="menuLabels.demote"
                      :password-label="menuLabels.password"
                      :edit-label="menuLabels.edit"
                      :delete-label="menuLabels.delete"
                      :lock-account-label="menuLabels.lockAccount"
                      :activate-account-label="menuLabels.activateAccount"
                      :show-password="!isGoogleAccount(user)"
                      :show-delete="!isSessionUser(user)"
                      :show-status-toggle="!isSessionUser(user)"
                      @toggle="toggleActionMenu(user.id)"
                      @action="(action, payload) => onRowAction(user, action, payload)"
                    >
                      <template #icon>
                        <MoreVertical class="h-4 w-4" />
                      </template>
                    </AccountsRowActions>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="!isLoading && filteredUsers.length" variant="body" visibility="mobile">
        <AdminShellTablePanel
          :title="t('admin.accounts.listTitle')"
          :count-text="t('admin.shared.totalCount', { count: filteredUsers.length })"
        >
          <template #below>
            <div class="admin-shell-frame__inner--pad admin-shell-frame__inner--stack admin-shell-mobile-list">
              <article v-for="user in paginatedUsers" :key="user.id" class="accounts-mobile-card">
                <div class="accounts-mobile-row">
                  <img
                    v-if="showAvatar(user)"
                    :src="avatarUrlFor(user)"
                    alt=""
                    class="accounts-avatar"
                    @error="onAvatarError(user.id)"
                  />
                  <div v-else class="accounts-avatar-fallback">
                    {{ (user.fullName || user.email || 'A').charAt(0).toUpperCase() }}
                  </div>
                  <div class="accounts-mobile-info">
                    <p class="accounts-name">{{ user.fullName }}</p>
                    <p class="accounts-email">{{ user.email }}</p>
                    <div class="accounts-mobile-meta">
                      <span class="accounts-status" :class="statusTextClass(user.status)">
                        {{ statusShortLabels[user.status] }}
                      </span>
                      <span v-if="isGoogleAccount(user)" class="accounts-badge">{{ t('admin.accounts.googleAccountBadge') }}</span>
                      <span v-if="isSessionUser(user)" class="accounts-badge accounts-badge--session">{{ t('admin.accounts.sessionAccountBadge') }}</span>
                    </div>
                    <p class="accounts-mobile-login">
                      {{ t('admin.accounts.columns.lastLoginAt') }}: {{ formatDate(user.lastLoginAt) }}
                    </p>
                    <div v-if="activeTab === 'customers'" class="accounts-mobile-promote">
                      <button type="button" class="accounts-promote-btn accounts-promote-btn--full" @click="openPromoteModal(user)">
                        {{ menuLabels.promote }}
                      </button>
                    </div>
                    <div v-if="activeTab === 'admins' && !isSessionUser(user)" class="accounts-mobile-promote">
                      <button type="button" class="accounts-demote-btn accounts-demote-btn--full" @click="openDemoteModal(user)">
                        {{ menuLabels.demote }}
                      </button>
                    </div>
                  </div>
                  <AccountsRowActions
                    :user="user"
                    layout="mobile"
                    :open="openMenuUserId === user.id"
                    :show-promote="false"
                    :show-demote="activeTab === 'admins' && !isSessionUser(user)"
                    :actions-label="menuLabels.actions"
                    :promote-label="menuLabels.promote"
                    :demote-label="menuLabels.demote"
                    :password-label="menuLabels.password"
                    :edit-label="menuLabels.edit"
                    :delete-label="menuLabels.delete"
                    :lock-account-label="menuLabels.lockAccount"
                    :activate-account-label="menuLabels.activateAccount"
                    :show-password="!isGoogleAccount(user)"
                    :show-delete="!isSessionUser(user)"
                    :show-status-toggle="!isSessionUser(user)"
                    @toggle="toggleActionMenu(user.id)"
                    @action="(action, payload) => onRowAction(user, action, payload)"
                  >
                    <template #icon>
                      <MoreVertical class="h-4 w-4" />
                    </template>
                  </AccountsRowActions>
                </div>
              </article>
            </div>
          </template>
        </AdminShellTablePanel>
      </AdminShellFrame>

      <AdminShellFrame v-if="filteredUsers.length" variant="footer">
        <Pagination
          :page="currentPage"
          :total-pages="totalPages"
          :visible-count="paginatedUsers.length"
          :total-count="filteredUsers.length"
          :label="t('admin.accounts.paginationLabel')"
          @prev="currentPage--"
          @next="currentPage++"
        />
      </AdminShellFrame>
    </AdminNestedShell>

    <BaseModal :open="showUserModal" :title="editingUser ? t('admin.accounts.modals.editUser') : t('admin.accounts.modals.createUser')" @close="closeUserModal">
      <form class="accounts-user-form grid gap-4" @submit.prevent="saveUser">
        <label class="accounts-field">
          <span class="accounts-field__label">{{ t('admin.accounts.modals.fullName') }}</span>
          <input
            v-model.trim="form.fullName"
            required
            :class="lockedFieldClass(false)"
          />
        </label>
        <label class="accounts-field">
          <span class="accounts-field__label">{{ t('admin.accounts.modals.email') }}</span>
          <input
            v-model.trim="form.email"
            required
            type="email"
            :disabled="!editFormAccess.email"
            :class="lockedFieldClass(!editFormAccess.email)"
          />
          <p v-if="!editFormAccess.email" class="accounts-field__hint">{{ fieldLockHint('email') }}</p>
        </label>
        <label class="accounts-field">
          <span class="accounts-field__label">{{ t('admin.accounts.modals.phone') }}</span>
          <input
            v-model.trim="form.phone"
            :class="lockedFieldClass(false)"
          />
        </label>
        <div class="accounts-field">
          <span class="accounts-field__label">{{ t('admin.accounts.modals.avatarUpload') }}</span>
          <div class="flex items-center gap-4 rounded-2xl border border-slate-200 bg-slate-50/60 p-4">
            <div class="grid h-16 w-16 shrink-0 place-items-center overflow-hidden rounded-full border border-slate-200 bg-white">
              <img v-if="avatarPreviewUrl" :src="avatarPreviewUrl" :alt="form.fullName || 'Avatar'" class="h-full w-full object-cover" />
              <UserRound v-else class="h-7 w-7 text-avocado-700" />
            </div>
            <div class="min-w-0 flex-1">
              <p class="text-xs font-semibold text-slate-500">{{ t('admin.accounts.modals.avatarUploadHint') }}</p>
              <label class="mt-2 inline-flex cursor-pointer items-center gap-2 rounded-xl border border-avocado-200 bg-white px-3 py-2 text-xs font-black text-avocado-800 hover:bg-avocado-50">
                <Camera class="h-4 w-4" />
                {{ isUploadingAvatar ? t('admin.profile.uploadingAvatar') : t('admin.profile.avatar.chooseLabel') }}
                <input class="sr-only" type="file" accept="image/*" :disabled="isUploadingAvatar" @change="handleAvatarUpload" />
              </label>
            </div>
          </div>
        </div>
        <label v-if="activeTab === 'admins'" class="accounts-field">
          <span class="accounts-field__label">{{ t('admin.accounts.profileLabel') }}</span>
          <select
            v-model="form.adminProfile"
            :disabled="!editFormAccess.adminProfile"
            :class="lockedFieldClass(!editFormAccess.adminProfile)"
          >
            <option v-for="profile in adminProfileOptions" :key="profile" :value="profile">{{ t(`admin.roles.${profile}`) }}</option>
          </select>
          <p v-if="!editFormAccess.adminProfile" class="accounts-field__hint">{{ fieldLockHint('adminProfile') }}</p>
        </label>
        <label class="accounts-field">
          <span class="accounts-field__label">{{ t('admin.accounts.modals.status') }}</span>
          <select
            v-model="form.status"
            :disabled="!editFormAccess.status"
            :class="lockedFieldClass(!editFormAccess.status)"
          >
            <option v-for="status in statusOptions" :key="status" :value="status">{{ statusLabels[status] }}</option>
          </select>
          <p v-if="!editFormAccess.status" class="accounts-field__hint">{{ fieldLockHint('status') }}</p>
        </label>
        <label v-if="editFormAccess.password" class="accounts-field">
          <span class="accounts-field__label">{{ t('admin.accounts.modals.password') }}</span>
          <input
            v-model="form.password"
            required
            :minlength="MIN_PASSWORD_LENGTH"
            type="password"
            :class="lockedFieldClass(false)"
          />
        </label>
        <div class="flex justify-end gap-3 pt-2">
          <button type="button" class="rounded-xl border border-slate-200 px-4 py-2 text-sm font-bold text-slate-600" @click="closeUserModal">{{ t('admin.accounts.actions.cancel') }}</button>
          <button class="rounded-xl bg-avocado-800 px-4 py-2 text-sm font-black text-white" :disabled="isUploadingAvatar">{{ t('admin.accounts.actions.save') }}</button>
        </div>
      </form>
    </BaseModal>

    <BaseModal :open="showPasswordModal" :title="t('admin.accounts.modals.changePassword')" @close="showPasswordModal = false">
      <form class="grid gap-4" @submit.prevent="savePassword">
        <p class="text-sm text-slate-600">{{ t('admin.accounts.modals.changePasswordHint', { email: editingUser?.email }) }}</p>
        <label class="grid gap-2 text-sm font-bold text-slate-700">{{ t('admin.accounts.modals.newPassword') }}
          <input v-model="passwordForm.password" required :minlength="MIN_PASSWORD_LENGTH" type="password" class="rounded-2xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" />
        </label>
        <div class="flex justify-end gap-3 pt-2">
          <button type="button" class="rounded-xl border border-slate-200 px-4 py-2 text-sm font-bold text-slate-600" @click="showPasswordModal = false">{{ t('admin.accounts.actions.cancel') }}</button>
          <button class="inline-flex items-center gap-2 rounded-xl bg-avocado-800 px-4 py-2 text-sm font-black text-white">
            <KeyRound class="h-4 w-4" />
            {{ t('admin.accounts.actions.changePassword') }}
          </button>
        </div>
      </form>
    </BaseModal>

    <ConfirmModal
      :open="Boolean(pendingStatusChange)"
      :title="t('admin.accounts.confirmStatus.title')"
      :message="pendingStatusChange ? t('admin.accounts.confirmStatus.message', { name: pendingStatusChange.user.fullName, status: statusLabels[pendingStatusChange.status] }) : ''"
      :confirm-label="t('admin.accounts.confirmStatus.confirm')"
      @close="pendingStatusChange = null"
      @confirm="confirmStatusChange"
    />

    <ConfirmModal
      :open="Boolean(pendingDelete)"
      :title="t('admin.accounts.confirmDelete.title')"
      :message="pendingDelete ? t('admin.accounts.confirmDelete.message', { name: pendingDelete.fullName, email: pendingDelete.email }) : ''"
      :confirm-label="t('admin.accounts.confirmDelete.confirm')"
      @close="pendingDelete = null"
      @confirm="confirmDelete"
    />

    <BaseModal
      :open="Boolean(pendingPromote)"
      :title="t('admin.accounts.promote.title')"
      @close="pendingPromote = null"
    >
      <div class="grid gap-4">
        <p class="text-sm leading-6 text-slate-600">
          {{ t('admin.accounts.promote.message', { name: pendingPromote?.fullName, email: pendingPromote?.email }) }}
        </p>
        <p class="rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm font-semibold text-amber-800">
          {{ t('admin.accounts.promote.reloginHint') }}
        </p>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ t('admin.accounts.profileLabel') }}
          <select v-model="promoteProfile" class="rounded-2xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100">
            <option v-for="profile in adminProfileOptions" :key="profile" :value="profile">{{ t(`admin.roles.${profile}`) }}</option>
          </select>
        </label>
        <div class="flex justify-end gap-3 pt-2">
          <button type="button" class="rounded-xl border border-slate-200 px-4 py-2 text-sm font-bold text-slate-600" @click="pendingPromote = null">
            {{ t('admin.accounts.actions.cancel') }}
          </button>
          <button type="button" class="inline-flex items-center gap-2 rounded-xl bg-indigo-700 px-4 py-2 text-sm font-black text-white" @click="confirmPromote">
            <UserCog class="h-4 w-4" />
            {{ t('admin.accounts.promote.confirm') }}
          </button>
        </div>
      </div>
    </BaseModal>

    <BaseModal
      :open="Boolean(pendingDemote)"
      :title="t('admin.accounts.demote.title')"
      @close="pendingDemote = null"
    >
      <div class="grid gap-4">
        <p class="text-sm leading-6 text-slate-600">
          {{ t('admin.accounts.demote.message', { name: pendingDemote?.fullName, email: pendingDemote?.email }) }}
        </p>
        <p class="rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm font-semibold text-amber-800">
          {{ t('admin.accounts.demote.reloginHint') }}
        </p>
        <div class="flex justify-end gap-3 pt-2">
          <button type="button" class="rounded-xl border border-slate-200 px-4 py-2 text-sm font-bold text-slate-600" @click="pendingDemote = null">
            {{ t('admin.accounts.actions.cancel') }}
          </button>
          <button type="button" class="inline-flex items-center gap-2 rounded-xl bg-amber-700 px-4 py-2 text-sm font-black text-white" @click="confirmDemote">
            <UserRound class="h-4 w-4" />
            {{ t('admin.accounts.demote.confirm') }}
          </button>
        </div>
      </div>
    </BaseModal>
  </AdminListPage>
</template>
