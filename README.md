# Fresh Install Setup Scripts

Cross-platform automation scripts for setting up development environments on Windows, macOS, and Linux.

## 🚀 Quick Start

### Windows
```powershell
# Open PowerShell as Administrator
cd C:\path\to\FreshWindowsInstall\windows
Set-ExecutionPolicy Unrestricted -Force
.\Setup-Windows.ps1
.\Setup-WezTerm.ps1
.\Setup-Zsh-Windows.ps1
.\Setup-GitHubKeys.ps1
```

### macOS
```bash
cd /path/to/FreshWindowsInstall/macos
bash Setup-WezTerm.sh
bash Setup-Zsh-macOS.sh
bash Setup-GitHubKeys.sh
```

### Linux/Ubuntu
```bash
cd /path/to/FreshWindowsInstall/linux
bash Setup-Zsh-Linux.sh
bash Setup-GitHubKeys.sh
```

---

## 📁 Repository Structure

```
FreshWindowsInstall/
├── windows/           # Windows PowerShell scripts
│   ├── Setup-Windows.ps1        # Main Windows setup (bloatware, privacy, apps)
│   ├── Setup-WezTerm.ps1        # WezTerm terminal setup
│   ├── Setup-Zsh-Windows.ps1    # Zsh setup (WSL wrapper)
│   ├── Setup-GitHubKeys.ps1     # GitHub SSH/GPG keys
│   ├── Get-InstalledSoftware.ps1
│   ├── Apps-List.txt            # Applications to install via winget
│   └── README.md
│
├── macos/             # macOS Bash scripts
│   ├── Setup-Zsh-macOS.sh       # Zsh + P10k (Homebrew-based)
│   ├── Setup-WezTerm.sh         # WezTerm terminal setup
│   ├── Setup-GitHubKeys.sh      # GitHub SSH/GPG keys
│   └── README.md
│
├── linux/             # Linux/Ubuntu Bash scripts
│   ├── Setup-Zsh-Linux.sh       # Zsh + P10k (Oh My Zsh-based)
│   ├── Setup-GitHubKeys.sh      # GitHub SSH/GPG keys
│   ├── Setup-WSL.sh             # Legacy WSL setup
│   └── README.md
│
├── .wezterm.lua       # WezTerm configuration
├── SETUP-GUIDE.md     # Complete setup guide
├── Setup-Zsh-README.md # Detailed Zsh documentation
├── CLAUDE.md          # Technical documentation
└── AGENTS.md          # Code style guidelines
```

---

## 📚 Documentation

- **[SETUP-GUIDE.md](SETUP-GUIDE.md)** - Complete step-by-step setup guide
- **[Setup-Zsh-README.md](Setup-Zsh-README.md)** - Detailed Zsh setup documentation
- **[windows/README.md](windows/README.md)** - Windows scripts documentation
- **[macos/README.md](macos/README.md)** - macOS scripts documentation
- **[linux/README.md](linux/README.md)** - Linux scripts documentation

---

## 🎯 What Gets Installed

### Windows (`windows/Setup-Windows.ps1`)
- ✓ Removes bloatware (Cortana, Office Hub, etc.)
- ✓ Configures privacy settings (disable telemetry)
- ✓ Configures UI/UX (show file extensions, hidden files)
- ✓ Enables Developer Mode
- ✓ Installs WSL with Ubuntu
- ✓ Interactive app installation with 3 modes:
  - **Skip** - No apps (system only)
  - **Basic** - ~15 essential apps
  - **Full** - 60+ apps (dev, productivity, gaming, etc.)
- ✓ Downloads and installs NVIDIA App

### Terminal Setup (All Platforms)
- ✓ WezTerm terminal emulator
- ✓ Meslo Nerd Font
- ✓ Custom keybindings (vim-style navigation)
- ✓ Cross-platform configuration

### Zsh Setup (All Platforms)
- ✓ Zsh shell
- ✓ Powerlevel10k theme
- ✓ zsh-autosuggestions
- ✓ zsh-syntax-highlighting
- ✓ eza (better ls)
- ✓ zoxide (better cd)
- ✓ History search with arrow keys

### GitHub Integration (All Platforms)
- ✓ SSH ed25519 key generation
- ✓ GPG 4096-bit RSA key generation
- ✓ Auto-signed Git commits
- ✓ Keys uploaded to GitHub

---

## ⏱️ Time Estimates

| Platform | Task | Time |
|----------|------|------|
| **Windows** | System Setup | 30-45 min |
| | Terminal Setup | 5 min |
| | Zsh Setup | 10 min |
| | GitHub Keys | 10 min |
| | **Total** | **1-2 hours** |
| **macOS** | Terminal Setup | 5-10 min |
| | Zsh Setup | 10-15 min |
| | GitHub Keys | 10 min |
| | **Total** | **30-45 min** |
| **Linux** | Zsh Setup | 15-20 min |
| | **Total** | **15-20 min** |

---

## 🔧 Platform Differences

### Zsh Setup Approaches

**macOS** (Homebrew-based):
- No Oh My Zsh dependency
- Installs everything via Homebrew
- Sources plugins directly in `.zshrc`
- Lighter and faster
- Easy updates: `brew upgrade`

**Linux/WSL** (Oh My Zsh-based):
- Uses Oh My Zsh framework
- Git clones P10k and plugins
- Oh My Zsh plugin system
- Works on any Debian-based distro
- Update with `git pull`

Both approaches provide the **same user experience** with identical functionality.

---

## 📋 Prerequisites

### Windows
- Windows 11 (or Windows 10 with latest updates)
- Administrator access
- Internet connection

### macOS
- macOS 11+ (Big Sur or later)
- [Homebrew](https://brew.sh/) installed
- Zsh (default shell on macOS)

### Linux
- Ubuntu 20.04+ or Debian 10+
- `sudo` access
- Internet connection

---

## 🎨 Customization

### Applications (Windows)

**Choose during setup:**
- **Skip** - No applications installed
- **Basic** - Essential apps (~15): Edit `windows/Apps-List-Basic.txt`
- **Full** - All apps (~60+): Edit `windows/Apps-List-Full.txt`

**To customize:**
```txt
# Add your apps (find IDs with: winget search "AppName")
Example.AppName

# Comment out apps you don't need
# Valve.Steam
```

### WezTerm Configuration
Edit `.wezterm.lua` to customize:
- Color scheme
- Font size
- Keybindings
- Window opacity

### Zsh Configuration
Edit `~/.zshrc` to customize:
- Aliases
- Environment variables
- Additional plugins

Edit `~/.p10k.zsh` to customize Powerlevel10k:
- Colors
- Prompt segments
- Icons

---

## 🆘 Troubleshooting

See the documentation for detailed troubleshooting:
- [SETUP-GUIDE.md](SETUP-GUIDE.md) - General troubleshooting
- [Setup-Zsh-README.md](Setup-Zsh-README.md) - Zsh-specific issues
- [windows/README.md](windows/README.md) - Windows-specific issues
- [macos/README.md](macos/README.md) - macOS-specific issues
- [linux/README.md](linux/README.md) - Linux-specific issues

---

## 🔄 Updating

### Windows Applications
```powershell
winget upgrade --all
```

### macOS Tools
```bash
brew update && brew upgrade
```

### Linux/WSL Tools
```bash
# Update Oh My Zsh
omz update

# Update Powerlevel10k
cd ~/.oh-my-zsh/custom/themes/powerlevel10k && git pull

# Update plugins
cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull
cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull

# Update system packages
sudo apt update && sudo apt upgrade
```

---

## 📖 Reference

Based on: [Josean's WezTerm Terminal Setup Guide](https://www.josean.com/posts/how-to-setup-wezterm-terminal)

---

## 📄 License

Personal use. Feel free to fork and customize for your own needs.

---

**Happy coding! 🚀**
