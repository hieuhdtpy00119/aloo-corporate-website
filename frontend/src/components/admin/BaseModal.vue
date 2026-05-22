<script setup>
import { onBeforeUnmount, onMounted } from 'vue'
import { X } from 'lucide-vue-next'

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
    <div v-if="show" class="fixed inset-0 z-50 grid place-items-center bg-slate-950/40 backdrop-blur-sm px-4 py-6" @click.self="$emit('close')">
      <section :class="['flex max-h-[90vh] w-full flex-col overflow-hidden rounded-[2rem] bg-white shadow-2xl border border-slate-100', maxWidth]">
        <header class="shrink-0 flex items-center justify-between gap-4 border-b border-slate-100 px-8 py-5">
          <h2 class="text-lg font-black text-avocado-950 tracking-tight">{{ title }}</h2>
          <button class="rounded-xl p-2 text-slate-400 hover:bg-slate-50 hover:text-slate-700 transition" type="button" @click="$emit('close')">
            <X class="h-5 w-5" />
          </button>
        </header>
        <div class="flex-1 overflow-y-auto px-8 py-6">
          <slot />
        </div>
        <footer v-if="$slots.footer" class="shrink-0 bg-slate-50/50 border-t border-slate-100 px-8 py-5">
          <slot name="footer" />
        </footer>
      </section>
    </div>
  </Teleport>
</template>

