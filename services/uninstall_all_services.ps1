$nssm = "C:\Windows\System32\nssm.exe"

& $nssm remove MoneroNode confirm
& $nssm remove XMRig confirm

Write-Host "All NSSM services removed."
