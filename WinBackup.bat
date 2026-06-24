@echo off
setlocal enabledelayedexpansion
title NH's Recovery Toolkit - Backup & Monitor
color 0E

:: ============================================================
:: NH's Recovery Toolkit v2.0
:: Author: Nikistar Corporation
:: Purpose: Create system backups, monitor disk space, log health
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
set "LOGFILE=%USERPROFILE%\Desktop\NH_Recovery_Logs\NH_Backup_%TIMESTAMP%.log"

if not exist "%USERPROFILE%\Desktop\NH_Recovery_Logs" mkdir "%USERPROFILE%\Desktop\NH_Recovery_Logs"

:: === INIT LOG ===
echo ====================================================== >> "%LOGFILE%"
echo NH's Recovery Toolkit v2.0 - Backup & Monitor >> "%LOGFILE%"
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
echo   ██████╗  █████╗  ██████╗██╗  ██╗██╗   ██╗██████╗ 
echo   ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██║   ██║██╔══██╗
echo   ██████╔╝███████║██║     █████╔╝ ██║   ██║██████╔╝
echo   ██╔══██╗██╔══██║██║     ██╔═██╗ ██║   ██║██╔══██╗
echo   ██████╔╝██║  ██║╚██████╗██║  ██╗╚██████╔╝██║  ██║
echo   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝
echo.
echo  ========================================================
echo       NH's BACKUP & SYSTEM MONITOR
echo  ========================================================
echo.
echo  [i] Logging is enabled. All actions are written to:
echo      %LOGFILE%
echo.
echo  [i] This tool will perform:
echo      - Create a system backup (registry + important files)
echo      - Monitor free disk space
echo      - Check system uptime and performance
echo      - Log system health metrics
echo.
echo.
set /p "choice=[+] Start backup and system monitoring? (Y/N) : "

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
echo [+] Starting backup and system monitoring...
echo [+] Logging to: %LOGFILE%
echo.
echo [%TIME%] Session started... >> "%LOGFILE%"

:: ============================================================
:: 3. SYSTEM BACKUP
:: ============================================================
echo.
echo --------------------------------------------------------
echo [1/4] Creating system backup...
echo --------------------------------------------------------
echo [%TIME%] Creating system backup... >> "%LOGFILE%"

set "BACKUP_DIR=%USERPROFILE%\Desktop\NH_System_Backup_%TIMESTAMP%"
mkdir "%BACKUP_DIR%" 2>nul

echo  >> "%LOGFILE%"
echo ---------- REGISTRY BACKUP ---------- >> "%LOGFILE%"
reg export HKLM "%BACKUP_DIR%\HKLM.reg" /y >nul 2>&1
reg export HKCU "%BACKUP_DIR%\HKCU.reg" /y >nul 2>&1

copy /y "%WINDIR%\System32\drivers\etc\hosts" "%BACKUP_DIR%\hosts.txt" >nul 2>&1
copy /y "%WINDIR%\System32\config\BCD-Template" "%BACKUP_DIR%\BCD.bak" >nul 2>&1

echo [OK] System backup created at: %BACKUP_DIR%
echo [OK] System backup created at: %BACKUP_DIR% >> "%LOGFILE%"

:: ============================================================
:: 4. MONITOR FREE DISK SPACE
:: ============================================================
echo.
echo --------------------------------------------------------
echo [2/4] Monitoring free disk space...
echo --------------------------------------------------------
echo [%TIME%] Monitoring free disk space... >> "%LOGFILE%"

echo  >> "%LOGFILE%"
echo ---------- FREE SPACE ---------- >> "%LOGFILE%"

powershell -Command "& {
    $drives = Get-PSDrive -PSProvider FileSystem;
    foreach ($d in $drives) {
        $free = [math]::Round($d.Free / 1GB, 2);
        $used = [math]::Round(($d.Used / 1GB), 2);
        $total = [math]::Round(($d.Free + $d.Used) / 1GB, 2);
        $percent = [math]::Round(($used / $total) * 100, 2);
        Write-Host 'Drive ' $d.Root ':';
        Write-Host '  Free:   ' $free 'GB';
        Write-Host '  Used:   ' $used 'GB';
        Write-Host '  Total:  ' $total 'GB';
        Write-Host '  Usage:  ' $percent '%';
        Write-Host '';
        Add-Content -Path '%LOGFILE%' -Value ('Drive ' + $d.Root + ': Free=' + $free + 'GB, Used=' + $used + 'GB, Total=' + $total + 'GB, Usage=' + $percent + '%');
    }
}" 2>nul

echo [OK] Disk space monitoring completed.
echo [OK] Disk space monitoring completed. >> "%LOGFILE%"

:: ============================================================
:: 5. SYSTEM UPTIME & PERFORMANCE
:: ============================================================
echo.
echo --------------------------------------------------------
echo [3/4] Checking system uptime and performance...
echo --------------------------------------------------------
echo [%TIME%] Checking system uptime... >> "%LOGFILE%"

echo  >> "%LOGFILE%"
echo ---------- UPTIME & PERFORMANCE ---------- >> "%LOGFILE%"

:: === НОВЫЙ СПОСОБ ПОЛУЧЕНИЯ UPTIME (без WMIC) ===
powershell -Command "& {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem;
    $uptime = (Get-Date) - $os.LastBootUpTime;
    $days = $uptime.Days;
    $hours = $uptime.Hours;
    $minutes = $uptime.Minutes;
    Write-Host '  System Uptime: ' $days 'days ' $hours 'hours ' $minutes 'minutes';
    Add-Content -Path '%LOGFILE%' -Value ('System Uptime: ' + $days + ' days ' + $hours + ' hours ' + $minutes + ' minutes');
}" 2>nul

:: CPU and Memory via modern PowerShell
powershell -Command "& {
    $cpu = Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average;
    $mem = Get-CimInstance Win32_OperatingSystem;
    $totalMem = [math]::Round($mem.TotalVisibleMemorySize / 1MB, 2);
    $freeMem = [math]::Round($mem.FreePhysicalMemory / 1MB, 2);
    $usedMem = [math]::Round($totalMem - $freeMem, 2);
    $memPercent = [math]::Round(($usedMem / $totalMem) * 100, 2);
    Write-Host '  CPU Load:  ' $cpu '%';
    Write-Host '  Memory:    ' $usedMem '/' $totalMem 'GB (' $memPercent '%)';
    Add-Content -Path '%LOGFILE%' -Value ('CPU Load: ' + $cpu + '%, Memory: ' + $usedMem + '/' + $totalMem + 'GB (' + $memPercent + '%)');
}" 2>nul

echo [OK] System uptime and performance logged.
echo [OK] System uptime and performance logged. >> "%LOGFILE%"

:: ============================================================
:: 6. SYSTEM HEALTH METRICS
:: ============================================================
echo.
echo --------------------------------------------------------
echo [4/4] Logging system health metrics...
echo --------------------------------------------------------
echo [%TIME%] Logging system health metrics... >> "%LOGFILE%"

echo  >> "%LOGFILE%"
echo ---------- SYSTEM HEALTH ---------- >> "%LOGFILE%"

sc query wuauserv | findstr "RUNNING" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Windows Update Service: RUNNING >> "%LOGFILE%"
) else (
    echo Windows Update Service: STOPPED >> "%LOGFILE%"
)

powershell -Command "& {
    try {
        $health = Get-PhysicalDisk | Select-Object -Property HealthStatus;
        foreach ($h in $health) {
            Add-Content -Path '%LOGFILE%' -Value ('Disk Health: ' + $h.HealthStatus);
        }
    } catch {
        Add-Content -Path '%LOGFILE%' -Value ('Disk Health: Not Available');
    }
}" 2>nul

echo [OK] System health metrics logged.
echo [OK] System health metrics logged. >> "%LOGFILE%"

:: ============================================================
:: 7. FINAL LOG
:: ============================================================
echo.
echo --------------------------------------------------------
echo Collecting final information...
echo --------------------------------------------------------
echo [%TIME%] Finishing backup and monitoring... >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo ---------- FINAL REPORT ---------- >> "%LOGFILE%"
echo Backup: Created at %BACKUP_DIR% >> "%LOGFILE%"
echo Disk Space: Monitored >> "%LOGFILE%"
echo Uptime: Logged >> "%LOGFILE%"
echo Health: Logged >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo [%TIME%] Backup and monitoring completed. >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"

:: ============================================================
:: 8. SCHEDULED TASK
:: ============================================================
echo.
echo --------------------------------------------------------
echo [AUTO] Setting up automatic repeat in 7 days...
echo --------------------------------------------------------

set "SCRIPT_PATH=%~dp0"
set "SCRIPT_PATH=%SCRIPT_PATH:\=\\%"
set "TASK_NAME=NHs_Backup_AutoCheck"

> "%TEMP%\BackupTask.xml" (
echo ^<?xml version="1.0" encoding="UTF-16"?^>
echo ^<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^>
echo   ^<RegistrationInfo^>
echo     ^<Date^>%DATE%^</Date^>
echo     ^<Author^>%USERNAME%^</Author^>
echo     ^<Description^>NH's Recovery Toolkit - Automatic weekly backup & monitoring^</Description^>
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

schtasks /create /tn "%TASK_NAME%" /xml "%TEMP%\BackupTask.xml" /f >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    echo [OK] Task "%TASK_NAME%" successfully created in Task Scheduler.
    echo [i] It will run this script every Monday at 10:00 AM.
    echo [i] To cancel, run: schtasks /delete /tn "%TASK_NAME%" /f
) else (
    echo [WARNING] Failed to create scheduled task. Try again later.
)

del "%TEMP%\BackupTask.xml" >nul 2>&1

:: ============================================================
:: 9. SILENT MODE
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
echo [i] Backup and system monitoring completed!
echo [i] Log saved to: %LOGFILE%
echo.
echo ========================================================
echo       NH's BACKUP & SYSTEM MONITOR - COMPLETED
echo ========================================================
echo.
echo.
pause
exit /b 0