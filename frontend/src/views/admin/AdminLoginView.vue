<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { loginAdmin } from '../../services/authService'
import { Chrome, Lock, Mail, ArrowLeft, ShieldAlert } from 'lucide-vue-next'
import { googleLoginUrl } from '../../services/oauthService'

const router = useRouter()
const email = ref('admin@aloo.vn')
const password = ref('')
const errorMessage = ref('')
const isSubmitting = ref(false)

const handleGoogleLogin = () => {
  window.location.assign(googleLoginUrl())
}

const handleLogin = async () => {
  if (isSubmitting.value) return

  errorMessage.value = ''
  isSubmitting.value = true

  try {
    const { data } = await loginAdmin({
      email: email.value,
      password: password.value,
    })

    localStorage.setItem('admin_token', data.token)
    localStorage.setItem('admin_user', JSON.stringify(data.user))
    window.dispatchEvent(new Event('aloo-auth-change'))
    router.push('/admin')
  } catch (error) {
    errorMessage.value = error.response?.data?.message || 'Sai tài khoản hoặc mật khẩu'
  } finally {
    isSubmitting.value = false
  }
}
</script>

<template>
  <main class="grid min-h-screen place-items-center bg-[#faf8f2] px-4 relative overflow-hidden">
    <!-- Visual background blobs -->
    <div class="absolute -left-20 -top-20 w-96 h-96 bg-avocado-200/20 rounded-full blur-3xl pointer-events-none"></div>
    <div class="absolute -right-20 -bottom-20 w-96 h-96 bg-cream-300/30 rounded-full blur-3xl pointer-events-none"></div>

    <div class="w-full max-w-md relative z-10">
      <!-- Back button -->
      <RouterLink 
        to="/" 
        class="inline-flex items-center gap-1.5 text-xs font-bold uppercase tracking-wider text-avocado-800 hover:text-avocado-950 mb-6 transition"
      >
        <ArrowLeft class="h-4 w-4" />
        Quay lại Trang chủ
      </RouterLink>

      <form class="rounded-[2rem] bg-white p-8 sm:p-10 shadow-xl border border-avocado-100/20" @submit.prevent="handleLogin">
        <!-- Logo -->
        <div class="flex items-center gap-2 mb-6">
          <div class="h-9 w-9 bg-cream-400 text-avocado-950 font-black rounded-xl grid place-items-center text-sm shadow-md">
            A
          </div>
          <div>
            <div class="text-xl font-bold tracking-tight text-avocado-950">ALOO Admin</div>
            <p class="text-[10px] uppercase font-bold tracking-widest text-slate-400">Đăng nhập hệ thống</p>
          </div>
        </div>

        <h1 class="text-2xl font-black text-avocado-950 leading-tight">Đăng Nhập CMS</h1>
        <p class="mt-2 text-xs leading-relaxed text-slate-400">
          Hãy nhập tài khoản quản trị để truy cập trang quản lý thương hiệu & sản phẩm ALOO.
        </p>

        <!-- Error panel -->
        <div v-if="errorMessage" class="mt-5 rounded-2xl bg-red-50 border border-red-200/50 px-4 py-3 text-xs font-bold text-red-700 flex items-center gap-2">
          <ShieldAlert class="h-4 w-4 shrink-0 text-red-600" />
          <span>{{ errorMessage }}</span>
        </div>

        <div class="mt-8 space-y-5">
          <button
            type="button"
            class="flex w-full items-center justify-center gap-2 rounded-full border border-slate-100 bg-white px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-700 transition hover:border-avocado-200 hover:bg-avocado-50"
            @click="handleGoogleLogin"
          >
            <Chrome class="h-4.5 w-4.5 text-avocado-700" />
            Đăng nhập bằng Google
          </button>

          <div class="flex items-center gap-3 text-[10px] font-bold uppercase tracking-widest text-slate-300">
            <span class="h-px flex-1 bg-slate-100"></span>
            hoặc
            <span class="h-px flex-1 bg-slate-100"></span>
          </div>

          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Email
            <div class="relative">
              <Mail class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 h-4.5 w-4.5" />
              <input v-model="email" type="email" required class="w-full rounded-2xl border border-slate-100 bg-slate-50/50 pl-11 pr-4 py-3.5 text-sm font-semibold text-slate-800 outline-none focus:bg-white focus:border-avocado-500 focus:ring-2 focus:ring-avocado-100 transition" />
            </div>
          </label>

          <label class="grid gap-2 text-xs font-bold uppercase tracking-wider text-slate-500">
            Mật khẩu
            <div class="relative">
              <Lock class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 h-4.5 w-4.5" />
              <input v-model="password" type="password" required class="w-full rounded-2xl border border-slate-100 bg-slate-50/50 pl-11 pr-4 py-3.5 text-sm font-semibold text-slate-800 outline-none focus:bg-white focus:border-avocado-500 focus:ring-2 focus:ring-avocado-100 transition" />
            </div>
          </label>

          <div class="pt-2">
            <button 
              class="w-full rounded-full bg-avocado-600 px-6 py-4 text-xs font-bold uppercase tracking-wider text-white hover:bg-avocado-700 transition duration-300 disabled:cursor-not-allowed disabled:opacity-60 flex items-center justify-center gap-2 shadow-lg shadow-avocado-600/10" 
              :disabled="isSubmitting"
            >
              {{ isSubmitting ? 'Đang xác thực...' : 'Xác thực tài khoản' }}
            </button>
          </div>
        </div>
      </form>
    </div>
  </main>
</template>
