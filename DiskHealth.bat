@echo off
setlocal enabledelayedexpansion
title NH's Recovery Toolkit - Disk Health Checker
color 0B

:: ============================================================
:: NH's Recovery Toolkit v2.0
:: Author: Nikistar Corporation
:: Purpose: Modern disk health check, S.M.A.R.T., temperature, speed test & restore point
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
set "LOGFILE=%USERPROFILE%\Desktop\NH_Recovery_Logs\NH_Disk_Health_%TIMESTAMP%.log"

if not exist "%USERPROFILE%\Desktop\NH_Recovery_Logs" mkdir "%USERPROFILE%\Desktop\NH_Recovery_Logs"

:: === INIT LOG ===
echo ====================================================== >> "%LOGFILE%"
echo NH's Recovery Toolkit v2.0 - Disk Health Checker >> "%LOGFILE%"
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
echo  ██████╗ ██╗███████╗██╗  ██╗    ██╗  ██╗███████╗ █████╗ ██╗  ████████╗██╗  ██╗
echo  ██╔══██╗██║██╔════╝██║ ██╔╝    ██║  ██║██╔════╝██╔══██╗██║  ╚══██╔══╝██║  ██║
echo  ██║  ██║██║█████╗  █████╔╝     ███████║█████╗  ███████║██║     ██║   ███████║
echo  ██║  ██║██║██╔══╝  ██╔═██╗     ██╔══██║██╔══╝  ██╔══██║██║     ██║   ██╔══██║
echo  ██████╔╝██║███████╗██║  ██╗    ██║  ██║███████╗██║  ██║███████╗██║   ██║  ██║
echo  ╚═════╝ ╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝   ╚═╝  ╚═╝
echo.
echo  ========================================================
echo       NH's DISK HEALTH CHECKER
echo  ========================================================
echo.
echo  [i] Logging is enabled. All actions are written to:
echo      %LOGFILE%
echo.
echo  [i] This tool will perform:
echo      - Full disk health check
echo      - Temperature monitoring
echo      - Read/Write speed test
echo      - System Restore Point creation
echo.
echo.
set /p "choice=[+] Start disk diagnostics? (Y/N) : "

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
echo [+] Starting disk diagnostics...
echo [+] Logging to: %LOGFILE%
echo.
echo [%TIME%] Session started... >> "%LOGFILE%"

:: ============================================================
:: 3. PHYSICAL DRIVE INFO (MODERN PowerShell)
:: ============================================================
echo.
echo --------------------------------------------------------
echo [1/4] Collecting physical drive information...
echo --------------------------------------------------------
echo [%TIME%] Collecting drive info... >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo ---------- PHYSICAL DRIVES ---------- >> "%LOGFILE%"

powershell -Command "& {
    try {
        $drives = Get-PhysicalDisk -ErrorAction Stop;
        foreach ($d in $drives) {
            Write-Host 'Drive: ' $d.FriendlyName;
            Write-Host '  Model:       ' $d.Model;
            Write-Host '  Size:        ' ([math]::Round($d.Size / 1GB, 2)) 'GB';
            Write-Host '  Health:      ' $d.HealthStatus;
            Write-Host '  Media Type:  ' $d.MediaType;
            Write-Host '  Operational: ' $d.OperationalStatus;
            Write-Host '';
            Add-Content -Path '%LOGFILE%' -Value ('Drive: ' + $d.FriendlyName + ', Model=' + $d.Model + ', Size=' + ([math]::Round($d.Size / 1GB, 2)) + 'GB, Health=' + $d.HealthStatus);
        }
    } catch {
        Write-Host '[WARNING] Could not retrieve physical drive info.';
        Add-Content -Path '%LOGFILE%' -Value '[WARNING] Could not retrieve physical drive info.';
    }
}" 2>nul

:: ============================================================
:: 4. S.M.A.R.T. & TEMPERATURE (MODERN PowerShell)
:: ============================================================
echo.
echo --------------------------------------------------------
echo [2/4] Checking S.M.A.R.T. & disk temperature...
echo --------------------------------------------------------
echo [%TIME%] Checking S.M.A.R.T. & temperature... >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo ---------- S.M.A.R.T. & TEMPERATURE ---------- >> "%LOGFILE%"

powershell -Command "& {
    try {
        $smart = Get-PhysicalDisk | Get-StorageReliabilityCounter -ErrorAction Stop;
        foreach ($s in $smart) {
            Write-Host 'Drive: ' $s.FriendlyName;
            Write-Host '  Temperature: ' $s.Temperature '°C';
            Write-Host '  Read Errors: ' $s.ReadErrorsTotal;
            Write-Host '  Write Errors:' $s.WriteErrorsTotal;
            Write-Host '';
            Add-Content -Path '%LOGFILE%' -Value ('Drive: ' + $s.FriendlyName + ', Temp=' + $s.Temperature + '°C, ReadErrors=' + $s.ReadErrorsTotal + ', WriteErrors=' + $s.WriteErrorsTotal);
        }
    } catch {
        Write-Host '[WARNING] S.M.A.R.T. data is not available on this system.';
        Add-Content -Path '%LOGFILE%' -Value '[WARNING] S.M.A.R.T. data is not available.';
    }
}" 2>nul

echo. >> "%LOGFILE%"

:: ============================================================
:: 5. DISK SPEED TEST (MODERN PowerShell)
:: ============================================================
echo.
echo --------------------------------------------------------
echo [3/4] Running disk speed test (Read/Write)...
echo --------------------------------------------------------
echo [%TIME%] Running speed test... >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo ---------- SPEED TEST ---------- >> "%LOGFILE%"

powershell -Command "& {
    try {
        $path = [System.IO.Path]::GetTempPath() + 'speedtest.tmp';
        $size = 100MB;
        $buffer = New-Object byte[] $size;
        (New-Object Random).NextBytes($buffer);
        
        # Write test
        $sw = [System.Diagnostics.Stopwatch]::StartNew();
        [System.IO.File]::WriteAllBytes($path, $buffer);
        $sw.Stop();
        $writeSpeed = [math]::Round($size / $sw.Elapsed.TotalSeconds / 1MB, 2);
        Write-Host '  Write: ' $writeSpeed 'MB/s';
        Add-Content -Path '%LOGFILE%' -Value ('  Write: ' + $writeSpeed + ' MB/s');

        # Read test
        $sw.Restart();
        $data = [System.IO.File]::ReadAllBytes($path);
        $sw.Stop();
        $readSpeed = [math]::Round($size / $sw.Elapsed.TotalSeconds / 1MB, 2);
        Write-Host '  Read:  ' $readSpeed 'MB/s';
        Add-Content -Path '%LOGFILE%' -Value ('  Read:  ' + $readSpeed + ' MB/s');

        Remove-Item $path -Force -ErrorAction SilentlyContinue;
    } catch {
        Write-Host '[WARNING] Speed test failed.';
        Add-Content -Path '%LOGFILE%' -Value '[WARNING] Speed test failed.';
    }
}" 2>nul

echo. >> "%LOGFILE%"

:: ============================================================
:: 6. SYSTEM RESTORE POINT
:: ============================================================
echo.
echo --------------------------------------------------------
echo [4/4] Creating System Restore Point...
echo --------------------------------------------------------
echo [%TIME%] Creating restore point... >> "%LOGFILE%"

powershell -Command "& {
    try {
        Checkpoint-Computer -Description 'NHs_Disk_Health_Check' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop;
        Write-Host '[OK] Restore point successfully created.';
        Add-Content -Path '%LOGFILE%' -Value '[OK] Restore point created.';
    } catch {
        Write-Host '[WARNING] Could not create restore point. System protection may be disabled.';
        Add-Content -Path '%LOGFILE%' -Value '[WARNING] Could not create restore point.';
    }
}" 2>nul

echo. >> "%LOGFILE%"

:: ============================================================
:: 7. FINAL LOG
:: ============================================================
echo.
echo --------------------------------------------------------
echo Collecting final information...
echo --------------------------------------------------------
echo [%TIME%] Finishing diagnostics... >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo ---------- FINAL REPORT ---------- >> "%LOGFILE%"
echo Drives: (see above) >> "%LOGFILE%"
echo S.M.A.R.T.: (see above) >> "%LOGFILE%"
echo Temperature: (see above) >> "%LOGFILE%"
echo Speed: (see above) >> "%LOGFILE%"
echo Restore Point: (see above) >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo [%TIME%] Diagnostics completed. >> "%LOGFILE%"
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
set "TASK_NAME=NHs_Disk_Health_AutoCheck"

> "%TEMP%\HealthTask.xml" (
echo ^<?xml version="1.0" encoding="UTF-16"?^>
echo ^<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^>
echo   ^<RegistrationInfo^>
echo     ^<Date^>%DATE%^</Date^>
echo     ^<Author^>%USERNAME%^</Author^>
echo     ^<Description^>NH's Recovery Toolkit - Automatic weekly disk health check^</Description^>
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

schtasks /create /tn "%TASK_NAME%" /xml "%TEMP%\HealthTask.xml" /f >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    echo [OK] Task "%TASK_NAME%" successfully created in Task Scheduler.
    echo [i] It will run this script every Monday at 10:00 AM.
    echo [i] To cancel, run: schtasks /delete /tn "%TASK_NAME%" /f
) else (
    echo [WARNING] Failed to create scheduled task. Try again later.
)

del "%TEMP%\HealthTask.xml" >nul 2>&1

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
echo [i] Disk diagnostics completed!
echo [i] Log saved to: %LOGFILE%
echo.
echo ========================================================
echo       NH's DISK HEALTH CHECKER - DIAGNOSTICS COMPLETED
echo ========================================================
echo.
echo.
pause
exit /b 0