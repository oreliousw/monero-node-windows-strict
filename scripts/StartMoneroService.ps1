#────────────────────────────────────────────
#  StartMoneroService.ps1 – STRICT MODE v3
#  PURPOSE: Full Node ONLY (no mining)
#  XMRig handles all mining separately.
#────────────────────────────────────────────

Set-StrictMode -Version Latest

#────────────────────────────────────────────
#  PATHS
#────────────────────────────────────────────

$BaseDir    = "D:\Monero-CLI"
$DataDir    = "D:\Monero-CLI\bitmonero"   # IMPORTANT: your chain lives here
$NodePath   = "$BaseDir\monerod.exe"
$StartupLog = "$BaseDir\startup_log.txt"
$RPC_URL    = "http://127.0.0.1:18081/json_rpc"

# SNS Alerts
$SNS_Topic  = "arn:aws:sns:us-west-2:381328847089:monero-alerts"

# Rate limit SNS (15 minutes)
$LastAlertTime = (Get-Date).AddMinutes(-20)

#────────────────────────────────────────────
#  ARGUMENTS — STRICT MODE, FULL NODE ONLY
#────────────────────────────────────────────

$Args = @(
    "--non-interactive",
    "--data-dir=$DataDir",

    # RPC (LOCAL ONLY)
    "--rpc-bind-ip=127.0.0.1",
    "--rpc-bind-port=18081",

    # P2P network
    "--p2p-bind-ip=0.0.0.0",
    "--p2p-bind-port=18080"
) -join " "

#────────────────────────────────────────────
#  LOGGING
#────────────────────────────────────────────

function Log($msg) {
    $line = "[{0}] {1}" -f (Get-Date), $msg
    Add-Content -Path $StartupLog -Value $line
    Write-Host $line
}

#────────────────────────────────────────────
#  SNS ALERTS
#────────────────────────────────────────────

function Send-SNSAlert($subject, $message) {
    if ((Get-Date) -lt $LastAlertTime.AddMinutes(15)) { return }
    $LastAlertTime = Get-Date

    try {
        aws sns publish `
            --topic-arn $SNS_Topic `
            --subject "$subject" `
            --message "$message" | Out-Null

        Log "SNS Alert Sent: $subject"
    }
    catch { Log "SNS ERROR: $($_.Exception.Message)" }
}

#────────────────────────────────────────────
#  RPC CHECK
#────────────────────────────────────────────

function Test-RPC {
    try {
        $body = @{
            jsonrpc = "2.0"
            id      = "0"
            method  = "get_info"
        } | ConvertTo-Json

        Invoke-RestMethod -Uri $RPC_URL -Method Post -Body $body -ContentType "application/json"
    }
    catch { return $null }
}

#────────────────────────────────────────────
#  DISK CHECK
#────────────────────────────────────────────

function Check-Disk {
    $drive = Get-PSDrive C
    $freeGB = [math]::Round($drive.Free / 1GB, 2)

    if ($freeGB -lt 10) {
        Send-SNSAlert "Monero Low Disk Space" "Only $freeGB GB free on C: drive."
        Log "Low disk space: $freeGB GB"
    }
}

#────────────────────────────────────────────
#  LOG ROTATION
#────────────────────────────────────────────

function Rotate-Logs {
    if (Test-Path $StartupLog) {
        if ((Get-Item $StartupLog).Length / 1MB -gt 50) {
            $backup = "$BaseDir\startup_log_{0}.txt" -f (Get-Date -Format "yyyyMMdd_HHmm")
            Move-Item $StartupLog $backup -Force
            Log "Log rotated → $backup"
        }
    }
}

#────────────────────────────────────────────
#  MAIN LOOP
#────────────────────────────────────────────

Log "Starting Monero Full Node (STRICT MODE v3)..."

while ($true) {

    Log "Launching monerod..."
    $process = Start-Process -FilePath $NodePath -ArgumentList $Args `
        -WorkingDirectory $BaseDir -NoNewWindow -PassThru

    $lastHeight   = 0
    $stalledCount = 0
    $syncedSent   = $false

    while (-not $process.HasExited) {

        Start-Sleep -Seconds 10
        Rotate-Logs
        Check-Disk

        $resp = Test-RPC
        if ($null -eq $resp) {
            Log "RPC DOWN"
            Send-SNSAlert "Monero RPC DOWN" "RPC not responding."
            continue
        }

        $height  = $resp.height
        $target  = $resp.target_height
        $peers   = $resp.incoming_connections_count + $resp.outgoing_connections_count
        $version = $resp.version

        Log "RPC OK: Height=$height Target=$target Peers=$peers Version=$version"

        if ($peers -lt 4) {
            Send-SNSAlert "Monero Low Peer Count" "Only $peers peers connected."
        }

        if ($height -eq $lastHeight) {
            $stalledCount++
            if ($stalledCount -ge 3) {
                Send-SNSAlert "Monero Sync Stalled" "Height stuck at $height."
            }
        } else {
            $stalledCount = 0
        }

        if (-not $syncedSent -and $target -gt 0 -and $height -ge ($target - 2)) {
            Send-SNSAlert "Monero Fully Synced" "Height $height (target $target)."
            $syncedSent = $true
        }

        if ($version -lt 18) {
            Send-SNSAlert "Monero Version Warning" "Node version $version is outdated."
        }

        $lastHeight = $height
    }

    $exitCode = $process.ExitCode
    Log "monerod exited with code $exitCode"
    Send-SNSAlert "Monero Node Crash" "monerod exited with code $exitCode. Restarting..."

    Log "Restarting in 10 seconds..."
    Start-Sleep -Seconds 10
}
