#-------------------------------------------------------------
#  DailyStatus.ps1  (STRICT MODE v4)
#  Monero Node + XMRig Daily Health Summary
#-------------------------------------------------------------

Set-StrictMode -Version Latest

$SNS_Topic = "arn:aws:sns:us-west-2:381328847089:monero-alerts"
$NodeURL   = "http://127.0.0.1:18081/json_rpc"

#----------------------------------------
function Get-RPCInfo {
    try {
        $body = @{
            jsonrpc = "2.0"
            id      = "0"
            method  = "get_info"
        } | ConvertTo-Json -Depth 5

        $resp = Invoke-RestMethod -Uri $NodeURL -Method Post `
                                  -Body $body -ContentType "application/json"

        if ($resp -and $resp.result) {
            return @{
                Ok     = $true
                Height = $resp.result.height
                Target = $resp.result.target_height
                Peers  = ($resp.result.incoming_connections_count +
                          $resp.result.outgoing_connections_count)
            }
        }

        return @{ Ok = $false }
    }
    catch {
        return @{ Ok = $false }
    }
}

#----------------------------------------
function Get-ProcessSafe($name) {
    $p = Get-Process -Name $name -ErrorAction SilentlyContinue
    if ($p) { return $true } else { return $false }
}

#----------------------------------------
function Get-SystemStats {
    $disk = Get-PSDrive C
    $freeGB = [math]::Round($disk.Free/1GB, 2)

    $cpu = Get-Counter '\Processor(_Total)\% Processor Time'
    $cpuLoad = [math]::Round($cpu.CounterSamples.CookedValue, 1)

    return @{
        Disk = $freeGB
        CPU  = $cpuLoad
    }
}

#----------------------------------------
function Send-StatusEmail($msg) {
    aws sns publish `
        --topic-arn $SNS_Topic `
        --subject "Monero + XMRig Daily Status" `
        --message "$msg" | Out-Null
}

#-------------------------------------------------------------
#  MAIN EXECUTION
#-------------------------------------------------------------

$rpcInfo       = Get-RPCInfo
$nodeRunning   = Get-ProcessSafe "monerod"
$xmrigRunning  = Get-ProcessSafe "xmrig"
$sys           = Get-SystemStats

#----------------------------------------
# Build message safely (no unicode, no ternary)
#----------------------------------------

$msg = @()
$msg += "Monero + XMRig Daily Status Report"
$msg += "----------------------------------"
$msg += ""
$msg += "NODE"

if ($nodeRunning) {
    $msg += "- monerod.exe: RUNNING"
} else {
    $msg += "- monerod.exe: STOPPED"
}

if ($rpcInfo.Ok) {
    $msg += "- RPC:         OK"
    $msg += "- Height:      $($rpcInfo.Height)"
    $msg += "- Target:      $($rpcInfo.Target)"
    $msg += "- Peers:       $($rpcInfo.Peers)"
} else {
    $msg += "- RPC:         DOWN"
    $msg += "- Height:      -"
    $msg += "- Target:      -"
    $msg += "- Peers:       -"
}

$msg += ""
$msg += "MINER"

if ($xmrigRunning) {
    $msg += "- xmrig.exe:   RUNNING"
} else {
    $msg += "- xmrig.exe:   STOPPED"
}

$msg += "- Hashrate:    (API disabled)"
$msg += "- Uptime:      (not tracked)"
$msg += "- Shares:      (not tracked)"

$msg += ""
$msg += "SYSTEM"
$msg += "- Disk Free:   $($sys.Disk) GB"
$msg += "- CPU Load:    $($sys.CPU) %"

$msg += ""
$msg += "FINAL"

if (-not $nodeRunning -or -not $xmrigRunning -or -not $rpcInfo.Ok) {
    $msg += "- ISSUES DETECTED - See sections above."
} else {
    $msg += "- Everything OK."
}

Send-StatusEmail ($msg -join "`n")

Write-Host "[DailyStatus] Summary sent."
