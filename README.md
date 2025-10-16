# Bootstrap Client

**Zero-effort system setup.** One command to go from fresh install to fully configured development environment.

Cross-platform automation scripts for Windows, macOS, and Linux that handle everything: bloatware removal, privacy settings, terminal configuration, shell setup, and developer tools.

---

## 🚀 Quick Start

### ⚡ One Command — That's It

**Windows** (PowerShell as Administrator):
```powershell
irm https://raw.githubusercontent.com/ovestokke/bootstrap-client/master/init-windows.ps1 | iex
```

**macOS**:
```bash
curl -fsSL https://raw.githubusercontent.com/ovestokke/bootstrap-client/master/init-macos.sh | bash
```

**Linux/Ubuntu**:
```bash
curl -fsSL https://raw.githubusercontent.com/ovestokke/bootstrap-client/master/init-linux.sh | bash
```

### What Happens Automatically

**The init script will:**
1. Install Git (winget/Homebrew/apt)
2. Install Homebrew (macOS only, if needed)
3. **Smart repository handling:**
   - If run from the repo: Offers to pull latest changes
   - If not in repo: Clones to your chosen location
4. Present setup options:
   - **Windows**: System setup with 3 app modes (Skip/Basic/Full)
   - **macOS**: Essentials, packages, or complete setup
   - **Linux**: Shell setup and GitHub keys

**No manual git clone needed. No prerequisites. Just run the command.**

**Tip:** If you already cloned the repo, run `bash init-macos.sh` from inside it to auto-detect and update.

---

## 📁 Repository Structure

```
bootstrap-client/
├── init-windows.ps1   # 🚀 One-line Windows initialization
├── init-macos.sh      # 🚀 One-line macOS initialization
├── init-linux.sh      # 🚀 One-line Linux initialization
│
├── windows/           # Windows PowerShell scripts
│   ├── Setup-Windows.ps1        # System setup (bloatware, privacy, apps)
│   ├── Setup-WezTerm.ps1        # WezTerm terminal
│   ├── Setup-Zsh-Windows.ps1    # Zsh in WSL
│   ├── Setup-GitHubKeys.ps1     # SSH/GPG keys
│   ├── Setup-PowerShell.ps1     # PowerShell profile
│   ├── Setup-Komorebi.ps1       # Tiling WM (optional)
│   ├── Apps-List-Basic.txt      # 15 essential apps
│   ├── Apps-List-Full.txt       # 60+ complete apps
│   └── README.md
│
├── macos/             # macOS Bash scripts
│   ├── setup-essentials.sh      # Homebrew + Git + chezmoi
│   ├── setup-packages.sh        # All tools (WezTerm, Neovim, etc.)
│   └── README.md
│
├── linux/             # Linux/Ubuntu Bash scripts
│   ├── Setup-Zsh-Linux.sh       # Zsh + P10k
│   ├── Setup-GitHubKeys.sh      # SSH/GPG keys
│   └── README.md
│
├── .wezterm.lua       # WezTerm configuration
├── CONTRIBUTING.md    # Code style & architecture
├── QUICK-REFERENCE.md # Commands, tips, troubleshooting
├── Setup-LazyVim-README.md # LazyVim detailed guide
└── Setup-Zsh-README.md # Zsh detailed guide
```

---

## 🎯 What Gets Installed

### macOS
✅ **Foundation**: Homebrew, Git, chezmoi (dotfile manager)  
✅ **Terminal**: WezTerm + Meslo Nerd Font  
✅ **Shell**: Zsh + Oh My Zsh + Powerlevel10k  
✅ **CLI Tools**: eza, zoxide, fzf, ripgrep, fd  
✅ **Development**: Neovim, lazygit, GitHub CLI, GPG  

**Configuration**: Managed by chezmoi (your dotfiles)

### Windows
✅ **System**: Bloatware removal, privacy settings, Developer Mode  
✅ **WSL**: Ubuntu distribution  
✅ **Applications**: 3 modes - Skip/Basic (15 apps)/Full (60+ apps)  
✅ **Terminal**: WezTerm + Nerd Font  
✅ **Shell**: Zsh in WSL with Powerlevel10k  
✅ **Tools**: Modern CLI tools, GitHub integration  

### Linux/Ubuntu
✅ **Shell**: Zsh + Oh My Zsh + Powerlevel10k  
✅ **CLI Tools**: eza, zoxide, and more  
✅ **GitHub**: SSH/GPG key generation and upload  

---

## ⏱️ Time Estimates

| Platform | Setup Type | Time |
|----------|-----------|------|
| **macOS** | Complete setup | 15-20 min |
| **Windows** | Skip apps | ~45 min |
| | Basic (15 apps) | ~1 hour |
| | Full (60+ apps) | ~2 hours |
| **Linux** | Complete setup | 15-20 min |

*Most time is automated - you can multitask while scripts run.*

---

## 📚 Documentation

### Quick Access
- **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - Commands, tips, troubleshooting
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Code style & architecture
- **[macos/README.md](macos/README.md)** - macOS scripts guide
- **[windows/README.md](windows/README.md)** - Windows scripts guide
- **[linux/README.md](linux/README.md)** - Linux scripts guide

### Detailed Guides
- **[Setup-LazyVim-README.md](Setup-LazyVim-README.md)** - Neovim/LazyVim setup
- **[Setup-Zsh-README.md](Setup-Zsh-README.md)** - Zsh configuration
- **[SETUP-GUIDE.md](SETUP-GUIDE.md)** - Complete walkthrough

---

## 🔧 Key Features

### Cross-Platform Consistency
Same development experience across all platforms:
- Identical terminal (WezTerm)
- Same shell (Zsh + Powerlevel10k)
- Same modern CLI tools (eza, zoxide)
- Same workflow (chezmoi for dotfiles)

### macOS Philosophy
**Minimalist approach** - Scripts install packages, chezmoi manages configuration:
1. `setup-essentials.sh` → Install Homebrew, Git, chezmoi (init dotfiles)
2. `setup-packages.sh` → Install all tools (no config writing)
3. `chezmoi apply` → Apply your dotfiles

Your dotfiles control everything: `.wezterm.lua`, `.zshrc`, `~/.config/nvim/`, etc.

### Windows Flexibility
**Three installation modes:**
- **Skip** - System setup only (no apps)
- **Basic** - 15 essential apps
- **Full** - 60+ complete app suite

**Interactive setup** - Choose what to install, automated execution.

---

## 🧩 Complementary Tools

### chezmoi - Dotfile Manager (Core)
**Repository**: [github.com/ovestokke/dotfiles](https://github.com/ovestokke/dotfiles)

Manage your configuration files across machines:
- WezTerm configuration
- Zsh setup (Oh My Zsh, Powerlevel10k, aliases)
- Neovim/LazyVim config
- Git configuration
- All your dotfiles in one place

**Quick start:**
```bash
# Initialize and apply dotfiles
chezmoi init --apply https://github.com/yourusername/dotfiles.git
```

**Installed automatically** by macOS `setup-essentials.sh` and Windows `Setup-Essentials.ps1`

### Chris Titus Tech WinUtil (Windows Optional)
Community tool for additional Windows tweaking. Use **after** running `Setup-Windows.ps1`:

```powershell
irm "https://christitus.com/win" | iex
```

**Why it's complementary:**
- This repo: Curated baseline (bloatware, privacy, dev tools)
- WinUtil: Visual GUI for granular tweaks
- Run it after for fine-tuning

---

## 🔄 Updating

### Update Packages

**macOS:**
```bash
brew update && brew upgrade
```

**Windows:**
```powershell
winget upgrade --all
```

**Linux:**
```bash
sudo apt update && sudo apt upgrade
omz update  # Update Oh My Zsh
```

### Update Dotfiles (chezmoi)
```bash
chezmoi update  # Pull and apply changes
```

### Update Neovim Plugins
```bash
nvim
:Lazy sync
```

---

## 🆘 Need Help?

Check these resources:
1. **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - Common commands and troubleshooting
2. **Platform READMEs** - Detailed documentation for each OS
3. **Detailed Guides** - Setup-LazyVim-README.md, Setup-Zsh-README.md

---

## 📖 Reference

Based on: [Josean's WezTerm Terminal Setup Guide](https://www.josean.com/posts/how-to-setup-wezterm-terminal)

---

## 📄 License

Personal use. Feel free to fork and customize for your own needs.

---

**Happy coding! 🚀**
