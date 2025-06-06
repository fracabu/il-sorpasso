<template>
  <div class="min-h-screen bg-black text-white pt-20">
    <Header />
    <main class="container py-12">
      <div data-aos="fade-up">
        <h1 class="text-4xl md:text-5xl font-bold mb-8">
          <slot name="title"></slot>
        </h1>
        <p class="text-xl mb-12 text-zinc-400">
          <slot name="description"></slot>
        </p>
      </div>

      <div 
        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8"
        data-aos="fade-up"
        data-aos-delay="200"
      >
        <slot name="cards"></slot>
      </div>
    </main>

    <!-- Contact Form Modal -->
    <Teleport to="body">
      <div 
        v-if="showContact" 
        class="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4"
        @click="showContact = false"
      >
        <div 
          class="bg-zinc-900 rounded-lg w-full max-w-2xl"
          @click.stop
        >
          <Contact />
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, provide } from 'vue'
import { useI18n } from 'vue-i18n'
import Header from './Header.vue'
import Contact from './Contact.vue'

const { t } = useI18n()
const showContact = ref(false)

// Provide the function to show contact form to child components
provide('showContactForm', () => {
  showContact.value = true
})
</script>