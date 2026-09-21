@ECHO OFF
title Kocam Bedirhan
color 0A

:: ==========================================
:: 1. SIFRE KONTROLU
:: ==========================================
set "CORRECT_PASS=1234"

:PASSWORD_LOOP
cls
echo.
echo ===================================================
echo    Bedirhuayn dan sultana software development
echo ===================================================
echo.
set /p "USER_PASS=Lutfen giris sifresini girin: "

if not "%USER_PASS%"=="%CORRECT_PASS%" (
    echo.
    echo [X] Hatali sifre! Lutfen tekrar deneyin.
    timeout /t 2 >nul
    goto :PASSWORD_LOOP
)

echo.
echo [+] Giris basarili!
echo.

:: ==========================================
:: 2. GUNCELLEME KONTROLU
:: ==========================================
set "CURRENT_VERSION=1.0.0"
set "REPO_RAW=https://raw.githubusercontent.com/KULLANICI_ADI/DEPO_ADI/main"

echo Guncellemeler kontrol ediliyor...

set "REMOTE_VERSION="
for /f "delims=" %%v in ('curl -s --connect-timeout 3 -L "%REPO_RAW%/version.txt" 2^>nul') do set "REMOTE_VERSION=%%v"

if not "%REMOTE_VERSION%"=="%CURRENT_VERSION%" (
    if not "%REMOTE_VERSION%"=="" (
        echo.
        echo Yeni bir guncelleme bulundu: v%REMOTE_VERSION%
        echo Indiriliyor ve uygulaniyor...
        
        curl -s -L "%REPO_RAW%/launcher.exe" -o "update_tmp.exe"
        if exist "update_tmp.exe" (
            (
                echo @echo off
                echo timeout /t 2 /nobreak ^>nul
                echo move /y update_tmp.exe "%~nx0" ^>nul
                echo start "" "%~nx0"
                echo del "%%~f0"
            ) > update.bat
            start "" update.bat
            exit
        )
    )
)

:: ==========================================
:: 3. GOODBYEDPI BASLAT
:: ==========================================
echo.
echo Servis baslatiliyor...
pause

PUSHD "%~dp0"
set _arch=x86
IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set _arch=x86_64)
IF DEFINED PROCESSOR_ARCHITEW6432 (set _arch=x86_64)
PUSHD "%_arch%"

start "" goodbyedpi.exe -5 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253

POPD
POPD