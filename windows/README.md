# Windows Setup Scripts

PowerShell scripts for Windows 11 fresh installation setup.

## Quick Start

### Option 1: Interactive Menu (Recommended)

Run the initialization script from the repository root:

```powershell
# Open PowerShell as Administrator
Set-ExecutionPolicy Unrestricted -Force
cd D:\Github\bootstrap-client
.\init-windows.ps1
```

The interactive menu offers:
1. **System cleanup** - Remove bloatware, configure privacy, enable WSL
2. **Install apps** - Choose categories (Basic/Gaming/Developer/Full)
3. **Setup essentials** - Install Git + chezmoi, initialize dotfiles
4. **Install packages** - Dev tools (WezTerm, Neovim, etc.)
5. **Apply dotfiles** - Run chezmoi apply
6. **PowerShell profile** - Configure PowerShell (optional)
7. **Komorebi WM** - Install tiling window manager (optional)
8. **Run full workflow** - Automated setup (steps 1→2→3→4→5)

### Option 2: Manual Execution

Run scripts individually from the `windows/` directory:

```powershell
cd D:\Github\bootstrap-client\windows

# Step 1: System cleanup
.\Setup-System.ps1

# Step 2: Install applications
.\Setup-Apps.ps1

# Step 3: Install essentials (Git + chezmoi)
.\Setup-Essentials.ps1

# Step 4: Install development tools
.\Setup-Packages.ps1

# Step 5: Apply dotfiles
chezmoi apply

# Optional: PowerShell customization
.\Setup-PowerShell.ps1

# Optional: Tiling window manager
.\Setup-Komorebi.ps1
```

---

## Core Scripts

### Setup-System.ps1
**System cleanup and configuration**

- Removes bloatware (Cortana, Office Hub, OneDrive, etc.)
- Configures privacy settings (disable telemetry)
- Configures UI/UX (show file extensions, hidden files)
- Enables Developer Mode
- Installs WSL with Ubuntu
- Creates system restore point
- Detects and installs NVIDIA App if NVIDIA GPU present

**Does NOT install applications** - Use Setup-Apps.ps1 for that.

**Time:** 15-20 minutes

---

### Setup-Apps.ps1
**Application installation with category selection**

Choose your installation mode:
- **Skip** - No apps (exit)
- **Basic** - Essential apps (~10 apps from `Apps-List-Basic.txt`)
- **Gaming** - Basic + Gaming platforms, peripherals, monitoring
- **Developer** - Basic + Development tools
- **Full** - Everything (Basic + Gaming + Developer + Productivity)

**Does NOT configure tools** - Configuration is managed by chezmoi.

**Time:** 20-45 minutes (depends on mode)

---

### Setup-Essentials.ps1
**Git and chezmoi installation**

- Verifies/installs winget
- Installs Git if not present
- Installs chezmoi via winget
- Optionally initializes chezmoi with your dotfiles repository

**Does NOT copy configs** - Use `chezmoi apply` after initialization.

**Time:** 5-10 minutes

---

### Setup-Packages.ps1
**Development tools and packages**

Installs:
- **WezTerm** terminal emulator
- **Meslo Nerd Font**
- **Zsh + Oh My Zsh + Powerlevel10k** in WSL
- **Modern CLI tools** (eza, zoxide, fzf, ripgrep, bat, fd)
- **Neovim + dependencies** in WSL (LazyVim ready)

**Configuration managed by chezmoi** - This script only installs packages.

**Time:** 15-25 minutes

---

### Setup-PowerShell.ps1
**PowerShell profile and Oh My Posh** (Optional)

- Installs Oh My Posh
- Installs Nerd Fonts
- Sets up PowerShell profile with custom prompt

**Only run if NOT using chezmoi** for PowerShell configuration.

**Time:** 5 minutes

---

### Setup-Komorebi.ps1
**Tiling window manager** (Optional)

- Installs komorebi tiling window manager
- Installs whkd (Windows hotkey daemon)
- Configures autostart

**Configuration managed by chezmoi** - This script only installs komorebi.

**Time:** 5 minutes

---

## Utility Scripts

### setup-github-keys.ps1
Generates and uploads SSH/GPG keys to GitHub.

- Generates SSH ed25519 key
- Generates GPG 4096-bit RSA key
- Configures Git to auto-sign commits
- Uploads keys to GitHub via `gh` CLI

**Prerequisites:** Git, GitHub CLI, GPG installed

**Time:** 10 minutes

---

### Get-InstalledSoftware.ps1
Inventory installed software.

Exports list of installed software from both winget and Windows registry to:
- `InstalledSoftware.log` (formatted report)
- `InstalledSoftware.csv` (spreadsheet format)

---

### Verify-WingetApps.ps1
Verify winget package IDs before installation.

---

## Application Lists

**📋 See [APPS-COMPARISON.md](APPS-COMPARISON.md) for detailed comparison and customization guide**

### Apps-List-Basic.txt
**Essential applications** (~10 apps) - Included in ALL modes

- Browsers (Firefox)
- Core dev tools (Git, VS Code, GitHub CLI)
- Terminals (Windows Terminal, PowerShell)
- Password management (1Password)
- Utilities (7zip)
- Privacy (O&O ShutUp10)

### Apps-List-Developer.txt
**Development tools** - Used in Developer and Full modes

- Languages & Runtimes (Node.js, Python)
- Containers (Docker)
- Cloud & DevOps (Azure CLI, Google Cloud SDK, Terraform, Tailscale)
- AI Development (Claude, Claude Code, opencode)
- Neovim dependencies (in addition to Setup-Packages.ps1)

### Apps-List-Gaming.txt
**Gaming and peripherals** - Used in Gaming and Full modes

- Gaming platforms (Steam, Epic Games, EA Desktop)
- Peripherals (Logitech G HUB)
- System monitoring (HWiNFO, CPU-Z, GPU-Z)
- Window management (Komorebi, whkd)
- Communication (Discord)
- Media (VLC)

### Apps-List-Productivity.txt
**Productivity and communication** - Used in Full mode only

- Additional browsers (Chrome)
- Productivity (Obsidian, PowerToys, Flow Launcher)
- Communication (Slack, Signal)
- File sync (Google Drive, Syncthing)
- Media (TIDAL)
- Advanced utilities (BulkCrapUninstaller, BleachBit, TreeSize)

### Apps-List-Full.txt (Deprecated)
Old monolithic list. Now uses the 4 category files above.

---

## Customization

**Format:**
- One package ID per line
- Lines starting with `#` are comments
- Find package IDs: `winget search "Application Name"`

**To customize:**
1. Edit the appropriate `Apps-List-*.txt` file
2. Run `.\Setup-Apps.ps1` and choose your mode
3. Or choose "Skip" and install apps manually later

---

## Recommended Workflow

### Full Setup (Automated)
```powershell
.\init-windows.ps1
# Choose option [8] - Run full workflow
```

### Manual Step-by-Step
```powershell
.\Setup-System.ps1       # 1. System cleanup
.\Setup-Apps.ps1         # 2. Install apps (choose mode)
# Reboot if prompted (WSL installation)
.\Setup-Essentials.ps1   # 3. Git + chezmoi
.\Setup-Packages.ps1     # 4. Dev tools
chezmoi apply            # 5. Apply dotfiles
.\setup-github-keys.ps1  # 6. GitHub keys (optional)
```

**Total time:** 1-2 hours (mostly automated)

---

## Complementary Tools (Optional)

### Chris Titus Tech WinUtil
A GUI-driven Windows optimization and debloat utility. Use it AFTER running `Setup-System.ps1` if you want to:
- Inspect/disable additional services & scheduled tasks
- Apply granular privacy toggles beyond this repo's curated baseline
- Audit/remove remaining Microsoft Store apps
- Explore optional tweaks (context menu, UI, cleanup)

Launch (PowerShell as Administrator):
```powershell
irm "https://christitus.com/win" | iex
```

**Guidelines:**
- Create a restore point before large tweak batches
- Avoid blindly selecting all debloat options
- Skip duplicate actions already automated here (telemetry baseline, Cortana removal)
- Log/manual note any changes for reproducibility

---

## Architecture

**Key improvements in v2.0:**
- **Modular design** - Each script has a single, clear purpose
- **Flexibility** - Run only what you need, when you need it
- **Category-based apps** - Install apps by category (Gaming, Developer, etc.)
- **Dotfiles-first** - Configuration managed by chezmoi, not scripts
- **Clear naming** - Actions, not just filenames

---

## See Also

- `../SETUP-GUIDE.md` - Complete setup guide with detailed instructions
- `../Setup-Zsh-README.md` - Detailed Zsh setup documentation
- `../.wezterm.lua` - WezTerm configuration file
- `../linux/` - Linux/WSL scripts
- `../macos/` - macOS scripts
