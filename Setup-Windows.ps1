#
# Windows 10/11 Setup Script
#
# @author: Ovestokke
# @version: 1.3
#

#region Setup

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this script again."
    exit 1
}

# Start logging
$logFile = Join-Path $PSScriptRoot "Setup-Windows-Log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"
Start-Transcript -Path $logFile
Write-Host "Logging to: $logFile"
Write-Host ""

# Set execution policy
Set-ExecutionPolicy Unrestricted -Force

#endregion

#region Computer Name

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Computer Hostname Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$currentName = $env:COMPUTERNAME
Write-Host "Current hostname: $currentName" -ForegroundColor Yellow
Write-Host ""

$changeName = Read-Host "Would you like to change the computer name? (Y/N)"

if ($changeName -eq "Y" -or $changeName -eq "y") {
    $defaultName = "Ares"
    $newName = Read-Host "Enter new computer name (default: $defaultName)"

    if ([string]::IsNullOrWhiteSpace($newName)) {
        $newName = $defaultName
        Write-Host "Using default name: $newName" -ForegroundColor Cyan
    }

    if ($newName -and $newName -ne $currentName) {
        try {
            Rename-Computer -NewName $newName -Force -ErrorAction Stop
            Write-Host "[OK] Computer name will be changed to '$newName' after reboot" -ForegroundColor Green
            $global:requiresReboot = $true
        }
        catch {
            Write-Host "[FAIL] Failed to change computer name: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "[SKIP] Invalid or same computer name, skipping..." -ForegroundColor Yellow
    }
}
else {
    Write-Host "[SKIP] Keeping current computer name: $currentName" -ForegroundColor Yellow
}

Write-Host ""

#endregion

#region Drivers

# Drivers for GIGABYTE B850 AORUS ELITE WIFI7 ICE
# Download and install the latest drivers from the official support page:
# https://www.gigabyte.com/Motherboard/B850-AORUS-ELITE-WIFI7-ICE-rev-1x/support

#endregion

#region Remove Bloatware

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Removing Bloatware..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# List of bloatware to remove
$bloatware = @(
    "Microsoft.549981C3F5F10", # Cortana
    "Microsoft.MicrosoftOfficeHub", # Office Hub
    "Microsoft.WindowsFeedbackHub", # Feedback Hub
    "Microsoft.GetHelp", # Get Help
    "Microsoft.Getstarted", # Get Started
    "Microsoft.People", # People
    "Microsoft.WindowsCamera", # Camera
    "Microsoft.WindowsMaps", # Maps
    "Microsoft.ZuneMusic", # Groove Music
    "Microsoft.ZuneVideo", # Movies & TV
    "Microsoft.MicrosoftSolitaireCollection", # Solitaire Collection
    "Microsoft.MixedReality.Portal", # Mixed Reality Portal
    "Microsoft.SkypeApp" # Skype
)

# Remove bloatware
foreach ($app in $bloatware) {
    Write-Host "Attempting to remove: $app" -ForegroundColor Yellow
    $package = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
    if ($package) {
        try {
            Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
            Write-Host "  [OK] Successfully removed $app" -ForegroundColor Green
        }
        catch {
            Write-Host "  [FAIL] Failed to remove $app" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  - Not installed: $app" -ForegroundColor Gray
    }
}

Write-Host ""

#endregion

#region Privacy

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuring Privacy Settings..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Function to safely set registry value
function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord"
    )

    try {
        # Create the key if it doesn't exist
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }

        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop
        Write-Host "  [OK] Set $Name in $Path" -ForegroundColor Green
    }
    catch {
        Write-Host "  [FAIL] Failed to set $Name in $Path - $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Disable telemetry
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0

# Disable web search in Start Menu
Set-RegistryValue -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1

# Disable Cortana
Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0

Write-Host ""

#endregion

#region UI/UX

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuring UI/UX Settings..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Show file extensions
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

# Show hidden files
Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1

Write-Host ""

#endregion

#region Developer

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Enabling Developer Mode..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Enable Developer Mode
Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Value 1

Write-Host ""

#endregion

#region WSL

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installing WSL..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Check if WSL is already installed
$wslInstalled = $false
try {
    $wslCheck = wsl --list 2>&1
    if ($LASTEXITCODE -eq 0) {
        $wslInstalled = $true
        Write-Host "WSL is already installed." -ForegroundColor Green

        # Check if Ubuntu is installed
        if ($wslCheck -match "Ubuntu") {
            Write-Host "Ubuntu distribution is already installed." -ForegroundColor Green
        }
        else {
            Write-Host "Installing Ubuntu distribution..." -ForegroundColor Yellow
            wsl --install -d Ubuntu --no-launch
        }
    }
}
catch {
    $wslInstalled = $false
}

if (-not $wslInstalled) {
    Write-Host "Installing WSL and Ubuntu (without launching)..." -ForegroundColor Yellow
    wsl --install -d Ubuntu --no-launch

    Write-Host ""
    Write-Host "IMPORTANT: WSL installation requires a system reboot!" -ForegroundColor Yellow
    Write-Host "After reboot, run this script again to continue with application installation." -ForegroundColor Yellow
    Write-Host ""

    $reboot = Read-Host "Would you like to reboot now? (Y/N)"
    if ($reboot -eq "Y" -or $reboot -eq "y") {
        Write-Host "Rebooting in 10 seconds..." -ForegroundColor Red
        Start-Sleep -Seconds 10
        Restart-Computer -Force
        exit
    }
    else {
        Write-Host ""
        Write-Host "Please reboot manually and run this script again." -ForegroundColor Yellow
        Stop-Transcript
        exit
    }
}

Write-Host ""
Write-Host "After completing this script, configure WSL by running:" -ForegroundColor Cyan
Write-Host "  1. wsl -d Ubuntu"
Write-Host "  2. cd /mnt/e/Github/FreshWindowsInstall  (or your path)"
Write-Host "  3. bash Setup-WSL.sh"
Write-Host ""

#endregion

#region Install Applications

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installing Applications via winget..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Load applications list from file
# NOTE: You can find the exact ID of an application by running 'winget search "Application Name"' on your Windows machine.
# Using the exact ID is more reliable.
$appsListFile = Join-Path $PSScriptRoot "Apps-List.txt"

if (-not (Test-Path $appsListFile)) {
    Write-Host "[FAIL] Apps-List.txt not found at: $appsListFile" -ForegroundColor Red
    Write-Host "Please ensure Apps-List.txt exists in the same directory as this script." -ForegroundColor Yellow
    Stop-Transcript
    exit 1
}

Write-Host "Loading applications list from: $appsListFile" -ForegroundColor Cyan

# Read and parse the apps list file (skip comments and empty lines)
$appsToInstall = Get-Content $appsListFile |
    Where-Object { $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' } |
    ForEach-Object { $_.Trim() }

Write-Host "Found $($appsToInstall.Count) applications to install" -ForegroundColor Green
Write-Host ""

# Install applications
$total = $appsToInstall.Count
$current = 0
$failed = @()

foreach ($app in $appsToInstall) {
    $current++
    $startTime = Get-Date
    Write-Host ""
    Write-Host "========================================" -ForegroundColor DarkGray
    Write-Host "[$current/$total] Installing: $app" -ForegroundColor Cyan
    Write-Host "Time: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray

    try {
        # Start installation with real-time output
        Write-Host "  Running winget install..." -ForegroundColor Yellow

        $process = Start-Process -FilePath "winget" `
            -ArgumentList "install --id $app -e --accept-package-agreements --accept-source-agreements" `
            -NoNewWindow -PassThru -Wait

        $duration = ((Get-Date) - $startTime).TotalSeconds

        if ($process.ExitCode -eq 0) {
            Write-Host "  [OK] Successfully installed $app" -ForegroundColor Green
            Write-Host "  Duration: $([math]::Round($duration, 1))s" -ForegroundColor Gray
        }
        elseif ($process.ExitCode -eq -1978335189) {
            Write-Host "  [SKIP] Already installed: $app" -ForegroundColor Yellow
            Write-Host "  Duration: $([math]::Round($duration, 1))s" -ForegroundColor Gray
        }
        else {
            Write-Host "  [FAIL] Failed to install $app (Exit code: $($process.ExitCode))" -ForegroundColor Red
            Write-Host "  Duration: $([math]::Round($duration, 1))s" -ForegroundColor Gray
            $failed += $app
        }
    }
    catch {
        $duration = ((Get-Date) - $startTime).TotalSeconds
        Write-Host "  [FAIL] Error installing $app - $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Duration: $([math]::Round($duration, 1))s" -ForegroundColor Gray
        $failed += $app
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total apps: $total" -ForegroundColor White
Write-Host "Successful: $($total - $failed.Count)" -ForegroundColor Green
Write-Host "Failed: $($failed.Count)" -ForegroundColor Red

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "Failed installations:" -ForegroundColor Red
    foreach ($app in $failed) {
        Write-Host "  - $app" -ForegroundColor Red
    }
}

Write-Host ""

#endregion

#region Manual Installations

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NVIDIA App Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NVIDIA App is not available on winget." -ForegroundColor Yellow
Write-Host "Attempting to download and install the latest version..." -ForegroundColor Yellow
Write-Host ""

try {
    # Scrape the latest download URL from NVIDIA's website
    Write-Host "Fetching latest NVIDIA App version..." -ForegroundColor Cyan
    $nvidiaPage = Invoke-WebRequest -Uri "https://www.nvidia.com/en-us/software/nvidia-app/" -UseBasicParsing -ErrorAction Stop
    $downloadUrl = ($nvidiaPage.Content | Select-String -Pattern 'https://[^"]*NVIDIA_app[^"]*\.exe' -AllMatches).Matches[0].Value

    if ($downloadUrl) {
        Write-Host "Found download URL: $downloadUrl" -ForegroundColor Green

        # Extract version from URL
        if ($downloadUrl -match 'v?([\d\.]+)') {
            $version = $Matches[1]
        }
        else {
            $version = "unknown"
        }
        Write-Host "Version: $version" -ForegroundColor Green

        # Download the installer
        $installerPath = Join-Path $env:TEMP "NVIDIA_app_installer.exe"
        Write-Host "Downloading NVIDIA App to: $installerPath" -ForegroundColor Cyan

        Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -ErrorAction Stop
        Write-Host "[OK] Download completed" -ForegroundColor Green

        # Install NVIDIA App
        Write-Host "Installing NVIDIA App (this may take a few minutes)..." -ForegroundColor Cyan
        $installProcess = Start-Process -FilePath $installerPath -ArgumentList "/s" -Wait -PassThru -ErrorAction Stop

        if ($installProcess.ExitCode -eq 0) {
            Write-Host "[OK] NVIDIA App installed successfully" -ForegroundColor Green
        }
        else {
            Write-Host "[FAIL] Installation failed with exit code: $($installProcess.ExitCode)" -ForegroundColor Red
        }

        # Clean up installer
        Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
    }
    else {
        Write-Host "[FAIL] Could not find download URL" -ForegroundColor Red
        Write-Host "Please download manually from: https://www.nvidia.com/en-us/software/nvidia-app/" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "[FAIL] Error downloading/installing NVIDIA App: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please download manually from: https://www.nvidia.com/en-us/software/nvidia-app/" -ForegroundColor Yellow
}

Write-Host ""

#endregion

#region Additional Setup Scripts

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Additional Setup Available" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Additional setup scripts available:" -ForegroundColor Yellow
Write-Host "  - Setup-WezTerm.ps1: Configure WezTerm with Nerd Fonts" -ForegroundColor White
Write-Host "  - Setup-WSL.sh: Configure WSL Ubuntu with Zsh and Oh My Zsh" -ForegroundColor White
Write-Host ""

#endregion

Write-Host "========================================" -ForegroundColor Green
Write-Host "Windows setup script finished!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Log file saved to: $logFile" -ForegroundColor Cyan
Write-Host ""

Stop-Transcript
