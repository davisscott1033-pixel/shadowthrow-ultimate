ShadowThrow Port Orchestrator
=============================

Where to place:
- Extract this ZIP into your monorepo root:
  D:\ShadowThrow\ShadowThrow_Ultimate_v6\my-shadowthrow\

Files:
- run-shadowthrow-orchestrator.ps1 — full setup + port management + browser open
- run-shadowthrow-orchestrator.bat — double-click launcher (keeps window open, logs output)
- run-shadowthrow-orchestrator.log — created on first run with all output

What it does:
1) Patches Next.js config for both apps (top-level typedRoutes/transpilePackages).
2) Ensures `apps/imported/.env.local` exists (generates NEXTAUTH_SECRET, adds Stripe placeholders).
3) Runs `pnpm install` for the whole workspace.
4) Runs Prisma `db:generate`, `db:push`, `db:seed` for the imported app (SQLite).
5) Checks ports 3000 and 3001; kills anything using them.
6) Starts `web` (3000) and `imported` (3001) in separate terminals.
7) Waits for both servers to respond and opens them in your browser in two tabs.

How to use:
1) Extract ZIP to the repo root above.
2) Double-click `run-shadowthrow-orchestrator.bat` (or run the .ps1 from PowerShell).
3) Watch the logs. If it reports both servers are up, it opens two tabs:
   - http://localhost:3000  (web shell)
   - http://localhost:3001  (imported app: login + Stripe)

Notes:
- If PowerShell blocks the script, run once:
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
- Update `apps/imported/.env.local` with your real Stripe keys after the first run.
