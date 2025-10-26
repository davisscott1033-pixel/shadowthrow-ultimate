import Stripe from 'stripe'
import { NextRequest } from 'next/server'

export const config = { api: { bodyParser: false } } as any

export async function POST(req: NextRequest) {
  const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, { apiVersion: '2024-09-30.acacia' as any })
  const sig = req.headers.get('stripe-signature')!
  const buf = Buffer.from(await req.arrayBuffer())
  let event: Stripe.Event
  try {
    event = stripe.webhooks.constructEvent(buf, sig, process.env.STRIPE_WEBHOOK_SECRET!)
  } catch (err: any) {
    return new Response(`Webhook Error: ${err.message}`, { status: 400 })
  }
  // Handle event
  switch (event.type) {
    case 'checkout.session.completed':
      // TODO: mark order as paid
      break
  }
  return new Response('ok', { status: 200 })
}
