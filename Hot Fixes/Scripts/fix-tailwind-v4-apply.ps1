# fix-tailwind-v4-apply.ps1
# Patches Tailwind v4 apply issues by:
# 1) Replacing globals.css with '@import "tailwindcss";'
# 2) Ensuring <body> has utility classes (bg/text) in layout.tsx
# 3) Clearing .next cache for the imported app
# 4) Offering to start the dev server

$ErrorActionPreference = "Stop"

function Info($m){ Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "[OK]  $m" -ForegroundColor Green }
function Warn($m){ Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Err($m){ Write-Host "[ERR]  $m" -ForegroundColor Red }

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $RepoRoot

$CssPath = "apps\imported\src\app\globals.css"
$LayoutPath = "apps\imported\src\app\layout.tsx"

# 1) Replace globals.css
$cssContent = '@import "tailwindcss";'
Set-Content $CssPath $cssContent -Encoding UTF8
Ok "Wrote Tailwind v4 import to $CssPath"

# 2) Patch layout.tsx to add body classes (idempotent)
if (Test-Path $LayoutPath) {
  $layout = Get-Content $LayoutPath -Raw

  # Ensure it imports the CSS (already does), and inject body classes
  if ($layout -match '<body[^>]*className=') {
    # Body already has a className: ensure required classes are present
    $required = 'bg-white text-gray-900 dark:bg-gray-950 dark:text-gray-100'
    if ($layout -notmatch 'bg-white' -or $layout -notmatch 'text-gray-900' -or $layout -notmatch 'dark:bg-gray-950' -or $layout -notmatch 'dark:text-gray-100') {
      # Append the required classes to existing className string
      $layout = $layout -replace '(className="\s*)([^"]*)(")', ('$1$2 ' + $required + '$3')
      Set-Content $LayoutPath $layout -Encoding UTF8
      Ok "Updated existing body className in $LayoutPath"
    } else {
      Info "Body already contains required classes; no change"
    }
  } else {
    # Add a className prop to <body>
    $layout2 = $layout -replace '<body>', '<body className="bg-white text-gray-900 dark:bg-gray-950 dark:text-gray-100">'
    if ($layout2 -ne $layout) {
      Set-Content $LayoutPath $layout2 -Encoding UTF8
      Ok "Added body className to $LayoutPath"
    } else {
      Warn "Could not find <body> tag to patch in $LayoutPath"
    }
  }
} else {
  Err "Missing $LayoutPath"
  exit 1
}

# 3) Clear .next cache
$nextDir = "apps\imported\.next"
if (Test-Path $nextDir) {
  try {
    Remove-Item $nextDir -Recurse -Force -ErrorAction SilentlyContinue
    Ok "Cleared $nextDir cache"
  } catch {
    Warn ("Could not clear {0}: {1}" -f $nextDir, $_.Exception.Message)
  }
}

# 4) Prompt to start dev server
try {
  $resp = Read-Host "Start the imported app now on port 3001? (Y/n)"
  if ($resp -eq "" -or $resp -match "^[Yy]") {
    Start-Process powershell -ArgumentList "-NoExit","-Command","Set-Location `"$RepoRoot`"; pnpm --filter imported dev"
    Ok "Started imported dev server (check the new terminal)"
  } else {
    Info "Skipping auto-start as requested."
  }
} catch {}
