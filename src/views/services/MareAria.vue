<template>
  <ServiceLayout>
    <template #title>{{ t('services.rental.categories.sea.title') }}</template>
    <template #description>
      {{ t('services.rental.categories.sea.longDescription') }}
    </template>
    <template #cards>
      <ServiceCard
        v-for="vehicle in vehicles"
        :key="vehicle.title"
        v-bind="vehicle"
      />
    </template>
  </ServiceLayout>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import ServiceLayout from '@/components/ServiceLayout.vue'
import ServiceCard from '@/components/ServiceCard.vue'

const { t } = useI18n()

const vehicles = [
  {
    image: 'https://images.unsplash.com/photo-1566847438217-76e82d383f84?q=80&w=2070',
    title: t('services.rental.categories.sea.vehicles.yacht.title'),
    description: t('services.rental.categories.sea.vehicles.yacht.description')
  },
  {
    image: 'https://images.unsplash.com/photo-1517925035435-7976539b920d?q=80&w=2070',
    title: t('services.rental.categories.sea.vehicles.planes.title'),
    description: t('services.rental.categories.sea.vehicles.planes.description')
  },
  {
    image: 'https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?q=80&w=2070',
    title: t('services.rental.categories.sea.vehicles.boats.title'),
    description: t('services.rental.categories.sea.vehicles.boats.description')
  }
]
</script>