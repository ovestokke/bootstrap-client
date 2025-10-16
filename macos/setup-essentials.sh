#!/bin/bash
#
# macOS Essentials Setup Script
#
# @author: Ovestokke
# @version: 1.0
#
# This script installs foundational tools:
# - Homebrew package manager
# - Git version control
# - chezmoi dotfile manager
# - Basic system utilities
#
# Usage:
#   bash macos/setup-essentials.sh
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

print_header "macOS Essentials Setup"
echo ""
print_info "This script will install:"
echo "  • Homebrew (package manager)"
echo "  • Git (version control)"
echo "  • chezmoi (dotfile manager)"
echo "  • Basic utilities (curl, wget)"
echo ""

#region Homebrew Installation

print_header "Homebrew Installation"

if command -v brew &> /dev/null; then
    BREW_VERSION=$(brew --version | head -n 1)
    print_success "Homebrew is already installed: $BREW_VERSION"
    
    print_info "Updating Homebrew..."
    if brew update &> /dev/null; then
        print_success "Homebrew updated"
    else
        print_warning "Homebrew update failed (non-critical)"
    fi
else
    print_warning "Homebrew is not installed"
    print_info "Homebrew is the package manager for macOS"
    echo ""
    
    read -p "Install Homebrew? (Y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_error "Cannot continue without Homebrew"
        exit 1
    fi
    
    print_info "Installing Homebrew..."
    echo ""
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    # Verify installation
    if command -v brew &> /dev/null; then
        BREW_VERSION=$(brew --version | head -n 1)
        print_success "Homebrew installed: $BREW_VERSION"
    else
        print_error "Homebrew installation failed"
        exit 1
    fi
fi

echo ""

#endregion

#region Git Installation

print_header "Git Installation"

if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    print_success "Git is already installed: $GIT_VERSION"
else
    print_warning "Git is not installed"
    print_info "Installing Git via Homebrew..."
    
    if brew install git; then
        GIT_VERSION=$(git --version)
        print_success "Git installed: $GIT_VERSION"
    else
        print_error "Git installation failed"
        print_info "You may need to install Xcode Command Line Tools:"
        print_info "  xcode-select --install"
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
    print_warning "chezmoi is not installed"
    print_info "Installing chezmoi via Homebrew..."
    
    if brew install chezmoi; then
        CHEZMOI_VERSION=$(chezmoi --version | head -n 1)
        print_success "chezmoi installed: $CHEZMOI_VERSION"
    else
        print_error "chezmoi installation failed"
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

# curl (usually pre-installed, but check)
if command -v curl &> /dev/null; then
    print_success "curl is installed"
else
    print_info "Installing curl..."
    brew install curl && print_success "curl installed" || print_warning "curl installation failed"
fi

# wget
if command -v wget &> /dev/null; then
    print_success "wget is installed"
else
    print_info "Installing wget..."
    if brew install wget; then
        print_success "wget installed"
    else
        print_warning "wget installation failed (non-critical)"
    fi
fi

echo ""

#endregion

#region Summary

print_header "Essentials Setup Complete!"

echo ""
print_success "Installed tools:"
echo "  • Homebrew: $(brew --version | head -n 1)"
echo "  • Git: $(git --version)"
echo "  • chezmoi: $(chezmoi --version | head -n 1)"
[[ $(command -v curl) ]] && echo "  • curl: $(curl --version | head -n 1)"
[[ $(command -v wget) ]] && echo "  • wget: $(wget --version | head -n 1)"

echo ""
print_info "Next steps:"
echo "  1. Run setup-terminal.sh to install WezTerm"
echo "  2. Run setup-shell.sh to configure Zsh + Powerlevel10k"
echo "  3. Run setup-neovim.sh to install LazyVim (optional)"
echo "  4. Run setup-github.sh to set up SSH/GPG keys"

echo ""
print_info "chezmoi quick reference:"
echo "  chezmoi status              # View status"
echo "  chezmoi diff                # See changes"
echo "  chezmoi apply               # Apply dotfiles"
echo "  chezmoi edit ~/.zshrc       # Edit a dotfile"
echo "  chezmoi update              # Pull and apply changes"

echo ""

#endregion
