#!/bin/bash
#
# Linux Essentials Setup Script
#
# @author: Ovestokke
# @version: 1.0
#
# This script installs foundational tools:
# - Git version control
# - chezmoi dotfile manager
# - Basic system utilities (curl, wget, unzip)
#
# Requirements: apt package manager (Debian/Ubuntu-based distributions)
#
# Usage:
#   bash linux/setup-essentials.sh
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

print_header "Linux Essentials Setup"
echo ""
print_info "This script will install:"
echo "  • Git (version control)"
echo "  • chezmoi (dotfile manager)"
echo "  • Basic utilities (curl, wget, unzip)"
echo ""

# Check for apt
if ! command -v apt-get &> /dev/null; then
    print_error "This script requires apt package manager (Debian/Ubuntu-based distributions)"
    exit 1
fi

print_success "apt package manager detected"
echo ""

#region System Update

print_header "System Update"
print_info "Updating package lists..."
sudo apt-get update -qq
print_success "Package lists updated"
echo ""

#endregion

#region Git Installation

print_header "Git Installation"

if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    print_success "Git is already installed: $GIT_VERSION"
else
    print_info "Installing Git..."
    if sudo apt-get install -y git; then
        GIT_VERSION=$(git --version)
        print_success "Git installed: $GIT_VERSION"
    else
        print_error "Git installation failed"
        exit 1
    fi
fi

echo ""

#endregion

#region chezmoi Installation

print_header "chezmoi Installation"

if command -v chezmoi &> /dev/null; then
    CHEZMOI_VERSION=$(chezmoi --version | head -n 1)
    print_success "chezmoi is already installed: $CHEZMOI_VERSION"
else
    print_info "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    
    # Add to PATH for this session
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Verify installation
    if command -v chezmoi &> /dev/null; then
        CHEZMOI_VERSION=$(chezmoi --version | head -n 1)
        print_success "chezmoi installed: $CHEZMOI_VERSION"
    else
        print_error "chezmoi installation failed"
        print_info "PATH may need to be updated. Add to ~/.zshrc or ~/.bashrc:"
        print_info "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        exit 1
    fi
fi

echo ""

#endregion

#region chezmoi Initialization

print_header "chezmoi Initialization"

# Check if chezmoi is already initialized
if [[ -d "$HOME/.local/share/chezmoi" ]]; then
    print_success "chezmoi is already initialized"
    print_info "Source directory: $HOME/.local/share/chezmoi"
    
    echo ""
    read -p "Re-initialize with a different repository? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping chezmoi initialization"
    else
        print_warning "This will backup your current dotfiles"
        mv "$HOME/.local/share/chezmoi" "$HOME/.local/share/chezmoi.bak.$(date +%Y%m%d%H%M%S)"
        print_success "Backed up existing chezmoi directory"
        
        # Re-run initialization
        REINIT=true
    fi
else
    REINIT=true
fi

if [[ "$REINIT" == "true" ]]; then
    echo ""
    print_info "chezmoi manages your dotfiles across machines"
    print_info "You can initialize it with your dotfiles repository"
    echo ""
    print_info "Example repositories:"
    echo "  • https://github.com/ovestokke/dotfiles"
    echo "  • https://github.com/yourusername/dotfiles"
    echo "  • git@github.com:yourusername/dotfiles.git"
    echo ""
    
    read -p "Initialize chezmoi with a dotfiles repository? (Y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_info "Skipping chezmoi initialization"
        print_info "You can initialize later with:"
        print_info "  chezmoi init --apply https://github.com/yourusername/dotfiles.git"
    else
        echo ""
        read -p "Enter your dotfiles repository URL (or press Enter to skip): " DOTFILES_REPO
        
        if [[ -z "$DOTFILES_REPO" ]]; then
            print_info "Skipping chezmoi initialization"
        else
            print_info "Initializing chezmoi with: $DOTFILES_REPO"
            echo ""
            
            if chezmoi init --apply "$DOTFILES_REPO"; then
                print_success "chezmoi initialized successfully"
                print_info "Your dotfiles have been applied to your home directory"
            else
                print_error "chezmoi initialization failed"
                print_warning "You can try manually with:"
                print_warning "  chezmoi init --apply $DOTFILES_REPO"
            fi
        fi
    fi
fi

echo ""

#endregion

#region Additional Utilities

print_header "Additional Utilities"

UTILITIES=("curl" "wget" "unzip")

for util in "${UTILITIES[@]}"; do
    if command -v "$util" &> /dev/null; then
        print_success "$util is already installed"
    else
        print_info "Installing $util..."
        if sudo apt-get install -y "$util"; then
            print_success "$util installed"
        else
            print_warning "$util installation failed (non-critical)"
        fi
    fi
done

echo ""

#endregion

#region Summary

print_header "Essentials Setup Complete!"

echo ""
print_success "Installed tools:"
[[ $(command -v git) ]] && echo "  • Git: $(git --version)"
[[ $(command -v chezmoi) ]] && echo "  • chezmoi: $(chezmoi --version | head -n 1)"
[[ $(command -v curl) ]] && echo "  • curl: $(curl --version | head -n 1)"
[[ $(command -v wget) ]] && echo "  • wget: $(wget --version | head -n 1)"
[[ $(command -v unzip) ]] && echo "  • unzip: $(unzip -v | head -n 1)"

echo ""
print_info "Next steps:"
echo "  1. Run setup-packages.sh to install all development tools"
echo "  2. Or manually install what you need:"
echo "     - Zsh: sudo apt-get install zsh"
echo "     - Neovim: Check setup-packages.sh for PPA setup"
echo "  3. Run setup-github-keys.sh to set up SSH/GPG keys"

echo ""
print_info "chezmoi quick reference:"
echo "  chezmoi status              # View status"
echo "  chezmoi diff                # See changes"
echo "  chezmoi apply               # Apply dotfiles"
echo "  chezmoi edit ~/.zshrc       # Edit a dotfile"
echo "  chezmoi update              # Pull and apply changes"

echo ""

#endregion
