$nssm = "C:\Windows\System32\nssm.exe"
$serviceName = "MoneroNode"
$exe = "D:\Monero-CLI\monerod.exe"
$args = "--non-interactive --data-dir D:\Monero-CLI\bitmonero --rpc-bind-ip 127.0.0.1 --rpc-bind-port 18081 --p2p-bind-port 18080 --confirm-external-bind"

& $nssm install $serviceName $exe $args
& $nssm set $serviceName Start SERVICE_AUTO_START
& $nssm set $serviceName AppNoConsole 1
& $nssm set $serviceName AppRestartDelay 5000

Write-Host "Monero service installed."
