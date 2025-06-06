import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
}

// Gmail SMTP configuration
const GMAIL_USER = 'ilsorpassodilorenzobasile@gmail.com'
const GMAIL_APP_PASSWORD = 'ermk ydkx xkmx oury'

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

    // Create email content
    const emailContent = `
Subject: Nuova richiesta di contatto da ${name}
From: ${GMAIL_USER}
To: ${GMAIL_USER}
Content-Type: text/html; charset=UTF-8

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Nuova richiesta di contatto</title>
</head>
<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="border-bottom: 3px solid #DC2626; padding-bottom: 20px; margin-bottom: 30px;">
        <h1 style="color: #DC2626; margin: 0;">Il Sorpasso</h1>
        <h2 style="color: #333; margin: 10px 0 0 0;">Nuova richiesta di contatto</h2>
    </div>
    
    <div style="background-color: #f9f9f9; padding: 25px; border-radius: 8px; margin: 20px 0;">
        <h3 style="margin-top: 0; color: #333; border-bottom: 1px solid #ddd; padding-bottom: 10px;">
            Dettagli del contatto:
        </h3>
        
        <table style="width: 100%; border-collapse: collapse;">
            <tr>
                <td style="padding: 8px 0; font-weight: bold; color: #555; width: 80px;">Nome:</td>
                <td style="padding: 8px 0; color: #333;">${name}</td>
            </tr>
            <tr>
                <td style="padding: 8px 0; font-weight: bold; color: #555;">Email:</td>
                <td style="padding: 8px 0; color: #333;">
                    <a href="mailto:${email}" style="color: #DC2626; text-decoration: none;">${email}</a>
                </td>
            </tr>
        </table>
        
        <h4 style="color: #333; margin: 25px 0 15px 0; border-bottom: 1px solid #ddd; padding-bottom: 8px;">
            Messaggio:
        </h4>
        <div style="background-color: white; padding: 20px; border-left: 4px solid #DC2626; border-radius: 4px; line-height: 1.6;">
            ${message.replace(/\n/g, '<br>')}
        </div>
    </div>
    
    <div style="margin-top: 30px; padding: 20px; background-color: #f0f0f0; border-radius: 8px; border: 1px solid #ddd;">
        <p style="margin: 0 0 10px 0; font-size: 14px; color: #666;">
            <strong>Ricevuto il:</strong> ${new Date().toLocaleString('it-IT', {
              timeZone: 'Europe/Rome',
              year: 'numeric',
              month: 'long',
              day: 'numeric',
              hour: '2-digit',
              minute: '2-digit'
            })}
        </p>
        <p style="margin: 0; font-size: 12px; color: #888;">
            Puoi rispondere direttamente a questa email o accedere alla dashboard admin per gestire la richiesta.
        </p>
    </div>
    
    <div style="margin-top: 30px; text-align: center; padding-top: 20px; border-top: 1px solid #eee;">
        <p style="margin: 0; font-size: 12px; color: #999;">
            Questo messaggio è stato inviato automaticamente dal sito web Il Sorpasso
        </p>
    </div>
</body>
</html>
    `.trim()

    // Send email using Gmail SMTP
    const smtpResponse = await fetch('https://api.smtp2go.com/v3/email/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Smtp2go-Api-Key': 'api-key-here' // You'll need to get this
      },
      body: JSON.stringify({
        api_key: 'your-smtp2go-api-key',
        to: [GMAIL_USER],
        sender: GMAIL_USER,
        subject: `Nuova richiesta di contatto da ${name}`,
        html_body: emailContent,
        text_body: `Nuova richiesta di contatto da ${name}\n\nEmail: ${email}\n\nMessaggio:\n${message}`
      })
    })

    // Alternative: Use Resend (recommended)
    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': 'Bearer re_123456789', // You'll need your Resend API key
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        from: 'Il Sorpasso <noreply@yourdomain.com>',
        to: [GMAIL_USER],
        subject: `Nuova richiesta di contatto da ${name}`,
        html: emailContent,
        reply_to: email
      })
    })

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: 'Email sent successfully',
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
    console.error('Error sending email:', error)
    
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Failed to send email',
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