#
# Get Installed Software Script
#
# @author: Ovestokke
# @version: 1.0
#

#region Setup

# Set execution policy
Set-ExecutionPolicy Unrestricted -Force

#endregion

#region Get Installed Software

# Get software from winget
$wingetApps = winget list | Out-String

# Get software from registry
$registryApps = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table | Out-String

# Combine the lists
$allApps = $wingetApps + "`n" + $registryApps

# Save to file
$allApps | Out-File -FilePath .\InstalledSoftware.txt

#endregion

Write-Host "Installed software list saved to .\InstalledSoftware.txt"
