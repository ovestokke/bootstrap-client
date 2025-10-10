# Windows Setup Scripts

PowerShell scripts for Windows 11 fresh installation setup.

## Scripts

### Setup-Windows.ps1
**Main Windows setup script** - Run this first!

- Removes bloatware (Cortana, Office Hub, etc.)
- Configures privacy settings (disable telemetry)
- Configures UI/UX (show file extensions, hidden files)
- Enables Developer Mode
- Installs WSL with Ubuntu
- **Interactive app installation with 3 modes:**
  - **Skip** - No applications (system setup only)
  - **Basic** - Essential apps only (~15 apps from `Apps-List-Basic.txt`)
  - **Full** - All applications (~60+ apps from `Apps-List-Full.txt`)
- Downloads and installs NVIDIA App

**Usage:**
```powershell
# Open PowerShell as Administrator
Set-ExecutionPolicy Unrestricted -Force
cd C:\path\to\FreshWindowsInstall\windows
.\Setup-Windows.ps1
```

**Time:** 30-45 minutes (mostly automated)

---

### Setup-WezTerm.ps1
Installs and configures WezTerm terminal emulator.

- Installs WezTerm via winget
- Downloads and installs Meslo Nerd Font
- Copies `.wezterm.lua` configuration from repository root

**Usage:**
```powershell
.\Setup-WezTerm.ps1
```

**Time:** 5 minutes

---

### Setup-Zsh-Windows.ps1
Configures Zsh with Powerlevel10k inside WSL.

- Detects WSL distributions
- Runs `../linux/Setup-Zsh-Linux.sh` inside WSL
- Sets up Zsh, Oh My Zsh, Powerlevel10k
- Installs modern CLI tools (eza, zoxide)

**Usage:**
```powershell
.\Setup-Zsh-Windows.ps1
```

**After running:**
```bash
# Launch WSL
wsl -d Ubuntu

# Run Powerlevel10k configuration wizard
p10k configure
```

**Time:** 10-15 minutes

---

### Setup-GitHubKeys.ps1
Generates and uploads SSH/GPG keys to GitHub.

- Generates SSH ed25519 key
- Generates GPG 4096-bit RSA key
- Configures Git to auto-sign commits
- Uploads keys to GitHub via `gh` CLI

**Prerequisites:**
- Git installed
- GitHub CLI (`gh`) installed
- GPG installed

**Usage:**
```powershell
.\Setup-GitHubKeys.ps1
```

**Time:** 10 minutes

---

### Get-InstalledSoftware.ps1
Utility script to inventory installed software.

Exports list of installed software from both winget and Windows registry to:
- `InstalledSoftware.txt` (formatted report)
- `InstalledSoftware.csv` (spreadsheet format)

**Usage:**
```powershell
.\Get-InstalledSoftware.ps1
```

---

## Configuration Files

**📋 See [APPS-COMPARISON.md](APPS-COMPARISON.md) for detailed comparison and customization guide**

### Apps-List-Basic.txt
**Essential applications list** for minimal Windows setup (~15 apps).

**Includes:**
- Browsers (Firefox, Chrome)
- Core dev tools (Git, VS Code, GitHub CLI)
- Terminal (Windows Terminal, WezTerm, PowerShell)
- Essential productivity (1Password, Obsidian, PowerToys)
- Utilities (7zip)
- Security (GnuPG)

### Apps-List-Full.txt
**Complete applications list** for full Windows setup (~60+ apps).

**Includes everything from Basic plus:**
- Extended dev tools (Node.js, Python, Docker, GitHub Desktop)
- Cloud & DevOps (Azure CLI, Google Cloud SDK, Terraform, Tailscale)
- Full productivity suite (Signal, Slack, Discord, Flow Launcher)
- Media (VLC, TIDAL)
- Advanced utilities (TreeSize)
- Gaming peripherals (Logitech G HUB)
- System monitoring (HWiNFO, CPU-Z, HWMonitor, GPU-Z)
- File sync (Google Drive, Syncthing)
- AI tools (Claude, Claude Code, Ollama, opencode)
- Gaming (Steam, Epic Games, EA Desktop)

### Apps-List.txt (Legacy)
Old single app list file. **Not used by default.**
The script now uses `Apps-List-Basic.txt` or `Apps-List-Full.txt` based on your choice.

**Format:**
- One package ID per line
- Lines starting with `#` are comments
- Find package IDs: `winget search "Application Name"`

**Customization:**
- Edit `Apps-List-Basic.txt` to customize essential apps
- Edit `Apps-List-Full.txt` to customize complete installation
- Or choose "Skip" during setup and install apps manually later

---

## Recommended Order

Run scripts in this order for a complete Windows setup:

1. `Setup-Windows.ps1` - System configuration and application installation
2. **Reboot if prompted** (WSL installation)
3. `Setup-WezTerm.ps1` - Terminal setup
4. `Setup-Zsh-Windows.ps1` - Zsh configuration in WSL
5. `Setup-GitHubKeys.ps1` - GitHub authentication

**Total time:** 1-2 hours (mostly automated)

---

## See Also

- `../SETUP-GUIDE.md` - Complete setup guide with detailed instructions
- `../Setup-Zsh-README.md` - Detailed Zsh setup documentation
- `../.wezterm.lua` - WezTerm configuration file
- `../linux/` - Linux/WSL scripts
- `../macos/` - macOS scripts
