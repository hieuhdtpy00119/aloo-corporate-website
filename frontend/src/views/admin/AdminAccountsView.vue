<script setup>
import { computed, onBeforeUnmount, onMounted, reactive, ref, watch } from 'vue'
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
const accountTypeFilter = ref(t('admin.accounts.allProfiles'))
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
const actionReason = ref('')
const deactivationReason = ref('')
const demoteTransferAdminId = ref('')
const transferAdminOptions = ref([])
const transferAdminSearch = ref('')
const isLoadingTransferAdmins = ref(false)
const adminEmailWhitelist = ref({ enabled: false, emails: [] })
const isUploadingAvatar = ref(false)
const isSavingUser = ref(false)
const isSavingPassword = ref(false)
const isPerformingAction = ref(false)

const accountTypes = [
  { key: 'admins', labelKey: 'admin.accounts.tabAdmins' },
  { key: 'customers', labelKey: 'admin.accounts.tabCustomers' },
]
const adminProfileOptions = ['FULL', 'CONTENT', 'STORES', 'CRM', 'SYSTEM']
const statusOptions = ['INVITED', 'ACTIVE', 'SUSPENDED', 'LOCKED', 'DEACTIVATED']
const statusLabels = computed(() => ({
  INVITED: t('admin.accounts.status.INVITED'),
  ACTIVE: t('admin.accounts.status.ACTIVE'),
  SUSPENDED: t('admin.accounts.status.SUSPENDED'),
  LOCKED: t('admin.accounts.status.LOCKED'),
  DEACTIVATED: t('admin.accounts.status.DEACTIVATED'),
}))
const statusShortLabels = computed(() => ({
  INVITED: t('admin.accounts.statusShort.INVITED'),
  ACTIVE: t('admin.accounts.statusShort.ACTIVE'),
  SUSPENDED: t('admin.accounts.statusShort.SUSPENDED'),
  LOCKED: t('admin.accounts.statusShort.LOCKED'),
  DEACTIVATED: t('admin.accounts.statusShort.DEACTIVATED'),
}))
const statusFilters = computed(() => [
  t('admin.accounts.allStatuses'),
  ...statusOptions.map((status) => statusLabels.value[status]),
])
const accountTypeFilterOptions = computed(() => (
  activeTab.value === 'admins'
    ? [t('admin.accounts.allProfiles'), ...adminProfileOptions.map((profile) => t(`admin.roles.${profile}`))]
    : [t('admin.accounts.allProviders'), t('admin.accounts.localAccountBadge'), t('admin.accounts.googleAccountBadge')]
))
const accountTypeFilterLabel = computed(() => (
  activeTab.value === 'admins' ? t('admin.accounts.profileLabel') : t('admin.accounts.authProviderLabel')
))
const resolveStatusFilter = (label) => {
  if (!label || label === t('admin.accounts.allStatuses')) return 'ALL'
  return statusOptions.find((status) => statusLabels.value[status] === label) || 'ALL'
}
const resolveAccountTypeFilter = () => {
  if (activeTab.value === 'admins') {
    const adminProfile = adminProfileOptions.find((profile) => t(`admin.roles.${profile}`) === accountTypeFilter.value)
    return adminProfile ? { adminProfile } : {}
  }
  if (accountTypeFilter.value === t('admin.accounts.localAccountBadge')) return { authProvider: 'LOCAL' }
  if (accountTypeFilter.value === t('admin.accounts.googleAccountBadge')) return { authProvider: 'GOOGLE' }
  return {}
}

const form = reactive({
  email: '',
  fullName: '',
  phone: '',
  avatarUrl: '',
  status: 'ACTIVE',
  adminProfile: 'FULL',
  password: '',
  changeReason: '',
})
const passwordForm = reactive({ password: '' })

const adminTotal = ref(0)
const customerTotal = ref(0)
const serverTotalPages = ref(1)
const currentUsers = computed(() => (activeTab.value === 'admins' ? adminUsers.value : customerUsers.value))
const filteredUsers = computed(() => currentUsers.value)
const totalElements = computed(() => (activeTab.value === 'admins' ? adminTotal.value : customerTotal.value))
const totalPages = computed(() => Math.max(1, serverTotalPages.value))
const paginatedUsers = computed(() => filteredUsers.value)
const accountTabItems = computed(() =>
  accountTypes.map((type) => ({
    key: type.key,
    label: tabLabel(type),
  })),
)
const avatarPreviewUrl = computed(() => resolveBackendAssetUrl(form.avatarUrl || ''))

const statusTextClass = (status) => ({
  'accounts-status--inactive': ['INVITED', 'SUSPENDED', 'DEACTIVATED'].includes(status),
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
    return t(`admin.accounts.roleShort.${user.adminProfile || 'FULL'}`)
  }
  return t('admin.accounts.customerRoleLabel')
}

const roleTitle = (user) => {
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
    status: isCreate,
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

let searchTimer = null
let transferSearchTimer = null
let accountRequestId = 0

const loadAccounts = async () => {
  const requestId = ++accountRequestId
  const requestedTab = activeTab.value
  isLoading.value = true
  errorMessage.value = ''
  const sharedParams = {
    q: searchQuery.value.trim() || undefined,
    status: resolveStatusFilter(statusFilter.value),
    page: currentPage.value - 1,
    size: pageSize,
  }
  const typeParams = resolveAccountTypeFilter()
  const countParams = { ...sharedParams, page: 0, size: 1 }
  const [admins, customers, whitelist] = await Promise.allSettled([
    accountService.search({
      ...(requestedTab === 'admins' ? sharedParams : countParams),
      role: 'ADMIN',
      ...(requestedTab === 'admins' ? typeParams : {}),
    }),
    accountService.search({
      ...(requestedTab === 'customers' ? sharedParams : countParams),
      role: 'USER',
      ...(requestedTab === 'customers' ? typeParams : {}),
    }),
    accountService.getAdminEmailWhitelist(),
  ])

  if (requestId !== accountRequestId) return

  if (admins.status === 'fulfilled') {
    if (requestedTab === 'admins') adminUsers.value = admins.value.data?.items || []
    adminTotal.value = admins.value.data?.totalElements || 0
    if (requestedTab === 'admins') serverTotalPages.value = admins.value.data?.totalPages || 1
  }
  if (customers.status === 'fulfilled') {
    if (requestedTab === 'customers') customerUsers.value = customers.value.data?.items || []
    customerTotal.value = customers.value.data?.totalElements || 0
    if (requestedTab === 'customers') serverTotalPages.value = customers.value.data?.totalPages || 1
  }
  if (whitelist.status === 'fulfilled') {
    adminEmailWhitelist.value = whitelist.value.data || { enabled: false, emails: [] }
  }

  const activeResult = requestedTab === 'admins' ? admins : customers
  if (activeResult.status === 'rejected') {
    errorMessage.value = activeResult.reason?.response?.data?.message || t('admin.accounts.loadError')
  }
  isLoading.value = false
}

watch(activeTab, () => {
  accountTypeFilter.value = activeTab.value === 'admins'
    ? t('admin.accounts.allProfiles')
    : t('admin.accounts.allProviders')
})

watch([activeTab, searchQuery, statusFilter, accountTypeFilter], () => {
  currentPage.value = 1
  clearTimeout(searchTimer)
  searchTimer = window.setTimeout(loadAccounts, 300)
})

watch(currentPage, loadAccounts)

watch(totalPages, (value) => {
  currentPage.value = Math.min(currentPage.value, value)
})

const resetForm = () => {
  Object.assign(form, {
    email: '',
    fullName: '',
    phone: '',
    avatarUrl: '',
    status: 'ACTIVE',
    adminProfile: 'FULL',
    password: '',
    changeReason: '',
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
    changeReason: '',
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
    changeReason: form.changeReason.trim() || null,
    expectedVersion: user?.version ?? null,
  }
}

const saveUser = async () => {
  if (isSavingUser.value) return
  if (!editingUser.value) {
    const errorKey = getNewPasswordErrorKey(form.password)
    if (errorKey) {
      toast.error(t(errorKey))
      return
    }
  }

  const adminProfileChanged = Boolean(
    editingUser.value
      && activeTab.value === 'admins'
      && form.adminProfile !== (editingUser.value.adminProfile || 'FULL'),
  )
  if (adminProfileChanged && !form.changeReason.trim()) {
    toast.error(t('admin.accounts.reasonRequired'))
    return
  }

  if (activeTab.value === 'admins' && editFormAccess.value.email && !isEmailWhitelisted(form.email)) {
    toast.error(t('admin.accounts.whitelistBlocked'))
    return
  }

  isSavingUser.value = true
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
  } finally {
    isSavingUser.value = false
  }
}

const updateStatus = async (user, status, reason) => {
  try {
    const payload = { status, reason, expectedVersion: user.version }
    activeTab.value === 'admins'
      ? await accountService.updateAdminStatus(user.id, payload)
      : await accountService.updateCustomerStatus(user.id, payload)
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
  pendingStatusChange.value = { user, status: nextStatus, reason: '' }
}

const confirmStatusChange = async () => {
  if (!pendingStatusChange.value) return
  const { user, status, reason } = pendingStatusChange.value
  pendingStatusChange.value = null
  await updateStatus(user, status, reason || t('admin.accounts.defaultActionReason'))
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
  if (isSavingPassword.value) return
  const errorKey = getNewPasswordErrorKey(passwordForm.password)
  if (errorKey) {
    toast.error(t(errorKey))
    return
  }

  isSavingPassword.value = true
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
  } finally {
    isSavingPassword.value = false
  }
}

const confirmDelete = async () => {
  if (isPerformingAction.value) return
  isPerformingAction.value = true
  try {
    const user = pendingDelete.value
    const payload = {
      status: 'DEACTIVATED',
      reason: deactivationReason.value || t('admin.accounts.defaultActionReason'),
      expectedVersion: user.version,
    }
    activeTab.value === 'admins'
      ? await accountService.updateAdminStatus(user.id, payload)
      : await accountService.updateCustomerStatus(user.id, payload)
    toast.success(t('admin.accounts.deactivateSuccess'))
    await loadAccounts()
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.accounts.deleteError'))
  } finally {
    pendingDelete.value = null
    deactivationReason.value = ''
    isPerformingAction.value = false
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
  actionReason.value = ''
}

const confirmPromote = async () => {
  if (!pendingPromote.value || isPerformingAction.value) return
  if (!actionReason.value.trim()) {
    toast.error(t('admin.accounts.reasonRequired'))
    return
  }

  isPerformingAction.value = true
  try {
    await accountService.promoteCustomer(pendingPromote.value.id, {
      adminProfile: promoteProfile.value,
      reason: actionReason.value,
      expectedVersion: pendingPromote.value.version,
    })
    toast.success(t('admin.accounts.promoteSuccess'))
    pendingPromote.value = null
    await loadAccounts()
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.accounts.promoteError'))
  } finally {
    isPerformingAction.value = false
  }
}

const loadTransferAdminCandidates = async () => {
  if (!pendingDemote.value) return
  isLoadingTransferAdmins.value = true
  try {
    const { data } = await accountService.search({
      role: 'ADMIN',
      status: 'ACTIVE',
      q: transferAdminSearch.value.trim() || undefined,
      page: 0,
      size: 20,
    })
    transferAdminOptions.value = (data?.items || []).filter((item) => item.id !== pendingDemote.value?.id)
  } catch {
    transferAdminOptions.value = []
  } finally {
    isLoadingTransferAdmins.value = false
  }
}

watch(transferAdminSearch, () => {
  if (!pendingDemote.value) return
  clearTimeout(transferSearchTimer)
  transferSearchTimer = window.setTimeout(loadTransferAdminCandidates, 250)
})

const openDemoteModal = async (user) => {
  if (isSessionUser(user)) {
    toast.error(t('admin.accounts.selfDemoteBlocked'))
    return
  }
  pendingDemote.value = user
  actionReason.value = ''
  demoteTransferAdminId.value = ''
  transferAdminSearch.value = ''
  transferAdminOptions.value = []
  await loadTransferAdminCandidates()
}

const confirmDemote = async () => {
  if (!pendingDemote.value || isPerformingAction.value) return
  if (!actionReason.value.trim()) {
    toast.error(t('admin.accounts.reasonRequired'))
    return
  }
  isPerformingAction.value = true
  try {
    await accountService.demoteAdmin(pendingDemote.value.id, {
      reason: actionReason.value,
      transferToAdminId: demoteTransferAdminId.value ? Number(demoteTransferAdminId.value) : null,
      expectedVersion: pendingDemote.value.version,
    })
    toast.success(t('admin.accounts.demoteSuccess'))
    pendingDemote.value = null
    await loadAccounts()
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.accounts.demoteError'))
  } finally {
    isPerformingAction.value = false
  }
}

const tabLabel = (type) => {
  const count = type.key === 'admins' ? adminTotal.value : customerTotal.value
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
  else if (action === 'delete') {
    pendingDelete.value = user
    deactivationReason.value = ''
  }
  else if (action === 'status') requestStatusChange(user, payload)
}

const onRowAction = (user, action, payload) => {
  runMenuAction(action, user, payload)
}

onMounted(loadAccounts)
onBeforeUnmount(() => {
  clearTimeout(searchTimer)
  clearTimeout(transferSearchTimer)
})
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
          v-model:extra-filter="accountTypeFilter"
          :extra-options="accountTypeFilterOptions"
          :extra-label="accountTypeFilterLabel"
        />
      </AdminShellFrame>

      <AdminShellFrame
        v-if="errorMessage"
        as="div"
        variant="alert"
        class="admin-list-alert"
      >
        <span>{{ errorMessage }}</span>
        <button type="button" class="ml-3 font-black underline" @click="loadAccounts">
          {{ t('admin.accounts.retry') }}
        </button>
      </AdminShellFrame>

      <AdminShellFrame v-else-if="isLoading" variant="body" inner="pad">
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
          :count-text="t('admin.shared.totalCount', { count: totalElements })"
        >
          <table class="admin-shell-table accounts-table">
            <colgroup>
              <col class="accounts-col-name" />
              <col class="accounts-col-email" />
              <col class="accounts-col-role" />
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
                <th class="accounts-col-role">{{ t('admin.accounts.columns.role') }}</th>
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
                    <div class="accounts-identity">
                      <p class="accounts-name" :title="user.fullName">{{ user.fullName }}</p>
                      <div v-if="isGoogleAccount(user) || isSessionUser(user)" class="accounts-identity__badges">
                        <span v-if="isGoogleAccount(user)" class="accounts-badge">{{ t('admin.accounts.googleAccountBadge') }}</span>
                        <span v-if="isSessionUser(user)" class="accounts-badge accounts-badge--session">{{ t('admin.accounts.sessionAccountBadge') }}</span>
                      </div>
                    </div>
                  </div>
                </td>
                <td class="accounts-col-email accounts-email">{{ user.email }}</td>
                <td class="accounts-col-role"><span class="accounts-badge accounts-role-badge" :title="roleTitle(user)">{{ roleLabel(user) }}</span></td>
                <td class="accounts-col-status">
                  <span class="accounts-status" :class="statusTextClass(user.status)">
                    {{ statusShortLabels[user.status] }}
                  </span>
                </td>
                <td class="accounts-col-login accounts-login">{{ formatDate(user.lastLoginAt) }}</td>
                <td class="accounts-col-actions">
                  <div class="accounts-row-actions">
                    <button
                      v-if="activeTab === 'customers' && user.status === 'ACTIVE'"
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
                      :show-delete="!isSessionUser(user) && user.status !== 'DEACTIVATED'"
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

      <AdminShellFrame v-if="!errorMessage && !isLoading && filteredUsers.length" variant="body" visibility="mobile">
        <AdminShellTablePanel
          :title="t('admin.accounts.listTitle')"
          :count-text="t('admin.shared.totalCount', { count: totalElements })"
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
                      <span class="accounts-badge accounts-role-badge">{{ roleLabel(user) }}</span>
                      <span class="accounts-status" :class="statusTextClass(user.status)">
                        {{ statusShortLabels[user.status] }}
                      </span>
                      <span v-if="isGoogleAccount(user)" class="accounts-badge">{{ t('admin.accounts.googleAccountBadge') }}</span>
                      <span v-if="isSessionUser(user)" class="accounts-badge accounts-badge--session">{{ t('admin.accounts.sessionAccountBadge') }}</span>
                    </div>
                    <p class="accounts-mobile-login">
                      {{ t('admin.accounts.columns.lastLoginAt') }}: {{ formatDate(user.lastLoginAt) }}
                    </p>
                    <div v-if="activeTab === 'customers' && user.status === 'ACTIVE'" class="accounts-mobile-promote">
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
                    :show-delete="!isSessionUser(user) && user.status !== 'DEACTIVATED'"
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

      <AdminShellFrame v-if="!errorMessage && filteredUsers.length" variant="footer">
        <Pagination
          :page="currentPage"
          :total-pages="totalPages"
          :visible-count="paginatedUsers.length"
          :total-count="totalElements"
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
        <label
          v-if="editingUser && activeTab === 'admins' && form.adminProfile !== (editingUser.adminProfile || 'FULL')"
          class="accounts-field"
        >
          <span class="accounts-field__label">{{ t('admin.accounts.reasonLabel') }}</span>
          <textarea v-model.trim="form.changeReason" required maxlength="500" rows="3" :class="lockedFieldClass(false)" />
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
          <button class="rounded-xl bg-avocado-800 px-4 py-2 text-sm font-black text-white disabled:cursor-not-allowed disabled:opacity-60" :disabled="isUploadingAvatar || isSavingUser">{{ t('admin.accounts.actions.save') }}</button>
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
          <button class="inline-flex items-center gap-2 rounded-xl bg-avocado-800 px-4 py-2 text-sm font-black text-white disabled:cursor-not-allowed disabled:opacity-60" :disabled="isSavingPassword">
            <KeyRound class="h-4 w-4" />
            {{ t('admin.accounts.actions.changePassword') }}
          </button>
        </div>
      </form>
    </BaseModal>

    <BaseModal :open="Boolean(pendingStatusChange)" :title="t('admin.accounts.confirmStatus.title')" @close="pendingStatusChange = null">
      <div class="grid gap-4">
        <p class="text-sm text-slate-600">
          {{ pendingStatusChange ? t('admin.accounts.confirmStatus.message', { name: pendingStatusChange.user.fullName, status: statusLabels[pendingStatusChange.status] }) : '' }}
        </p>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ t('admin.accounts.reasonLabel') }}
          <textarea v-if="pendingStatusChange" v-model.trim="pendingStatusChange.reason" required maxlength="500" rows="3" class="rounded-2xl border border-slate-200 px-4 py-3" />
        </label>
        <div class="flex justify-end gap-3">
          <button type="button" class="rounded-xl border border-slate-200 px-4 py-2 font-bold" @click="pendingStatusChange = null">{{ t('admin.accounts.actions.cancel') }}</button>
          <button type="button" class="rounded-xl bg-avocado-800 px-4 py-2 font-black text-white" :disabled="!pendingStatusChange?.reason?.trim()" @click="confirmStatusChange">{{ t('admin.accounts.confirmStatus.confirm') }}</button>
        </div>
      </div>
    </BaseModal>

    <BaseModal :open="Boolean(pendingDelete)" :title="t('admin.accounts.confirmDelete.title')" @close="pendingDelete = null">
      <div class="grid gap-4">
        <p class="text-sm text-slate-600">{{ pendingDelete ? t('admin.accounts.confirmDelete.message', { name: pendingDelete.fullName, email: pendingDelete.email }) : '' }}</p>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ t('admin.accounts.reasonLabel') }}
          <textarea v-model.trim="deactivationReason" required maxlength="500" rows="3" class="rounded-2xl border border-slate-200 px-4 py-3" />
        </label>
        <div class="flex justify-end gap-3">
          <button type="button" class="rounded-xl border border-slate-200 px-4 py-2 font-bold" @click="pendingDelete = null">{{ t('admin.accounts.actions.cancel') }}</button>
          <button type="button" class="rounded-xl bg-red-700 px-4 py-2 font-black text-white disabled:cursor-not-allowed disabled:opacity-60" :disabled="!deactivationReason.trim() || isPerformingAction" @click="confirmDelete">{{ t('admin.accounts.confirmDelete.confirm') }}</button>
        </div>
      </div>
    </BaseModal>

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
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ t('admin.accounts.reasonLabel') }}
          <textarea v-model.trim="actionReason" required maxlength="500" rows="3" class="rounded-2xl border border-slate-200 px-4 py-3" />
        </label>
        <div class="flex justify-end gap-3 pt-2">
          <button type="button" class="rounded-xl border border-slate-200 px-4 py-2 text-sm font-bold text-slate-600" @click="pendingPromote = null">
            {{ t('admin.accounts.actions.cancel') }}
          </button>
          <button type="button" class="inline-flex items-center gap-2 rounded-xl bg-indigo-700 px-4 py-2 text-sm font-black text-white disabled:cursor-not-allowed disabled:opacity-60" :disabled="!actionReason.trim() || isPerformingAction" @click="confirmPromote">
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
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ t('admin.accounts.reasonLabel') }}
          <textarea v-model.trim="actionReason" required maxlength="500" rows="3" class="rounded-2xl border border-slate-200 px-4 py-3" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          {{ t('admin.accounts.transferAdminLabel') }}
          <input
            v-model.trim="transferAdminSearch"
            type="search"
            :placeholder="t('admin.accounts.transferAdminSearch')"
            class="rounded-2xl border border-slate-200 px-4 py-3"
          />
          <select v-model="demoteTransferAdminId" class="rounded-2xl border border-slate-200 px-4 py-3">
            <option value="">{{ isLoadingTransferAdmins ? t('admin.shared.loading') : t('admin.accounts.transferAdminOptional') }}</option>
            <option v-for="admin in transferAdminOptions" :key="admin.id" :value="admin.id">{{ admin.fullName }} — {{ admin.email }}</option>
          </select>
          <span class="text-xs font-medium text-slate-500">{{ t('admin.accounts.transferAdminLimitHint') }}</span>
        </label>
        <div class="flex justify-end gap-3 pt-2">
          <button type="button" class="rounded-xl border border-slate-200 px-4 py-2 text-sm font-bold text-slate-600" @click="pendingDemote = null">
            {{ t('admin.accounts.actions.cancel') }}
          </button>
          <button type="button" class="inline-flex items-center gap-2 rounded-xl bg-amber-700 px-4 py-2 text-sm font-black text-white disabled:cursor-not-allowed disabled:opacity-60" :disabled="!actionReason.trim() || isPerformingAction" @click="confirmDemote">
            <UserRound class="h-4 w-4" />
            {{ t('admin.accounts.demote.confirm') }}
          </button>
        </div>
      </div>
    </BaseModal>
  </AdminListPage>
</template>
