@echo off
title LibraryKu Frontend - Flutter Web
echo ===================================================
echo   LibraryKu Frontend - Flutter Web
echo ===================================================
echo.

rem Set engine version jika git tidak tersedia di environment sistem
set FLUTTER_PREBUILT_ENGINE_VERSION=a804b261645ef8c13eb3d5c44a5c2fb0340c5539

rem Periksa apakah Flutter terpasang di sistem
where flutter >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Perintah 'flutter' tidak ditemukan di PATH sistem.
    echo Pastikan Flutter SDK telah diinstal dan ditambahkan ke Environment Variables PATH.
    echo.
    pause
    exit /b 1
)

cd /d "%~dp0frontend"
if errorlevel 1 (
    echo [ERROR] Gagal berpindah ke folder frontend.
    pause
    exit /b 1
)

echo [INFO] Memeriksa dependensi Flutter (flutter pub get)...
call flutter pub get
if errorlevel 1 (
    echo [WARNING] flutter pub get mengalami kendala. Melanjutkan...
)

echo.
echo [INFO] Pastikan backend CI4 SUDAH berjalan terlebih dahulu di:
echo        http://localhost:8080
echo.
echo [INFO] Menjalankan Flutter Web pada browser Chrome...
echo [INFO] Port web: http://localhost:7080
echo.
echo Tekan Ctrl+C untuk menghentikan.
echo ===================================================
echo.

flutter run -d chrome --web-port 7080

echo.
echo [INFO] Aplikasi Flutter Web telah dihentikan.
pause
