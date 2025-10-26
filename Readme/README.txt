ShadowThrow Setup Bundle
=======================

Where to place:
- Extract this ZIP into your **monorepo root**:
  D:\ShadowThrow\ShadowThrow_Ultimate_v6\my-shadowthrow\

Files:
- setup-shadowthrow.ps1  → One-shot setup (fix Next config, create .env.local, install, Prisma init, launch dev)
- run-web-dev.bat        → Launch web app (3000)
- run-imported-dev.bat   → Launch imported app (3001)
- status-check.ps1       → Quick diagnostics
- README.txt             → This file

How to use:
1) Right-click **setup-shadowthrow.ps1** → Run with PowerShell
   - Patches apps/web/next.config.mjs (serverActions boolean → object)
   - Creates apps/imported/.env.local with a generated NEXTAUTH_SECRET and Stripe placeholders (update with your keys)
   - Runs pnpm install for the workspace
   - Runs Prisma generate/push/seed for apps/imported
   - Opens two terminals running `pnpm --filter web dev` and `pnpm --filter imported dev`

2) Visit:
   - Web shell: http://localhost:3000
   - Imported app: http://localhost:3001 (login: admin@shadowthrow.dev / change-me)

Re-run helpers:
- Double-click **run-web-dev.bat** or **run-imported-dev.bat** any time.
- Run **status-check.ps1** to verify environment and DB quickly.
