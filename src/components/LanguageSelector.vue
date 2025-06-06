<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import { ref, watch } from 'vue'

const languages = [
  { code: 'it', name: 'Italiano', flag: '🇮🇹' },
  { code: 'en', name: 'English', flag: '🇬🇧' }
]

const { locale } = useI18n()
const isOpen = ref(false)

const toggleDropdown = () => {
  isOpen.value = !isOpen.value
}

const changeLanguage = (langCode: string) => {
  locale.value = langCode
  localStorage.setItem('preferred-locale', langCode)
  isOpen.value = false
}

// Watch for locale changes
watch(locale, (newLocale) => {
  document.documentElement.lang = newLocale
})
</script>

<template>
  <div class="relative">
    <button
      @click="toggleDropdown"
      class="flex items-center space-x-2 text-white hover:text-accent transition-colors"
    >
      <span class="text-lg">{{ languages.find(l => l.code === locale)?.flag }}</span>
      <i class="fas fa-chevron-down text-xs"></i>
    </button>

    <div
      v-if="isOpen"
      class="absolute right-0 mt-2 w-40 rounded-lg bg-zinc-900 shadow-lg ring-1 ring-black ring-opacity-5 z-50"
    >
      <div class="py-1">
        <button
          v-for="lang in languages"
          :key="lang.code"
          @click="changeLanguage(lang.code)"
          class="flex items-center space-x-3 w-full px-4 py-2 text-sm text-white hover:bg-zinc-800"
          :class="{ 'bg-zinc-800': locale === lang.code }"
        >
          <span class="text-lg">{{ lang.flag }}</span>
          <span>{{ lang.name }}</span>
        </button>
      </div>
    </div>
  </div>
</template>