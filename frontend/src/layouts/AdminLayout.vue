<script setup>
import { onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useI18n } from 'vue-i18n'
import AdminSidebar from '../components/admin/AdminSidebar.vue'
import AdminTopbar from '../components/admin/AdminTopbar.vue'
import { useAppStore } from '../stores/appStore'
import { useToastStore } from '../stores/toastStore'

const store = useAppStore()
const toast = useToastStore()
const route = useRoute()
const { t } = useI18n()
const isSidebarOpen = ref(false)

onMounted(() => {
  store.fetchAdminData()
})

watch(
  () => route.query.denied,
  (deniedPath) => {
    if (!deniedPath) return
    toast.error(t('admin.accessDenied'))
  },
  { immediate: true },
)
</script>

<template>
  <div class="aloo-admin-shell min-h-screen w-full bg-slate-50">
    <AdminSidebar :mobile-open="isSidebarOpen" @navigate="isSidebarOpen = false" />
    <div
      v-if="isSidebarOpen"
      class="fixed inset-0 z-40 bg-slate-950/50 backdrop-blur-sm lg:hidden"
      @click="isSidebarOpen = false"
    />
    <div class="min-h-screen min-w-0 lg:ml-72">
      <AdminTopbar @toggle-sidebar="isSidebarOpen = true" />
      <main class="min-w-0 flex-1 p-4 sm:p-6 lg:p-8">
        <RouterView class="aloo-admin-page pb-10" />
      </main>
    </div>
  </div>
</template>
