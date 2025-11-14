#────────────────────────────────────────────
#  XMRigService.ps1 – STRICT MODE
#  PURPOSE:
#     • Run XMRig miner as a Windows service
#     • No flags added beyond config.json
#     • No mining done by monerod
#     • Clean restart loop for reliability
#────────────────────────────────────────────

Set-StrictMode -Version Latest

#────────────────────────────────────────────
#  PATHS
#────────────────────────────────────────────

$BaseDir    = "D:\Monero-CLI"
$MinerPath  = "$BaseDir\xmrig.exe"
$StartupLog = "$BaseDir\xmrig_log.txt"

#────────────────────────────────────────────
#  LOG FUNCTION
#────────────────────────────────────────────

function Log($msg) {
    $line = "[{0}] {1}" -f (Get-Date), $msg
    Add-Content -Path $StartupLog -Value $line
    Write-Host $line
}

#────────────────────────────────────────────
#  VERIFY FILES (STRICT MODE SAFETY)
#────────────────────────────────────────────

if (-not (Test-Path $MinerPath)) {
    Log "ERROR: XMRig missing at $MinerPath"
    exit 1
}

if (-not (Test-Path "$BaseDir\config.json")) {
    Log "ERROR: config.json missing — miner cannot run."
    exit 1
}

#────────────────────────────────────────────
#  MAIN LOOP
#────────────────────────────────────────────

Log "Starting XMRig Miner (STRICT MODE)..."

while ($true) {

    Log "Launching XMRig..."

    $process = Start-Process `
        -FilePath $MinerPath `
        -WorkingDirectory $BaseDir `
        -NoNewWindow `
        -PassThru

    # Wait until process exits
    Wait-Process -Id $process.Id

    $exitCode = $process.ExitCode
    Log "XMRig exited with code $exitCode"

    Log "Restarting miner in 10 seconds..."
    Start-Sleep -Seconds 10
}
