# fix-tailwind-postcss-plugin.ps1
# Install @tailwindcss/postcss and update PostCSS configs for Tailwind v4 in both apps.

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERR]  $m" -ForegroundColor Red }

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $RepoRoot

# 1) Install @tailwindcss/postcss in both apps
Info "Installing @tailwindcss/postcss as a devDependency in web and imported"
pnpm --filter web add -D @tailwindcss/postcss | Out-Host
pnpm --filter imported add -D @tailwindcss/postcss | Out-Host
Ok "Installed @tailwindcss/postcss"

# 2) Rewrite postcss.config.js to use the new plugin
$esmConfig = @"
export default {
  plugins: {
    '@tailwindcss/postcss': {},
    autoprefixer: {},
  },
};
"@

$targets = @(
  "apps\web\postcss.config.js",
  "apps\imported\postcss.config.js"
)

foreach ($p in $targets) {
  if (Test-Path $p) {
    Set-Content $p $esmConfig -Encoding UTF8
    Ok ("Updated {0} to use @tailwindcss/postcss" -f $p)
  } else {
    Warn ("{0} not found; skipping" -f $p)
  }
}

# 3) Clear .next caches
$nextDirs = @("apps\web\.next","apps\imported\.next")
foreach ($d in $nextDirs) {
  if (Test-Path $d) {
    try {
      Remove-Item $d -Recurse -Force -ErrorAction SilentlyContinue
      Ok ("Cleared cache: {0}" -f $d)
    } catch {
      Warn ("Could not clear {0}: {1}" -f $d, $_.Exception.Message)
    }
  }
}

# 4) Prompt to restart imported dev server
try {
  $resp = Read-Host "Restart the imported dev server on port 3001 now? (Y/n)"
  if ($resp -eq "" -or $resp -match "^[Yy]") {
    Start-Process powershell -ArgumentList "-NoExit","-Command","Set-Location `"$RepoRoot`"; pnpm --filter imported dev"
    Ok "Started imported dev server (check the new terminal)"
  } else {
    Info "Skipping auto-start as requested."
  }
} catch {}
