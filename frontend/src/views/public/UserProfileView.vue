<script setup>
import { onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Camera, KeyRound, LockKeyhole, Mail, Phone, ShieldCheck, UserRound } from 'lucide-vue-next'
import { changeUserPassword, getCurrentUser, updateUserProfile, uploadUserImage } from '../../services/userAuthService'
import { useToastStore } from '../../stores/toastStore'

const toast = useToastStore()
const route = useRoute()
const router = useRouter()
const activeTab = ref(route.query.tab === 'security' ? 'security' : 'account')
const isSaving = ref(false)
const isUploadingAvatar = ref(false)
const isChangingPassword = ref(false)

const defaultProfile = {
  fullName: 'Khách hàng ALOO',
  email: 'user@aloo.vn',
  phone: '0901 234 567',
  role: 'Khách hàng',
  avatar: '/logo-aloo.png',
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

const setTab = (tab) => {
  activeTab.value = tab
  router.replace({ path: '/profile', query: tab === 'security' ? { tab: 'security' } : {} })
}

watch(
  () => route.query.tab,
  (tab) => {
    activeTab.value = tab === 'security' ? 'security' : 'account'
  },
)

const handleAvatarChange = async (event) => {
  const file = event.target.files?.[0]
  if (!file) return

  isUploadingAvatar.value = true
  try {
    const { data } = await uploadUserImage(file)
    profile.avatar = data.url
    toast.success('Đã upload ảnh đại diện')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không upload được ảnh đại diện')
  } finally {
    isUploadingAvatar.value = false
    event.target.value = ''
  }
}

const saveProfile = async () => {
  if (isSaving.value) return
  isSaving.value = true
  try {
    const { data } = await updateUserProfile({
      fullName: profile.fullName,
      email: profile.email,
      phone: profile.phone,
      avatarUrl: profile.avatar,
    })
    Object.assign(profile, {
      fullName: data.fullName,
      email: data.email,
      phone: data.phone || '',
      avatar: data.avatarUrl || defaultProfile.avatar,
      role: data.role || 'USER',
    })
    localStorage.setItem('user_user', JSON.stringify(data))
    window.dispatchEvent(new Event('aloo-auth-change'))
    toast.success('Cập nhật thông tin thành công')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không cập nhật được thông tin')
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

  if (!passwordForm.currentPassword.trim()) {
    passwordErrors.currentPassword = 'Vui lòng nhập mật khẩu hiện tại'
  }

  if (!passwordForm.newPassword.trim()) {
    passwordErrors.newPassword = 'Vui lòng nhập mật khẩu mới'
  } else if (passwordForm.newPassword.length < 8) {
    passwordErrors.newPassword = 'Mật khẩu mới tối thiểu 8 ký tự'
  }

  if (!passwordForm.confirmPassword.trim()) {
    passwordErrors.confirmPassword = 'Vui lòng nhập lại mật khẩu mới'
  } else if (passwordForm.confirmPassword !== passwordForm.newPassword) {
    passwordErrors.confirmPassword = 'Mật khẩu nhập lại không khớp'
  }

  return !passwordErrors.currentPassword && !passwordErrors.newPassword && !passwordErrors.confirmPassword
}

const changePassword = async () => {
  if (!validatePasswordForm()) {
    toast.error('Vui lòng kiểm tra lại thông tin')
    return
  }

  isChangingPassword.value = true
  try {
    await changeUserPassword({
      currentPassword: passwordForm.currentPassword,
      newPassword: passwordForm.newPassword,
    })
    passwordForm.currentPassword = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
    localStorage.removeItem('user_token')
    localStorage.removeItem('user_user')
    localStorage.removeItem('user_role')
    window.dispatchEvent(new Event('aloo-auth-change'))
    toast.success('Đổi mật khẩu thành công')
    router.replace('/login')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không đổi được mật khẩu')
  } finally {
    isChangingPassword.value = false
  }
}

onMounted(async () => {
  try {
    const { data } = await getCurrentUser()
    Object.assign(profile, {
      fullName: data.fullName,
      email: data.email,
      phone: data.phone || '',
      avatar: data.avatarUrl || defaultProfile.avatar,
      role: data.role || 'USER',
    })
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không tải được thông tin tài khoản')
  }
})
</script>

<template>
  <section class="bg-avocado-50 px-4 py-10 sm:px-5 lg:px-6">
    <div class="mx-auto max-w-5xl space-y-6">
      <div class="rounded-2xl border border-avocado-100 bg-gradient-to-br from-white via-avocado-50 to-cream-100 p-6 shadow-sm">
        <p class="text-sm font-black uppercase tracking-[0.18em] text-avocado-600">Tài khoản người dùng</p>
        <h1 class="mt-2 text-3xl font-black text-avocado-950">Tài khoản của tôi</h1>
        <p class="mt-2 max-w-2xl text-slate-600">
          Quản lý thông tin cá nhân và bảo mật trong cùng một khu vực gọn hơn.
        </p>
        <div class="mt-6 inline-flex rounded-2xl bg-white p-1 shadow-sm ring-1 ring-avocado-100">
          <button
            type="button"
            class="rounded-xl px-5 py-2.5 text-sm font-black transition"
            :class="activeTab === 'account' ? 'bg-avocado-900 text-white shadow-sm' : 'text-slate-600 hover:bg-avocado-50 hover:text-avocado-900'"
            @click="setTab('account')"
          >
            Tài khoản
          </button>
          <button
            type="button"
            class="rounded-xl px-5 py-2.5 text-sm font-black transition"
            :class="activeTab === 'security' ? 'bg-avocado-900 text-white shadow-sm' : 'text-slate-600 hover:bg-avocado-50 hover:text-avocado-900'"
            @click="setTab('security')"
          >
            Bảo mật
          </button>
        </div>
      </div>

      <form v-if="activeTab === 'account'" class="grid gap-6 lg:grid-cols-[320px_1fr]" @submit.prevent="saveProfile">
        <aside class="rounded-2xl border border-avocado-100 bg-white p-6 shadow-sm">
          <div class="flex flex-col items-center text-center">
            <div class="relative">
              <div class="grid h-36 w-36 place-items-center overflow-hidden rounded-full border-4 border-cream-200 bg-avocado-50 shadow-inner">
                <img v-if="profile.avatar" :src="profile.avatar" :alt="profile.fullName" class="h-full w-full object-cover" />
                <UserRound v-else class="h-14 w-14 text-avocado-700" />
              </div>
              <label class="absolute bottom-1 right-1 grid h-11 w-11 cursor-pointer place-items-center rounded-full border border-avocado-100 bg-white text-avocado-800 shadow-lg transition hover:bg-avocado-50" aria-label="Chọn ảnh đại diện">
                <Camera class="h-5 w-5" />
                <input class="sr-only" type="file" accept="image/*" :disabled="isUploadingAvatar" @change="handleAvatarChange" />
              </label>
            </div>

            <h2 class="mt-5 text-xl font-black text-avocado-950">{{ profile.fullName }}</h2>
            <p class="mt-1 rounded-full bg-cream-100 px-3 py-1 text-sm font-black text-avocado-800">{{ profile.role }}</p>
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

        <article class="rounded-2xl border border-avocado-100 bg-white p-6 shadow-sm">
          <div class="grid gap-5 md:grid-cols-2">
            <label class="grid gap-2 text-sm font-bold text-slate-700">
              Họ tên
              <input v-model.trim="profile.fullName" required class="rounded-xl border border-slate-200 px-4 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" />
            </label>
            <label class="grid gap-2 text-sm font-bold text-slate-700">
              Email
              <input v-model.trim="profile.email" type="email" required class="rounded-xl border border-slate-200 px-4 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" />
            </label>
            <label class="grid gap-2 text-sm font-bold text-slate-700">
              Số điện thoại
              <input v-model.trim="profile.phone" type="tel" required class="rounded-xl border border-slate-200 px-4 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" />
            </label>
            <label class="grid gap-2 text-sm font-bold text-slate-700">
              Vai trò
              <input v-model.trim="profile.role" required class="rounded-xl border border-slate-200 px-4 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" />
            </label>
            <label class="grid gap-2 text-sm font-bold text-slate-700 md:col-span-2">
              Ảnh đại diện
              <input type="file" accept="image/*" class="rounded-xl border border-dashed border-avocado-200 bg-avocado-50/60 px-4 py-3 text-sm outline-none file:mr-4 file:rounded-full file:border-0 file:bg-avocado-800 file:px-4 file:py-2 file:font-black file:text-white hover:bg-avocado-50 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isUploadingAvatar" @change="handleAvatarChange" />
              <span v-if="isUploadingAvatar" class="text-xs font-bold text-avocado-700">Đang upload ảnh lên backend...</span>
            </label>
          </div>

          <div class="mt-8 flex justify-end">
            <button type="submit" class="rounded-xl bg-avocado-800 px-6 py-3 font-black text-white shadow-sm transition hover:bg-avocado-900 focus:outline-none focus:ring-4 focus:ring-avocado-100 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isSaving || isUploadingAvatar">
              {{ isSaving ? 'Đang lưu...' : 'Cập nhật thông tin' }}
            </button>
          </div>
        </article>
      </form>

      <div v-else class="grid gap-6 lg:grid-cols-[280px_1fr]">
        <aside class="rounded-2xl border border-avocado-100 bg-white p-6 shadow-sm">
          <div class="grid h-16 w-16 place-items-center rounded-2xl bg-avocado-50 text-avocado-800">
            <ShieldCheck class="h-8 w-8" />
          </div>
          <h2 class="mt-5 text-xl font-black text-avocado-950">Bảo mật đăng nhập</h2>
          <p class="mt-2 text-sm leading-6 text-slate-600">
            Đổi mật khẩu ngay trong trang tài khoản. Sau khi đổi thành công, hệ thống sẽ yêu cầu đăng nhập lại.
          </p>
        </aside>

        <form class="rounded-2xl border border-avocado-100 bg-white p-6 shadow-sm" novalidate @submit.prevent="changePassword">
          <div class="grid gap-5">
            <label class="grid gap-2 text-sm font-bold text-slate-700">
              Mật khẩu hiện tại
              <span class="relative">
                <LockKeyhole class="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-avocado-700" />
                <input v-model="passwordForm.currentPassword" type="password" autocomplete="current-password" class="w-full rounded-xl border px-12 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" :class="passwordErrors.currentPassword ? 'border-red-300 bg-red-50/40' : 'border-slate-200'" />
              </span>
              <span v-if="passwordErrors.currentPassword" class="text-xs font-bold text-red-600">{{ passwordErrors.currentPassword }}</span>
            </label>

            <label class="grid gap-2 text-sm font-bold text-slate-700">
              Mật khẩu mới
              <span class="relative">
                <KeyRound class="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-avocado-700" />
                <input v-model="passwordForm.newPassword" type="password" autocomplete="new-password" class="w-full rounded-xl border px-12 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" :class="passwordErrors.newPassword ? 'border-red-300 bg-red-50/40' : 'border-slate-200'" />
              </span>
              <span v-if="passwordErrors.newPassword" class="text-xs font-bold text-red-600">{{ passwordErrors.newPassword }}</span>
            </label>

            <label class="grid gap-2 text-sm font-bold text-slate-700">
              Nhập lại mật khẩu mới
              <span class="relative">
                <KeyRound class="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-avocado-700" />
                <input v-model="passwordForm.confirmPassword" type="password" autocomplete="new-password" class="w-full rounded-xl border px-12 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" :class="passwordErrors.confirmPassword ? 'border-red-300 bg-red-50/40' : 'border-slate-200'" />
              </span>
              <span v-if="passwordErrors.confirmPassword" class="text-xs font-bold text-red-600">{{ passwordErrors.confirmPassword }}</span>
            </label>
          </div>

          <div class="mt-8 flex justify-end">
            <button type="submit" class="rounded-xl bg-avocado-800 px-6 py-3 font-black text-white shadow-sm transition hover:bg-avocado-900 focus:outline-none focus:ring-4 focus:ring-avocado-100 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isChangingPassword">
              {{ isChangingPassword ? 'Đang đổi...' : 'Đổi mật khẩu' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </section>
</template>
