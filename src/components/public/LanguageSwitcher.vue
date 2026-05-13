<script setup>
import { useI18n } from 'vue-i18n'

const { locale } = useI18n()

const changeLocale = (value) => {
  locale.value = value
  localStorage.setItem('aloo_locale', value)
}
</script>

<template>
  <div class="inline-flex rounded-full border border-avocado-200 bg-white p-1 shadow-sm">
    <button
      type="button"
      class="rounded-full px-3 py-1.5 text-xs font-black transition"
      :class="locale === 'vi' ? 'bg-avocado-700 text-white' : 'text-avocado-700 hover:bg-avocado-50'"
      @click="changeLocale('vi')"
    >
      VI
    </button>
    <button
      type="button"
      class="rounded-full px-3 py-1.5 text-xs font-black transition"
      :class="locale === 'en' ? 'bg-avocado-700 text-white' : 'text-avocado-700 hover:bg-avocado-50'"
      @click="changeLocale('en')"
    >
      EN
    </button>
  </div>
</template>
