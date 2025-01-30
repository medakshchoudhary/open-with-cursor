@echo off
echo Running Installer...
powershell -ExecutionPolicy Bypass -File "%~dp0add_cursor_context.ps1"
echo Installation complete! Press any key to exit.
pause
