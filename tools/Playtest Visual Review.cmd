@echo off
setlocal
cd /d "%~dp0.."
set "APPDATA=%CD%\artifacts\claude_review_2026-10-08\owner_profile"
set "LOCALAPPDATA=%APPDATA%"
if not exist "%APPDATA%" mkdir "%APPDATA%"
"%CD%\tools\godot\Godot_v4.6.2-stable_win64.exe" --path "%CD%" --resolution 1280x720
endlocal
