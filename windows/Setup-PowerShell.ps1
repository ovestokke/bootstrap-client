#
# PowerShell + Oh My Posh Setup Script
#
# @author: Ovestokke
# @version: 1.0
#
# This script installs and configures Oh My Posh with PowerShell
# Usage: Run in PowerShell as Administrator
#

#region Check Admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this script again."
    exit 1
}
#endregion

#region Helper Functions

function Write-Success {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Fail {
    param([string]$Message)
    Write-Host "  [FAIL] $Message" -ForegroundColor Red
}

function Write-Skip {
    param([string]$Message)
    Write-Host "  [SKIP] $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "  → $Message" -ForegroundColor Cyan
}

#endregion

# Start logging
$logFile = Join-Path $PSScriptRoot "Setup-PowerShell-Log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').log"
Start-Transcript -Path $logFile
Write-Host "Logging to: $logFile" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PowerShell + Oh My Posh Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

#region Check PowerShell Version

Write-Host "Checking PowerShell version..." -ForegroundColor Cyan

$psVersion = $PSVersionTable.PSVersion
Write-Info "PowerShell version: $psVersion"

if ($psVersion.Major -lt 7) {
    Write-Host ""
    Write-Host "[WARN] You are running Windows PowerShell $psVersion" -ForegroundColor Yellow
    Write-Info "PowerShell 7+ is recommended for the best experience"
    Write-Host ""
    
    $installPS7 = Read-Host "Install PowerShell 7? (Y/N)"
    
    if ($installPS7 -eq "Y" -or $installPS7 -eq "y") {
        Write-Info "Installing PowerShell 7..."
        
        # NOTE: You can find the exact ID of an application by running 'winget search "Application Name"' on your Windows machine. Using the exact ID is more reliable.
        winget install --id Microsoft.PowerShell -e --accept-package-agreements --accept-source-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "PowerShell 7 installed successfully"
            Write-Host ""
            Write-Host "[INFO] Please restart your terminal and run this script again in PowerShell 7" -ForegroundColor Yellow
            Write-Host "To launch PowerShell 7, type: pwsh" -ForegroundColor Yellow
            Stop-Transcript
            exit 0
        }
        elseif ($LASTEXITCODE -eq -1978335189) {
            Write-Success "PowerShell 7 is already installed"
        }
        else {
            Write-Fail "PowerShell 7 installation failed"
        }
    }
}
else {
    Write-Success "PowerShell 7+ detected"
}

Write-Host ""

#endregion

#region Install Oh My Posh

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Oh My Posh Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Info "Installing Oh My Posh..."

try {
    # NOTE: You can find the exact ID of an application by running 'winget search "Application Name"' on your Windows machine. Using the exact ID is more reliable.
    winget install --id JanDeDobbeleer.OhMyPosh -e --source winget --scope user --accept-package-agreements --accept-source-agreements --force
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Oh My Posh installed successfully"
    }
    elseif ($LASTEXITCODE -eq -1978335189) {
        Write-Success "Oh My Posh is already installed"
    }
    else {
        Write-Fail "Oh My Posh installation failed with exit code: $LASTEXITCODE"
    }
}
catch {
    Write-Fail "Failed to install Oh My Posh: $($_.Exception.Message)"
}

Write-Host ""

# Refresh PATH to include Oh My Posh
Write-Info "Refreshing environment PATH..."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

#endregion

#region Install Meslo Nerd Font

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Nerd Font Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Oh My Posh font command is available
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    Write-Info "Installing Meslo Nerd Font via Oh My Posh..."
    
    try {
        oh-my-posh font install meslo --user
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Meslo Nerd Font installed successfully"
        }
        else {
            Write-Skip "Font may already be installed or installation skipped"
        }
    }
    catch {
        Write-Fail "Failed to install font: $($_.Exception.Message)"
        Write-Info "You can install fonts manually from: https://www.nerdfonts.com/font-downloads"
    }
}
else {
    Write-Skip "Oh My Posh command not found - restart terminal and run font installation separately"
    Write-Info "After restarting, run: oh-my-posh font install meslo"
}

Write-Host ""

#endregion

#region Install PowerShell Modules

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PowerShell Modules Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Set PSGallery as trusted for module installation
Write-Info "Setting PSGallery as trusted repository..."
try {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction Stop
    Write-Success "PSGallery set as trusted"
}
catch {
    Write-Fail "Failed to set PSGallery as trusted: $($_.Exception.Message)"
}

Write-Host ""

# Install PSReadLine (enhanced command-line editing)
Write-Info "Installing PSReadLine module..."
try {
    if (Get-Module -ListAvailable -Name PSReadLine) {
        Write-Skip "PSReadLine is already installed"
        
        # Update to latest version
        Write-Info "Updating PSReadLine to latest version..."
        Update-Module -Name PSReadLine -Force -ErrorAction SilentlyContinue
    }
    else {
        Install-Module -Name PSReadLine -Force -Scope CurrentUser -ErrorAction Stop
        Write-Success "PSReadLine installed"
    }
}
catch {
    Write-Fail "Failed to install PSReadLine: $($_.Exception.Message)"
}

Write-Host ""

# Install Terminal-Icons (file/folder icons in directory listings)
Write-Info "Installing Terminal-Icons module..."
try {
    if (Get-Module -ListAvailable -Name Terminal-Icons) {
        Write-Skip "Terminal-Icons is already installed"
    }
    else {
        Install-Module -Name Terminal-Icons -Force -Scope CurrentUser -ErrorAction Stop
        Write-Success "Terminal-Icons installed"
    }
}
catch {
    Write-Fail "Failed to install Terminal-Icons: $($_.Exception.Message)"
}

Write-Host ""

# Install PSFzf (fuzzy finder)
Write-Info "Installing PSFzf module (fuzzy finder)..."
try {
    if (Get-Module -ListAvailable -Name PSFzf) {
        Write-Skip "PSFzf is already installed"
    }
    else {
        Install-Module -Name PSFzf -Force -Scope CurrentUser -ErrorAction Stop
        Write-Success "PSFzf installed"
    }
}
catch {
    Write-Fail "Failed to install PSFzf: $($_.Exception.Message)"
}

Write-Host ""

# Install z (directory jumper)
Write-Info "Installing z module (directory jumper)..."
try {
    if (Get-Module -ListAvailable -Name z) {
        Write-Skip "z is already installed"
    }
    else {
        Install-Module -Name z -Force -Scope CurrentUser -AllowClobber -ErrorAction Stop
        Write-Success "z installed"
    }
}
catch {
    Write-Fail "Failed to install z: $($_.Exception.Message)"
}

Write-Host ""

#endregion

#region Configure PowerShell Profile

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PowerShell Profile Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Determine profile path based on PowerShell version
if ($psVersion.Major -ge 7) {
    $profilePath = $PROFILE.CurrentUserCurrentHost
    Write-Info "Using PowerShell 7+ profile: $profilePath"
}
else {
    $profilePath = $PROFILE.CurrentUserCurrentHost
    Write-Info "Using Windows PowerShell profile: $profilePath"
}

# Check if profile already exists
if (Test-Path $profilePath) {
    Write-Host ""
    Write-Host "[WARN] PowerShell profile already exists" -ForegroundColor Yellow
    Write-Info "Current profile: $profilePath"
    Write-Host ""
    
    $overwrite = Read-Host "Overwrite with new configuration? (Y/N/B for Backup+Overwrite)"
    
    if ($overwrite -eq "B" -or $overwrite -eq "b") {
        # Backup existing profile
        $backupPath = "$profilePath.backup-$(Get-Date -Format 'yyyy-MM-dd-HHmmss')"
        Copy-Item $profilePath -Destination $backupPath -Force
        Write-Success "Backed up existing profile to: $backupPath"
        
        $shouldOverwrite = $true
    }
    elseif ($overwrite -eq "Y" -or $overwrite -eq "y") {
        $shouldOverwrite = $true
    }
    else {
        $shouldOverwrite = $false
        Write-Skip "Keeping existing profile"
    }
}
else {
    $shouldOverwrite = $true
    Write-Info "Creating new PowerShell profile"
}

if ($shouldOverwrite) {
    # Get the profile template from repository
    $repoProfileTemplate = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile.ps1"
    
    if (Test-Path $repoProfileTemplate) {
        # Ensure profile directory exists
        $profileDir = Split-Path $profilePath -Parent
        if (-not (Test-Path $profileDir)) {
            New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
            Write-Info "Created profile directory: $profileDir"
        }
        
        # Copy template to profile location
        Copy-Item $repoProfileTemplate -Destination $profilePath -Force
        Write-Success "PowerShell profile configured: $profilePath"
    }
    else {
        # Create profile from scratch
        $profileContent = @'
# Oh My Posh initialization
oh-my-posh init pwsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/catppuccin_mocha.omp.json | Invoke-Expression

# Import modules
Import-Module Terminal-Icons
Import-Module z
Import-Module PSReadLine
Import-Module PSFzf

# PSReadLine configuration
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# PSFzf configuration
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Aliases
Set-Alias -Name g -Value git
Set-Alias -Name vim -Value nvim -ErrorAction SilentlyContinue
Set-Alias -Name ll -Value Get-ChildItem

# Custom functions
function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function touch ($file) {
    "" | Out-File $file -Encoding ASCII
}

function mkcd ($dir) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Set-Location $dir
}
'@
        
        # Ensure profile directory exists
        $profileDir = Split-Path $profilePath -Parent
        if (-not (Test-Path $profileDir)) {
            New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
            Write-Info "Created profile directory: $profileDir"
        }
        
        # Write profile content
        $profileContent | Out-File -FilePath $profilePath -Encoding UTF8 -Force
        Write-Success "PowerShell profile created: $profilePath"
        Write-Info "Profile template not found in repository, created default configuration"
    }
}

Write-Host ""

#endregion

#region Enable Oh My Posh Auto-Reload

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Oh My Posh Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    Write-Info "Enabling Oh My Posh auto-reload..."
    
    try {
        oh-my-posh enable reload
        Write-Success "Oh My Posh auto-reload enabled"
    }
    catch {
        Write-Skip "Auto-reload may already be enabled or command not available"
    }
}
else {
    Write-Skip "Oh My Posh command not found - restart terminal to complete setup"
}

Write-Host ""

#endregion

#region Summary

Write-Host "========================================" -ForegroundColor Green
Write-Host "PowerShell Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "What was installed:" -ForegroundColor Cyan
Write-Host "  ✓ Oh My Posh (prompt theme engine)" -ForegroundColor White
Write-Host "  ✓ Meslo Nerd Font (patched font with icons)" -ForegroundColor White
Write-Host "  ✓ PSReadLine (enhanced command-line editing)" -ForegroundColor White
Write-Host "  ✓ Terminal-Icons (file/folder icons)" -ForegroundColor White
Write-Host "  ✓ PSFzf (fuzzy finder)" -ForegroundColor White
Write-Host "  ✓ z (directory jumper)" -ForegroundColor White
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. " -NoNewline; Write-Host "IMPORTANT: Restart your PowerShell terminal" -ForegroundColor Yellow
Write-Host "  2. " -NoNewline; Write-Host "Open WezTerm or Windows Terminal" -ForegroundColor White
Write-Host "  3. " -NoNewline; Write-Host "Oh My Posh should load automatically with Catppuccin Mocha theme" -ForegroundColor White
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  oh-my-posh config export --output ~/my-theme.omp.json  " -NoNewline -ForegroundColor Gray
Write-Host "# Export current theme" -ForegroundColor DarkGray
Write-Host "  oh-my-posh init pwsh --config ~/my-theme.omp.json      " -NoNewline -ForegroundColor Gray
Write-Host "# Use custom theme" -ForegroundColor DarkGray
Write-Host "  z <keyword>                                             " -NoNewline -ForegroundColor Gray
Write-Host "# Jump to directory" -ForegroundColor DarkGray
Write-Host "  Ctrl+R                                                  " -NoNewline -ForegroundColor Gray
Write-Host "# Search command history" -ForegroundColor DarkGray
Write-Host "  Ctrl+F                                                  " -NoNewline -ForegroundColor Gray
Write-Host "# Fuzzy file finder" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Profile location: " -NoNewline -ForegroundColor Cyan
Write-Host "$profilePath" -ForegroundColor White
Write-Host "Log file: " -NoNewline -ForegroundColor Cyan
Write-Host "$logFile" -ForegroundColor White
Write-Host ""
Write-Host "Theme gallery: " -NoNewline -ForegroundColor Cyan
Write-Host "https://ohmyposh.dev/docs/themes" -ForegroundColor White
Write-Host ""

Stop-Transcript

#endregion
