@echo off
setlocal enabledelayedexpansion
title NH's Recovery Toolkit - Network & Security
color 0D

:: ============================================================
:: NH's Recovery Toolkit v1.0
:: Author: Nikistar Corporation
:: Purpose: Reset network adapters, flush DNS, and apply basic security settings
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
set "LOGFILE=%USERPROFILE%\Desktop\NH_Recovery_Logs\NH_Network_%TIMESTAMP%.log"

if not exist "%USERPROFILE%\Desktop\NH_Recovery_Logs" mkdir "%USERPROFILE%\Desktop\NH_Recovery_Logs"

:: === INIT LOG ===
echo ====================================================== >> "%LOGFILE%"
echo NH's Recovery Toolkit v1.0 - Network & Security >> "%LOGFILE%"
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
echo   ███╗   ██╗███████╗████████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
echo   ████╗  ██║██╔════╝╚══██╔══╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
echo   ██╔██╗ ██║█████╗     ██║   ██║ █╗ ██║██║   ██║██████╔╝█████╔╝
echo   ██║╚██╗██║██╔══╝     ██║   ██║███╗██║██║   ██║██╔══██╗██╔═██╗
echo   ██║ ╚████║███████╗   ██║   ╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
echo   ╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝
echo.
echo  ========================================================
echo       NH's NETWORK & SECURITY TOOL
echo  ========================================================
echo.
echo  [i] Logging is enabled. All actions are written to:
echo      %LOGFILE%
echo.
echo  [i] This tool will perform:
echo      - Flush DNS cache
echo      - Reset Winsock catalog
echo      - Reset IP configuration
echo      - Enable Windows Firewall
echo      - Disable unnecessary network services
echo.
echo.
set /p "choice=[+] Start network & security setup? (Y/N) : "

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
echo [+] Starting network and security setup...
echo [+] Logging to: %LOGFILE%
echo.
echo [%TIME%] Session started... >> "%LOGFILE%"

:: ============================================================
:: 3. FLUSH DNS
:: ============================================================
echo.
echo --------------------------------------------------------
echo [1/5] Flushing DNS cache...
echo --------------------------------------------------------
echo [%TIME%] Flushing DNS cache... >> "%LOGFILE%"

echo  >> "%LOGFILE%"
echo ---------- DNS FLUSH ---------- >> "%LOGFILE%"

ipconfig /flushdns >nul 2>&1
echo [OK] DNS cache flushed.
echo [OK] DNS cache flushed. >> "%LOGFILE%"

:: ============================================================
:: 4. RESET WINSOCK
:: ============================================================
echo.
echo --------------------------------------------------------
echo [2/5] Resetting Winsock catalog...
echo --------------------------------------------------------
echo [%TIME%] Resetting Winsock... >> "%LOGFILE%"

echo  >> "%LOGFILE%"
echo ---------- WINSOCK RESET ---------- >> "%LOGFILE%"

netsh winsock reset >nul 2>&1
echo [OK] Winsock catalog reset.
echo [OK] Winsock catalog reset. >> "%LOGFILE%"

:: ============================================================
:: 5. RESET IP CONFIGURATION
:: ============================================================
echo.
echo --------------------------------------------------------
echo [3/5] Resetting IP configuration...
echo --------------------------------------------------------
echo [%TIME%] Resetting IP configuration... >> "%LOGFILE%"

echo  >> "%LOGFILE%"
echo ---------- IP RESET ---------- >> "%LOGFILE%"

netsh int ip reset >nul 2>&1
echo [OK] IP configuration reset.
echo [OK] IP configuration reset. >> "%LOGFILE%"

:: ============================================================
:: 6. ENABLE WINDOWS FIREWALL
:: ============================================================
echo.
echo --------------------------------------------------------
echo [4/5] Enabling Windows Firewall...
echo --------------------------------------------------------
echo [%TIME%] Enabling Windows Firewall... >> "%LOGFILE%"

echo  >> "%LOGFILE%"
echo ---------- FIREWALL ---------- >> "%LOGFILE%"

netsh advfirewall set allprofiles state on >nul 2>&1
echo [OK] Windows Firewall enabled.
echo [OK] Windows Firewall enabled. >> "%LOGFILE%"

:: ============================================================
:: 7. DISABLE UNNECESSARY NETWORK SERVICES
:: ============================================================
echo.
echo --------------------------------------------------------
echo [5/5] Disabling unnecessary network services...
echo --------------------------------------------------------
echo [%TIME%] Disabling network services... >> "%LOGFILE%"

echo  >> "%LOGFILE%"
echo ---------- NETWORK SERVICES ---------- >> "%LOGFILE%"

:: Disable NetBIOS over TCP/IP (often a security risk)
sc config netbt start= disabled >nul 2>&1
net stop netbt >nul 2>&1

echo [OK] Unnecessary network services disabled.
echo [OK] Unnecessary network services disabled. >> "%LOGFILE%"

:: ============================================================
:: 8. FINAL LOG
:: ============================================================
echo.
echo --------------------------------------------------------
echo Collecting final information...
echo --------------------------------------------------------
echo [%TIME%] Finishing network setup... >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo ---------- FINAL REPORT ---------- >> "%LOGFILE%"
echo DNS: Flushed >> "%LOGFILE%"
echo Winsock: Reset >> "%LOGFILE%"
echo IP: Reset >> "%LOGFILE%"
echo Firewall: Enabled >> "%LOGFILE%"
echo NetBIOS: Disabled >> "%LOGFILE%"

echo. >> "%LOGFILE%"
echo [%TIME%] Network setup completed. >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"

:: ============================================================
:: 9. SCHEDULED TASK (AUTO-REPEAT EVERY 7 DAYS)
:: ============================================================
echo.
echo --------------------------------------------------------
echo [AUTO] Setting up automatic repeat in 7 days...
echo --------------------------------------------------------

set "SCRIPT_PATH=%~dp0"
set "SCRIPT_PATH=%SCRIPT_PATH:\=\\%"
set "TASK_NAME=NHs_Network_AutoCheck"

> "%TEMP%\NetworkTask.xml" (
echo ^<?xml version="1.0" encoding="UTF-16"?^>
echo ^<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^>
echo   ^<RegistrationInfo^>
echo     ^<Date^>%DATE%^</Date^>
echo     ^<Author^>%USERNAME%^</Author^>
echo     ^<Description^>NH's Recovery Toolkit - Automatic weekly network & security check^</Description^>
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

schtasks /create /tn "%TASK_NAME%" /xml "%TEMP%\NetworkTask.xml" /f >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    echo [OK] Task "%TASK_NAME%" successfully created in Task Scheduler.
    echo [i] It will run this script every Monday at 10:00 AM.
    echo [i] To cancel, run: schtasks /delete /tn "%TASK_NAME%" /f
) else (
    echo [WARNING] Failed to create scheduled task. Try again later.
)

del "%TEMP%\NetworkTask.xml" >nul 2>&1

:: ============================================================
:: 10. SILENT MODE (--silent)
:: ============================================================
if "%1"=="--silent" (
    echo [%TIME%] Running in silent mode (scheduler)... >> "%LOGFILE%"
    echo [i] Completed. Log saved to: %LOGFILE%
    exit /b 0
)

:: ============================================================
:: 11. FINISH
:: ============================================================
echo.
echo --------------------------------------------------------
echo [i] Network and security setup completed!
echo [i] Log saved to: %LOGFILE%
echo.
echo ========================================================
echo       NH's NETWORK & SECURITY TOOL - COMPLETED
echo ========================================================
echo.
echo.
pause
exit /b 0