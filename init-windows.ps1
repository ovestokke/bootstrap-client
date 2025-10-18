#
# Bootstrap Client Initialization Script for Windows
#
# @author: Ovestokke
# @version: 2.0
#
# This script automates the initial setup:
# 1. Installs Git via winget
# 2. Clones or updates the bootstrap-client repository
# 3. Presents setup workflow options
#
# Usage:
#   irm https://raw.githubusercontent.com/ovestokke/bootstrap-client/master/init-windows.ps1 | iex
#   OR save this file and run: .\init-windows.ps1
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

# Check if running from inside the repository
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($scriptDir -and (Test-Path (Join-Path $scriptDir ".git"))) {
    Write-Host "✓ Running from repository: $scriptDir" -ForegroundColor Green
    
    # Verify it's the bootstrap-client repository
    Push-Location $scriptDir
    $remote = git remote get-url origin 2>$null
    Pop-Location
    
    if ($remote -like "*bootstrap-client*") {
        Write-Host "✓ Confirmed: bootstrap-client repository" -ForegroundColor Green
        Write-Host ""
        
        $pull = Read-Host "Pull latest changes? (Y/n)"
        if ($pull -ne "n" -and $pull -ne "N") {
            Write-Host ""
            Write-Host "Pulling latest changes..." -ForegroundColor Cyan
            Push-Location $scriptDir
            git pull
            $pullSuccess = $LASTEXITCODE -eq 0
            Pop-Location
            
            if ($pullSuccess) {
                Write-Host "[OK] Repository updated" -ForegroundColor Green
            } else {
                Write-Host "[WARN] Git pull encountered issues" -ForegroundColor Yellow
            }
        } else {
            Write-Host "[SKIP] Using current version" -ForegroundColor Yellow
        }
        
        $cloneLocation = $scriptDir
        Write-Host ""
    } else {
        Write-Host "[WARN] This appears to be a different git repository" -ForegroundColor Yellow
        Write-Host "Remote: $remote" -ForegroundColor Gray
        Write-Host ""
        
        # Fall through to clone logic
        $scriptDir = $null
    }
}

# If not running from repo, ask for clone location
if (-not $scriptDir) {
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
                if ($repoUrl -notmatch '^(https?://|git@)[\w\-\.]+') {
                    Write-Host "[FAIL] Invalid URL format. Must start with https://, http://, or git@" -ForegroundColor Red
                    exit 1
                }
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
}

Write-Host ""

#endregion

#region Setup Workflow Menu

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup Workflow Options" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Available setup scripts:" -ForegroundColor Yellow
Write-Host "  [1] System setup          → Remove bloatware, configure privacy, enable WSL" -ForegroundColor White
Write-Host "  [2] Install apps          → Choose app categories (Basic/Gaming/Developer/Full)" -ForegroundColor White
Write-Host "  [3] Setup essentials      → Install Git + chezmoi, initialize dotfiles" -ForegroundColor White
Write-Host "  [4] Install packages      → Dev tools (WezTerm, Neovim, etc.)" -ForegroundColor White
Write-Host "  [5] Apply dotfiles        → Run chezmoi apply" -ForegroundColor White
Write-Host "  [6] PowerShell profile    → Configure PowerShell (optional)" -ForegroundColor White
Write-Host "  [7] Komorebi WM           → Install tiling window manager (optional)" -ForegroundColor White
Write-Host "  [8] Run full workflow     → Automated setup (1→2→3→4→5)" -ForegroundColor White
Write-Host "  [0] Exit                  → Manual setup" -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "What would you like to do? (0-8)"

switch ($choice) {
    "1" {
        $script = Join-Path $cloneLocation "windows\Setup-System.ps1"
        if (Test-Path $script) {
            Write-Host "" -ForegroundColor Green
            Write-Host "Launching Setup-System.ps1..." -ForegroundColor Green
            Push-Location (Join-Path $cloneLocation "windows")
            & $script
            Pop-Location
        } else {
            Write-Host "[FAIL] Script not found: $script" -ForegroundColor Red
        }
    }
    "2" {
        $script = Join-Path $cloneLocation "windows\Setup-Apps.ps1"
        if (Test-Path $script) {
            Write-Host ""
            Write-Host "Launching Setup-Apps.ps1..." -ForegroundColor Green
            Push-Location (Join-Path $cloneLocation "windows")
            & $script
            Pop-Location
        } else {
            Write-Host "[FAIL] Script not found: $script" -ForegroundColor Red
        }
    }
    "3" {
        $script = Join-Path $cloneLocation "windows\Setup-Essentials.ps1"
        if (Test-Path $script) {
            Write-Host ""
            Write-Host "Launching Setup-Essentials.ps1..." -ForegroundColor Green
            Push-Location (Join-Path $cloneLocation "windows")
            & $script
            Pop-Location
        } else {
            Write-Host "[FAIL] Script not found: $script" -ForegroundColor Red
        }
    }
    "4" {
        $script = Join-Path $cloneLocation "windows\Setup-Packages.ps1"
        if (Test-Path $script) {
            Write-Host ""
            Write-Host "Launching Setup-Packages.ps1..." -ForegroundColor Green
            Push-Location (Join-Path $cloneLocation "windows")
            & $script
            Pop-Location
        } else {
            Write-Host "[FAIL] Script not found: $script" -ForegroundColor Red
        }
    }
    "5" {
        if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
            Write-Host ""
            Write-Host "Running: chezmoi apply" -ForegroundColor Green
            chezmoi apply
        } else {
            Write-Host "[FAIL] chezmoi not found. Run Setup-Essentials.ps1 first." -ForegroundColor Red
        }
    }
    "6" {
        $script = Join-Path $cloneLocation "windows\Setup-PowerShell.ps1"
        if (Test-Path $script) {
            Write-Host ""
            Write-Host "Launching Setup-PowerShell.ps1..." -ForegroundColor Green
            Push-Location (Join-Path $cloneLocation "windows")
            & $script
            Pop-Location
        } else {
            Write-Host "[FAIL] Script not found: $script" -ForegroundColor Red
        }
    }
    "7" {
        $script = Join-Path $cloneLocation "windows\Setup-Komorebi.ps1"
        if (Test-Path $script) {
            Write-Host ""
            Write-Host "Launching Setup-Komorebi.ps1..." -ForegroundColor Green
            Push-Location (Join-Path $cloneLocation "windows")
            & $script
            Pop-Location
        } else {
            Write-Host "[FAIL] Script not found: $script" -ForegroundColor Red
        }
    }
    "8" {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "Running Full Setup Workflow" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        
        Push-Location (Join-Path $cloneLocation "windows")
        
        # Step 1: System Cleanup
        $script = "Setup-System.ps1"
        if (Test-Path $script) {
            Write-Host "→ Step 1/5: Running Setup-System.ps1" -ForegroundColor Cyan
            & ".\$script"
            Write-Host ""
        }
        
        # Step 2: Install Apps
        $script = "Setup-Apps.ps1"
        if (Test-Path $script) {
            Write-Host "→ Step 2/5: Running Setup-Apps.ps1" -ForegroundColor Cyan
            & ".\$script"
            Write-Host ""
        }
        
        # Step 3: Essentials
        $script = "Setup-Essentials.ps1"
        if (Test-Path $script) {
            Write-Host "→ Step 3/5: Running Setup-Essentials.ps1" -ForegroundColor Cyan
            & ".\$script"
            Write-Host ""
        }
        
        # Step 4: Packages
        $script = "Setup-Packages.ps1"
        if (Test-Path $script) {
            Write-Host "→ Step 4/5: Running Setup-Packages.ps1" -ForegroundColor Cyan
            & ".\$script"
            Write-Host ""
        }
        
        # Step 5: Apply dotfiles
        if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
            Write-Host "→ Step 5/5: Running chezmoi apply" -ForegroundColor Cyan
            chezmoi apply
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "Full Setup Complete!" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
        } else {
            Write-Host "⚠ chezmoi not available, skipping dotfiles step" -ForegroundColor Yellow
        }
        
        Pop-Location
    }
    default {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host "Manual Setup" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "To run scripts manually:" -ForegroundColor Cyan
        Write-Host "  cd $cloneLocation\windows" -ForegroundColor White
        Write-Host "  .\Setup-System.ps1" -ForegroundColor White
        Write-Host "  .\Setup-Apps.ps1" -ForegroundColor White
        Write-Host "  .\Setup-Essentials.ps1" -ForegroundColor White
        Write-Host "  .\Setup-Packages.ps1" -ForegroundColor White
        Write-Host "  chezmoi apply" -ForegroundColor White
        Write-Host ""
    }
}

#endregion
