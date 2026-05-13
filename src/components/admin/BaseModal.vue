<script setup>
import { onBeforeUnmount, onMounted } from 'vue'

const props = defineProps({
  show: {
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

const handleKeydown = (event) => {
  if (event.key === 'Escape' && props.show) {
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
    <div v-if="show" class="fixed inset-0 z-50 grid place-items-center bg-slate-950/50 px-4 py-6" @click.self="$emit('close')">
      <section :class="['max-h-[90vh] w-full overflow-y-auto rounded-xl bg-white shadow-2xl', maxWidth]">
        <header class="flex items-center justify-between gap-4 border-b border-slate-200 px-6 py-4">
          <h2 class="text-xl font-black text-avocado-950">{{ title }}</h2>
          <button class="rounded-lg px-3 py-2 text-xl font-black text-slate-500 hover:bg-slate-100" type="button" @click="$emit('close')">
            ×
          </button>
        </header>
        <div class="px-6 py-5">
          <slot />
        </div>
        <footer v-if="$slots.footer" class="border-t border-slate-200 px-6 py-4">
          <slot name="footer" />
        </footer>
      </section>
    </div>
  </Teleport>
</template>
