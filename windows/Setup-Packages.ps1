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
# - Zsh + Oh My Zsh + Powerlevel10k in WSL
# - Modern CLI tools (eza, zoxide, fzf, ripgrep)
# - Neovim + dependencies in WSL
# - Git tools (GitHub CLI, GPG)
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

#region WSL Detection and Tools

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WSL Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Use wsl.exe with proper encoding handling
    $wslOutput = wsl.exe --list --quiet 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "WSL command failed"
    }
    
    # Remove null characters and extra spaces from UTF-16 output
    $wslDistros = $wslOutput -replace '\x00', '' -replace '\r', ''
    $distroList = $wslDistros -split "`n" | 
        Where-Object { $_ -match '\S' } | 
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne '' }
    
    if ($distroList.Count -eq 0) {
        throw "No distributions found"
    }
} catch {
    Write-Skip "WSL is not installed or no distributions found"
    Write-Info "Run Setup-System.ps1 to install WSL first"
    Write-Host ""
    $distroList = @()
}

# Initialize validDistros in case WSL section is skipped
$validDistros = @()
$wslSetupSkipped = $false

if ($distroList.Count -gt 0) {
    
    # Filter out docker-desktop and other non-standard distros
    $validDistros = $distroList | Where-Object { 
        $_ -notlike "*docker*" -and 
        $_ -notlike "*rancher*" -and
        $_ -ne ""
    }
    
    if ($validDistros.Count -eq 0) {
        Write-Skip "No standard WSL distributions found (found: $($distroList -join ', '))"
        Write-Info "Install Ubuntu with: wsl --install -d Ubuntu"
        Write-Host ""
    } else {
        Write-Success "Found $($validDistros.Count) WSL distribution(s):"
        foreach ($distro in $validDistros) {
            Write-Host "  • $distro" -ForegroundColor White
        }
        Write-Host ""
        
        $setupWSL = Read-Host "Set up development tools in WSL now? (Y/n)"
        
        if ($setupWSL -eq "n" -or $setupWSL -eq "N") {
            Write-Skip "Skipping WSL development tools setup"
            Write-Info "You can set up dev tools manually later"
            Write-Host ""
            $wslSetupSkipped = $true
        }
    }
    
    # Only run dev tools installation if not skipped
    if (-not $wslSetupSkipped) {
        foreach ($distro in $validDistros) {
            Write-Host "----------------------------------------" -ForegroundColor Cyan
            Write-Host "Setting up: $distro" -ForegroundColor Cyan
            Write-Host "----------------------------------------" -ForegroundColor Cyan
            Write-Host ""
            
            #region Install Zsh and Oh My Zsh
        
        Write-Info "Installing Zsh and Oh My Zsh in $distro..."
        
        $zshSetupScript = @'
#!/bin/bash
set -e

echo "→ Updating package lists..."
sudo apt-get update -qq

echo "→ Installing Zsh..."
if ! command -v zsh &> /dev/null; then
    sudo apt-get install -y zsh
    echo "✓ Zsh installed"
else
    echo "✓ Zsh already installed"
fi

echo "→ Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ Oh My Zsh installed"
else
    echo "✓ Oh My Zsh already installed"
fi

echo "→ Installing Powerlevel10k theme..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    echo "✓ Powerlevel10k installed"
else
    echo "✓ Powerlevel10k already installed"
fi

echo "→ Installing zsh-autosuggestions..."
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    echo "✓ zsh-autosuggestions installed"
else
    echo "✓ zsh-autosuggestions already installed"
fi

echo "→ Installing zsh-syntax-highlighting..."
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    echo "✓ zsh-syntax-highlighting installed"
else
    echo "✓ zsh-syntax-highlighting already installed"
fi

echo "→ Setting Zsh as default shell..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
    echo "✓ Zsh set as default shell (logout/login required)"
else
    echo "✓ Zsh is already default shell"
fi

echo ""
echo "NOTE: .zshrc configuration should be managed by chezmoi"
echo ""
'@
        
        $zshSetupScript | wsl -d $distro bash
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Zsh and Oh My Zsh installed in $distro"
        } else {
            Write-Fail "Failed to install Zsh in $distro"
        }
        
        Write-Host ""
        
        #endregion
        
        #region Install Modern CLI Tools
        
        Write-Info "Installing modern CLI tools in $distro..."
        
        $cliToolsScript = @'
#!/bin/bash
set -e

echo "→ Installing eza (better ls)..."
if ! command -v eza &> /dev/null; then
    sudo apt-get install -y gpg
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update -qq
    sudo apt-get install -y eza
    echo "✓ eza installed"
else
    echo "✓ eza already installed"
fi

echo "→ Installing zoxide (better cd)..."
if ! command -v zoxide &> /dev/null; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    echo "✓ zoxide installed"
else
    echo "✓ zoxide already installed"
fi

echo "→ Installing fzf (fuzzy finder)..."
if ! command -v fzf &> /dev/null; then
    sudo apt-get install -y fzf
    echo "✓ fzf installed"
else
    echo "✓ fzf already installed"
fi

echo "→ Installing ripgrep (better grep)..."
if ! command -v rg &> /dev/null; then
    sudo apt-get install -y ripgrep
    echo "✓ ripgrep installed"
else
    echo "✓ ripgrep already installed"
fi

echo "→ Installing fd-find (better find)..."
if ! command -v fd &> /dev/null; then
    sudo apt-get install -y fd-find
    sudo ln -sf $(which fdfind) /usr/local/bin/fd 2>/dev/null || true
    echo "✓ fd-find installed"
else
    echo "✓ fd-find already installed"
fi

echo ""
echo "NOTE: Tool aliases should be configured in .zshrc (managed by chezmoi)"
echo ""
'@
        
        $cliToolsScript | wsl -d $distro bash
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Modern CLI tools installed in $distro"
        } else {
            Write-Fail "Failed to install CLI tools in $distro"
        }
        
        Write-Host ""
        
        #endregion
        
        #region Install Meslo Nerd Font in WSL
        
        Write-Info "Installing Meslo Nerd Font in $distro..."
        
        $fontInstallScript = @'
#!/bin/bash
set -e

mkdir -p ~/.local/share/fonts

cd ~/.local/share/fonts

if ls MesloLGS*.ttf 1> /dev/null 2>&1; then
    echo "✓ Meslo Nerd Font already installed in WSL"
else
    echo "→ Downloading Meslo Nerd Font..."
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    wget -q https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    
    fc-cache -f -v > /dev/null 2>&1
    echo "✓ Meslo Nerd Font installed in WSL"
fi
'@
        
        $fontInstallScript | wsl -d $distro bash
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Font installed in $distro"
        } else {
            Write-Fail "Failed to install font in $distro"
        }
        
        Write-Host ""
        
        #endregion
        
        #region Install Neovim and Dependencies
        
        Write-Info "Installing Neovim and dependencies in $distro..."
        
        $neovimSetupScript = @'
#!/bin/bash
set -e

echo "→ Adding Neovim PPA..."
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt-get update -qq

echo "→ Installing Neovim..."
if ! command -v nvim &> /dev/null; then
    sudo apt-get install -y neovim
    echo "✓ Neovim installed"
else
    echo "✓ Neovim already installed"
fi

echo "→ Installing build-essential (for Treesitter)..."
sudo apt-get install -y build-essential

echo "→ Installing Neovim dependencies..."
if ! command -v lazygit &> /dev/null; then
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -sLo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit.tar.gz lazygit
    echo "✓ lazygit installed"
else
    echo "✓ lazygit already installed"
fi

echo ""
echo "NOTE: Neovim configuration (~/.config/nvim) should be managed by chezmoi"
echo "      LazyVim will auto-install on first nvim launch if configured in dotfiles"
echo ""
'@
        
        $neovimSetupScript | wsl -d $distro bash
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Neovim and dependencies installed in $distro"
        } else {
            Write-Fail "Failed to install Neovim in $distro"
        }
        
        Write-Host ""
        
        #endregion
        }
    }
}

#endregion

#region Summary

Write-Host "========================================" -ForegroundColor Green
Write-Host "Packages Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Installed:" -ForegroundColor Cyan
Write-Host "  ✓ WezTerm terminal" -ForegroundColor Green
Write-Host "  ✓ Meslo Nerd Font (Windows + WSL)" -ForegroundColor Green
if ($validDistros.Count -gt 0 -and -not $wslSetupSkipped) {
    Write-Host "  ✓ Zsh + Oh My Zsh + Powerlevel10k (WSL)" -ForegroundColor Green
    Write-Host "  ✓ Modern CLI tools: eza, zoxide, fzf, ripgrep, fd (WSL)" -ForegroundColor Green
    Write-Host "  ✓ Neovim + dependencies (WSL)" -ForegroundColor Green
}
Write-Host ""

Write-Host "⚠ IMPORTANT: Configuration is managed by chezmoi" -ForegroundColor Yellow
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
                if ($validDistros.Count -eq 0) {
                    Write-Host ""
                    Write-Fail "No suitable WSL distributions found!"
                    Write-Info "1Password SSH agent requires WSL (Ubuntu/Debian). Install WSL first with Setup-System.ps1"
                } else {
                    Write-Host ""
                    Write-Info "Installing 1Password SSH bridge for WSL..."
                    
                    foreach ($distro in $validDistros) {
                        Write-Info "Setting up in $distro..."
                        
                        $sshBridgeScript = @'
#!/bin/bash
set -e

echo "→ Installing socat..."
sudo apt-get update -qq
sudo apt-get install -y socat

echo "→ Downloading npiperelay..."
mkdir -p ~/.local/bin
cd ~/.local/bin

if [ ! -f npiperelay.exe ]; then
    wget -q https://github.com/jstarks/npiperelay/releases/latest/download/npiperelay_windows_amd64.zip
    unzip -q npiperelay_windows_amd64.zip
    rm npiperelay_windows_amd64.zip
    chmod +x npiperelay.exe
    echo "✓ npiperelay installed"
else
    echo "✓ npiperelay already installed"
fi

echo ""
echo "=========================================="
echo "1Password SSH Agent Configuration"
echo "=========================================="
echo ""
echo "Add this to your .zshrc (managed by chezmoi):"
echo ""
echo '# 1Password SSH Agent'
echo 'export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"'
echo 'if [ ! -S "$SSH_AUTH_SOCK" ]; then'
echo '    rm -f "$SSH_AUTH_SOCK"'
echo '    (setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK,fork" EXEC:"~/.local/bin/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1'
echo 'fi'
echo ""
'@
                        
                        $sshBridgeScript | wsl -d $distro bash
                        
                        if ($LASTEXITCODE -eq 0) {
                            Write-Success "1Password SSH bridge installed in $distro"
                        } else {
                            Write-Fail "Failed to install in $distro"
                        }
                    }
                    
                    Write-Host ""
                    Write-Success "1Password SSH bridge setup complete!"
                    Write-Host ""
                    Write-Host "Next steps:" -ForegroundColor Cyan
                    Write-Host "  1. Add the SSH configuration to your chezmoi dotfiles (.zshrc)" -ForegroundColor White
                    Write-Host "  2. Run: chezmoi apply" -ForegroundColor White
                    Write-Host "  3. Restart WSL or source ~/.zshrc" -ForegroundColor White
                    Write-Host "  4. Test: ssh -T git@github.com" -ForegroundColor White
                    Write-Host ""
                }
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
Write-Host "  1. Ensure chezmoi is initialized: chezmoi status" -ForegroundColor White
Write-Host "  2. Apply your dotfiles: chezmoi apply" -ForegroundColor White
Write-Host "  3. Launch WezTerm" -ForegroundColor White
if ($validDistros.Count -gt 0 -and -not $wslSetupSkipped) {
    Write-Host "  4. In WSL, run: p10k configure (first time only)" -ForegroundColor White
}
Write-Host ""

Stop-Transcript

#endregion
