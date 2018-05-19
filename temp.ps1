# Load up the PSWindowsUpdate Module
Import-Module -Name PSWindowsUpdate

# By Ian Matthews with the help of many
# Last Updated July 28 2017

# Requires PowerShell 5.0 or newer
# Apparently NUGET is required for the PSWINDOWSUPDATE module
Install-PackageProvider NuGet -Force
Import-PackageProvider NuGet -Force


# Apparentely PSWindowsUpdate module comes from the PSGallery and needs to be trusted
# See https://msdn.microsoft.com/en-us/powershell/gallery/psgallery/psgallery_gettingstarted
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted


# Now actually do the update and reboot if necessary
Install-Module PSWindowsUpdate
Get-Command –module PSWindowsUpdate
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false
Get-WUInstall –MicrosoftUpdate –AcceptAll –AutoReboot

}


$objSystemInfo = New-Object -ComObject "Microsoft.Update.SystemInfo"
If($objSystemInfo.RebootRequired)
{
Write-Warning "Reboot is required to continue"
If($AutoReboot)
{
Restart-Computer -Force
} #End If $AutoReboot

# Register windows update service manager
# Examples Of ServiceID:
# Windows Update 9482f4b4-e343-43b6-b170-9a65bc822c77
# Microsoft Update 7971f918-a847-4430-9279-4a52d1efe18d
# Windows Store 117cab2d-82b1-4b5a-a08c-4d62dbee7782
# Windows Server Update Service 3da21691-e39d-4da6-8a4b-b43877bcb1b7
##Add-WUServiceManager -ServiceID 3da21691-e39d-4da6-8a4b-b43877bcb1b7