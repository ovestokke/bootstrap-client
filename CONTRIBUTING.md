# Contributing & Code Style Guide

This document provides guidance for contributors and AI assistants (like Claude Code) when working with this repository.

---

## 📋 Project Overview

Cross-platform automation scripts for setting up development environments on Windows, macOS, and Linux. The scripts handle:
- OS configuration and privacy settings
- Bloatware removal (Windows)
- Application installation
- Terminal setup (WezTerm)
- Shell configuration (Zsh + Powerlevel10k)
- Modern CLI tools (eza, zoxide, chezmoi)
- Neovim/LazyVim setup
- GitHub SSH/GPG keys

---

## 🏗️ Architecture

### macOS Setup
1. **Essentials** (`macos/setup-essentials.sh`): Homebrew, Git, chezmoi initialization
2. **Terminal** (`macos/setup-terminal.sh`): WezTerm + Nerd fonts
3. **Shell** (`macos/setup-shell.sh`): Zsh + Powerlevel10k (Homebrew-based, no Oh My Zsh)
4. **Neovim** (`macos/setup-neovim.sh`): LazyVim + dependencies
5. **GitHub** (`macos/setup-github.sh`): SSH/GPG keys

### Windows Setup
1. **System** (`windows/Setup-Windows.ps1`): Bloatware removal, privacy, WSL, apps
2. **Essentials** (`windows/Setup-Essentials.ps1`): Git, chezmoi initialization
3. **Terminal** (`windows/Setup-Terminal.ps1`): WezTerm + Nerd fonts
4. **Shell** (`windows/Setup-Shell.ps1`): Zsh in WSL + chezmoi aliases
5. **Neovim** (`windows/Setup-Neovim.ps1`): LazyVim in WSL
6. **GitHub** (`windows/Setup-GitHub.ps1`): SSH/GPG keys
7. **PowerShell** (`windows/Setup-PowerShell.ps1`): PowerShell profile (optional)
8. **Komorebi** (`windows/Setup-Komorebi.ps1`): Tiling window manager (optional)

### Linux Setup
1. **Essentials** (`linux/setup-essentials.sh`): apt, Git, chezmoi initialization
2. **Shell** (`linux/setup-shell.sh`): Zsh + Powerlevel10k (Oh My Zsh-based)
3. **Neovim** (`linux/setup-neovim.sh`): LazyVim + dependencies
4. **GitHub** (`linux/setup-github.sh`): SSH/GPG keys

---

## 💻 Code Style

### PowerShell Scripts (.ps1)

**Header Format:**
```powershell
#
# Script Title
#
# @author: Ovestokke
# @version: X.X
#
# Usage comment (optional)
#
```

**Structure:**
- Use `#region Name` / `#endregion` for sections
- Common regions: Setup, Functions, Privacy, UI/UX, Developer, Cleanup

**Variables:**
- camelCase: `$bloatware`, `$appsToInstall`
- Arrays: `@()` syntax
- Check if empty: `[string]::IsNullOrEmpty($var)`

**Error Handling:**
- Use `try/catch` blocks
- Check `$LASTEXITCODE` after external commands
- Use `-ErrorAction Stop` or `SilentlyContinue`

**Admin Check:**
```powershell
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    exit 1
}
```

**Logging:**
```powershell
Start-Transcript -Path "Setup-Script-Log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt"
# ... script content ...
Stop-Transcript
```

**Output Functions:**
```powershell
function Write-Success { param([string]$Message); Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Fail { param([string]$Message); Write-Host "[FAIL] $Message" -ForegroundColor Red }
function Write-Skip { param([string]$Message); Write-Host "[SKIP] $Message" -ForegroundColor Yellow }
function Write-Info { param([string]$Message); Write-Host "→ $Message" -ForegroundColor Cyan }
```

**Winget Usage:**
```powershell
# Use exact IDs with -e flag
winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements

# Check exit codes
# 0 = success
# -1978335189 = already installed (not an error)

# NOTE: You can find the exact ID by running:
# winget search "Application Name"
```

**Registry Modifications:**
```powershell
# Always comment the purpose
# Disable telemetry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force
```

---

### Bash Scripts (.sh)

**Header Format:**
```bash
#!/bin/bash
#
# Script Title
#
# @author: Ovestokke
# @version: X.X
#
# Usage comment
#

set -e  # Exit on error
```

**Color Variables:**
```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
```

**Helper Functions:**
```bash
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_info() { echo -e "${CYAN}→${NC} $1"; }
print_header() { 
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
}
```

**Checks:**
```bash
# Check if command exists
if command -v git &> /dev/null; then
    print_success "Git is installed"
fi

# Check WSL environment
if grep -qi microsoft /proc/version 2>/dev/null; then
    print_info "Running in WSL"
fi

# Check if directory exists
if [[ -d "$HOME/.config/nvim" ]]; then
    print_warning "Directory already exists"
fi
```

**Variables:**
```bash
# UPPER_CASE for configuration
INSTALL_DIR="$HOME/.local"
REPO_URL="https://github.com/user/repo.git"

# Check if empty
if [[ -z "$VARIABLE" ]]; then
    print_error "Variable is empty"
fi
```

---

## 🧪 Testing Changes

### Windows
- Use Windows Sandbox or VM for testing
- Test PowerShell scripts as Administrator
- Create test WSL distribution: `wsl --install -d Ubuntu-Test`

### macOS
- Test on non-critical user account or VM
- Verify Homebrew installations work
- Check that dotfiles don't conflict

### Linux/WSL
- Use fresh VM or container
- Test on Ubuntu 20.04+ and Debian 10+
- Verify Oh My Zsh installations

---

## 🔧 Common Commands

### Running Scripts

**macOS:**
```bash
cd macos
bash setup-essentials.sh
bash setup-terminal.sh
bash setup-shell.sh
bash setup-neovim.sh
bash setup-github.sh
```

**Windows (PowerShell as Administrator):**
```powershell
cd windows
Set-ExecutionPolicy Unrestricted -Force
.\Setup-Windows.ps1
.\Setup-Essentials.ps1
.\Setup-Terminal.ps1
.\Setup-Shell.ps1
.\Setup-Neovim.ps1
.\Setup-GitHub.ps1
```

**Linux:**
```bash
cd linux
bash setup-essentials.sh
bash setup-shell.sh
bash setup-neovim.sh
bash setup-github.sh
```

### Finding Package IDs

**Windows (winget):**
```powershell
winget search "Visual Studio Code"
# Use exact ID: Microsoft.VisualStudioCode
```

**macOS (Homebrew):**
```bash
brew search neovim
brew info neovim
```

**Linux (apt):**
```bash
apt search neovim
apt-cache show neovim
```

---

## 📁 Key Files

### Configuration Files
- `.wezterm.lua` - WezTerm terminal config (cross-platform)
- `windows/Apps-List-Basic.txt` - Essential Windows apps (~15)
- `windows/Apps-List-Full.txt` - Complete Windows apps (~60+)
- `windows/Microsoft.PowerShell_profile.ps1` - PowerShell profile

### Utility Scripts
- `windows/Get-InstalledSoftware.ps1` - Inventory installed software
- `windows/Verify-WingetApps.ps1` - Verify app installations
- `linux/setup-wsl.sh` - Legacy WSL setup (deprecated)

### Documentation
- `README.md` - Main documentation
- `QUICK-REFERENCE.md` - Commands, tips, troubleshooting
- `Setup-LazyVim-README.md` - LazyVim detailed guide
- `Setup-Zsh-README.md` - Zsh detailed guide
- `SETUP-GUIDE.md` - Complete walkthrough

---

## 🎯 Implementation Details

### Application Installation

**Windows - winget:**
```powershell
# Always use exact IDs with -e flag
winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
```

**macOS - Homebrew:**
```bash
brew install neovim
brew install --cask wezterm
```

**Linux - apt:**
```bash
sudo apt update
sudo apt install -y neovim
```

### Zsh Configuration

**macOS (Homebrew-based, no Oh My Zsh):**
```bash
# Install via Homebrew
brew install powerlevel10k zsh-autosuggestions zsh-syntax-highlighting

# Source in .zshrc
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

**Linux/WSL (Oh My Zsh-based):**
```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Clone into custom directories
git clone https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

### Chezmoi Integration

**Initialize with dotfiles:**
```bash
# Interactive prompt in setup-essentials scripts
chezmoi init --apply https://github.com/username/dotfiles.git
```

**Aliases (added to .zshrc):**
```bash
# Ensure chezmoi is available
[[ $+commands[chezmoi] ]] || return 0

# Completion
source <(chezmoi completion zsh)

# Status
alias ch="chezmoi"
alias chd="chezmoi diff"
alias chst="chezmoi status"
alias chdoc="chezmoi doctor"

# Editing source
alias cha="chezmoi add"
alias chr="chezmoi re-add"
alias che="chezmoi edit"
alias chea="chezmoi edit --apply"
alias chcd="chezmoi cd"

# Updating target
alias chap="chezmoi apply"
alias chup="chezmoi update"
alias chug="chezmoi upgrade"
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Follow the code style guidelines
5. Submit a pull request with clear description

**For major changes:**
- Open an issue first to discuss
- Update relevant documentation
- Test on all platforms if possible

---

## 📖 References

- **WezTerm Config**: Based on [Josean's guide](https://www.josean.com/posts/how-to-setup-wezterm-terminal)
- **LazyVim**: https://www.lazyvim.org/
- **Oh My Zsh**: https://ohmyz.sh/
- **Powerlevel10k**: https://github.com/romkatv/powerlevel10k
- **chezmoi**: https://www.chezmoi.io/

---

**Happy coding! 🚀**
