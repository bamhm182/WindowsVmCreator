#Disable IPv6
New-ItemProperty -Path "Registry::HKLM\System\CurrentControlSet\Service\Tcpip6\Parameters" -Name "DisabledComponents" -Value 255 -PropertyType DWord

# Configure WinRM
Add-LocalGroupMember -Group 'Remote Management Users' -Member 'Admin'
Start-Service WinRM
Set-Service -Name WinRM -StartupType 'Automatic'
Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*' -Force
Restart-Service WinRM

# Configure RDP
Add-LocalGroupMember -Group 'Remote Desktop Users' -Member 'User'

# Configure OpenSSH
Add-WindowsCapability -Online -Name OpenSSH.Client
Add-WindowsCapability -Online -Name OpenSSH.Server
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
