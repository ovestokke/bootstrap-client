#
# Zsh + Powerlevel10k Setup Script for Windows/WSL
#
# @author: Ovestokke
# @version: 1.0
#
# This script helps setup Zsh with Powerlevel10k inside WSL from Windows
# Usage: Run in PowerShell (Admin not required)
#

#region Functions

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

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Zsh + Powerlevel10k Setup for WSL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

#region Check WSL

Write-Host "Checking WSL installation..." -ForegroundColor Cyan
Write-Host ""

# Check if WSL is installed
try {
    $wslCheck = wsl --list --verbose 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "WSL not found"
    }
    Write-Success "WSL is installed"
}
catch {
    Write-Fail "WSL is not installed"
    Write-Info "Install WSL first by running: wsl --install"
    Write-Info "Or run Setup-Windows.ps1 which includes WSL installation"
    exit 1
}

# List available distributions
Write-Host ""
Write-Host "Available WSL distributions:" -ForegroundColor Cyan
wsl --list --verbose

Write-Host ""

#endregion

#region Select Distribution

# Get list of distributions
$distributions = wsl --list --quiet | Where-Object { $_ -notmatch "docker" }

if ($distributions.Count -eq 0) {
    Write-Fail "No WSL distributions found"
    Write-Info "Install a distribution first: wsl --install -d Ubuntu"
    exit 1
}

# If only one distribution, use it
if ($distributions.Count -eq 1) {
    $selectedDistro = $distributions[0].Trim()
    Write-Info "Using WSL distribution: $selectedDistro"
}
else {
    Write-Host "Multiple distributions found:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $distributions.Count; $i++) {
        Write-Host "  [$i] $($distributions[$i].Trim())" -ForegroundColor White
    }
    Write-Host ""
    $selection = Read-Host "Select distribution number (default: 0)"
    
    if ([string]::IsNullOrWhiteSpace($selection)) {
        $selection = 0
    }
    
    $selectedDistro = $distributions[$selection].Trim()
    Write-Info "Selected distribution: $selectedDistro"
}

# Verify WSL distribution is running/usable
Write-Info "Verifying WSL distribution is configured..."
try {
    $testResult = wsl -d $selectedDistro -e true 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Distribution not properly configured"
    }
    Write-Success "WSL distribution is ready"
}
catch {
    Write-Fail "WSL distribution '$selectedDistro' is not properly configured"
    Write-Info "Try running: wsl -d $selectedDistro"
    Write-Info "Complete the initial setup, then run this script again"
    exit 1
}

Write-Host ""

#endregion

#region Check Script Location

# Get the directory where this script is located and find the Linux script
$scriptDir = $PSScriptRoot
$repoRoot = Split-Path $scriptDir -Parent
$linuxScriptName = "Setup-Zsh-Linux.sh"
$linuxScriptPath = Join-Path (Join-Path $repoRoot "linux") $linuxScriptName

if (-not (Test-Path $linuxScriptPath)) {
    Write-Fail "Setup-Zsh-Linux.sh not found at: $linuxScriptPath"
    Write-Info "Please ensure $linuxScriptName exists in the linux/ directory"
    exit 1
}

Write-Success "Found $linuxScriptName"

# Convert Windows path to WSL path
$linuxScriptDir = Split-Path $linuxScriptPath -Parent

try {
    $driveInfo = Get-Item $linuxScriptDir -ErrorAction Stop
    $driveLetter = $driveInfo.PSDrive.Name
    
    if ([string]::IsNullOrEmpty($driveLetter)) {
        throw "Could not determine drive letter"
    }
    
    # Properly escape path and convert to WSL format
    $relativePath = $linuxScriptDir.Substring(3).Replace("\", "/")
    $wslPath = "/mnt/$($driveLetter.ToLower())/$relativePath"
}
catch {
    Write-Fail "Failed to convert Windows path to WSL path: $($_.Exception.Message)"
    exit 1
}

Write-Info "WSL path: $wslPath"
Write-Host ""

#endregion

#region Run Setup in WSL

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Running Zsh Setup in WSL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Info "This will run Setup-Zsh-Linux.sh inside your WSL distribution"
Write-Info "You may be prompted for your sudo password inside WSL"
Write-Host ""

$confirm = Read-Host "Continue? (Y/N)"

if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Skip "Setup cancelled"
    exit 0
}

Write-Host ""
Write-Host "Launching WSL and running setup script..." -ForegroundColor Cyan
Write-Host ""

# Run the Linux script inside WSL
try {
    wsl -d $selectedDistro bash -c "cd '$wslPath' && chmod +x $linuxScriptName && ./$linuxScriptName"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Success "Zsh setup completed successfully in WSL!"
    }
    else {
        Write-Host ""
        Write-Fail "Setup script exited with error code: $LASTEXITCODE"
    }
}
catch {
    Write-Host ""
    Write-Fail "Failed to run setup script: $($_.Exception.Message)"
    exit 1
}

#endregion

#region Summary

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Launch WSL: " -NoNewline; Write-Host "wsl -d $selectedDistro" -ForegroundColor Yellow
Write-Host "  2. Run Powerlevel10k config wizard: " -NoNewline; Write-Host "p10k configure" -ForegroundColor Yellow
Write-Host "  3. Configure WezTerm to use WSL as default (optional)" -ForegroundColor White
Write-Host ""
Write-Host "WezTerm WSL Configuration:" -ForegroundColor Cyan
Write-Host "  Add to .wezterm.lua:" -ForegroundColor White
Write-Host "  default_prog = { 'wsl.exe', '-d', '$selectedDistro' }" -ForegroundColor Gray
Write-Host ""
Write-Host "Reference guide:" -ForegroundColor Cyan
Write-Host "  https://www.josean.com/posts/how-to-setup-wezterm-terminal" -ForegroundColor White
Write-Host ""

#endregion
