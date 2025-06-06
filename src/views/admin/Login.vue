<script setup lang="ts">
import { ref } from 'vue'
import { supabase } from '@/lib/supabaseClient'
import { useRouter } from 'vue-router'

const router = useRouter()
const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)

const handleLogin = async (e: Event) => {
  e.preventDefault()
  loading.value = true
  error.value = ''

  try {
    const { data, error: err } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value
    })

    if (err) throw err

    if (data.user) {
      // Solo Lorenzo può accedere
      if (data.user.email === 'ilsorpassodilorenzobasile@gmail.com') {
        await router.push('/admin/dashboard')
      } else {
        error.value = 'Accesso non autorizzato'
      }
    }
  } catch (err: any) {
    if (err.message?.includes('Invalid login credentials')) {
      error.value = 'Email o password non corretti'
    } else {
      error.value = 'Errore durante l\'accesso. Riprova.'
    }
    console.error('Error:', err)
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="flex-1 flex items-center justify-center px-4 py-20">
    <div class="max-w-md w-full">
      <div class="text-center mb-8">
        <h2 class="text-3xl font-bold text-white">
          Area Admin
        </h2>
        <p class="mt-2 text-zinc-400">
          Accedi per gestire le richieste di contatto
        </p>
      </div>

      <form @submit.prevent="handleLogin" class="space-y-6 bg-zinc-900/50 p-8 rounded-lg border border-zinc-800">
        <div class="space-y-4">
          <div>
            <label for="email" class="block text-sm font-medium text-zinc-300 mb-1">Email</label>
            <input
              v-model="email"
              id="email"
              name="email"
              type="email"
              required
              class="w-full px-3 py-2 bg-zinc-900 border border-zinc-800 rounded-lg focus:border-accent focus:outline-none"
              placeholder="Inserisci la tua email"
            />
          </div>
          <div>
            <label for="password" class="block text-sm font-medium text-zinc-300 mb-1">Password</label>
            <input
              v-model="password"
              id="password"
              name="password"
              type="password"
              required
              class="w-full px-3 py-2 bg-zinc-900 border border-zinc-800 rounded-lg focus:border-accent focus:outline-none"
              placeholder="Inserisci la tua password"
            />
          </div>
        </div>

        <div v-if="error" class="text-red-500 text-sm text-center">
          {{ error }}
        </div>

        <button
          type="submit"
          class="btn-primary w-full"
          :disabled="loading"
        >
          {{ loading ? 'Accesso in corso...' : 'Accedi' }}
        </button>

        <div class="text-center mt-4">
          <router-link 
            to="/" 
            class="text-sm text-zinc-400 hover:text-accent"
          >
            Torna alla home
          </router-link>
        </div>
      </form>
    </div>
  </div>
</template>