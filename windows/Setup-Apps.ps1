#
# Windows Application Installation Script
#
# @author: Ovestokke
# @version: 1.0
#
# Installs applications via winget using categorized app lists
# Does NOT configure tools - use Setup-Packages.ps1 for development tools
# Does NOT copy configs - chezmoi manages all configurations
#

#region Setup

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows Application Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this script again." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Running as Administrator" -ForegroundColor Green
Write-Host ""

$logFile = Join-Path $PSScriptRoot "Setup-Apps-Log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').log"
Start-Transcript -Path $logFile
Write-Host "Logging to: $logFile" -ForegroundColor Gray
Write-Host ""

Set-ExecutionPolicy Unrestricted -Force -ErrorAction SilentlyContinue

#endregion

#region Install Applications

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Application Installation Options" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Choose installation mode:" -ForegroundColor Yellow
Write-Host "  [1] Skip       - No apps (exit script)" -ForegroundColor White
Write-Host "  [2] Basic      - Essential apps only (~10 apps)" -ForegroundColor White
Write-Host "  [3] Gaming     - Basic + Gaming platforms + peripherals + monitoring" -ForegroundColor White
Write-Host "  [4] Developer  - Basic + Development tools" -ForegroundColor White
Write-Host "  [5] Full       - Everything (Basic + Gaming + Developer + Productivity)" -ForegroundColor White
Write-Host ""

do {
    $installChoice = Read-Host "Enter your choice (1-5)"
} while ($installChoice -notmatch '^[12345]$')

if ($installChoice -eq "1") {
    Write-Host ""
    Write-Host "[SKIP] Skipping application installation" -ForegroundColor Yellow
    Write-Host ""
    Stop-Transcript
    exit 0
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installing Applications via winget..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Determine which apps lists to use
$appsListFiles = @()

switch ($installChoice) {
    "2" {
        Write-Host "Mode: BASIC installation" -ForegroundColor Green
        $appsListFiles += Join-Path $PSScriptRoot "Apps-List-Basic.txt"
    }
    "3" {
        Write-Host "Mode: GAMING installation" -ForegroundColor Green
        $appsListFiles += Join-Path $PSScriptRoot "Apps-List-Basic.txt"
        $appsListFiles += Join-Path $PSScriptRoot "Apps-List-Gaming.txt"
    }
    "4" {
        Write-Host "Mode: DEVELOPER installation" -ForegroundColor Green
        $appsListFiles += Join-Path $PSScriptRoot "Apps-List-Basic.txt"
        $appsListFiles += Join-Path $PSScriptRoot "Apps-List-Developer.txt"
    }
    "5" {
        Write-Host "Mode: FULL installation (all categories)" -ForegroundColor Green
        $appsListFiles += Join-Path $PSScriptRoot "Apps-List-Basic.txt"
        $appsListFiles += Join-Path $PSScriptRoot "Apps-List-Gaming.txt"
        $appsListFiles += Join-Path $PSScriptRoot "Apps-List-Developer.txt"
        $appsListFiles += Join-Path $PSScriptRoot "Apps-List-Productivity.txt"
    }
}

# NOTE: You can find the exact ID of an application by running 'winget search "Application Name"' on your Windows machine.
# Using the exact ID is more reliable.

# Verify all app list files exist
foreach ($file in $appsListFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "[FAIL] Apps list not found at: $file" -ForegroundColor Red
        Write-Host "Please ensure all app list files exist in the same directory as this script." -ForegroundColor Yellow
        Stop-Transcript
        exit 1
    }
}

Write-Host "Loading applications from:" -ForegroundColor Cyan
foreach ($file in $appsListFiles) {
    Write-Host "  • $(Split-Path -Leaf $file)" -ForegroundColor White
}
Write-Host ""

# Read and parse all app list files (skip comments and empty lines, remove duplicates)
$appsToInstall = @()
foreach ($file in $appsListFiles) {
    $apps = Get-Content $file |
        Where-Object { $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' } |
        ForEach-Object { $_.Trim() }
    $appsToInstall += $apps
}

# Remove duplicates while preserving order
$appsToInstall = $appsToInstall | Select-Object -Unique

Write-Host "Found $($appsToInstall.Count) unique applications to install" -ForegroundColor Green
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

Stop-Transcript
