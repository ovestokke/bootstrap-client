#!/bin/bash
#
# Linux Essentials Setup Script
#
# @author: Ovestokke
# @version: 2.0
#
# This script performs minimal bootstrap setup:
# - Installs basic system utilities (git, curl, wget, unzip)
# - Installs and initializes chezmoi with dotfiles
#
# All package installation, shell configuration, and dotfile management
# is handled by chezmoi via .chezmoiscripts
#
# Requirements: apt package manager (Debian/Ubuntu-based distributions)
#
# Usage:
#   bash linux/setup-essentials.sh
#

set -e

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

print_header "Linux Essentials Setup"
echo ""
print_info "This script will:"
echo "  • Install basic utilities (git, curl, wget, unzip)"
echo "  • Install chezmoi dotfiles manager"
echo "  • Initialize your dotfiles from GitHub"
echo ""
print_warning "All packages and configurations are managed by chezmoi"
echo ""

if ! command -v apt-get &> /dev/null; then
    print_error "This script requires apt package manager (Debian/Ubuntu-based distributions)"
    exit 1
fi

print_success "apt package manager detected"
echo ""

print_header "System Update"
print_info "Updating package lists..."
sudo apt-get update -qq
print_success "Package lists updated"
echo ""

print_header "Basic Utilities"

UTILITIES=("git" "curl" "wget" "unzip")

for util in "${UTILITIES[@]}"; do
    if command -v "$util" &> /dev/null; then
        print_success "$util is already installed"
    else
        print_info "Installing $util..."
        if sudo apt-get install -y "$util"; then
            print_success "$util installed"
        else
            print_error "$util installation failed"
            exit 1
        fi
    fi
done

echo ""

print_header "Development Tools"

print_info "Installing Neovim and dependencies..."

if ! grep -q "neovim-ppa/unstable" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
    print_info "Adding Neovim PPA..."
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update -qq
fi

DEVTOOLS=("neovim" "build-essential")

for tool in "${DEVTOOLS[@]}"; do
    if dpkg -l | grep -q "^ii  $tool "; then
        print_success "$tool is already installed"
    else
        print_info "Installing $tool..."
        if sudo apt-get install -y "$tool"; then
            print_success "$tool installed"
        else
            print_warning "$tool installation failed (non-critical)"
        fi
    fi
done

if command -v lazygit &> /dev/null; then
    print_success "lazygit is already installed"
else
    print_info "Installing lazygit..."
    if sudo apt-get install -y lazygit; then
        print_success "lazygit installed"
    else
        print_warning "lazygit installation failed (non-critical)"
    fi
fi

echo ""

print_header "chezmoi Installation & Initialization"

if command -v chezmoi &> /dev/null; then
    print_success "chezmoi is already installed"
    CHEZMOI_VERSION=$(chezmoi --version | head -n 1)
    print_info "Version: $CHEZMOI_VERSION"
else
    print_info "Installing chezmoi and initializing dotfiles..."
    echo ""
    
    read -p "Enter your GitHub username [ovestokke]: " GITHUB_USER
    GITHUB_USER=${GITHUB_USER:-ovestokke}
    
    print_info "Installing chezmoi from: https://github.com/$GITHUB_USER/dotfiles"
    echo ""
    
    if sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply "$GITHUB_USER"; then
        print_success "chezmoi installed and dotfiles applied"
        
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            export PATH="$HOME/.local/bin:$PATH"
        fi
    else
        print_error "chezmoi installation failed"
        exit 1
    fi
fi

echo ""

print_header "Setup Complete!"

echo ""
print_success "Bootstrap complete!"
echo ""
print_info "Installed:"
echo "  • Neovim + dependencies (build-essential)"
echo "  • lazygit (TUI for git)"
echo "  • All system packages via chezmoi (git, eza, zoxide, fzf, ripgrep, etc.)"
echo "  • Zsh + Oh My Zsh + Powerlevel10k (via chezmoi)"
echo "  • GitHub CLI (gh)"
echo "  • VS Code extensions (via chezmoi)"
echo "  • All dotfiles (.zshrc, .gitconfig, etc.)"
echo ""

if ! command -v zsh &> /dev/null; then
    print_warning "Zsh installation may still be in progress"
    echo ""
    print_info "If zsh is installed, set it as your default shell:"
    echo -e "  ${YELLOW}chsh -s \$(which zsh)${NC}"
else
    CURRENT_SHELL=$(echo $SHELL)
    if [[ "$CURRENT_SHELL" != *"zsh"* ]]; then
        echo ""
        read -p "Set Zsh as default shell? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            chsh -s $(which zsh)
            print_success "Default shell changed to Zsh"
            print_warning "Log out and log back in to apply shell change"
        else
            print_info "You can change your shell later with: chsh -s \$(which zsh)"
        fi
    else
        print_success "Zsh is already your default shell"
    fi
fi

echo ""
print_info "Next steps:"
echo "  1. Restart your terminal or log out/in"
echo "  2. Run Powerlevel10k configuration wizard:"
echo -e "     ${YELLOW}p10k configure${NC}"
echo ""
print_info "Chezmoi commands:"
echo "  chezmoi status              # View changes"
echo "  chezmoi diff                # See differences"
echo "  chezmoi apply               # Apply changes"
echo "  chezmoi edit ~/.zshrc       # Edit a dotfile"
echo "  chezmoi update              # Pull latest from GitHub"
echo ""
