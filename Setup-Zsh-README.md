# Zsh + Powerlevel10k Setup Guide

This repository includes cross-platform scripts to setup Zsh with Powerlevel10k theme and modern CLI tools.

Based on: [Josean's WezTerm Terminal Setup Guide](https://www.josean.com/posts/how-to-setup-wezterm-terminal)

## What Gets Installed

All scripts install the same tools with platform-appropriate methods:

- **Zsh** - Modern shell (replaces bash)
- **Powerlevel10k** - Beautiful and fast prompt theme
- **zsh-autosuggestions** - Fish-like autosuggestions
- **zsh-syntax-highlighting** - Syntax highlighting as you type
- **eza** - Better `ls` command with colors and icons
- **zoxide** - Smart `cd` command that learns your habits
- **Meslo Nerd Font** - Font with icons support

## Platform-Specific Scripts

### macOS: `Setup-Zsh-macOS.sh`

**Prerequisites:**
- macOS (tested on macOS 11+)
- [Homebrew](https://brew.sh/) installed

**Installation:**
```bash
bash macos/Setup-Zsh-macOS.sh
```

**Features:**
- Installs everything via Homebrew (clean and updatable)
- No Oh My Zsh dependency (lighter and faster)
- Sources plugins directly in `.zshrc`

---

### Linux/Ubuntu/WSL: `Setup-Zsh-Linux.sh`

**Prerequisites:**
- Ubuntu, Debian, or WSL with Ubuntu
- `apt` package manager
- `sudo` access

**Installation:**
```bash
bash linux/Setup-Zsh-Linux.sh
```

**Features:**
- Installs Oh My Zsh as plugin framework
- Uses git clone for Powerlevel10k and plugins
- Falls back to third-party repositories for eza/zoxide if needed
- Installs Meslo Nerd Font to `~/.local/share/fonts`

---

### Windows (PowerShell): `Setup-Zsh-Windows.ps1`

**Prerequisites:**
- Windows 10/11 with WSL installed
- PowerShell (Admin not required)
- At least one WSL distribution installed (Ubuntu recommended)

**Installation:**
```powershell
cd windows && .\Setup-Zsh-Windows.ps1
```

**How it works:**
- Detects installed WSL distributions
- Lets you choose which distribution to configure
- Runs `Setup-Zsh-Linux.sh` inside the selected WSL distribution
- Provides instructions for WezTerm WSL integration

---

## Post-Installation

After running any of the scripts:

### 1. Restart Your Terminal
```bash
# Source the new configuration
source ~/.zshrc

# Or close and reopen your terminal
```

### 2. Run Powerlevel10k Configuration Wizard
```bash
p10k configure
```

**Tips for the wizard:**
- Choose **Lean** (8 colors) or **Rainbow** style for coolnight theme compatibility
- If using rainbow style, set directory background color to black in `~/.p10k.zsh`:
  ```zsh
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=0
  ```

### 3. Start Using New Commands

**eza (better ls):**
```bash
ls                    # Now uses eza with icons
ls -l                 # Long format
ls -la                # Long format with hidden files
ls --tree             # Tree view
```

**zoxide (better cd):**
```bash
cd ~/projects         # First visit
cd /etc              # Go somewhere else
z proj               # Jump back to ~/projects (partial match!)
z etc                # Jump to /etc
```

**History search:**
- Type start of command and press **UP/DOWN** arrows to search history
- Press **RIGHT** arrow to accept autosuggestions

---

## Configuration Files

### `.zshrc`
Main Zsh configuration file located at `~/.zshrc`

Contains:
- Plugin configuration
- History settings
- Aliases for eza and zoxide
- Key bindings

### `.p10k.zsh`
Powerlevel10k theme configuration at `~/.p10k.zsh`

Created after running `p10k configure`

---

## Unified Configuration

All scripts configure the same features:

### History Configuration
```zsh
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
```

### Arrow Key History Search
```zsh
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
```

### Aliases
```zsh
# Eza (better ls)
alias ls="eza --icons=always"

# Zoxide (better cd)
eval "$(zoxide init zsh)"
alias cd="z"
```

---

## Integration with WezTerm

### macOS/Linux
WezTerm should automatically use your default shell (Zsh) after changing it with:
```bash
chsh -s $(which zsh)
```

### Windows/WSL
Add to your `.wezterm.lua`:
```lua
config.default_prog = { 'wsl.exe', '-d', 'Ubuntu' }
```

Replace `'Ubuntu'` with your WSL distribution name.

---

## Troubleshooting

### Fonts not showing icons
- Ensure Meslo Nerd Font is installed
- Configure your terminal to use "MesloLGS NF" or "MesloLGS Nerd Font Mono"
- In WezTerm: `config.font = wezterm.font("MesloLGS NF")`

### Plugins not working
- Check if Oh My Zsh is installed (Linux only): `[ -d ~/.oh-my-zsh ] && echo "Installed"`
- Verify plugins are sourced: `grep -E "(autosuggestions|syntax-highlighting)" ~/.zshrc`
- Restart terminal or run: `source ~/.zshrc`

### zoxide not finding directories
- Visit directories first before jumping to them
- zoxide learns from your usage over time
- Check database: `zoxide query --list`

### Permission issues (Linux/WSL)
- Ensure script is executable: `chmod +x Setup-Zsh-Linux.sh`
- Run with bash explicitly: `bash linux/Setup-Zsh-Linux.sh`

---

## Updating

### macOS
```bash
brew update
brew upgrade powerlevel10k zsh-autosuggestions zsh-syntax-highlighting eza zoxide
```

### Linux/Ubuntu/WSL
```bash
# Update Powerlevel10k
cd ~/.oh-my-zsh/custom/themes/powerlevel10k
git pull

# Update plugins
cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git pull

cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git pull

# Update tools
sudo apt update
sudo apt upgrade eza zoxide
```

---

## Differences Between Scripts

| Feature | macOS | Linux/WSL |
|---------|-------|-----------|
| Package Manager | Homebrew | apt + manual |
| Framework | None | Oh My Zsh |
| P10k Install | `brew install` | `git clone` |
| Plugins | Source in `.zshrc` | Oh My Zsh plugins |
| Updates | `brew upgrade` | `git pull` + `apt` |

Both approaches result in the same functionality, just using platform-appropriate tools.

---

## References

- [Josean's WezTerm Terminal Setup](https://www.josean.com/posts/how-to-setup-wezterm-terminal)
- [Powerlevel10k GitHub](https://github.com/romkatv/powerlevel10k)
- [Oh My Zsh](https://ohmyz.sh/)
- [eza GitHub](https://github.com/eza-community/eza)
- [zoxide GitHub](https://github.com/ajeetdsouza/zoxide)

---

## Need Help?

Check the reference guide or open an issue on the repository.

For WezTerm-specific configuration, see `.wezterm.lua` in this repository.
