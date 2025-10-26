<#
  Setup-ShadowThrow-Workspace_v2_6_1.ps1
  - Same as v2.6 (UTF-8 no BOM; robust pnpm install)
  - NEW: Tails the install log live in the same window
#>

[CmdletBinding()]
param(
  [string]$PnpmVersion = "10.19.0"
)

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[st]" $m -ForegroundColor Cyan }
function Ok($m){ Write-Host "[ok]" $m -ForegroundColor Green }
function Warn($m){ Write-Host "[!]" $m -ForegroundColor Yellow }
function Fail($m){ Write-Host "[x]" $m -ForegroundColor Red }

$step = @{
  Corepack = $false
  WorkspaceYaml = $false
  PackageJson = $false
  Install = $false
}
$overallExit = 0

try {
  $here = Get-Location
  if (-not (Test-Path -LiteralPath ".\package.json")) {
    Warn "package.json not found; a clean one will be created."
  }

  try { chcp 65001 | Out-Null } catch {}

  # A) Corepack best-effort
  Info "Corepack: preparing pnpm@$PnpmVersion and enabling..."
  try {
    corepack prepare "pnpm@$PnpmVersion" --activate | Out-Null
    corepack enable | Out-Null
    Ok "Corepack prepared & enabled (pnpm@$PnpmVersion)."
    $step.Corepack = $true
  } catch {
    Warn "Corepack step had issues (permissions?). Continuing anyway..."
  }

  # Helper: write UTF8 without BOM
  $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

  # B) Ensure pnpm-workspace.yaml (no BOM)
  $workspaceYaml = @"
packages:
  - "apps/*"
  - "packages/*"
"@
  [System.IO.File]::WriteAllText((Join-Path $here "pnpm-workspace.yaml"), $workspaceYaml, $Utf8NoBom)
  if (Test-Path ".\pnpm-workspace.yaml") { Ok "pnpm-workspace.yaml written (UTF-8 no BOM)."; $step.WorkspaceYaml = $true } else { throw "Failed to write pnpm-workspace.yaml" }

  # C) Overwrite root package.json with safe minimal (no BOM) if needed (always rewrite for consistency)
  if (Test-Path ".\package.json") {
    try {
      $ts = Get-Date -Format "yyyyMMdd_HHmmss"
      Copy-Item -Path ".\package.json" -Destination (".\package.json.bak."+ $ts) -Force
      Ok ("Backed up existing package.json to package.json.bak."+ $ts)
    } catch { Warn "Could not backup package.json (continuing)"; }
  }

  $cleanPkg = @"
{
  "name": "shadowthrow-root",
  "version": "0.0.0",
  "private": true,
  "packageManager": "pnpm@$PnpmVersion",
  "scripts": {
    "dev": "turbo dev --parallel",
    "build": "turbo build",
    "lint": "turbo lint",
    "typecheck": "turbo run typecheck"
  },
  "devDependencies": {
    "turbo": "2.5.8",
    "typescript": "5.9.3"
  }
}
"@

  [System.IO.File]::WriteAllText((Join-Path $here "package.json"), $cleanPkg, $Utf8NoBom)

  # Validate with a temp JS file that strips BOM if present
  $tmpJs = Join-Path $env:TEMP "st_validate_package_json.js"
  @'
const fs = require("fs");
let s = fs.readFileSync("package.json","utf8");
if (s.charCodeAt(0) === 0xFEFF) s = s.slice(1); // strip BOM
JSON.parse(s);
console.log("package.json OK");
'@ | Set-Content -Path $tmpJs -Encoding UTF8

  node $tmpJs | Write-Host
  if ($LASTEXITCODE -ne 0) { throw "package.json validation failed" }
  Ok "package.json written (UTF-8 no BOM) & validated."
  $step.PackageJson = $true

  # D) Install via cmd.exe to single log + live tail
  $log = Join-Path $env:TEMP "shadowthrow_pnpm_install.log"
  Remove-Item $log -ErrorAction SilentlyContinue
  Info ("Installing dependencies (logging to " + $log + ")...")

  $cmdline = 'pnpm install 1>>"' + $log + '" 2>&1'

  # Start tail in background job
  $tailJob = Start-Job -ScriptBlock {
    param($logPath)
    try {
      Start-Sleep -Milliseconds 600
      Get-Content -Path $logPath -Tail 20 -Wait
    } catch {}
  } -ArgumentList $log

  # Kick off install
  cmd.exe /d /s /c $cmdline
  $exit = $LASTEXITCODE

  # Stop tail
  try { Stop-Job $tailJob -Force | Out-Null } catch {}
  try { Remove-Job $tailJob -Force | Out-Null } catch {}

  if ($exit -ne 0) {
    Warn ("cmd.exe path failed (code " + $exit + "). Trying pnpm.cmd directly... (live output below)")
    try {
      # Direct live output without log
      & pnpm.cmd install
      $exit = $LASTEXITCODE
    } catch {
      $exit = 1
    }
  }

  if ($exit -eq 0) {
    Ok "pnpm install completed successfully."
    $step.Install = $true
  } else {
    Fail ("pnpm install failed (code " + $exit + "). See log: " + $log)
    if (Test-Path $log) {
      Write-Host "---- pnpm install log (tail) ----" -ForegroundColor DarkGray
      Get-Content $log -Tail 120 | Write-Host
      Write-Host "---------------------------------"
    }
    $overallExit = $exit
  }

} catch {
  $overallExit = 1
  Fail ("Setup encountered an error: " + $_.Exception.Message)
}

Write-Host ""
Write-Host "========== SUMMARY ==========" -ForegroundColor White
if ($step.Corepack) { Ok "Corepack prepared/enabled" } else { Warn "Corepack step skipped/failed (you can still proceed)" }
if ($step.WorkspaceYaml) { Ok "pnpm-workspace.yaml present" } else { Fail "pnpm-workspace.yaml missing" }
if ($step.PackageJson) { Ok "package.json clean & validated" } else { Fail "package.json step failed" }
if ($step.Install) { Ok "Dependencies installed" } else { Fail "Dependency install failed" }
Write-Host "=============================" -ForegroundColor White

if (-not $step.WorkspaceYaml -or -not $step.PackageJson -or -not $step.Install) {
  $overallExit = $(if ($overallExit -ne 0) { $overallExit } else { 1 })
}

if ($overallExit -eq 0) {
  Ok "Setup completed. You can now run: pnpm dev"
} else {
  Fail "Setup incomplete. See messages above."
}

exit $overallExit