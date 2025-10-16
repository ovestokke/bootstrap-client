#!/bin/bash
#
# macOS Packages Installation Script
#
# @author: Ovestokke
# @version: 1.0
#
# This script installs development tools and applications.
# Configuration is managed by chezmoi - this script only installs packages.
#
# Installed packages:
# - WezTerm (terminal emulator)
# - Meslo Nerd Font (for icons)
# - Zsh plugins (Powerlevel10k, autosuggestions, syntax-highlighting)
# - Modern CLI tools (eza, zoxide, fzf, ripgrep, fd)
# - Neovim + LazyVim dependencies (lazygit)
# - GitHub CLI (gh)
# - GPG (for git signing)
#
# Usage:
#   bash macos/setup-packages.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_info() { echo -e "${CYAN}→${NC} $1"; }
print_header() { 
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
}

print_header "macOS Packages Installation"
echo ""
print_warning "This script installs packages only"
print_info "Configuration is managed by chezmoi"
echo ""

#region Check Prerequisites

if ! command -v brew &> /dev/null; then
    print_error "Homebrew is not installed"
    print_info "Please run setup-essentials.sh first"
    exit 1
fi

print_success "Homebrew is installed"
echo ""

#endregion

#region Terminal Emulator

print_header "Terminal Emulator"

# Install WezTerm
if brew list --cask wezterm &> /dev/null; then
    print_success "WezTerm is already installed"
else
    print_info "Installing WezTerm..."
    if brew install --cask wezterm; then
        print_success "WezTerm installed"
    else
        print_warning "WezTerm installation failed"
    fi
fi

# Install Nerd Font
if brew list --cask font-meslo-lg-nerd-font &> /dev/null; then
    print_success "Meslo Nerd Font is already installed"
else
    print_info "Installing Meslo Nerd Font..."
    brew tap homebrew/cask-fonts 2>/dev/null || true
    if brew install --cask font-meslo-lg-nerd-font; then
        print_success "Meslo Nerd Font installed"
    else
        print_warning "Font installation failed (non-critical)"
        print_info "You can install manually from: https://www.nerdfonts.com/"
    fi
fi

echo ""

#endregion

#region Zsh Packages

print_header "Zsh Packages"

ZSH_PACKAGES=("powerlevel10k" "zsh-autosuggestions" "zsh-syntax-highlighting")

for pkg in "${ZSH_PACKAGES[@]}"; do
    if brew list "$pkg" &> /dev/null; then
        print_success "$pkg is already installed"
    else
        print_info "Installing $pkg..."
        if brew install "$pkg"; then
            print_success "$pkg installed"
        else
            print_warning "$pkg installation failed"
        fi
    fi
done

echo ""

#endregion

#region Modern CLI Tools

print_header "Modern CLI Tools"

CLI_TOOLS=("eza" "zoxide" "fzf" "ripgrep" "fd")

for tool in "${CLI_TOOLS[@]}"; do
    if brew list "$tool" &> /dev/null; then
        print_success "$tool is already installed"
    else
        print_info "Installing $tool..."
        if brew install "$tool"; then
            print_success "$tool installed"
        else
            print_warning "$tool installation failed"
        fi
    fi
done

echo ""

#endregion

#region Neovim & Dependencies

print_header "Neovim & Dependencies"

NEOVIM_PACKAGES=("neovim" "lazygit")

for pkg in "${NEOVIM_PACKAGES[@]}"; do
    if brew list "$pkg" &> /dev/null; then
        print_success "$pkg is already installed"
    else
        print_info "Installing $pkg..."
        if brew install "$pkg"; then
            print_success "$pkg installed"
        else
            print_warning "$pkg installation failed"
        fi
    fi
done

# Check Neovim version
if command -v nvim &> /dev/null; then
    NVIM_VERSION=$(nvim --version | head -n 1)
    print_success "Neovim: $NVIM_VERSION"
    
    # Check if version is >= 0.11.2
    NVIM_VER_NUM=$(nvim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    REQUIRED_VER="0.11.2"
    
    if [[ "$(printf '%s\n' "$REQUIRED_VER" "$NVIM_VER_NUM" | sort -V | head -n1)" != "$REQUIRED_VER" ]]; then
        print_warning "Neovim version $NVIM_VER_NUM is below recommended $REQUIRED_VER"
        print_info "Run: brew upgrade neovim"
    fi
fi

echo ""

#endregion

#region Git Tools

print_header "Git Tools"

GIT_TOOLS=("gh" "gnupg")

for tool in "${GIT_TOOLS[@]}"; do
    if brew list "$tool" &> /dev/null; then
        print_success "$tool is already installed"
    else
        print_info "Installing $tool..."
        if brew install "$tool"; then
            print_success "$tool installed"
        else
            print_warning "$tool installation failed"
        fi
    fi
done

echo ""

#endregion

#region Oh My Zsh Installation

print_header "Oh My Zsh Framework"

# Check if Oh My Zsh is installed (needed for your dotfiles)
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_success "Oh My Zsh is already installed"
else
    print_info "Installing Oh My Zsh..."
    print_warning "This may prompt for input..."
    echo ""
    
    # Install Oh My Zsh (non-interactive)
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
    
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_success "Oh My Zsh installed"
    else
        print_warning "Oh My Zsh installation failed"
        print_info "You can install manually later"
    fi
fi

echo ""

#endregion

#region Summary

print_header "Package Installation Complete!"

echo ""
print_success "Installed packages:"
echo ""
echo "📱 Terminal:"
[[ $(brew list --cask wezterm 2>/dev/null) ]] && echo "  ✓ WezTerm"
[[ $(brew list --cask font-meslo-lg-nerd-font 2>/dev/null) ]] && echo "  ✓ Meslo Nerd Font"
echo ""
echo "🐚 Shell:"
[[ -d "$HOME/.oh-my-zsh" ]] && echo "  ✓ Oh My Zsh"
[[ $(brew list powerlevel10k 2>/dev/null) ]] && echo "  ✓ Powerlevel10k"
[[ $(brew list zsh-autosuggestions 2>/dev/null) ]] && echo "  ✓ zsh-autosuggestions"
[[ $(brew list zsh-syntax-highlighting 2>/dev/null) ]] && echo "  ✓ zsh-syntax-highlighting"
echo ""
echo "🛠️  Modern CLI:"
[[ $(brew list eza 2>/dev/null) ]] && echo "  ✓ eza (better ls)"
[[ $(brew list zoxide 2>/dev/null) ]] && echo "  ✓ zoxide (better cd)"
[[ $(brew list fzf 2>/dev/null) ]] && echo "  ✓ fzf (fuzzy finder)"
[[ $(brew list ripgrep 2>/dev/null) ]] && echo "  ✓ ripgrep (fast grep)"
[[ $(brew list fd 2>/dev/null) ]] && echo "  ✓ fd (fast find)"
echo ""
echo "💻 Development:"
[[ $(command -v nvim) ]] && echo "  ✓ Neovim $(nvim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
[[ $(brew list lazygit 2>/dev/null) ]] && echo "  ✓ lazygit"
[[ $(brew list gh 2>/dev/null) ]] && echo "  ✓ GitHub CLI"
[[ $(brew list gnupg 2>/dev/null) ]] && echo "  ✓ GPG"
echo ""

print_warning "IMPORTANT: Configuration is managed by chezmoi"
echo ""
print_info "Next steps:"
echo "  1. Ensure chezmoi is initialized with your dotfiles"
echo "     ${YELLOW}chezmoi status${NC}"
echo ""
echo "  2. Apply your dotfiles configuration"
echo "     ${YELLOW}chezmoi apply${NC}"
echo ""
echo "  3. Launch WezTerm and restart your terminal"
echo ""
echo "  4. Run Powerlevel10k configuration (first time only)"
echo "     ${YELLOW}p10k configure${NC}"
echo ""

print_info "Your dotfiles will configure:"
echo "  • WezTerm (~/.wezterm.lua)"
echo "  • Zsh (~/.zshrc, ~/.zprofile)"
echo "  • Neovim (~/.config/nvim/)"
echo "  • Git (~/.gitconfig)"
echo ""

#endregion
