'use client'
import { useState } from 'react'
import { Button } from '@shadow/ui'

export default function PricingPage() {
  const [loading, setLoading] = useState(false)
  async function checkout() {
    setLoading(true)
    const res = await fetch('/api/checkout/session', { method: 'POST' })
    const data = await res.json()
    if (data?.url) window.location.href = data.url
    setLoading(false)
  }
  return (
    <section className="space-y-6">
      <h1 className="text-2xl font-semibold">Pricing</h1>
      <div className="card">
        <h2 className="text-xl font-medium mb-2">Starter Plan</h2>
        <p className="text-sm text-gray-600 dark:text-gray-300 mb-4">$10 one-time</p>
        <Button onClick={checkout} disabled={loading}>{loading ? 'Redirecting…' : 'Buy now'}</Button>
      </div>
    </section>
  )
}
