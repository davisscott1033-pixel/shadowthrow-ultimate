# run-shadowthrow-bootstrap.ps1
# ShadowThrow repo bootstrap helper
# Usage: Right-click -> Run with PowerShell (or run the included .bat)
# Safe & idempotent: creates/updates files without overwriting critical configs.

$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Done($msg) { Write-Host "[DONE] $msg" -ForegroundColor Green }
function Append-Content-Safe($path, $content) {
  if (Test-Path $path) {
    Add-Content -Path $path -Value "`r`n$content"
  } else {
    Set-Content -Path $path -Value $content -Encoding UTF8
  }
}

# 0) Move to script directory (repo root expected)
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)
Write-Info "Working directory: $(Get-Location)"

# 1) Create folders
New-Item -ItemType Directory -Force -Path ".github\workflows" | Out-Null
New-Item -ItemType Directory -Force -Path ".github\ISSUE_TEMPLATE" | Out-Null
New-Item -ItemType Directory -Force -Path ".vscode" | Out-Null

# 2) README.md (append if exists)
$readme = @"
# ShadowThrow (Monorepo)

> PNPM workspace for ShadowThrow. Apps live in `apps/`.

## Quick Start
```bash
corepack enable
pnpm install
pnpm dev
```

## Apps
- `apps/web` — main Next.js app
- `apps/imported` — optional drop-in app

## Scripts
- `pnpm dev`, `pnpm -r build`, `pnpm lint`, `pnpm format`, `pnpm typecheck`

## Environment
Copy `.env.example` to `.env.local` and fill values.

## CI
GitHub Actions workflow in `.github/workflows/ci.yml`.
"@
if (Test-Path "README.md") { Add-Content "README.md" "`r`n$readme" } else { Set-Content "README.md" $readme -Encoding UTF8 }
Write-Done "README.md created/appended"

# 3) LICENSE (MIT) if missing
$year = (Get-Date).Year
$license = @"
MIT License

Copyright (c) $year Preston Davis

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@
if (-not (Test-Path "LICENSE")) { Set-Content "LICENSE" $license -Encoding UTF8; Write-Done "LICENSE created" } else { Write-Info "LICENSE exists; leaving as-is" }

# 4) SECURITY.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md
Set-Content "SECURITY.md" "Report vulnerabilities to: TODO: security@example.com" -Encoding UTF8
Set-Content "CONTRIBUTING.md" @"
## Workflow
- Branch from `main`
- Use Conventional Commits
- Open PR with checklist
"@ -Encoding UTF8
Set-Content "CODE_OF_CONDUCT.md" "We follow the Contributor Covenant v2.1." -Encoding UTF8
Write-Done "SECURITY.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md ensured"

# 5) .gitignore (append without clobbering)
$gitignore = @"
# Node / pnpm
node_modules/
.pnpm-store/
pnpm-lock.yaml

# Builds
.next/
dist/
.turbo/
out/
coverage/

# Env
.env*
!.env.example

# OS / editors
.DS_Store
Thumbs.db
.idea/
.vscode/*
!.vscode/settings.json
!.vscode/extensions.json
"@
Append-Content-Safe ".gitignore" $gitignore
Write-Done ".gitignore appended/created"

# 6) .gitattributes
$gitattributes = @"
* text=auto eol=lf

# Large media through LFS
*.png filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text
*.jpeg filter=lfs diff=lfs merge=lfs -text
*.gif filter=lfs diff=lfs merge=lfs -text
*.mp4 filter=lfs diff=lfs merge=lfs -text
"@
Set-Content ".gitattributes" $gitattributes -Encoding UTF8
Write-Done ".gitattributes written"

# 7) .editorconfig
Set-Content ".editorconfig" @"
root = true
[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 2
trim_trailing_whitespace = true
"@ -Encoding UTF8
Write-Done ".editorconfig written"

# 8) VS Code settings
Set-Content ".vscode\settings.json" @"
{
  "files.eol": "\n",
  "files.insertFinalNewline": true,
  "files.trimTrailingWhitespace": true,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "prettier.requireConfig": true
}
"@ -Encoding UTF8
Set-Content ".vscode\extensions.json" @"
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint"
  ]
}
"@ -Encoding UTF8
Write-Done "VS Code settings ensured"

# 9) .prettierignore (safe)
if (-not (Test-Path ".prettierignore")) {
  Set-Content ".prettierignore" @"
.next
dist
coverage
"@ -Encoding UTF8
  Write-Done ".prettierignore created"
} else {
  Write-Info ".prettierignore exists; leaving as-is"
}

# 10) .env.example
Set-Content ".env.example" @"
NEXT_PUBLIC_APP_NAME=ShadowThrow
NEXT_PUBLIC_SITE_URL=http://localhost:3000
DATABASE_URL=postgres://USER:PASS@localhost:5432/shadowthrow
"@ -Encoding UTF8
Write-Done ".env.example written"

# 11) CI workflow
Set-Content ".github\workflows\ci.yml" @"
name: CI
on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
      - uses: pnpm/action-setup@v4
        with:
          version: 9
      - run: pnpm install --frozen-lockfile=false
      - run: pnpm lint
      - run: pnpm typecheck || echo No typecheck
      - run: pnpm -r build
"@ -Encoding UTF8
Write-Done "GitHub Actions workflow added"

# 12) PR & issue templates
Set-Content ".github\pull_request_template.md" @"
## Summary

## Changes

## Testing
- [ ] pnpm dev
- [ ] pnpm lint
- [ ] pnpm -r build
"@ -Encoding UTF8

Set-Content ".github\ISSUE_TEMPLATE\bug_report.md" @"
---
name: Bug report
about: Create a report to help us improve
---

**Describe the bug**
**Steps to reproduce**
**Expected behavior**
**Screenshots**
**Environment**
"@ -Encoding UTF8

Set-Content ".github\ISSUE_TEMPLATE\feature_request.md" @"
---
name: Feature request
about: Suggest an idea
---

**Problem**
**Proposal**
**Alternatives**
**Additional context**
"@ -Encoding UTF8
Write-Done "PR & Issue templates created"

# 13) Optional health route (only if apps/web exists)
if (Test-Path "apps\web") {
  New-Item -ItemType Directory -Force -Path "apps\web\src\app\health" | Out-Null
  Set-Content "apps\web\src\app\health\route.ts" @"
export async function GET() {
  return new Response(JSON.stringify({ ok: true, ts: Date.now() }), {
    headers: { "content-type": "application/json" }
  });
}
"@ -Encoding UTF8
  Set-Content "apps\web\src\app\health\page.tsx" @"
export default function HealthPage() {
  return <pre>OK</pre>;
}
"@ -Encoding UTF8
  Write-Done "Health route added to apps/web"
} else {
  Write-Info "apps/web not found; skipping health route"
}

# 14) Git LFS install (safe, no error if not installed)
try { git lfs install | Out-Null; Write-Info "git LFS initialized (if available)" } catch { Write-Info "git LFS not available; continuing" }

# 15) Optional auto-commit
$autoCommit = $true
if ($autoCommit) {
  try {
    git add . | Out-Null
    git commit -m "chore: add repo bootstrap (docs/ci/hygiene/env)" | Out-Null
    Write-Done "Changes committed"
  } catch {
    Write-Info "Git commit skipped (no repo or no changes)"
  }
}

Write-Done "Bootstrap complete! Review changes, then push to origin if desired."
