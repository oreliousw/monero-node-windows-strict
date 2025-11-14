Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "🔍 Starting cleanup of old Monero/XMRig monitor tasks, services, and scripts..." -ForegroundColor Cyan

#────────────────────────────────────────
# 1. Remove old Scheduled Tasks
#────────────────────────────────────────

$oldTasks = @(
    "SNSPublishMoneroHealth",
    "MoneroMonitor",
    "XMRigMonitor",
    "MiningMonitor",
    "MiningHealthCheck",
    "MoneroHealth"
)

foreach ($task in $oldTasks) {
    try {
        $exists = Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
        if ($exists) {
            Write-Host "🗑️ Removing scheduled task: $task"
            Unregister-ScheduledTask -TaskName $task -Confirm:$false
        }
    }
    catch { }
}

#────────────────────────────────────────
# 2. Remove old NSSM monitor services
#────────────────────────────────────────

$oldServices = @(
    "MoneroMonitor",
    "XMRigMonitor",
    "MiningWatchdog",
    "MoneroHealth",
    "MoneroStatus"
)

foreach ($svc in $oldServices) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service) {
        Write-Host "🗑️ Removing NSSM service: $svc"
        nssm stop $svc | Out-Null
        nssm remove $svc confirm | Out-Null
    }
}

#────────────────────────────────────────
# 3. Kill any running PowerShell monitor jobs
#────────────────────────────────────────

$procs = Get-Process powershell -ErrorAction SilentlyContinue
foreach ($p in $procs) {
    if ($p.Path -like "*monero*" -or
        $p.Path -like "*xmrig*" -or
        $p.Path -like "*monitor*") {

        Write-Host "🛑 Stopping leftover monitor PowerShell job (PID $($p.Id))"
        Stop-Process -Id $p.Id -Force
    }
}

#────────────────────────────────────────
# 4. Remove leftover monitor scripts from disk
#────────────────────────────────────────

$foldersToScan = @(
    "D:\Monero-CLI",
    "D:\Monero",
    "D:\Scripts",
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Documents"
)

$patterns = @("*monitor*.ps1", "*health*.ps1", "*status*.ps1")

foreach ($folder in $foldersToScan) {
    if (Test-Path $folder) {
        foreach ($pattern in $patterns) {
            $files = Get-ChildItem -Path $folder -Filter $pattern -Recurse -ErrorAction SilentlyContinue
            foreach ($f in $files) {
                # DO NOT delete the new DailyStatus.ps1
                if ($f.Name -ne "DailyStatus.ps1") {
                    Write-Host "🗑️ Deleting old script: $($f.FullName)"
                    Remove-Item $f.FullName -Force
                }
            }
        }
    }
}

#────────────────────────────────────────
# 5. Final status
#────────────────────────────────────────

Write-Host ""
Write-Host "✨ Cleanup complete!" -ForegroundColor Green
Write-Host "Only your new Strict-Mode services remain:"
Write-Host " - MoneroNode (NSSM)"
Write-Host " - XMRigService (NSSM)"
Write-Host " - DailyStatus.ps1 scheduled task (if enabled)" 
Write-Host ""
Write-Host "Everything else has been safely removed."
