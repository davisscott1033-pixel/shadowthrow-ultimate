# Server2.ps1 (patched) - imported @ 3001

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERR]  $m" -ForegroundColor Red }

function Write-TextNoBOM([string]$Path, [string]$Content) {
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

function Ensure-PostCSS-CJS([string]$ConfigPath) {
  $c = @"
module.exports = {
  plugins: {
    '@tailwindcss/postcss': {},
    autoprefixer: {},
  },
};
"@
  Write-TextNoBOM -Path $ConfigPath -Content $c
  Ok ("PostCSS config written: {0}" -f $ConfigPath)
}

function Ensure-Globals([string]$CssPath) {
  $css = '@import "tailwindcss";'
  Write-TextNoBOM -Path $CssPath -Content $css
  Ok ("globals.css set for Tailwind v4: {0}" -f $CssPath)
}

function Ensure-BodyClasses([string]$LayoutPath) {
  if (!(Test-Path $LayoutPath)) { Warn ("layout not found: {0}" -f $LayoutPath); return }
  $layout = Get-Content $LayoutPath -Raw
  $required = 'bg-white text-gray-900 dark:bg-gray-950 dark:text-gray-100'
  if ($layout -match '<body[^>]*className="([^"]*)"') {
    $current = $Matches[1]
    if ($current -notmatch 'bg-white|text-gray-900|dark:bg-gray-950|dark:text-gray-100') {
      $new = $layout -replace '(className=")([^"]*)(")', ('$1' + $current + ' ' + $required + '$3')
      Write-TextNoBOM -Path $LayoutPath -Content $new
      Ok ("Updated body className in: {0}" -f $LayoutPath)
    } else {
      Info "Body classes already present"
    }
  } else {
    $new = $layout -replace '<body>', '<body className="bg-white text-gray-900 dark:bg-gray-950 dark:text-gray-100">'
    if ($new -ne $layout) {
      Write-TextNoBOM -Path $LayoutPath -Content $new
      Ok ("Added body className in: {0}" -f $LayoutPath)
    } else {
      Warn ("Could not find <body> in: {0}" -f $LayoutPath)
    }
  }
}

function Get-FirstPidOnPort([int]$Port){
  try {
    $conns = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    if ($conns) {
      $procId = ($conns | Select-Object -Expand OwningProcess -First 1)
      if ($procId) { return [int]$procId }
    }
  } catch {}

  # Fallback to netstat parsing
  $matches = @()
  try {
    $lines = netstat -ano | Select-String "[:\.]$Port(\s|$)" | ForEach-Object { $_.Line }
    foreach ($line in $lines) {
      if ($line -match 'LISTENING\s+(\d+)$') { return [int]$Matches[1] }
      elseif ($line -match 'ESTABLISHED\s+(\d+)$') { return [int]$Matches[1] }
      elseif ($line -match '\s+(\d+)$') { return [int]$Matches[1] }
    }
  } catch {}
  return $null
}

function Kill-Port([int]$Port){
  $procId = Get-FirstPidOnPort -Port $Port
  if ($procId) {
    Warn ("Killing PID {0} on port {1}" -f $procId, $Port)
    try { taskkill /PID $procId /F | Out-Null; Start-Sleep -Milliseconds 300 } catch { Warn ("Failed to kill PID {0}: {1}" -f $procId, $_.Exception.Message) }
  } else {
    Info ("No process on port {0}" -f $Port)
  }
}

function Wait-For-Http([string]$Url, [int]$TimeoutSec=90){
  $deadline = (Get-Date).AddSeconds($TimeoutSec)
  while((Get-Date) -lt $deadline){
    try {
      $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5
      if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500) { return $true }
    } catch {}
    Start-Sleep -Milliseconds 600
  }
  return $false
}

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $RepoRoot

$AppDir   = Join-Path $RepoRoot "apps\imported"
$Port     = 3001
$Url      = "http://localhost:$Port"

Ensure-PostCSS-CJS -ConfigPath (Join-Path $AppDir "postcss.config.cjs")
if (Test-Path (Join-Path $AppDir "postcss.config.js"))  { Remove-Item (Join-Path $AppDir "postcss.config.js") -Force }
if (Test-Path (Join-Path $AppDir "postcss.config.mjs")) { Remove-Item (Join-Path $AppDir "postcss.config.mjs") -Force }

Ensure-Globals     -CssPath    (Join-Path $AppDir "src\app\globals.css")
Ensure-BodyClasses -LayoutPath (Join-Path $AppDir "src\app\layout.tsx")

$EnvPath      = Join-Path $AppDir ".env"
$EnvLocalPath = Join-Path $AppDir ".env.local"
if (!(Test-Path $EnvPath)) {
  Write-TextNoBOM -Path $EnvPath -Content "DATABASE_URL=file:./prisma/shadowthrow.sqlite"
  Ok "Created apps/imported/.env (DATABASE_URL)"
}
if (!(Test-Path $EnvLocalPath)) {
  $secret = [Convert]::ToBase64String([byte[]](1..48 | ForEach-Object {Get-Random -Minimum 0 -Maximum 256}))
  $envLocal = @"
NEXTAUTH_URL=http://localhost:$Port
NEXT_PUBLIC_SITE_URL=http://localhost:$Port
NEXTAUTH_SECRET=$secret

STRIPE_PUBLISHABLE_KEY=pk_test_xxx
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
"@
  Write-TextNoBOM -Path $EnvLocalPath -Content $envLocal
  Ok "Created apps/imported/.env.local (fill Stripe keys later)"
}

Info "Installing workspace deps (pnpm install)"
pnpm install --reporter=append-only | Out-Null

Push-Location $AppDir
try {
  Info "Prisma generate"
  pnpm exec prisma generate | Out-Host
  $dbFile = Join-Path $AppDir "prisma\shadowthrow.sqlite"
  if (-not (Test-Path $dbFile)) {
    Info "Database not found; running db push + seed"
    pnpm exec prisma db push | Out-Host
    pnpm run db:seed | Out-Host
  } else {
    Info "Database exists; skipping db push/seed"
  }
} finally {
  Pop-Location
}

Kill-Port -Port $Port
$next = Join-Path $AppDir ".next"
if (Test-Path $next) { Remove-Item $next -Recurse -Force -ErrorAction SilentlyContinue }

Start-Process powershell -ArgumentList "-NoExit","-Command","Set-Location `"$RepoRoot`"; pnpm --filter imported dev -- -p $Port"
Info ("Waiting for {0} ..." -f $Url)
if (Wait-For-Http -Url $Url) {
  Ok ("Server2 (imported) is up: {0}" -f $Url)
  Start-Process $Url | Out-Null
} else {
  Warn "Server2 did not verify within timeout; check the dev window."
}

