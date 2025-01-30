@echo off
echo Running Uninstaller...
powershell -ExecutionPolicy Bypass -File "%~dp0remove_cursor_context.ps1"
echo Uninstallation complete! Press any key to exit.
pause
