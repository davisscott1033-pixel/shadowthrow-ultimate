Server Launchers
=================

This bundle gives you two one-click launchers:

- **Server1** → `apps/web` on **http://localhost:3000**
- **Server2** → `apps/imported` on **http://localhost:3001**

What each script ensures automatically:
- Tailwind PostCSS config (`postcss.config.cjs`) with `@tailwindcss/postcss` + `autoprefixer`
- `globals.css` uses `@import "tailwindcss";`
- `<body>` has sensible light/dark classes
- Kills the target port if busy, clears `.next` cache
- Starts the dev server in a new terminal and opens your browser when ready

For **Server2** (imported) extras:
- Creates `apps/imported/.env` with `DATABASE_URL` if missing
- Creates `apps/imported/.env.local` with a generated `NEXTAUTH_SECRET` + Stripe placeholders if missing
- Runs `prisma generate` always, and `db push` + `seed` only if the SQLite DB is not present

How to use:
1) Extract this ZIP into your repo root:
   `D:\ShadowThrow\ShadowThrow_Ultimate_v6\my-shadowthrow\`
2) Double-click `Server1.bat` (web) or `Server2.bat` (imported).

Notes:
- If PowerShell blocks scripts, run once: `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force`
- You can run the `.ps1` directly if you prefer; the `.bat` just launches PowerShell with safe flags.
