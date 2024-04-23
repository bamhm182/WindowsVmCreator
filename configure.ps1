#Disable IPv6
New-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name "DisabledComponents" -Value 255 -PropertyType DWord -Force -ErrorAction SilentlyContinue

# Configure WinRM
Add-LocalGroupMember -Group 'Remote Management Users' -Member 'Administrator' -ErrorAction SilentlyContinue
Start-Service WinRM
Set-Service -Name WinRM -StartupType 'Automatic'
Set-Item WSMan:\localhost\Client\TrustedHosts -Value '*' -Force
Restart-Service WinRM

# Configure RDP
#Add-LocalGroupMember -Group 'Remote Desktop Users' -Member 'User'

# Configure OpenSSH
Add-WindowsCapability -Online -Name OpenSSH.Client
Add-WindowsCapability -Online -Name OpenSSH.Server
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
New-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force -ErrorAction SilentlyContinue

# Configure Coder
#New-Item -ItemType Directory -Path "C:\Users\user\AppData\Roaming\coder\"
#Invoke-WebRequest https://raw.githubusercontent.com/coder/coder/main/provisionersdk/scripts/bootstrap_windows.ps1 -OutFile C:\Users\user\AppData\Roaming\coder\coder.ps1
#$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File C:\Users\user\AppData\Roaming\coder\coder.ps1"
#$trigger = New-ScheduledTaskTrigger -AtStartup
#$principal = New-ScheduledTaskPrincipal -UserId "User" -LogonType S4U -RunLevel Limited
#Register-ScheduledTask -TaskName "CoderAgent" -Description "Start the Coder Agent" -Action $action -Trigger $trigger -Principal $principal
#$envVariables = ${
#    "CODER_AGENT_AUTH" = "token"
#    "CODER_AGENT_TOKEN_FILE" = "C:\Users\user\AppData\Coder\token"
#    "CODER_AGENT_URL" = "https://coder.lab.bytepen.com"
#}
#Set-ScheduledTask -TaskName "CoderAgent" -TaskPath "\" -Principal $envVariables

# Configure Windows
# Don't lock the screen when the screensaver appears
Set-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Control Panel\Desktop" -Name "ScreenSaverIsSecure" -Value 0 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "Registry::HKEY_USERS\.DEFAULT\Control Panel\Desktop" -Name "ScreenSaverIsSecure" -Value 0 -Force -ErrorAction SilentlyContinue
# Dark Mode
New-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Force -ErrorAction SilentlyContinue
#New-ItemProperty -Path "Registry::HKEY_USERS\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value 0 -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Force -ErrorAction SilentlyContinue
#New-ItemProperty -Path "Registry::HKEY_USERS\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value 0 -Force -ErrorAction SilentlyContinue

# Cleanup
Get-WmiObject -Namespace "root\cimv2" -Class Win32_ShadowCopy | ForEach-Object { $_.Delete() }
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Prefetch\*" -Force -Recurse -ErrorAction SilentlyContinue
Start-Process -FilePath "C:\Windows\System32\cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait
Optimize-Volume -DriveLetter "C" -Defrag -Verbose
Get-WinEvent -ListLog * | ForEach-Object { wevtutil cl $_.LogName }
Clear-DnsClientCache
Get-ChildItem -Path "$env:LOCALAPPDATA\Packages\Microsoft.MicrosoftEdge_*" -Recurse | Remove-Item -Force -Recurse
Remove-Item -Path "$env:USERPROFILE\Downloads\*" -Force -Recurse
Clear-History
Remove-Item -Path "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\*" -Recurse
