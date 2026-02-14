@echo off
title Instalador JaxMedia Downloader
color 0A

::ubicarse en la carpeta del archivo
cd /d "%~dp0"

echo ==================================================
echo      JAXMEDIA DOWNLOADER - INSTALADOR AUTOMATICO
echo ==================================================
echo.

::verificacion de seguridad: existe la carpeta?
if not exist "Downloader" (
    color 0C
    echo [ERROR CRITICO] No encuentro la carpeta "Downloader".
    echo Asegurate de que este archivo "installer.bat" este AL LADO de la carpeta "Downloader".
    echo.
    echo Estructura actual detectada:
    dir /b
    pause
    exit
)

::verificar si Python esta instalado
echo Buscando Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Python no detectado.
    echo.
    echo Intentando instalar Python via Winget...
    winget install -e --id Python.Python.3.10
    if %errorlevel% neq 0 (
        color 0C
        echo.
        echo [ERROR] No se pudo instalar Python automaticamente.
        echo Por favor instala Python desde python.org manualmente.
        pause
        exit
    )
    echo [OK] Python instalado. POR FAVOR REINICIA ESTE INSTALADOR.
    pause
    exit
) else (
    echo [OK] Python detectado.
)

::verificar FFmpeg
echo Buscando FFmpeg...
ffmpeg -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] FFmpeg no detectado.
    echo Intentando instalar FFmpeg...
    winget install -e --id Gyan.FFmpeg
) else (
    echo [OK] FFmpeg detectado.
)

echo.
echo --------------------------------------------------
echo Creando entorno virtual en la carpeta Downloader...
echo --------------------------------------------------
cd "Downloader"

python -m venv venv
if %errorlevel% neq 0 (
    color 0C
    echo [ERROR] Fallo al crear el entorno virtual.
    pause
    exit
)

echo.
echo Instalando dependencias (Flask, yt-dlp)...
call venv\Scripts\activate
pip install -r requirements.txt
if %errorlevel% neq 0 (
    color 0C
    echo [ERROR] Fallo al instalar las librerias. Revisa tu internet.
    pause
    exit
)

echo.
echo Creando el Launcher...
cd ..

::crear el archivo LAUNCHER.BAT
(
echo @echo off
echo title JaxMedia Server
echo color 0B
echo cd /d "%%~dp0"
echo echo Iniciando servidor... NO CIERRES ESTA VENTANA.
echo echo El navegador se abrira automaticamente...
echo cd "Downloader"
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
echo Haz doble click en el para abrir tu programa.
echo.
pause