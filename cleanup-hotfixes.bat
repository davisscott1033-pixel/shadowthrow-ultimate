@echo off
:: cleanup-hotfixes.bat
powershell -NoExit -NoProfile -ExecutionPolicy Bypass -File "%~dp0cleanup-hotfixes.ps1"
