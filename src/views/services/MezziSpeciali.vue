<template>
  <ServiceLayout>
    <template #title>{{ t('services.rental.categories.special.title') }}</template>
    <template #description>
      {{ t('services.rental.categories.special.longDescription') }}
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
    image: 'https://images.unsplash.com/photo-1599257552611-6215905f4f96?q=80&w=2070',
    title: t('services.rental.categories.special.vehicles.military.title'),
    description: t('services.rental.categories.special.vehicles.military.description')
  },
  {
    image: 'https://images.unsplash.com/photo-1558981359-219d6364c9c8?q=80&w=2070',
    title: t('services.rental.categories.special.vehicles.trucks.title'),
    description: t('services.rental.categories.special.vehicles.trucks.description')
  },
  {
    image: 'https://images.unsplash.com/photo-1566933293069-b55c7f326dd4?q=80&w=2070',
    title: t('services.rental.categories.special.vehicles.vans.title'),
    description: t('services.rental.categories.special.vehicles.vans.description')
  }
]
</script>