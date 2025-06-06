import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
}

// Lista di domini email temporanei/sospetti
const suspiciousDomains = [
  'tempmail.org', '10minutemail.com', 'guerrillamail.com', 'mailinator.com',
  'throwaway.email', 'temp-mail.org', 'getnada.com', 'maildrop.cc',
  'sharklasers.com', 'grr.la', 'guerrillamailblock.com', 'pokemail.net',
  'spam4.me', 'bccto.me', 'chacuo.net', 'dispostable.com', 'emailondeck.com'
]

// Lista di provider email legittimi
const legitimateProviders = [
  'gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'live.com',
  'icloud.com', 'protonmail.com', 'fastmail.com', 'zoho.com', 'aol.com',
  'libero.it', 'virgilio.it', 'alice.it', 'tin.it', 'tiscali.it',
  'email.it', 'inwind.it', 'kataweb.it', 'iol.it', 'supereva.it'
]

// Verifica formato email
const isValidEmailFormat = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

// Verifica se il dominio è sospetto
const isSuspiciousDomain = (email: string): boolean => {
  const domain = email.split('@')[1]?.toLowerCase()
  return suspiciousDomains.some(suspDomain => 
    domain === suspDomain || domain.includes(suspDomain)
  )
}

// Verifica se il dominio è legittimo
const isLegitimateProvider = (email: string): boolean => {
  const domain = email.split('@')[1]?.toLowerCase()
  return legitimateProviders.includes(domain)
}

// Verifica MX record (semplificata)
const checkMXRecord = async (domain: string): Promise<boolean> => {
  try {
    // In un ambiente reale, useresti un servizio di verifica email
    // Qui facciamo una verifica base del dominio
    const response = await fetch(`https://dns.google/resolve?name=${domain}&type=MX`)
    const data = await response.json()
    
    return data.Answer && data.Answer.length > 0
  } catch (error) {
    console.warn('MX check failed:', error)
    return true // In caso di errore, assumiamo che sia valido
  }
}

// Verifica email usando servizio esterno (opzionale)
const verifyEmailWithService = async (email: string): Promise<{
  valid: boolean
  reason?: string
  confidence: number
}> => {
  try {
    // Esempio con Abstract API (sostituisci con la tua API key)
    // const response = await fetch(`https://emailvalidation.abstractapi.com/v1/?api_key=YOUR_API_KEY&email=${email}`)
    // const data = await response.json()
    
    // Per ora, facciamo una verifica locale
    const domain = email.split('@')[1]?.toLowerCase()
    
    if (isSuspiciousDomain(email)) {
      return { valid: false, reason: 'Temporary/suspicious email provider', confidence: 90 }
    }
    
    if (isLegitimateProvider(email)) {
      return { valid: true, confidence: 95 }
    }
    
    // Verifica MX record per domini sconosciuti
    const hasMX = await checkMXRecord(domain)
    if (!hasMX) {
      return { valid: false, reason: 'Domain has no MX record', confidence: 85 }
    }
    
    return { valid: true, confidence: 70 }
    
  } catch (error) {
    console.error('Email verification failed:', error)
    return { valid: true, confidence: 50 } // In caso di errore, assumiamo valido
  }
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    })
  }

  try {
    const { email } = await req.json()

    if (!email) {
      throw new Error('Email is required')
    }

    // Verifica formato base
    if (!isValidEmailFormat(email)) {
      return new Response(
        JSON.stringify({
          valid: false,
          reason: 'Invalid email format',
          confidence: 100
        }),
        {
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      )
    }

    // Verifica avanzata
    const verification = await verifyEmailWithService(email)

    return new Response(
      JSON.stringify({
        email,
        ...verification,
        timestamp: new Date().toISOString()
      }),
      {
        headers: {
          'Content-Type': 'application/json',
          ...corsHeaders,
        },
      }
    )

  } catch (error) {
    console.error('Error verifying email:', error)
    
    return new Response(
      JSON.stringify({
        valid: true, // In caso di errore, assumiamo valido per non bloccare utenti legittimi
        reason: 'Verification service unavailable',
        confidence: 50,
        error: error.message
      }),
      {
        status: 200, // Non restituiamo errore per non bloccare il form
        headers: {
          'Content-Type': 'application/json',
          ...corsHeaders,
        },
      }
    )
  }
})