<template>
  <ServiceLayout>
    <template #title>{{ t('services.rental.categories.vintage.title') }}</template>
    <template #description>
      La nostra collezione di auto d'epoca spazia dal 1900 ad oggi, organizzata per decenni per facilitare la ricerca del veicolo perfetto per ogni produzione cinematografica.
    </template>
    <template #cards>
      <!-- Auto Anni 10/20 -->
      <div class="col-span-full mb-8">
        <h3 class="text-2xl font-bold mb-4 text-accent">🚗 Auto Anni 10/20 - Belle Époque e Anni Ruggenti</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <ServiceCard
            image="https://images.unsplash.com/photo-1544829099-b9a0c5303bea?q=80&w=2070"
            title="Ford Model T"
            description="L'auto che ha motorizzato il mondo, simbolo dell'era industriale e degli anni ruggenti"
          />
          <ServiceCard
            image="https://images.unsplash.com/photo-1552519507-da3b142c6e3d?q=80&w=2070"
            title="Rolls-Royce Silver Ghost"
            description="L'epitome del lusso e dell'eleganza della Belle Époque"
          />
          <ServiceCard
            image="https://images.unsplash.com/photo-1600706432502-77a0e2e32771?q=80&w=2069"
            title="Bugatti Type 35"
            description="Leggenda delle corse degli anni '20, simbolo di velocità e innovazione"
          />
        </div>
      </div>

      <!-- Auto Anni 30/40 -->
      <div class="col-span-full mb-8">
        <h3 class="text-2xl font-bold mb-4 text-accent">🎭 Auto Anni 30/40 - Eleganza Art Déco</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <ServiceCard
            image="https://images.unsplash.com/photo-1614200187524-dc4b892acf16?q=80&w=2070"
            title="Mercedes 540K"
            description="Capolavoro dell'ingegneria tedesca, simbolo di potenza ed eleganza"
          />
          <ServiceCard
            image="https://images.unsplash.com/photo-1592198084033-aade902d1aae?q=80&w=2070"
            title="Jaguar SS100"
            description="Sportiva britannica iconica, perfetta per scene d'epoca raffinate"
          />
          <ServiceCard
            image="https://images.unsplash.com/photo-1583356322882-85559b472f56?q=80&w=2070"
            title="Alfa Romeo 8C"
            description="Passione italiana su quattro ruote, leggenda delle competizioni"
          />
        </div>
      </div>

      <!-- Auto Anni 50 -->
      <div class="col-span-full mb-8">
        <h3 class="text-2xl font-bold mb-4 text-accent">🌟 Auto Anni 50 - Boom Economico</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <ServiceCard
            image="https://images.unsplash.com/photo-1600706432502-77a0e2e32771?q=80&w=2069"
            title="Fiat 500"
            description="L'icona italiana del boom economico, simbolo di rinascita e ottimismo"
          />
          <ServiceCard
            image="https://images.unsplash.com/photo-1592198084033-aade902d1aae?q=80&w=2070"
            title="Ferrari 250"
            description="Leggenda di Maranello, perfetta per scene di lusso e velocità"
          />
          <ServiceCard
            image="https://images.unsplash.com/photo-1614200187524-dc4b892acf16?q=80&w=2070"
            title="Porsche 356"
            description="La prima vera Porsche, eleganza e sportività tedesche"
          />
        </div>
      </div>

      <!-- Auto Anni 70 -->
      <div class="col-span-full mb-8">
        <h3 class="text-2xl font-bold mb-4 text-accent">⚡ Auto Anni 70 - Rivoluzione e Stile</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <ServiceCard
            image="https://images.unsplash.com/photo-1592198084033-aade902d1aae?q=80&w=2070"
            title="Lamborghini Countach"
            description="Rivoluzione del design automobilistico, icona futuristica degli anni '70"
          />
          <ServiceCard
            image="https://images.unsplash.com/photo-1614200187524-dc4b892acf16?q=80&w=2070"
            title="BMW 2002"
            description="La berlina sportiva che ha definito un'epoca, stile bavarese puro"
          />
          <ServiceCard
            image="https://images.unsplash.com/photo-1600706432502-77a0e2e32771?q=80&w=2069"
            title="Lancia Stratos"
            description="Leggenda dei rally, design italiano e prestazioni da corsa"
          />
        </div>
      </div>

      <!-- Auto Anni 80/90 -->
      <div class="col-span-full mb-8">
        <h3 class="text-2xl font-bold mb-4 text-accent">🚀 Auto Anni 80/90 - Icone Moderne</h3>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <ServiceCard
            image="https://images.unsplash.com/photo-1592198084033-aade902d1aae?q=80&w=2070"
            title="Ferrari Testarossa"
            description="Il mito degli anni '80 in tutta la sua gloria rossa"
          />
          <ServiceCard
            image="https://images.unsplash.com/photo-1614200187524-dc4b892acf16?q=80&w=2070"
            title="Porsche 911 Turbo"
            description="Potenza e tecnologia tedesca, icona delle supercar anni '80"
          />
          <ServiceCard
            image="https://images.unsplash.com/photo-1583356322882-85559b472f56?q=80&w=2070"
            title="BMW M3"
            description="La berlina sportiva definitiva, leggenda delle piste e delle strade"
          />
        </div>
      </div>
    </template>
  </ServiceLayout>
</template>

<script setup lang="ts">
import { useI18n } from 'vue-i18n'
import ServiceLayout from '@/components/ServiceLayout.vue'
import ServiceCard from '@/components/ServiceCard.vue'

const { t } = useI18n()
</script>