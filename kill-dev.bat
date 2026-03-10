@echo off
setlocal

pwsh.exe -ExecutionPolicy Bypass -File "%~dp0scripts\kill-dev.ps1" %*

endlocal
