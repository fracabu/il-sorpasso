<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const features = [
  {
    icon: 'fa-clock-rotate-left',
    number: t('why.features.experience.number'),
    title: t('why.features.experience.title'),
    description: t('why.features.experience.description')
  },
  {
    icon: 'fa-map-location-dot',
    number: t('why.features.coverage.number'),
    title: t('why.features.coverage.title'),
    description: t('why.features.coverage.description')
  },
  {
    icon: 'fa-headset',
    number: t('why.features.support.number'),
    title: t('why.features.support.title'),
    description: t('why.features.support.description')
  }
]
</script>

<template>
  <section id="perche-noi" class="bg-black flex items-center">
    <div class="container">
      <h2 
        class="text-4xl md:text-5xl font-bold mb-16 text-center"
        data-aos="fade-up"
      >
        {{ t('why.title') }}
      </h2>
      
      <div class="grid grid-cols-1 md:grid-cols-3 gap-12">
        <div 
          v-for="(feature, index) in features" 
          :key="feature.title"
          class="relative group"
          :data-aos="'fade-up'"
          :data-aos-delay="200 * (index + 1)"
        >
          <!-- Card Background -->
          <div class="absolute inset-0 bg-zinc-900/50 rounded-2xl transform group-hover:scale-105 transition-transform duration-500"></div>
          
          <!-- Card Content -->
          <div class="relative p-8 text-center">
            <!-- Icon -->
            <div class="mb-6">
              <i 
                :class="['fas', feature.icon]"
                class="text-4xl text-accent opacity-75 group-hover:opacity-100 transition-opacity duration-300"
              ></i>
            </div>
            
            <!-- Number -->
            <div class="text-6xl font-black text-accent mb-4 transform group-hover:scale-110 transition-transform duration-300">
              {{ feature.number }}
            </div>
            
            <!-- Title -->
            <h3 class="text-2xl font-bold mb-4 group-hover:text-accent transition-colors duration-300">
              {{ feature.title }}
            </h3>
            
            <!-- Description -->
            <p class="text-zinc-400 text-lg group-hover:text-zinc-300 transition-colors duration-300">
              {{ feature.description }}
            </p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>