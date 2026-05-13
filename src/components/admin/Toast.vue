<script setup>
import { useToastStore } from '../../stores/toastStore'

const toastStore = useToastStore()
</script>

<template>
  <div class="fixed right-4 top-4 z-[60] grid w-[min(360px,calc(100vw-2rem))] gap-3">
    <div
      v-for="toast in toastStore.toasts"
      :key="toast.id"
      class="flex items-start justify-between gap-4 rounded-xl border border-green-200 bg-green-50 px-4 py-3 text-green-800 shadow-lg"
    >
      <p class="text-sm font-bold">{{ toast.message }}</p>
      <button class="text-sm font-black text-green-700" type="button" @click="toastStore.remove(toast.id)">×</button>
    </div>
  </div>
</template>
