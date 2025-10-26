# status-check.ps1
# Quick diagnostics for ShadowThrow
$ErrorActionPreference = "Continue"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $RepoRoot

function say($sym,$msg,$color){ Write-Host "$sym $msg" -ForegroundColor $color }

# pnpm
try { $v = pnpm -v; say "✅" "pnpm $v found" Green } catch { say "❌" "pnpm not found" Red }

# workspace check
$ws = Test-Path (Join-Path $RepoRoot "pnpm-workspace.yaml")
if ($ws) { say "✅" "pnpm-workspace.yaml present" Green } else { say "❌" "pnpm-workspace.yaml missing" Red }

# apps
if (Test-Path "apps\web\package.json") { say "✅" "apps/web present" Green } else { say "❌" "apps/web missing" Red }
if (Test-Path "apps\imported\package.json") { say "✅" "apps/imported present" Green } else { say "❌" "apps/imported missing" Red }

# env
if (Test-Path "apps\imported\.env.local") { say "✅" "apps/imported/.env.local present" Green } else { say "❌" "apps/imported/.env.local missing" Red }

# prisma db file
if (Test-Path "apps\imported\prisma\shadowthrow.sqlite") { say "✅" "SQLite DB exists" Green } else { say "⚠" "SQLite DB not found yet (run db:push/seed)" Yellow }

# Ports hint
say "ℹ" "Web:      http://localhost:3000" Cyan
say "ℹ" "Imported: http://localhost:3001" Cyan
