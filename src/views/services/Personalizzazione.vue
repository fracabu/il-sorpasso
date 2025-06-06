<template>
  <ServiceLayout>
    <template #title>{{ t('services.rental.categories.custom.title') }}</template>
    <template #description>
      {{ t('services.rental.categories.custom.longDescription') }}
    </template>
    <template #cards>
      <ServiceCard
        v-for="service in services"
        :key="service.title"
        v-bind="service"
      />
    </template>
  </ServiceLayout>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import ServiceLayout from '@/components/ServiceLayout.vue'
import ServiceCard from '@/components/ServiceCard.vue'

const { t } = useI18n()

const services = [
  {
    image: 'https://images.unsplash.com/photo-1612825173281-9a193378527e?q=80&w=2070',
    title: t('services.rental.categories.custom.services.paint.title'),
    description: t('services.rental.categories.custom.services.paint.description')
  },
  {
    image: 'https://images.unsplash.com/photo-1574352067721-c7fb02b9b838?q=80&w=2069',
    title: t('services.rental.categories.custom.services.interior.title'),
    description: t('services.rental.categories.custom.services.interior.description')
  },
  {
    image: 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?q=80&w=2083',
    title: t('services.rental.categories.custom.services.effects.title'),
    description: t('services.rental.categories.custom.services.effects.description')
  }
]
</script>