<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const scrollToContact = () => {
  document.getElementById('contattaci')?.scrollIntoView({ behavior: 'smooth' })
}
</script>

<template>
  <section id="chi-siamo" class="bg-zinc-900 flex items-center">
    <div class="container">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
        <!-- Left Column: Content -->
        <div data-aos="fade-right">
          <h2 class="text-4xl md:text-5xl font-bold mb-6">{{ t('about.title') }}</h2>
          <div class="prose prose-invert max-w-none">
            <p class="text-xl mb-6">
              {{ t('about.description1') }}
            </p>
            <p class="text-lg text-zinc-400 mb-6">
              {{ t('about.description2') }}
            </p>
            <p class="text-lg text-zinc-400">
              {{ t('about.description3') }}
            </p>
          </div>
          
          <div class="mt-8">
            <button 
              @click="scrollToContact"
              class="btn-primary"
            >
              {{ t('about.cta') }}
            </button>
          </div>
        </div>
        
        <!-- Right Column: Lorenzo's Illustration -->
        <div class="relative aspect-video rounded-lg overflow-hidden" data-aos="fade-left">
          <img 
            src="/src/assets/IMG-20250415-WA0030.jpg" 
            alt="Il Sorpasso - Lorenzo Basile illustration with vintage car and film equipment"
            class="w-full h-full object-cover"
          />
          <div class="absolute inset-0 bg-gradient-to-t from-black/30 via-transparent to-transparent"></div>
          <div class="absolute bottom-4 left-4 right-4">
            <p class="text-white text-sm font-medium bg-black/50 backdrop-blur-sm rounded px-3 py-2">
              Illustrazione originale di Lorenzo Basile - Il Sorpasso
            </p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>