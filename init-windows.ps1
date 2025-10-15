#
# Bootstrap Client Initialization Script for Windows
#
# @author: Ovestokke
# @version: 1.0
#
# This script automates the initial setup:
# 1. Installs Git via winget
# 2. Clones the bootstrap-client repository
# 3. Launches the main Setup-Windows.ps1 script
#
# Usage:
#   irm https://raw.githubusercontent.com/YOUR-USERNAME/bootstrap-client/master/Init-Windows.ps1 | iex
#   OR save this file and run: .\Init-Windows.ps1
#

#region Setup

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Bootstrap Client Initialization" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this script again." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Running as Administrator" -ForegroundColor Green
Write-Host ""

# Set execution policy
try {
    Set-ExecutionPolicy Unrestricted -Force -ErrorAction Stop
    Write-Host "[OK] Execution policy set to Unrestricted" -ForegroundColor Green
}
catch {
    Write-Host "[FAIL] Failed to set execution policy: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

#endregion

#region Install Git

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Git Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Git is already installed
if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitVersion = git --version
    Write-Host "[OK] Git is already installed: $gitVersion" -ForegroundColor Green
}
else {
    Write-Host "Git is not installed. Installing via winget..." -ForegroundColor Yellow
    
    try {
        $process = Start-Process -FilePath "winget" `
            -ArgumentList "install --id Git.Git -e --accept-package-agreements --accept-source-agreements" `
            -NoNewWindow -PassThru -Wait
        
        if ($process.ExitCode -eq 0) {
            Write-Host "[OK] Git installed successfully" -ForegroundColor Green
            
            # Refresh PATH to include Git
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            # Verify installation
            if (Get-Command git -ErrorAction SilentlyContinue) {
                $gitVersion = git --version
                Write-Host "[OK] Git verified: $gitVersion" -ForegroundColor Green
            }
            else {
                Write-Host "[FAIL] Git installed but not found in PATH. Please restart PowerShell and run this script again." -ForegroundColor Red
                exit 1
            }
        }
        else {
            Write-Host "[FAIL] Git installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
            exit 1
        }
    }
    catch {
        Write-Host "[FAIL] Error installing Git: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""

#endregion

#region Clone Repository

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Repository Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Ask for clone location
$defaultLocation = "C:\bootstrap-client"
$cloneLocation = Read-Host "Where should the repository be cloned? (default: $defaultLocation)"

if ([string]::IsNullOrWhiteSpace($cloneLocation)) {
    $cloneLocation = $defaultLocation
}

Write-Host "Clone location: $cloneLocation" -ForegroundColor Cyan

# Check if directory already exists
if (Test-Path $cloneLocation) {
    Write-Host "[SKIP] Directory already exists: $cloneLocation" -ForegroundColor Yellow
    
    # Check if it's a git repository
    if (Test-Path (Join-Path $cloneLocation ".git")) {
        Write-Host "[OK] Directory is a git repository" -ForegroundColor Green
        
        # Ask if user wants to update
        $update = Read-Host "Update repository? (Y/N)"
        if ($update -eq "Y" -or $update -eq "y") {
            Write-Host "Updating repository..." -ForegroundColor Yellow
            Push-Location $cloneLocation
            git pull
            Pop-Location
            Write-Host "[OK] Repository updated" -ForegroundColor Green
        }
    }
    else {
        Write-Host "[FAIL] Directory exists but is not a git repository" -ForegroundColor Red
        Write-Host "Please remove the directory or choose a different location" -ForegroundColor Yellow
        exit 1
    }
}
else {
    Write-Host ""
    Write-Host "Repository URL options:" -ForegroundColor Yellow
    Write-Host "  [1] HTTPS (default): https://github.com/ovestokke/bootstrap-client.git" -ForegroundColor White
    Write-Host "  [2] SSH: git@github.com:ovestokke/bootstrap-client.git" -ForegroundColor White
    Write-Host "  [3] Custom URL (your fork or private repo)" -ForegroundColor White
    Write-Host ""
    
    $urlChoice = Read-Host "Choose clone method (1, 2, or 3, default: 1)"
    
    if ([string]::IsNullOrWhiteSpace($urlChoice)) {
        $urlChoice = "1"
    }
    
    switch ($urlChoice) {
        "1" {
            $repoUrl = "https://github.com/ovestokke/bootstrap-client.git"
        }
        "2" {
            $repoUrl = "git@github.com:ovestokke/bootstrap-client.git"
        }
        "3" {
            $repoUrl = Read-Host "Enter repository URL"
        }
        default {
            Write-Host "[FAIL] Invalid choice" -ForegroundColor Red
            exit 1
        }
    }
    
    Write-Host ""
    Write-Host "Cloning repository from: $repoUrl" -ForegroundColor Cyan
    Write-Host "To: $cloneLocation" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        git clone $repoUrl $cloneLocation
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Repository cloned successfully" -ForegroundColor Green
        }
        else {
            Write-Host "[FAIL] Git clone failed with exit code: $LASTEXITCODE" -ForegroundColor Red
            exit 1
        }
    }
    catch {
        Write-Host "[FAIL] Error cloning repository: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""

#endregion

#region Launch Setup Script

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Launch Main Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$setupScript = Join-Path $cloneLocation "windows\Setup-Windows.ps1"

if (-not (Test-Path $setupScript)) {
    Write-Host "[FAIL] Setup script not found: $setupScript" -ForegroundColor Red
    exit 1
}

Write-Host "Setup script found: $setupScript" -ForegroundColor Green
Write-Host ""

$launch = Read-Host "Launch Setup-Windows.ps1 now? (Y/N)"

if ($launch -eq "Y" -or $launch -eq "y") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Launching Setup-Windows.ps1" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    Push-Location (Join-Path $cloneLocation "windows")
    & $setupScript
    Pop-Location
}
else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "Setup script not launched" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To continue setup manually, run:" -ForegroundColor Cyan
    Write-Host "  cd $cloneLocation\windows" -ForegroundColor White
    Write-Host "  .\Setup-Windows.ps1" -ForegroundColor White
    Write-Host ""
}

#endregion
