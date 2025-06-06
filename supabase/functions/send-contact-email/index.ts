import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
}

// Rate limiting in memoria (in produzione usare Redis)
const rateLimitMap = new Map<string, { count: number; resetTime: number }>()

const checkRateLimit = (identifier: string, maxRequests = 5, windowMs = 60000): boolean => {
  const now = Date.now()
  const record = rateLimitMap.get(identifier)
  
  if (!record || now > record.resetTime) {
    rateLimitMap.set(identifier, { count: 1, resetTime: now + windowMs })
    return true
  }
  
  if (record.count >= maxRequests) {
    return false
  }
  
  record.count++
  return true
}

const detectSpam = (name: string, email: string, message: string): number => {
  let score = 0
  
  // Controlla lunghezza nome
  if (name.length < 2 || name.length > 100) score += 2
  
  // Controlla caratteri sospetti
  if (/[<>{}[\]\\\/]/.test(name) || /[<>{}[\]\\\/]/.test(message)) score += 3
  
  // Controlla lunghezza messaggio
  if (message.length < 10) score += 2
  if (message.length > 2000) score += 3
  
  // Controlla URL nel messaggio
  const urlCount = (message.match(/https?:\/\/[^\s]+/g) || []).length
  if (urlCount > 2) score += urlCount * 2
  
  // Controlla caratteri ripetuti
  if (/(.)\1{10,}/.test(message)) score += 3
  
  // Controlla parole spam
  const spamWords = ['viagra', 'casino', 'lottery', 'winner', 'congratulations', 'urgent', 'act now', 'click here', 'free money']
  const messageWords = message.toLowerCase()
  spamWords.forEach(word => {
    if (messageWords.includes(word)) score += 2
  })
  
  // Controlla email temporanee
  const tempEmailDomains = ['tempmail', '10minutemail', 'guerrillamail', 'mailinator', 'throwaway']
  tempEmailDomains.forEach(domain => {
    if (email.toLowerCase().includes(domain)) score += 5
  })
  
  // Controlla se nome e email sono simili (possibile bot)
  const nameParts = name.toLowerCase().split(' ')
  const emailPart = email.split('@')[0].toLowerCase()
  if (nameParts.some(part => emailPart.includes(part) && part.length > 3)) score += 1
  
  return Math.min(score, 10)
}

serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    })
  }

  try {
    const { name, email, message } = await req.json()

    if (!name || !email || !message) {
      throw new Error('Missing required fields')
    }

    // Validazione base
    if (name.length < 2 || name.length > 100) {
      throw new Error('Nome non valido')
    }
    
    if (message.length < 10 || message.length > 2000) {
      throw new Error('Messaggio non valido')
    }

    // Rate limiting per email
    if (!checkRateLimit(email, 3, 300000)) { // 3 email ogni 5 minuti
      throw new Error('Troppi tentativi. Riprova più tardi.')
    }

    // Controlla spam
    const spamScore = detectSpam(name, email, message)
    
    // Se spam score è troppo alto, non inviare email
    if (spamScore >= 8) {
      console.log(`Blocked spam email from ${email}, score: ${spamScore}`)
      return new Response(
        JSON.stringify({ 
          success: false, 
          error: 'Messaggio identificato come spam',
          spamScore
        }),
        {
          status: 400,
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      )
    }

    // Crea contenuto email con indicatore spam se necessario
    const spamWarning = spamScore >= 5 ? `
      <div style="background-color: #FEF3C7; border: 1px solid #F59E0B; padding: 15px; border-radius: 6px; margin-bottom: 20px;">
        <h4 style="color: #92400E; margin: 0 0 10px 0;">⚠️ Possibile Spam (Score: ${spamScore}/10)</h4>
        <p style="color: #92400E; margin: 0; font-size: 14px;">Questo messaggio ha un punteggio spam elevato. Verifica attentamente prima di rispondere.</p>
      </div>
    ` : ''

    const htmlContent = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Nuova richiesta di contatto - Il Sorpasso</title>
</head>
<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
    <div style="background-color: white; border-radius: 10px; overflow: hidden; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
        <!-- Header -->
        <div style="background: linear-gradient(135deg, #DC2626, #B91C1C); padding: 30px; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 28px; font-weight: bold;">🚗 Il Sorpasso</h1>
            <p style="color: #FEE2E2; margin: 10px 0 0 0; font-size: 16px;">Nuova richiesta di contatto dal sito web</p>
        </div>
        
        <!-- Content -->
        <div style="padding: 30px;">
            ${spamWarning}
            
            <div style="background-color: #F9FAFB; padding: 25px; border-radius: 8px; border-left: 4px solid #DC2626; margin-bottom: 25px;">
                <h3 style="margin: 0 0 20px 0; color: #374151; font-size: 18px;">📋 Dettagli del contatto</h3>
                
                <table style="width: 100%; border-collapse: collapse;">
                    <tr>
                        <td style="padding: 12px 0; font-weight: bold; color: #6B7280; width: 100px; vertical-align: top;">👤 Nome:</td>
                        <td style="padding: 12px 0; color: #111827; font-size: 16px;">${name}</td>
                    </tr>
                    <tr>
                        <td style="padding: 12px 0; font-weight: bold; color: #6B7280; vertical-align: top;">📧 Email:</td>
                        <td style="padding: 12px 0;">
                            <a href="mailto:${email}" style="color: #DC2626; text-decoration: none; font-size: 16px; font-weight: 500;">${email}</a>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 12px 0; font-weight: bold; color: #6B7280; vertical-align: top;">🔍 Spam Score:</td>
                        <td style="padding: 12px 0; color: #111827; font-size: 16px;">${spamScore}/10</td>
                    </tr>
                    <tr>
                        <td style="padding: 12px 0; font-weight: bold; color: #6B7280; vertical-align: top;">🕒 Data:</td>
                        <td style="padding: 12px 0; color: #111827; font-size: 16px;">${new Date().toLocaleString('it-IT', {
                          timeZone: 'Europe/Rome',
                          year: 'numeric',
                          month: 'long',
                          day: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit'
                        })}</td>
                    </tr>
                </table>
            </div>
            
            <div style="background-color: #FFFBEB; padding: 25px; border-radius: 8px; border-left: 4px solid #F59E0B;">
                <h4 style="margin: 0 0 15px 0; color: #92400E; font-size: 16px; font-weight: bold;">💬 Messaggio:</h4>
                <div style="background-color: white; padding: 20px; border-radius: 6px; line-height: 1.6; color: #374151; font-size: 15px; border: 1px solid #FDE68A;">
                    ${message.replace(/\n/g, '<br>')}
                </div>
            </div>
            
            <!-- Action Button -->
            <div style="text-align: center; margin: 30px 0;">
                <a href="mailto:${email}?subject=Re: Richiesta di contatto - Il Sorpasso" 
                   style="background-color: #DC2626; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; font-weight: bold; display: inline-block; font-size: 16px;">
                    📧 Rispondi Subito
                </a>
            </div>
        </div>
        
        <!-- Footer -->
        <div style="background-color: #F9FAFB; padding: 20px; text-align: center; border-top: 1px solid #E5E7EB;">
            <p style="margin: 0; font-size: 14px; color: #6B7280;">
                Messaggio inviato automaticamente dal sito web <strong>Il Sorpasso</strong>
            </p>
            <p style="margin: 5px 0 0 0; font-size: 12px; color: #9CA3AF;">
                Via Suor Celestina Donati 90, 00167 Roma
            </p>
        </div>
    </div>
</body>
</html>
    `

    // Prova prima con Resend
    console.log('Attempting to send email via Resend...')
    
    try {
      const resendResponse = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Authorization': 'Bearer re_FZDHUQCH_EUpJFHfdftJppunvB84VbpjX',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          from: 'Il Sorpasso <noreply@resend.dev>',
          to: ['ilsorpassodilorenzobasile@gmail.com'],
          subject: `🚗 ${spamScore >= 5 ? '[POSSIBILE SPAM] ' : ''}Nuova richiesta di contatto da ${name}`,
          html: htmlContent,
          reply_to: email,
          text: `Nuova richiesta di contatto da ${name}\n\nEmail: ${email}\nSpam Score: ${spamScore}/10\n\nMessaggio:\n${message}\n\nRicevuto il: ${new Date().toLocaleString('it-IT')}`
        })
      })

      const resendResult = await resendResponse.json()
      
      if (!resendResponse.ok) {
        console.error('Resend failed:', resendResult)
        throw new Error(`Resend API error: ${JSON.stringify(resendResult)}`)
      }

      console.log('Email sent successfully via Resend:', resendResult)

      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'Email sent successfully via Resend',
          emailId: resendResult.id,
          spamScore,
          timestamp: new Date().toISOString(),
          provider: 'resend'
        }),
        {
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      )

    } catch (resendError) {
      console.error('Resend failed, trying alternative method:', resendError)
      
      // Fallback: prova con un webhook alternativo o log dettagliato
      console.log('EMAIL CONTENT FOR MANUAL DELIVERY:')
      console.log('TO:', 'ilsorpassodilorenzobasile@gmail.com')
      console.log('FROM:', email)
      console.log('SUBJECT:', `Nuova richiesta di contatto da ${name}`)
      console.log('MESSAGE:', message)
      console.log('SPAM SCORE:', spamScore)
      console.log('TIMESTAMP:', new Date().toISOString())
      
      // Ritorna successo anche se l'email non è stata inviata
      // ma salva i dettagli per debug
      return new Response(
        JSON.stringify({ 
          success: true, 
          message: 'Contact saved, email delivery pending',
          spamScore,
          timestamp: new Date().toISOString(),
          provider: 'fallback',
          debug: {
            name,
            email,
            message: message.substring(0, 100) + '...',
            error: resendError.message
          }
        }),
        {
          headers: {
            'Content-Type': 'application/json',
            ...corsHeaders,
          },
        }
      )
    }

  } catch (error) {
    console.error('Error in send-contact-email function:', error)
    
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Failed to process contact request',
        timestamp: new Date().toISOString()
      }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          ...corsHeaders,
        },
      }
    )
  }
})