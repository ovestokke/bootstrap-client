# Complete Windows Fresh Install Setup Guide

This guide walks you through setting up a fresh Windows 11 installation with all development tools, terminal configuration, and modern CLI utilities.

**Total estimated time: 1-2 hours** (mostly automated)

---

## Prerequisites

- Fresh Windows 11 installation
- Administrator access
- Internet connection
- **That's it!** No need to manually clone the repository

**Note:** Scripts are now organized by platform in `windows/`, `macos/`, and `linux/` folders.

---

## ⚡ Quick Start (Recommended)

Open PowerShell **as Administrator** and run this single command:

```powershell
irm https://raw.githubusercontent.com/ovestokke/bootstrap-client/master/Init-Windows.ps1 | iex
```

This will:
1. Install Git via winget
2. Clone the repository to a location of your choice (defaults to C:\bootstrap-client)
3. Ask if you want to use HTTPS (default), SSH, or a custom URL (for forks)
4. Launch Setup-Windows.ps1 automatically

**Then continue with the remaining setup scripts as described below.**

---

## 📦 Manual Setup (If Repository Already Cloned)

### Step 1: Prepare PowerShell

Open PowerShell **as Administrator** and navigate to this directory:

```powershell
cd C:\path\to\bootstrap-client\windows
```

Set execution policy:

```powershell
Set-ExecutionPolicy Unrestricted -Force
```

---

## Phase 1: Windows System Setup (30-45 minutes)

### Step 2: Run Main Windows Setup Script

This script will:
- ✓ Remove Windows bloatware
- ✓ Configure privacy settings
- ✓ Enable Developer Mode
- ✓ Install WSL with Ubuntu
- ✓ Install applications via winget (you choose the mode)

```powershell
cd windows && .\Setup-Windows.ps1
```

**Installation Modes:**

You'll be prompted to choose:
1. **Skip** - No applications (system setup only)
2. **Basic** - Essential apps only (~15 apps)
   - Browsers, core dev tools, terminal, 1Password, Obsidian, PowerToys, 7zip
3. **Full** - All applications (~60+ apps)
   - Everything from Basic + extended dev tools, productivity, media, gaming, etc.

**Notes:**
- The script will log everything to `Setup-Windows-Log-[timestamp].txt`
- You may need to reboot after WSL installation
- The script will prompt you if you want to change the computer name
- NVIDIA App will be downloaded and installed automatically (regardless of mode)

**Expected output:**
- Bloatware removed
- Privacy settings applied
- Applications installed based on your choice
- WSL with Ubuntu ready to use

---

## Phase 2: Terminal Setup (15-20 minutes)

### Step 3: Install and Configure WezTerm

WezTerm is a modern, GPU-accelerated terminal with great features.

```powershell
.\windows\Setup-WezTerm.ps1
```

**What this does:**
- Installs WezTerm via winget (if not already installed)
- Downloads and installs Meslo Nerd Font
- Copies `.wezterm.lua` configuration to your home directory

**After installation:**
- Launch WezTerm from Start Menu
- It will automatically use the Meslo Nerd Font
- Keybindings are configured (CTRL+\ for split, CTRL+h/j/k/l for navigation)

### Step 4: Configure Zsh in WSL

This sets up Zsh with Powerlevel10k theme and modern CLI tools inside WSL.

```powershell
.\windows\Setup-Zsh-Windows.ps1
```

**What this does:**
- Detects your WSL distributions
- Runs `Setup-Zsh-Linux.sh` inside WSL
- Installs Oh My Zsh, Powerlevel10k, plugins (autosuggestions, syntax-highlighting)
- Installs eza (better ls) and zoxide (better cd)
- Installs Meslo Nerd Font in WSL

**After installation:**
1. Launch WSL: `wsl -d Ubuntu`
2. Run the Powerlevel10k configuration wizard: `p10k configure`
3. Choose your preferred style (Lean or Rainbow recommended)

---

## Phase 3: Development Tools Setup (10-15 minutes)

### Step 5: Configure GitHub SSH & GPG Keys

This will generate SSH and GPG keys and upload them to GitHub.

```powershell
.\windows\Setup-GitHubKeys.ps1
```

**What this does:**
- Checks for existing SSH/GPG keys
- Generates new ed25519 SSH key
- Generates new 4096-bit RSA GPG key
- Configures Git to sign commits automatically
- Uploads keys to GitHub via `gh` CLI

**You'll need:**
- Your GitHub email address
- Your full name for Git config
- GitHub authentication (script will prompt via `gh auth login`)

**After setup:**
- Test SSH connection: `ssh -T git@github.com`
- All commits will be automatically signed

---

## Phase 4: Configure WezTerm to Use WSL (Optional)

To make WezTerm launch directly into WSL:

1. Open `%USERPROFILE%\.wezterm.lua` in your editor
2. Add this line in the config section:

```lua
config.default_prog = { 'wsl.exe', '-d', 'Ubuntu' }
```

3. Save and restart WezTerm

---

## Verification Checklist

After completing all steps, verify your setup:

### Windows
- [ ] Bloatware removed (check Start Menu)
- [ ] Privacy settings applied
- [ ] File extensions visible in Explorer
- [ ] Applications installed based on selected mode (Skip/Basic/Full)
- [ ] WSL installed and working: `wsl --list --verbose`

### Terminal
- [ ] WezTerm installed and configured
- [ ] Meslo Nerd Font displaying icons correctly
- [ ] WezTerm keybindings work (CTRL+\ splits pane)

### WSL/Zsh
- [ ] Zsh is default shell: `echo $SHELL` shows `/usr/bin/zsh`
- [ ] Powerlevel10k theme displays correctly
- [ ] Autosuggestions work (type partial command, see gray suggestion)
- [ ] Syntax highlighting works (valid commands in green, invalid in red)
- [ ] eza works: `ls` shows colored output with icons
- [ ] zoxide works: `cd` or `z` for smart directory jumping
- [ ] Arrow keys search history (type `git` then UP arrow)

### Git/GitHub
- [ ] SSH key uploaded to GitHub
- [ ] GPG key uploaded to GitHub
- [ ] SSH connection works: `ssh -T git@github.com`
- [ ] Git signing configured: `git config --global commit.gpgsign` shows `true`
- [ ] Test signed commit works

---

## Customization

### Applications List

**Choose installation mode during setup** or customize the app lists:

- **Basic mode** (`windows/Apps-List-Basic.txt`): Edit to customize essential apps (~15)
- **Full mode** (`windows/Apps-List-Full.txt`): Edit to customize complete installation (~60+)

**To customize:**
- Add new applications (find IDs with `winget search "AppName"`)
- Comment out applications you don't need with `#`
- Or choose "Skip" mode and install apps manually later

### WezTerm Configuration

Edit `%USERPROFILE%\.wezterm.lua` to customize:
- Color scheme (line 9): `config.color_scheme = 'Batman'`
- Font size (line 13): `config.font_size = 14`
- Keybindings (lines 45-312)
- Opacity (line 23): `config.window_background_opacity = 0.98`

### Zsh Configuration

Edit `~/.zshrc` (in WSL) to customize:
- Add custom aliases
- Install additional Oh My Zsh plugins
- Modify eza or zoxide settings

Edit `~/.p10k.zsh` (in WSL) to customize Powerlevel10k theme:
- Change colors
- Add/remove segments
- Adjust prompt layout

---

## Troubleshooting

### Setup-Windows.ps1 Issues

**"Script must be run as Administrator"**
- Right-click PowerShell and select "Run as Administrator"

**"Execution policy error"**
- Run: `Set-ExecutionPolicy Unrestricted -Force`

**WSL installation requires reboot**
- Reboot and run `Setup-Windows.ps1` again
- It will skip completed steps and continue

**Application installation fails**
- Check exit code in the log file
- -1978335189 means already installed (not an error)
- Other codes: verify package ID with `winget search "AppName"`

### WezTerm Issues

**Font not showing icons**
- Verify Meslo Nerd Font is installed in Windows Fonts
- Check WezTerm config uses: `config.font = wezterm.font("MesloLGS NF")`
- Restart WezTerm

**Config file not found**
- Should be at: `%USERPROFILE%\.wezterm.lua`
- Check with: `echo %USERPROFILE%\.wezterm.lua`

### Zsh/WSL Issues

**Zsh not default shell**
- Run in WSL: `chsh -s $(which zsh)`
- Logout and login to WSL

**Powerlevel10k not showing**
- Check `.zshrc` has: `ZSH_THEME="powerlevel10k/powerlevel10k"`
- Run: `source ~/.zshrc`
- Run wizard: `p10k configure`

**eza or zoxide not found**
- Verify installation: `command -v eza` and `command -v zoxide`
- Re-run: `bash linux/Setup-Zsh-Linux.sh`

**Icons not showing in WSL**
- Ensure Meslo Nerd Font is installed in WSL: `fc-list | grep -i meslo`
- Configure WezTerm to use the font
- Some icons require the terminal to support true color

### GitHub Keys Issues

**gh CLI not found**
- Install: `winget install --id GitHub.cli -e`
- Restart PowerShell

**GPG not found**
- Install: `winget install --id GnuPG.GnuPG -e`

**SSH connection fails**
- Check key was uploaded: `gh ssh-key list`
- Verify SSH agent is running
- Test connection: `ssh -T git@github.com`

---

## Complementary Tools (Optional)

### Chris Titus Tech WinUtil
Community-driven Windows maintenance and tweaking utility. Run it AFTER this guide's automated scripts if you want to:
- Apply additional GUI privacy / telemetry tweaks
- Inspect and selectively disable services / scheduled tasks
- Perform further debloat beyond curated defaults
- Audit Microsoft Store apps and remove leftovers
- Apply selective performance or UI adjustments

Launch (PowerShell as Administrator):
```powershell
irm "https://christitus.com/win" | iex
```

Best Practices:
- Create a system restore point before large batches
- Review each tab rather than bulk‑applying everything
- Skip actions already handled by `Setup-Windows.ps1` (e.g., Cortana, telemetry baseline)
- Document any manual tweaks you apply for future reproducibility

Why Not Integrated Directly?
- Philosophy here: minimal, opinionated, reproducible baseline
- WinUtil: broad surface area, user‑driven, potentially overreaching if automated blindly

---

## Post-Setup Recommendations

### 1. Configure 1Password
- Install browser extensions
- Enable SSH agent integration
- Set up autofill

### 2. Configure Cloud Sync
- Set up Google Drive sync folders
- Configure Obsidian vault sync
- Set up Syncthing for cross-device sync

### 3. Configure Development Tools
- Set up VSCode extensions and settings sync
- Configure Docker Desktop
- Set up language-specific tools (Node, Python, etc.)

### 4. Install Optional Tools

**In WSL:**
```bash
# Install tmux (if you want terminal multiplexing)
sudo apt-get install tmux

# Install additional CLI tools
sudo apt-get install htop ncdu fzf bat ripgrep fd-find
```

**In Windows:**
Consider installing:
- Keyboard remapping tools (if needed)
- Display calibration tools
- Game-specific tools
- Creative software

### 5. Backup Your Configuration

After you've customized everything, back up these files:
- `%USERPROFILE%\.wezterm.lua` (Windows)
- `~/.zshrc` (WSL)
- `~/.p10k.zsh` (WSL)
- `~/.gitconfig` (both Windows and WSL)
- Custom scripts and configs

Store them in this repository or a private dotfiles repo.

---

## Quick Reference Commands

### Windows PowerShell
```powershell
# Check WSL distributions
wsl --list --verbose

# Launch specific WSL distro
wsl -d Ubuntu

# Update WSL
wsl --update

# Check winget installed apps
winget list

# Search for apps
winget search "AppName"
```

### WSL/Zsh
```bash
# Source zsh config
source ~/.zshrc

# Reconfigure Powerlevel10k
p10k configure

# Update Oh My Zsh
omz update

# List all aliases
alias

# Zoxide stats
zoxide query --list
```

### Git
```bash
# Verify GPG signing
git config --global commit.gpgsign

# List GPG keys
gpg --list-secret-keys

# Test SSH
ssh -T git@github.com

# View GitHub CLI status
gh auth status
```

---

## Estimated Timeline

| Phase | Task | Time |
|-------|------|------|
| 1 | Windows Setup (Setup-Windows.ps1) | 30-45 min |
| 2 | WezTerm Setup (Setup-WezTerm.ps1) | 5 min |
| 2 | Zsh Setup (Setup-Zsh-Windows.ps1) | 10 min |
| 3 | GitHub Keys (Setup-GitHubKeys.ps1) | 5-10 min |
| 4 | Verification & Customization | 15-30 min |
| **Total** | | **65-100 min** |

Most time is spent waiting for application installations. You can do other tasks while scripts run.

---

## Scripts Overview

| Script | Platform | Purpose |
|--------|----------|---------|
| `Setup-Windows.ps1` | Windows | Main system setup, bloatware removal, app installation |
| `Setup-WezTerm.ps1` | Windows | Install and configure WezTerm terminal |
| `Setup-Zsh-Windows.ps1` | Windows | Wrapper to configure Zsh in WSL |
| `Setup-Zsh-Linux.sh` | WSL/Linux | Install Zsh, Oh My Zsh, P10k, and tools |
| `Setup-GitHubKeys.ps1` | Windows | Generate and upload SSH/GPG keys |
| `Get-InstalledSoftware.ps1` | Windows | Inventory current installations |

**Alternative scripts for other platforms:**
- `Setup-Zsh-macOS.sh` - For macOS setup
- `Setup-WezTerm.sh` - For macOS WezTerm setup
- `macos/Setup-GitHubKeys.sh` - For macOS GitHub keys
- `linux/Setup-GitHubKeys.sh` - For Linux GitHub keys

---

## Need Help?

- Check `Setup-Zsh-README.md` for detailed Zsh setup documentation
- Check `CLAUDE.md` for implementation details
- Review log files generated by scripts
- Refer to Josean's guide: https://www.josean.com/posts/how-to-setup-wezterm-terminal

---

**Enjoy your fresh, automated Windows setup! 🚀**
