# Bootstrap Client

**Zero-effort system setup.** One command to go from fresh install to fully configured development environment.

Cross-platform automation scripts for Windows, macOS, and Linux that handle everything: bloatware removal, privacy settings, terminal configuration, shell setup, and developer tools.

---

## 🚀 Quick Start

### ⚡ One Command — That's It

**Windows** (PowerShell as Administrator):
```powershell
irm https://raw.githubusercontent.com/ovestokke/bootstrap-client/master/Init-Windows.ps1 | iex
```

**macOS**:
```bash
curl -fsSL https://raw.githubusercontent.com/ovestokke/bootstrap-client/master/Init-macOS.sh | bash
```

**Linux/Ubuntu**:
```bash
curl -fsSL https://raw.githubusercontent.com/ovestokke/bootstrap-client/master/Init-Linux.sh | bash
```

### What Happens Automatically

**The init script will:**
1. Install Git (winget/Homebrew/apt)
2. Install Homebrew (macOS only, if needed)
3. Clone this repository to your chosen location
4. Present setup options:
   - **Windows**: Launch system setup with 3 app installation modes (Skip/Basic/Full)
   - **macOS**: Choose to run WezTerm, Zsh, GitHub keys, or all
   - **Linux**: Choose to run Zsh, GitHub keys, or both

**No manual git clone needed. No prerequisites. Just run the command.**

### For Forks

If you forked this repo, the init script will ask which URL to use:
- Option 1: HTTPS (default) - `https://github.com/ovestokke/bootstrap-client.git`
- Option 2: SSH - `git@github.com:ovestokke/bootstrap-client.git`
- Option 3: Custom URL - Enter your fork's URL

---

### 📦 Manual Setup (Advanced)

If you already cloned the repo or want to run individual scripts:

<details>
<summary><b>Windows Scripts</b></summary>

```powershell
# Open PowerShell as Administrator
cd C:\path\to\bootstrap-client\windows
Set-ExecutionPolicy Unrestricted -Force

# Run scripts individually
.\Setup-Windows.ps1      # System setup + apps (30-45 min)
.\Setup-WezTerm.ps1      # Terminal setup (5 min)
.\Setup-Zsh-Windows.ps1  # Zsh + tools in WSL (10 min)
.\Setup-GitHubKeys.ps1   # SSH/GPG keys (5-10 min)
```
</details>

<details>
<summary><b>macOS Scripts</b></summary>

```bash
cd /path/to/bootstrap-client/macos

# Run scripts individually
bash Setup-WezTerm.sh     # Terminal setup (5-10 min)
bash Setup-Zsh-macOS.sh   # Zsh + tools (10-15 min)
bash Setup-GitHubKeys.sh  # SSH/GPG keys (10 min)
```
</details>

<details>
<summary><b>Linux Scripts</b></summary>

```bash
cd /path/to/bootstrap-client/linux

# Run scripts individually
bash Setup-Zsh-Linux.sh   # Zsh + tools (15-20 min)
bash Setup-GitHubKeys.sh  # SSH/GPG keys (10 min)
bash Setup-WSL.sh         # Legacy WSL setup (deprecated)
```
</details>

---

## 📁 Repository Structure

```
bootstrap-client/
├── Init-Windows.ps1   # 🚀 One-line Windows initialization
├── Init-macOS.sh      # 🚀 One-line macOS initialization
├── Init-Linux.sh      # 🚀 One-line Linux initialization
│
├── windows/           # Windows PowerShell scripts
│   ├── Setup-Windows.ps1        # Main Windows setup (bloatware, privacy, apps)
│   ├── Setup-WezTerm.ps1        # WezTerm terminal setup
│   ├── Setup-Zsh-Windows.ps1    # Zsh setup (WSL wrapper)
│   ├── Setup-GitHubKeys.ps1     # GitHub SSH/GPG keys
│   ├── Get-InstalledSoftware.ps1
│   ├── Verify-WingetApps.ps1
│   ├── Apps-List-Basic.txt      # Essential applications (~15 apps)
│   ├── Apps-List-Full.txt       # Complete applications (~60 apps)
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

<details open>
<summary><b>Windows System Setup</b></summary>

### `Setup-Windows.ps1` (30-45 min)
- ✓ **Debloat**: Removes Cortana, Office Hub, Feedback Hub, etc.
- ✓ **Privacy**: Disables telemetry, web search in Start Menu
- ✓ **UI/UX**: Shows file extensions and hidden files
- ✓ **Developer Mode**: Enables development features
- ✓ **WSL + Ubuntu**: Full installation (no launch required)
- ✓ **Applications**: 3 installation modes
  - **Skip** - System setup only, no apps
  - **Basic** - 15 essential apps (browsers, dev tools, 1Password, Obsidian)
  - **Full** - 60+ apps (everything + gaming, media, productivity)
- ✓ **NVIDIA App**: Auto-downloads and installs latest version

See `windows/Apps-List-Basic.txt` and `windows/Apps-List-Full.txt` for complete lists.
</details>

<details open>
<summary><b>Terminal Setup (All Platforms)</b></summary>

### `Setup-WezTerm` (5-10 min)
- ✓ **WezTerm**: GPU-accelerated terminal with modern features
- ✓ **Meslo Nerd Font**: Powerline icons and glyphs
- ✓ **Custom Config**: Vim-style navigation (CTRL+h/j/k/l for panes)
- ✓ **Coolnight Theme**: Custom color scheme
- ✓ **Cross-platform**: Same config on Windows, macOS, Linux
</details>

<details open>
<summary><b>Zsh + Modern CLI Tools (All Platforms)</b></summary>

### `Setup-Zsh-*` (10-20 min)
- ✓ **Zsh Shell**: Modern shell with powerful features
- ✓ **Powerlevel10k**: Beautiful, fast theme with git integration
- ✓ **Plugins**:
  - `zsh-autosuggestions` - Fish-like suggestions
  - `zsh-syntax-highlighting` - Real-time syntax validation
- ✓ **Modern Tools**:
  - `eza` - Better `ls` with colors and icons
  - `zoxide` - Smart `cd` with frecency algorithm
- ✓ **History**: Arrow key search, deduplication
- ✓ **Nerd Fonts**: Icons and glyphs (Linux only, macOS uses system font)

**Platform Differences:**
- **macOS**: Homebrew-based, no Oh My Zsh (lighter, faster)
- **Linux/WSL**: Oh My Zsh framework (more plugins, wider compatibility)
- **Both**: Identical user experience and functionality
</details>

<details open>
<summary><b>GitHub Integration (All Platforms)</b></summary>

### `Setup-GitHubKeys` (5-10 min)
- ✓ **SSH Key**: ed25519 key generation
- ✓ **GPG Key**: 4096-bit RSA for commit signing
- ✓ **Git Config**: Auto-sign all commits
- ✓ **GitHub Upload**: Automatic key upload via `gh` CLI
- ✓ **Verification**: Signed commits show "Verified" badge

All future commits will be automatically signed and verified on GitHub.
</details>

---

## ⏱️ Time Estimates

| Platform | Mode | Total Time | Notes |
|----------|------|------------|-------|
| **Windows** | Skip apps | ~45 min | System setup + terminal + zsh + keys |
| | Basic (15 apps) | ~1 hour | + essential app installations |
| | Full (60+ apps) | ~2 hours | + complete app suite |
| **macOS** | All scripts | ~30-45 min | Terminal + zsh + keys |
| **Linux** | All scripts | ~15-20 min | Zsh + keys |

**Note:** Most time is spent on automated installations. You can do other tasks while scripts run.

---

## 🔧 Features & Philosophy

### Design Principles

1. **Zero Manual Steps**: One command from fresh install to configured system
2. **Sensible Defaults**: Works out of the box, customizable if needed
3. **Cross-Platform**: Same experience on Windows, macOS, Linux
4. **Idempotent**: Safe to run multiple times, won't break existing setups
5. **Logged**: Everything logged with timestamps for debugging
6. **Interactive**: Choose what to install, no forced installations

### Platform-Specific Approaches

**Windows:**
- Uses native `winget` package manager (built into Windows 11)
- PowerShell scripts with admin elevation checks
- WSL for Linux environment (Ubuntu)
- Separate app lists for flexibility (Basic/Full)

**macOS:**
- Homebrew for all package management
- No Oh My Zsh dependency (lighter, faster)
- Native Zsh (default shell since Catalina)
- Xcode CLI tools for Git

**Linux:**
- Uses `apt` for system packages
- Oh My Zsh framework for broader compatibility
- Works on Ubuntu, Debian, WSL
- Third-party repos for modern tools (eza, zoxide)

All platforms achieve **identical end-user experience** despite different installation methods.

---

## 📋 Prerequisites

**Literally nothing.** Just run the command.

| Platform | Requirements |
|----------|--------------|
| **Windows** | Windows 11 (or 10 with updates) + Admin access + Internet |
| **macOS** | macOS 11+ (Big Sur or later) + Internet |
| **Linux** | Ubuntu 20.04+ or Debian 10+ + sudo access + Internet |

The init script automatically installs:
- ✓ Git (via winget/Xcode CLI/apt)
- ✓ Homebrew (macOS only, if not present)
- ✓ curl (Linux only, if not present)

**No need to:**
- ❌ Install Git first
- ❌ Clone the repository manually
- ❌ Install package managers
- ❌ Download anything beforehand

Just copy-paste the one-line command and go.

---

## 🎨 Customization

### Before Running

**Fork this repo if you want to:**
- Customize app lists (Windows)
- Modify WezTerm configuration
- Change Zsh defaults
- Add your own scripts

The init script will ask for your fork's URL (Option 3: Custom URL).

### After Running

<details>
<summary><b>Windows Applications</b></summary>

Edit app lists before first run:
- `windows/Apps-List-Basic.txt` - 15 essential apps
- `windows/Apps-List-Full.txt` - 60+ complete suite

```txt
# Find app IDs with:
winget search "Application Name"

# Add apps (use exact ID)
Microsoft.VisualStudioCode

# Comment out unwanted apps
# Valve.Steam
# EpicGames.EpicGamesLauncher
```

App categories in Full list:
- Browsers, Dev tools, Productivity, Media, Gaming, Utilities
</details>

<details>
<summary><b>WezTerm Terminal</b></summary>

Edit `~/.wezterm.lua` (Windows: `%USERPROFILE%\.wezterm.lua`):

```lua
-- Color scheme
config.color_scheme = 'Coolnight'  -- or 'Batman', 'Tokyo Night', etc.

-- Font size
config.font_size = 13  -- default: 13

-- Opacity
config.window_background_opacity = 0.98  -- 0.0 to 1.0

-- Default program (Windows WSL)
config.default_prog = { 'wsl.exe', '-d', 'Ubuntu' }
```

See [WezTerm docs](https://wezfurlong.org/wezterm/config/files.html) for more options.
</details>

<details>
<summary><b>Zsh Configuration</b></summary>

**General Zsh** (`~/.zshrc`):
```bash
# Add custom aliases
alias ll='ls -la'
alias g='git'
alias dc='docker-compose'

# Environment variables
export EDITOR="code"
export PATH="$HOME/bin:$PATH"

# Additional Oh My Zsh plugins (Linux/WSL)
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker kubectl)
```

**Powerlevel10k Theme** (`~/.p10k.zsh`):
```bash
# Re-run configuration wizard anytime:
p10k configure

# Or edit ~/.p10k.zsh directly for:
# - Prompt segments (git, directory, time, etc.)
# - Colors and icons
# - Left/right prompt layout
```

**Tool Options**:
```bash
# eza (ls) options
alias ls='eza --icons=always --group-directories-first'
alias ll='eza --icons=always --long --group-directories-first'
alias la='eza --icons=always --long --all --group-directories-first'

# zoxide (cd) aliases
alias cd='z'
alias cdi='zi'  # interactive selection
```
</details>

<details>
<summary><b>Git Configuration</b></summary>

After `Setup-GitHubKeys`:

```bash
# View current config
git config --global --list

# Change commit signing
git config --global commit.gpgsign true  # or false

# Change default editor
git config --global core.editor "code --wait"

# Git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st status
git config --global alias.cm "commit -m"
```
</details>

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

## 🧩 Complementary Tools

### Chris Titus Tech WinUtil (Optional)
A popular community tool for additional Windows cleanup and tweaking. Use it AFTER running `Setup-Windows.ps1` if you want to:
- Apply extra GUI‑driven privacy / services tweaks
- Audit / remove remaining Microsoft Store apps
- Tweak Windows features granularly (services, context menu, scheduled tasks)
- Run additional debloat steps or selective installs

Quick launch (PowerShell as Administrator):
```powershell
irm "https://christitus.com/win" | iex
```

Why it's complementary (not a replacement):
- This repository already performs a curated, opinionated baseline (bloat removal, privacy, dev tooling)
- WinUtil lets you visually review and optionally apply further changes
- Running it first can overlap with our automated steps; run it after to layer fine‑grained tweaks

Recommendations:
- Create a restore point before large tweak batches
- Review each tab; avoid blindly applying every toggle
- Skip duplicate debloat actions already handled here (e.g., Cortana removal)

---

## 📄 License

Personal use. Feel free to fork and customize for your own needs.

---

**Happy coding! 🚀**
