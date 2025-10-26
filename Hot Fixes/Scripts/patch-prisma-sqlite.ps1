# patch-prisma-sqlite.ps1
# Fix Prisma schema for SQLite and ensure DATABASE_URL is available to Prisma.
# Then run prisma generate / db push / seed inside apps/imported.

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERR] $m" -ForegroundColor Red }

# Paths
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$AppDir = Join-Path $RepoRoot "apps\imported"
$Schema = Join-Path $AppDir "prisma\schema.prisma"
$EnvLocal = Join-Path $AppDir ".env.local"
$Env = Join-Path $AppDir ".env"

if (-not (Test-Path $Schema)) { Err "Schema not found: $Schema"; exit 1 }

# 1) Patch @db.Text (unsupported in SQLite) -> remove the native type annotation
$raw = Get-Content $Schema -Raw
$patched = $raw -replace '@db\.Text', ''
if ($patched -ne $raw) {
  Set-Content $Schema $patched -Encoding UTF8
  Ok "Patched @db.Text -> (removed) in prisma/schema.prisma"
} else {
  Info "No @db.Text annotations found or already removed"
}

# 2) Ensure DATABASE_URL for Prisma in a .env (Prisma reads .env, not .env.local)
if (-not (Test-Path $Env)) {
  $dbLine = 'DATABASE_URL=file:./prisma/shadowthrow.sqlite'
  # If .env.local exists and has DATABASE_URL, reuse it; otherwise write a minimal .env
  if (Test-Path $EnvLocal) {
    $local = Get-Content $EnvLocal -Raw
    if ($local -match 'DATABASE_URL\s*=') {
      $dbVal = ($local -split "`r?`n" | Where-Object { $_ -match '^DATABASE_URL\s*=' } | Select-Object -First 1)
      if ($dbVal) { $dbLine = $dbVal }
    }
  }
  Set-Content $Env $dbLine -Encoding UTF8
  Ok "Created apps/imported/.env with $dbLine"
} else {
  Info ".env already present; leaving it"
}

# 3) Run prisma commands from the app directory so it reads the app's .env
Push-Location $AppDir
try {
  Info "pnpm --filter imported run db:generate"
  pnpm --filter imported run db:generate | Out-Host

  Info "pnpm --filter imported run db:push"
  pnpm --filter imported run db:push | Out-Host

  Info "pnpm --filter imported run db:seed"
  pnpm --filter imported run db:seed | Out-Host

  Ok "Prisma generate/push/seed succeeded"
} finally {
  Pop-Location
}
