<script setup>
import AdminSidebar from '../components/admin/AdminSidebar.vue'
import AdminTopbar from '../components/admin/AdminTopbar.vue'
import Toast from '../components/admin/Toast.vue'
</script>

<template>
  <div class="min-h-screen bg-slate-50 lg:flex">
    <AdminSidebar />
    <div class="min-w-0 flex-1">
      <AdminTopbar />
      <main class="p-4 sm:p-6 lg:p-8">
        <RouterView />
      </main>
    </div>
    <Toast />
  </div>
</template>
