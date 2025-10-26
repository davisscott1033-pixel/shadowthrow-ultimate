import type { Metadata } from 'next'
import './globals.css'
import Link from 'next/link'
import { getServerSession } from 'next-auth'
import { authOptions } from '@/lib/auth'

export const metadata: Metadata = {
  title: 'ShadowThrow',
  description: 'Completed app template (Tailwind + Prisma + NextAuth)'
}

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const session = await getServerSession(authOptions)
  return (
    <html lang="en">
      <body className="bg-white text-gray-900 dark:bg-gray-950 dark:text-gray-100">
        <header className="border-b border-gray-200 dark:border-gray-800">
          <nav className="container flex h-14 items-center justify-between">
            <Link href="/" className="font-semibold">ShadowThrow</Link>
            <div className="flex items-center gap-3 text-sm">
              <Link href="/dashboard">Dashboard</Link>
              {session ? (
                <form action="/api/auth/signout" method="post">
                  <button className="btn" type="submit">Sign out</button>
                </form>
              ) : (
                <>
                  <Link className="btn" href="/login">Log in</Link>
                  <Link className="btn" href="/register">Register</Link>
                </>
              )}
            </div>
          </nav>
        </header>
        <main className="container py-8">{children}</main>
        <footer className="container py-10 text-center text-xs text-gray-500">Â© {new Date().getFullYear()} ShadowThrow</footer>
      </body>
    </html>
  )
}

