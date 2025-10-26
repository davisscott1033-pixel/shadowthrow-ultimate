Stripe setup for apps/imported
------------------------------
1) Add env vars to apps/imported/.env.local (or root .env.local):
   STRIPE_PUBLISHABLE_KEY=pk_test_...
   STRIPE_SECRET_KEY=sk_test_...
   STRIPE_WEBHOOK_SECRET=whsec_...
   NEXT_PUBLIC_SITE_URL=http://localhost:3001

2) Install any missing deps (already in package.json if you used the full app I provided):
   pnpm --filter imported add stripe

3) Start dev:
   pnpm --filter imported dev

4) (Optional) Test webhooks with Stripe CLI:
   stripe listen --forward-to localhost:3001/api/stripe/webhook
