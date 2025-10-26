@echo off
:: run-shadowthrow-bootstrap.bat
:: Double-click to run the repo bootstrap script with PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-shadowthrow-bootstrap.ps1"
echo.
echo ===== Finished. Press any key to close this window. =====
pause >nul
