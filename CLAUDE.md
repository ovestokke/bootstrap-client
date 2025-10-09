# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains automation scripts for setting up a fresh Windows installation with WSL Ubuntu. The scripts handle Windows configuration, bloatware removal, privacy settings, application installation via winget, and WSL Ubuntu environment setup with Zsh, Oh My Zsh, and modern CLI tools.

## Architecture

### Two-Phase Setup Process

1. **Windows Setup** (`Setup-Windows.ps1`): Runs on Windows host
   - Removes bloatware via AppxPackage removal
   - Configures privacy settings via registry modifications
   - Installs applications using winget with exact package IDs
   - Enables WSL and installs Ubuntu distribution
   - Must be run with elevated privileges (Administrator)

2. **WSL Setup** (`Setup-WSL.sh`): Runs inside WSL Ubuntu
   - Installs Zsh with Oh My Zsh framework
   - Configures Powerlevel10k theme
   - Installs modern CLI tools (eza, zoxide)
   - Sets up Meslo Nerd Font for terminal icons
   - Modifies .zshrc for plugin and tool configuration

### Configuration Files

- `wezterm.lua`: WezTerm terminal emulator configuration
  - Custom "coolnight" color scheme
  - Keybindings for pane management (CMD+d for horizontal split, CMD+SHIFT+d for vertical split)
  - Should be placed in `%USERPROFILE%\.wezterm.lua` on Windows

### Utility Scripts

- `Get-InstalledSoftware.ps1`: Inventory script that exports currently installed software from both winget and Windows registry to `InstalledSoftware.txt`

## Common Commands

### Running the Setup Scripts

**Windows Setup (PowerShell as Administrator):**
```powershell
Set-ExecutionPolicy Unrestricted -Force
.\Setup-Windows.ps1
```

**WSL Setup (inside WSL Ubuntu):**
```bash
cd /mnt/c/path/to/this/directory
bash Setup-WSL.sh
```

**Get Installed Software Inventory:**
```powershell
.\Get-InstalledSoftware.ps1
```

### Testing Changes

After modifying scripts, test in a safe environment:
- Use Windows Sandbox or VM for testing `Setup-Windows.ps1`
- Use a fresh WSL distribution for testing `Setup-WSL.sh` (create with `wsl --install -d Ubuntu-Test`)

## Key Implementation Details

### Application Installation (Setup-Windows.ps1:101-133)

Uses winget with exact package IDs for reliability. Format: `winget install --id PackageID -e --accept-package-agreements --accept-source-agreements`

To find exact IDs: `winget search "Application Name"`

### Registry Modifications (Setup-Windows.ps1:51-78)

Privacy and UI/UX settings are applied via `Set-ItemProperty` to registry paths. Changes include:
- Telemetry: `HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection`
- File explorer: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`
- Developer mode: `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock`

### WSL Configuration (Setup-WSL.sh:20-72)

Zsh plugins and tools are installed to Oh My Zsh custom directories:
- Themes: `${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/`
- Plugins: `${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/`

Configuration is automated via `sed` commands to modify `.zshrc`
