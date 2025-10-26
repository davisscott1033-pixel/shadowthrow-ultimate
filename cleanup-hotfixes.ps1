# cleanup-hotfixes.ps1
param(
  [switch]$DryRun,
  [switch]$Undo,
  [string]$ManifestPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Path)\Hot Fixes\cleanup-manifest.json"
)

# ----------------------------------------
# Helpers
# ----------------------------------------
$ErrorActionPreference = "Stop"
function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERR]  $m" -ForegroundColor Red }

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $RepoRoot
Info "Repo root: $RepoRoot"

# ----------------------------------------
# Undo flow
# ----------------------------------------
if ($Undo) {
  if (!(Test-Path $ManifestPath)) {
    Err "Manifest not found: $ManifestPath"
    exit 1
  }
  $moves = Get-Content $ManifestPath -Raw | ConvertFrom-Json
  foreach ($entry in $moves) {
    $from = $entry.to
    $to   = $entry.from
    if (Test-Path $from) {
      if ($DryRun) {
        Write-Host ("[UNDO-DRYRUN] {0} -> {1}" -f $from, $to)
      } else {
        $toDir = Split-Path -Parent $to
        if (!(Test-Path $toDir)) { New-Item -ItemType Directory -Path $toDir | Out-Null }
        Move-Item -LiteralPath $from -Destination $to -Force
        Write-Host ("[UNDO] {0} -> {1}" -f $from, $to)
      }
    }
  }
  if (-not $DryRun) { Ok "Undo complete." }
  exit 0
}

# ----------------------------------------
# Destinations
# ----------------------------------------
$hotfixRoot = Join-Path $RepoRoot "Hot Fixes"
$hotfixScripts = Join-Path $hotfixRoot "Scripts"
$hotfixLogs = Join-Path $hotfixRoot "Logs"
$hotfixArchives = Join-Path $hotfixRoot "Archives"
$miscRoot = Join-Path $RepoRoot "Misc"

foreach ($d in @($hotfixRoot,$hotfixScripts,$hotfixLogs,$hotfixArchives,$miscRoot)) {
  if (!(Test-Path $d)) { New-Item -ItemType Directory -Path $d | Out-Null }
}

# ----------------------------------------
# Safelist (NEVER move)
# ----------------------------------------
$neverMove = @(
  ".git", ".github", "node_modules", "apps", "packages", "one-click-ultimate",
  "pnpm-workspace.yaml", "pnpm-lock.yaml", "package.json", "turbo.json",
  "tsconfig.json", "README.md", "postcss.config.cjs"
)

# ----------------------------------------
# Patterns to classify
# ----------------------------------------
$hotfixScriptPatterns = @(
  "fix-*.ps1","fix-*.bat",
  "*patch*.ps1","*patch*.bat",
  "run-shadowthrow-orchestrator.ps1","run-shadowthrow-orchestrator.bat",
  "setup-shadowthrow.ps1","setup-shadowthrow.bat",
  "fix-corepack-and-run.ps1","fix-corepack-and-run.bat",
  "apply-prisma-sqlite-patch.ps1","apply-prisma-sqlite-patch.bat",
  "patch-prisma-sqlite.ps1",
  "fix-postcss-esm.ps1","fix-postcss-esm.bat",
  "fix-tailwind-postcss-plugin.ps1","fix-tailwind-postcss-plugin.bat",
  "fix-tailwind-v4-apply.ps1","fix-tailwind-v4-apply.bat",
  "fix-web-postcss.ps1","fix-web-postcss.bat"
)

$hotfixLogPatterns = @("*.log")

$hotfixArchivePatterns = @(
  "*orchestrator*.zip","*patch*.zip","*setup*bundle*.zip","*shadowthrow*_*.zip","*shadowthrow*patch*.zip"
)

$miscPatterns = @("*.tmp","*.bak")

# ----------------------------------------
# Collect candidates (root-level only)
# ----------------------------------------
$rootFiles = Get-ChildItem -LiteralPath $RepoRoot -File -Force

$plan = @()

function ShouldNeverMove($name){
  foreach ($n in $neverMove) {
    if ($name -ieq $n) { return $true }
  }
  return $false
}

foreach ($f in $rootFiles) {
  if (ShouldNeverMove $f.Name) { continue }

  $dest = $null

  foreach ($pat in $hotfixScriptPatterns) {
    if ($f.Name -like $pat) { $dest = $hotfixScripts; break }
  }
  if (-not $dest) {
    foreach ($pat in $hotfixArchivePatterns) {
      if ($f.Name -like $pat) { $dest = $hotfixArchives; break }
    }
  }
  if (-not $dest) {
    foreach ($pat in $hotfixLogPatterns) {
      if ($f.Name -like $pat) { $dest = $hotfixLogs; break }
    }
  }
  if (-not $dest) {
    foreach ($pat in $miscPatterns) {
      if ($f.Name -like $pat) { $dest = $miscRoot; break }
    }
  }

  if ($dest) {
    $plan += [pscustomobject]@{ from = $f.FullName; to = (Join-Path $dest $f.Name) }
  }
}

if ($plan.Count -eq 0) {
  Info "No files to move. Root looks clean."
  exit 0
}

Write-Host ""
Info "Planned moves:"
$plan | ForEach-Object { Write-Host (" - {0} -> {1}" -f $_.from, $_.to) }

$go = "Y"
if (-not $DryRun) { $go = Read-Host "Proceed with these moves? (Y/n)" }
if ($go -ne "" -and $go -notmatch "^[Yy]") { exit 0 }

$manifest = @()
foreach ($m in $plan) {
  if ($DryRun) {
    Write-Host ("[DRYRUN] {0} -> {1}" -f $m.from, $m.to)
  } else {
    $toDir = Split-Path -Parent $m.to
    if (!(Test-Path $toDir)) { New-Item -ItemType Directory -Path $toDir | Out-Null }
    try {
      Move-Item -LiteralPath $m.from -Destination $m.to -Force
      $manifest += $m
      Write-Host ("[MOVED] {0} -> {1}" -f $m.from, $m.to)
    } catch {
      Warn ("Failed to move {0}: {1}" -f $m.from, $_.Exception.Message)
    }
  }
}

if (-not $DryRun) {
  $manifest | ConvertTo-Json | Set-Content $ManifestPath -Encoding UTF8
  Ok ("Manifest saved to: {0}" -f $ManifestPath)
  Ok "Cleanup complete."
} else {
  Warn "Dry run only. No changes written."
}
