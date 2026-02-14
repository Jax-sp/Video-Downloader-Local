@echo off
title Instalador JaxMedia Downloader
color 0A

echo ==================================================
echo      JAXMEDIA DOWNLOADER - INSTALADOR AUTOMATICO
echo ==================================================
echo.

::Verificar si Python está instalado
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Python no detectado.
    echo.
    echo Intentando instalar Python via Winget...
    winget install -e --id Python.Python.3.10
    if %errorlevel% neq 0 (
        echo.
        echo [ERROR] No se pudo instalar Python automaticamente.
        echo Por favor instala Python desde python.org y vuelve a abrir este archivo.
        pause
        exit
    )
    echo [OK] Python instalado correctamente. Reinicia el instalador para confirmar.
    pause
    exit
) else (
    echo [OK] Python detectado.
)

::Verificar FFmpeg (Necesario para MP3)
ffmpeg -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] FFmpeg no detectado (Necesario para convertir a MP3).
    echo Intentando instalar FFmpeg via Winget...
    winget install -e --id Gyan.FFmpeg
    echo.
    echo Si hubo un error arriba, deberas instalar FFmpeg manualmente.
) else (
    echo [OK] FFmpeg detectado.
)

echo.
echo Creando entorno virtual (esto puede tardar unos segundos)...
cd downloader
python -m venv venv

echo Activando entorno e instalando dependencias...
call venv\Scripts\activate
pip install -r requirements.txt

echo.
echo Creando el Launcher...
cd ..

::Crear el archivo LAUNCHER.BAT dinámicamente
(
echo @echo off
echo title JaxMedia Server
echo color 0B
echo echo Iniciando servidor... NO CIERRES ESTA VENTANA.
echo echo El navegador se abrira automaticamente.
echo cd downloader
echo call venv\Scripts\activate
echo python app.py
echo pause
) > launcher.bat

echo.
echo ==================================================
echo      INSTALACION COMPLETADA CON EXITO!
echo ==================================================
echo.
echo Se ha creado el archivo "launcher.bat".
echo Haz doble click en el para usar la aplicacion cuando quieras.
echo.
pause