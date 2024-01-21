# Windows VM Creator

I have been wanting to create a way to provision a Windows qcow2 file that I could use as an ephemeral Virtual Machine in my KVM-based home lab.
I also wanted to be able to customize these images and create new images with as much automation as possible.

## Requirements

- KVM/libvirt installed on your workstation

Binaries:
- mkisofs
- virt-viewer
- qemu-img

If you're using NixOS and already have libvirt set up, you should be able to get everything else needed with the following command:

```
nix shell nixpkgs#cdrkit nixpkgs#virt-viewer nixpkgs#qemu
```

## Download the Windows iso

You can download the official Windows ISO from the following website:

- [Windows 11](https://www.microsoft.com/software-download/windows11)

Copy it to this folder and name it `windows.iso`.

## Generate the Answer File

The key to an automated Windows installation lies in the `autounattend.xml` file.
You can use the generator at [schneegans.de](https://schneegans.de/windows/unattend-generator/) to easily create one of these files.
If you create an iso an mount it in the VM alongside the installation media, then Windows will automatically use it.

This can be done with the following commands:

```
ls autounattend
autounattend.xml
mkisofs -o autounattend.iso -J -r autounattend
```

I have included an `autounattend.xml` that probably has most of the configurations you'll want.
You can use it as a jumping off point [here](https://schneegans.de/windows/unattend-generator/?LanguageMode=Unattended&UILanguage=en-US&UserLocale=en-US&KeyboardLayout=0409%3A00000409&ProcessorArchitecture=amd64&BypassRequirementsCheck=true&BypassNetworkCheck=true&ComputerNameMode=Random&TimeZoneMode=Explicit&TimeZone=UTC&PartitionMode=Unattended&PartitionLayout=GPT&EspSize=300&RecoveryMode=None&WindowsEditionMode=Unattended&WindowsEdition=pro&UserAccountMode=Unattended&AccountName0=Admin&AccountPassword0=password&AccountGroup0=Administrators&AccountName1=User&AccountPassword1=password&AccountGroup1=Users&AccountName2=&AccountName3=&AccountName4=&AutoLogonMode=Own&LockoutMode=Default&DisableSystemRestore=true&EnableLongPaths=true&EnableRemoteDesktop=true&AllowPowerShellScripts=true&DisableLastAccess=true&DisableAppSuggestions=true&WifiMode=Skip&ExpressSettings=DisableAll&Remove3DViewer=true&RemoveCalculator=true&RemoveCamera=true&RemoveClipchamp=true&RemoveClock=true&RemoveCortana=true&RemoveDevHome=true&RemoveFeedbackHub=true&RemoveGetHelp=true&RemoveInternetExplorer=true&RemoveMaps=true&RemoveMathInputPanel=true&RemoveZuneVideo=true&RemoveNews=true&RemoveNotepadClassic=true&RemoveNotepad=true&RemoveOffice365=true&RemoveOneDrive=true&RemoveOneNote=true&RemoveOpenSSHClient=true&RemoveOutlook=true&RemovePaint=true&RemovePaint3D=true&RemovePeople=true&RemovePhotos=true&RemovePowerAutomate=true&RemovePowerShellISE=true&RemoveQuickAssist=true&RemoveSkype=true&RemoveSnippingTool=true&RemoveSolitaire=true&RemoveStepsRecorder=true&RemoveStickyNotes=true&RemoveTeams=true&RemoveGetStarted=true&RemoveToDo=true&RemoveVoiceRecorder=true&RemoveWeather=true&RemoveWindowsMediaPlayer=true&RemoveZuneMusic=true&RemoveWindowsTerminal=true&RemoveWordPad=true&RemoveXboxApps=true&RemoveYourPhone=true&WdacMode=Skip&Error=).

## Create the Virtual Machine

The installation can be kicked off with the following command:

```
sudo virt-install --name windows \
  --vcpus 2 \
  --memory 4096 \
  --network network=default \
  --graphics=vnc \
  --console pty,target_type=serial \
  --cdrom ./windows.iso \
  --disk path=./autounattend.iso,device=cdrom \
  --disk path=./windows.qcow2,size=64,format=qcow2 \
  --os-variant win11 
```

Upon executing that command, virt-viewer should appear and (unfortunately) you will need to press a key to boot the iso.
From there, however, you should just be able to walk off for about 30 minutes and come back to a Windows desktop.

At the end of the installation, you can run the following command to kill the Virtual Machine while leaving the qcow2 intact:
```
sudo virsh destroy windows
sudo virsh undefine --nvram windows
```

## Shrink the qcow2

At this point, you might notice that the qcow2 says it's 64GB.
It isn't taking up all of this space, so we can make that file smaller with the following command:

```
qemu-img convert -O qcow2 ./windows.qcow2 ./windows.shrunk.qcow2
```
