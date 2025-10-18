# Linux Setup Scripts

Bash scripts for Linux development environment setup.

**Requirements:** apt package manager (Debian/Ubuntu-based distributions)  
**Supported:** Ubuntu, Debian, WSL (Ubuntu/Debian), Linux Mint, Pop!_OS, etc.

## Quick Start

### Option 1: Automated Setup (Recommended)

Run from the repository root:

```bash
bash init-linux.sh
```

This offers:
1. **setup-packages.sh** - Install all packages (comprehensive)
2. **setup-essentials.sh** - Install Git + chezmoi only
3. **setup-github-keys.sh** - Generate and upload SSH/GPG keys
4. **Run full setup** - Automated workflow (1→2→3)

### Option 2: Remote Installation

```bash
curl -fsSL https://raw.githubusercontent.com/ovestokke/bootstrap-client/master/init-linux.sh | bash
```

---

## Core Scripts

### setup-packages.sh
**Comprehensive package installation** - Install everything you need

Installs:
- **Zsh + Oh My Zsh + Powerlevel10k** - Modern shell with beautiful prompt
- **Zsh plugins** - autosuggestions, syntax-highlighting
- **Modern CLI tools** - eza, zoxide, fzf, ripgrep, fd, bat
- **Neovim** (latest via PPA) + dependencies (lazygit, build-essential)
- **GitHub CLI** (gh) + GPG (for commit signing)
- **chezmoi** - Dotfiles manager
- **Meslo Nerd Font** - Font with icon support

**Usage:**
```bash
bash linux/setup-packages.sh
```

**Time:** 15-20 minutes

---

### setup-essentials.sh
**Minimal setup** - Git + chezmoi only

For when you want to manage everything else via dotfiles.

**Usage:**
```bash
bash linux/setup-essentials.sh
```

**Time:** 2-5 minutes

---

### setup-github-keys.sh
**GitHub SSH & GPG keys setup**

- Generates SSH ed25519 key
- Generates GPG 4096-bit RSA key  
- Configures Git to auto-sign commits
- Uploads keys to GitHub via `gh` CLI

**Prerequisites:**
- Git user.name and user.email configured (from chezmoi dotfiles)
- GitHub CLI, GPG (auto-installed if missing)

**Usage:**
```bash
bash linux/setup-github-keys.sh
```

**Time:** 10 minutes

---

### setup-zsh-linux.sh
**Zsh-only setup** - Standalone Zsh configuration script

Use this if you only want to set up Zsh without other tools.

**Installs:**
- Zsh + Oh My Zsh + Powerlevel10k
- Zsh plugins (autosuggestions, syntax-highlighting)
- Modern CLI tools (eza, zoxide)
- chezmoi (dotfiles manager)
- Meslo Nerd Font

**Usage:**
```bash
bash linux/setup-zsh-linux.sh
```

**Time:** 10-15 minutes

---

### setup-wsl.sh
**Legacy WSL setup script** ⚠️ Deprecated

Use `setup-packages.sh` or `setup-zsh-linux.sh` instead. This script is kept for backwards compatibility but is no longer maintained.

---

## Recommended Workflow

### Full Setup (Automated)
```bash
# Clone the repository first or use init-linux.sh
cd ~/bootstrap-client/linux

# Option 1: Run everything
bash init-linux.sh
# Choose option 4 (Run full setup)

# Option 2: Step by step
bash setup-packages.sh     # 1. Install all packages
bash setup-essentials.sh   # 2. Git + chezmoi (if not using setup-packages.sh)
chezmoi init https://github.com/YOUR_USERNAME/dotfiles.git
chezmoi apply              # 3. Apply dotfiles
bash setup-github-keys.sh  # 4. GitHub authentication
chsh -s $(which zsh)       # 5. Set Zsh as default shell
```

**Total time:** 20-30 minutes (mostly automated)

---

## What Gets Installed

### Shell Environment
- **Zsh** - Modern shell with better features than bash
- **Oh My Zsh** - Plugin framework and configuration management
- **Powerlevel10k** - Beautiful and highly configurable prompt
- **zsh-autosuggestions** - Fish-like autosuggestions based on history
- **zsh-syntax-highlighting** - Syntax highlighting for commands

### Modern CLI Tools
- **eza** - Better `ls` with colors, icons, and git integration
- **zoxide** - Smart `cd` that learns your most-used directories
- **fzf** - Fuzzy finder for files, history, and more
- **ripgrep (rg)** - Fast grep alternative
- **fd** - Fast find alternative
- **bat** - Better `cat` with syntax highlighting

### Development Tools
- **Neovim** - Modern Vim fork (v0.11.2+)
- **lazygit** - Terminal UI for git
- **build-essential** - C/C++ compiler and tools (for Neovim plugins)
- **GitHub CLI (gh)** - GitHub command-line tool
- **GPG** - For signing git commits
- **chezmoi** - Dotfiles management system

### Fonts
- **Meslo Nerd Font** - Monospace font with icons and ligatures

---

## Configuration Management

**IMPORTANT:** These scripts only install packages. Configuration is managed by chezmoi dotfiles.

### What should be in your dotfiles:
- `~/.zshrc` - Zsh configuration
- `~/.zprofile` - Zsh login shell configuration  
- `~/.config/nvim/` - Neovim configuration (LazyVim)
- `~/.gitconfig` - Git configuration
- `~/.wezterm.lua` - WezTerm configuration (if using WezTerm)
- `~/.p10k.zsh` - Powerlevel10k configuration

### First-time setup:
```bash
# Initialize chezmoi with your dotfiles
chezmoi init https://github.com/YOUR_USERNAME/dotfiles.git

# Review what will be changed
chezmoi diff

# Apply your dotfiles
chezmoi apply

# Run Powerlevel10k configuration (first time only)
p10k configure
```

---

## After Installation

### 1. Set Zsh as default shell
```bash
chsh -s $(which zsh)
# Logout and login, or restart terminal
```

### 2. Configure Powerlevel10k (first time only)
```bash
p10k configure
```

Choose your preferred style (lean or rainbow recommended for coolnight theme).

### 3. Test installations
```bash
# Modern CLI tools
ls           # Should use eza with icons
z ~/          # Should use zoxide smart cd
fzf          # Should open fuzzy finder
nvim         # Should open Neovim

# Check versions
nvim --version
lazygit --version
gh --version
chezmoi --version
```

---

## Updating Tools

### Update system packages
```bash
sudo apt update
sudo apt upgrade
```

### Update Oh My Zsh
```bash
omz update
```

### Update Powerlevel10k
```bash
cd ~/.oh-my-zsh/custom/themes/powerlevel10k
git pull
```

### Update Zsh plugins
```bash
# zsh-autosuggestions
cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git pull

# zsh-syntax-highlighting
cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git pull
```

### Update Neovim
```bash
sudo apt update
sudo apt upgrade neovim
```

### Update chezmoi dotfiles
```bash
chezmoi update
```

---

## Troubleshooting

### Zsh not default shell
```bash
chsh -s $(which zsh)
# Then logout and login
```

### Plugins not working
```bash
# Verify plugins are installed
ls ~/.oh-my-zsh/custom/plugins/

# Check .zshrc configuration
grep "plugins=" ~/.zshrc
# Should show: plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```

### Command not found (eza, zoxide, etc.)
```bash
# Check if installed
command -v eza
command -v zoxide

# Check PATH
echo $PATH | grep -o ".local/bin"

# Add to PATH if needed (should be in dotfiles)
export PATH="$HOME/.local/bin:$PATH"
```

### Icons not showing in terminal
```bash
# Verify font is installed
fc-list | grep -i meslo

# Make sure your terminal uses Meslo Nerd Font
# For WezTerm: set in .wezterm.lua
# For other terminals: check terminal preferences
```

### Neovim version too old
```bash
# Check version
nvim --version

# If < 0.11.2, update from PPA
sudo apt update
sudo apt upgrade neovim
```

### Git config not found (for setup-github-keys.sh)
```bash
# Check git config
git config --global user.name
git config --global user.email

# Should come from chezmoi dotfiles
# If empty, initialize and apply dotfiles:
chezmoi init https://github.com/YOUR_USERNAME/dotfiles.git
chezmoi apply
```

---

## See Also

- `../init-linux.sh` - Automated initialization script
- `../SETUP-GUIDE.md` - Complete setup guide
- `../Setup-Zsh-README.md` - Detailed Zsh setup documentation
- `../windows/` - Windows setup scripts
- `../macos/` - macOS setup scripts
