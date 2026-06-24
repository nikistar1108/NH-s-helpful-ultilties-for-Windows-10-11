@echo off
setlocal enabledelayedexpansion
title NH's Recovery Toolkit - System Cleanup & Optimize
color 0C

:: ============================================================
:: NH's Recovery Toolkit v1.1
:: Author: Nikistar Corporation
:: Purpose: Clean up system junk, clear temp files, and optimize disk performance
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
set "LOGFILE=%USERPROFILE%\Desktop\NH_Recovery_Logs\NH_Cleanup_%TIMESTAMP%.log"

if not exist "%USERPROFILE%\Desktop\NH_Recovery_Logs" mkdir "%USERPROFILE%\Desktop\NH_Recovery_Logs"

:: === INIT LOG ===
echo ====================================================== >> "%LOGFILE%"
echo NH's Recovery Toolkit v1.1 - System Cleanup & Optimize >> "%LOGFILE%"
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
echo   ██████╗██╗     ███████╗ █████╗ ███╗   ██╗██╗   ██╗██████╗ 
echo  ██╔════╝██║     ██╔════╝██╔══██╗████╗  ██║██║   ██║██╔══██╗
echo  ██║     ██║     █████╗  ███████║██╔██╗ ██║██║   ██║██████╔╝
echo  ██║     ██║     ██╔══╝  ██╔══██║██║╚██╗██║██║   ██║██╔══██╗
echo  ╚██████╗███████╗███████╗██║  ██║██║ ╚████║╚██████╔╝██║  ██║
echo   ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝
echo.
echo  ========================================================
echo       NH's CLEANUP & OPTIMIZE TOOL
echo  ========================================================
echo.
echo  [i] Logging is enabled. All actions are written to:
echo      %LOGFILE%
echo.
echo  [i] This tool will perform:
echo      - Clean temporary files (Temp, Prefetch, Recycle Bin)
echo      - Clean Windows Update cache
echo      - Defragment system drive (if HDD)
echo      - Disable unnecessary startup services
echo.
echo.
set /p "choice=[+] Start cleanup and optimization? (Y/N) : "

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
echo [+] Starting system cleanup and optimization...
echo [+] Logging to: %LOGFILE%
echo.
echo [%TIME%] Session started... >> "%LOGFILE%"

:: ============================================================
:: 3. CLEAN TEMPORARY FILES (SILENT)
:: ============================================================
echo.
echo --------------------------------------------------------
echo [1/5] Cleaning temporary files and system junk...
echo --------------------------------------------------------
echo [%TIME%] Cleaning temporary files... >> "%LOGFILE%"

echo  >> "%LOGFILE%"
echo ---------- TEMPORARY FILES CLEANED ---------- >> "%LOGFILE%"

:: Clean user Temp (тихо)
del /f /s /q "%TEMP%\*" >nul 2>&1
for /d %%x in ("%TEMP%\*") do rmdir /s /q "%%x" >nul 2>&1

:: Clean Windows Temp (тихо)
del /f /s /q "%WINDIR%\Temp\*" >nul 2>&1
for /d %%x in ("%WINDIR%\Temp\*") do rmdir /s /q "%%x" >nul 2>&1

:: Clean Prefetch (тихо)
del /f /s /q "%WINDIR%\Prefetch\*" >nul 2>&1

:: Clean Recycle Bin (тихо)
rd /s /q %SYSTEMDRIVE%\$Recycle.bin >nul 2>&1

echo [OK] Temporary files cleaned.
echo [OK] Temporary files cleaned. >> "%LOGFILE%"

:: ============================================================
:: 4. CLEAN WINDOWS UPDATE CACHE
:: ============================================================
echo.
echo --------------------------------------------------------
echo [2/5] Cleaning Windows Update cache...
echo --------------------------------------------------------
echo [%TIME%] Cleaning Windows Update cache... >> "%LOGFILE%"

echo  >> "%LOGFILE%"
echo ---------- UPDATE CACHE CLEANED ---------- >> "%LOGFILE%"

net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
del /f /s /q "%WINDIR%\SoftwareDistribution\Download\*" >nul 2>&1
for /d %%x in ("%WINDIR%\SoftwareDistribution\Download\*") do rmdir /s /q "%%x" >nul 2>&1
del /f /s /q "%WINDIR%\SoftwareDistribution\DataStore\*" >nul 2>&1
for /d %%x in ("%WINDIR%\SoftwareDistribution\DataStore\*") do rmdir /s /q "%%x" >nul 2>&1
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

echo [OK] Windows Update cache cleaned.
echo [OK] Windows Update cache cleaned. >> "%LOGFILE%"

:: ============================================================
:: 5. DISK DEFRAGMENTATION (only for HDD)
:: ============================================================
echo.
echo --------------------------------------------------------
echo [3/5] Analyzing and defragmenting system drive...
echo --------------------------------------------------------
echo [%TIME%] Checking if defragmentation is needed... >> "%LOGFILE%"

echo  >> "%LOGFILE%"
echo ---------- DEFRAGMENTATION ---------- >> "%LOGFILE%"

powershell -Command "& {
    try {
        $drive = Get-PhysicalDisk | Where-Object { $_.MediaType -eq 'HDD' } | Select-Object -First 1;
        if ($drive) {
            Write-Host '[i] HDD detected. Running defragmentation...';
            Add-Content -Path '%LOGFILE%' -Value '[i] HDD detected. Running defragmentation...';
            defrag C: /O /U
            Write-Host '[OK] Defragmentation completed.';
            Add-Content -Path '%LOGFILE%' -Value '[OK] Defragmentation completed.';
        } else {
            Write-Host '[i] SSD detected. Defragmentation skipped.';
            Add-Content -Path '%LOGFILE%' -Value '[i] SSD detected. Defragmentation skipped.';
        }
    } catch {
        Write-Host '[WARNING] Defragmentation not available.';
        Add-Content -Path '%LOGFILE%' -Value '[WARNING] Defragmentation not available.';
    }
}" 2>nul

:: ============================================================
:: 6. DISABLE UNNECESSARY SERVICES
:: ============================================================
echo.
echo --------------------------------------------------------
echo [4/5] Disabling unnecessary startup services...
echo --------------------------------------------------------
echo [%TIME%] Disabling unnecessary services... >> "%LOGFILE%"

echo  >> "%LOGFILE%"
echo ---------- SERVICES DISABLED ---------- >> "%LOGFILE%"

sc config WSearch start= disabled >nul 2>&1
net stop WSearch >nul 2>&1

sc config XblAuthManager start= disabled >nul 2>&1
sc config XblGameSave start= disabled >nul 2>&1
sc config XboxNetApiSvc start= disabled >nul 2>&1
net stop XblAuthManager >nul 2>&1
net stop XblGameSave >nul 2>&1
net stop XboxNetApiSvc >nul 2>&1

echo [OK] Unnecessary services disabled.
echo [OK] Unnecessary services disabled. >> "%LOGFILE%"

:: ============================================================
:: 7. FINAL LOG
:: ============================================================
echo.
echo --------------------------------------------------------
echo [5/5] Collecting final information...
echo --------------------------------------------------------
echo [%TIME%] Finishing cleanup... >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo ---------- FINAL REPORT ---------- >> "%LOGFILE%"
echo Temp Files: Cleaned >> "%LOGFILE%"
echo Update Cache: Cleaned >> "%LOGFILE%"
echo Defragmentation: (see above) >> "%LOGFILE%"
echo Services: Disabled >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo [%TIME%] Cleanup completed. >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"

:: ============================================================
:: 8. SCHEDULED TASK (AUTO-REPEAT EVERY 7 DAYS)
:: ============================================================
echo.
echo --------------------------------------------------------
echo [AUTO] Setting up automatic repeat in 7 days...
echo --------------------------------------------------------

set "SCRIPT_PATH=%~dp0"
set "SCRIPT_PATH=%SCRIPT_PATH:\=\\%"
set "TASK_NAME=NHs_Cleanup_AutoCheck"

> "%TEMP%\CleanupTask.xml" (
echo ^<?xml version="1.0" encoding="UTF-16"?^>
echo ^<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^>
echo   ^<RegistrationInfo^>
echo     ^<Date^>%DATE%^</Date^>
echo     ^<Author^>%USERNAME%^</Author^>
echo     ^<Description^>NH's Recovery Toolkit - Automatic weekly cleanup and optimization^</Description^>
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

schtasks /create /tn "%TASK_NAME%" /xml "%TEMP%\CleanupTask.xml" /f >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    echo [OK] Task "%TASK_NAME%" successfully created in Task Scheduler.
    echo [i] It will run this script every Monday at 10:00 AM.
    echo [i] To cancel, run: schtasks /delete /tn "%TASK_NAME%" /f
) else (
    echo [WARNING] Failed to create scheduled task. Try again later.
)

del "%TEMP%\CleanupTask.xml" >nul 2>&1

:: ============================================================
:: 9. SILENT MODE (--silent)
:: ============================================================
if "%1"=="--silent" (
    echo [%TIME%] Running in silent mode (scheduler)... >> "%LOGFILE%"
    echo [i] Completed. Log saved to: %LOGFILE%
    exit /b 0
)

:: ============================================================
:: 10. FINISH
:: ============================================================
echo.
echo --------------------------------------------------------
echo [i] Cleanup and optimization completed!
echo [i] Log saved to: %LOGFILE%
echo.
echo ========================================================
echo       NH's CLEANUP & OPTIMIZE TOOL - COMPLETED
echo ========================================================
echo.
echo.
pause
exit /b 0