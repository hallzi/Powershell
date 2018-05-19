Function Install-Powershell {
 # Use shortcode to find latest TechNet download site
 $confirmationPage = 'http://www.microsoft.com/en-us/download/' +  $((invoke-webrequest 'http://aka.ms/wmf5latest' -UseBasicParsing).links | ? Class -eq 'mscom-link download-button dl' | % href)
 # Parse confirmation page and look for URL to file
 $directURL = (invoke-webrequest $confirmationPage -UseBasicParsing).Links | ? Class -eq 'mscom-link' | ? href -match 'Win8.1AndW2K12R2-KB3134758-x64.msu' | % href | select -first 1
 # Download file to local
 $download = invoke-webrequest $directURL -OutFile $env:Temp\wmf5latest.msu
 # Install quietly with no reboot
 if (test-path $env:Temp\wmf5latest.msu) {
   start -wait $env:Temp\wmf5latest.msu -argumentlist '/quiet /norestart'
   }
 else { throw 'the update file is not available at the specified location' }
 # Clean up
 Remove-Item $env:Temp\wmf5latest.msu
}

Function Set-WSUSSettings {
 [CmdletBinding(DefaultParameterSetName='DownloadAndNotify')]
 param(
  [switch] $DownloadNotify,

  [parameter(ParameterSetName='InstallDay')][string] $InstallDay,
  [parameter(ParameterSetName='EveryDay')][switch] $EveryDay,
  [parameter(ParameterSetName='NoAuto')][switch] $NoAuto,
  [parameter(ParameterSetName='NotifyAndDownload')][switch] $NotifyDownload,
  [parameter(ParameterSetName='Pilot')][switch] $Pilot
 )
 # Add WSUS settings to Registry
 $RegistryBasePath = "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
 $ScheduledInstallDay = [Int] [DayOfWeek] $InstallDay + 1
 if($InstallDay) {
  $TargetGroup = "4-" + $ScheduledInstallDay + " Auto every $InstallDay"
 } elseif ($EveryDay) {
   $TargetGroup = "4-0 Auto every Night"
 } elseif ($NoAuto) {
   $TargetGroup = "5 No Auto Updates"
 } elseif ($DownloadNotify) {
   $TargetGroup = "3-0 Download and Notify for Install"
 } elseif ($NotifyDownload) {
   $TargetGroup = "2-0 Notify for Download and Install"
 } elseif ($Pilot) {
   $TargetGroup = "Pilot Group 4-0"
 }
 $WUServer = (Get-WmiObject -class Win32_OperatingSystem).Caption
 if (((Get-WmiObject win32_operatingsystem).Version) -ge 10) {
  $WUServer = "https://wau.umsja.is"
 } else {
  $WUServer = "https://wsus.umsja.is"
 }
 # Write WSUS settings
 if($Pilot) {
  New-ItemProperty -Path $RegistryBasePath -Name ElevateNonAdmins -Value "1" -PropertyType DWORD -Force | Out-Null
 } else {
  New-ItemProperty -Path $RegistryBasePath -Name ElevateNonAdmins -Value "0" -PropertyType DWORD -Force | Out-Null
 }
 New-ItemProperty -Path $RegistryBasePath -Name WUServer -Value $WUServer -PropertyType String -Force | Out-Null
 New-ItemProperty -Path $RegistryBasePath -Name WUStatusServer -Value $WUServer -PropertyType String -Force | Out-Null
 New-ItemProperty -Path $RegistryBasePath -Name TargetGroupEnabled -Value "1" -PropertyType DWORD -Force | Out-Null
 New-ItemProperty -Path $RegistryBasePath -Name TargetGroup -Value $TargetGroup -PropertyType String -Force | Out-Null
 if(($InstallDay -eq 1) -or ($InstallDay -eq 7) -or $Pilot) {
  New-ItemProperty -Path $RegistryBasePath -Name NoAutoRebootWithLoggedOnUsers -Value "0" -PropertyType DWORD -Force | Out-Null
 } else {
  New-ItemProperty -Path $RegistryBasePath -Name NoAutoRebootWithLoggedOnUsers -Value "1" -PropertyType DWORD -Force | Out-Null
 }
 if(($InstallDay -eq 1) -or ($InstallDay -eq 7) -or $Pilot) {
  New-ItemProperty -Path $RegistryBasePath -Name NoAutoUpdate -Value "0" -PropertyType DWORD -Force | Out-Null
 } else {
  New-ItemProperty -Path $RegistryBasePath -Name NoAutoUpdate -Value "1" -PropertyType DWORD -Force | Out-Null
 }
 if($DownloadNotify) {
  New-ItemProperty -Path $RegistryBasePath -Name AUOptions -Value "3" -PropertyType DWORD -Force | Out-Null
 } elseif ($EveryDay -or ($InstallDay -eq 1) -or ($InstallDay -eq 7) -or $Pilot) {
  New-ItemProperty -Path $RegistryBasePath -Name AUOptions -Value "4" -PropertyType DWORD -Force | Out-Null
 } elseif ($NoAuto) {
  New-ItemProperty -Path $RegistryBasePath -Name AUOptions -Value "5" -PropertyType DWORD -Force | Out-Null
 } else {
  New-ItemProperty -Path $RegistryBasePath -Name AUOptions -Value "2" -PropertyType DWORD -Force | Out-Null
 }
 New-ItemProperty -Path $RegistryBasePath -Name ScheduledInstallDay -Value $ScheduledInstallDay -PropertyType DWORD -Force | Out-Null
 New-ItemProperty -Path $RegistryBasePath -Name ScheduledInstallTime -Value "5" -PropertyType DWORD -Force | Out-Null
 if($NoAuto) {
  New-ItemProperty -Path $RegistryBasePath -Name AutoInstallMinorUpdates -Value "0" -PropertyType DWORD -Force | Out-Null
 } else {
  New-ItemProperty -Path $RegistryBasePath -Name AutoInstallMinorUpdates -Value "1" -PropertyType DWORD -Force | Out-Null
 }
 if($Pilot) {
  New-ItemProperty -Path $RegistryBasePath -Name NoAUShutdownOption -Value "0" -PropertyType DWORD -Force | Out-Null
 } else {
  New-ItemProperty -Path $RegistryBasePath -Name NoAUShutdownOption -Value "1" -PropertyType DWORD -Force | Out-Null
 }
 New-ItemProperty -Path $RegistryBasePath -Name UseWUServer -Value "1" -PropertyType DWORD -Force | Out-Null
 New-ItemProperty -Path $RegistryBasePath -Name RescheduleWaitTimeEnabled -Value "1" -PropertyType DWORD -Force | Out-Null
 New-ItemProperty -Path $RegistryBasePath -Name RescheduleWaitTime -Value "10" -PropertyType DWORD -Force | Out-Null
 New-ItemProperty -Path $RegistryBasePath -Name RebootRelaunchTimeoutEnabled -Value "1" -PropertyType DWORD -Force | Out-Null
 New-ItemProperty -Path $RegistryBasePath -Name RebootRelaunchTimeout -Value "240" -PropertyType DWORD -Force | Out-Null
}

function Import-WindowsUpdate {
# Check if NuGet is installed for PSWindowsUpdate Module
if(!(Get-PackageProvider -Name NuGet)) {
    Install-PackageProvider -Name NuGet -Force
}

# Check if Windows Update module is installed, if not install it
if(!(Get-Module -Name PSWindowsUpdate)) {
    if($PSVersionTable.PSVersion.Major -eq 5) {
        Install-Module -Name PSWindowsUpdate -Scope CurrentUser
    }
}

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