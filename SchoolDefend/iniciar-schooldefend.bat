@echo off
setlocal

set "PHP_XAMPP=C:\xampp\php\php.exe"
set "PUERTO=8086"
set "RUTA_PROYECTO=%~dp0"

if not exist "%PHP_XAMPP%" (
    echo No se encontro PHP en %PHP_XAMPP%.
    echo Revisa que XAMPP este instalado en C:\xampp.
    pause
    exit /b 1
)

echo.
echo SchoolDefend se abrira en http://127.0.0.1:%PUERTO%/login.php
echo MySQL debe estar iniciado desde el panel de XAMPP.
echo Para detener la pagina, presiona Ctrl+C en esta ventana.
echo.

start "" "http://127.0.0.1:%PUERTO%/login.php"
"%PHP_XAMPP%" -S 127.0.0.1:%PUERTO% -t "%RUTA_PROYECTO%"

if errorlevel 1 (
    echo.
    echo No se pudo iniciar SchoolDefend. Es posible que el puerto %PUERTO% ya este ocupado.
    pause
)

endlocal
