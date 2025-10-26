@echo off
setlocal
chcp 65001 >nul

REM Double-click launcher for the dev server.
REM Place this file in: D:\ShadowThrow\ShadowThrow_Ultimate_v6\my-shadowthrow

pushd "%~dp0" || (
  echo [st] Could not cd into script directory.
  pause
  exit /b 1
)

REM Ensure pnpm is available via corepack
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "try { corepack enable | Out-Null } catch {}"

echo [st] Starting dev server (pnpm dev) ...
start "" http://localhost:3000/
pnpm dev

set EXITCODE=%ERRORLEVEL%
echo [st] Dev server exited with code %EXITCODE%
pause
popd
exit /b %EXITCODE%