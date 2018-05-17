# Check if Windows Update module is installed
if(!(Get-Module -Name PSWindowsUpdate)) {
    if($PSVersionTable.PSVersion.Major -eq 5) {
        Install-Module -Name PSWindowsUpdate
    }
}

if(!(Get-PackageProvider -Name NuGet)) {
    Install-PackageProvider -Name NuGet -Force
}

Import-Module -Name PSWindowsUpdate