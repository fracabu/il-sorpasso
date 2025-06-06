<template>
  <ServiceLayout>
    <template #title>{{ t('services.rental.categories.wedding.title') }}</template>
    <template #description>
      {{ t('services.rental.categories.wedding.longDescription') }}
    </template>
    <template #cards>
      <ServiceCard
        v-for="car in cars"
        :key="car.title"
        v-bind="car"
      />
    </template>
  </ServiceLayout>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import ServiceLayout from '@/components/ServiceLayout.vue'
import ServiceCard from '@/components/ServiceCard.vue'

const { t } = useI18n()

const cars = [
  {
    image: 'https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?q=80&w=2069',
    title: t('services.rental.categories.wedding.cars.rolls.title'),
    description: t('services.rental.categories.wedding.cars.rolls.description')
  },
  {
    image: 'https://images.unsplash.com/photo-1632548260498-b7246fa466ea?q=80&w=2069',
    title: t('services.rental.categories.wedding.cars.bentley.title'),
    description: t('services.rental.categories.wedding.cars.bentley.description')
  },
  {
    image: 'https://images.unsplash.com/photo-1583356322882-85559b472f56?q=80&w=2070',
    title: t('services.rental.categories.wedding.cars.mercedes.title'),
    description: t('services.rental.categories.wedding.cars.mercedes.description')
  }
]
</script>