# apply-prisma-sqlite-patch.ps1
# Patch Prisma schema for SQLite, ensure DATABASE_URL, run Prisma steps (format/validate/generate/db push/seed).

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERR]  $m" -ForegroundColor Red }

# Resolve repo root (script location)
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $RepoRoot

$AppDir = Join-Path $RepoRoot "apps\imported"
$Schema = Join-Path $AppDir "prisma\schema.prisma"
$Env    = Join-Path $AppDir ".env"

if (-not (Test-Path $Schema)) { Err "Schema not found: $Schema"; exit 1 }

# 1) Overwrite schema.prisma with a SQLite-safe model (NextAuth v4 compatible)
$schemaText = @"
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "sqlite"
  url      = env("DATABASE_URL")
}

model User {
  id           String    @id @default(cuid())
  email        String    @unique
  passwordHash String?
  name         String?
  image        String?
  accounts     Account[]
  sessions     Session[]
}

model Account {
  id                String  @id @default(cuid())
  userId            String
  type              String
  provider          String
  providerAccountId String
  refresh_token     String?
  access_token      String?
  expires_at        Int?
  token_type        String?
  scope             String?
  id_token          String?
  session_state     String?
  user              User    @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([provider, providerAccountId])
}

model Session {
  id           String   @id @default(cuid())
  sessionToken String   @unique
  userId       String
  expires      DateTime
  user         User     @relation(fields: [userId], references: [id], onDelete: Cascade)
}
"@

Set-Content $Schema $schemaText -Encoding UTF8
Ok "Wrote SQLite-safe prisma/schema.prisma"

# 2) Ensure Prisma can read DATABASE_URL from .env
if (-not (Test-Path $Env)) {
  'DATABASE_URL=file:./prisma/shadowthrow.sqlite' | Set-Content $Env -Encoding UTF8
  Ok "Created apps/imported/.env with DATABASE_URL=file:./prisma/shadowthrow.sqlite"
} else {
  Info ".env already exists; leaving it"
}

# 3) Run Prisma steps from the app directory
Push-Location $AppDir
try {
  Info "pnpm exec prisma format"
  pnpm exec prisma format | Out-Host

  Info "pnpm exec prisma validate"
  pnpm exec prisma validate | Out-Host

  Info "pnpm exec prisma generate"
  pnpm exec prisma generate | Out-Host

  Info "pnpm exec prisma db push"
  pnpm exec prisma db push | Out-Host

  Info "pnpm run db:seed"
  pnpm run db:seed | Out-Host

  Ok "Prisma patch + DB setup completed successfully."
} finally {
  Pop-Location
}
