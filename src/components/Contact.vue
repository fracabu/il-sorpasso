<script setup lang="ts">
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { supabase } from '@/lib/supabaseClient'

const { t } = useI18n()

interface ContactForm {
  name: string
  surname: string
  email: string
  message: string
  privacy_accepted: boolean
  status: 'new' | 'in-progress' | 'completed'
  created_at: string
}

const form = ref<ContactForm>({
  name: '',
  surname: '',
  email: '',
  message: '',
  privacy_accepted: false,
  status: 'new',
  created_at: new Date().toISOString()
})

const loading = ref(false)
const success = ref(false)
const error = ref('')
const cooldownTime = ref(0)
const emailVerifying = ref(false)
const emailValid = ref<boolean | null>(null)
const emailVerificationMessage = ref('')
const nameValid = ref<boolean | null>(null)
const surnameValid = ref<boolean | null>(null)
const retryCount = ref(0)
const maxRetries = 3

// Lista di domini email temporanei/sospetti
const suspiciousEmailDomains = [
  'tempmail.org', '10minutemail.com', 'guerrillamail.com', 'mailinator.com',
  'throwaway.email', 'temp-mail.org', 'getnada.com', 'maildrop.cc',
  'sharklasers.com', 'grr.la', 'guerrillamailblock.com', 'pokemail.net',
  'spam4.me', 'bccto.me', 'chacuo.net', 'dispostable.com', 'emailondeck.com',
  'yopmail.com', 'mohmal.com', 'fakeinbox.com', 'trashmail.com'
]

// Lista di provider email legittimi
const legitimateProviders = [
  'gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'live.com',
  'icloud.com', 'protonmail.com', 'fastmail.com', 'zoho.com', 'aol.com',
  'libero.it', 'virgilio.it', 'alice.it', 'tin.it', 'tiscali.it',
  'email.it', 'inwind.it', 'kataweb.it', 'iol.it', 'supereva.it',
  'pec.it', 'legalmail.it'
]

// Pattern email sospetti comuni
const suspiciousEmailPatterns = [
  /^test\d*@/i,
  /^fake\d*@/i,
  /^spam\d*@/i,
  /^temp\d*@/i,
  /^prova\d*@/i,
  /^esempio\d*@/i,
  /^admin\d*@/i,
  /^user\d*@/i,
  /^asdf+@/i,
  /^qwerty+@/i,
  /^123+@/i,
  /^abc+@/i,
  /^xxx+@/i,
  /^noreply@/i,
  /^no-reply@/i,
  /^donotreply@/i,
  /^[a-z]{1,3}\d{3,}@/i, // pattern come abc123@, xy456@
  /^[a-z]+\d{4,}@/i, // pattern come test1234@
  /^\d+@/i, // solo numeri prima della @
  /^[a-z]{10,}@/i // stringhe troppo lunghe senza senso
]

// Nomi e cognomi italiani comuni per validazione
const commonItalianNames = [
  'alessandro', 'andrea', 'antonio', 'carlo', 'claudio', 'davide', 'fabio', 'francesco', 'giovanni', 'giuseppe',
  'lorenzo', 'luca', 'luigi', 'marco', 'mario', 'matteo', 'michele', 'paolo', 'roberto', 'stefano',
  'alessandra', 'anna', 'antonella', 'barbara', 'carla', 'claudia', 'elena', 'francesca', 'giovanna', 'giulia',
  'laura', 'lucia', 'luisa', 'maria', 'marina', 'paola', 'roberta', 'sara', 'silvia', 'valentina'
]

const commonItalianSurnames = [
  'rossi', 'russo', 'ferrari', 'esposito', 'bianchi', 'romano', 'colombo', 'ricci', 'marino', 'greco',
  'bruno', 'gallo', 'conti', 'de luca', 'costa', 'giordano', 'mancini', 'rizzo', 'lombardi', 'moretti',
  'barbieri', 'fontana', 'santoro', 'mariani', 'rinaldi', 'caruso', 'ferrara', 'galli', 'martini', 'leone'
]

// Parole sospette per nomi/cognomi
const suspiciousNameWords = [
  'test', 'fake', 'spam', 'admin', 'user', 'prova', 'esempio', 'demo', 'sample',
  'asdf', 'qwerty', 'abc', 'xyz', 'null', 'undefined', 'none', 'temp', 'temporary'
]

// Funzione per validare nome/cognome
const validateName = (name: string, type: 'name' | 'surname'): { valid: boolean, reason?: string } => {
  const cleanName = name.trim().toLowerCase()
  
  // Controlla lunghezza
  if (cleanName.length < 2) {
    return { valid: false, reason: `${type === 'name' ? 'Nome' : 'Cognome'} troppo corto` }
  }
  
  if (cleanName.length > 50) {
    return { valid: false, reason: `${type === 'name' ? 'Nome' : 'Cognome'} troppo lungo` }
  }
  
  // Controlla caratteri validi (solo lettere, spazi, apostrofi, trattini)
  if (!/^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ\s'\-]+$/.test(name)) {
    return { valid: false, reason: 'Contiene caratteri non validi' }
  }
  
  // Controlla parole sospette
  if (suspiciousNameWords.some(word => cleanName.includes(word))) {
    return { valid: false, reason: 'Nome sospetto o di test' }
  }
  
  // Controlla pattern sospetti
  if (/^\d+$/.test(cleanName) || /^(.)\1{3,}$/.test(cleanName)) {
    return { valid: false, reason: 'Pattern non realistico' }
  }
  
  // Controlla se è solo consonanti o solo vocali
  const vowels = 'aeiouàáâäãåęèéêëėįìíîïòóôöõøùúûüųūÿý'
  const consonants = 'bcdfghjklmnpqrstvwxyzçčšžñß'
  const nameLetters = cleanName.replace(/[\s'\-]/g, '')
  
  if (nameLetters.length > 3) {
    const vowelCount = nameLetters.split('').filter(char => vowels.includes(char)).length
    const consonantCount = nameLetters.split('').filter(char => consonants.includes(char)).length
    
    if (vowelCount === 0 || consonantCount === 0) {
      return { valid: false, reason: 'Nome non realistico' }
    }
  }
  
  // Bonus per nomi/cognomi italiani comuni
  const isCommon = type === 'name' 
    ? commonItalianNames.includes(cleanName)
    : commonItalianSurnames.includes(cleanName)
  
  return { 
    valid: true, 
    reason: isCommon ? 'Nome verificato ✓' : 'Nome valido' 
  }
}

// Validazione nome in tempo reale
const validateNameField = (value: string, type: 'name' | 'surname') => {
  const validation = validateName(value, type)
  
  if (type === 'name') {
    nameValid.value = validation.valid
  } else {
    surnameValid.value = validation.valid
  }
  
  return validation
}

// Funzione per ottenere l'IP del client (approssimativo)
const getClientInfo = () => {
  return {
    userAgent: navigator.userAgent,
    // In produzione, l'IP sarà gestito dal server
    timestamp: new Date().toISOString()
  }
}

// Verifica email avanzata
const verifyEmailAdvanced = (email: string) => {
  const domain = email.split('@')[1]?.toLowerCase()
  const localPart = email.split('@')[0]?.toLowerCase()
  
  if (!domain || !localPart) {
    return { valid: false, reason: 'Formato email non valido', confidence: 100 }
  }

  // Controlla pattern email sospetti
  if (suspiciousEmailPatterns.some(pattern => pattern.test(email))) {
    return { valid: false, reason: 'Pattern email sospetto o di test', confidence: 95 }
  }

  // Controlla domini temporanei
  if (suspiciousEmailDomains.some(suspDomain => 
    domain === suspDomain || domain.includes(suspDomain.split('.')[0])
  )) {
    return { valid: false, reason: 'Email temporanea non consentita', confidence: 95 }
  }

  // Controlla pattern sospetti nel dominio
  if (domain.includes('temp') || domain.includes('fake') || domain.includes('trash') || domain.includes('test')) {
    return { valid: false, reason: 'Dominio email sospetto', confidence: 90 }
  }

  // Controlla se il dominio ha estensioni sospette
  const suspiciousExtensions = ['.tk', '.ml', '.ga', '.cf', '.gq']
  if (suspiciousExtensions.some(ext => domain.endsWith(ext))) {
    return { valid: false, reason: 'Estensione dominio sospetta', confidence: 85 }
  }

  // Controlla se la parte locale è troppo semplice per un provider legittimo
  if (legitimateProviders.includes(domain)) {
    // Per provider legittimi, controlla pattern sospetti nella parte locale
    if (localPart.length < 3) {
      return { valid: false, reason: 'Email troppo corta per essere reale', confidence: 80 }
    }
    
    // Controlla se è solo numeri o lettere ripetute
    if (/^\d+$/.test(localPart) || /^(.)\1+$/.test(localPart)) {
      return { valid: false, reason: 'Pattern email non realistico', confidence: 85 }
    }
    
    // Controlla sequenze ovvie
    const obviousSequences = ['123', 'abc', 'qwe', 'asd', 'zxc', 'test', 'prova', 'fake']
    if (obviousSequences.some(seq => localPart.includes(seq) && localPart.length < 8)) {
      return { valid: false, reason: 'Email sembra essere di test', confidence: 75 }
    }
    
    return { valid: true, reason: 'Provider email verificato', confidence: 90 }
  }

  // Per domini sconosciuti, richiedi verifica più approfondita
  return { valid: null, reason: 'Dominio sconosciuto - verifica in corso', confidence: 50 }
}

// Verifica email in tempo reale
const verifyEmail = async (email: string) => {
  if (!email || email.length < 5) {
    emailValid.value = null
    emailVerificationMessage.value = ''
    return
  }

  emailVerifying.value = true
  
  try {
    // Prima verifica locale
    const localVerification = verifyEmailAdvanced(email)
    
    if (localVerification.valid === false) {
      emailValid.value = false
      emailVerificationMessage.value = localVerification.reason
      emailVerifying.value = false
      return
    }

    if (localVerification.valid === true) {
      emailValid.value = true
      emailVerificationMessage.value = localVerification.reason + ' ✓'
      emailVerifying.value = false
      return
    }

    // Se la verifica locale non è conclusiva, prova il servizio esterno
    const { data, error } = await supabase.functions.invoke('verify-email', {
      body: { email }
    })

    if (error) {
      console.warn('Email verification service failed:', error)
      // Se il servizio fallisce, usa solo la verifica locale
      emailValid.value = localVerification.confidence > 60
      emailVerificationMessage.value = localVerification.reason
      return
    }

    emailValid.value = data.valid
    
    if (!data.valid) {
      emailVerificationMessage.value = data.reason || 'Email non valida'
    } else if (data.confidence < 70) {
      emailVerificationMessage.value = 'Email verificata con bassa confidenza'
    } else {
      emailVerificationMessage.value = 'Email verificata ✓'
    }
    
  } catch (err) {
    console.warn('Email verification error:', err)
    // In caso di errore, usa la verifica locale
    const localVerification = verifyEmailAdvanced(email)
    emailValid.value = localVerification.valid !== false
    emailVerificationMessage.value = localVerification.reason || 'Verifica non disponibile'
  } finally {
    emailVerifying.value = false
  }
}

// Debounce per la verifica email
let emailVerificationTimeout: number | null = null
const handleEmailChange = () => {
  if (emailVerificationTimeout) {
    clearTimeout(emailVerificationTimeout)
  }
  
  emailVerificationTimeout = setTimeout(() => {
    verifyEmail(form.value.email)
  }, 600) // Verifica dopo 600ms di inattività
}

// Funzione per calcolare spam score migliorata
const calculateSpamScore = (formData: any) => {
  let score = 0
  
  // Controlla validità nome e cognome
  const nameValidation = validateName(formData.name, 'name')
  const surnameValidation = validateName(formData.surname, 'surname')
  
  if (!nameValidation.valid) score += 4
  if (!surnameValidation.valid) score += 4
  
  // Controlla se nome e cognome sono troppo simili
  if (formData.name.toLowerCase() === formData.surname.toLowerCase()) score += 3
  
  // Controlla caratteri sospetti nel nome
  if (/[<>{}[\]\\\/]/.test(formData.name) || /[<>{}[\]\\\/]/.test(formData.surname)) score += 4
  
  // Controlla se il messaggio è troppo corto
  if (formData.message.length < 10) score += 3
  
  // Controlla se il messaggio è troppo lungo (possibile spam)
  if (formData.message.length > 2000) score += 4
  
  // Controlla URL nel messaggio
  const urlCount = (formData.message.match(/https?:\/\/[^\s]+/g) || []).length
  if (urlCount > 0) score += urlCount * 3
  
  // Controlla caratteri ripetuti
  if (/(.)\1{10,}/.test(formData.message)) score += 4
  
  // Controlla parole spam comuni
  const spamWords = [
    'viagra', 'casino', 'lottery', 'winner', 'congratulations', 'urgent', 'act now',
    'click here', 'free money', 'make money', 'work from home', 'guaranteed',
    'no risk', 'limited time', 'offer expires', 'buy now', 'discount'
  ]
  const messageWords = formData.message.toLowerCase()
  spamWords.forEach(word => {
    if (messageWords.includes(word)) score += 3
  })
  
  // Controlla email temporanee o sospette
  if (emailValid.value === false) score += 6
  
  // Controlla se nome/cognome e email sono troppo simili (possibile bot)
  const fullName = `${formData.name} ${formData.surname}`.toLowerCase()
  const emailPart = formData.email.split('@')[0].toLowerCase()
  if (fullName.split(' ').some(part => emailPart.includes(part) && part.length > 3)) score += 2
  
  // Controlla pattern email sospetti anche nello spam score
  if (suspiciousEmailPatterns.some(pattern => pattern.test(formData.email))) score += 5
  
  return Math.min(score, 10) // Max score 10
}

// Cooldown per prevenire spam
const startCooldown = () => {
  cooldownTime.value = 60 // 60 secondi
  const interval = setInterval(() => {
    cooldownTime.value--
    if (cooldownTime.value <= 0) {
      clearInterval(interval)
    }
  }, 1000)
}

// Funzione per controllare la connettività a Supabase
const checkSupabaseConnection = async (): Promise<boolean> => {
  try {
    const { data, error } = await supabase
      .from('contact_requests')
      .select('id')
      .limit(1)
    
    return !error
  } catch (err) {
    console.error('Supabase connection check failed:', err)
    return false
  }
}

// Funzione per determinare il tipo di errore
const getErrorType = (error: any): string => {
  if (!error) return 'unknown'
  
  const errorMessage = error.message?.toLowerCase() || ''
  const errorString = error.toString?.()?.toLowerCase() || ''
  
  if (errorMessage.includes('failed to fetch') || errorString.includes('failed to fetch')) {
    return 'network'
  }
  
  if (errorMessage.includes('rate limit') || errorString.includes('rate limit')) {
    return 'rate_limit'
  }
  
  if (errorMessage.includes('unauthorized') || errorString.includes('unauthorized')) {
    return 'auth'
  }
  
  if (errorMessage.includes('timeout') || errorString.includes('timeout')) {
    return 'timeout'
  }
  
  return 'database'
}

// Funzione per ottenere un messaggio di errore user-friendly
const getUserFriendlyError = (errorType: string, retryAttempt: number): string => {
  switch (errorType) {
    case 'network':
      if (retryAttempt < maxRetries) {
        return `Problema di connessione. Tentativo ${retryAttempt + 1} di ${maxRetries}...`
      }
      return 'Impossibile connettersi al server. Verifica la tua connessione internet e riprova più tardi.'
    
    case 'rate_limit':
      return 'Troppi tentativi. Attendi qualche minuto prima di riprovare.'
    
    case 'auth':
      return 'Errore di autenticazione. Ricarica la pagina e riprova.'
    
    case 'timeout':
      return 'La richiesta ha impiegato troppo tempo. Riprova più tardi.'
    
    case 'database':
      return 'Errore del database. Il nostro team è stato notificato. Riprova più tardi.'
    
    default:
      return 'Si è verificato un errore imprevisto. Riprova più tardi.'
  }
}

const sendEmailNotification = async (formData: any) => {
  try {
    const { data, error } = await supabase.functions.invoke('send-contact-email', {
      body: {
        name: `${formData.name} ${formData.surname}`,
        email: formData.email,
        message: formData.message
      }
    })

    if (error) {
      console.warn('Email notification failed:', error)
    } else {
      console.log('Email sent successfully:', data)
    }
  } catch (emailError) {
    console.warn('Email notification failed:', emailError)
  }
}

// Funzione di retry con backoff esponenziale
const retryWithBackoff = async (fn: () => Promise<any>, attempt: number = 0): Promise<any> => {
  try {
    return await fn()
  } catch (error) {
    const errorType = getErrorType(error)
    
    // Non fare retry per errori di rate limit o auth
    if (errorType === 'rate_limit' || errorType === 'auth') {
      throw error
    }
    
    if (attempt < maxRetries - 1) {
      const delay = Math.pow(2, attempt) * 1000 // 1s, 2s, 4s
      console.log(`Retry attempt ${attempt + 1} after ${delay}ms`)
      
      // Aggiorna l'errore per mostrare il tentativo
      error.value = getUserFriendlyError(errorType, attempt)
      
      await new Promise(resolve => setTimeout(resolve, delay))
      return retryWithBackoff(fn, attempt + 1)
    }
    
    throw error
  }
}

const handleSubmit = async (e: Event) => {
  e.preventDefault()
  
  // Controlla cooldown
  if (cooldownTime.value > 0) {
    error.value = `Attendi ${cooldownTime.value} secondi prima di inviare un altro messaggio`
    return
  }
  
  // Controlla accettazione privacy
  if (!form.value.privacy_accepted) {
    error.value = 'Devi accettare l\'informativa sulla privacy per continuare'
    return
  }
  
  loading.value = true
  error.value = ''
  success.value = false
  retryCount.value = 0

  try {
    // Validazione avanzata lato client
    const nameValidation = validateName(form.value.name, 'name')
    const surnameValidation = validateName(form.value.surname, 'surname')
    
    if (!nameValidation.valid) {
      throw new Error(`Nome non valido: ${nameValidation.reason}`)
    }
    
    if (!surnameValidation.valid) {
      throw new Error(`Cognome non valido: ${surnameValidation.reason}`)
    }
    
    if (form.value.message.length < 10 || form.value.message.length > 2000) {
      throw new Error('Il messaggio deve essere tra 10 e 2000 caratteri')
    }
    
    // Controlla email valida con regex più rigorosa
    const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
    if (!emailRegex.test(form.value.email)) {
      throw new Error('Inserisci un indirizzo email valido')
    }
    
    // Verifica email se non già fatto
    if (emailValid.value === null) {
      await verifyEmail(form.value.email)
    }
    
    // Blocca se email non valida
    if (emailValid.value === false) {
      throw new Error('L\'indirizzo email fornito non è valido, è temporaneo, sembra essere di test o non esiste')
    }
    
    // Calcola spam score
    const spamScore = calculateSpamScore(form.value)
    if (spamScore >= 6) {
      throw new Error('Il messaggio è stato identificato come spam o di test. Se pensi che sia un errore, contattaci direttamente al telefono.')
    }
    
    const clientInfo = getClientInfo()
    
    // Prima controlla la connettività
    const isConnected = await checkSupabaseConnection()
    if (!isConnected) {
      throw new Error('Impossibile connettersi al database. Verifica la tua connessione internet.')
    }
    
    // Salva nel database con retry logic
    const insertOperation = async () => {
      const { error: insertError } = await supabase
        .from('contact_requests')
        .insert([{
          name: `${form.value.name.trim()} ${form.value.surname.trim()}`,
          email: form.value.email.toLowerCase().trim(),
          message: form.value.message.trim(),
          status: 'new',
          user_agent: clientInfo.userAgent,
          spam_score: spamScore
        }])

      if (insertError) {
        throw insertError
      }
    }

    await retryWithBackoff(insertOperation)

    // Invia email solo se spam score è basso
    if (spamScore < 4) {
      await sendEmailNotification({
        name: form.value.name,
        surname: form.value.surname,
        email: form.value.email,
        message: form.value.message
      })
    }

    success.value = true
    startCooldown() // Avvia cooldown
    
    // Reset form
    form.value = {
      name: '',
      surname: '',
      email: '',
      message: '',
      privacy_accepted: false,
      status: 'new',
      created_at: new Date().toISOString()
    }
    
    // Reset validation states
    emailValid.value = null
    emailVerificationMessage.value = ''
    nameValid.value = null
    surnameValid.value = null
    
  } catch (err) {
    console.error('Error:', err)
    const errorType = getErrorType(err)
    error.value = getUserFriendlyError(errorType, retryCount.value)
    
    // Se è un errore di rete, suggerisci azioni specifiche
    if (errorType === 'network') {
      error.value += '\n\nSuggerimenti:\n• Controlla la tua connessione internet\n• Prova a ricaricare la pagina\n• Se il problema persiste, contattaci direttamente'
    }
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <section id="contattaci" class="relative min-h-screen flex items-center justify-center py-20">
    <!-- Background Image -->
    <div class="absolute inset-0 z-0">
      <img 
        src="https://images.unsplash.com/photo-1583121274602-3e2820c69888?q=80&w=2000" 
        alt="Background" 
        class="w-full h-full object-cover"
      />
      <div class="absolute inset-0 bg-black/90"></div>
    </div>

    <div class="container relative z-10">
      <div class="max-w-2xl mx-auto">
        <div class="text-center mb-12" data-aos="fade-up">
          <h2 class="text-4xl md:text-5xl font-bold mb-4">{{ t('contact.title') }}</h2>
          <p class="text-xl text-zinc-400">
            {{ t('contact.subtitle') }}
          </p>
        </div>
        
        <div 
          class="bg-zinc-900/50 backdrop-blur-sm border border-zinc-800 rounded-lg overflow-hidden shadow-xl"
          data-aos="fade-up"
          data-aos-delay="200"
        >
          <div v-if="success" class="p-8 text-center">
            <div class="bg-green-900/30 border border-green-500/50 rounded-lg p-8">
              <i class="fas fa-check-circle text-4xl text-green-500 mb-4"></i>
              <h3 class="text-2xl font-bold mb-4">{{ t('contact.form.success.title') }}</h3>
              <p class="text-lg text-zinc-300 mb-4">
                {{ t('contact.form.success.message') }}
              </p>
              <p class="text-sm text-zinc-400">
                📧 Una copia della richiesta è stata inviata anche a ilsorpassodilorenzobasile@gmail.com
              </p>
            </div>
          </div>
          
          <form 
            v-else
            @submit="handleSubmit" 
            class="p-8 space-y-6"
          >
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div class="group">
                <label for="name" class="block text-sm font-medium mb-2 text-accent">Nome *</label>
                <input 
                  v-model="form.name"
                  type="text" 
                  id="name" 
                  required
                  maxlength="50"
                  @input="validateNameField(form.name, 'name')"
                  class="w-full px-4 py-3 bg-black/30 border border-zinc-700 rounded-lg focus:border-accent focus:ring-1 focus:ring-accent focus:outline-none transition-colors group-hover:border-accent"
                  :class="{
                    'border-green-500': nameValid === true,
                    'border-red-500': nameValid === false
                  }"
                  placeholder="Il tuo nome"
                />
                <div v-if="nameValid === false" class="text-xs text-red-400 mt-1">
                  Nome non valido
                </div>
                <div v-else-if="nameValid === true" class="text-xs text-green-400 mt-1">
                  Nome verificato ✓
                </div>
              </div>
              
              <div class="group">
                <label for="surname" class="block text-sm font-medium mb-2 text-accent">Cognome *</label>
                <input 
                  v-model="form.surname"
                  type="text" 
                  id="surname" 
                  required
                  maxlength="50"
                  @input="validateNameField(form.surname, 'surname')"
                  class="w-full px-4 py-3 bg-black/30 border border-zinc-700 rounded-lg focus:border-accent focus:ring-1 focus:ring-accent focus:outline-none transition-colors group-hover:border-accent"
                  :class="{
                    'border-green-500': surnameValid === true,
                    'border-red-500': surnameValid === false
                  }"
                  placeholder="Il tuo cognome"
                />
                <div v-if="surnameValid === false" class="text-xs text-red-400 mt-1">
                  Cognome non valido
                </div>
                <div v-else-if="surnameValid === true" class="text-xs text-green-400 mt-1">
                  Cognome verificato ✓
                </div>
              </div>
            </div>
            
            <div class="group">
              <label for="email" class="block text-sm font-medium mb-2 text-accent">{{ t('contact.form.email') }} *</label>
              <div class="relative">
                <input 
                  v-model="form.email"
                  type="email" 
                  id="email" 
                  required
                  @input="handleEmailChange"
                  class="w-full px-4 py-3 bg-black/30 border border-zinc-700 rounded-lg focus:border-accent focus:ring-1 focus:ring-accent focus:outline-none transition-colors group-hover:border-accent"
                  :class="{
                    'border-green-500': emailValid === true,
                    'border-red-500': emailValid === false,
                    'border-yellow-500': emailVerifying
                  }"
                  :placeholder="t('contact.form.emailPlaceholder')"
                />
                <div v-if="emailVerifying" class="absolute right-3 top-1/2 transform -translate-y-1/2">
                  <i class="fas fa-spinner fa-spin text-yellow-500"></i>
                </div>
                <div v-else-if="emailValid === true" class="absolute right-3 top-1/2 transform -translate-y-1/2">
                  <i class="fas fa-check text-green-500"></i>
                </div>
                <div v-else-if="emailValid === false" class="absolute right-3 top-1/2 transform -translate-y-1/2">
                  <i class="fas fa-times text-red-500"></i>
                </div>
              </div>
              <div v-if="emailVerificationMessage" class="text-xs mt-1" 
                   :class="{
                     'text-green-400': emailValid === true,
                     'text-red-400': emailValid === false,
                     'text-yellow-400': emailVerifying
                   }">
                {{ emailVerificationMessage }}
              </div>
            </div>
            
            <div class="group">
              <label for="message" class="block text-sm font-medium mb-2 text-accent">{{ t('contact.form.message') }} *</label>
              <textarea 
                v-model="form.message"
                id="message" 
                rows="5" 
                required
                maxlength="2000"
                class="w-full px-4 py-3 bg-black/30 border border-zinc-700 rounded-lg focus:border-accent focus:ring-1 focus:ring-accent focus:outline-none transition-colors group-hover:border-accent resize-none"
                :placeholder="t('contact.form.messagePlaceholder')"
              ></textarea>
              <div class="text-xs text-zinc-500 mt-1">
                {{ form.message.length }}/2000 caratteri
              </div>
            </div>

            <!-- Privacy Policy Checkbox -->
            <div class="flex items-start space-x-3">
              <input
                v-model="form.privacy_accepted"
                type="checkbox"
                id="privacy"
                required
                class="mt-1 h-4 w-4 text-accent bg-black/30 border-zinc-700 rounded focus:ring-accent focus:ring-2"
              />
              <label for="privacy" class="text-sm text-zinc-300 leading-relaxed">
                Accetto l'<a href="#" class="text-accent hover:underline">informativa sulla privacy</a> e autorizzo il trattamento dei miei dati personali per rispondere alla mia richiesta. I dati saranno conservati per il tempo necessario a gestire la richiesta e cancellati automaticamente dopo 2 anni, salvo diversa richiesta. *
              </label>
            </div>
            
            <div v-if="error" class="p-4 bg-red-900/30 border border-red-500/50 rounded-lg text-red-400 text-sm whitespace-pre-line">
              {{ error }}
            </div>
            
            <button 
              type="submit" 
              class="btn-primary w-full transform hover:scale-105 transition-all duration-300 disabled:opacity-50 disabled:hover:scale-100"
              :disabled="loading || cooldownTime > 0 || emailValid === false || nameValid === false || surnameValid === false || !form.privacy_accepted"
            >
              <i class="fas fa-paper-plane mr-2" :class="{ 'fa-spin': loading }"></i>
              <span v-if="cooldownTime > 0">
                Attendi {{ cooldownTime }}s
              </span>
              <span v-else>
                {{ loading ? t('contact.form.sending') : t('contact.form.submit') }}
              </span>
            </button>

            <!-- Connection Status Indicator -->
            <div v-if="loading" class="text-center">
              <div class="inline-flex items-center space-x-2 text-sm text-zinc-400">
                <i class="fas fa-wifi text-accent"></i>
                <span>Connessione al server in corso...</span>
              </div>
            </div>

            <!-- GDPR Info -->
            <div class="text-xs text-zinc-500 bg-zinc-800/30 p-4 rounded-lg">
              <h4 class="font-semibold text-zinc-400 mb-2">🔒 Informazioni sui tuoi dati</h4>
              <ul class="space-y-1">
                <li>• I tuoi dati sono protetti secondo il GDPR (Regolamento UE 2016/679)</li>
                <li>• Utilizziamo i dati solo per rispondere alla tua richiesta</li>
                <li>• Non condividiamo i dati con terze parti</li>
                <li>• Puoi richiedere la cancellazione in qualsiasi momento</li>
                <li>• I dati sono conservati su server sicuri in Europa</li>
              </ul>
            </div>
          </form>
        </div>
      </div>
    </div>
  </section>
</template>