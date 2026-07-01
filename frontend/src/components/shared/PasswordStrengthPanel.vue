<script setup>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { Check, X } from 'lucide-vue-next'
import { getPasswordRequirements, getPasswordStrength } from '../../utils/passwordPolicy'

const props = defineProps({
  password: {
    type: String,
    default: '',
  },
})

const { t } = useI18n()

const requirements = computed(() => getPasswordRequirements(props.password))
const strength = computed(() => getPasswordStrength(props.password))

const requirementItems = computed(() => [
  { key: 'minLength', met: requirements.value.minLength },
  { key: 'upperCase', met: requirements.value.upperCase },
  { key: 'lowerCase', met: requirements.value.lowerCase },
  { key: 'number', met: requirements.value.number },
  { key: 'special', met: requirements.value.special },
])

const strengthLabel = computed(() => {
  if (strength.value === 'empty') return ''
  return t(`admin.password.strength.${strength.value}`)
})

const strengthWidth = computed(() => {
  if (strength.value === 'empty') return '0%'
  if (strength.value === 'weak') return '33%'
  if (strength.value === 'medium') return '66%'
  return '100%'
})

const strengthClass = computed(() => {
  if (strength.value === 'weak') return 'is-weak'
  if (strength.value === 'medium') return 'is-medium'
  if (strength.value === 'strong') return 'is-strong'
  return ''
})
</script>

<template>
  <div class="password-strength-panel">
    <div v-if="password" class="password-strength-panel__meter">
      <div class="password-strength-panel__track">
        <div
          class="password-strength-panel__bar"
          :class="strengthClass"
          :style="{ width: strengthWidth }"
        />
      </div>
      <p class="password-strength-panel__label" :class="strengthClass">{{ strengthLabel }}</p>
    </div>

    <ul class="password-strength-panel__list">
      <li
        v-for="item in requirementItems"
        :key="item.key"
        :class="item.met ? 'is-met' : 'is-unmet'"
      >
        <Check v-if="item.met" class="h-3.5 w-3.5" />
        <X v-else class="h-3.5 w-3.5" />
        <span>{{ t(`admin.password.requirements.${item.key}`) }}</span>
      </li>
    </ul>
  </div>
</template>

<style scoped>
.password-strength-panel {
  display: grid;
  gap: 10px;
}

.password-strength-panel__meter {
  display: grid;
  gap: 6px;
}

.password-strength-panel__track {
  height: 6px;
  overflow: hidden;
  border-radius: 999px;
  background: #eef2ee;
}

.password-strength-panel__bar {
  height: 100%;
  border-radius: inherit;
  transition: width 0.2s ease, background-color 0.2s ease;
}

.password-strength-panel__bar.is-weak {
  background: #ef4444;
}

.password-strength-panel__bar.is-medium {
  background: #f59e0b;
}

.password-strength-panel__bar.is-strong {
  background: #007a35;
}

.password-strength-panel__label {
  margin: 0;
  font-size: 12px;
  font-weight: 700;
}

.password-strength-panel__label.is-weak {
  color: #dc2626;
}

.password-strength-panel__label.is-medium {
  color: #d97706;
}

.password-strength-panel__label.is-strong {
  color: #007a35;
}

.password-strength-panel__list {
  margin: 0;
  padding: 0;
  list-style: none;
  display: grid;
  gap: 6px;
}

.password-strength-panel__list li {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  font-weight: 600;
}

.password-strength-panel__list li.is-met {
  color: #007a35;
}

.password-strength-panel__list li.is-unmet {
  color: #64748b;
}
</style>
