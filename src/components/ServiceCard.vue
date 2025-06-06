<template>
  <div class="service-card">
    <div class="service-image">
      <img 
        :src="image" 
        :alt="title"
        loading="lazy"
      />
    </div>
    <div class="service-content">
      <h3 class="service-title">{{ title }}</h3>
      <p class="service-description">{{ description }}</p>
      <button 
        @click="showContactForm"
        class="btn-primary inline-block"
      >
        {{ t('contact.cta') }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { inject } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

defineProps<{
  image: string
  title: string
  description: string
}>()

const showContactForm = inject('showContactForm') as () => void
</script>