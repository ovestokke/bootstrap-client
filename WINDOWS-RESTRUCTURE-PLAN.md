# Windows Restructure Implementation Plan

**Status:** Planning - To be implemented when Windows machine is available for testing

**Goal:** Apply same chezmoi-first approach from macOS to Windows, while maintaining gaming support.

---

## 📊 Current State Analysis

### Existing Files (2,633 lines)
```
windows/
├── setup-windows.ps1 (615 lines)           - System + bloatware + WSL + apps
├── setup-wezterm.ps1 (185 lines)           - Installs + COPIES .wezterm.lua ❌
├── setup-zsh-windows.ps1 (225 lines)       - WSL wrapper
├── setup-github-keys.ps1 (408 lines)       - Generates SSH/GPG keys
├── Setup-PowerShell.ps1 (454 lines)        - PowerShell profile setup
├── Setup-Komorebi.ps1 (294 lines)          - Tiling WM (optional)
├── Apps-List-Basic.txt (23 lines)          - 10 essential apps
├── Apps-List-Full.txt (84 lines)           - Gaming + Dev + Productivity
├── Get-InstalledSoftware.ps1 (131 lines)   - Utility
├── Verify-WingetApps.ps1 (76 lines)        - Utility
└── Microsoft.PowerShell_profile.ps1        - PowerShell profile
```

### Gaming-Specific Features (KEEP!)
- ✅ NVIDIA App auto-install with GPU detection
- ✅ Steam, Epic Games, EA Desktop
- ✅ Logitech G HUB (peripherals)
- ✅ System monitoring tools (HWiNFO, CPU-Z, GPU-Z)
- ✅ Komorebi tiling WM with game workspace rules
- ✅ Discord for gaming communication

### Problems to Fix
- ❌ `setup-wezterm.ps1` copies `.wezterm.lua` from repo (lines 147, 155)
- ❌ No chezmoi integration
- ❌ `setup-github-keys.ps1` generates keys (should be per-machine/manual)
- ❌ Configs scattered across scripts
- ❌ No unified workflow with macOS/Linux

---

## 🎯 Target Structure

### New File Organization
```
windows/
├── Setup-Essentials.ps1        # NEW: winget, git, chezmoi (init dotfiles)
├── Setup-System.ps1            # RENAMED: setup-windows.ps1 (bloatware, WSL, apps)
├── Setup-Packages.ps1          # NEW: Install all tools (WezTerm, dev tools) - NO CONFIG
├── Setup-PowerShell.ps1        # KEEP: PowerShell profile (optional)
├── Setup-Komorebi.ps1          # KEEP: Tiling WM (optional)
│
├── Apps-List-Basic.txt         # KEEP: 10 essential apps
├── Apps-List-Gaming.txt        # NEW: Gaming-specific apps
├── Apps-List-Full.txt          # UPDATE: Reference to other lists
│
├── Utilities/                  # NEW: Organize utility scripts
│   ├── Get-InstalledSoftware.ps1
│   ├── Verify-WingetApps.ps1
│   └── Microsoft.PowerShell_profile.ps1
│
└── README.md                   # UPDATE: New workflow
```

### Files to DELETE
- ❌ `setup-wezterm.ps1` (functionality moved to Setup-Packages.ps1)
- ❌ `setup-zsh-windows.ps1` (functionality moved to Setup-Packages.ps1)
- ❌ `setup-github-keys.ps1` (keys are per-machine, not in bootstrap)
- ❌ `APPS-COMPARISON.md` (outdated?)
- ❌ `Komorebi-Game-Workspaces.md` (move content to Setup-Komorebi.ps1 comments)

---

## 📝 Script Specifications

### 1. Setup-Essentials.ps1 (NEW)

**Purpose:** Install foundational tools only

**Actions:**
```powershell
# Check Administrator privileges
# Verify winget is available and up to date
# Install/verify Git via winget
# Install chezmoi via winget
#   winget install --id twpayne.chezmoi -e
# 
# Interactive chezmoi initialization:
#   Prompt: "Initialize chezmoi with your dotfiles repository?"
#   Default: https://github.com/ovestokke/dotfiles.git
#   Command: chezmoi init --apply <repo-url>
#
# If chezmoi already initialized:
#   Detect: Test-Path "$env:USERPROFILE\.local\share\chezmoi"
#   Prompt: "Re-initialize with different repository? (y/N)"
#   Action: Backup existing, then re-init
```

**Does NOT:**
- ❌ Install applications
- ❌ Configure system settings
- ❌ Copy any config files
- ❌ Generate SSH/GPG keys

**Time:** 3-5 minutes

---

### 2. Setup-System.ps1 (RENAME from setup-windows.ps1)

**Purpose:** Windows system configuration and application installation

**Changes from current setup-windows.ps1:**
```powershell
# KEEP all current functionality:
✅ Computer hostname configuration
✅ System Restore
✅ Remove bloatware (Cortana, Office Hub, etc.)
✅ Privacy settings (telemetry, web search)
✅ UI/UX (file extensions, hidden files)
✅ Developer Mode
✅ WSL + Ubuntu installation
✅ NVIDIA App with GPU detection (KEEP AS-IS - IT'S PERFECT!)

# UPDATE app installation modes:
Old:
  [1] Skip
  [2] Basic (15 apps)
  [3] Full (60+ apps)

New:
  [1] Skip - System setup only
  [2] Basic - Essential apps (Apps-List-Basic.txt)
  [3] Gaming - Gaming platforms + peripherals (Apps-List-Gaming.txt)
  [4] Developer - Dev tools only (extract from Full)
  [5] Full - Everything (Basic + Gaming + Dev)
```

**NVIDIA App Section (KEEP EXACTLY AS-IS):**
- GPU detection works perfectly
- Auto-scrapes latest download URL
- Graceful fallback to manual download
- This is gaming-critical, don't touch!

**Time:** 30-45 minutes

---

### 3. Setup-Packages.ps1 (NEW)

**Purpose:** Install all development tools (NO configuration)

**Installs:**

```powershell
#region Terminal
# WezTerm via winget
#   winget install --id wez.wezterm -e
# 
# Meslo Nerd Font
#   Download and install to Windows Fonts
#   NOTE: Do NOT copy .wezterm.lua! chezmoi manages it!
#endregion

#region WSL Tools Detection
# Detect WSL distributions
#   wsl --list --verbose
# 
# For each WSL distro, install:
#   - Zsh (apt install zsh)
#   - Oh My Zsh (curl install script)
#   - Powerlevel10k (git clone to Oh My Zsh themes)
#   - zsh-autosuggestions (git clone to plugins)
#   - zsh-syntax-highlighting (git clone to plugins)
#   - eza (apt or third-party repo)
#   - zoxide (apt or curl install)
#   - Meslo Nerd Font (to ~/.local/share/fonts)
#
# NOTE: Do NOT modify .zshrc! chezmoi manages it!
#endregion

#region Neovim in WSL
# For each WSL distro:
#   - Add Neovim unstable PPA (for latest version)
#   - Install neovim via apt
#   - Install dependencies: lazygit, ripgrep, fd-find, fzf
#   - Install build-essential (for Treesitter)
#
# NOTE: Do NOT install LazyVim! chezmoi manages ~/.config/nvim/
#endregion

#region Git Tools (Windows)
# Install via winget:
#   - GitHub CLI (gh)
#   - GnuPG / Gpg4win (for commit signing)
#
# NOTE: Do NOT generate SSH/GPG keys! Per-machine task!
#endregion

#region WSL-Specific Tools (Optional)
# Check if 1Password SSH agent bridge is needed
#   Prompt: "Set up 1Password SSH agent bridge for WSL?"
#   If yes: Install socat, npiperelay
#   
# Note: Actual SSH agent config in chezmoi dotfiles (.zshrc.tmpl)
#endregion
```

**Does NOT:**
- ❌ Copy .wezterm.lua
- ❌ Modify .zshrc
- ❌ Create Neovim config
- ❌ Generate SSH/GPG keys
- ❌ Configure Git

**Output:**
```
✓ WezTerm installed
✓ Meslo Nerd Font installed
✓ WSL (Ubuntu): Zsh + Oh My Zsh + plugins installed
✓ WSL (Ubuntu): eza, zoxide, fzf, ripgrep installed
✓ WSL (Ubuntu): Neovim + dependencies installed
✓ GitHub CLI (gh) installed
✓ GPG installed

⚠ IMPORTANT: Configuration is managed by chezmoi

Next steps:
  1. Ensure chezmoi is initialized: chezmoi status
  2. Apply your dotfiles: chezmoi apply
  3. Launch WezTerm
  4. In WSL, run: p10k configure (first time only)
```

**Time:** 15-20 minutes

---

### 4. Setup-PowerShell.ps1 (KEEP - OPTIONAL)

**Current functionality:**
- Installs Oh My Posh
- Installs PSReadLine
- Installs Terminal-Icons
- Creates PowerShell profile

**Decision:** Keep as optional script

**Reason:** 
- Some users prefer native PowerShell over WSL
- Gaming launchers often use PowerShell
- Useful for quick Windows admin tasks

**Note:** If user wants to manage PowerShell profile via chezmoi:
- Add to dotfiles: `Documents/PowerShell/Microsoft.PowerShell_profile.ps1`
- Make Setup-PowerShell.ps1 install-only (no profile creation)

---

### 5. Setup-Komorebi.ps1 (KEEP - OPTIONAL)

**Current functionality:** Perfect as-is!
- Installs Komorebi + whkd via winget
- Generates default config
- Sets up autostart
- Documents keybindings

**Gaming enhancement:**
- Keep Komorebi-Game-Workspaces.md content
- Move it into Setup-Komorebi.ps1 as comments/examples
- Or create: `windows/Komorebi/README.md`

**Why keep for gaming:**
- Multi-monitor gaming setups benefit from tiling
- Game-specific workspace rules
- Quick window management for Discord/browser/game

---

## 📋 App List Reorganization

### Apps-List-Basic.txt (UPDATE)
```txt
# Essential applications - Minimal setup
# ~10 apps, cross-platform tools only

# Browsers
Mozilla.Firefox

# Development - Core
Git.Git
GitHub.cli
Microsoft.VisualStudioCode

# Terminal
Microsoft.WindowsTerminal
Microsoft.PowerShell

# Utilities
7zip.7zip

# Privacy
OO-Software.ShutUp10
```

### Apps-List-Gaming.txt (NEW)
```txt
# Gaming-specific applications
# Platforms, peripherals, monitoring

# Gaming Platforms
Valve.Steam
EpicGames.EpicGamesLauncher
ElectronicArts.EADesktop

# Gaming Peripherals
Logitech.GHUB

# System Monitoring (crucial for gaming)
REALiX.HWiNFO
CPUID.CPU-Z
TechPowerUp.GPU-Z

# Window Management
LGUG2Z.komorebi
LGUG2Z.whkd

# Communication
Discord.Discord

# Media
VideoLAN.VLC

# Note: NVIDIA App installed separately by Setup-System.ps1
```

### Apps-List-Developer.txt (NEW)
```txt
# Development tools (extract from Full)

# Version Control
Git.Git
GitHub.GitHubDesktop
GitHub.cli

# Editors & IDEs
Microsoft.VisualStudioCode

# Terminals
Microsoft.WindowsTerminal
wez.wezterm
Microsoft.PowerShell

# Languages & Runtimes
OpenJS.NodeJS.LTS
Python.Python.3.12

# Containers
Docker.DockerDesktop

# Cloud & DevOps
Microsoft.AzureCLI
Google.CloudSDK
Hashicorp.Terraform
Tailscale.Tailscale

# AI Tools
Anthropic.Claude
Anthropic.ClaudeCode
SST.opencode

# Utilities
sharkdp.bat
GnuPG.GnuPG
GnuPG.Gpg4win
```

### Apps-List-Productivity.txt (NEW)
```txt
# Productivity & Communication

# Productivity
AgileBits.1Password
Obsidian.Obsidian
Microsoft.PowerToys
Flow-Launcher.Flow-Launcher

# Communication
SlackTechnologies.Slack
Discord.Discord
OpenWhisperSystems.Signal

# File Management
Google.GoogleDrive
BillStewart.SyncthingWindowsSetup

# Media
VideoLAN.VLC
TIDALMusicAS.TIDAL

# Utilities
JAMSoftware.TreeSize.Free
Klocman.BulkCrapUninstaller
BleachBit.BleachBit
```

### Apps-List-Full.txt (UPDATE)
```txt
# Complete installation
# This installs ALL app lists combined

# NOTE: This file references other lists
# The Setup-System.ps1 script will install:
#   - Apps-List-Basic.txt
#   - Apps-List-Gaming.txt
#   - Apps-List-Developer.txt
#   - Apps-List-Productivity.txt

# To customize, edit the individual list files
```

---

## 🔄 Updated Workflow

### init-windows.ps1 Changes

**Add smart repo detection (mirror macOS):**
```powershell
# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check if running from git repository
if (Test-Path (Join-Path $scriptDir ".git")) {
    Write-Host "✓ Running from repository: $scriptDir" -ForegroundColor Green
    
    # Check if it's bootstrap-client
    Push-Location $scriptDir
    $remote = git remote get-url origin 2>$null
    Pop-Location
    
    if ($remote -like "*bootstrap-client*") {
        Write-Host "✓ Confirmed: bootstrap-client repository" -ForegroundColor Green
        
        $pull = Read-Host "Pull latest changes? (Y/n)"
        if ($pull -ne "n" -and $pull -ne "N") {
            Push-Location $scriptDir
            git pull
            Pop-Location
        }
        
        $cloneLocation = $scriptDir
    }
}

# If not in repo, proceed with clone logic...
```

**Update menu:**
```powershell
Write-Host "Setup workflow:" -ForegroundColor Cyan
Write-Host "  1. Setup-System.ps1      → Bloatware, privacy, WSL, apps" -ForegroundColor White
Write-Host "  2. Setup-Essentials.ps1  → Git + chezmoi (init dotfiles)" -ForegroundColor White
Write-Host "  3. Setup-Packages.ps1    → All tools (WezTerm, Neovim, etc.)" -ForegroundColor White
Write-Host "  4. chezmoi apply         → Apply your dotfiles" -ForegroundColor White
Write-Host "  5. Setup-PowerShell.ps1  → PowerShell profile (optional)" -ForegroundColor White
Write-Host "  6. Setup-Komorebi.ps1    → Tiling WM (optional)" -ForegroundColor White
Write-Host "  7. Run core setup        → 1→2→3→4 automated" -ForegroundColor White
Write-Host ""

$choice = Read-Host "What would you like to do? (1-7 or skip)"

switch ($choice) {
    "1" { & "$cloneLocation\windows\Setup-System.ps1" }
    "2" { & "$cloneLocation\windows\Setup-Essentials.ps1" }
    "3" { & "$cloneLocation\windows\Setup-Packages.ps1" }
    "4" { 
        if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
            chezmoi apply
        } else {
            Write-Host "✗ chezmoi not found. Run Setup-Essentials.ps1 first." -ForegroundColor Red
        }
    }
    "5" { & "$cloneLocation\windows\Setup-PowerShell.ps1" }
    "6" { & "$cloneLocation\windows\Setup-Komorebi.ps1" }
    "7" {
        & "$cloneLocation\windows\Setup-System.ps1"
        & "$cloneLocation\windows\Setup-Essentials.ps1"
        & "$cloneLocation\windows\Setup-Packages.ps1"
        
        if (Get-Command chezmoi -ErrorAction SilentlyContinue) {
            chezmoi apply
            Write-Host "✓ Setup complete!" -ForegroundColor Green
        }
    }
    default {
        Write-Host "Manual setup:" -ForegroundColor Yellow
        Write-Host "  cd $cloneLocation\windows"
        Write-Host "  .\Setup-System.ps1"
        Write-Host "  .\Setup-Essentials.ps1"
        Write-Host "  .\Setup-Packages.ps1"
        Write-Host "  chezmoi apply"
    }
}
```

---

## 📦 chezmoi Dotfiles Structure (Windows)

Your dotfiles repo should include:

```
~/.local/share/chezmoi/
├── dot_wezterm.lua                    # Terminal config (cross-platform)
│   OR
├── dot_wezterm.lua.tmpl               # If OS-specific customization needed
│
├── dot_zshrc.tmpl                     # With WSL detection for 1Password SSH
│   {{- if eq .chezmoi.os "linux" }}
│   if grep -qi microsoft /proc/version 2>/dev/null; then
│       # WSL-specific: 1Password SSH agent bridge
│       export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
│   fi
│   {{- end }}
│
├── dot_zprofile                       # Shell profile
├── dot_p10k.zsh                       # Powerlevel10k theme config
│
├── private_dot_gitconfig.tmpl         # Git config with OS detection
│   [user]
│       name = Your Name
│       email = {{ .email }}
│   [core]
│   {{- if eq .chezmoi.os "windows" }}
│       autocrlf = true
│   {{- else }}
│       autocrlf = input
│   {{- end }}
│
├── dot_config/
│   ├── nvim/                          # Neovim/LazyVim (cross-platform)
│   └── opencode/                      # OpenCode settings
│
└── Documents/PowerShell/              # Windows-specific (if managing)
    └── Microsoft.PowerShell_profile.ps1
```

---

## ⚡ Key Improvements Summary

### Philosophy Change
**Before:**
- Scripts install AND configure
- Configs scattered across multiple scripts
- No chezmoi integration
- Different workflow from macOS/Linux

**After:**
- Scripts ONLY install packages
- chezmoi manages ALL configs
- Single source of truth (dotfiles)
- Unified workflow across all platforms

### Benefits
1. **Consistency:** Same workflow as macOS/Linux
2. **Portability:** Dotfiles work across machines
3. **Gaming Support:** All gaming features maintained
4. **Idempotent:** Safe to re-run scripts
5. **Flexibility:** Gaming-only, Dev-only, or Full install modes

### Time Estimates
- Skip apps: ~45 min (system only)
- Basic: ~1 hour (essential apps)
- Gaming: ~1.5 hours (gaming + essentials)
- Developer: ~1.5 hours (dev + essentials)
- Full: ~2 hours (everything)

---

## ✅ Implementation Checklist

### Phase 1: Preparation (Read-only)
- [x] Analyze current Windows scripts
- [x] Identify gaming-specific features to preserve
- [x] Design new structure
- [x] Create implementation plan
- [ ] Review plan on Windows machine

### Phase 2: Create New Scripts
- [ ] Create `Setup-Essentials.ps1`
  - [ ] winget verification
  - [ ] Git installation
  - [ ] chezmoi installation
  - [ ] chezmoi init prompt
  - [ ] Test on Windows

- [ ] Create `Setup-Packages.ps1`
  - [ ] WezTerm installation (NO CONFIG COPY!)
  - [ ] Meslo Nerd Font installation
  - [ ] WSL detection and tool installation
  - [ ] Neovim + dependencies in WSL
  - [ ] Git tools (gh, GPG)
  - [ ] 1Password SSH bridge prompt
  - [ ] Test on Windows + WSL

- [ ] Rename `setup-windows.ps1` → `Setup-System.ps1`
  - [ ] Keep all current functionality
  - [ ] Update app installation modes (4 options)
  - [ ] Test NVIDIA App detection
  - [ ] Test on Windows

### Phase 3: App List Reorganization
- [ ] Create `Apps-List-Gaming.txt`
- [ ] Create `Apps-List-Developer.txt`
- [ ] Create `Apps-List-Productivity.txt`
- [ ] Update `Apps-List-Basic.txt`
- [ ] Update `Apps-List-Full.txt` (reference to others)
- [ ] Update `Setup-System.ps1` to handle new lists

### Phase 4: Update Existing Scripts
- [ ] Update `init-windows.ps1`
  - [ ] Add smart repo detection
  - [ ] Update menu with new options
  - [ ] Test from repo
  - [ ] Test as one-liner

- [ ] Review `Setup-PowerShell.ps1`
  - [ ] Keep as optional
  - [ ] Document chezmoi alternative

- [ ] Review `Setup-Komorebi.ps1`
  - [ ] Keep as optional
  - [ ] Move/integrate Komorebi-Game-Workspaces.md

### Phase 5: Cleanup
- [ ] Delete obsolete scripts
  - [ ] setup-wezterm.ps1
  - [ ] setup-zsh-windows.ps1
  - [ ] setup-github-keys.ps1

- [ ] Organize utilities
  - [ ] Create `Utilities/` folder
  - [ ] Move utility scripts
  - [ ] Update paths in documentation

- [ ] Clean up documentation
  - [ ] Delete APPS-COMPARISON.md (if outdated)
  - [ ] Move Komorebi-Game-Workspaces.md content

### Phase 6: Documentation
- [ ] Update `windows/README.md`
  - [ ] New philosophy section
  - [ ] Script descriptions
  - [ ] Gaming features highlighted
  - [ ] Workflow examples

- [ ] Update main `README.md`
  - [ ] Windows workflow section
  - [ ] Gaming support mention

- [ ] Add idempotency section
  - [ ] Safe to re-run
  - [ ] What gets checked vs installed

### Phase 7: Testing
- [ ] Test on fresh Windows 11 install
  - [ ] Run init-windows.ps1 one-liner
  - [ ] Test each script individually
  - [ ] Test "Run core setup" option
  - [ ] Verify chezmoi applies configs
  - [ ] Test Gaming mode
  - [ ] Test NVIDIA App detection

- [ ] Test on existing Windows setup
  - [ ] Run from cloned repo
  - [ ] Verify idempotency
  - [ ] Check git pull detection

- [ ] Test WSL integration
  - [ ] Zsh installation
  - [ ] Plugin installation
  - [ ] Neovim installation
  - [ ] chezmoi dotfile application
  - [ ] 1Password SSH agent bridge (if applicable)

- [ ] Test Gaming-specific
  - [ ] NVIDIA App auto-install
  - [ ] Gaming app list
  - [ ] Komorebi installation
  - [ ] Multi-monitor setup

### Phase 8: Finalization
- [ ] Commit all changes
- [ ] Update version numbers
- [ ] Create release notes
- [ ] Test one-liner from GitHub

---

## 🎮 Gaming-Specific Notes

### What Makes Windows Gaming Special
1. **NVIDIA Drivers:** Direct GPU access, no WSL overhead
2. **Game Launchers:** Native Windows apps (Steam, Epic, etc.)
3. **Peripherals:** Logitech G HUB, RGB software
4. **Performance Monitoring:** HWiNFO, GPU-Z for FPS/temps
5. **Multi-Monitor:** Komorebi for window management

### Dev + Gaming Coexistence
- **Windows:** Gaming, NVIDIA drivers, native apps
- **WSL:** Dev tools, Zsh, Neovim (lightweight, no overhead)
- **chezmoi:** Manages configs for both environments
- **Benefit:** Best of both worlds!

### Gaming Mode Install
When user chooses "Gaming" mode:
1. Install gaming platforms (Steam, Epic, EA)
2. Install peripherals (G HUB)
3. Install monitoring (HWiNFO, GPU-Z)
4. Prompt for NVIDIA App (if NVIDIA GPU detected)
5. Optionally install Komorebi
6. Skip heavy dev tools (Docker, Node, Python, etc.)

**Result:** Lean gaming setup, can add dev tools later with Setup-Packages.ps1

---

## 📝 Notes for Implementation

### Test Environment Needed
- Windows 11 machine (or VM)
- NVIDIA GPU (optional, for NVIDIA App testing)
- WSL Ubuntu installed
- Internet connection

### Dependencies
- winget (built into Windows 11)
- PowerShell 5.1+ (built into Windows)
- Administrator privileges

### Testing Strategy
1. **VM Snapshot:** Take snapshot before testing
2. **Test Scripts:** Run each script individually
3. **Verify Output:** Check installations succeeded
4. **Test chezmoi:** Verify dotfiles applied correctly
5. **Rollback:** Restore snapshot between tests

### WSL 1Password SSH Agent
**Complex topic - needs testing:**
- Multiple approaches (npiperelay, socat, wsl-ssh-agent)
- Depends on 1Password version
- May need to test different solutions
- Document working solution in dotfiles repo

---

## 🚀 When Ready to Implement

1. Review this plan on Windows machine
2. Take Windows VM snapshot (for testing)
3. Start with Phase 2 (Create New Scripts)
4. Test each script individually
5. Update dotfiles repo with Windows configs
6. Test complete workflow end-to-end
7. Document any issues or changes needed
8. Update this plan based on testing

---

**Created:** October 2025  
**Status:** Planning phase - awaiting Windows machine for implementation  
**Related:** macOS restructure completed, Linux restructure planned
