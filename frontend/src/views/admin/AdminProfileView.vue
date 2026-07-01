<script setup>
import { onMounted, onUnmounted, reactive, ref, watch, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { Camera, KeyRound, LockKeyhole, Mail, Phone, ShieldCheck, UserRound } from 'lucide-vue-next'
import { changeAdminPassword, getCurrentAdmin, refreshAuthProfile, requestPasswordChangeOtp, updateAdminProfile, uploadProfileAvatar, usesGoogleSignIn } from '../../services/authService'
import { resolveBackendAssetUrl } from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'
import AvatarCropModal from '../../components/shared/AvatarCropModal.vue'
import PasswordInput from '../../components/shared/PasswordInput.vue'
import PasswordStrengthPanel from '../../components/shared/PasswordStrengthPanel.vue'
import AdminListPage from '../../components/admin/AdminListPage.vue'
import AdminNestedShell from '../../components/admin/shell/AdminNestedShell.vue'
import AdminShellFrame from '../../components/admin/shell/AdminShellFrame.vue'
import AdminShellTabs from '../../components/admin/shell/AdminShellTabs.vue'
import AdminPageHeader from '../../components/admin/AdminPageHeader.vue'
import { isAuthenticatedToken } from '../../router/authGuard'
import {
  getConfirmPasswordErrorKey,
  getCurrentPasswordErrorKey,
  getNewPasswordErrorKey,
  getSameAsCurrentPasswordErrorKey,
} from '../../utils/passwordPolicy'

const props = defineProps({
  basePath: {
    type: String,
    default: '/admin/profile',
  },
  variant: {
    type: String,
    default: 'admin',
  },
})

const securityAvailable = () => !usesGoogleSignIn() || props.variant === 'account'

const toast = useToastStore()
const route = useRoute()
const router = useRouter()
const { t } = useI18n()
const activeTab = ref(route.query.tab === 'security' && securityAvailable() ? 'security' : 'account')
const isSaving = ref(false)
const isLoadingProfile = ref(true)
const profileLoadError = ref('')
const isUploadingAvatar = ref(false)
const isChangingPassword = ref(false)
const showAvatarCropper = ref(false)
const pendingAvatarSrc = ref('')
const pendingAvatarFileName = ref('avatar.jpg')

const defaultProfile = {
  fullName: '',
  email: '',
  phone: '',
  role: '',
  adminProfile: '',
  authProvider: '',
  hasPasswordLogin: false,
  passwordChangeRequiresOtp: false,
  passwordChangedAt: '',
  avatar: '',
}

const profile = reactive({ ...defaultProfile })
const passwordForm = reactive({
  currentPassword: '',
  otp: '',
  newPassword: '',
  confirmPassword: '',
})
const passwordErrors = reactive({
  currentPassword: '',
  otp: '',
  newPassword: '',
  confirmPassword: '',
})
const confirmTouched = ref(false)
const otpMaskedEmail = ref('')
const isRequestingOtp = ref(false)
const otpResendSeconds = ref(0)
let otpResendTimer = null

const profileEyebrow = computed(() =>
  props.variant === 'account' ? t('admin.profile.accountEyebrow') : t('admin.profile.adminEyebrow'),
)
const profileTitle = computed(() =>
  props.variant === 'account' ? t('admin.profile.accountTitle') : t('admin.profile.adminTitle'),
)
const securityTitle = computed(() =>
  props.variant === 'account' ? t('admin.profile.security.accountTitle') : t('admin.profile.security.adminTitle'),
)
const securityDescription = computed(() => {
  if (!profile.hasPasswordLogin) {
    return profile.passwordChangeRequiresOtp
      ? t('admin.profile.security.setDescriptionOtp')
      : t('admin.profile.security.setDescription')
  }
  return props.variant === 'account'
    ? t('admin.profile.security.accountDescription')
    : t('admin.profile.security.adminDescription')
})
const showSecurityTab = computed(() => !usesGoogleSignIn() || isAccountVariant.value)
const requiresCurrentPassword = computed(() => profile.hasPasswordLogin)
const requiresOtp = computed(() => profile.passwordChangeRequiresOtp)
const canResendOtp = computed(() => otpResendSeconds.value <= 0 && !isRequestingOtp.value)
const passwordActionLabel = computed(() =>
  requiresCurrentPassword.value
    ? t('admin.profile.actions.changePassword')
    : t('admin.profile.actions.setPassword'),
)
const passwordActionPendingLabel = computed(() =>
  requiresCurrentPassword.value
    ? t('admin.profile.actions.changingPassword')
    : t('admin.profile.actions.settingPassword'),
)
const isAccountVariant = computed(() => props.variant === 'account')
const shellWrapper = computed(() => (isAccountVariant.value ? 'div' : AdminListPage))
const profileTabItems = computed(() => {
  const items = [{ key: 'account', label: t('admin.profile.tabs.account') }]
  if (showSecurityTab.value) {
    items.push({ key: 'security', label: t('admin.profile.tabs.security') })
  }
  return items
})
const avatarSrc = computed(() => resolveBackendAssetUrl(profile.avatar))
const usesGoogleAvatar = computed(() => {
  const avatar = String(profile.avatar || '')
  return usesGoogleSignIn() && avatar.includes('googleusercontent.com')
})
const isEmailLocked = computed(() => profile.authProvider === 'GOOGLE' || usesGoogleSignIn())
const roleDisplayLabel = computed(() => {
  if (profile.role === 'ADMIN' && profile.adminProfile) {
    const key = `admin.roles.${profile.adminProfile}`
    const label = t(key)
    return label !== key ? label : profile.adminProfile
  }
  return profile.role
})

const formatDateTime = (value) => (value ? String(value).replace('T', ' ').slice(0, 16) : '')

const passwordChangedLabel = computed(() => {
  if (!profile.passwordChangedAt) return ''
  return t('admin.profile.security.lastChanged', { time: formatDateTime(profile.passwordChangedAt) })
})

const setTab = (tab) => {
  if (tab === 'security' && !showSecurityTab.value) {
    tab = 'account'
  }
  activeTab.value = tab
  router.replace({ path: props.basePath, query: tab === 'security' ? { tab: 'security' } : {} })
}

watch(
  () => route.query.tab,
  (tab) => {
    if (tab === 'security' && !showSecurityTab.value) {
      setTab('account')
      return
    }
    activeTab.value = tab === 'security' ? 'security' : 'account'
  },
)

watch(
  () => passwordForm.confirmPassword,
  (value) => {
    if (!value && !confirmTouched.value) return
    if (value) confirmTouched.value = true
    const confirmErrorKey = getConfirmPasswordErrorKey(
      passwordForm.newPassword,
      value,
      { touched: confirmTouched.value },
    )
    passwordErrors.confirmPassword = confirmErrorKey ? t(confirmErrorKey) : ''
  },
)

const handleAvatarChange = (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  if (!file.type.startsWith('image/')) {
    toast.error(t('admin.profile.toasts.invalidImageType'))
    event.target.value = ''
    return
  }

  if (file.size > 5 * 1024 * 1024) {
    toast.error(t('admin.profile.toasts.imageTooLarge'))
    event.target.value = ''
    return
  }

  const reader = new FileReader()
  reader.onload = (loadEvent) => {
    pendingAvatarSrc.value = loadEvent.target?.result || ''
    pendingAvatarFileName.value = file.name || 'avatar.jpg'
    showAvatarCropper.value = true
  }
  reader.onerror = () => {
    toast.error(t('admin.profile.toasts.imageReadError'))
  }
  reader.readAsDataURL(file)
  event.target.value = ''
}

const closeAvatarCropper = () => {
  showAvatarCropper.value = false
  pendingAvatarSrc.value = ''
  pendingAvatarFileName.value = 'avatar.jpg'
}

const uploadAvatarFile = async (file) => {
  isUploadingAvatar.value = true
  try {
    const { data } = await uploadProfileAvatar(file)
    profile.avatar = resolveBackendAssetUrl(data.url)

    const { data: saved } = await updateAdminProfile({
      fullName: profile.fullName,
      email: profile.email,
      phone: profile.phone,
      avatarUrl: profile.avatar,
    })
    Object.assign(profile, {
      fullName: saved.fullName,
      email: saved.email,
      phone: saved.phone || profile.phone,
      avatar: resolveBackendAssetUrl(saved.avatarUrl || profile.avatar),
      role: saved.role || profile.role,
      adminProfile: saved.adminProfile || profile.adminProfile,
      authProvider: saved.authProvider || profile.authProvider,
    })
    localStorage.setItem('admin_user', JSON.stringify(saved))
    window.dispatchEvent(new Event('aloo-auth-change'))
    toast.success(t('admin.profile.toasts.avatarUpdated'))
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.profile.toasts.avatarUploadError'))
  } finally {
    isUploadingAvatar.value = false
  }
}

const handleAvatarCropConfirm = async (file) => {
  closeAvatarCropper()
  await uploadAvatarFile(file)
}

const saveProfile = async () => {
  if (isSaving.value) return
  isSaving.value = true
  try {
    const { data } = await updateAdminProfile({
      fullName: profile.fullName,
      email: profile.email,
      phone: profile.phone,
      avatarUrl: profile.avatar,
    })
    Object.assign(profile, {
      fullName: data.fullName,
      email: data.email,
      phone: data.phone || profile.phone,
      avatar: resolveBackendAssetUrl(data.avatarUrl || profile.avatar),
      role: data.role || profile.role,
      adminProfile: data.adminProfile || profile.adminProfile,
      authProvider: data.authProvider || profile.authProvider,
    })
    localStorage.setItem('admin_user', JSON.stringify(data))
    window.dispatchEvent(new Event('aloo-auth-change'))
    toast.success(t('admin.profile.toasts.profileUpdated'))
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.profile.toasts.profileUpdateError'))
  } finally {
    isSaving.value = false
  }
}

const clearPasswordErrors = () => {
  passwordErrors.currentPassword = ''
  passwordErrors.otp = ''
  passwordErrors.newPassword = ''
  passwordErrors.confirmPassword = ''
}

const stopOtpResendTimer = () => {
  if (otpResendTimer) {
    clearInterval(otpResendTimer)
    otpResendTimer = null
  }
}

const startOtpResendTimer = (seconds = 60) => {
  stopOtpResendTimer()
  otpResendSeconds.value = seconds
  otpResendTimer = setInterval(() => {
    otpResendSeconds.value -= 1
    if (otpResendSeconds.value <= 0) {
      stopOtpResendTimer()
      otpResendSeconds.value = 0
    }
  }, 1000)
}

const requestOtp = async () => {
  if (!canResendOtp.value) return

  isRequestingOtp.value = true
  try {
    const { data } = await requestPasswordChangeOtp()
    otpMaskedEmail.value = data.maskedEmail || ''
    startOtpResendTimer(60)
    toast.success(t('admin.profile.toasts.otpSent', { email: otpMaskedEmail.value }))
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.profile.toasts.otpSendError'))
  } finally {
    isRequestingOtp.value = false
  }
}

const validatePasswordForm = () => {
  clearPasswordErrors()

  const currentErrorKey = getCurrentPasswordErrorKey(passwordForm.currentPassword, {
    required: requiresCurrentPassword.value,
  })
  if (currentErrorKey) passwordErrors.currentPassword = t(currentErrorKey)

  if (requiresOtp.value) {
    const otp = String(passwordForm.otp || '').trim()
    if (!otp) {
      passwordErrors.otp = t('admin.password.errors.otpRequired')
    } else if (!/^\d{6}$/.test(otp)) {
      passwordErrors.otp = t('admin.password.errors.otpInvalid')
    }
  }

  const newErrorKey = getNewPasswordErrorKey(passwordForm.newPassword)
  if (newErrorKey) passwordErrors.newPassword = t(newErrorKey)

  const sameAsCurrentKey = getSameAsCurrentPasswordErrorKey(
    passwordForm.currentPassword,
    passwordForm.newPassword,
  )
  if (sameAsCurrentKey) passwordErrors.newPassword = t(sameAsCurrentKey)

  const confirmErrorKey = getConfirmPasswordErrorKey(
    passwordForm.newPassword,
    passwordForm.confirmPassword,
    { touched: true },
  )
  if (confirmErrorKey) passwordErrors.confirmPassword = t(confirmErrorKey)

  return !passwordErrors.currentPassword
    && !passwordErrors.otp
    && !passwordErrors.newPassword
    && !passwordErrors.confirmPassword
}

const changePassword = async () => {
  if (!validatePasswordForm()) {
    toast.error(t('admin.profile.toasts.checkForm'))
    return
  }

  isChangingPassword.value = true
  const wasSettingPassword = !profile.hasPasswordLogin
  try {
    const { data } = await changeAdminPassword({
      currentPassword: passwordForm.currentPassword,
      otp: requiresOtp.value ? passwordForm.otp.trim() : undefined,
      newPassword: passwordForm.newPassword,
    })
    passwordForm.currentPassword = ''
    passwordForm.otp = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
    confirmTouched.value = false
    const refreshed = await refreshAuthProfile()
    profile.hasPasswordLogin = Boolean(refreshed.hasPasswordLogin)
    profile.passwordChangeRequiresOtp = Boolean(refreshed.passwordChangeRequiresOtp)
    profile.passwordChangedAt = refreshed.passwordChangedAt || data?.passwordChangedAt || ''
    stopOtpResendTimer()
    otpResendSeconds.value = 0
    otpMaskedEmail.value = ''
    const successKey = wasSettingPassword
      ? 'admin.profile.toasts.passwordSet'
      : 'admin.profile.toasts.passwordUpdated'
    if (data?.emailNotificationSent) {
      toast.success(`${t(successKey)} ${t('admin.profile.toasts.passwordEmailSent')}`)
    } else {
      toast.success(t(successKey))
    }
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.profile.toasts.passwordUpdateError'))
  } finally {
    isChangingPassword.value = false
  }
}

const resetProfileIfLoggedOut = () => {
  if (!isAuthenticatedToken(localStorage.getItem('admin_token'))) {
    Object.assign(profile, defaultProfile)
    profileLoadError.value = ''
    isLoadingProfile.value = false
  }
}

onMounted(async () => {
  window.addEventListener('aloo-auth-change', resetProfileIfLoggedOut)
  isLoadingProfile.value = true
  profileLoadError.value = ''
  try {
    const { data } = await getCurrentAdmin()
    Object.assign(profile, {
      fullName: data.fullName,
      email: data.email,
      phone: data.phone || '',
      avatar: resolveBackendAssetUrl(data.avatarUrl || ''),
      role: data.role || 'ADMIN',
      adminProfile: data.adminProfile || '',
      authProvider: data.authProvider || '',
      hasPasswordLogin: Boolean(data.hasPasswordLogin),
      passwordChangeRequiresOtp: Boolean(data.passwordChangeRequiresOtp),
      passwordChangedAt: data.passwordChangedAt || '',
    })
  } catch (error) {
    profileLoadError.value = error.response?.data?.message || t('admin.profile.loadError')
    toast.error(profileLoadError.value)
  } finally {
    isLoadingProfile.value = false
  }
})

onUnmounted(() => {
  window.removeEventListener('aloo-auth-change', resetProfileIfLoggedOut)
  stopOtpResendTimer()
})
</script>

<template>
  <component :is="shellWrapper" class="mx-auto max-w-5xl">
    <AdminNestedShell>
      <AdminShellFrame variant="header" inner="header">
        <AdminPageHeader
          :eyebrow="profileEyebrow"
          :title="profileTitle"
        />
        <template v-if="showSecurityTab" #after>
          <AdminShellTabs
            :model-value="activeTab"
            :items="profileTabItems"
            :aria-label="profileTitle"
            @update:model-value="setTab"
          />
        </template>
      </AdminShellFrame>

      <AdminShellFrame v-if="isLoadingProfile" variant="body" inner="pad" aria-busy="true">
        <p class="sr-only">{{ t('admin.profile.loading') }}</p>
        <div v-for="i in 4" :key="i" class="admin-shell-skeleton" />
      </AdminShellFrame>

      <AdminShellFrame v-else-if="profileLoadError" as="p" variant="alert" class="admin-list-alert">
        {{ profileLoadError }}
      </AdminShellFrame>

      <AdminShellFrame v-else-if="activeTab === 'account'" variant="body" inner="pad">
        <form class="grid gap-6 lg:grid-cols-[320px_1fr]" @submit.prevent="saveProfile">
          <aside class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="flex flex-col items-center text-center">
          <div class="relative">
            <div class="grid h-36 w-36 place-items-center overflow-hidden rounded-full border-4 border-cream-200 bg-avocado-50 shadow-inner">
              <img
                v-if="avatarSrc"
                :src="avatarSrc"
                :alt="profile.fullName"
                class="h-full w-full object-cover"
              />
              <UserRound v-else class="h-14 w-14 text-avocado-700" />
            </div>
            <label
              class="absolute bottom-1 right-1 grid h-11 w-11 cursor-pointer place-items-center rounded-full border border-avocado-100 bg-white text-avocado-800 shadow-lg transition hover:bg-avocado-50"
              :aria-label="t('admin.profile.avatar.chooseLabel')"
            >
              <Camera class="h-5 w-5" />
              <input class="sr-only" type="file" accept="image/*" :disabled="isUploadingAvatar" @change="handleAvatarChange" />
            </label>
          </div>

          <h3 class="mt-5 text-xl font-black text-avocado-950">{{ profile.fullName }}</h3>
          <p v-if="!isAccountVariant" class="mt-1 rounded-full bg-cream-100 px-3 py-1 text-sm font-black text-avocado-800">{{ roleDisplayLabel }}</p>
          <p v-if="isAccountVariant && usesGoogleAvatar" class="mt-3 text-xs leading-5 text-slate-500">
            {{ t('admin.profile.avatar.googleCurrent') }}
          </p>
          <p v-else-if="isAccountVariant && usesGoogleSignIn()" class="mt-3 text-xs leading-5 text-slate-500">
            {{ t('admin.profile.avatar.googleCustom') }}
          </p>
          <p v-if="isUploadingAvatar" class="mt-3 text-xs font-bold text-avocado-700">{{ t('admin.profile.uploadingAvatar') }}</p>
        </div>

        <div class="mt-6 grid gap-3 text-sm font-bold text-slate-600">
          <div class="flex items-center gap-3 rounded-xl bg-avocado-50 px-4 py-3">
            <Mail class="h-4 w-4 text-avocado-700" />
            <span class="min-w-0 truncate">{{ profile.email }}</span>
          </div>
          <div class="flex items-center gap-3 rounded-xl bg-cream-100/70 px-4 py-3">
            <Phone class="h-4 w-4 text-avocado-700" />
            <span>{{ profile.phone }}</span>
          </div>
          <div v-if="!isAccountVariant" class="flex items-center gap-3 rounded-xl bg-slate-50 px-4 py-3">
            <ShieldCheck class="h-4 w-4 text-avocado-700" />
            <span>{{ roleDisplayLabel }}</span>
          </div>
        </div>
      </aside>

      <article class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="grid gap-5 md:grid-cols-2">
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ t('admin.profile.fields.fullName') }}
            <input
              v-model.trim="profile.fullName"
              required
              class="rounded-xl border border-slate-200 px-4 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
            />
          </label>

          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ t('admin.profile.fields.email') }}
            <input
              v-model.trim="profile.email"
              type="email"
              :required="!isEmailLocked"
              :readonly="isEmailLocked"
              class="rounded-xl border border-slate-200 px-4 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
              :class="isEmailLocked ? 'cursor-not-allowed bg-slate-50 text-slate-500' : ''"
            />
          </label>

          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ t('admin.profile.fields.phone') }}
            <input
              v-model.trim="profile.phone"
              type="tel"
              required
              class="rounded-xl border border-slate-200 px-4 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
            />
          </label>

          <label v-if="!isAccountVariant" class="grid gap-2 text-sm font-bold text-slate-700">
            {{ profile.role === 'ADMIN' ? t('admin.profile.fields.adminProfile') : t('admin.profile.fields.role') }}
            <input
              :value="roleDisplayLabel"
              readonly
              class="cursor-not-allowed rounded-xl border border-slate-200 bg-slate-50 px-4 py-3 text-slate-500 outline-none"
            />
          </label>
        </div>

        <div class="mt-8 flex justify-end">
          <button
            type="submit"
            class="rounded-xl bg-avocado-800 px-6 py-3 font-black text-white shadow-sm transition hover:bg-avocado-900 focus:outline-none focus:ring-4 focus:ring-avocado-100"
            :disabled="isSaving || isUploadingAvatar"
          >
            {{ isSaving ? t('admin.profile.actions.savingProfile') : t('admin.profile.actions.saveProfile') }}
          </button>
        </div>
      </article>
        </form>
      </AdminShellFrame>

      <AdminShellFrame v-else-if="showSecurityTab" variant="body" inner="pad">
        <div class="grid gap-6 lg:grid-cols-[280px_1fr]">
          <aside class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="grid h-16 w-16 place-items-center rounded-2xl bg-avocado-50 text-avocado-800">
          <ShieldCheck class="h-8 w-8" />
        </div>
        <h3 class="mt-5 text-xl font-black text-avocado-950">{{ securityTitle }}</h3>
        <p class="mt-2 text-sm leading-6 text-slate-600">{{ securityDescription }}</p>
        <p v-if="passwordChangedLabel" class="mt-4 text-xs font-bold text-slate-500">{{ passwordChangedLabel }}</p>
      </aside>

      <form class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm" novalidate @submit.prevent="changePassword">
        <div class="grid gap-5">
          <PasswordInput
            v-if="requiresCurrentPassword"
            v-model="passwordForm.currentPassword"
            :label="t('admin.profile.fields.currentPassword')"
            :error="passwordErrors.currentPassword"
            autocomplete="current-password"
          >
            <template #icon>
              <LockKeyhole class="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-avocado-700" />
            </template>
          </PasswordInput>

          <div v-if="requiresOtp" class="grid gap-3 rounded-xl border border-slate-200 bg-slate-50/80 p-4">
            <p class="text-sm leading-6 text-slate-600">
              {{ t('admin.profile.security.otpHint') }}
            </p>
            <div class="flex flex-wrap items-center gap-3">
              <button
                type="button"
                class="rounded-xl border border-avocado-200 bg-white px-4 py-2 text-sm font-bold text-avocado-800 transition hover:bg-avocado-50 disabled:cursor-not-allowed disabled:opacity-60"
                :disabled="!canResendOtp"
                @click="requestOtp"
              >
                {{
                  isRequestingOtp
                    ? t('admin.profile.actions.sendingOtp')
                    : otpResendSeconds > 0
                      ? t('admin.profile.actions.resendOtpIn', { seconds: otpResendSeconds })
                      : t('admin.profile.actions.sendOtp')
                }}
              </button>
              <p v-if="otpMaskedEmail" class="text-xs font-semibold text-slate-500">
                {{ t('admin.profile.security.otpSentTo', { email: otpMaskedEmail }) }}
              </p>
            </div>
            <label class="grid gap-2 text-sm font-bold text-slate-700">
              {{ t('admin.profile.fields.otp') }}
              <span class="relative block">
                <Mail class="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-avocado-700" />
                <input
                  v-model="passwordForm.otp"
                  type="text"
                  inputmode="numeric"
                  maxlength="6"
                  autocomplete="one-time-code"
                  class="w-full rounded-xl border py-3 pl-12 pr-4 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
                  :class="passwordErrors.otp ? 'border-red-300 bg-red-50/40' : 'border-slate-200 bg-white'"
                  :placeholder="t('admin.profile.fields.otpPlaceholder')"
                />
              </span>
              <span v-if="passwordErrors.otp" class="text-xs font-bold text-red-600">{{ passwordErrors.otp }}</span>
            </label>
          </div>

          <div class="grid gap-3">
            <PasswordInput
              v-model="passwordForm.newPassword"
              :label="t('admin.profile.fields.newPassword')"
              :error="passwordErrors.newPassword"
              autocomplete="new-password"
            >
              <template #icon>
                <KeyRound class="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-avocado-700" />
              </template>
            </PasswordInput>
            <PasswordStrengthPanel :password="passwordForm.newPassword" />
          </div>

          <PasswordInput
            v-model="passwordForm.confirmPassword"
            :label="t('admin.profile.fields.confirmPassword')"
            :error="passwordErrors.confirmPassword"
            autocomplete="new-password"
          >
            <template #icon>
              <KeyRound class="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-avocado-700" />
            </template>
          </PasswordInput>
        </div>

        <div class="mt-8 flex justify-end">
          <button
            type="submit"
            class="rounded-xl bg-avocado-800 px-6 py-3 font-black text-white shadow-sm transition hover:bg-avocado-900 focus:outline-none focus:ring-4 focus:ring-avocado-100 disabled:cursor-not-allowed disabled:opacity-60"
            :disabled="isChangingPassword"
          >
            {{ isChangingPassword ? passwordActionPendingLabel : passwordActionLabel }}
          </button>
        </div>
      </form>
        </div>
      </AdminShellFrame>
    </AdminNestedShell>
  </component>

  <AvatarCropModal
    :show="showAvatarCropper"
    :image-src="pendingAvatarSrc"
    :file-name="pendingAvatarFileName"
    @close="closeAvatarCropper"
    @confirm="handleAvatarCropConfirm"
  />
</template>
