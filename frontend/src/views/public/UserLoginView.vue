<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { LogIn, ShieldCheck, UserRound } from 'lucide-vue-next'
import { loginAdmin } from '../../services/authService'
import { loginUser } from '../../services/userAuthService'

const router = useRouter()
const email = ref('user@aloo.vn')
const password = ref('123456')
const errorMessage = ref('')
const isSubmitting = ref(false)

const validateLogin = () => {
  const normalizedEmail = email.value.trim().toLowerCase()
  if (!normalizedEmail) {
    errorMessage.value = 'Vui lòng nhập email'
    return false
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail)) {
    errorMessage.value = 'Email không đúng định dạng'
    return false
  }
  if (!password.value) {
    errorMessage.value = 'Vui lòng nhập mật khẩu'
    return false
  }
  if (password.value.length < 6) {
    errorMessage.value = 'Mật khẩu tối thiểu 6 ký tự'
    return false
  }
  return true
}

const loginAsAdmin = async () => {
  const { data } = await loginAdmin({
    email: email.value,
    password: password.value,
  })

  localStorage.setItem('admin_token', data.token)
  localStorage.setItem('admin_user', JSON.stringify(data.user))
  window.dispatchEvent(new Event('aloo-auth-change'))
  router.push('/admin')
}

const loginAsUser = async () => {
  const { data } = await loginUser({
    email: email.value,
    password: password.value,
  })

  localStorage.setItem('user_token', data.token)
  localStorage.setItem('user_user', JSON.stringify(data.user))
  localStorage.setItem('user_role', data.user?.role || 'USER')
  window.dispatchEvent(new Event('aloo-auth-change'))
  router.push('/profile')
}

const handleLogin = async () => {
  if (isSubmitting.value) return

  errorMessage.value = ''
  if (!validateLogin()) return

  isSubmitting.value = true
  try {
    if (email.value.trim().toLowerCase() === 'admin@aloo.vn') {
      await loginAsAdmin()
    } else {
      await loginAsUser()
    }
  } catch (error) {
    errorMessage.value = error.response?.data?.message || 'Sai tài khoản hoặc mật khẩu'
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <main class="bg-avocado-50 px-4 py-12 sm:px-5 lg:px-6">
    <section class="mx-auto grid min-h-[68vh] max-w-5xl items-center gap-6 lg:grid-cols-[0.9fr_1.1fr]">
      <aside class="rounded-2xl border border-avocado-100 bg-gradient-to-br from-white via-avocado-50 to-cream-100 p-7 shadow-sm">
        <div class="grid h-16 w-16 place-items-center rounded-2xl bg-white text-avocado-800 shadow-sm">
          <UserRound class="h-8 w-8" />
        </div>
        <p class="mt-6 text-sm font-black uppercase tracking-[0.18em] text-avocado-600">Tài khoản ALOO</p>
        <h1 class="mt-2 text-3xl font-black text-avocado-950">Đăng nhập</h1>
        <p class="mt-3 leading-7 text-slate-600">
          Đăng nhập tài khoản khách hàng hoặc tài khoản quản trị qua backend.
        </p>
        <div class="mt-6 rounded-xl bg-white/80 p-4 text-sm font-bold text-slate-600">
          <div class="flex items-center gap-2 text-avocado-800">
            <ShieldCheck class="h-4 w-4" />
            <span>Tài khoản demo</span>
          </div>
          <p class="mt-2">Email: user@aloo.vn</p>
          <p>Mật khẩu: 123456</p>
          <div class="my-3 border-t border-avocado-100"></div>
          <p>Email admin: admin@aloo.vn</p>
          <p>Mật khẩu admin: 123456</p>
        </div>
      </aside>

      <form class="rounded-2xl border border-avocado-100 bg-white p-7 shadow-sm" @submit.prevent="handleLogin">
        <RouterLink to="/" class="inline-flex outline-none ring-avocado-400 focus-visible:ring-2 focus-visible:ring-offset-2">
          <img src="/logo-aloo.png" alt="ALOO Kem Bơ" class="h-12 w-auto object-contain" width="200" height="48" />
        </RouterLink>

        <h2 class="mt-6 text-2xl font-black text-avocado-950">Đăng nhập</h2>
        <p class="mt-2 text-slate-600">User sẽ vào trang cá nhân, admin sẽ vào CMS.</p>

        <p v-if="errorMessage" class="mt-5 rounded-xl bg-red-50 px-4 py-3 text-sm font-bold text-red-700">
          {{ errorMessage }}
        </p>

        <div class="mt-7 grid gap-5">
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            Email
            <input v-model.trim="email" type="email" required class="rounded-xl border border-slate-200 px-4 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" />
          </label>
          <label class="grid gap-2 text-sm font-bold text-slate-700">
            Mật khẩu
            <input v-model="password" type="password" required minlength="6" class="rounded-xl border border-slate-200 px-4 py-3 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100" />
          </label>
          <button class="inline-flex items-center justify-center gap-2 rounded-xl bg-avocado-800 px-6 py-3 font-black text-white transition hover:bg-avocado-900 disabled:cursor-not-allowed disabled:opacity-60" :disabled="isSubmitting">
            <LogIn class="h-5 w-5" />
            {{ isSubmitting ? 'Đang đăng nhập...' : 'Đăng nhập' }}
          </button>
        </div>
      </form>
    </section>
  </main>
</template>
