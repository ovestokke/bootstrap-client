# Windows Scripts Status

## Active Scripts (v2.0)

### Core Setup Scripts
These are the main scripts used in the new modular architecture:

| Script | Purpose | Status |
|--------|---------|--------|
| **Setup-System.ps1** | System cleanup, bloatware removal, privacy settings, WSL | ✅ Active |
| **Setup-Apps.ps1** | Application installation with category selection | ✅ Active |
| **Setup-Essentials.ps1** | Git + chezmoi installation and dotfiles initialization | ✅ Active |
| **Setup-Packages.ps1** | Development tools (WezTerm, Neovim, Zsh, CLI tools) | ✅ Active |
| **Setup-PowerShell.ps1** | PowerShell profile and Oh My Posh configuration | ✅ Active |
| **Setup-Komorebi.ps1** | Tiling window manager installation | ✅ Active |

### Utility Scripts

| Script | Purpose | Status |
|--------|---------|--------|
| **Get-InstalledSoftware.ps1** | Generate inventory of installed software | ✅ Active |
| **Verify-WingetApps.ps1** | Verify winget package IDs | ✅ Active |
| **setup-github-keys.ps1** | Generate and upload SSH/GPG keys to GitHub | ✅ Active |

### App Lists

| File | Purpose | Status |
|------|---------|--------|
| **Apps-List-Basic.txt** | Essential apps (~10 apps) | ✅ Active |
| **Apps-List-Developer.txt** | Development tools | ✅ Active |
| **Apps-List-Gaming.txt** | Gaming platforms and peripherals | ✅ Active |
| **Apps-List-Productivity.txt** | Productivity and communication apps | ✅ Active |
| **Apps-List-Full.txt** | Deprecated - now a placeholder file explaining the split | ⚠️ Deprecated |

## Deprecated Scripts

### Replaced by New Architecture

| Old Script | Replaced By | Notes |
|------------|-------------|-------|
| **setup-windows.ps1** | Setup-System.ps1 + Setup-Apps.ps1 | Monolithic script split into modular components |
| **setup-wezterm.ps1** | Setup-Packages.ps1 | Now part of comprehensive package installation |
| **setup-zsh-windows.ps1** | Setup-Packages.ps1 | Zsh setup integrated into package installation |

### Status of Deprecated Scripts
- ❌ **setup-windows.ps1** (v1.4) - Superseded by modular v2.0 scripts
  - System setup → Setup-System.ps1
  - App installation → Setup-Apps.ps1
  
- ❌ **setup-wezterm.ps1** (v1.0) - Superseded by Setup-Packages.ps1
  - WezTerm installation now handled by Setup-Packages.ps1
  - Font installation integrated
  - Configuration managed by chezmoi
  
- ❌ **setup-zsh-windows.ps1** (v1.0) - Superseded by Setup-Packages.ps1
  - Zsh + Oh My Zsh + Powerlevel10k now in Setup-Packages.ps1
  - WSL distribution detection integrated
  - Modern CLI tools installation included

## Migration Guide

### From v1.x to v2.0

**Old workflow:**
```powershell
.\setup-windows.ps1      # Everything in one script
.\setup-wezterm.ps1      # Separate WezTerm setup
.\setup-zsh-windows.ps1  # Separate Zsh setup
```

**New workflow:**
```powershell
.\Setup-System.ps1       # System cleanup and WSL
.\Setup-Apps.ps1         # Choose app categories
.\Setup-Essentials.ps1   # Git + chezmoi
.\Setup-Packages.ps1     # All dev tools including WezTerm + Zsh
chezmoi apply            # Apply dotfiles
```

**Or use init-windows.ps1 menu:**
```powershell
.\init-windows.ps1       # Interactive menu with all options
# Choose option [8] for full automated workflow
```

## Recommended Action

### Files to Keep
- All Setup-*.ps1 scripts (v2.0)
- All Apps-List-*.txt files except Apps-List-Full.txt
- Get-InstalledSoftware.ps1
- Verify-WingetApps.ps1
- setup-github-keys.ps1

### Files to Remove or Archive
- setup-windows.ps1
- setup-wezterm.ps1
- setup-zsh-windows.ps1

### Documentation to Update
- windows/README.md - Update to reflect v2.0 architecture
- Root README.md - Update Windows setup instructions
- SETUP-GUIDE.md - Update workflow steps
- CONTRIBUTING.md - Update script references

## Architecture Benefits

The new v2.0 modular architecture provides:

1. **Separation of Concerns** - Each script has a single, clear purpose
2. **Flexibility** - Run only what you need, when you need it
3. **Maintainability** - Easier to update individual components
4. **Clarity** - Clear script names that describe actions, not just files
5. **Scalability** - Easy to add new category-specific scripts
6. **Better UX** - Interactive menu with descriptive options
