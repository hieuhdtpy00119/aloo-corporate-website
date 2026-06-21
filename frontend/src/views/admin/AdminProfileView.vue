<script setup>
import { onMounted, reactive, ref, watch, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { Camera, KeyRound, LockKeyhole, Mail, Phone, ShieldCheck, UserRound } from 'lucide-vue-next'
import { changeAdminPassword, getCurrentAdmin, updateAdminProfile, uploadProfileAvatar, usesGoogleSignIn } from '../../services/authService'
import { resolveBackendAssetUrl } from '../../services/cmsService'
import { useToastStore } from '../../stores/toastStore'
import AvatarCropModal from '../../components/shared/AvatarCropModal.vue'
import {
  getConfirmPasswordErrorKey,
  getCurrentPasswordErrorKey,
  getNewPasswordErrorKey,
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

const toast = useToastStore()
const route = useRoute()
const router = useRouter()
const { t } = useI18n()
const activeTab = ref(route.query.tab === 'security' && !usesGoogleSignIn() ? 'security' : 'account')
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
  avatar: '',
}

const profile = reactive({ ...defaultProfile })
const passwordForm = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
})
const passwordErrors = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
})

const profileEyebrow = computed(() =>
  props.variant === 'account' ? t('admin.profile.accountEyebrow') : t('admin.profile.adminEyebrow'),
)
const profileTitle = computed(() =>
  props.variant === 'account' ? t('admin.profile.accountTitle') : t('admin.profile.adminTitle'),
)
const profileDescription = computed(() =>
  props.variant === 'account' ? t('admin.profile.accountDescription') : t('admin.profile.adminDescription'),
)
const securityTitle = computed(() =>
  props.variant === 'account' ? t('admin.profile.security.accountTitle') : t('admin.profile.security.adminTitle'),
)
const securityDescription = computed(() =>
  props.variant === 'account' ? t('admin.profile.security.accountDescription') : t('admin.profile.security.adminDescription'),
)
const showSecurityTab = computed(() => !usesGoogleSignIn())
const avatarSrc = computed(() => resolveBackendAssetUrl(profile.avatar))
const usesGoogleAvatar = computed(() => {
  const avatar = String(profile.avatar || '')
  return usesGoogleSignIn() && avatar.includes('googleusercontent.com')
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
  passwordErrors.newPassword = ''
  passwordErrors.confirmPassword = ''
}

const validatePasswordForm = () => {
  clearPasswordErrors()

  const currentErrorKey = getCurrentPasswordErrorKey(passwordForm.currentPassword)
  if (currentErrorKey) passwordErrors.currentPassword = t(currentErrorKey)

  const newErrorKey = getNewPasswordErrorKey(passwordForm.newPassword)
  if (newErrorKey) passwordErrors.newPassword = t(newErrorKey)

  const confirmErrorKey = getConfirmPasswordErrorKey(passwordForm.newPassword, passwordForm.confirmPassword)
  if (confirmErrorKey) passwordErrors.confirmPassword = t(confirmErrorKey)

  return !passwordErrors.currentPassword && !passwordErrors.newPassword && !passwordErrors.confirmPassword
}

const changePassword = async () => {
  if (!validatePasswordForm()) {
    toast.error(t('admin.profile.toasts.checkForm'))
    return
  }

  isChangingPassword.value = true
  try {
    await changeAdminPassword({
      currentPassword: passwordForm.currentPassword,
      newPassword: passwordForm.newPassword,
    })
    passwordForm.currentPassword = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
    toast.success(t('admin.profile.toasts.passwordUpdated'))
  } catch (error) {
    toast.error(error.response?.data?.message || t('admin.profile.toasts.passwordUpdateError'))
  } finally {
    isChangingPassword.value = false
  }
}

onMounted(async () => {
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
    })
  } catch (error) {
    profileLoadError.value = error.response?.data?.message || t('admin.profile.loadError')
    toast.error(profileLoadError.value)
  } finally {
    isLoadingProfile.value = false
  }
})
</script>

<template>
  <section class="mx-auto grid max-w-5xl gap-6">
    <div class="aloo-admin-header max-lg:!grid-cols-1">
      <div>
        <p class="aloo-eyebrow">{{ profileEyebrow }}</p>
        <h1 class="aloo-title aloo-title--admin mt-2">{{ profileTitle }}</h1>
        <p class="aloo-copy mt-2 max-w-2xl">{{ profileDescription }}</p>
        <div v-if="showSecurityTab" class="mt-6 inline-flex rounded-2xl bg-white p-1 shadow-sm ring-1 ring-avocado-100">
          <button
            type="button"
            class="rounded-xl px-5 py-2.5 text-sm font-black transition"
            :class="activeTab === 'account' ? 'bg-avocado-900 text-white shadow-sm' : 'text-slate-600 hover:bg-avocado-50 hover:text-avocado-900'"
            @click="setTab('account')"
          >
            {{ t('admin.profile.tabs.account') }}
          </button>
          <button
            type="button"
            class="rounded-xl px-5 py-2.5 text-sm font-black transition"
            :class="activeTab === 'security' ? 'bg-avocado-900 text-white shadow-sm' : 'text-slate-600 hover:bg-avocado-50 hover:text-avocado-900'"
            @click="setTab('security')"
          >
            {{ t('admin.profile.tabs.security') }}
          </button>
        </div>
      </div>
    </div>

    <div
      v-if="isLoadingProfile"
      class="rounded-2xl border border-slate-200 bg-white p-8 text-center text-sm font-semibold text-slate-500"
      aria-busy="true"
    >
      {{ t('admin.profile.loading') }}
    </div>

    <p
      v-else-if="profileLoadError"
      class="rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-sm font-semibold text-red-700"
      role="alert"
    >
      {{ profileLoadError }}
    </p>

    <form v-else-if="activeTab === 'account'" class="grid gap-6 lg:grid-cols-[320px_1fr]" @submit.prevent="saveProfile">
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
          <p class="mt-1 rounded-full bg-cream-100 px-3 py-1 text-sm font-black text-avocado-800">{{ profile.role }}</p>
          <p v-if="usesGoogleAvatar" class="mt-3 text-xs leading-5 text-slate-500">
            {{ t('admin.profile.avatar.googleCurrent') }}
          </p>
          <p v-else-if="usesGoogleSignIn()" class="mt-3 text-xs leading-5 text-slate-500">
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
          <div class="flex items-center gap-3 rounded-xl bg-slate-50 px-4 py-3">
            <ShieldCheck class="h-4 w-4 text-avocado-700" />
            <span>{{ profile.role }}</span>
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
              required
              class="rounded-xl border border-slate-200 px-4 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
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

          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ t('admin.profile.fields.role') }}
            <input
              v-model.trim="profile.role"
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

    <div v-else-if="showSecurityTab" class="grid gap-6 lg:grid-cols-[280px_1fr]">
      <aside class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="grid h-16 w-16 place-items-center rounded-2xl bg-avocado-50 text-avocado-800">
          <ShieldCheck class="h-8 w-8" />
        </div>
        <h3 class="mt-5 text-xl font-black text-avocado-950">{{ securityTitle }}</h3>
        <p class="mt-2 text-sm leading-6 text-slate-600">{{ securityDescription }}</p>
      </aside>

      <form class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm" novalidate @submit.prevent="changePassword">
        <div class="grid gap-5">
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ t('admin.profile.fields.currentPassword') }}
            <span class="relative">
              <LockKeyhole class="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-avocado-700" />
              <input v-model="passwordForm.currentPassword" type="password" autocomplete="current-password" class="w-full rounded-xl border px-12 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" :class="passwordErrors.currentPassword ? 'border-red-300 bg-red-50/40' : 'border-slate-200'" />
            </span>
            <span v-if="passwordErrors.currentPassword" class="text-xs font-bold text-red-600">{{ passwordErrors.currentPassword }}</span>
          </label>

          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ t('admin.profile.fields.newPassword') }}
            <span class="relative">
              <KeyRound class="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-avocado-700" />
              <input v-model="passwordForm.newPassword" type="password" autocomplete="new-password" class="w-full rounded-xl border px-12 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" :class="passwordErrors.newPassword ? 'border-red-300 bg-red-50/40' : 'border-slate-200'" />
            </span>
            <span v-if="passwordErrors.newPassword" class="text-xs font-bold text-red-600">{{ passwordErrors.newPassword }}</span>
          </label>

          <label class="grid gap-2 text-sm font-bold text-slate-700">
            {{ t('admin.profile.fields.confirmPassword') }}
            <span class="relative">
              <KeyRound class="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-avocado-700" />
              <input v-model="passwordForm.confirmPassword" type="password" autocomplete="new-password" class="w-full rounded-xl border px-12 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" :class="passwordErrors.confirmPassword ? 'border-red-300 bg-red-50/40' : 'border-slate-200'" />
            </span>
            <span v-if="passwordErrors.confirmPassword" class="text-xs font-bold text-red-600">{{ passwordErrors.confirmPassword }}</span>
          </label>
        </div>

        <div class="mt-8 flex justify-end">
          <button
            type="submit"
            class="rounded-xl bg-avocado-800 px-6 py-3 font-black text-white shadow-sm transition hover:bg-avocado-900 focus:outline-none focus:ring-4 focus:ring-avocado-100 disabled:cursor-not-allowed disabled:opacity-60"
            :disabled="isChangingPassword"
          >
            {{ isChangingPassword ? t('admin.profile.actions.changingPassword') : t('admin.profile.actions.changePassword') }}
          </button>
        </div>
      </form>
    </div>
  </section>

  <AvatarCropModal
    :show="showAvatarCropper"
    :image-src="pendingAvatarSrc"
    :file-name="pendingAvatarFileName"
    @close="closeAvatarCropper"
    @confirm="handleAvatarCropConfirm"
  />
</template>
