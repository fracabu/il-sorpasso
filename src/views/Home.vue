<script setup lang="ts">
import Header from '../components/Header.vue'
import Hero from '../components/Hero.vue'
import AboutUs from '../components/AboutUs.vue'
import Services from '../components/Services.vue'
import WhyUs from '../components/WhyUs.vue'
import Contact from '../components/Contact.vue'
import Footer from '../components/Footer.vue'
</script>

<template>
  <div class="min-h-screen bg-black text-white">
    <Header />
    <main>
      <Hero />
      <AboutUs />
      <Services />
      <WhyUs />
      <Contact />
    </main>
    <Footer />
  </div>
</template>