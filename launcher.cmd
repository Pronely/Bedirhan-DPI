
@echo off
title Kocam Bedirhan
color 0A
echo.
echo        BedirhanT
echo        GoodbyeDPI Launcher
echo.

set "OWNER=Pronely"
set "REPO=Bedirhan-DPI"
set "BRANCH=main"
set "LOCAL_VERSION=1.0"

set "BASE=https://raw.githubusercontent.com/%OWNER%/%REPO%/%BRANCH%"
set "VERSION_URL=%BASE%/version.txt"
set "SCRIPT_URL=%BASE%/launcher.cmd"

set "INSTALL_DIR=%~dp0"
set "CURRENT=%~f0"
set "NEW_FILE=%INSTALL_DIR%launcher.new.cmd"
set "BACKUP=%INSTALL_DIR%launcher.backup.cmd"

echo [1/3] Guncelleme kontrol ediliyor...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
 "$ErrorActionPreference='Stop'; try { $v=(Invoke-WebRequest -Uri '%VERSION_URL%' -UseBasicParsing -TimeoutSec 8).Content.Trim(); if ([version]$v -gt [version]'%LOCAL_VERSION%') { Invoke-WebRequest -Uri '%SCRIPT_URL%' -OutFile '%NEW_FILE%' -UseBasicParsing -TimeoutSec 20; if ((Get-Content '%NEW_FILE%' -TotalCount 1) -ne '@echo off') { throw 'Dosya dogrulamasi basarisiz' }; Write-Host 'Yeni surum indirildi.'; $p=Start-Process powershell -PassThru -WindowStyle Hidden -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-Command',\"Start-Sleep 2; Copy-Item -LiteralPath '%CURRENT%' -Destination '%BACKUP%' -Force; Move-Item -LiteralPath '%NEW_FILE%' -Destination '%CURRENT%' -Force; Start-Process -FilePath '%CURRENT%'\"; exit 10 } } catch { Write-Host 'Guncelleme kontrolu basarisiz; mevcut surumle devam ediliyor.' }"

if errorlevel 10 exit /b

echo [2/3] GoodbyeDPI baslatiliyor...

PUSHD "%~dp0"
set "_arch=x86"
IF "%PROCESSOR_ARCHITECTURE%"=="AMD64" set "_arch=x86_64"
IF DEFINED PROCESSOR_ARCHITEW6432 set "_arch=x86_64"
PUSHD "%_arch%"

start "" goodbyedpi.exe -5 --dns-addr 77.88.8.8 --dns-port 1253 --dnsv6-addr 2a02:6b8::feed:0ff --dnsv6-port 1253

POPD
POPD
exit /b