import { defineStore } from 'pinia'

export const useToastStore = defineStore('toast', {
  state: () => ({
    toasts: [],
  }),
  actions: {
    success(message) {
      const id = Date.now()
      this.toasts.push({ id, message, type: 'success' })
      window.setTimeout(() => {
        this.toasts = this.toasts.filter((toast) => toast.id !== id)
      }, 2600)
    },
    remove(id) {
      this.toasts = this.toasts.filter((toast) => toast.id !== id)
    },
  },
})
