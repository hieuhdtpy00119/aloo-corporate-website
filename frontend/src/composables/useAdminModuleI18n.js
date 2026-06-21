import { useI18n } from 'vue-i18n'

export const useAdminModuleI18n = (moduleKey) => {
  const { t } = useI18n()

  const m = (suffix, params) => t(`admin.${moduleKey}.${suffix}`, params)

  return { t, m }
}
