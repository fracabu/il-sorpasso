<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabaseClient'
import { useRouter } from 'vue-router'

const router = useRouter()
const requests = ref([])
const loading = ref(true)
const statusFilter = ref('all')
const searchQuery = ref('')
const spamFilter = ref('all')

// Statistiche
const stats = ref({
  total: 0,
  new: 0,
  inProgress: 0,
  completed: 0,
  spam: 0,
  todayCount: 0,
  invalidEmails: 0
})

const fetchRequests = async () => {
  try {
    let query = supabase
      .from('contact_requests')
      .select('*')
      .order('created_at', { ascending: false })

    if (statusFilter.value !== 'all') {
      query = query.eq('status', statusFilter.value)
    }

    if (spamFilter.value === 'spam') {
      query = query.gte('spam_score', 5)
    } else if (spamFilter.value === 'clean') {
      query = query.lt('spam_score', 5)
    }

    if (searchQuery.value) {
      query = query.or(`name.ilike.%${searchQuery.value}%,email.ilike.%${searchQuery.value}%`)
    }

    const { data, error } = await query

    if (error) throw error
    requests.value = data

    // Calcola statistiche
    const today = new Date().toDateString()
    stats.value = {
      total: data.length,
      new: data.filter(r => r.status === 'new').length,
      inProgress: data.filter(r => r.status === 'in-progress').length,
      completed: data.filter(r => r.status === 'completed').length,
      spam: data.filter(r => r.spam_score >= 5).length,
      todayCount: data.filter(r => new Date(r.created_at).toDateString() === today).length,
      invalidEmails: data.filter(r => r.spam_score >= 8).length
    }
  } catch (error) {
    console.error('Error fetching requests:', error)
  } finally {
    loading.value = false
  }
}

const updateStatus = async (id: string, status: string) => {
  try {
    const { error } = await supabase
      .from('contact_requests')
      .update({ status, updated_at: new Date().toISOString() })
      .eq('id', id)

    if (error) throw error
    await fetchRequests()
  } catch (error) {
    console.error('Error updating status:', error)
  }
}

const deleteRequest = async (id: string) => {
  if (!confirm('Sei sicuro di voler eliminare questa richiesta?')) return

  try {
    const { error } = await supabase
      .from('contact_requests')
      .delete()
      .eq('id', id)

    if (error) throw error
    await fetchRequests()
  } catch (error) {
    console.error('Error deleting request:', error)
  }
}

const blockEmail = async (email: string) => {
  if (!confirm(`Vuoi bloccare l'email ${email}?`)) return

  try {
    const { error } = await supabase
      .from('blocked_emails')
      .insert([{
        email_pattern: email,
        reason: 'Blocked by admin',
        created_by: 'admin'
      }])

    if (error) throw error
    alert('Email bloccata con successo')
  } catch (error) {
    console.error('Error blocking email:', error)
    alert('Errore nel bloccare l\'email')
  }
}

const verifyEmailManually = async (email: string) => {
  try {
    const { data, error } = await supabase.functions.invoke('verify-email', {
      body: { email }
    })

    if (error) {
      alert('Errore nella verifica email')
      return
    }

    const status = data.valid ? 'Valida' : 'Non valida'
    const confidence = data.confidence || 0
    const reason = data.reason || ''
    
    alert(`Email: ${email}\nStato: ${status}\nConfidenza: ${confidence}%\nMotivo: ${reason}`)
  } catch (error) {
    console.error('Error verifying email:', error)
    alert('Errore nella verifica email')
  }
}

const getSpamBadge = (score: number) => {
  if (score >= 8) return { class: 'bg-red-900 text-red-300', text: 'SPAM' }
  if (score >= 5) return { class: 'bg-yellow-900 text-yellow-300', text: 'SOSPETTO' }
  if (score >= 3) return { class: 'bg-blue-900 text-blue-300', text: 'MEDIO' }
  return { class: 'bg-green-900 text-green-300', text: 'PULITO' }
}

const logout = async () => {
  try {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
    router.push('/admin/login')
  } catch (error) {
    console.error('Error logging out:', error)
  }
}

onMounted(() => {
  fetchRequests()
})
</script>

<template>
  <div class="min-h-screen bg-black text-white p-4">
    <!-- Top Bar -->
    <div class="flex justify-between items-center mb-8">
      <div class="flex items-center space-x-4">
        <router-link 
          to="/" 
          class="btn-primary"
        >
          <i class="fas fa-home mr-2"></i> Home
        </router-link>
        <router-link 
          to="/admin/email-test" 
          class="btn border border-accent text-accent hover:bg-accent hover:text-white"
        >
          <i class="fas fa-envelope mr-2"></i> Test Email
        </router-link>
      </div>
      <button @click="logout" class="btn border border-accent text-accent hover:bg-accent hover:text-white">
        Logout
      </button>
    </div>

    <div class="container mx-auto max-w-6xl">
      <h1 class="text-2xl font-bold mb-8">Gestione Richieste</h1>

      <!-- Statistiche -->
      <div class="grid grid-cols-2 md:grid-cols-7 gap-4 mb-8">
        <div class="bg-zinc-900 p-4 rounded-lg text-center">
          <div class="text-2xl font-bold text-blue-400">{{ stats.total }}</div>
          <div class="text-sm text-zinc-400">Totali</div>
        </div>
        <div class="bg-zinc-900 p-4 rounded-lg text-center">
          <div class="text-2xl font-bold text-green-400">{{ stats.new }}</div>
          <div class="text-sm text-zinc-400">Nuove</div>
        </div>
        <div class="bg-zinc-900 p-4 rounded-lg text-center">
          <div class="text-2xl font-bold text-yellow-400">{{ stats.inProgress }}</div>
          <div class="text-sm text-zinc-400">In Corso</div>
        </div>
        <div class="bg-zinc-900 p-4 rounded-lg text-center">
          <div class="text-2xl font-bold text-purple-400">{{ stats.completed }}</div>
          <div class="text-sm text-zinc-400">Completate</div>
        </div>
        <div class="bg-zinc-900 p-4 rounded-lg text-center">
          <div class="text-2xl font-bold text-red-400">{{ stats.spam }}</div>
          <div class="text-sm text-zinc-400">Spam</div>
        </div>
        <div class="bg-zinc-900 p-4 rounded-lg text-center">
          <div class="text-2xl font-bold text-orange-400">{{ stats.invalidEmails }}</div>
          <div class="text-sm text-zinc-400">Email Non Valide</div>
        </div>
        <div class="bg-zinc-900 p-4 rounded-lg text-center">
          <div class="text-2xl font-bold text-accent">{{ stats.todayCount }}</div>
          <div class="text-sm text-zinc-400">Oggi</div>
        </div>
      </div>

      <!-- Filters -->
      <div class="mb-8 flex flex-col sm:flex-row gap-4">
        <div class="flex-1">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Cerca per nome o email..."
            class="w-full px-4 py-2 bg-zinc-900 border border-zinc-800 rounded-lg focus:border-accent focus:outline-none"
            @input="fetchRequests"
          />
        </div>
        <select
          v-model="statusFilter"
          class="px-4 py-2 bg-zinc-900 border border-zinc-800 rounded-lg focus:border-accent focus:outline-none"
          @change="fetchRequests"
        >
          <option value="all">Tutti gli stati</option>
          <option value="new">Nuovo</option>
          <option value="in-progress">In Lavorazione</option>
          <option value="completed">Completato</option>
        </select>
        <select
          v-model="spamFilter"
          class="px-4 py-2 bg-zinc-900 border border-zinc-800 rounded-lg focus:border-accent focus:outline-none"
          @change="fetchRequests"
        >
          <option value="all">Tutti i messaggi</option>
          <option value="clean">Solo puliti</option>
          <option value="spam">Solo spam</option>
        </select>
      </div>

      <!-- Requests List -->
      <div v-if="loading" class="text-center py-8">
        Caricamento...
      </div>
      
      <div v-else-if="requests.length === 0" class="text-center py-8">
        Nessuna richiesta trovata.
      </div>
      
      <div v-else class="grid gap-6">
        <div
          v-for="request in requests"
          :key="request.id"
          class="bg-zinc-900 border border-zinc-800 rounded-lg p-6"
          :class="{ 'border-red-500/50': request.spam_score >= 8 }"
        >
          <div class="flex justify-between items-start mb-4">
            <div>
              <h3 class="text-xl font-bold">{{ request.name }}</h3>
              <div class="flex items-center gap-2">
                <p class="text-zinc-400">{{ request.email }}</p>
                <button
                  @click="verifyEmailManually(request.email)"
                  class="text-blue-400 hover:text-blue-300 text-sm"
                  title="Verifica email"
                >
                  <i class="fas fa-search"></i>
                </button>
              </div>
              <div class="flex items-center gap-2 mt-2">
                <span 
                  class="px-2 py-1 rounded text-xs font-medium"
                  :class="getSpamBadge(request.spam_score || 0).class"
                >
                  {{ getSpamBadge(request.spam_score || 0).text }} ({{ request.spam_score || 0 }})
                </span>
                <span v-if="request.user_agent" class="text-xs text-zinc-500">
                  {{ request.user_agent.includes('Mobile') ? '📱' : '💻' }}
                </span>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <select
                v-model="request.status"
                class="px-3 py-1 bg-zinc-800 border border-zinc-700 rounded-lg focus:border-accent focus:outline-none"
                @change="updateStatus(request.id, request.status)"
              >
                <option value="new">Nuovo</option>
                <option value="in-progress">In Lavorazione</option>
                <option value="completed">Completato</option>
              </select>
              <button
                @click="blockEmail(request.email)"
                class="text-orange-500 hover:text-orange-400 p-1"
                title="Blocca email"
              >
                <i class="fas fa-ban"></i>
              </button>
              <button
                @click="deleteRequest(request.id)"
                class="text-red-500 hover:text-red-400 p-1"
                title="Elimina"
              >
                <i class="fas fa-trash"></i>
              </button>
            </div>
          </div>
          
          <p class="text-zinc-300 mb-4">{{ request.message }}</p>
          
          <div class="text-sm text-zinc-500">
            Creato il: {{ new Date(request.created_at).toLocaleString() }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>