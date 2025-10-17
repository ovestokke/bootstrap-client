#
# Komorebi Tiling Window Manager Setup Script
#
# @author: Ovestokke
# @version: 1.0
#
# This script installs and configures Komorebi, a tiling window manager for Windows
# Usage: Run as Administrator in PowerShell

#region Setup

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this script again."
    exit 1
}

$logFile = Join-Path $PSScriptRoot "Setup-Komorebi-Log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').log"
Start-Transcript -Path $logFile
Write-Host "Logging to: $logFile" -ForegroundColor Gray
Write-Host ""

Set-ExecutionPolicy Unrestricted -Force -ErrorAction SilentlyContinue

#endregion

#region Helper Functions

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Fail {
    param([string]$Message)
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Write-Skip {
    param([string]$Message)
    Write-Host "[SKIP] $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "→ $Message" -ForegroundColor Cyan
}

#endregion

#region Banner

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Komorebi Tiling Window Manager Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will install:" -ForegroundColor Yellow
Write-Host "  • Komorebi - Tiling window manager for Windows" -ForegroundColor Gray
Write-Host "  • whkd - Windows Hotkey Daemon" -ForegroundColor Gray
Write-Host "  • Default configuration files" -ForegroundColor Gray
Write-Host ""

$continue = Read-Host "Continue with installation? (Y/N)"
if ($continue -ne "Y" -and $continue -ne "y") {
    Write-Skip "Installation cancelled by user"
    Stop-Transcript
    exit 0
}

Write-Host ""

#endregion

#region Check Prerequisites

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Checking Prerequisites" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    $wingetVersion = winget --version
    Write-Success "winget is installed: $wingetVersion"
}
catch {
    Write-Fail "winget is not installed or not in PATH"
    Write-Info "Please install winget from: https://aka.ms/getwinget"
    Stop-Transcript
    exit 1
}

Write-Host ""

#endregion

#region Install Komorebi

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installing Komorebi" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Info "Installing Komorebi tiling window manager..."
$komorebicCheck = Get-Command komorebic -ErrorAction SilentlyContinue
if ($komorebicCheck) {
    Write-Skip "Komorebi is already installed"
} else {
    try {
        winget install --id LGUG2Z.komorebi -e --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Komorebi installed successfully"
        } elseif ($LASTEXITCODE -eq -1978335189) {
            Write-Skip "Komorebi is already installed"
        } else {
            Write-Fail "Failed to install Komorebi (exit code: $LASTEXITCODE)"
        }
    }
    catch {
        Write-Fail "Error installing Komorebi: $($_.Exception.Message)"
    }
}

Write-Host ""

#endregion

#region Install whkd

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installing whkd (Windows Hotkey Daemon)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Info "Installing whkd hotkey daemon..."
$whkdCheck = Get-Command whkd -ErrorAction SilentlyContinue
if ($whkdCheck) {
    Write-Skip "whkd is already installed"
} else {
    try {
        winget install --id LGUG2Z.whkd -e --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Success "whkd installed successfully"
        } elseif ($LASTEXITCODE -eq -1978335189) {
            Write-Skip "whkd is already installed"
        } else {
            Write-Fail "Failed to install whkd (exit code: $LASTEXITCODE)"
        }
    }
    catch {
        Write-Fail "Error installing whkd: $($_.Exception.Message)"
    }
}

Write-Host ""

#endregion

#region Refresh PATH

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Refreshing Environment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Info "Refreshing PATH environment variable..."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
Write-Success "Environment refreshed"

Write-Host ""

#endregion

#region Generate Configuration

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Generating Configuration Files" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$komorebicPath = Get-Command komorebic -ErrorAction SilentlyContinue
if (-not $komorebicPath) {
    Write-Fail "komorebic command not found. Please close and reopen PowerShell, then run this script again."
    Stop-Transcript
    exit 1
}

Write-Info "Running komorebic quickstart to generate default configurations..."
try {
    $quickstartOutput = komorebic quickstart 2>&1
    Write-Success "Configuration files generated"
    Write-Host ""
    Write-Host $quickstartOutput -ForegroundColor Gray
}
catch {
    Write-Fail "Failed to run quickstart: $($_.Exception.Message)"
}

Write-Host ""

#endregion

#region Configuration Locations

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Configuration File Locations" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$komorebicConfigPath = "$env:USERPROFILE\komorebi.json"
$whkdConfigPath = "$env:USERPROFILE\.config\whkdrc"
$applicationsPath = "$env:USERPROFILE\applications.yaml"

Write-Info "Komorebi configuration: $komorebicConfigPath"
Write-Info "whkd hotkey configuration: $whkdConfigPath"
Write-Info "Application-specific rules: $applicationsPath"

Write-Host ""

#endregion

#region Autostart Configuration

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Autostart Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$autostart = Read-Host "Enable Komorebi autostart on login? (Y/N)"
if ($autostart -eq "Y" -or $autostart -eq "y") {
    try {
        Write-Info "Enabling autostart..."
        komorebic enable-autostart --whkd 2>&1 | Out-Null
        Write-Success "Autostart enabled for Komorebi and whkd"
    }
    catch {
        Write-Fail "Failed to enable autostart: $($_.Exception.Message)"
    }
} else {
    Write-Skip "Autostart not enabled"
    Write-Info "You can enable it later with: komorebic enable-autostart --whkd"
}

Write-Host ""

#endregion

#region Next Steps

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Grant Accessibility Permissions:" -ForegroundColor Cyan
Write-Host "   • Open Settings > Privacy & Security > Accessibility" -ForegroundColor Gray
Write-Host "   • Add and enable 'komorebi.exe' and 'whkd.exe'" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Start Komorebi:" -ForegroundColor Cyan
Write-Host "   komorebic start --whkd" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Stop Komorebi:" -ForegroundColor Cyan
Write-Host "   komorebic stop --whkd" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Customize Configuration:" -ForegroundColor Cyan
Write-Host "   • Edit: $komorebicConfigPath" -ForegroundColor Gray
Write-Host "   • Edit keybindings: $whkdConfigPath" -ForegroundColor Gray
Write-Host ""
Write-Host "5. View Documentation:" -ForegroundColor Cyan
Write-Host "   • https://lgug2z.github.io/komorebi/" -ForegroundColor Gray
Write-Host ""
Write-Host "6. Reload Configuration:" -ForegroundColor Cyan
Write-Host "   komorebic reload-configuration" -ForegroundColor Gray
Write-Host ""
Write-Host "7. Send Games to Specific Workspaces:" -ForegroundColor Cyan
Write-Host "   Add rules to $komorebicConfigPath" -ForegroundColor Gray
Write-Host '   Example: {"initial_workspace_rules": [{"id": "steam.exe", "kind": "Exe", "monitor": 0, "workspace": 8}]}' -ForegroundColor Gray
Write-Host "   Or use CLI: komorebic initial-workspace-rule exe steam.exe 0 8" -ForegroundColor Gray
Write-Host ""

Write-Host "Example Hotkeys (default whkdrc):" -ForegroundColor Yellow
Write-Host "   Alt+Shift+Q         Close window" -ForegroundColor Gray
Write-Host "   Alt+Shift+H/J/K/L   Focus window (vim-style)" -ForegroundColor Gray
Write-Host "   Alt+Shift+1-9       Switch to workspace 1-9" -ForegroundColor Gray
Write-Host "   Alt+Shift+Enter     Promote window to main" -ForegroundColor Gray
Write-Host ""

Write-Host "Logs saved to: $logFile" -ForegroundColor Gray
Write-Host ""

#endregion

Stop-Transcript
