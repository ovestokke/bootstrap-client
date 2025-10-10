# Linux/Ubuntu Setup Scripts

Bash scripts for Linux/Ubuntu and WSL development environment setup.

## Scripts

### Setup-GitHubKeys.sh
Generates and uploads SSH/GPG keys to GitHub.

- Generates SSH ed25519 key
- Generates GPG 4096-bit RSA key
- Configures Git to auto-sign commits
- Uploads keys to GitHub via `gh` CLI

**Prerequisites:**
- Git installed
- GitHub CLI (`gh`) installed: `sudo apt install gh`
- GPG installed: `sudo apt install gnupg`

**Usage:**
```bash
bash linux/Setup-GitHubKeys.sh
```

**Time:** 10 minutes

---

### Setup-Zsh-Linux.sh
**Main Zsh setup script** - Oh My Zsh-based approach

- Installs Zsh (if not already installed)
- Installs Oh My Zsh framework
- Installs Powerlevel10k theme (git clone)
- Installs zsh-autosuggestions plugin (git clone)
- Installs zsh-syntax-highlighting plugin (git clone)
- Configures history search with arrow keys
- Installs eza (better ls) with fallback to third-party repository
- Installs zoxide (better cd) with fallback to curl installer
- Installs Meslo Nerd Font to `~/.local/share/fonts`

**Compatible with:**
- Ubuntu 20.04+
- Debian 10+
- WSL (Windows Subsystem for Linux)
- Other Debian-based distributions

**Usage:**
```bash
bash linux/Setup-Zsh-Linux.sh
```

**After running:**
```bash
# Change default shell to Zsh (if prompted)
chsh -s $(which zsh)

# Logout and login, or restart terminal
# Then run Powerlevel10k configuration wizard
p10k configure
```

**Time:** 15-20 minutes

---

### Setup-WSL.sh
**Legacy WSL setup script** - Use `Setup-Zsh-Linux.sh` instead

This is the original WSL setup script. It's functionally equivalent to `Setup-Zsh-Linux.sh` but less generic.

**Recommendation:** Use `Setup-Zsh-Linux.sh` for new setups as it works on any Linux distribution, not just WSL.

---

## Running from Windows

If you're setting up WSL from Windows, use the PowerShell wrapper:

```powershell
# From Windows PowerShell
cd C:\path\to\FreshWindowsInstall\windows
.\Setup-Zsh-Windows.ps1
```

This will:
1. Detect your WSL distributions
2. Let you choose which one to configure
3. Automatically run `linux/Setup-Zsh-Linux.sh` inside WSL
4. Provide next steps

---

## Manual Installation in WSL

If you prefer to run the script manually inside WSL:

```bash
# From WSL
cd /mnt/c/path/to/FreshWindowsInstall/linux
bash Setup-Zsh-Linux.sh
```

---

## Updating Tools

### Update Oh My Zsh
```bash
omz update
```

### Update Powerlevel10k
```bash
cd ~/.oh-my-zsh/custom/themes/powerlevel10k
git pull
```

### Update Plugins
```bash
# zsh-autosuggestions
cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git pull

# zsh-syntax-highlighting
cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git pull
```

### Update CLI Tools
```bash
# Check if available via apt
sudo apt update
sudo apt upgrade eza zoxide

# Or reinstall via curl (zoxide)
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
```

---

## What Gets Installed

### Zsh Components
- **Zsh** - Modern shell
- **Oh My Zsh** - Plugin framework
- **Powerlevel10k** - Beautiful prompt theme
- **zsh-autosuggestions** - Fish-like autosuggestions
- **zsh-syntax-highlighting** - Command syntax highlighting

### Modern CLI Tools
- **eza** - Better `ls` with colors and icons
- **zoxide** - Smart `cd` that learns your habits

### Fonts
- **Meslo Nerd Font** - Font with icon support for terminal

### Configuration
- History search with arrow keys
- Unified aliases (`ls` → eza, `cd` → zoxide)
- Shared history between sessions

---

## Differences from macOS Setup

| Feature | Linux/WSL | macOS |
|---------|-----------|-------|
| Package Manager | apt + git clone | Homebrew |
| Framework | Oh My Zsh | None (direct sourcing) |
| P10k Install | `git clone` | `brew install` |
| Plugins | Oh My Zsh plugins | Source in `.zshrc` |
| Font Install | `~/.local/share/fonts` | `brew install --cask` |
| Updates | `git pull` + `apt` | `brew upgrade` |

Both approaches result in the same functionality, just using platform-appropriate tools.

---

## Troubleshooting

### Zsh not default shell
```bash
chsh -s $(which zsh)
# Logout and login
```

### Plugins not working
```bash
# Verify plugins are installed
ls ~/.oh-my-zsh/custom/plugins/

# Verify .zshrc configuration
grep "plugins=" ~/.zshrc

# Should show: plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```

### eza or zoxide not found
```bash
# Check if installed
command -v eza
command -v zoxide

# Reinstall if needed
sudo apt-get update
sudo apt-get install eza zoxide
```

### Icons not showing
```bash
# Verify font is installed
fc-list | grep -i meslo

# Ensure terminal uses Meslo Nerd Font
# In WezTerm: config.font = wezterm.font("MesloLGS NF")
```

---

## See Also

- `../SETUP-GUIDE.md` - Complete setup guide
- `../Setup-Zsh-README.md` - Detailed Zsh setup documentation
- `../windows/Setup-Zsh-Windows.ps1` - Windows wrapper script
- `../windows/` - Windows scripts
- `../macos/` - macOS scripts
