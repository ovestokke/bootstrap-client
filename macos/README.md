# macOS Setup Scripts

Bash scripts for macOS development environment setup.

## Planned: 
https://github.com/nikitabobko/AeroSpace
## Scripts

### Setup-Zsh-macOS.sh
**Main Zsh setup script** - Homebrew-based approach

- Installs Powerlevel10k theme via Homebrew
- Installs zsh-autosuggestions via Homebrew
- Installs zsh-syntax-highlighting via Homebrew
- Configures history search with arrow keys
- Installs eza (better ls) via Homebrew
- Installs zoxide (better cd) via Homebrew
- Sources plugins directly in `.zshrc` (no Oh My Zsh dependency)

**Prerequisites:**
- macOS 11+ (Big Sur or later)
- Homebrew installed: https://brew.sh/
- Zsh installed (default on macOS)

**Usage:**
```bash
bash macos/Setup-Zsh-macOS.sh
```

**After running:**
```bash
# Restart terminal or source config
source ~/.zshrc

# Run Powerlevel10k configuration wizard
p10k configure
```

**Time:** 10-15 minutes

---

### Setup-WezTerm.sh
Installs and configures WezTerm terminal emulator.

- Installs WezTerm via Homebrew
- Installs Meslo Nerd Font via `homebrew/cask-fonts`
- Copies `.wezterm.lua` configuration from repository root
- Fallback to manual font installation if Homebrew fails

**Prerequisites:**
- Homebrew installed

**Usage:**
```bash
bash macos/Setup-WezTerm.sh
```

**Time:** 5-10 minutes

---

### Setup-GitHubKeys.sh
Generates and uploads SSH/GPG keys to GitHub.

- Generates SSH ed25519 key
- Generates GPG 4096-bit RSA key
- Configures Git to auto-sign commits
- Uploads keys to GitHub via `gh` CLI

**Prerequisites:**
- Git installed
- GitHub CLI (`gh`) installed: `brew install gh`
- GPG installed: `brew install gnupg`

**Usage:**
```bash
bash macos/Setup-GitHubKeys.sh
```

**Time:** 10 minutes

---

## Recommended Order

Run scripts in this order for a complete macOS development setup:

1. Install Homebrew (if not already installed)
2. `Setup-WezTerm.sh` - Terminal setup
3. `Setup-Zsh-macOS.sh` - Zsh configuration with Powerlevel10k
4. `Setup-GitHubKeys.sh` - GitHub authentication

**Total time:** 30-45 minutes

---

## Updating Tools

All tools installed via Homebrew can be updated with:

```bash
brew update
brew upgrade
```

Specific updates:
```bash
# Update Zsh components
brew upgrade powerlevel10k zsh-autosuggestions zsh-syntax-highlighting

# Update CLI tools
brew upgrade eza zoxide

# Update WezTerm
brew upgrade --cask wezterm
```

---

## Differences from Linux/WSL Setup

| Feature | macOS | Linux/WSL |
|---------|-------|-----------|
| Package Manager | Homebrew | apt + git clone |
| Framework | None (direct sourcing) | Oh My Zsh |
| P10k Install | `brew install` | `git clone` |
| Plugins | Source in `.zshrc` | Oh My Zsh plugins |
| Font Install | `brew install --cask` | Manual to `~/.local/share/fonts` |
| Updates | `brew upgrade` | `git pull` + `apt upgrade` |

Both approaches result in the same functionality, just using platform-appropriate tools.

---

## See Also

- `../SETUP-GUIDE.md` - Complete setup guide
- `../Setup-Zsh-README.md` - Detailed Zsh setup documentation
- `../.wezterm.lua` - WezTerm configuration file
- `../windows/` - Windows scripts
- `../linux/` - Linux/WSL scripts
