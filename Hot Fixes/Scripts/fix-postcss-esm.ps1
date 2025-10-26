# fix-postcss-esm.ps1 (patched)
# Fix "module is not defined in ES module scope" by converting PostCSS configs to ESM.
# Applies to apps/imported and apps/web.

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERR]  $m" -ForegroundColor Red }

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $RepoRoot

$targets = @(
  @{ app = "apps\imported"; path = "apps\imported\postcss.config.js" },
  @{ app = "apps\web";      path = "apps\web\postcss.config.js" }
)

$esmConfig = @"
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
"@

foreach ($t in $targets) {
  $p = Join-Path $RepoRoot $t.path
  if (Test-Path $p) {
    $raw = Get-Content $p -Raw
    # Overwrite to ESM unconditionally to avoid CJS in ESM mode
    Set-Content $p $esmConfig -Encoding UTF8
    Ok ("Converted {0}\postcss.config.js to ESM (export default ...)" -f $t.app)
  } else {
    Info ("{0}\postcss.config.js not found; skipping" -f $t.app)
  }
}

# Clear .next caches to avoid stale loader state
$nextDirs = @("apps\imported\.next","apps\web\.next")
foreach ($d in $nextDirs) {
  $full = Join-Path $RepoRoot $d
  if (Test-Path $full) {
    try {
      Remove-Item $full -Recurse -Force -ErrorAction SilentlyContinue
      Ok ("Cleared {0} cache" -f $d)
    } catch {
      Warn ("Could not clear {0}: {1}" -f $d, $_.Exception.Message)
    }
  }
}

Ok "PostCSS ESM patch complete."

# Optional: prompt to start imported dev server
try {
  $resp = Read-Host "Start the imported app now on port 3001? (Y/n)"
  if ($resp -eq "" -or $resp -match "^[Yy]") {
    Start-Process powershell -ArgumentList "-NoExit","-Command","Set-Location `"$RepoRoot`"; pnpm --filter imported dev"
    Ok "Started imported dev server (check the new terminal)"
  } else {
    Info "Skipping auto-start as requested."
  }
} catch {}
