# macOS Setup Scripts

**Minimalist approach:** Scripts install packages only. Configuration is managed by chezmoi.

---

## 🎯 Philosophy

This setup separates concerns cleanly:
- **Scripts** → Install tools (Homebrew, WezTerm, Neovim, etc.)
- **chezmoi** → Manage ALL configuration files

Your dotfiles repo (via chezmoi) controls:
- `.wezterm.lua` - Terminal config
- `.zshrc` - Shell config with Oh My Zsh, P10k, aliases
- `~/.config/nvim/` - Neovim/LazyVim config
- `.gitconfig` - Git configuration
- Any other dotfiles

---

## 📋 Scripts

### setup-essentials.sh
**Foundation setup** - Run this first!

**What it installs:**
- Homebrew (macOS package manager)
- Git (version control)
- chezmoi (dotfile manager)
- Basic utilities (curl, wget)

**What it does:**
- Prompts to initialize chezmoi with your dotfiles repo
- Interactive setup: `chezmoi init --apply https://github.com/yourusername/dotfiles.git`

**Prerequisites:**
- macOS 11+ (Big Sur or later)
- Internet connection

**Usage:**
```bash
bash macos/setup-essentials.sh
```

**Time:** 3-5 minutes

---

### setup-packages.sh
**Package installation** - Installs all development tools

**What it installs:**
- **Terminal:** WezTerm, Meslo Nerd Font
- **Shell:** Oh My Zsh, Powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting
- **CLI Tools:** eza, zoxide, fzf, ripgrep, fd
- **Development:** Neovim (>= 0.11.2), lazygit
- **Git Tools:** GitHub CLI (gh), GPG

**What it does NOT do:**
- ❌ No configuration file writing
- ❌ No `.zshrc` modifications
- ❌ No `.wezterm.lua` copying
- ❌ No Neovim config setup

**Prerequisites:**
- Homebrew installed (run setup-essentials.sh first)

**Usage:**
```bash
bash macos/setup-packages.sh
```

**Time:** 10-15 minutes

---

## 🚀 Recommended Workflow

### Quick Start (One Command)
```bash
curl -fsSL https://raw.githubusercontent.com/ovestokke/bootstrap-client/master/init-macos.sh | bash
```

Then choose **Option 4: Run complete setup**

### Manual Setup
```bash
cd macos

# Step 1: Install Homebrew, Git, chezmoi (initialize with your dotfiles)
bash setup-essentials.sh

# Step 2: Install all packages (WezTerm, Neovim, Zsh plugins, etc.)
bash setup-packages.sh

# Step 3: Apply your dotfiles
chezmoi apply

# Done! Launch WezTerm and run p10k configure
```

**Total time:** 15-20 minutes

---

## 📦 What You Get

After complete setup:

✅ **Package Manager** - Homebrew  
✅ **Version Control** - Git  
✅ **Dotfile Manager** - chezmoi (with your dotfiles applied)  
✅ **Terminal** - WezTerm with Nerd fonts  
✅ **Shell Framework** - Oh My Zsh + Powerlevel10k  
✅ **Shell Plugins** - Autosuggestions + syntax highlighting  
✅ **Modern CLI** - eza, zoxide, fzf, ripgrep, fd  
✅ **Editor** - Neovim + LazyVim (via your dotfiles)  
✅ **Git Tools** - GitHub CLI + GPG  

**All configured via your chezmoi dotfiles!**

---

## 🔄 Configuration Management

### Your Dotfiles (chezmoi)

```bash
# Check status
chezmoi status

# View diff before applying
chezmoi diff

# Apply dotfiles
chezmoi apply

# Edit a dotfile
chezmoi edit ~/.zshrc

# Edit and apply immediately
chezmoi edit --apply ~/.wezterm.lua

# Update from remote
chezmoi update

# Go to source directory
chezmoi cd
```

### Quick Aliases (if in your .zshrc)
```bash
ch         # chezmoi
chst       # chezmoi status
chd        # chezmoi diff
che        # chezmoi edit
chea       # chezmoi edit --apply
chap       # chezmoi apply
chup       # chezmoi update
chcd       # chezmoi cd
```

---

## 🔄 Updating

### Update Packages
```bash
# Update Homebrew itself
brew update

# Upgrade all installed packages
brew upgrade

# Upgrade specific package
brew upgrade neovim
```

### Update Oh My Zsh
```bash
# In your terminal (if set up in dotfiles)
omz update
```

### Update Neovim Plugins
```bash
nvim
:Lazy sync
```

### Update Dotfiles
```bash
# Pull latest changes and apply
chezmoi update
```

---

## 💡 Key Differences from Old Scripts

| Old Approach | New Approach |
|--------------|--------------|
| Scripts write to `.zshrc` | chezmoi manages `.zshrc` |
| Scripts copy `.wezterm.lua` | chezmoi manages `.wezterm.lua` |
| Scripts create nvim config | chezmoi manages `~/.config/nvim/` |
| 5 separate scripts | 2 install scripts + chezmoi |
| Config scattered | Single source of truth (dotfiles) |

---

## 🆘 Troubleshooting

### chezmoi Not Initialized
```bash
# Initialize with your dotfiles repo
chezmoi init --apply https://github.com/yourusername/dotfiles.git
```

### Dotfiles Not Applied
```bash
# Check what would change
chezmoi diff

# Apply dotfiles
chezmoi apply

# Or do a dry run first
chezmoi apply --dry-run --verbose
```

### Oh My Zsh Not Installed
```bash
# Install manually (if setup-packages.sh failed)
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Powerlevel10k Not Showing
```bash
# Run configuration wizard
p10k configure

# Or check if sourced in your .zshrc
grep "powerlevel10k" ~/.zshrc
```

### Neovim Version Too Old
```bash
# Upgrade Neovim
brew upgrade neovim

# Verify version (need >= 0.11.2)
nvim --version
```

---

## 📚 Documentation

- **Main README**: ../README.md
- **Quick Reference**: ../QUICK-REFERENCE.md (commands, tips)
- **Contributing**: ../CONTRIBUTING.md (code style)
- **LazyVim Guide**: ../Setup-LazyVim-README.md
- **Zsh Guide**: ../Setup-Zsh-README.md

---

## 🔗 Reference Links

- **Homebrew**: https://brew.sh/
- **chezmoi**: https://www.chezmoi.io/
- **WezTerm**: https://wezfurlong.org/wezterm/
- **Oh My Zsh**: https://ohmyz.sh/
- **Powerlevel10k**: https://github.com/romkatv/powerlevel10k
- **LazyVim**: https://www.lazyvim.org/

---

## 💭 Philosophy

**Why separate installation from configuration?**

1. **Single source of truth** - Your dotfiles repo controls all configs
2. **Portability** - Same dotfiles work on multiple machines
3. **Version control** - Track config changes in git
4. **Flexibility** - Change configs without re-running scripts
5. **Simplicity** - Scripts just install, chezmoi does the rest

**The bootstrap scripts get you 80% there. Your dotfiles make it 100% yours.**

---

**Ready for a clean macOS dev setup! 🚀**
