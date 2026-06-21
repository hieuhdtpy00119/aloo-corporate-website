import { createI18n } from 'vue-i18n'
import vi from '../locales/vi.json'
import en from '../locales/en.json'
import adminViewsVi from '../locales/admin-views-vi.json'
import adminViewsEn from '../locales/admin-views-en.json'

const supportedLocales = ['vi', 'en']
const savedLocale = localStorage.getItem('aloo_locale')
const defaultLocale = supportedLocales.includes(savedLocale) ? savedLocale : 'vi'

const mergeAdminViews = (baseLocale, adminViews) => ({
  ...baseLocale,
  admin: {
    ...baseLocale.admin,
    ...adminViews,
  },
})

const i18n = createI18n({
  legacy: false,
  globalInjection: true,
  locale: defaultLocale,
  fallbackLocale: 'vi',
  messages: {
    vi: mergeAdminViews(vi, adminViewsVi),
    en: mergeAdminViews(en, adminViewsEn),
  },
})

export default i18n
