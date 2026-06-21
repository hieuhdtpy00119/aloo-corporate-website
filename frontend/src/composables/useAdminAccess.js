import { computed, onMounted, onUnmounted, ref } from 'vue'
import { ADMIN_SCOPES, canAccessAdminSession } from '../utils/adminAccess'

export const useAdminAccess = () => {
  const permissions = ref(canAccessAdminSession())

  const refreshPermissions = () => {
    permissions.value = canAccessAdminSession()
  }

  onMounted(() => {
    window.addEventListener('aloo-auth-change', refreshPermissions)
  })

  onUnmounted(() => {
    window.removeEventListener('aloo-auth-change', refreshPermissions)
  })

  const can = (scope) => computed(() => Boolean(permissions.value[scope]))

  return {
    permissions,
    can,
    scopes: ADMIN_SCOPES,
    refreshPermissions,
  }
}
