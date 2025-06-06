<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import heroImage from '@/assets/hero-section1 copy.png'

const { t } = useI18n()

const scrollToContact = () => {
  document.getElementById('contattaci')?.scrollIntoView({ behavior: 'smooth' })
}
</script>

<template>
  <section class="relative h-screen">
    <!-- Background Image Container -->
    <div class="absolute inset-0">
      <img 
        :src="heroImage"
        alt="Il Sorpasso hero image" 
        class="w-full h-full object-cover"
        loading="eager"
      />
      <div class="absolute inset-0 bg-gradient-to-r from-black via-black/80 to-transparent"></div>
    </div>

    <!-- Content -->
    <div class="container relative h-full flex items-center">
      <div class="w-full max-w-lg">
        <h1 class="text-6xl md:text-8xl font-black uppercase mb-4">
          Il Sorpasso
        </h1>
        <p class="text-xl md:text-2xl mb-8">
          {{ t('hero.subtitle', { count: '7.000' }) }}
        </p>
        <button 
          @click="scrollToContact"
          class="btn-primary px-6 py-3 text-base"
        >
          {{ t('hero.cta') }}
        </button>
      </div>
    </div>
  </section>
</template>