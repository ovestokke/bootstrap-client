#
# Windows Essentials Setup Script
#
# @author: Ovestokke
# @version: 1.0
#
# Installs foundational tools: winget, Git, chezmoi
# Does NOT install applications or configure system settings
# Does NOT copy any config files - chezmoi manages all configs
#

#region Setup

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows Essentials Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this script again." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Running as Administrator" -ForegroundColor Green
Write-Host ""

$logFile = Join-Path $PSScriptRoot "Setup-Essentials-Log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').log"
Start-Transcript -Path $logFile
Write-Host "Logging to: $logFile" -ForegroundColor Gray
Write-Host ""

Set-ExecutionPolicy Unrestricted -Force -ErrorAction SilentlyContinue

#endregion

#region Helper Functions

function Write-Success { param([string]$Message); Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Fail { param([string]$Message); Write-Host "[FAIL] $Message" -ForegroundColor Red }
function Write-Skip { param([string]$Message); Write-Host "[SKIP] $Message" -ForegroundColor Yellow }
function Write-Info { param([string]$Message); Write-Host "→ $Message" -ForegroundColor Cyan }

#endregion

#region Verify winget

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Verify winget" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (Get-Command winget -ErrorAction SilentlyContinue) {
    $wingetVersion = winget --version
    Write-Success "winget is installed: $wingetVersion"
} else {
    Write-Fail "winget is not installed or not in PATH"
    Write-Host ""
    Write-Host "winget should be pre-installed on Windows 11." -ForegroundColor Yellow
    Write-Host "If missing, install from: https://aka.ms/getwinget" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host ""

#endregion

#region Install Git

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Git Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitVersion = git --version
    Write-Success "Git is already installed: $gitVersion"
} else {
    Write-Info "Installing Git via winget..."
    
    try {
        $process = Start-Process -FilePath "winget" `
            -ArgumentList "install --id Git.Git -e --accept-package-agreements --accept-source-agreements" `
            -NoNewWindow -PassThru -Wait
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq -1978335189) {
            Write-Success "Git installed successfully"
            
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            if (Get-Command git -ErrorAction SilentlyContinue) {
                $gitVersion = git --version
                Write-Success "Git verified: $gitVersion"
            } else {
                Write-Fail "Git installed but not found in PATH. Restart PowerShell and try again."
                exit 1
            }
        } else {
            Write-Fail "Git installation failed with exit code: $($process.ExitCode)"
            exit 1
        }
    } catch {
        Write-Fail "Error installing Git: $($_.Exception.Message)"
        exit 1
    }
}

Write-Host ""

#endregion

#region Install chezmoi

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "chezmoi Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
    $chezmoiVersion = chezmoi --version
    Write-Success "chezmoi is already installed: $chezmoiVersion"
} else {
    Write-Info "Installing chezmoi via winget..."
    
    try {
        $process = Start-Process -FilePath "winget" `
            -ArgumentList "install --id twpayne.chezmoi -e --accept-package-agreements --accept-source-agreements" `
            -NoNewWindow -PassThru -Wait
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq -1978335189) {
            Write-Success "chezmoi installed successfully"
            
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
                $chezmoiVersion = chezmoi --version
                Write-Success "chezmoi verified: $chezmoiVersion"
            } else {
                Write-Fail "chezmoi installed but not found in PATH. Restart PowerShell and try again."
                exit 1
            }
        } else {
            Write-Fail "chezmoi installation failed with exit code: $($process.ExitCode)"
            exit 1
        }
    } catch {
        Write-Fail "Error installing chezmoi: $($_.Exception.Message)"
        exit 1
    }
}

Write-Host ""

#endregion

#region Initialize chezmoi

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "chezmoi Initialization" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$chezmoiSourceDir = "$env:USERPROFILE\.local\share\chezmoi"

if (Test-Path $chezmoiSourceDir) {
    Write-Info "chezmoi is already initialized at: $chezmoiSourceDir"
    
    Push-Location $chezmoiSourceDir
    $remoteUrl = git remote get-url origin 2>$null
    Pop-Location
    
    if ($remoteUrl) {
        Write-Info "Current dotfiles repository: $remoteUrl"
    }
    
    Write-Host ""
    $reinit = Read-Host "Re-initialize with a different repository? (y/N)"
    
    if ($reinit -eq "y" -or $reinit -eq "Y") {
        Write-Info "Backing up existing chezmoi directory..."
        $backupDir = "$env:USERPROFILE\.local\share\chezmoi.backup-$(Get-Date -Format 'yyyy-MM-dd-HHmmss')"
        Move-Item -Path $chezmoiSourceDir -Destination $backupDir -Force
        Write-Success "Backup created: $backupDir"
    } else {
        Write-Skip "Keeping existing chezmoi initialization"
        Write-Host ""
        Write-Info "To update your dotfiles, run: chezmoi update"
        Write-Host ""
        Stop-Transcript
        exit 0
    }
}

Write-Host ""
Write-Host "Initialize chezmoi with your dotfiles repository" -ForegroundColor Yellow
Write-Host ""
Write-Host "Examples:" -ForegroundColor Cyan
Write-Host "  • https://github.com/ovestokke/dotfiles.git" -ForegroundColor Gray
Write-Host "  • git@github.com:username/dotfiles.git" -ForegroundColor Gray
Write-Host ""
Write-Host "Leave empty to skip initialization (you can do it later)" -ForegroundColor Gray
Write-Host ""

$dotfilesRepo = Read-Host "Enter your dotfiles repository URL (or press Enter to skip)"

if ([string]::IsNullOrWhiteSpace($dotfilesRepo)) {
    Write-Skip "Skipping chezmoi initialization"
    Write-Host ""
    Write-Info "To initialize later, run:"
    Write-Host "  chezmoi init --apply https://github.com/username/dotfiles.git" -ForegroundColor White
    Write-Host ""
} else {
    Write-Info "Initializing chezmoi with: $dotfilesRepo"
    Write-Host ""
    
    $apply = Read-Host "Apply dotfiles immediately after init? (Y/n)"
    
    if ($apply -eq "n" -or $apply -eq "N") {
        Write-Info "Running: chezmoi init $dotfilesRepo"
        chezmoi init $dotfilesRepo
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "chezmoi initialized successfully"
            Write-Info "To apply your dotfiles, run: chezmoi apply"
        } else {
            Write-Fail "chezmoi init failed with exit code: $LASTEXITCODE"
        }
    } else {
        Write-Info "Running: chezmoi init --apply $dotfilesRepo"
        chezmoi init --apply $dotfilesRepo
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "chezmoi initialized and dotfiles applied successfully"
        } else {
            Write-Fail "chezmoi init --apply failed with exit code: $LASTEXITCODE"
        }
    }
}

Write-Host ""

#endregion

#region Summary

Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup Essentials Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Installed:" -ForegroundColor Cyan
if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitVer = git --version
    Write-Host "  ✓ Git: $gitVer" -ForegroundColor Green
}
if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
    $chezmoiVer = chezmoi --version | Select-Object -First 1
    Write-Host "  ✓ chezmoi: $chezmoiVer" -ForegroundColor Green
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Run Setup-System.ps1     → System configuration & apps" -ForegroundColor White
Write-Host "  2. Run Setup-Packages.ps1   → Development tools (WezTerm, Neovim, etc.)" -ForegroundColor White
Write-Host "  3. Run chezmoi apply        → Apply your dotfiles" -ForegroundColor White
Write-Host ""
Write-Host "Or run the automated workflow from init-windows.ps1" -ForegroundColor Gray
Write-Host ""

Stop-Transcript

#endregion
