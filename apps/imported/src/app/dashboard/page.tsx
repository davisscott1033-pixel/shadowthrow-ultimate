import { getServerSession } from 'next-auth'
import { authOptions } from '@/lib/auth'

export default async function DashboardPage() {
  const session = await getServerSession(authOptions)
  return (
    <div className="space-y-2">
      <h2 className="text-2xl font-semibold">Dashboard</h2>
      <p>Welcome, <strong>{session?.user?.email}</strong>.</p>
      <p>This route is protected by middleware and requires authentication.</p>
    </div>
  )
}
