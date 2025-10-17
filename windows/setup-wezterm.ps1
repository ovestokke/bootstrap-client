#
# WezTerm Setup Script
#
# @author: Ovestokke
# @version: 1.0
#
# This script installs and configures WezTerm with Meslo Nerd Font
#

#region Check Admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this script again."
    exit 1
}
#endregion

# Start logging
$logFile = Join-Path $PSScriptRoot "Setup-WezTerm-Log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').log"
Start-Transcript -Path $logFile
Write-Host "Logging to: $logFile" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WezTerm Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

#region Install WezTerm

Write-Host "Installing WezTerm..." -ForegroundColor Cyan

try {
    $wezterm = winget show --id wez.wezterm -e 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "WezTerm is already available via winget" -ForegroundColor Green

        $install = Read-Host "Install/Reinstall WezTerm? (Y/N)"
        if ($install -eq "Y" -or $install -eq "y") {
            winget install --id wez.wezterm -e --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[OK] WezTerm installed successfully" -ForegroundColor Green
            }
        }
    }
}
catch {
    Write-Host "[FAIL] Failed to check/install WezTerm: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

#endregion

#region Install Meslo Nerd Font

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installing Meslo Nerd Font..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Download Meslo Nerd Font
    # NOTE: Update version periodically - check https://github.com/ryanoasis/nerd-fonts/releases
    $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip"
    $fontZip = Join-Path $env:TEMP "Meslo.zip"
    $fontExtract = Join-Path $env:TEMP "MesloFonts"

    Write-Host "Downloading Meslo Nerd Font from GitHub..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip -ErrorAction Stop
    Write-Host "[OK] Download completed" -ForegroundColor Green

    # Extract fonts
    Write-Host "Extracting fonts..." -ForegroundColor Cyan
    Expand-Archive -Path $fontZip -DestinationPath $fontExtract -Force -ErrorAction Stop

    # Install fonts
    $fontsFolder = [System.Environment]::GetFolderPath('Fonts')

    Write-Host "Installing fonts to: $fontsFolder" -ForegroundColor Cyan
    $installed = 0
    $skipped = 0

    Get-ChildItem -Path $fontExtract -Include @('*.ttf', '*.otf') -Recurse | ForEach-Object {
        $fontName = $_.Name
        $targetPath = Join-Path $fontsFolder $fontName

        if (-not (Test-Path $targetPath)) {
            try {
                Copy-Item $_.FullName -Destination $fontsFolder -Force
                $installed++
            }
            catch {
                Write-Host "  [SKIP] Could not install $fontName" -ForegroundColor Yellow
            }
        }
        else {
            $skipped++
        }
    }

    if ($installed -eq 0 -and $skipped -gt 0) {
        Write-Host "[OK] All $skipped font files already installed" -ForegroundColor Green
    }
    elseif ($installed -gt 0) {
        Write-Host "[OK] Installed $installed new font files ($skipped already existed)" -ForegroundColor Green
    }
    else {
        Write-Host "[FAIL] No font files found to install" -ForegroundColor Red
    }

    # Cleanup
    Write-Host "Cleaning up temporary files..." -ForegroundColor Cyan
    Remove-Item $fontZip -Force -ErrorAction SilentlyContinue
    Remove-Item $fontExtract -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] Cleanup completed" -ForegroundColor Green
}
catch {
    Write-Host "[FAIL] Failed to install Nerd Fonts: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manual installation:" -ForegroundColor Yellow
    Write-Host "  1. Download from: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip" -ForegroundColor White
    Write-Host "  2. Extract the zip file" -ForegroundColor White
    Write-Host "  3. Select all .ttf files, right-click, and choose 'Install for all users'" -ForegroundColor White
}

Write-Host ""

#endregion

#region Configure WezTerm

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WezTerm Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$weztermConfig = Join-Path $env:USERPROFILE ".wezterm.lua"
$repoWeztermConfig = Join-Path (Split-Path $PSScriptRoot -Parent) ".wezterm.lua"

if (Test-Path $repoWeztermConfig) {
    if (Test-Path $weztermConfig) {
        Write-Host "WezTerm config already exists at: $weztermConfig" -ForegroundColor Yellow
        $overwrite = Read-Host "Overwrite with repository config? (Y/N)"

        if ($overwrite -eq "Y" -or $overwrite -eq "y") {
            Copy-Item $repoWeztermConfig -Destination $weztermConfig -Force
            Write-Host "[OK] WezTerm config updated" -ForegroundColor Green
        }
        else {
            Write-Host "[SKIP] Keeping existing config" -ForegroundColor Yellow
        }
    }
    else {
        Copy-Item $repoWeztermConfig -Destination $weztermConfig -Force
        Write-Host "[OK] WezTerm config installed to: $weztermConfig" -ForegroundColor Green
    }
}
else {
    Write-Host "[INFO] No wezterm.lua found in repository" -ForegroundColor Yellow
    Write-Host "You'll need to create a config file at: $weztermConfig" -ForegroundColor Yellow
}

Write-Host ""

#endregion

#region Summary

Write-Host "========================================" -ForegroundColor Green
Write-Host "WezTerm Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Launch WezTerm from Start Menu" -ForegroundColor White
Write-Host "  2. The Meslo Nerd Font should be automatically detected" -ForegroundColor White
Write-Host "  3. Configure your .wezterm.lua file if needed" -ForegroundColor White
Write-Host "  4. Reference: https://www.josean.com/posts/how-to-setup-wezterm-terminal" -ForegroundColor White
Write-Host ""
Write-Host "Log file: $logFile" -ForegroundColor Cyan
Write-Host ""

Stop-Transcript

#endregion
