<script setup>
import { computed, ref } from 'vue'
import { Eye, EyeOff } from 'lucide-vue-next'

const props = defineProps({
  modelValue: {
    type: String,
    default: '',
  },
  label: {
    type: String,
    required: true,
  },
  error: {
    type: String,
    default: '',
  },
  autocomplete: {
    type: String,
    default: 'current-password',
  },
  inputId: {
    type: String,
    default: '',
  },
})

const emit = defineEmits(['update:modelValue'])

const visible = ref(false)

const inputType = computed(() => (visible.value ? 'text' : 'password'))

const toggleVisible = () => {
  visible.value = !visible.value
}
</script>

<template>
  <label class="grid gap-2 text-sm font-bold text-slate-700">
    {{ label }}
    <span class="relative block">
      <slot name="icon" />
      <input
        :id="inputId"
        :value="modelValue"
        :type="inputType"
        :autocomplete="autocomplete"
        class="w-full rounded-xl border py-3 pl-12 pr-12 outline-none transition focus:border-avocado-500 focus:ring-4 focus:ring-avocado-100"
        :class="error ? 'border-red-300 bg-red-50/40' : 'border-slate-200'"
        @input="emit('update:modelValue', $event.target.value)"
      />
      <button
        type="button"
        class="absolute right-3 top-1/2 grid h-8 w-8 -translate-y-1/2 place-items-center rounded-lg text-slate-500 transition hover:bg-slate-100 hover:text-avocado-800"
        :aria-label="visible ? 'Ẩn mật khẩu' : 'Hiện mật khẩu'"
        @click="toggleVisible"
      >
        <EyeOff v-if="visible" class="h-4 w-4" />
        <Eye v-else class="h-4 w-4" />
      </button>
    </span>
    <span v-if="error" class="text-xs font-bold text-red-600">{{ error }}</span>
  </label>
</template>
