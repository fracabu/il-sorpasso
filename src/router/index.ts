import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from '@/lib/supabaseClient'
import { i18n } from '@/i18n'
import Home from '../views/Home.vue'
import AdminLogin from '../views/admin/Login.vue'
import AdminDashboard from '../views/admin/Dashboard.vue'
import AdminEmailTest from '../views/admin/EmailTest.vue'
import AutoEpoca from '../views/services/AutoEpoca.vue'
import MezziSpeciali from '../views/services/MezziSpeciali.vue'
import MareAria from '../views/services/MareAria.vue'
import Personalizzazione from '../views/services/Personalizzazione.vue'
import AutoMatrimoni from '../views/services/AutoMatrimoni.vue'

// Auth guard - solo per Lorenzo
const requireAuth = async (to: any, from: any, next: any) => {
  try {
    const { data: { session } } = await supabase.auth.getSession()
    
    if (!session) {
      return next('/admin/login')
    }

    const email = session.user?.email
    if (email === 'ilsorpassodilorenzobasile@gmail.com') {
      return next()
    }

    return next('/admin/login')
  } catch (error) {
    console.error('Auth error:', error)
    return next('/admin/login')
  }
}

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home,
      alias: '/home'
    },
    {
      path: '/admin',
      children: [
        {
          path: 'login',
          name: 'admin-login',
          component: AdminLogin
        },
        {
          path: 'dashboard',
          name: 'admin-dashboard',
          component: AdminDashboard,
          beforeEnter: requireAuth
        },
        {
          path: 'email-test',
          name: 'admin-email-test',
          component: AdminEmailTest,
          beforeEnter: requireAuth
        }
      ]
    },
    {
      path: '/servizi/auto-epoca',
      name: 'auto-epoca',
      component: AutoEpoca
    },
    {
      path: '/servizi/mezzi-speciali',
      name: 'mezzi-speciali',
      component: MezziSpeciali
    },
    {
      path: '/servizi/mare-aria',
      name: 'mare-aria',
      component: MareAria
    },
    {
      path: '/servizi/personalizzazione',
      name: 'personalizzazione',
      component: Personalizzazione
    },
    {
      path: '/servizi/auto-matrimoni',
      name: 'auto-matrimoni',
      component: AutoMatrimoni
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/'
    }
  ]
})

// Navigation guard to handle language
router.beforeEach((to, from, next) => {
  // Get the saved locale or default to 'it'
  const locale = localStorage.getItem('preferred-locale') || 'it'
  
  // Set the i18n locale
  i18n.global.locale.value = locale
  
  next()
})

export default router