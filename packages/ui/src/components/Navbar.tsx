import Link from 'next/link'
import { AppSwitcher } from './AppSwitcher'

export function Navbar() {
  return (
    <header className="border-b border-gray-200 dark:border-gray-800">
      <nav className="max-w-5xl mx-auto px-4 flex h-14 items-center justify-between">
        <Link href="/" className="font-semibold">ShadowThrow</Link>
        <div className="flex items-center gap-3 text-sm">
          <Link href="/dashboard">Dashboard</Link>
          <AppSwitcher />
        </div>
      </nav>
    </header>
  )
}
