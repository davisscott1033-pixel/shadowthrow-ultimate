import Stripe from 'stripe'

export async function POST() {
  const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, { apiVersion: '2024-09-30.acacia' as any })
  const domain = process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3001'
  const session = await stripe.checkout.sessions.create({
    mode: 'payment',
    line_items: [{
      price_data: {
        currency: 'usd',
        unit_amount: 1000,
        product_data: { name: 'ShadowThrow Starter' }
      },
      quantity: 1
    }],
    success_url: `${domain}/pricing?status=success`,
    cancel_url: `${domain}/pricing?status=cancel`
  })
  return new Response(JSON.stringify({ url: session.url }), { headers: { 'content-type': 'application/json' } })
}
