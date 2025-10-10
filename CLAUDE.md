# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains cross-platform automation scripts for setting up development environments on Windows, macOS, and Linux. The scripts handle OS configuration, bloatware removal, privacy settings, application installation, terminal setup with Zsh/Powerlevel10k, and modern CLI tools.

## Architecture

### Windows Setup

1. **Windows Configuration** (`windows/Setup-Windows.ps1`): Runs on Windows host
   - Removes bloatware via AppxPackage removal
   - Configures privacy settings via registry modifications
   - Installs applications using winget with exact package IDs
   - Enables WSL and installs Ubuntu distribution
   - Must be run with elevated privileges (Administrator)

2. **WSL Zsh Setup** (`windows/Setup-Zsh-Windows.ps1` + `linux/Setup-Zsh-Linux.sh`): Configures Zsh inside WSL
   - PowerShell script detects WSL distributions and launches Linux setup script
   - Installs Zsh, Oh My Zsh, Powerlevel10k, and plugins
   - Configures modern CLI tools (eza, zoxide)

### macOS Setup

1. **WezTerm Setup** (`macos/Setup-WezTerm.sh`): Installs and configures WezTerm terminal
   - Installs WezTerm via Homebrew
   - Installs Meslo Nerd Font
   - Copies `.wezterm.lua` configuration

2. **Zsh Setup** (`macos/Setup-Zsh-macOS.sh`): Configures Zsh with Homebrew-based approach
   - Installs Powerlevel10k, plugins, and tools via Homebrew (no Oh My Zsh dependency)
   - Configures history search with arrow keys
   - Sources plugins directly in `.zshrc`

### Linux/Ubuntu Setup

1. **Zsh Setup** (`linux/Setup-Zsh-Linux.sh`): Configures Zsh with Oh My Zsh
   - Installs Oh My Zsh framework
   - Git clones Powerlevel10k and plugins into Oh My Zsh custom directories
   - Installs eza and zoxide with apt fallback to third-party repositories
   - Installs Meslo Nerd Font to `~/.local/share/fonts`

### Configuration Files

- `.wezterm.lua`: WezTerm terminal emulator configuration
  - Cross-platform keybindings (CMD on macOS, CTRL on Windows/Linux)
  - Vim-style pane navigation and splitting
  - Configurable color schemes

### Utility Scripts

- `windows/Get-InstalledSoftware.ps1`: Inventory script that exports currently installed software from both winget and Windows registry
- `windows/Setup-GitHubKeys.ps1` / `macos/Setup-GitHubKeys.sh`: Generate and upload SSH/GPG keys to GitHub
- `windows/Setup-WezTerm.ps1` / `macos/Setup-WezTerm.sh`: Install and configure WezTerm terminal

## Common Commands

### Running the Setup Scripts

**Windows Setup (PowerShell as Administrator):**
```powershell
Set-ExecutionPolicy Unrestricted -Force
.cd windows && .\Setup-Windows.ps1
```

**Windows/WSL Zsh Setup (PowerShell):**
```powershell
.\Setup-Zsh-Windows.ps1
```

**macOS Zsh Setup:**
```bash
bash Setup-Zsh-macOS.sh
```

**Linux/Ubuntu Zsh Setup:**
```bash
bash Setup-Zsh-Linux.sh
```

**Legacy WSL Setup (deprecated - use Setup-Zsh-Linux.sh instead):**
```bash
cd /mnt/c/path/to/this/directory
bash Setup-WSL.sh
```

**WezTerm Setup (macOS):**
```bash
bash Setup-WezTerm.sh
```

**WezTerm Setup (Windows, PowerShell as Administrator):**
```powershell
.\Setup-WezTerm.ps1
```

**Get Installed Software Inventory (Windows):**
```powershell
.\Get-InstalledSoftware.ps1
```

**GitHub Keys Setup:**
```powershell
# Windows
.\Setup-GitHubKeys.ps1
```
```bash
# Linux/macOS
bash Setup-GitHubKeys.sh
```

### Testing Changes

After modifying scripts, test in a safe environment:
- Use Windows Sandbox or VM for testing Windows PowerShell scripts
- Use a fresh WSL distribution for testing WSL scripts (create with `wsl --install -d Ubuntu-Test`)
- Test macOS scripts on a non-critical user account or VM

## Key Implementation Details

### Application Installation (Setup-Windows.ps1:101-133)

Uses winget with exact package IDs for reliability. Format: `winget install --id PackageID -e --accept-package-agreements --accept-source-agreements`

To find exact IDs: `winget search "Application Name"`

### Registry Modifications (Setup-Windows.ps1:51-78)

Privacy and UI/UX settings are applied via `Set-ItemProperty` to registry paths. Changes include:
- Telemetry: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection`
- File explorer: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`
- Developer mode: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock`

### Zsh Configuration (Cross-Platform)

**macOS Approach** (`macos/Setup-Zsh-macOS.sh`):
- Uses Homebrew for all installations (no Oh My Zsh dependency)
- Sources plugins directly in `.zshrc`: `source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh`
- Lighter and faster, easier to update with `brew upgrade`

**Linux/WSL Approach** (`linux/Setup-Zsh-Linux.sh`):
- Uses Oh My Zsh as plugin framework
- Git clones Powerlevel10k and plugins into Oh My Zsh custom directories:
  - Themes: `${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/`
  - Plugins: `${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/`
- Configuration automated via `sed` commands to modify `.zshrc`

**Unified Features** (all platforms):
- History configuration with arrow key search
- eza alias: `alias ls="eza --icons=always"`
- zoxide alias: `alias cd="z"`
- Same user experience across all platforms

**Reference Guide**: https://www.josean.com/posts/how-to-setup-wezterm-terminal
