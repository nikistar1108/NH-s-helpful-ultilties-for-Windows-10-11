NH's RECOVERY TOOLKIT
======================

A complete set of Windows system recovery, diagnostics, and optimization tools.
Created by Nikistar Corporation. All scripts are designed to be run as Administrator.


INCLUDED TOOLS
--------------

RestoreOS.bat
    Full system repair using SFC, DISM, and CHKDSK.

DiskHealth.bat
    Disk health check: S.M.A.R.T., temperature, and read/write speed test.

OS_Optimizer.bat
    System cleanup: temp files, update cache, defragmentation (HDD only).

Network_Fixer.bat
    Network reset: flush DNS, reset Winsock, reset IP, enable Firewall.

WinBackup.bat
    System backup: registry export, hosts file, BCD, and disk space monitoring.


IMPORTANT NOTES
---------------

- All scripts must be run as Administrator.
  Right-click the file and select "Run as administrator".

- Logs are automatically saved to:
  %USERPROFILE%\Desktop\NH_Recovery_Logs\

- All scripts support the --silent argument for scheduled execution.


AUTOMATIC SCHEDULING
--------------------

Every script automatically creates a scheduled task that runs every Monday at 10:00 AM.

To cancel a scheduled task, open Command Prompt as Administrator and run:

schtasks /delete /tn "NHs_Recovery_AutoCheck" /f
schtasks /delete /tn "NHs_Disk_Health_AutoCheck" /f
schtasks /delete /tn "NHs_Cleanup_AutoCheck" /f
schtasks /delete /tn "NHs_Network_AutoCheck" /f
schtasks /delete /tn "NHs_Backup_AutoCheck" /f


HOW TO USE
----------

1. Download or copy the entire toolkit folder.
2. Right-click any .bat file and select Run as administrator.
3. Follow the on-screen prompts.
4. Let the script finish. Logs will be saved to your Desktop.


TOOL DETAILS
------------

RestoreOS.bat
    - Runs sfc /scannow to repair system files.
    - Runs DISM /Online /Cleanup-Image /RestoreHealth.
    - Optionally runs chkdsk C: /F /R to check for disk errors.
    - Logs system information.

DiskHealth.bat
    - Uses modern PowerShell to detect physical drives and their health.
    - Reads S.M.A.R.T. data and temperature.
    - Performs a 100 MB read/write speed test.
    - Creates a System Restore Point.

OS_Optimizer.bat
    - Cleans user and system Temp folders.
    - Cleans Prefetch and $Recycle.Bin.
    - Stops Windows Update services, cleans the update cache, and restarts them.
    - Defragments system drive only if an HDD is detected.
    - Disables unnecessary services: Windows Search, Xbox services.

Network_Fixer.bat
    - Flushes DNS cache.
    - Resets Winsock catalog.
    - Resets IP configuration.
    - Enables Windows Firewall for all profiles.
    - Disables NetBIOS over TCP/IP.

WinBackup.bat
    - Exports HKLM and HKCU registry hives to .reg files.
    - Backs up hosts file and BCD boot configuration.
    - Monitors free disk space and logs usage per drive.
    - Logs system uptime, CPU load, and memory usage.
    - Checks Windows Update service and disk health status.


RECOMMENDED FOLDER STRUCTURE
----------------------------

NHs_Recovery_Toolkit/
    README.md
    RestoreOS.bat
    DiskHealth.bat
    OS_Optimizer.bat
    Network_Fixer.bat
    WinBackup.bat
    NH_Recovery_Logs/   (created automatically on Desktop)


LICENSE
-------

This toolkit is provided as is for personal and educational use.
Use at your own risk. Always back up important data before running system tools.


AUTHOR
------

Nikistar Corporation
Built with batch scripts.
