<script setup lang="ts">
import { ref } from 'vue'
import { supabase } from '@/lib/supabaseClient'

const loading = ref(false)
const testResults = ref<any[]>([])

const testForm = ref({
  name: 'Lorenzo Basile Test',
  email: 'test@ilsorpasso.it',
  message: 'Questo è un messaggio di test per verificare che il sistema email funzioni correttamente. Se ricevi questa email, tutto sta funzionando! Test inviato il: ' + new Date().toLocaleString('it-IT')
})

const sendTestEmail = async (e: Event) => {
  e.preventDefault()
  loading.value = true

  try {
    console.log('Sending test email...')
    
    // Prima salva nel database
    const { data: dbData, error: dbError } = await supabase
      .from('contact_requests')
      .insert([{
        name: testForm.value.name,
        email: testForm.value.email,
        message: testForm.value.message,
        status: 'new',
        privacy_accepted: true
      }])
      .select()

    if (dbError) {
      throw new Error(`Errore database: ${dbError.message}`)
    }

    console.log('Database insert successful:', dbData)

    // Poi invia l'email
    console.log('Calling send-contact-email function...')
    const { data: emailData, error: emailError } = await supabase.functions.invoke('send-contact-email', {
      body: {
        name: testForm.value.name,
        email: testForm.value.email,
        message: testForm.value.message
      }
    })

    console.log('Email function response:', { emailData, emailError })

    if (emailError) {
      throw new Error(`Errore email function: ${emailError.message}`)
    }

    testResults.value.unshift({
      success: true,
      timestamp: new Date().toLocaleString('it-IT'),
      data: { ...testForm.value },
      emailResponse: emailData,
      dbId: dbData?.[0]?.id
    })

    // Reset form con nuovo timestamp
    testForm.value = {
      name: 'Lorenzo Basile Test',
      email: 'test@ilsorpasso.it',
      message: 'Questo è un messaggio di test per verificare che il sistema email funzioni correttamente. Se ricevi questa email, tutto sta funzionando! Test inviato il: ' + new Date().toLocaleString('it-IT')
    }

  } catch (error: any) {
    console.error('Test email error:', error)
    testResults.value.unshift({
      success: false,
      timestamp: new Date().toLocaleString('it-IT'),
      data: { ...testForm.value },
      error: error.message,
      stack: error.stack
    })
  } finally {
    loading.value = false
  }
}

const checkEmailLogs = async () => {
  try {
    console.log('Checking email function logs...')
    
    // Prova a chiamare la funzione con dati di test per vedere i log
    const { data, error } = await supabase.functions.invoke('send-contact-email', {
      body: {
        name: 'Test Log Check',
        email: 'log-test@example.com',
        message: 'Questo è un test per controllare i log della funzione email'
      }
    })
    
    console.log('Log check response:', { data, error })
    
    testResults.value.unshift({
      success: !error,
      timestamp: new Date().toLocaleString('it-IT'),
      data: { type: 'LOG_CHECK' },
      response: data,
      error: error?.message
    })
    
  } catch (error: any) {
    console.error('Log check error:', error)
    testResults.value.unshift({
      success: false,
      timestamp: new Date().toLocaleString('it-IT'),
      data: { type: 'LOG_CHECK_ERROR' },
      error: error.message
    })
  }
}
</script>

<template>
  <div class="min-h-screen bg-black text-white p-4">
    <div class="container mx-auto max-w-4xl">
      <div class="flex justify-between items-center mb-8">
        <h1 class="text-2xl font-bold">Test Sistema Email - Debug Avanzato</h1>
        <router-link to="/admin/dashboard" class="btn-primary">
          <i class="fas fa-arrow-left mr-2"></i> Torna alla Dashboard
        </router-link>
      </div>

      <!-- Test Form -->
      <div class="bg-zinc-900 rounded-lg p-6 mb-8">
        <h2 class="text-xl font-bold mb-4">Invia Email di Test</h2>
        <form @submit="sendTestEmail" class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium mb-2">Nome</label>
              <input
                v-model="testForm.name"
                type="text"
                class="w-full px-4 py-2 bg-zinc-800 border border-zinc-700 rounded-lg focus:border-accent focus:outline-none"
                placeholder="Nome di test"
                required
              />
            </div>
            <div>
              <label class="block text-sm font-medium mb-2">Email</label>
              <input
                v-model="testForm.email"
                type="email"
                class="w-full px-4 py-2 bg-zinc-800 border border-zinc-700 rounded-lg focus:border-accent focus:outline-none"
                placeholder="test@example.com"
                required
              />
            </div>
          </div>
          <div>
            <label class="block text-sm font-medium mb-2">Messaggio</label>
            <textarea
              v-model="testForm.message"
              rows="4"
              class="w-full px-4 py-2 bg-zinc-800 border border-zinc-700 rounded-lg focus:border-accent focus:outline-none"
              placeholder="Messaggio di test..."
              required
            ></textarea>
          </div>
          <div class="flex gap-4">
            <button
              type="submit"
              class="btn-primary"
              :disabled="loading"
            >
              <i class="fas fa-paper-plane mr-2"></i>
              {{ loading ? 'Invio in corso...' : 'Invia Email di Test' }}
            </button>
            <button
              type="button"
              @click="checkEmailLogs"
              class="btn border border-accent text-accent hover:bg-accent hover:text-white"
            >
              <i class="fas fa-search mr-2"></i>
              Controlla Log
            </button>
          </div>
        </form>
      </div>

      <!-- Test Results -->
      <div v-if="testResults.length > 0" class="bg-zinc-900 rounded-lg p-6 mb-8">
        <h2 class="text-xl font-bold mb-4">Risultati Test</h2>
        <div class="space-y-4">
          <div
            v-for="(result, index) in testResults"
            :key="index"
            class="p-4 rounded-lg border"
            :class="result.success ? 'bg-green-900/30 border-green-500/50' : 'bg-red-900/30 border-red-500/50'"
          >
            <div class="flex items-center justify-between mb-2">
              <span class="font-medium">
                <i :class="result.success ? 'fas fa-check-circle text-green-500' : 'fas fa-times-circle text-red-500'" class="mr-2"></i>
                {{ result.success ? 'Test completato' : 'Errore nel test' }}
              </span>
              <span class="text-sm text-zinc-400">{{ result.timestamp }}</span>
            </div>
            <div class="text-sm space-y-2">
              <div v-if="result.data.type !== 'LOG_CHECK' && result.data.type !== 'LOG_CHECK_ERROR'">
                <p><strong>Nome:</strong> {{ result.data.name }}</p>
                <p><strong>Email:</strong> {{ result.data.email }}</p>
              </div>
              <div v-if="result.emailResponse">
                <p><strong>Provider:</strong> {{ result.emailResponse.provider || 'Unknown' }}</p>
                <p v-if="result.emailResponse.emailId"><strong>Email ID:</strong> {{ result.emailResponse.emailId }}</p>
                <p v-if="result.emailResponse.spamScore !== undefined"><strong>Spam Score:</strong> {{ result.emailResponse.spamScore }}/10</p>
              </div>
              <div v-if="result.response" class="bg-zinc-800 p-2 rounded text-xs">
                <strong>Response:</strong>
                <pre>{{ JSON.stringify(result.response, null, 2) }}</pre>
              </div>
              <p v-if="result.error" class="text-red-400"><strong>Errore:</strong> {{ result.error }}</p>
              <div v-if="result.stack" class="bg-zinc-800 p-2 rounded text-xs">
                <strong>Stack Trace:</strong>
                <pre>{{ result.stack }}</pre>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Debug Info -->
      <div class="bg-zinc-900 rounded-lg p-6">
        <h2 class="text-xl font-bold mb-4">Informazioni Debug</h2>
        <div class="space-y-4 text-sm">
          <div class="bg-zinc-800 p-4 rounded">
            <h3 class="font-semibold mb-2">🔧 Configurazione Sistema</h3>
            <ul class="space-y-1 text-zinc-300">
              <li><strong>Edge Function:</strong> send-contact-email</li>
              <li><strong>Destinatario:</strong> ilsorpassodilorenzobasile@gmail.com</li>
              <li><strong>Provider Primario:</strong> Resend</li>
              <li><strong>API Key:</strong> re_FZDHUQCH_EUpJFHfdftJppunvB84VbpjX (nascosta)</li>
              <li><strong>Fallback:</strong> Log dettagliato per debug</li>
            </ul>
          </div>
          
          <div class="bg-zinc-800 p-4 rounded">
            <h3 class="font-semibold mb-2">🚨 Possibili Problemi</h3>
            <ul class="space-y-1 text-zinc-300">
              <li>• <strong>Spam Filter:</strong> L'email potrebbe finire in spam</li>
              <li>• <strong>API Key:</strong> Verifica che la chiave Resend sia valida</li>
              <li>• <strong>Dominio:</strong> resend.dev potrebbe essere bloccato</li>
              <li>• <strong>Rate Limiting:</strong> Troppi invii in poco tempo</li>
              <li>• <strong>Gmail:</strong> Filtri automatici di Gmail</li>
            </ul>
          </div>

          <div class="bg-zinc-800 p-4 rounded">
            <h3 class="font-semibold mb-2">✅ Cosa Controllare</h3>
            <ul class="space-y-1 text-zinc-300">
              <li>1. Controlla la cartella SPAM di Lorenzo</li>
              <li>2. Verifica i log della funzione Edge</li>
              <li>3. Testa con un'altra email per conferma</li>
              <li>4. Controlla lo stato dell'API Resend</li>
              <li>5. Verifica le impostazioni Gmail di Lorenzo</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>