# Quick Reference Guide

Personal reference for commands, tips, and troubleshooting.

---

## ⏱️ Time Estimates

| Platform | Setup Type | Time | Notes |
|----------|-----------|------|-------|
| **macOS** | Full setup | 40-60 min | All scripts including LazyVim |
| | Without LazyVim | 25-40 min | Skip Neovim setup |
| | Individual scripts | 5-15 min each | Run specific components |
| **Windows** | Full (60+ apps) | ~2 hours | System + all apps + dev tools |
| | Basic (15 apps) | ~1 hour | System + essential apps |
| | Skip apps | ~45 min | System setup + dev tools only |
| **Linux** | Full setup | 30-40 min | All scripts including LazyVim |
| | Without LazyVim | 15-20 min | Shell + GitHub keys only |

---

## 🎨 Customization

### WezTerm Configuration

Edit `~/.wezterm.lua` (Windows: `%USERPROFILE%\.wezterm.lua`):

```lua
-- Color scheme
config.color_scheme = 'Catppuccin Mocha'  -- or 'Tokyo Night', 'Gruvbox', etc.

-- Font size
config.font_size = 12  -- Adjust to preference

-- Opacity
config.window_background_opacity = 0.98  -- 0.0 to 1.0

-- Default program (Windows WSL)
config.default_prog = { 'wsl.exe', '-d', 'Ubuntu' }

-- macOS default shell
config.default_prog = { 'zsh' }
```

Popular color schemes:
- `Catppuccin Mocha` (dark, purple/blue)
- `Tokyo Night`
- `Gruvbox`
- `Nord`
- `Dracula`

**Full config docs**: https://wezfurlong.org/wezterm/config/files.html

---

### Zsh Configuration

Edit `~/.zshrc`:

```bash
# Custom aliases
alias ll='ls -la'
alias g='git'
alias dc='docker-compose'
alias k='kubectl'

# Environment variables
export EDITOR="nvim"
export VISUAL="nvim"
export PATH="$HOME/bin:$PATH"

# Additional Oh My Zsh plugins (Linux/WSL only)
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker kubectl terraform 1password)
```

**Reconfigure Powerlevel10k anytime:**
```bash
p10k configure
```

---

### Eza (ls replacement)

```bash
# Already set in .zshrc, but can customize:
alias ls='eza --icons=always --group-directories-first'
alias ll='eza --icons=always --long --group-directories-first'
alias la='eza --icons=always --long --all --group-directories-first'
alias lt='eza --icons=always --tree --group-directories-first'

# Show git status in list
alias lg='eza --icons=always --long --git'
```

---

### Zoxide (cd replacement)

```bash
# Already set in .zshrc
alias cd='z'
alias cdi='zi'  # Interactive selection

# View frecency database
zoxide query --list

# Clear database
zoxide query --list | sed 's/^[0-9.]* //' | xargs -I {} zoxide remove {}
```

---

### Git Configuration

```bash
# View current config
git config --global --list

# Change commit signing
git config --global commit.gpgsign true  # Enable
git config --global commit.gpgsign false # Disable

# Change default editor
git config --global core.editor "nvim"
git config --global core.editor "code --wait"

# Git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st status
git config --global alias.cm "commit -m"
git config --global alias.last "log -1 HEAD"
git config --global alias.unstage "reset HEAD --"
```

---

### LazyVim Configuration

**Change colorscheme** - Create `~/.config/nvim/lua/plugins/colorscheme.lua`:

```lua
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",  -- latte, frappe, macchiato, mocha
      transparent_background = false,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
```

**Custom options** - Edit `~/.config/nvim/lua/config/options.lua`:

```lua
vim.opt.relativenumber = false  -- Absolute line numbers
vim.opt.wrap = true             -- Enable line wrap
vim.opt.tabstop = 4             -- 4 spaces for tabs
vim.opt.shiftwidth = 4          -- 4 spaces for indent
```

**Custom keymaps** - Edit `~/.config/nvim/lua/config/keymaps.lua`:

```lua
local map = vim.keymap.set

map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
```

---

## 🔄 Updating

### macOS

```bash
# Update Homebrew packages
brew update && brew upgrade

# Update Oh My Zsh (if installed)
omz update

# Update LazyVim
nvim
:Lazy sync
```

### Windows

```powershell
# Update all winget packages
winget upgrade --all

# Update specific package
winget upgrade --id Microsoft.VisualStudioCode
```

### Linux/WSL

```bash
# Update system packages
sudo apt update && sudo apt upgrade

# Update Oh My Zsh
omz update

# Update Powerlevel10k
cd ~/.oh-my-zsh/custom/themes/powerlevel10k && git pull

# Update plugins
cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull
cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull

# Update LazyVim
nvim
:Lazy sync
```

### chezmoi

```bash
# Update dotfiles from remote
chezmoi update

# Or manually
chezmoi cd
git pull
chezmoi apply
```

---

## 🆘 Troubleshooting

### Zsh

**Zsh not default shell:**
```bash
chsh -s $(which zsh)
# Then logout and login
```

**Powerlevel10k not showing:**
```bash
# Check theme is set
grep ZSH_THEME ~/.zshrc

# Should show:
# ZSH_THEME="powerlevel10k/powerlevel10k"  (Linux/WSL)
# or sourcing powerlevel10k.zsh-theme (macOS)

# Reconfigure
p10k configure
```

**Icons not showing:**
- Verify Nerd Font is installed: `fc-list | grep -i meslo`
- Check terminal uses Nerd Font (WezTerm should auto-detect)
- Restart terminal after font installation

---

### WezTerm

**Config not loading:**
```bash
# Check file exists
ls -la ~/.wezterm.lua  # macOS/Linux
dir $env:USERPROFILE\.wezterm.lua  # Windows

# Check for syntax errors
wezterm start --config-file ~/.wezterm.lua
```

**Font issues:**
- Install Meslo Nerd Font manually from: https://www.nerdfonts.com/
- Set in config: `config.font = wezterm.font("MesloLGS NF")`
- Restart WezTerm

---

### Git/GitHub

**SSH connection fails:**
```bash
# Test connection
ssh -T git@github.com

# Check SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Verify key uploaded
gh ssh-key list
```

**GPG signing fails:**
```bash
# List keys
gpg --list-secret-keys --keyid-format LONG

# Check git config
git config --global user.signingkey

# Test signing
echo "test" | gpg --clearsign
```

---

### LazyVim

**Plugins not installing:**
```vim
" Retry sync
:Lazy sync

" Check logs
:Lazy log

" Health check
:LazyHealth
```

**LSP not working:**
```vim
" Check active servers
:LspInfo

" Install language server
:Mason
" Browse and install with 'i'

" Or install specific server
:MasonInstall lua-language-server
```

**Treesitter errors:**
```bash
# macOS - Install Xcode CLI tools
xcode-select --install

# Linux - Install build tools
sudo apt install build-essential

# Then in Neovim
:TSUpdate
```

---

### chezmoi

**Init fails:**
```bash
# Check chezmoi is installed
which chezmoi
chezmoi --version

# Re-init with clean state
chezmoi init --apply https://github.com/username/dotfiles.git
```

**Diff shows unexpected changes:**
```bash
# View diff
chezmoi diff

# See what will change
chezmoi apply --dry-run --verbose

# Apply selectively
chezmoi apply path/to/file
```

---

## 📋 Daily Commands

### Zsh

```bash
# Reload config
source ~/.zshrc

# Reconfigure Powerlevel10k
p10k configure

# List aliases
alias

# History search
# Start typing, then press UP arrow
```

### Git

```bash
# Daily workflow
git st                    # Status
git add .                 # Stage all
git cm "message"          # Commit
git push                  # Push

# Branch management
git br                    # List branches
git co -b feature-name    # Create branch
git co main               # Switch branch

# Undo changes
git unstage file.txt      # Unstage file
git restore file.txt      # Discard changes
```

### LazyVim

```vim
" Plugin management
:Lazy                     " Open Lazy manager
:Lazy sync                " Update plugins
:LazyExtras               " Browse extras

" LSP/Tools
:Mason                    " Open Mason (LSP installer)
:LspInfo                  " Show active LSP servers
:LazyHealth               " Health check

" File navigation
<leader><space>           " Find files (fuzzy)
<leader>ff                " Find files
<leader>fg                " Grep in files
<leader>fb                " Find buffers
<leader>e                 " File explorer

" Code actions
gd                        " Go to definition
gr                        " Go to references
K                         " Hover documentation
<leader>ca                " Code actions
<leader>cr                " Rename symbol
<leader>cf                " Format document

" Git
<leader>gg                " Open lazygit
<leader>gb                " Git blame line
```

### chezmoi

```bash
# Daily workflow
chst                      " Status
chd                       " Diff
che ~/.zshrc              " Edit file
chea ~/.zshrc             " Edit and apply
chap                      " Apply changes
chup                      " Update from remote

# Add new dotfiles
cha ~/.config/newfile

# Re-add modified
chr ~/.zshrc
```

---

## 💡 Pro Tips

### Zsh

1. **Use `z` instead of `cd`** - Zoxide learns your habits
   ```bash
   z projects      # Jumps to most frecent match
   z proj doc      # Multiple keywords
   zi              # Interactive selection
   ```

2. **Arrow key history** - Start typing, press UP for matching history

3. **Tab completion** - Works for commands, paths, git branches, etc.

### Git

1. **Use aliases** - Faster workflow
   ```bash
   g st            # git status (if 'g' alias set)
   git cm "msg"    # git commit -m
   ```

2. **Auto-signed commits** - Already configured by setup-github scripts

3. **Branch autocomplete** - Tab complete branch names:
   ```bash
   git co feat<TAB>  # Completes to feature-branch
   ```

### LazyVim

1. **Press `<leader>?`** - Shows ALL keybindings

2. **Use `:LazyExtras`** - Enable language support as needed
   - TypeScript, Python, Go, Rust, etc.
   - Formatting, linting, debugging

3. **Learn incrementally** - Start with basic keybindings, add more over time

4. **Use `:Telescope`** - Fuzzy find everything

### chezmoi

1. **Use templates** - Machine-specific configs
   ```bash
   # In dotfile: .zshrc.tmpl
   {{ if eq .chezmoi.os "darwin" }}
   # macOS specific
   {{ else if eq .chezmoi.os "linux" }}
   # Linux specific
   {{ end }}
   ```

2. **Encrypt secrets** - Use chezmoi's encryption for sensitive data

3. **Quick sync** - Make changes and push
   ```bash
   che ~/.zshrc      # Edit
   chap              # Apply locally
   chcd              # Go to source dir
   git add -A && git commit -m "update" && git push
   cd -              # Return
   ```

---

## 🔗 Useful Links

### Documentation
- WezTerm: https://wezfurlong.org/wezterm/
- Oh My Zsh: https://ohmyz.sh/
- Powerlevel10k: https://github.com/romkatv/powerlevel10k
- LazyVim: https://www.lazyvim.org/
- chezmoi: https://www.chezmoi.io/
- eza: https://github.com/eza-community/eza
- zoxide: https://github.com/ajeetdsouza/zoxide

### Nerd Fonts
- Download: https://www.nerdfonts.com/
- Already installed: MesloLGS NF

### Colorschemes
- Catppuccin: https://github.com/catppuccin/catppuccin
- Tokyo Night: https://github.com/folke/tokyonight.nvim
- Gruvbox: https://github.com/morhetz/gruvbox
- Nord: https://www.nordtheme.com/

---

**Last updated**: October 2025
