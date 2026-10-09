@echo off
setlocal
cd /d "%~dp0.."
set "KIT_GODOT=%CD%\tools\godot\Godot_v4.6.2-stable_win64.exe"
if not "%~1"=="" set "KIT_GODOT=%~f1"
if not exist "%KIT_GODOT%" (
  echo Godot 4.6.2 non trovato. Passare il percorso dell'eseguibile come primo argomento.
  pause
  exit /b 1
)
set "APPDATA=%CD%\artifacts\ui_kit_preview\profile"
set "LOCALAPPDATA=%CD%\artifacts\ui_kit_preview\local"
set "TEMP=%CD%\artifacts\ui_kit_preview\temp"
set "TMP=%TEMP%"
if not exist "%APPDATA%" mkdir "%APPDATA%"
if not exist "%LOCALAPPDATA%" mkdir "%LOCALAPPDATA%"
if not exist "%TEMP%" mkdir "%TEMP%"
"%KIT_GODOT%" --path "%CD%" --audio-driver Dummy --resolution 1280x720 res://tools/manifesto_kit_gallery.tscn
endlocal
