. .\GlobalVariables.ps1
Function Create-StartupTask {
 if(!(Get-ScheduledTask -TaskName "Baseline Setup" -ErrorAction SilentlyContinue)) {
  $ScheduleAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument ' -NoProfile -WindowStyle Hidden -file C:\temp\BaselineSetup\Install-Baseline.ps1'
  $ScheduleTrigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay (New-TimeSpan -minutes 3)
  Register-ScheduledTask -Action $ScheduleAction -Trigger $ScheduleTrigger -TaskName "Baseline Setup" -Description "Installing Baseline setup for host" -User "System"
  Write-Verbose "Registering Scheduled Task `"Baseline Setup`""
 }
}

Function Remove-StartupTask {
 if(Get-ScheduledTask -TaskName "Baseline Setup" -ErrorAction SilentlyContinue) {
  Unregister-ScheduledTask -TaskName "Baseline Setup" -Confirm:$false
 }
}

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
 Restart-Computer -Force
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
    Import-PackageProvider NuGet -Force
}

# Apparentely PSWindowsUpdate module comes from the PSGallery and needs to be trusted
# See https://msdn.microsoft.com/en-us/powershell/gallery/psgallery/psgallery_gettingstarted
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Check if Windows Update module is installed, if not install it
if(!(Get-Module -Name PSWindowsUpdate)) {
 Install-Module -Name PSWindowsUpdate -Scope CurrentUser
}

# Add WSUS as Service Manager
Add-WUServiceManager -ServiceID 3da21691-e39d-4da6-8a4b-b43877bcb1b7

}

Check-RestartStatus {
 $objSystemInfo = New-Object -ComObject "Microsoft.Update.SystemInfo"
 If($objSystemInfo.RebootRequired) {
  Write-Verbose "Reboot is required to continue, Restarting."
  Restart-Computer -Force
 }
}
Function List-BaselineService {
 $Title = "Baseline Services"
 $Message = "Which Baseline Service would you like today?"
 for ($i = 0; $i -lt $global:BLServices.Count; $i++) {
  "$i. " + $global:BLServices[$i].Name
 }
 $global:Choice = Read-Host "Please select service to install Baseline"
}

Function Install-BaselineService {
 param(
  #[parameter(Mandatory=$true)] $InstallService,
  #[parameter] $BaselineServices
 )
Write-Host $global:BLServices[$global:choice].FeatureName
}