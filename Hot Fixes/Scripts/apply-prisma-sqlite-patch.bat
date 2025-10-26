@echo off
:: apply-prisma-sqlite-patch.bat
:: Double-click to run the PowerShell patch with a persistent window.
powershell -NoExit -NoProfile -ExecutionPolicy Bypass -File "%~dp0apply-prisma-sqlite-patch.ps1"
