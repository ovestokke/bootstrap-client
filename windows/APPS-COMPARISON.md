# Windows App Lists Comparison

## Quick Reference

| Mode | Apps | Time | Best For |
|------|------|------|----------|
| **Skip** | 0 | 10-15 min | System only, manual installs |
| **Basic** | 14 | 20-30 min | Essential tools, lightweight setup |
| **Full** | 43 | 45-60 min | Complete workstation |

---

## Basic Apps (14 total)

### Browsers (2)
- Mozilla.Firefox
- Google.Chrome

### Development Tools (3)
- Git.Git
- GitHub.cli
- Microsoft.VisualStudioCode

### Terminal (3)
- Microsoft.WindowsTerminal
- wez.wezterm
- Microsoft.PowerShell

### Productivity (3)
- AgileBits.1Password
- Obsidian.Obsidian
- Microsoft.PowerToys

### Utilities (1)
- 7zip.7zip

### Security (2)
- GnuPG.GnuPG
- GnuPG.Gpg4win

---

## Full Apps (43 total)

### ✅ All Basic Apps (14)
*Everything from the Basic list above*

### + Extended Development (4)
- GitHub.GitHubDesktop
- OpenJS.NodeJS.LTS
- Python.Python.3.12
- Docker.DockerDesktop

### + Cloud & DevOps (4)
- Microsoft.AzureCLI
- Google.CloudSDK
- Hashicorp.Terraform
- Tailscale.Tailscale

### + Communication & Productivity (4)
- OpenWhisperSystems.Signal
- SlackTechnologies.Slack
- Discord.Discord
- Flow-Launcher.Flow-Launcher

### + Media (2)
- VideoLAN.VLC
- TIDALMusicAS.TIDAL

### + Advanced Utilities (1)
- JAMSoftware.TreeSize.Free

### + Gaming Peripherals (1)
- Logitech.GHUB

### + System Monitoring (4)
- REALiX.HWiNFO
- CPUID.CPU-Z
- CPUID.HWMonitor
- TechPowerUp.GPU-Z

### + File Management & Sync (2)
- Google.GoogleDrive
- BillSteward.SyncthingWindowsSetup

### + AI & Modern Tools (4)
- Anthropic.Claude
- Anthropic.ClaudeCode
- Ollama.Ollama
- SST.opencode

### + Gaming (3)
- Valve.Steam
- EpicGames.EpicGamesLauncher
- ElectronicArts.EADesktop

---

## Customization Guide

### To Modify Basic List
Edit `Apps-List-Basic.txt`:
```powershell
notepad Apps-List-Basic.txt
```

Add apps:
```txt
# Find ID first
winget search "App Name"

# Add to file
PackageID.Here
```

### To Modify Full List
Edit `Apps-List-Full.txt`:
```powershell
notepad Apps-List-Full.txt
```

### Common Additions

**IDEs:**
```txt
JetBrains.IntelliJIDEA.Community
JetBrains.PyCharm.Community
Microsoft.VisualStudio.2022.Community
```

**Browsers:**
```txt
BraveSoftware.BraveBrowser
Microsoft.Edge
Opera.Opera
```

**Communication:**
```txt
Zoom.Zoom
Microsoft.Teams
```

**Media:**
```txt
Spotify.Spotify
OBSProject.OBSStudio
```

**Utilities:**
```txt
Notepad++.Notepad++
WinMerge.WinMerge
Sysinternals Suite
```

---

## Finding Package IDs

```powershell
# Search for an app
winget search "Application Name"

# Get exact ID
winget show "Partial.Name"

# Example
winget search "Brave Browser"
# Output shows: BraveSoftware.BraveBrowser
```

---

## Installation Time Breakdown

### Skip Mode (10-15 min)
- Bloatware removal: 2-3 min
- Privacy settings: 1 min
- WSL installation: 5-10 min
- NVIDIA App download: 2 min

### Basic Mode (20-30 min)
- Skip mode tasks: 10-15 min
- 14 apps installation: 10-15 min

### Full Mode (45-60 min)
- Skip mode tasks: 10-15 min
- 43 apps installation: 30-45 min
- Depends on internet speed and system

---

## Post-Installation

After choosing any mode, you can always install more apps later:

```powershell
# Install individual apps
winget install --id PackageID -e

# Update all installed apps
winget upgrade --all
```
