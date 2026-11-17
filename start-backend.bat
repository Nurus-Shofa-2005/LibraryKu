@echo off
title LibraryKu Backend - CI4 Server
echo ===================================================
echo   LibraryKu Backend - CodeIgniter 4
echo   PHP 8.3 + MySQL REST API
echo ===================================================
echo.

set PHP_EXE=C:\wamp64\bin\php\php8.3.28\php.exe

rem Cek apakah PHP 8.3 terpasang di lokasi WAMP
if not exist "%PHP_EXE%" (
    echo [ERROR] PHP 8.3 executable tidak ditemukan di:
    echo         %PHP_EXE%
    echo.
    echo Mohon periksa apakah WAMP Server terpasang dan memiliki PHP 8.3.
    echo.
    pause
    exit /b 1
)

cd /d "%~dp0backend"
if errorlevel 1 (
    echo [ERROR] Gagal berpindah ke folder backend.
    pause
    exit /b 1
)

echo [INFO] PHP Version:
"%PHP_EXE%" -v | findstr /i "PHP 8."
echo.
echo [INFO] Memulai server backend CI4 pada port 8080...
echo [INFO] Base URL: http://localhost:8080
echo [INFO] API URL : http://localhost:8080/api/books
echo.
echo Tekan Ctrl+C untuk menghentikan server.
echo ===================================================
echo.

"%PHP_EXE%" spark serve --host 0.0.0.0 --port 8080

echo.
echo [INFO] Server backend telah dihentikan.
pause
