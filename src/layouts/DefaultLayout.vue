<template>
  <div class="min-h-screen bg-black text-white">
    <Header />
    <slot></slot>
    <Footer />
  </div>
</template>

<script setup lang="ts">
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
</script>