<script setup>
import { onMounted } from 'vue'
import AdminSidebar from '../components/admin/AdminSidebar.vue'
import AdminTopbar from '../components/admin/AdminTopbar.vue'
import { useAppStore } from '../stores/appStore'

const store = useAppStore()

onMounted(() => {
  store.fetchAdminData()
})
</script>

<template>
  <div class="min-h-screen w-full bg-slate-50">
    <AdminSidebar />
    <div class="min-h-screen min-w-0 lg:ml-72">
      <AdminTopbar />
      <main class="min-w-0 flex-1 p-4 sm:p-6 lg:p-8">
        <RouterView />
      </main>
    </div>
  </div>
</template>
