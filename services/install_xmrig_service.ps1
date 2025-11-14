$nssm = "C:\Windows\System32\nssm.exe"
$serviceName = "XMRig"
$exe = "D:\Monero-CLI\xmrig.exe"
$args = "--config=D:\Monero-CLI\config.json"

& $nssm install $serviceName $exe $args
& $nssm set $serviceName Start SERVICE_AUTO_START
& $nssm set $serviceName AppNoConsole 1
& $nssm set $serviceName AppRestartDelay 5000

Write-Host "XMRig service installed."
