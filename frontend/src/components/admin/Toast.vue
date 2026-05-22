<script setup>
import { useToastStore } from '../../stores/toastStore'

const toastStore = useToastStore()
</script>

<template>
  <div class="fixed right-4 top-4 z-[60] grid w-[min(360px,calc(100vw-2rem))] gap-3">
    <div
      v-for="toast in toastStore.toasts"
      :key="toast.id"
      class="flex items-start justify-between gap-4 rounded-xl border px-4 py-3 shadow-lg"
      :class="
        toast.type === 'error'
          ? 'border-red-200 bg-red-50 text-red-800'
          : 'border-green-200 bg-green-50 text-green-800'
      "
    >
      <p class="text-sm font-bold">{{ toast.message }}</p>
      <button class="text-sm font-black" type="button" @click="toastStore.remove(toast.id)">×</button>
    </div>
  </div>
</template>
