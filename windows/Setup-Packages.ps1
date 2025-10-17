#
# Windows Packages Setup Script
#
# @author: Ovestokke
# @version: 1.0
#
# Installs all development tools and packages
# Does NOT configure or copy any config files - chezmoi manages all configs
#
# Installs:
# - WezTerm terminal emulator
# - Meslo Nerd Font
# - GitHub CLI and GPG (optional)
#
# WSL setup (Zsh, Neovim, CLI tools) must be done manually from within WSL
# See: linux/init-linux.sh or linux/setup-zsh-linux.sh
#

#region Setup

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows Packages Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this script again." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Running as Administrator" -ForegroundColor Green
Write-Host ""

$logFile = Join-Path $PSScriptRoot "Setup-Packages-Log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').log"
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

#region Install WezTerm

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WezTerm Terminal Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (Get-Command wezterm -ErrorAction SilentlyContinue) {
    Write-Success "WezTerm is already installed"
} else {
    Write-Info "Installing WezTerm via winget..."
    
    try {
        $process = Start-Process -FilePath "winget" `
            -ArgumentList "install --id wez.wezterm -e --accept-package-agreements --accept-source-agreements" `
            -NoNewWindow -PassThru -Wait
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq -1978335189) {
            Write-Success "WezTerm installed successfully"
        } else {
            Write-Fail "WezTerm installation failed with exit code: $($process.ExitCode)"
        }
    } catch {
        Write-Fail "Error installing WezTerm: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Info "Configuration: .wezterm.lua should be managed by chezmoi"
Write-Host ""

#endregion

#region Install Meslo Nerd Font

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Meslo Nerd Font Installation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$fontsInstalled = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" | 
    Select-String -Pattern "MesloLGS" -Quiet

if ($fontsInstalled) {
    Write-Success "Meslo Nerd Font is already installed"
} else {
    Write-Info "Installing Meslo Nerd Font..."
    
    $fontUrls = @(
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf",
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf",
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf",
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
    )
    
    $tempDir = Join-Path $env:TEMP "MesloFont"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    $fontsFolder = (New-Object -ComObject Shell.Application).Namespace(0x14)
    
    foreach ($url in $fontUrls) {
        $fileName = [System.IO.Path]::GetFileName($url) -replace '%20', ' '
        $filePath = Join-Path $tempDir $fileName
        
        try {
            Write-Info "Downloading $fileName..."
            Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction Stop
            
            Write-Info "Installing $fileName..."
            $fontsFolder.CopyHere($filePath, 0x10)
            
            Write-Success "Installed $fileName"
        } catch {
            Write-Fail "Failed to install $fileName : $($_.Exception.Message)"
        }
    }
    
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Success "Meslo Nerd Font installation complete"
}

Write-Host ""

#endregion

#region WSL Setup Information

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WSL Development Tools" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "⚠ WSL setup cannot be automated from PowerShell (requires interactive sudo)" -ForegroundColor Yellow
Write-Host ""

try {
    $wslOutput = wsl.exe --list --quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        $wslDistros = $wslOutput -replace '\x00', '' -replace '\r', ''
        $distroList = $wslDistros -split "`n" | 
            Where-Object { $_ -match '\S' } | 
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ -ne '' -and $_ -notlike "*docker*" -and $_ -notlike "*rancher*" }
        
        if ($distroList.Count -gt 0) {
            Write-Success "Found WSL distribution(s):"
            foreach ($distro in $distroList) {
                Write-Host "  • $distro" -ForegroundColor White
            }
            Write-Host ""
        }
    }
} catch {
    Write-Skip "WSL not detected"
}

Write-Host "To set up development tools in WSL:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Open WSL:" -ForegroundColor White
Write-Host "     wsl -d Ubuntu" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Clone bootstrap-client in WSL:" -ForegroundColor White
Write-Host "     cd ~ && git clone https://github.com/YOUR_USERNAME/bootstrap-client.git" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Run the Linux initialization script:" -ForegroundColor White
Write-Host "     cd bootstrap-client && ./init-linux.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "  Or manually run specific scripts:" -ForegroundColor White
Write-Host "     ./linux/setup-zsh-linux.sh     # Zsh + Oh My Zsh + Powerlevel10k" -ForegroundColor Gray
Write-Host "     ./linux/setup-neovim.sh        # Neovim + LazyVim (if available)" -ForegroundColor Gray
Write-Host ""

Write-Host "What gets installed in WSL (via init-linux.sh):" -ForegroundColor Cyan
Write-Host "  • Zsh + Oh My Zsh + Powerlevel10k" -ForegroundColor White
Write-Host "  • Modern CLI tools (eza, zoxide, fzf, ripgrep, fd, bat)" -ForegroundColor White
Write-Host "  • Neovim + dependencies (build-essential, lazygit)" -ForegroundColor White
Write-Host "  • Meslo Nerd Font" -ForegroundColor White
Write-Host ""

#endregion

#region Summary

Write-Host "========================================" -ForegroundColor Green
Write-Host "Packages Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Installed:" -ForegroundColor Cyan
Write-Host "  ✓ WezTerm terminal" -ForegroundColor Green
Write-Host "  ✓ Meslo Nerd Font (Windows)" -ForegroundColor Green
Write-Host ""

Write-Host "⚠ Next: Set up WSL tools from within WSL (see instructions above)" -ForegroundColor Yellow
Write-Host "⚠ Configuration is managed by chezmoi" -ForegroundColor Yellow
Write-Host ""

#endregion

#region GitHub Setup (Optional)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub / Git Tools Setup (Optional)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This section installs tools for GitHub authentication and commit signing." -ForegroundColor Yellow
Write-Host "You can skip this and set up GitHub authentication later." -ForegroundColor Yellow
Write-Host ""

$setupGitHub = Read-Host "Set up GitHub tools now? (y/N)"

if ($setupGitHub -eq "y" -or $setupGitHub -eq "Y") {
    Write-Host ""
    Write-Info "Installing GitHub CLI..."
    $process = Start-Process -FilePath "winget" `
        -ArgumentList "install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements" `
        -NoNewWindow -PassThru -Wait

    if ($process.ExitCode -eq 0 -or $process.ExitCode -eq -1978335189) {
        Write-Success "GitHub CLI installed"
    } else {
        Write-Fail "GitHub CLI installation failed"
    }

    Write-Host ""

    Write-Info "Installing GPG for commit signing..."
    $process = Start-Process -FilePath "winget" `
        -ArgumentList "install --id GnuPG.GnuPG -e --accept-package-agreements --accept-source-agreements" `
        -NoNewWindow -PassThru -Wait

    if ($process.ExitCode -eq 0 -or $process.ExitCode -eq -1978335189) {
        Write-Success "GPG installed"
    } else {
        Write-Fail "GPG installation failed"
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "GitHub Authentication Options" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Choose how you want to authenticate with GitHub:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] 1Password SSH Agent (recommended if you use 1Password)" -ForegroundColor White
    Write-Host "      → Requires: 1Password installed with SSH agent enabled" -ForegroundColor Gray
    Write-Host "      → Benefit: Automatic SSH key management, biometric unlock" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [2] Traditional SSH Keys (manual setup)" -ForegroundColor White
    Write-Host "      → You'll generate keys manually later" -ForegroundColor Gray
    Write-Host "      → Benefit: Works without 1Password" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  [3] Skip - Set up later" -ForegroundColor White
    Write-Host "      → No SSH setup now" -ForegroundColor Gray
    Write-Host ""
    
    do {
        $authChoice = Read-Host "Choose option (1, 2, or 3)"
    } while ($authChoice -notmatch '^[123]$')
    
    Write-Host ""
    
    switch ($authChoice) {
        "1" {
            # 1Password SSH Agent setup
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "1Password SSH Agent Setup" -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host ""
            
            Write-Host "Prerequisites:" -ForegroundColor Yellow
            Write-Host "  1. 1Password app installed on Windows" -ForegroundColor White
            Write-Host "  2. SSH agent enabled in 1Password settings:" -ForegroundColor White
            Write-Host "     Settings → Developer → Use the SSH agent" -ForegroundColor Gray
            Write-Host ""
            
            $has1Password = Read-Host "Do you have 1Password installed and SSH agent enabled? (y/N)"
            
            if ($has1Password -eq "y" -or $has1Password -eq "Y") {
                    Write-Host ""
                    Write-Info "1Password SSH bridge setup requires WSL configuration"
                    Write-Host ""
                    Write-Host "Setup steps (run in WSL):" -ForegroundColor Cyan
                    Write-Host "  1. Install socat: sudo apt-get install -y socat" -ForegroundColor White
                    Write-Host "  2. Download npiperelay:" -ForegroundColor White
                    Write-Host "     mkdir -p ~/.local/bin && cd ~/.local/bin" -ForegroundColor Gray
                    Write-Host "     wget https://github.com/jstarks/npiperelay/releases/latest/download/npiperelay_windows_amd64.zip" -ForegroundColor Gray
                    Write-Host "     unzip npiperelay_windows_amd64.zip && chmod +x npiperelay.exe" -ForegroundColor Gray
                    Write-Host ""
                    Write-Host "  3. Add to .zshrc (managed by chezmoi):" -ForegroundColor White
                    Write-Host '     export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"' -ForegroundColor Gray
                    Write-Host '     if [ ! -S "$SSH_AUTH_SOCK" ]; then' -ForegroundColor Gray
                    Write-Host '         rm -f "$SSH_AUTH_SOCK"' -ForegroundColor Gray
                    Write-Host '         (setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK,fork" EXEC:"~/.local/bin/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1' -ForegroundColor Gray
                    Write-Host '     fi' -ForegroundColor Gray
                    Write-Host ""
                    Write-Host "  4. Test: ssh -T git@github.com" -ForegroundColor White
                    Write-Host ""
            } else {
                Write-Host ""
                Write-Info "Install 1Password first, then run this script again"
                Write-Info "Or choose option 2 for traditional SSH keys"
            }
        }
        "2" {
            # Traditional SSH keys
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "Traditional SSH Keys" -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "To generate SSH keys manually:" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "In WSL (Ubuntu):" -ForegroundColor Cyan
            Write-Host '  ssh-keygen -t ed25519 -C "your_email@example.com"' -ForegroundColor White
            Write-Host "  gh auth login" -ForegroundColor White
            Write-Host ""
            Write-Host "Or use the legacy Setup-GitHub.ps1 script (deprecated)" -ForegroundColor Gray
            Write-Host ""
        }
        "3" {
            Write-Skip "Skipping GitHub authentication setup"
            Write-Info "You can set this up later manually"
        }
    }
} else {
    Write-Skip "Skipping GitHub tools installation"
    Write-Host ""
    Write-Info "To install later:"
    Write-Host "  GitHub CLI: winget install --id GitHub.cli" -ForegroundColor White
    Write-Host "  GPG: winget install --id GnuPG.GnuPG" -ForegroundColor White
}

Write-Host ""

#endregion

#region Final Summary

Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Set up WSL tools (see instructions above)" -ForegroundColor White
Write-Host "  2. Ensure chezmoi is initialized: chezmoi status" -ForegroundColor White
Write-Host "  3. Apply your dotfiles: chezmoi apply" -ForegroundColor White
Write-Host "  4. Launch WezTerm" -ForegroundColor White
Write-Host ""

Stop-Transcript

#endregion
