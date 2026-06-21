<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { refreshAuthProfile, setAuthProvider } from '../../services/authService'
import { decodeBase64JsonUtf8 } from '../../utils/textEncoding'

const route = useRoute()
const router = useRouter()
const errorMessage = ref('')

const nextLabel = computed(() => (errorMessage.value ? 'Quay lại đăng nhập' : 'Đang hoàn tất đăng nhập...'))

const decodeUserPayload = (payload) => {
  if (!payload) return null

  try {
    return JSON.parse(payload)
  } catch {
    // Backward compatible with older redirects that sent raw JSON.
  }

  return decodeBase64JsonUtf8(payload)
}

onMounted(async () => {
  const error = route.query.error
  if (error) {
    errorMessage.value = Array.isArray(error) ? error[0] : error
    return
  }

  const token = Array.isArray(route.query.token) ? route.query.token[0] : route.query.token

  if (!token) {
    errorMessage.value = 'Không nhận được thông tin đăng nhập từ Google'
    return
  }

  localStorage.setItem('admin_token', token)
  setAuthProvider('google')

  try {
    const profile = await refreshAuthProfile()
    router.replace(profile.role === 'ADMIN' ? '/admin' : '/')
    return
  } catch {
    const userPayload = Array.isArray(route.query.user) ? route.query.user[0] : route.query.user
    const user = decodeUserPayload(userPayload)

    if (!user) {
      errorMessage.value = 'Không tải được hồ sơ tài khoản sau đăng nhập Google'
      return
    }

    localStorage.setItem('admin_user', JSON.stringify(user))
    window.dispatchEvent(new Event('aloo-auth-change'))
    router.replace(user.role === 'ADMIN' ? '/admin' : '/')
  }
})
</script>

<template>
  <main class="grid min-h-screen place-items-center bg-avocado-50 px-4">
    <section class="w-full max-w-md rounded-2xl border border-avocado-100 bg-white p-8 text-center shadow-sm">
      <img src="/logo-aloo.png" alt="ALOO Kem Bơ" class="mx-auto h-12 w-auto object-contain" width="200" height="48" />
      <h1 class="mt-6 text-2xl font-black text-avocado-950">{{ nextLabel }}</h1>
      <p v-if="errorMessage" class="mt-4 rounded-xl bg-red-50 px-4 py-3 text-sm font-bold text-red-700">
        {{ errorMessage }}
      </p>
      <RouterLink
        v-if="errorMessage"
        to="/login"
        class="mt-6 inline-flex rounded-full bg-avocado-700 px-6 py-3 text-sm font-black text-white transition hover:bg-avocado-800"
      >
        Đăng nhập lại
      </RouterLink>
    </section>
  </main>
</template>
