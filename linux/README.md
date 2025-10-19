# Linux Setup Scripts

Minimal bootstrap script for Debian/Ubuntu-based Linux distributions (including WSL).

**Requirements:** apt package manager (Debian/Ubuntu-based distributions)  
**Supported:** Ubuntu 20.04+, Debian 11+, WSL2 (Ubuntu/Debian), Linux Mint, Pop!_OS

## Philosophy

**All package installation and configuration is handled by [chezmoi](https://www.chezmoi.io/)** via your dotfiles repository.

This script only installs the bare minimum needed to bootstrap chezmoi, which then handles everything else.

## Quick Start

### Option 1: Automated Setup (Recommended)

Run from the repository root:

```bash
bash init-linux.sh
```

### Option 2: Remote Installation

```bash
curl -fsSL https://raw.githubusercontent.com/ovestokke/bootstrap-client/master/init-linux.sh | bash
```

---

## Script

### setup-essentials.sh

Minimal bootstrap script that:
1. Installs basic system utilities (git, curl, wget, unzip)
2. Installs development tools (Neovim, lazygit, build-essential)
3. Installs chezmoi
4. Initializes your dotfiles from GitHub (`chezmoi init --apply`)

Chezmoi then handles the rest via `.chezmoiscripts` in your dotfiles repo.

**Usage:**
```bash
bash linux/setup-essentials.sh
```

**Time:** 5-10 minutes (depending on your dotfiles)

---

## What Chezmoi Installs

Your dotfiles repository (via chezmoi) will install and configure:

### Shell Environment
- **Zsh** - Modern shell
- **Oh My Zsh** - Plugin framework (via `.chezmoiscripts`)
- **Powerlevel10k** - Beautiful prompt theme
- **zsh-autosuggestions** - Fish-like autosuggestions
- **zsh-syntax-highlighting** - Syntax highlighting for commands

### Modern CLI Tools
- **eza** - Better `ls` with colors and icons
- **zoxide** - Smart `cd` that learns your directories
- **fzf** - Fuzzy finder for files and history
- **ripgrep (rg)** - Fast grep alternative
- **fd** - Fast find alternative
- **bat** - Better `cat` with syntax highlighting

### Development Tools
- **Neovim** - Modern Vim fork (installed via setup script + PPA)
- **lazygit** - Terminal UI for git (installed via setup script)
- **build-essential** - C/C++ compiler and tools for Neovim plugins
- **GitHub CLI (gh)** - GitHub command-line tool (via chezmoi)
- **GPG** - For signing git commits (via chezmoi)
- **git** - Version control (via chezmoi)

### Fonts
- **Meslo Nerd Font** - Monospace font with icons

See your dotfiles repo's `applications.json` and `.chezmoiscripts/` for the complete list.

---

## After Installation

### 1. Restart your terminal
Log out and back in, or restart your terminal.

### 2. Set Zsh as default shell (if not already)
```bash
chsh -s $(which zsh)
# Then logout and login
```

### 3. Configure Powerlevel10k (first time only)
```bash
p10k configure
```

Choose your preferred style (lean or rainbow recommended).

---

## Managing Your Configuration

All dotfiles are managed by chezmoi:

```bash
# View status
chezmoi status

# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Edit a dotfile
chezmoi edit ~/.zshrc

# Update from GitHub
chezmoi update
```

### What's in your dotfiles:
- `~/.zshrc` - Zsh configuration
- `~/.zprofile` - Zsh login shell configuration  
- `~/.config/nvim/` - Neovim configuration
- `~/.gitconfig` - Git configuration
- `~/.wezterm.lua` - WezTerm configuration
- `~/.p10k.zsh` - Powerlevel10k configuration

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

### Packages not installed
If packages are missing, check your dotfiles repo:
1. Verify `applications.json` contains the packages
2. Check `.chezmoiscripts/` for installation scripts
3. Re-run: `chezmoi apply -v` (verbose mode)

### Chezmoi init failed
Ensure you have:
1. Git installed
2. Internet connection
3. Correct GitHub username

### Icons not showing in terminal
```bash
# Verify font is installed
fc-list | grep -i meslo

# Make sure your terminal uses Meslo Nerd Font
# For WezTerm: set in .wezterm.lua
# For other terminals: check terminal preferences
```

### Git config not found
```bash
# Check git config
git config --global user.name
git config --global user.email

# Should come from chezmoi dotfiles
# If empty, re-apply dotfiles:
chezmoi apply
```

---

## See Also

- `../init-linux.sh` - Automated initialization script
- `../SETUP-GUIDE.md` - Complete setup guide
- `../windows/` - Windows setup scripts
- `../macos/` - macOS setup scripts
