@echo off
title Kocam Bedirhan - GoodbyeDPI Launcher
color 0A
setlocal enabledelayedexpansion

:: ==========================================
:: YAPILANDIRMA VE SURUM BILGILERI
:: ==========================================
set "CURRENT_VERSION=1.0.0"
set "REPO_RAW=https://raw.githubusercontent.com/Pronely/Bedirhan-DPI/main"
set "VERSION_URL=%REPO_RAW%/version.txt"
set "UPDATE_URL=%REPO_RAW%/launcher.cmd"
set "HASH_URL=%REPO_RAW%/launcher.cmd.sha256"

echo.
echo ===================================================
echo               KOCAM BEDIRHAN LAUNCHER
echo               Mevcut Surum: v%CURRENT_VERSION%
echo ===================================================
echo.

:: ==========================================
:: GUNCELLEME KONTROLU (TIMEOUT KORUMALI)
:: ==========================================
echo [i] Guncellemeler kontrol ediliyor...

set "REMOTE_VERSION="

:: 1. YONTEM: PowerShell WebRequest (3 Saniye Timeout)
for /f "delims=" %%v in ('powershell -Command "$ProgressPreference='SilentlyContinue'; try { $req = [Net.HttpWebRequest]::Create('%VERSION_URL%'); $req.Timeout = 3000; $res = $req.GetResponse(); $sr = New-Object System.IO.StreamReader($res.GetResponseStream()); $sr.ReadToEnd().Trim() } catch { }" 2^>nul') do set "REMOTE_VERSION=%%v"

:: 2. YONTEM: Curl (Ikinci Yedek)
if "%REMOTE_VERSION%"=="" (
    for /f "delims=" %%v in ('curl -s --connect-timeout 3 -L "%VERSION_URL%" 2^>nul') do set "REMOTE_VERSION=%%v"
)

if "%REMOTE_VERSION%"=="" (
    echo [!] Guncelleme sunucusuna baglanilamadi veya zaman asimina ugradi.
    echo [i] Mevcut surum ile devam ediliyor...
    goto :START_GOODBYEDPI
)

if "%REMOTE_VERSION%"=="%CURRENT_VERSION%" (
    echo [+] Surumunuz guncel (v%CURRENT_VERSION%).
    goto :START_GOODBYEDPI
)

echo.
echo [!] YENI SURUM BULUNDU: v%REMOTE_VERSION% (Mevcut: v%CURRENT_VERSION%)
set /p CHOICE="Yeni surumu indirip guncellemek ister misiniz? (E/H): "
if /i not "%CHOICE%"=="E" (
    echo [i] Guncelleme atlandi. Mevcut surum baslatiliyor...
    goto :START_GOODBYEDPI
)

:: ==========================================
:: GUNCELLEME VE SHA-256 DOGRULAMA
:: ==========================================
echo.
echo [1/4] Yeni surum indiriliyor...
curl -s -L --connect-timeout 5 "%UPDATE_URL%" -o "launcher_new.cmd"
curl -s -L --connect-timeout 5 "%HASH_URL%" -o "launcher_new.cmd.sha256"

if not exist "launcher_new.cmd" (
    echo [X] HATA: Guncelleme dosyasi indirilemedi!
    goto :START_GOODBYEDPI
)

echo [2/4] SHA-256 hash'i hesaplaniyor ve kontrol ediliyor...

for /f "tokens=*" %%a in ('powershell -Command "(Get-FileHash 'launcher_new.cmd' -Algorithm SHA256).Hash.ToUpper()" 2^>nul') do set "CALCULATED_HASH=%%a"

set /p EXPECTED_HASH=<launcher_new.cmd.sha256
set "EXPECTED_HASH=%EXPECTED_HASH: =%"

echo     Hesaplanan Hash : !CALCULATED_HASH!
echo     Beklenen Hash   : !EXPECTED_HASH!

if /i "!CALCULATED_HASH!"=="!EXPECTED_HASH!" (
    echo [3/4] Hash dogrulamasi BASARILI!
    echo [4/4] Eski surum yedekleniyor ve yenisi uygulaniyor...
    
    copy /y "launcher.cmd" "launcher.cmd.bak" >nul
    
    (
        echo @echo off
        echo timeout /t 1 /nobreak ^>nul
        echo move /y launcher_new.cmd launcher.cmd ^>nul
        echo del launcher_new.cmd.sha256 ^>nul
        echo start "" "launcher.cmd"
        echo del "%%~f0"
    ) > update_apply.bat
    
    start "" update_apply.bat
    exit
) else (
    echo [X] HATA: SHA-256 Hash eslesmedi! Dosya bozulmus olabilir.
    echo [X] Guncelleme iptal edildi.
    del "launcher_new.cmd" >nul 2>&1
    del "launcher_new.cmd.sha256" >nul 2>&1
    pause
    goto :START_GOODBYEDPI
)

:: ==========================================
:: GOODBYEDPI BASLATMA
:: ==========================================
:START_GOODBYEDPI
echo.
echo ===================================================
echo               GoodbyeDPI Baslatiliyor...
echo ===================================================
echo.

cd /d "%~dp0"
if exist "goodbyedpi.exe" (
    start "" "goodbyedpi.exe" -5 --dns-addr 1.1.1.1 --dns-port 53
) else (
    echo [!] goodbyedpi.exe bulunamadi. Lutfen dosyanin bu klasorde oldugundan emin olun.
)

pause