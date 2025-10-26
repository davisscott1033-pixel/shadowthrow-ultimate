@echo off
:: run-web-dev.bat
cd /d %~dp0
pnpm --filter web dev
