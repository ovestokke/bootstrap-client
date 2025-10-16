# LazyVim Setup Guide

LazyVim transforms Neovim into a full-fledged IDE with minimal configuration. This guide covers installation and setup across all platforms supported by this bootstrap repository.

**Time estimate: 10-15 minutes**

---

## 📖 What is LazyVim?

LazyVim is a Neovim configuration framework powered by [lazy.nvim](https://github.com/folke/lazy.nvim) that provides:

- 🔥 Full IDE experience out of the box
- 💤 Easy customization and extension
- 🚀 Blazingly fast performance
- 🧹 Sane defaults for options, autocmds, and keymaps
- 📦 Wealth of pre-configured plugins

**Official Resources:**
- Website: https://www.lazyvim.org/
- GitHub: https://github.com/LazyVim/LazyVim
- Starter Template: https://github.com/LazyVim/starter

---

## ⚡ Requirements

### Essential
- ✓ **Neovim** >= 0.11.2 (built with LuaJIT)
- ✓ **Git** >= 2.19.0 (for partial clones)
- ✓ **Nerd Font** v3.0+ *(Already installed by Setup-WezTerm scripts!)*

### Highly Recommended
- ✓ **lazygit** - Git TUI integration
- ✓ **ripgrep** (rg) - Live grep in files
- ✓ **fd** - Find files
- ✓ **fzf** >= 0.25.1 - Fuzzy finder

### Optional
- **tree-sitter-cli** + C compiler - Syntax highlighting (auto-installed)
- **curl** - Completion engine requirement (usually pre-installed)

---

## 🚀 Installation

### Prerequisites Check

Run these commands to verify requirements:

```bash
# Check Neovim version (need >= 0.11.2)
nvim --version

# Check Git version (need >= 2.19.0)
git --version

# Check if Nerd Font is installed (should show MesloLGS NF)
fc-list | grep -i "meslo"  # Linux/WSL
```

### Platform-Specific Setup

<details>
<summary><b>macOS Installation</b></summary>

```bash
# Install Neovim and dependencies
brew install neovim lazygit ripgrep fd fzf

# Backup existing Neovim config (if any)
mv ~/.config/nvim{,.bak} 2>/dev/null
mv ~/.local/share/nvim{,.bak} 2>/dev/null
mv ~/.local/state/nvim{,.bak} 2>/dev/null
mv ~/.cache/nvim{,.bak} 2>/dev/null

# Clone LazyVim starter
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Remove .git folder to make it your own
rm -rf ~/.config/nvim/.git

# Start Neovim (will auto-install plugins)
nvim
```

**Note:** Nerd Font is already installed by `Setup-WezTerm.sh` (MesloLGS NF).

</details>

<details>
<summary><b>Linux/Ubuntu Installation</b></summary>

```bash
# Install Neovim (use official PPA for latest version)
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim

# Install dependencies
sudo apt install git curl build-essential

# Install modern tools
# fd
sudo apt install fd-find
ln -s $(which fdfind) ~/.local/bin/fd

# ripgrep
sudo apt install ripgrep

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

# Backup existing Neovim config (if any)
mv ~/.config/nvim{,.bak} 2>/dev/null
mv ~/.local/share/nvim{,.bak} 2>/dev/null
mv ~/.local/state/nvim{,.bak} 2>/dev/null
mv ~/.cache/nvim{,.bak} 2>/dev/null

# Clone LazyVim starter
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Remove .git folder
rm -rf ~/.config/nvim/.git

# Start Neovim
nvim
```

**Note:** Nerd Font is already installed by `Setup-Zsh-Linux.sh` (MesloLGS NF).

</details>

<details>
<summary><b>Windows/WSL Installation</b></summary>

**Install in WSL (Recommended):**

Follow the Linux/Ubuntu instructions above in your WSL environment.

**Install in Windows (PowerShell):**

```powershell
# Install Neovim via winget
winget install Neovim.Neovim

# Install lazygit
winget install JesseDuffield.lazygit

# Install ripgrep
winget install BurntSushi.ripgrep.MSVC

# Install fd
winget install sharkdp.fd

# Install fzf
winget install junegunn.fzf

# Backup existing config (if any)
Move-Item $env:LOCALAPPDATA\nvim $env:LOCALAPPDATA\nvim.bak -ErrorAction SilentlyContinue
Move-Item $env:LOCALAPPDATA\nvim-data $env:LOCALAPPDATA\nvim-data.bak -ErrorAction SilentlyContinue

# Clone LazyVim starter
git clone https://github.com/LazyVim/starter $env:LOCALAPPDATA\nvim

# Remove .git folder
Remove-Item $env:LOCALAPPDATA\nvim\.git -Recurse -Force

# Start Neovim
nvim
```

**Note:** Nerd Font is already installed by `Setup-WezTerm.ps1` (MesloLGS NF).

</details>

---

## 🎯 First Launch

When you first open Neovim after installation:

1. **LazyVim will automatically:**
   - Install lazy.nvim plugin manager
   - Download and install all configured plugins
   - Set up LSP servers, linters, and formatters
   - Configure keybindings and UI

2. **Wait for installation to complete** (1-3 minutes)
   - Watch the progress in the Lazy plugin manager UI
   - Don't close Neovim until all plugins show ✓

3. **Run health check:**
   ```vim
   :LazyHealth
   ```
   This verifies all dependencies are correctly installed.

4. **Restart Neovim** for best results after initial setup

---

## 📂 Configuration Structure

LazyVim uses a clean, organized structure:

```
~/.config/nvim/
├── lua/
│   ├── config/
│   │   ├── autocmds.lua    # Auto commands
│   │   ├── keymaps.lua     # Custom keybindings
│   │   ├── lazy.lua        # Lazy.nvim setup
│   │   └── options.lua     # Neovim options
│   └── plugins/
│       ├── example.lua     # Custom plugin configs
│       └── ...             # Add more plugin specs here
└── init.lua                # Entry point
```

**Key Files:**
- `lua/config/options.lua` - Add your Neovim settings (line numbers, tabs, etc.)
- `lua/config/keymaps.lua` - Define custom keybindings
- `lua/plugins/*.lua` - Configure or add plugins

---

## ⌨️ Essential Keybindings

LazyVim uses `<space>` as the leader key. Here are the most important keybindings:

### General
| Key | Description |
|-----|-------------|
| `<leader>?` | Show all keybindings |
| `<leader>l` | Open Lazy plugin manager |
| `<leader>:` | Command history |
| `<leader>qq` | Quit all |

### File Navigation
| Key | Description |
|-----|-------------|
| `<leader><space>` | Find files |
| `<leader>ff` | Find files |
| `<leader>fr` | Recent files |
| `<leader>fg` | Live grep (search in files) |
| `<leader>fb` | Find buffers |
| `<leader>e` | Toggle file explorer |

### Code
| Key | Description |
|-----|-------------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format document |

### Git (with lazygit)
| Key | Description |
|-----|-------------|
| `<leader>gg` | Open lazygit |
| `<leader>gb` | Git blame line |
| `<leader>gf` | Lazygit current file history |

### Terminal
| Key | Description |
|-----|-------------|
| `<C-/>` | Toggle terminal |
| `<C-_>` | Toggle terminal (alternative) |

**Full keymap reference:** https://www.lazyvim.org/keymaps

---

## 🎨 Customization

### Change Colorscheme

Create `~/.config/nvim/lua/plugins/colorscheme.lua`:

```lua
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",  -- or "tokyonight", "gruvbox", etc.
    },
  },
}
```

**Popular colorschemes:**
- `tokyonight` (default)
- `catppuccin`
- `gruvbox`
- `rose-pine`
- `nord`

### Add Custom Options

Edit `~/.config/nvim/lua/config/options.lua`:

```lua
-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.opt.relativenumber = false  -- Disable relative line numbers
vim.opt.wrap = true             -- Enable line wrap
vim.opt.tabstop = 4             -- 4 spaces for tabs
vim.opt.shiftwidth = 4          -- 4 spaces for indent
```

### Add Custom Keymaps

Edit `~/.config/nvim/lua/config/keymaps.lua`:

```lua
-- Keymaps are automatically loaded
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- Example: Save with Ctrl+S
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })

-- Example: Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
```

### Install Additional Plugins

Create a new file in `~/.config/nvim/lua/plugins/`, for example `~/.config/nvim/lua/plugins/extras.lua`:

```lua
return {
  -- Add GitHub Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({})
    end,
  },

  -- Add vim-surround
  {
    "tpope/vim-surround",
    event = "VeryLazy",
  },
}
```

---

## 🔌 LazyVim Extras

LazyVim includes optional "extras" for specific languages and tools. Enable them easily:

```vim
:LazyExtras
```

Browse and toggle extras:
- Language support (Python, Go, Rust, TypeScript, etc.)
- Linting and formatting
- DAP (debugging)
- UI enhancements
- Editor features

Or add them manually in `~/.config/nvim/lua/config/lazy.lua`:

```lua
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.formatting.prettier" },
    { import = "plugins" },
  },
})
```

---

## 🔧 Integration with Bootstrap Scripts

LazyVim works seamlessly with this bootstrap setup:

### ✅ Already Configured
- **Nerd Font** - MesloLGS NF installed by WezTerm setup
- **Terminal** - WezTerm with true color and undercurl support
- **Git** - Configured with SSH/GPG keys
- **Zsh** - Modern shell with Oh My Zsh and P10k

### 🔄 Recommended Workflow

1. **Run bootstrap scripts first:**
   ```bash
   # macOS
   curl -fsSL https://raw.githubusercontent.com/ovestokke/bootstrap-client/master/init-macos.sh | bash

   # Linux
   curl -fsSL https://raw.githubusercontent.com/ovestokke/bootstrap-client/master/init-linux.sh | bash
   ```

2. **Install LazyVim** (follow platform-specific steps above)

3. **Set Neovim as your default editor:**
   ```bash
   # Add to ~/.zshrc
   export EDITOR="nvim"
   export VISUAL="nvim"
   
   # Git integration
   git config --global core.editor "nvim"
   ```

4. **Add LazyVim config to dotfiles** (if using chezmoi)
   ```bash
   chezmoi add ~/.config/nvim
   ```

---

## 🆘 Troubleshooting

### Neovim Version Too Old

**Error:** `Neovim >= 0.11.2 is required`

**Solution:**
```bash
# macOS
brew upgrade neovim

# Linux - Use unstable PPA
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt upgrade neovim
```

### Missing Dependencies

**Error:** `command not found: rg` or `fd` or `fzf`

**Solution:**
```bash
# macOS
brew install ripgrep fd fzf

# Linux
sudo apt install ripgrep fd-find fzf
```

### Plugins Not Installing

1. Check internet connection
2. Run `:Lazy sync` to retry
3. Check `:Lazy log` for errors
4. Run `:LazyHealth` to diagnose issues

### LSP Not Working

1. Verify language server installed: `:Mason`
2. Install manually if needed: `:MasonInstall <server>`
3. Check `:LspInfo` for active servers
4. Restart Neovim

### Icons Not Showing

**Issue:** Square boxes instead of icons

**Solution:**
- Verify Nerd Font is installed and active in terminal
- Check WezTerm config uses: `config.font = wezterm.font("MesloLGS NF")`
- Restart terminal after font installation

### Treesitter Errors

**Error:** Parser compilation failed

**Solution:**
```bash
# Install C compiler
# macOS
xcode-select --install

# Linux
sudo apt install build-essential

# Then in Neovim
:TSUpdate
```

---

## 📚 Learning Resources

### Official Documentation
- **LazyVim Docs:** https://www.lazyvim.org/
- **lazy.nvim:** https://github.com/folke/lazy.nvim
- **Neovim Docs:** https://neovim.io/doc/

### Video Tutorials
- **Elijah Manor's Walkthrough:** https://www.youtube.com/watch?v=N93cTbtLCIM
- **LazyVim Playlist:** Search YouTube for "LazyVim tutorial"

### Books
- **LazyVim for Ambitious Developers:** https://lazyvim-ambitious-devs.phillips.codes (free online)

### Community
- **GitHub Discussions:** https://github.com/LazyVim/LazyVim/discussions
- **Discord/Matrix:** Links on LazyVim website

---

## 🔄 Updating

### Update LazyVim and Plugins

```vim
" Update all plugins
:Lazy sync

" Update specific plugin
:Lazy update <plugin-name>

" Check for LazyVim news
:LazyNews
```

### Update Core Dependencies

```bash
# macOS
brew upgrade neovim lazygit ripgrep fd fzf

# Linux
sudo apt update && sudo apt upgrade neovim
```

---

## 📋 Quick Reference

### Daily Commands
```vim
:Lazy           " Plugin manager
:Mason          " LSP/tool installer  
:LazyExtras     " Enable language/tool extras
:LazyHealth     " Health check
:e <file>       " Edit file
:w              " Save
:q              " Quit
:wq             " Save and quit
```

### File Navigation
```vim
<leader><space> " Find files (fuzzy)
<leader>fg      " Grep in files
<leader>e       " File explorer
```

### Editing
```vim
:Format         " Format document
:LazyFormat     " Format with LazyVim formatter
```

---

## ✨ Pro Tips

1. **Learn incrementally** - Don't try to learn everything at once
2. **Use `<leader>?`** - Shows all available keybindings
3. **Check `:LazyExtras`** - Enable language support as needed
4. **Customize gradually** - Start with defaults, add customizations slowly
5. **Read `:help`** - Neovim has excellent built-in documentation
6. **Join the community** - Ask questions in GitHub Discussions

---

## 🎯 Next Steps

After installing LazyVim:

1. ✅ Complete first launch and plugin installation
2. ✅ Run `:LazyHealth` to verify setup
3. ✅ Learn basic keybindings (`<leader>?` to see all)
4. ✅ Enable language support via `:LazyExtras`
5. ✅ Customize colorscheme and options
6. ✅ Set as default editor in shell/git
7. ✅ Practice with real projects
8. ✅ Explore advanced features over time

---

**Happy coding with LazyVim! 🚀**
