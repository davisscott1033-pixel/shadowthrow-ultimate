# fix-web-postcss.ps1
# Fix web app PostCSS to include a `plugins` key and use Tailwind v4 plugin package

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERR]  $m" -ForegroundColor Red }

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $RepoRoot

$WebDir = "apps\web"
$Postcss = Join-Path $WebDir "postcss.config.js"
$Globals = Join-Path $WebDir "src\app\globals.css"
$Layout  = Join-Path $WebDir "src\app\layout.tsx"

if (-not (Test-Path $WebDir)) { Err "Missing $WebDir"; exit 1 }

# 1) Ensure @tailwindcss/postcss is installed for web
Info "Installing @tailwindcss/postcss in web"
pnpm --filter web add -D @tailwindcss/postcss | Out-Host
Ok "Installed @tailwindcss/postcss"

# 2) Write a correct ESM PostCSS config with plugins key
$postcssEsm = @"
export default {
  plugins: {
    '@tailwindcss/postcss': {},
    autoprefixer: {},
  },
};
"@
Set-Content $Postcss $postcssEsm -Encoding UTF8
Ok "Wrote $Postcss with plugins key"

# 3) (Optional) Make sure globals + layout are Tailwind v4-friendly
if (Test-Path $Globals) {
  Set-Content $Globals '@import "tailwindcss";' -Encoding UTF8
  Ok "Patched $Globals with @import \"tailwindcss\""
} else {
  Warn "$Globals not found; skipping CSS patch"
}

if (Test-Path $Layout) {
  $layout = Get-Content $Layout -Raw
  if ($layout -match '<body[^>]*className=') {
    $required = 'bg-white text-gray-900 dark:bg-gray-950 dark:text-gray-100'
    if ($layout -notmatch 'bg-white' -or $layout -notmatch 'text-gray-900' -or $layout -notmatch 'dark:bg-gray-950' -or $layout -notmatch 'dark:text-gray-100') {
      $layout = $layout -replace '(className="\s*)([^"]*)(")', ('$1$2 ' + $required + '$3')
      Set-Content $Layout $layout -Encoding UTF8
      Ok "Updated body className in $Layout"
    } else {
      Info "Body already has required classes; no change"
    }
  } else {
    $layout2 = $layout -replace '<body>', '<body className="bg-white text-gray-900 dark:bg-gray-950 dark:text-gray-100">'
    if ($layout2 -ne $layout) {
      Set-Content $Layout $layout2 -Encoding UTF8
      Ok "Added body className to $Layout"
    } else {
      Warn "Could not find <body> tag to patch in $Layout"
    }
  }
} else {
  Warn "$Layout not found; skipping layout patch"
}

# 4) Clear .next cache for web
$nextDir = Join-Path $WebDir ".next"
if (Test-Path $nextDir) {
  try {
    Remove-Item $nextDir -Recurse -Force -ErrorAction SilentlyContinue
    Ok "Cleared $nextDir cache"
  } catch {
    Warn ("Could not clear {0}: {1}" -f $nextDir, $_.Exception.Message)
  }
}

# 5) Prompt to start web dev server
try {
  $resp = Read-Host "Start the web app now on port 3000? (Y/n)"
  if ($resp -eq "" -or $resp -match "^[Yy]") {
    Start-Process powershell -ArgumentList "-NoExit","-Command","Set-Location `"$RepoRoot`"; pnpm --filter web dev"
    Ok "Started web dev server (check the new terminal)"
  } else {
    Info "Skipping auto-start as requested."
  }
} catch {}
