<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const errorMessage = ref('')

const nextLabel = computed(() => (errorMessage.value ? 'Quay lại đăng nhập' : 'Đang hoàn tất đăng nhập...'))

onMounted(() => {
  const error = route.query.error
  if (error) {
    errorMessage.value = Array.isArray(error) ? error[0] : error
    return
  }

  const token = Array.isArray(route.query.token) ? route.query.token[0] : route.query.token
  const role = Array.isArray(route.query.role) ? route.query.role[0] : route.query.role
  const userPayload = Array.isArray(route.query.user) ? route.query.user[0] : route.query.user

  if (!token || !role || !userPayload) {
    errorMessage.value = 'Không nhận được thông tin đăng nhập từ Google'
    return
  }

  let user
  try {
    user = JSON.parse(userPayload)
  } catch {
    errorMessage.value = 'Thông tin tài khoản Google không hợp lệ'
    return
  }

  if (role !== 'ADMIN') {
    errorMessage.value = 'Tài khoản Google này không có quyền quản trị'
    return
  }

  localStorage.setItem('admin_token', token)
  localStorage.setItem('admin_user', JSON.stringify(user))
  window.dispatchEvent(new Event('aloo-auth-change'))
  router.replace('/admin')
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
        to="/admin/login"
        class="mt-6 inline-flex rounded-full bg-avocado-700 px-6 py-3 text-sm font-black text-white transition hover:bg-avocado-800"
      >
        Đăng nhập lại
      </RouterLink>
    </section>
  </main>
</template>
