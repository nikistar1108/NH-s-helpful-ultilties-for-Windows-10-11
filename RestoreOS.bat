@echo off
setlocal enabledelayedexpansion
title NH's Recovery Toolkit - System Restore & Maintenance
color 0A

:: ============================================================
:: NH's Recovery Toolkit v1.4
:: Author: Nikistar Corporation
:: Purpose: Full Windows system repair, DISM, SFC, CHKDSK, and Auto-Schedule
:: ============================================================

:: === ADMIN CHECK ===
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo.
    echo [ERROR] Administrator privileges are required!
    echo         Right-click this file and select "Run as administrator".
    echo.
    pause
    exit /b
)

:: === SAFE LOG FILE SETUP ===
for /f "tokens=1-3 delims=/" %%a in ('echo %DATE%') do set "YYYY=%%c" & set "MM=%%a" & set "DD=%%b"
for /f "tokens=1-3 delims=: " %%a in ('echo %TIME%') do set "HH=%%a" & set "MIN=%%b" & set "SEC=%%c"
if "%HH:~0,1%"==" " set "HH=0%HH:~1%"
if "%MIN:~0,1%"==" " set "MIN=0%MIN:~1%"
if "%SEC:~0,1%"==" " set "SEC=0%SEC:~1%"

set "TIMESTAMP=%YYYY%-%MM%-%DD%_%HH%-%MIN%-%SEC%"
set "LOGFILE=%USERPROFILE%\Desktop\NH_Recovery_Logs\NH_Recovery_Log_%TIMESTAMP%.log"

if not exist "%USERPROFILE%\Desktop\NH_Recovery_Logs" mkdir "%USERPROFILE%\Desktop\NH_Recovery_Logs"

:: === INIT LOG ===
echo ====================================================== >> "%LOGFILE%"
echo NH's Recovery Toolkit v1.4 - System Restore & Maintenance >> "%LOGFILE%"
echo Start Date: %DATE% %TIME% >> "%LOGFILE%"
echo User: %USERNAME% >> "%LOGFILE%"
echo Computer: %COMPUTERNAME% >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"
echo. >> "%LOGFILE%"

:: ============================================================
:: 1. UI & WELCOME
:: ============================================================
cls
echo.
echo  ███╗   ██╗██╗  ██╗ ' ██████╗ ██████╗ ███████╗ ██████╗ ██████╗ ██╗   ██╗███████╗██████╗ ██╗   ██╗
echo  ████╗  ██║██║  ██║██╔════╝ ██╔══██╗██╔════╝██╔═══██╗██╔══██╗╚██╗ ██╔╝██╔════╝██╔══██╗╚██╗ ██╔╝
echo  ██╔██╗ ██║███████║██║  ███╗██████╔╝█████╗  ██║   ██║██████╔╝ ╚████╔╝ █████╗  ██████╔╝ ╚████╔╝
echo  ██║╚██╗██║██╔══██║██║   ██║██╔══██╗██╔══╝  ██║   ██║██╔══██╗  ╚██╔╝  ██╔══╝  ██╔══██╗  ╚██╔╝
echo  ██║ ╚████║██║  ██║╚██████╔╝██║  ██║███████╗╚██████╔╝██║  ██║   ██║   ███████╗██║  ██║   ██║
echo  ╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝   ╚═╝
echo.
echo  ========================================================
echo       NH's RECOVERY TOOLKIT - SYSTEM RESTORE & MAINTENANCE
echo  ========================================================
echo.
echo  [i] Logging is enabled. All actions are written to:
echo      %LOGFILE%
echo.
echo  [i] This tool will run the full system repair:
echo      - SFC /SCANNOW (System File Checker)
echo      - DISM /RESTOREHEALTH (Image Repair)
echo      - CHKDSK (Disk Error Check)
echo.
echo.
set /p "choice=[+] Start system repair? (Y/N) : "

if /i not "%choice%"=="Y" (
    echo.
    echo [i] Action cancelled. Exiting...
    echo.
    pause
    exit /b
)

:: ============================================================
:: 2. START LOGGING
:: ============================================================
echo.
echo [+] Starting diagnostics and repair...
echo [+] Logging to: %LOGFILE%
echo.
echo [%TIME%] Session started... >> "%LOGFILE%"

:: ============================================================
:: 3. SFC /SCANNOW
:: ============================================================
echo.
echo --------------------------------------------------------
echo [1/4] Running SFC /SCANNOW (System File Check)...
echo --------------------------------------------------------
echo [%TIME%] Launching SFC /SCANNOW... >> "%LOGFILE%"

sfc /scannow 2>nul

if %ERRORLEVEL% EQU 0 (
    echo [OK] SFC completed successfully. System files are intact.
    echo [%TIME%] SFC completed successfully. >> "%LOGFILE%"
) else (
    echo [WARNING] SFC found errors or requires a reboot.
    echo [%TIME%] SFC finished with code %ERRORLEVEL%. >> "%LOGFILE%"
)

echo. >> "%LOGFILE%"

:: ============================================================
:: 4. DISM /ONLINE /CLEANUP-IMAGE /RESTOREHEALTH
:: ============================================================
echo.
echo --------------------------------------------------------
echo [2/4] Running DISM (System Image Restoration)...
echo --------------------------------------------------------
echo [%TIME%] Launching DISM /Online /Cleanup-Image /RestoreHealth... >> "%LOGFILE%"

DISM /Online /Cleanup-Image /RestoreHealth 2>nul

if %ERRORLEVEL% EQU 0 (
    echo [OK] DISM completed successfully. System image is repaired.
    echo [%TIME%] DISM completed successfully. >> "%LOGFILE%"
) else (
    echo [WARNING] DISM failed. Check your internet connection and try again later.
    echo [%TIME%] DISM finished with code %ERRORLEVEL%. >> "%LOGFILE%"
)

echo. >> "%LOGFILE%"

:: ============================================================
:: 5. CHKDSK /F /R
:: ============================================================
echo.
echo --------------------------------------------------------
echo [3/4] Running CHKDSK (Disk Error Check)...
echo --------------------------------------------------------
echo [WARNING] CHKDSK may require a system reboot and can take several hours.
echo.
set /p "chkdsk_choice=[?] Run CHKDSK on system drive (C:)? (Y/N) : "

if /i "%chkdsk_choice%"=="Y" (
    echo [%TIME%] Launching CHKDSK C: /F /R... >> "%LOGFILE%"
    echo.
    echo [+] Starting disk check...
    chkdsk C: /F /R 2>nul
    
    if %ERRORLEVEL% EQU 0 (
        echo [OK] CHKDSK completed successfully. No errors found.
        echo [%TIME%] CHKDSK completed successfully. >> "%LOGFILE%"
    ) else (
        echo [WARNING] CHKDSK found problems or requires a reboot.
        echo [%TIME%] CHKDSK finished with code %ERRORLEVEL%. >> "%LOGFILE%"
    )
) else (
    echo [i] CHKDSK skipped by user.
    echo [%TIME%] CHKDSK skipped by user. >> "%LOGFILE%"
)

echo. >> "%LOGFILE%"

:: ============================================================
:: 6. SYSTEM INFO COLLECTION
:: ============================================================
echo.
echo --------------------------------------------------------
echo [4/4] Collecting system information...
echo --------------------------------------------------------
echo [%TIME%] Collecting system info... >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo ---------- SYSTEM INFORMATION ---------- >> "%LOGFILE%"
echo OS: %OS% >> "%LOGFILE%"
echo Windows Version: %PROCESSOR_IDENTIFIER% >> "%LOGFILE%"
echo Processor: %PROCESSOR_IDENTIFIER% >> "%LOGFILE%"
echo Memory: >> "%LOGFILE%"
systeminfo | findstr /C:"Total Physical Memory" >> "%LOGFILE%"
systeminfo | findstr /C:"Available Physical Memory" >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo ---------- DRIVES ---------- >> "%LOGFILE%"
wmic diskdrive get model,size,status >> "%LOGFILE%"
echo. >> "%LOGFILE%"
echo ---------- FREE SPACE ---------- >> "%LOGFILE%"
wmic logicaldisk where drivetype=3 get deviceid,size,freespace >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo ---------- FINAL REPORT ---------- >> "%LOGFILE%"
echo SFC: (see above) >> "%LOGFILE%"
echo DISM: (see above) >> "%LOGFILE%"
echo CHKDSK: (see above) >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo [%TIME%] Repair session finished. >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"

:: ============================================================
:: 7. SCHEDULED TASK (AUTO-REPEAT EVERY 7 DAYS)
:: ============================================================
echo.
echo --------------------------------------------------------
echo [AUTO] Setting up automatic repeat in 7 days...
echo --------------------------------------------------------

set "SCRIPT_PATH=%~dp0"
set "SCRIPT_PATH=%SCRIPT_PATH:\=\\%"
set "TASK_NAME=NHs_Recovery_AutoCheck"

> "%TEMP%\RecoveryTask.xml" (
echo ^<?xml version="1.0" encoding="UTF-16"?^>
echo ^<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^>
echo   ^<RegistrationInfo^>
echo     ^<Date^>%DATE%^</Date^>
echo     ^<Author^>%USERNAME%^</Author^>
echo     ^<Description^>NH's Recovery Toolkit - Automatic weekly system check^</Description^>
echo   ^</RegistrationInfo^>
echo   ^<Triggers^>
echo     ^<CalendarTrigger^>
echo       ^<StartBoundary^>2026-07-01T10:00:00^</StartBoundary^>
echo       ^<Enabled^>true^</Enabled^>
echo       ^<ScheduleByWeek^>
echo         ^<DaysOfWeek^>
echo           ^<Monday^>true^</Monday^>
echo         ^</DaysOfWeek^>
echo         ^<WeeksInterval^>1^</WeeksInterval^>
echo       ^</ScheduleByWeek^>
echo     ^</CalendarTrigger^>
echo   ^</Triggers^>
echo   ^<Actions^>
echo     ^<Exec^>
echo       ^<Command^>"%~dp0%~nx0"^</Command^>
echo       ^<Arguments^>--silent^</Arguments^>
echo     ^</Exec^>
echo   ^</Actions^>
echo   ^<Principals^>
echo     ^<Principal id="Author"^>
echo       ^<RunLevel^>HighestAvailable^</RunLevel^>
echo     ^</Principal^>
echo   ^</Principals^>
echo   ^<Settings^>
echo     ^<AllowStartOnDemand^>true^</AllowStartOnDemand^>
echo     ^<Compatibility^>Win10^</Compatibility^>
echo   ^</Settings^>
echo ^</Task^>
)

schtasks /create /tn "%TASK_NAME%" /xml "%TEMP%\RecoveryTask.xml" /f >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    echo [OK] Task "%TASK_NAME%" successfully created in Task Scheduler.
    echo [i] It will run this script every Monday at 10:00 AM.
    echo [i] To cancel, run: schtasks /delete /tn "%TASK_NAME%" /f
) else (
    echo [WARNING] Failed to create scheduled task. Try again later.
)

del "%TEMP%\RecoveryTask.xml" >nul 2>&1

:: ============================================================
:: 8. SILENT MODE (--silent)
:: ============================================================
if "%1"=="--silent" (
    echo [%TIME%] Running in silent mode (scheduler)... >> "%LOGFILE%"
    echo [i] Completed. Log saved to: %LOGFILE%
    exit /b 0
)

:: ============================================================
:: 9. FINISH
:: ============================================================
echo.
echo --------------------------------------------------------
echo [i] Diagnostics and repair completed!
echo [i] Log saved to: %LOGFILE%
echo.
echo ========================================================
echo         NH's RECOVERY TOOLKIT - SYSTEM RESTORED
echo ========================================================
echo.
echo.
pause
exit /b 0