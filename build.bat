@echo off
setlocal
cd /d "%~dp0"

set "DARKLUA_CMD="
where darklua >nul 2>nul
if not errorlevel 1 set "DARKLUA_CMD=darklua"
if not defined DARKLUA_CMD (
  where rokit >nul 2>nul
  if not errorlevel 1 set "DARKLUA_CMD=rokit run darklua"
)
if not defined DARKLUA_CMD (
  echo [ERROR] Darklua no esta instalado o no esta disponible en PATH.
  echo Instala Darklua: https://darklua.com/docs/getting-started/
  echo Si usas Rokit, instala el paquete seaofvoices/darklua y vuelve a ejecutar.
  exit /b 1
)

if not exist dist mkdir dist

echo.
echo [Harkening UI] Compilando directamente con Darklua...
call %DARKLUA_CMD% process "Harkening\init.lua" "dist\Harkening.lua" --config "build\darklua.config.json"
if errorlevel 1 (
  echo.
  echo [ERROR] Darklua no pudo generar el bundle.
  exit /b 1
)

echo.
echo [OK] Archivo generado: dist\Harkening.lua
echo Copia su contenido a un ModuleScript llamado Harkening.
exit /b 0
