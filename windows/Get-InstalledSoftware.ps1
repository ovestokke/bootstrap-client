#
# Get Installed Software Script
#
# @author: Ovestokke
# @version: 1.0
#

#region Setup

# Set execution policy
#Set-ExecutionPolicy Unrestricted -Force

#endregion

#region Get Installed Software

Write-Host "Gathering installed software information..."

# Get software from winget (JSON format for better parsing)
Write-Host "  - Querying winget..."
$wingetOutput = winget list --disable-interactivity | Out-String

# Parse winget output to get clean data
$wingetApps = @()
$wingetLines = $wingetOutput -split "`n"
$headerProcessed = $false
foreach ($line in $wingetLines) {
    if ($line -match '^Name\s+Id\s+Version') {
        $headerProcessed = $true
        continue
    }
    if ($headerProcessed -and $line.Trim() -ne "" -and $line -notmatch '^-+') {
        # Parse the line to extract app info
        if ($line -match '^\s*(.+?)\s{2,}([^\s]+)\s+([^\s]+)(?:\s+([^\s]+))?(?:\s+(.+))?$') {
            $wingetApps += [PSCustomObject]@{
                Name    = $matches[1].Trim()
                Id      = $matches[2].Trim()
                Version = $matches[3].Trim()
                Source  = "winget"
            }
        }
    }
}

# Get software from registry (both 64-bit and 32-bit paths)
Write-Host "  - Querying registry..."
$registryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$registryApps = @()
foreach ($path in $registryPaths) {
    Get-ItemProperty $path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |
        ForEach-Object {
            $registryApps += [PSCustomObject]@{
                Name        = $_.DisplayName
                Version     = $_.DisplayVersion
                Publisher   = $_.Publisher
                InstallDate = $_.InstallDate
                Source      = "registry"
            }
        }
}

# Deduplicate and combine
Write-Host "  - Processing and deduplicating..."
$allApps = @()

# Add winget apps
$allApps += $wingetApps

# Add registry apps that aren't already in winget list
foreach ($regApp in $registryApps) {
    $duplicate = $false
    foreach ($winApp in $wingetApps) {
        if ($regApp.Name -eq $winApp.Name) {
            $duplicate = $true
            break
        }
    }
    if (-not $duplicate) {
        $allApps += [PSCustomObject]@{
            Name    = $regApp.Name
            Id      = "N/A"
            Version = $regApp.Version
            Source  = $regApp.Source
        }
    }
}

# Sort and format output
$allApps = $allApps | Sort-Object Name | Where-Object { $_.Name -ne $null }

# Create formatted output
$output = @()
$output += "=" * 120
$output += "INSTALLED SOFTWARE INVENTORY"
$output += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$output += "Total Applications: $($allApps.Count)"
$output += "=" * 120
$output += ""
$output += "WINGET-MANAGED APPLICATIONS ($($wingetApps.Count)):"
$output += "-" * 120
$output += $wingetApps | Format-Table -Property Name, Id, Version -AutoSize | Out-String
$output += ""
$output += "REGISTRY-ONLY APPLICATIONS ($(($allApps | Where-Object { $_.Source -eq 'registry' }).Count)):"
$output += "-" * 120
$output += ($allApps | Where-Object { $_.Source -eq 'registry' }) | Format-Table -Property Name, Version -AutoSize | Out-String
$output += ""
$output += "=" * 120

# Save to file
$output | Out-File -FilePath .\InstalledSoftware.txt -Encoding UTF8

# Also export to CSV for easy analysis
$allApps | Export-Csv -Path .\InstalledSoftware.csv -NoTypeInformation -Encoding UTF8

#endregion

Write-Host ""
Write-Host "Installed software list saved to:"
Write-Host "  - .\InstalledSoftware.txt (formatted report)"
Write-Host "  - .\InstalledSoftware.csv (spreadsheet format)"
Write-Host ""
Write-Host "Summary:"
Write-Host "  Total applications: $($allApps.Count)"
Write-Host "  Winget-managed: $($wingetApps.Count)"
Write-Host "  Registry-only: $(($allApps | Where-Object { $_.Source -eq 'registry' }).Count)"
