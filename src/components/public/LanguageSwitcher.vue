<script setup>
import { useI18n } from 'vue-i18n'

const { locale } = useI18n()

const changeLocale = (value) => {
  locale.value = value
  localStorage.setItem('aloo_locale', value)
}
</script>

<template>
  <div class="inline-flex rounded-full bg-avocado-50/80 p-0.5 ring-1 ring-avocado-950/10">
    <button
      type="button"
      class="rounded-full px-2.5 py-1.5 text-[11px] font-black transition"
      :class="locale === 'vi' ? 'bg-white text-avocado-900 shadow-sm' : 'text-avocado-700 hover:text-avocado-950'"
      @click="changeLocale('vi')"
    >
      VI
    </button>
    <button
      type="button"
      class="rounded-full px-2.5 py-1.5 text-[11px] font-black transition"
      :class="locale === 'en' ? 'bg-white text-avocado-900 shadow-sm' : 'text-avocado-700 hover:text-avocado-950'"
      @click="changeLocale('en')"
    >
      EN
    </button>
  </div>
</template>
