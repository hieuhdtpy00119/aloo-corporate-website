<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const email = ref('admin@aloo.vn')
const password = ref('123456')
const errorMessage = ref('')

const handleLogin = () => {
  if (email.value === 'admin@aloo.vn' && password.value === '123456') {
    localStorage.setItem('admin_token', 'demo-token')
    router.push('/admin')
  } else {
    errorMessage.value = 'Sai tai khoan hoac mat khau'
  }
}
</script>

<template>
  <main class="grid min-h-screen place-items-center bg-avocado-50 px-4">
    <form class="w-full max-w-md rounded-lg bg-white p-8 shadow-xl" @submit.prevent="handleLogin">
      <RouterLink to="/" class="text-sm font-bold text-avocado-700">Ve website</RouterLink>
      <h1 class="mt-6 text-3xl font-black text-avocado-950">Dang nhap Admin</h1>
      <p class="mt-2 text-slate-600">Man hinh dang nhap demo cho phan quan tri ALOO.</p>
      <p v-if="errorMessage" class="mt-5 rounded-lg bg-red-50 px-4 py-3 text-sm font-bold text-red-700">
        {{ errorMessage }}
      </p>
      <div class="mt-8 grid gap-5">
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Email
          <input v-model="email" type="email" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <label class="grid gap-2 text-sm font-bold text-slate-700">
          Mat khau
          <input v-model="password" type="password" class="rounded-lg border border-slate-200 px-4 py-3 outline-none focus:border-avocado-500" />
        </label>
        <button class="rounded-full bg-avocado-700 px-6 py-3 font-black text-white hover:bg-avocado-800">Dang nhap</button>
      </div>
    </form>
  </main>
</template>
