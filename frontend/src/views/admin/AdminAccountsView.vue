<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { KeyRound, Plus, Search, ShieldCheck, UserRound } from 'lucide-vue-next'
import BaseModal from '../../components/admin/BaseModal.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import ConfirmModal from '../../components/admin/ConfirmModal.vue'
import EmptyState from '../../components/admin/EmptyState.vue'
import { accountService } from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'
import { MIN_PASSWORD_LENGTH, getNewPasswordErrorKey } from '../../utils/passwordPolicy'

const toast = useToastStore()
const { t } = useI18n()
const activeTab = ref('admins')
const searchQuery = ref('')
const statusFilter = ref('ALL')
const isLoading = ref(false)
const errorMessage = ref('')
const adminUsers = ref([])
const customerUsers = ref([])
const showUserModal = ref(false)
const showPasswordModal = ref(false)
const editingUser = ref(null)
const pendingDelete = ref(null)
const pendingStatusChange = ref(null)

const accountTypes = [
  { key: 'admins', labelKey: 'admin.accounts.tabAdmins', icon: ShieldCheck },
  { key: 'customers', labelKey: 'admin.accounts.tabCustomers', icon: UserRound },
]
const adminProfileOptions = ['FULL', 'CONTENT', 'STORES', 'CRM', 'SYSTEM']
const statusOptions = ['ACTIVE', 'INACTIVE', 'LOCKED']
const statusLabels = computed(() => ({
  ACTIVE: t('admin.accounts.status.ACTIVE'),
  INACTIVE: t('admin.accounts.status.INACTIVE'),
  LOCKED: t('admin.accounts.status.LOCKED'),
}))

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

const currentUsers = computed(() => activeTab.value === 'admins' ? adminUsers.value : customerUsers.value)
const filteredUsers = computed(() => {
  const keyword = searchQuery.value.trim().toLowerCase()
  return currentUsers.value.filter((user) => {
    const matchesKeyword = !keyword || [user.email, user.fullName, user.phone, user.role]
      .filter(Boolean)
      .some((value) => String(value).toLowerCase().includes(keyword))
    const matchesStatus = statusFilter.value === 'ALL' || user.status === statusFilter.value
    return matchesKeyword && matchesStatus
  })
})
const activeTitle = computed(() => (
  activeTab.value === 'admins' ? t('admin.accounts.adminType') : t('admin.accounts.customerType')
))

const statusClass = (status) => ({
  'border-green-200 bg-green-50 text-green-700': status === 'ACTIVE',
  'border-slate-200 bg-slate-50 text-slate-600': status === 'INACTIVE',
  'border-red-200 bg-red-50 text-red-700': status === 'LOCKED',
})

const formatDate = (value) => value ? String(value).replace('T', ' ').slice(0, 16) : '-'

const loadAccounts = async () => {
  isLoading.value = true
  errorMessage.value = ''
  try {
    const [admins, customers] = await Promise.all([
      accountService.listAdmins(),
      accountService.listCustomers(),
    ])
    adminUsers.value = Array.isArray(admins.data) ? admins.data : []
    customerUsers.value = Array.isArray(customers.data) ? customers.data : []
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

const buildPayload = () => ({
  email: form.email.trim(),
  fullName: form.fullName.trim(),
  phone: form.phone.trim(),
  avatarUrl: form.avatarUrl.trim(),
  status: form.status,
  adminProfile: activeTab.value === 'admins' ? form.adminProfile : null,
  password: form.password || null,
})

const saveUser = async () => {
  if (!editingUser.value) {
    const errorKey = getNewPasswordErrorKey(form.password)
    if (errorKey) {
      toast.error(t(errorKey))
      return
    }
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
  const nextStatus = event.target.value
  if (nextStatus === user.status) return
  event.target.value = user.status
  pendingStatusChange.value = { user, status: nextStatus }
}

const confirmStatusChange = async () => {
  if (!pendingStatusChange.value) return
  const { user, status } = pendingStatusChange.value
  pendingStatusChange.value = null
  await updateStatus(user, status)
}

const openPasswordModal = (user) => {
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

onMounted(loadAccounts)
</script>

<template>
  <div>
    <AdminPageHeader
      :eyebrow="t('admin.accounts.systemEyebrow')"
      :title="t('admin.accounts.title')"
      :description="t('admin.accounts.description')"
    >
      <template #actions>
        <button class="aloo-btn aloo-btn--primary inline-flex items-center gap-2" @click="openCreateModal">
          <Plus class="h-4 w-4" />
          {{ t('admin.accounts.addAccount', { type: activeTitle }) }}
        </button>
      </template>
    </AdminPageHeader>

    <section class="rounded-3xl border border-slate-200 bg-white p-4 shadow-sm">
      <div class="flex flex-col gap-4 xl:flex-row xl:items-center xl:justify-between">
        <div class="inline-flex rounded-2xl bg-slate-100 p-1">
          <button
            v-for="type in accountTypes"
            :key="type.key"
            class="inline-flex items-center gap-2 rounded-xl px-4 py-2 text-sm font-black transition"
            :class="activeTab === type.key ? 'bg-white text-avocado-900 shadow-sm' : 'text-slate-500 hover:text-avocado-800'"
            @click="activeTab = type.key"
          >
            <component :is="type.icon" class="h-4 w-4" />
            {{ t(type.labelKey) }}
          </button>
        </div>
        <div class="grid gap-3 md:grid-cols-[minmax(260px,1fr)_220px] xl:min-w-[680px]">
          <label class="relative block">
            <Search class="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
            <input v-model="searchQuery" class="h-12 w-full rounded-2xl border border-slate-200 bg-white pl-11 pr-4 text-sm font-semibold outline-none focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" :placeholder="t('admin.accounts.searchPlaceholder')" />
          </label>
          <select v-model="statusFilter" class="h-12 rounded-2xl border border-slate-200 bg-white px-4 text-sm font-bold outline-none focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100">
            <option value="ALL">{{ t('admin.accounts.allStatuses') }}</option>
            <option v-for="status in statusOptions" :key="status" :value="status">{{ statusLabels[status] }}</option>
          </select>
        </div>
      </div>
    </section>

    <p v-if="errorMessage" class="rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-sm font-bold text-red-700">{{ errorMessage }}</p>

    <section class="overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-sm">
      <div v-if="isLoading" class="grid gap-3 p-5">
        <div v-for="i in 5" :key="i" class="h-16 animate-pulse rounded-2xl bg-slate-100" />
      </div>
      <EmptyState
        v-else-if="!filteredUsers.length"
        :title="t('admin.accounts.emptyTitle')"
        :description="t('admin.accounts.emptyDescription')"
      />
      <div v-else class="overflow-x-auto">
        <table class="min-w-[1100px] w-full text-left text-sm">
          <thead class="bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
            <tr>
              <th class="px-5 py-4">{{ t('admin.accounts.columns.account') }}</th>
              <th class="px-5 py-4">{{ t('admin.accounts.columns.phone') }}</th>
              <th class="px-5 py-4">{{ t('admin.accounts.columns.role') }}</th>
              <th class="px-5 py-4">{{ t('admin.accounts.columns.status') }}</th>
              <th class="px-5 py-4">{{ t('admin.accounts.columns.createdAt') }}</th>
              <th class="px-5 py-4 text-right">{{ t('admin.accounts.columns.actions') }}</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr v-for="user in filteredUsers" :key="user.id" class="align-middle">
              <td class="px-5 py-4">
                <div class="flex min-w-0 items-center gap-3">
                  <img v-if="user.avatarUrl" :src="user.avatarUrl" :alt="user.fullName" class="h-11 w-11 rounded-full object-cover" />
                  <div v-else class="grid h-11 w-11 shrink-0 place-items-center rounded-full bg-avocado-50 text-sm font-black text-avocado-800">
                    {{ (user.fullName || user.email || 'A').charAt(0).toUpperCase() }}
                  </div>
                  <div class="min-w-0">
                    <p class="truncate font-black text-avocado-950">{{ user.fullName }}</p>
                    <p class="truncate text-xs font-semibold text-slate-500">{{ user.email }}</p>
                  </div>
                </div>
              </td>
              <td class="whitespace-nowrap px-5 py-4 font-semibold text-slate-600">{{ user.phone || '-' }}</td>
              <td class="whitespace-nowrap px-5 py-4 font-black text-slate-700">
                <span v-if="activeTab === 'admins'">{{ t(`admin.roles.${user.adminProfile || 'FULL'}`) }}</span>
                <span v-else>{{ user.role }}</span>
              </td>
              <td class="whitespace-nowrap px-5 py-4">
                <select class="rounded-full border px-3 py-2 text-xs font-black outline-none" :class="statusClass(user.status)" :value="user.status" @change="requestStatusChange(user, $event)">
                  <option v-for="status in statusOptions" :key="status" :value="status">{{ statusLabels[status] }}</option>
                </select>
              </td>
              <td class="whitespace-nowrap px-5 py-4 text-slate-600">{{ formatDate(user.createdAt) }}</td>
              <td class="px-5 py-4">
                <div class="flex justify-end gap-2">
                  <button class="rounded-xl border border-slate-200 px-3 py-2 text-xs font-bold text-slate-700 hover:bg-slate-50" @click="openPasswordModal(user)">
                    {{ t('admin.accounts.actions.password') }}
                  </button>
                  <button class="rounded-xl border border-avocado-200 px-3 py-2 text-xs font-bold text-avocado-800 hover:bg-avocado-50" @click="openEditModal(user)">
                    {{ t('admin.accounts.actions.edit') }}
                  </button>
                  <button class="rounded-xl border border-red-200 px-3 py-2 text-xs font-bold text-red-600 hover:bg-red-50" @click="pendingDelete = user">
                    {{ t('admin.accounts.actions.delete') }}
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <BaseModal :open="showUserModal" :title="editingUser ? t('admin.accounts.modals.editUser') : t('admin.accounts.modals.createUser')" @close="closeUserModal">
      <form class="grid gap-4" @submit.prevent="saveUser">
        <label class="grid gap-2 text-sm font-bold text-slate-700">{{ t('admin.accounts.modals.fullName') }}
          <input v-model.trim="form.fullName" required class="rounded-2xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">{{ t('admin.accounts.modals.email') }}
          <input v-model.trim="form.email" required type="email" class="rounded-2xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">{{ t('admin.accounts.modals.phone') }}
          <input v-model.trim="form.phone" class="rounded-2xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">{{ t('admin.accounts.modals.avatarUrl') }}
          <input v-model.trim="form.avatarUrl" class="rounded-2xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" placeholder="https://..." />
        </label>
        <label v-if="activeTab === 'admins'" class="grid gap-2 text-sm font-bold text-slate-700">{{ t('admin.accounts.profileLabel') }}
          <select v-model="form.adminProfile" class="rounded-2xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100">
            <option v-for="profile in adminProfileOptions" :key="profile" :value="profile">{{ t(`admin.roles.${profile}`) }}</option>
          </select>
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">{{ t('admin.accounts.modals.status') }}
          <select v-model="form.status" class="rounded-2xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100">
            <option v-for="status in statusOptions" :key="status" :value="status">{{ statusLabels[status] }}</option>
          </select>
        </label>
        <label v-if="!editingUser" class="grid gap-2 text-sm font-bold text-slate-700">{{ t('admin.accounts.modals.password') }}
          <input v-model="form.password" required :minlength="MIN_PASSWORD_LENGTH" type="password" class="rounded-2xl border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" />
        </label>
        <div class="flex justify-end gap-3 pt-2">
          <button type="button" class="rounded-xl border border-slate-200 px-4 py-2 text-sm font-bold text-slate-600" @click="closeUserModal">{{ t('admin.accounts.actions.cancel') }}</button>
          <button class="rounded-xl bg-avocado-800 px-4 py-2 text-sm font-black text-white">{{ t('admin.accounts.actions.save') }}</button>
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
      :message="t('admin.accounts.confirmDelete.message')"
      :confirm-label="t('admin.accounts.confirmDelete.confirm')"
      @close="pendingDelete = null"
      @confirm="confirmDelete"
    />
  </div>
</template>