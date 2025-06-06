<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import LanguageSelector from './LanguageSelector.vue'

const router = useRouter()
const { t } = useI18n()

const isMenuOpen = ref(false)
const isScrolled = ref(false)

const goToHome = async () => {
  if (router.currentRoute.value.path !== '/') {
    await router.push('/')
  } else {
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
}

const toggleMenu = () => {
  isMenuOpen.value = !isMenuOpen.value
}

const handleScroll = () => {
  isScrolled.value = window.scrollY > 0
}

const scrollToSection = async (href: string) => {
  if (href.startsWith('#')) {
    if (router.currentRoute.value.path !== '/') {
      await router.push('/')
      // Wait for the DOM to update after route change
      await new Promise(resolve => setTimeout(resolve, 100))
    }
    
    const element = document.querySelector(href)
    if (element) {
      // Get the header height
      const headerHeight = 80

      // Get the viewport height
      const viewportHeight = window.innerHeight

      // Get the element's dimensions
      const elementRect = element.getBoundingClientRect()
      const elementHeight = elementRect.height

      // Calculate the ideal scroll position to center the element
      let scrollPosition
      
      if (elementHeight >= viewportHeight) {
        // If the element is taller than the viewport, align its top with the header
        scrollPosition = element.offsetTop - headerHeight
      } else {
        // Center the element in the viewport, accounting for header
        scrollPosition = element.offsetTop - ((viewportHeight - elementHeight) / 2) - headerHeight
      }

      // Ensure we don't scroll past the element
      const maxScroll = document.documentElement.scrollHeight - viewportHeight
      scrollPosition = Math.min(scrollPosition, maxScroll)
      
      // Ensure we don't scroll above the top
      scrollPosition = Math.max(0, scrollPosition)

      window.scrollTo({
        top: scrollPosition,
        behavior: 'smooth'
      })
    }
  }
}

const handleMobileNavClick = (href: string) => {
  isMenuOpen.value = false
  scrollToSection(href)
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})

const socialLinks = [
  { icon: 'facebook', url: 'https://www.facebook.com/IlSorpassodiLorenzoBasile', label: 'Facebook' },
  { icon: 'instagram', url: 'https://www.instagram.com/ilsorpassodilorenzobasile/', label: 'Instagram' },
  { icon: 'linkedin', url: '#', label: 'LinkedIn' }
]

// Make headerLinks a computed property so it updates when the language changes
const headerLinks = computed(() => [
  { text: t('nav.about'), href: '#chi-siamo' },
  { text: t('nav.services'), href: '#servizi' },
  { text: t('nav.tour'), href: '#tour' },
  { text: t('nav.why'), href: '#perche-noi' },
  { text: t('nav.contact'), href: '#contattaci' }
])
</script>

<template>
  <header 
    class="fixed top-0 left-0 right-0 z-50 transition-all duration-300"
    :class="[
      isScrolled ? 'bg-black/90 backdrop-blur-sm border-b border-accent' : 'bg-transparent',
      isMenuOpen ? 'bg-black' : ''
    ]"
  >
    <div class="container">
      <nav class="flex items-center justify-between h-40 md:h-44">
        <!-- Logo -->
        <button 
          @click="goToHome"
          class="flex items-center hover:opacity-80 transition-opacity"
        >
          <img 
            src="/logo il sorpasso definitivo.png" 
            alt="Il Sorpasso - Picture Vehicles of Rome" 
            class="h-36 w-auto md:h-40"
          />
        </button>

        <!-- Desktop Menu -->
        <div class="hidden md:flex items-center space-x-8">
          <a 
            v-for="link in headerLinks"
            :key="link.href"
            href="javascript:void(0)"
            class="nav-link text-sm"
            @click="scrollToSection(link.href)"
          >
            {{ link.text }}
          </a>
          
          <!-- Social Links -->
          <div class="flex items-center space-x-4 border-l border-zinc-800 pl-4">
            <a 
              v-for="social in socialLinks" 
              :key="social.label"
              :href="social.url"
              :aria-label="social.label"
              target="_blank"
              rel="noopener noreferrer"
              class="text-white hover:text-accent transition-colors"
            >
              <i :class="'fab fa-' + social.icon" class="text-lg"></i>
            </a>
          </div>
          
          <!-- Language Selector -->
          <LanguageSelector />
        </div>

        <!-- Mobile Menu Button -->
        <div class="md:hidden flex items-center space-x-4">
          <LanguageSelector />
          <button 
            class="p-2 text-white hover:text-accent transition-colors"
            @click="toggleMenu"
            aria-label="Toggle Menu"
          >
            <i :class="isMenuOpen ? 'fas fa-times' : 'fas fa-bars'" class="text-xl"></i>
          </button>
        </div>
      </nav>

      <!-- Mobile Menu -->
      <div 
        v-show="isMenuOpen"
        class="md:hidden absolute left-0 right-0 w-full bg-black shadow-xl border-t border-zinc-800"
      >
        <div class="px-2 pt-2 pb-3 space-y-1">
          <a 
            v-for="link in headerLinks"
            :key="link.href"
            href="javascript:void(0)"
            class="block px-3 py-2 nav-link text-sm"
            @click="handleMobileNavClick(link.href)"
          >
            {{ link.text }}
          </a>
          <!-- Mobile Social Links -->
          <div class="flex items-center space-x-4 px-3 py-2 border-t border-zinc-800 mt-2">
            <a 
              v-for="social in socialLinks" 
              :key="social.label"
              :href="social.url"
              :aria-label="social.label"
              target="_blank"
              rel="noopener noreferrer"
              class="text-white hover:text-accent transition-colors"
            >
              <i :class="'fab fa-' + social.icon" class="text-lg"></i>
            </a>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>