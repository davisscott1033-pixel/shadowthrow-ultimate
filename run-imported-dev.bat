@echo off
:: run-imported-dev.bat
cd /d %~dp0
pnpm --filter imported dev
