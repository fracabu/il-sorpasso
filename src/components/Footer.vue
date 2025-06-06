<template>
  <footer class="bg-zinc-950 text-white pt-16 pb-8">
    <div class="container">
      <!-- Main Footer Content -->
      <div class="grid grid-cols-1 md:grid-cols-12 gap-12 mb-12">
        <!-- Brand Column -->
        <div class="md:col-span-4">
          <a 
            href="#" 
            class="inline-block mb-6"
          >
            <img 
              src="/logo il sorpasso definitivo.png" 
              alt="Il Sorpasso - Picture Vehicles of Rome" 
              class="h-40 w-auto"
            />
          </a>
          <p class="text-zinc-400 mb-6">
            {{ t('about.description1') }}
          </p>
          <!-- Social Links -->
          <div class="flex space-x-4 mb-6">
            <a 
              v-for="social in socialLinks" 
              :key="social.label"
              :href="social.url"
              :aria-label="social.label"
              target="_blank"
              rel="noopener noreferrer"
              class="text-zinc-400 hover:text-accent transition-colors"
            >
              <i :class="'fab fa-' + social.icon" class="text-lg"></i>
            </a>
          </div>
          <!-- Admin Link -->
          <router-link 
            to="/admin/login" 
            class="text-zinc-400 hover:text-accent transition-colors inline-flex items-center"
          >
            <i class="fas fa-lock mr-2"></i>
            Area Admin
          </router-link>
        </div>

        <!-- Navigation Columns -->
        <div 
          v-for="section in sections" 
          :key="section.title"
          class="md:col-span-2"
        >
          <h3 class="text-lg font-bold text-white mb-4">{{ section.title }}</h3>
          <ul class="space-y-2">
            <li v-for="link in section.links" :key="link.text">
              <a 
                :href="link.href"
                class="text-zinc-400 hover:text-accent transition-colors"
              >
                {{ link.text }}
              </a>
            </li>
          </ul>
        </div>

        <!-- Contact Information -->
        <div class="md:col-span-4">
          <h3 class="text-lg font-bold text-white mb-4">{{ t('footer.contacts') }}</h3>
          <div class="space-y-2 text-zinc-400">
            <p class="font-semibold text-white">{{ companyInfo.name }}</p>
            <p>{{ companyInfo.address }}</p>
            <p>{{ companyInfo.postalCode }} - {{ companyInfo.city }}</p>
            <p>{{ companyInfo.vat }}</p>
            <p>{{ companyInfo.sdiCode }}</p>
            <div class="pt-4">
              <p class="font-semibold text-white">{{ companyInfo.role }}</p>
              <p>
                <a 
                  :href="'tel:' + companyInfo.mobile" 
                  class="hover:text-accent transition-colors"
                >
                  {{ companyInfo.mobile }}
                </a>
              </p>
              <div class="space-y-1">
                <p v-for="email in companyInfo.emails" :key="email">
                  <a 
                    :href="'mailto:' + email"
                    class="hover:text-accent transition-colors"
                  >
                    {{ email }}
                  </a>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Bottom Bar -->
      <div class="pt-8 border-t border-zinc-800 text-center text-zinc-500">
        <p>&copy; {{ currentYear }} {{ companyInfo.name }}. {{ t('footer.rights') }}</p>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'

const router = useRouter()
const { t } = useI18n()
const currentYear = new Date().getFullYear()

const sections = computed(() => [
  {
    title: t('footer.services'),
    links: [
      { text: t('services.rental.categories.vintage.title'), href: '/servizi/auto-epoca' },
      { text: t('services.rental.categories.special.title'), href: '/servizi/mezzi-speciali' },
      { text: t('services.rental.categories.sea.title'), href: '/servizi/mare-aria' },
      { text: t('services.rental.categories.custom.title'), href: '/servizi/personalizzazione' },
      { text: t('services.rental.categories.wedding.title'), href: '/servizi/auto-matrimoni' }
    ]
  },
  {
    title: t('footer.company'),
    links: [
      { text: t('nav.about'), href: '#chi-siamo' },
      { text: t('nav.why'), href: '#perche-noi' },
      { text: t('nav.tour'), href: '#tour' },
      { text: t('nav.contact'), href: '#contattaci' }
    ]
  }
])

const socialLinks = [
  { icon: 'facebook', url: 'https://www.facebook.com/IlSorpassodiLorenzoBasile', label: 'Facebook' },
  { icon: 'instagram', url: 'https://www.instagram.com/ilsorpassodilorenzobasile/', label: 'Instagram' },
  { icon: 'linkedin', url: '#', label: 'LinkedIn' }
]

const companyInfo = {
  name: 'Il Sorpasso di Lorenzo Basile',
  address: 'Via Suor Celestina Donati 90',
  postalCode: '00167',
  city: 'Roma',
  vat: 'P.I: 15844201002',
  sdiCode: 'Codice Univoco: DHYCJZQ',
  role: 'Picture Vehicles & Marine Coordinator',
  mobile: '+393473952838',
  emails: [
    'lorenzo.basile@yahoo.it',
    'ilsorpassodilorenzobasile@gmail.com'
  ]
}
</script>