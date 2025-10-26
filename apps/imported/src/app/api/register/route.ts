import { NextRequest } from 'next/server'
import { prisma } from '@/lib/prisma'
import bcrypt from 'bcryptjs'

export async function POST(req: NextRequest) {
  try {
    const { email, password } = await req.json()
    if (!email || !password) return new Response(JSON.stringify({ error: 'Email and password required' }), { status: 400 })
    const exists = await prisma.user.findUnique({ where: { email } })
    if (exists) return new Response(JSON.stringify({ error: 'User already exists' }), { status: 400 })
    const passwordHash = await bcrypt.hash(password, 10)
    await prisma.user.create({ data: { email, passwordHash } })
    return new Response(JSON.stringify({ ok: true }), { status: 201 })
  } catch (e) {
    return new Response(JSON.stringify({ error: 'Failed' }), { status: 500 })
  }
}
