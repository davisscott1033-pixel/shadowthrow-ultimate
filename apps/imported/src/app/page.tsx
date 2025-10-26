import Link from 'next/link'
import { ArrowRight } from 'lucide-react'

export default function Home() {
  return (
    <section className="py-16">
      <div className="card text-center">
        <h1 className="text-3xl font-semibold mb-2">Welcome to ShadowThrow</h1>
        <p className="text-gray-600 dark:text-gray-300 mb-6">A ready-to-run Next.js template with Tailwind, Prisma (SQLite), and NextAuth.</p>
        <div className="flex justify-center gap-3">
          <Link href="/register" className="btn">Get started</Link>
          <Link href="/dashboard" className="btn">Go to dashboard <ArrowRight size={16} /></Link>
        </div>
      </div>
    </section>
  )
}
