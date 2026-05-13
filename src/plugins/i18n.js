import { createI18n } from 'vue-i18n'
import vi from '../locales/vi.json'
import en from '../locales/en.json'

const supportedLocales = ['vi', 'en']
const savedLocale = localStorage.getItem('aloo_locale')
const defaultLocale = supportedLocales.includes(savedLocale) ? savedLocale : 'vi'

const i18n = createI18n({
  legacy: false,
  globalInjection: true,
  locale: defaultLocale,
  fallbackLocale: 'vi',
  messages: {
    vi,
    en,
  },
})

export default i18n
