import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
  const email = 'admin@shadowthrow.dev'
  const password = 'change-me'
  const passwordHash = await bcrypt.hash(password, 10)
  await prisma.user.upsert({
    where: { email },
    update: {},
    create: { email, passwordHash }
  })
  console.log('Seeded user:', email, 'password:', password)
}

main().finally(async () => prisma.$disconnect())
