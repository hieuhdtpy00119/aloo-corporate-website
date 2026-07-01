<script setup>
import { computed, onBeforeUnmount, onMounted } from 'vue'
import { X } from 'lucide-vue-next'

const props = defineProps({
  show: {
    type: Boolean,
    default: false,
  },
  open: {
    type: Boolean,
    default: false,
  },
  title: {
    type: String,
    required: true,
  },
  maxWidth: {
    type: String,
    default: 'max-w-2xl',
  },
})

const emit = defineEmits(['close'])
const isVisible = computed(() => props.show || props.open)

const handleKeydown = (event) => {
  if (event.key === 'Escape' && isVisible.value) {
    emit('close')
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<template>
  <Teleport to="body">
    <div v-if="isVisible" class="fixed inset-0 z-50 grid place-items-center bg-slate-950/40 px-3 py-4 backdrop-blur-sm sm:px-4 sm:py-6" @click.self="$emit('close')">
      <section :class="['flex max-h-[92vh] w-full flex-col overflow-hidden rounded-2xl border border-slate-100 bg-white shadow-2xl sm:max-h-[90vh] sm:rounded-[2rem]', maxWidth]">
        <header class="flex shrink-0 items-center justify-between gap-4 border-b border-slate-100 px-5 py-4 sm:px-8 sm:py-5">
          <h2 class="min-w-0 truncate text-sm font-bold tracking-tight text-avocado-950 sm:text-base">{{ title }}</h2>
          <button class="rounded-xl p-2 text-slate-400 hover:bg-slate-50 hover:text-slate-700 transition" type="button" @click="$emit('close')">
            <X class="h-5 w-5" />
          </button>
        </header>
        <div class="flex-1 overflow-y-auto px-5 py-5 sm:px-8 sm:py-6">
          <slot />
        </div>
        <footer v-if="$slots.footer" class="shrink-0 border-t border-slate-100 bg-slate-50/50 px-5 py-4 sm:px-8 sm:py-5">
          <slot name="footer" />
        </footer>
      </section>
    </div>
  </Teleport>
</template>
