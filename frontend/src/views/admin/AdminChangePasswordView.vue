<script setup>
import { reactive, ref } from 'vue'
import { KeyRound, LockKeyhole, ShieldCheck } from 'lucide-vue-next'
import { changeAdminPassword } from '../../services/authService'
import { useToastStore } from '../../stores/toastStore'

const toast = useToastStore()
const isSaving = ref(false)

const form = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
})

const errors = reactive({
  currentPassword: '',
  newPassword: '',
  confirmPassword: '',
})

const clearErrors = () => {
  errors.currentPassword = ''
  errors.newPassword = ''
  errors.confirmPassword = ''
}

const validate = () => {
  clearErrors()

  if (!form.currentPassword.trim()) {
    errors.currentPassword = 'Vui lòng nhập mật khẩu hiện tại'
  }

  if (!form.newPassword.trim()) {
    errors.newPassword = 'Vui lòng nhập mật khẩu mới'
  } else if (form.newPassword.length < 8) {
    errors.newPassword = 'Mật khẩu mới tối thiểu 8 ký tự'
  }

  if (!form.confirmPassword.trim()) {
    errors.confirmPassword = 'Vui lòng nhập lại mật khẩu mới'
  } else if (form.confirmPassword !== form.newPassword) {
    errors.confirmPassword = 'Mật khẩu nhập lại không khớp'
  }

  return !errors.currentPassword && !errors.newPassword && !errors.confirmPassword
}

const changePassword = async () => {
  if (!validate()) {
    toast.error('Vui lòng kiểm tra lại thông tin')
    return
  }

  isSaving.value = true
  try {
    await changeAdminPassword({
      currentPassword: form.currentPassword,
      newPassword: form.newPassword,
    })
    form.currentPassword = ''
    form.newPassword = ''
    form.confirmPassword = ''
    toast.success('Đổi mật khẩu thành công')
  } catch (error) {
    toast.error(error.response?.data?.message || 'Không đổi được mật khẩu')
  } finally {
    isSaving.value = false
  }
}
</script>

<template>
  <section class="mx-auto max-w-4xl space-y-6">
    <div class="rounded-2xl border border-avocado-100 bg-gradient-to-br from-avocado-50 via-white to-cream-100 p-6 shadow-sm">
      <p class="text-sm font-black uppercase tracking-[0.18em] text-avocado-600">Bảo mật tài khoản</p>
      <h2 class="mt-2 text-3xl font-black text-avocado-950">Đổi mật khẩu</h2>
      <p class="mt-2 max-w-2xl text-slate-600">
        Cập nhật mật khẩu admin qua backend Spring Boot.
      </p>
    </div>

    <div class="grid gap-6 lg:grid-cols-[260px_1fr]">
      <aside class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
        <div class="grid h-16 w-16 place-items-center rounded-2xl bg-avocado-50 text-avocado-800">
          <ShieldCheck class="h-8 w-8" />
        </div>
        <h3 class="mt-5 text-xl font-black text-avocado-950">Tăng bảo mật</h3>
        <p class="mt-2 text-sm leading-6 text-slate-600">
          Mật khẩu mới nên có ít nhất 8 ký tự và khác mật khẩu đang sử dụng.
        </p>
      </aside>

      <form class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm" novalidate @submit.prevent="changePassword">
        <div class="grid gap-5">
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            Mật khẩu hiện tại
            <span class="relative">
              <LockKeyhole class="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-avocado-700" />
              <input
                v-model="form.currentPassword"
                type="password"
                autocomplete="current-password"
                class="w-full rounded-xl border px-12 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
                :class="errors.currentPassword ? 'border-red-300 bg-red-50/40' : 'border-slate-200'"
              />
            </span>
            <span v-if="errors.currentPassword" class="text-xs font-bold text-red-600">{{ errors.currentPassword }}</span>
          </label>

          <label class="grid gap-2 text-sm font-bold text-slate-700">
            Mật khẩu mới
            <span class="relative">
              <KeyRound class="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-avocado-700" />
              <input
                v-model="form.newPassword"
                type="password"
                autocomplete="new-password"
                class="w-full rounded-xl border px-12 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
                :class="errors.newPassword ? 'border-red-300 bg-red-50/40' : 'border-slate-200'"
              />
            </span>
            <span v-if="errors.newPassword" class="text-xs font-bold text-red-600">{{ errors.newPassword }}</span>
          </label>

          <label class="grid gap-2 text-sm font-bold text-slate-700">
            Nhập lại mật khẩu mới
            <span class="relative">
              <KeyRound class="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-avocado-700" />
              <input
                v-model="form.confirmPassword"
                type="password"
                autocomplete="new-password"
                class="w-full rounded-xl border px-12 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
                :class="errors.confirmPassword ? 'border-red-300 bg-red-50/40' : 'border-slate-200'"
              />
            </span>
            <span v-if="errors.confirmPassword" class="text-xs font-bold text-red-600">{{ errors.confirmPassword }}</span>
          </label>
        </div>

        <div class="mt-8 flex justify-end">
          <button
            type="submit"
            class="rounded-xl bg-avocado-800 px-6 py-3 font-black text-white shadow-sm transition hover:bg-avocado-900 focus:outline-none focus:ring-4 focus:ring-avocado-100"
            :disabled="isSaving"
          >
            {{ isSaving ? 'Đang đổi...' : 'Đổi mật khẩu' }}
          </button>
        </div>
      </form>
    </div>
  </section>
</template>
