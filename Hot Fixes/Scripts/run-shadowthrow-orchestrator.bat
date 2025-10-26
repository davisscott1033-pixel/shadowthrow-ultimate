@echo off
:: run-shadowthrow-orchestrator.bat (patched)
powershell -NoExit -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-shadowthrow-orchestrator.ps1" *>> "%~dp0run-shadowthrow-orchestrator.log"
echo.
echo ===== Finished. The script window remains open. Logs saved to run-shadowthrow-orchestrator.log =====
