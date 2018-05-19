# Set the PSScript folder location
$PSScriptFolder = "C:\Users\Halli\Desktop\Powershell\Scripts\Powershell"

# Import all the functions
Remove-Module .\Import-Function.psm1
Import-Module .\Import-Function.psm1
. $PSScriptFolder\GlobalVariables.ps1

# Select Available Services
List-BaselineService

# Create scheduled task to start at system boot to ensure the script will keep running
Create-StartupTask

# Script requires Powershell 5, so install it if lower version
if(!($PSVersionTable.PSVersion.Major -eq 5) -and !(((Get-WmiObject win32_operatingsystem).Version) -ge 10)) {
 Install-Powershell
}

# Import the Windows Update commands
Import-WindowsUpdate

# Check if server needs Restart
Check-RestartStatus

# Check for updates
Get-WUInstall –MicrosoftUpdate –AcceptAll -AutoReboot

# Check if server needs Restart
Check-RestartStatus

# Updates are finished, lets start baselining
Install-BaselineService $global:choice $BaselineServices

# Remove the Scheduled task
Remove-StartupTask
