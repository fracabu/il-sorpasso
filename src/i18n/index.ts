import { createI18n } from 'vue-i18n'
import en from './locales/en.json'
import it from './locales/it.json'

// Get the saved locale or default to 'it'
const savedLocale = localStorage.getItem('preferred-locale') || 'it'

export const i18n = createI18n({
  legacy: false,
  locale: savedLocale,
  fallbackLocale: 'it',
  messages: {
    en,
    it
  },
  globalInjection: true,
  sync: true,
  silentTranslationWarn: true,
  missingWarn: false,
  fallbackWarn: false
})

// Set initial document language
document.documentElement.lang = savedLocale