<script setup lang="ts">
import { Swiper, SwiperSlide } from 'swiper/vue'
import { Autoplay, Navigation, Pagination } from 'swiper/modules'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import 'swiper/css'
import 'swiper/css/navigation'
import 'swiper/css/pagination'

const router = useRouter()
const { t } = useI18n()

const vehicleCategories = [
  {
    title: t('services.rental.categories.vintage.title'),
    subtitle: t('services.rental.categories.vintage.subtitle'),
    description: t('services.rental.categories.vintage.description'),
    bgImage: "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?q=80&w=2070",
    route: '/servizi/auto-epoca'
  },
  {
    title: t('services.rental.categories.special.title'),
    subtitle: t('services.rental.categories.special.subtitle'),
    description: t('services.rental.categories.special.description'),
    bgImage: "https://images.unsplash.com/photo-1558981806-ec527fa84c39?q=80&w=2070",
    route: '/servizi/mezzi-speciali'
  },
  {
    title: t('services.rental.categories.sea.title'),
    subtitle: t('services.rental.categories.sea.subtitle'),
    description: t('services.rental.categories.sea.description'),
    bgImage: "https://images.unsplash.com/photo-1471922694854-ff1b63b20054?q=80&w=2072",
    route: '/servizi/mare-aria'
  },
  {
    title: t('services.rental.categories.custom.title'),
    subtitle: t('services.rental.categories.custom.subtitle'),
    description: t('services.rental.categories.custom.description'),
    bgImage: "https://images.unsplash.com/photo-1614200187524-dc4b892acf16?q=80&w=2070",
    route: '/servizi/personalizzazione'
  },
  {
    title: t('services.rental.categories.wedding.title'),
    subtitle: t('services.rental.categories.wedding.subtitle'),
    description: t('services.rental.categories.wedding.description'),
    bgImage: "https://images.unsplash.com/photo-1515706886582-54c73c5eaf41?q=80&w=2070",
    route: '/servizi/auto-matrimoni'
  }
]

const tourImages = [
  { 
    url: 'https://images.unsplash.com/photo-1516483638261-f4dbaf036963',
    title: t('services.tour.locations.amalfi.title'),
    description: t('services.tour.locations.amalfi.description')
  },
  { 
    url: 'https://images.unsplash.com/photo-1467269204594-9661b134dd2b',
    title: t('services.tour.locations.tuscany.title'),
    description: t('services.tour.locations.tuscany.description')
  },
  { 
    url: 'https://images.unsplash.com/photo-1534445867742-43195f401b6c',
    title: t('services.tour.locations.como.title'),
    description: t('services.tour.locations.como.description')
  },
  { 
    url: 'https://images.unsplash.com/photo-1499678329028-101435549a4e',
    title: t('services.tour.locations.sicily.title'),
    description: t('services.tour.locations.sicily.description')
  },
  { 
    url: 'https://images.unsplash.com/photo-1537799943037-f5da89a65689',
    title: t('services.tour.locations.dolomites.title'),
    description: t('services.tour.locations.dolomites.description')
  }
]

const navigateToService = (route: string) => {
  router.push(route)
}
</script>

<template>
  <!-- Services Section -->
  <section id="servizi" class="min-h-screen flex items-center justify-center py-20">
    <div class="container">
      <h2 
        class="text-4xl md:text-5xl font-bold mb-16 text-center"
        data-aos="fade-up"
      >
        {{ t('services.title') }}
      </h2>
      
      <!-- Noleggio Mezzi di Scena -->
      <div class="mb-20">
        <h3 
          class="text-3xl font-bold mb-8 text-center text-accent"
          data-aos="fade-up"
        >
          {{ t('services.rental.title') }}
        </h3>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div 
            v-for="(category, index) in vehicleCategories" 
            :key="category.title"
            @click="navigateToService(category.route)"
            class="relative group cursor-pointer overflow-hidden rounded-lg h-[250px]"
            data-aos="fade-up"
            :data-aos-delay="100 * index"
          >
            <!-- Background Image -->
            <img 
              :src="category.bgImage" 
              :alt="category.title"
              class="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
            />
            
            <!-- Overlay -->
            <div class="absolute inset-0 bg-black/60 group-hover:bg-black/40 transition-colors duration-300"></div>
            
            <!-- Content -->
            <div class="relative h-full p-6 flex flex-col justify-end z-10">
              <h4 class="text-xl font-bold mb-1">{{ category.title }}</h4>
              <p class="text-accent font-semibold mb-1 text-sm">{{ category.subtitle }}</p>
              <p class="text-white/80 text-sm">{{ category.description }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Tour in Italia -->
      <section id="tour" class="min-h-screen flex items-center justify-center">
        <div class="w-full">
          <h3 
            class="text-3xl font-bold mb-8 text-center text-accent"
            data-aos="fade-up"
          >
            {{ t('services.tour.title') }}
          </h3>
          <div data-aos="fade-up" data-aos-delay="200">
            <swiper
              :modules="[Autoplay, Navigation, Pagination]"
              :slides-per-view="1"
              :breakpoints="{
                '640': {
                  slidesPerView: 2,
                  spaceBetween: 20
                },
                '1024': {
                  slidesPerView: 3,
                  spaceBetween: 30
                }
              }"
              :space-between="30"
              :navigation="true"
              :pagination="{ clickable: true }"
              :autoplay="{
                delay: 3000,
                disableOnInteraction: false
              }"
              class="tour-swiper"
            >
              <swiper-slide 
                v-for="image in tourImages" 
                :key="image.title"
                class="pb-12"
              >
                <div class="relative group overflow-hidden rounded-lg h-[300px]">
                  <img 
                    :src="image.url" 
                    :alt="image.title"
                    class="w-full h-full object-cover transform group-hover:scale-110 transition-transform duration-500"
                  />
                  <div class="absolute inset-0 bg-gradient-to-t from-black via-black/50 to-transparent flex flex-col items-center justify-end p-6 text-center">
                    <h4 class="text-xl font-bold text-white mb-2">{{ image.title }}</h4>
                    <p class="text-white/80 text-sm">{{ image.description }}</p>
                  </div>
                </div>
              </swiper-slide>
            </swiper>
          </div>
        </div>
      </section>
    </div>
  </section>
</template>

<style>
.tour-swiper {
  padding-bottom: 3rem !important;
}

.tour-swiper .swiper-button-next,
.tour-swiper .swiper-button-prev {
  color: #DC2626 !important;
}

.tour-swiper .swiper-pagination-bullet {
  background: #DC2626 !important;
}

.tour-swiper .swiper-pagination {
  bottom: 0 !important;
}
</style>